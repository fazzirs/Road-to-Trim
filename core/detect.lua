-- core/detect.lua
-- Reads the player's current state from the game. In normal play this is the
-- only module that reads game state; the planner (core/planner.lua) never
-- touches the API directly, so it can be tested without the game.
-- Game API read here: Player, SkillType, config (Quest, Achievement, Inv),
-- var.VarPlayer and Inventory. No persistence is done here (main.lua saves
-- the name indexes).
--
-- Config and inventory lookups use pcall where shown and return the
-- documented fallbacks (nil, 0 or an empty list). Some availability and
-- config-property reads are direct, so callers must not assume every API
-- access is protected.

local Detect = {}

-- Skill names used in data/steps.lua map to the API's SkillType enum.
local SKILLS = {
    attack = "ATTACK", defence = "DEFENCE", strength = "STRENGTH",
    constitution = "HITPOINTS", ranged = "RANGED", prayer = "PRAYER",
    magic = "MAGIC", cooking = "COOKING", woodcutting = "WOODCUTTING",
    fletching = "FLETCHING", fishing = "FISHING", firemaking = "FIREMAKING",
    crafting = "CRAFTING", smithing = "SMITHING", mining = "MINING",
    herblore = "HERBLORE", agility = "AGILITY", thieving = "THIEVING",
    slayer = "SLAYER", farming = "FARMING", runecrafting = "RUNECRAFTING",
    hunter = "HUNTER", construction = "CONSTRUCTION", summoning = "SUMMONING",
    dungeoneering = "DUNGEONEERING", divination = "DIVINATION",
    invention = "INVENTION", archaeology = "ARCHAEOLOGY", necromancy = "NECROMANCY",
}

-- True when Player.IsAvailable says a character is in a world. main.lua gates
-- normal evaluation on it; it does not guarantee later config or inventory
-- reads succeed.
function Detect.ready()
    return Player ~= nil and Player.IsAvailable()
end

-- Real level from XP, ignoring boosts and the free-to-play cap.
function Detect.skillLevel(skillName)
    local enumName = SKILLS[skillName]
    if not enumName then return nil end
    local ok, level = pcall(function()
        return Player.GetLevelUncapped(SkillType[enumName])
    end)
    if ok then return level end
    return nil
end

-- Combat level. Some quests (and achievements) gate on it rather than a skill.
function Detect.combatLevel()
    local ok, level = pcall(function() return Player.GetCombatLevel() end)
    if ok then return level end
    return nil
end

-- Reverse of SKILLS: SkillType enum value -> our skill name. Built lazily
-- because SkillType only exists inside the game.
local skillByEnum = nil
local function skillNameFor(skillType)
    if not skillByEnum then
        skillByEnum = {}
        for name, enumName in pairs(SKILLS) do
            local ok, v = pcall(function() return SkillType[enumName] end)
            if ok and v ~= nil then skillByEnum[v] = name end
        end
    end
    return skillByEnum[skillType]
end

-- Quests are addressed by their display name ("Lunar Diplomacy"), because
-- Jagex's config names are not predictable (Cook's Assistant is COOK_QUEST).
-- The index below maps display name -> config name. It's built once by walking
-- config.Quest.FromID over the ID range, and main.lua saves it in PersistentDB
-- so later sessions skip the walk.
Detect.questIndex = nil

-- Walks FromID from 0 upwards. The ID range isn't documented, so instead of
-- assuming a maximum it stops after more than `gap` consecutive IDs with no
-- config, counted from the last hit. The gaps used (500 for quests, 2000 for
-- achievements) are search heuristics, not documented maxima: a larger real
-- gap would hide later configs. Only run when rebuilding the caches.
-- Returns index, count, highest ID seen.
local function walkConfigs(fromID, gap)
    local index, count, lastHit, id = {}, 0, 0, 0
    while id - lastHit <= gap do
        local ok, cfg = pcall(fromID, id)
        if ok and cfg ~= nil and cfg.name and cfg.name ~= "" then
            index[cfg.name] = cfg.configName
            count = count + 1
            lastHit = id
        end
        id = id + 1
    end
    return index, count, lastHit
end

function Detect.buildQuestIndex()
    local index, count, highest = walkConfigs(function(id) return config.Quest.FromID(id) end, 500)
    Detect.questIndex = index
    return count, highest
end

-- Normalise a name for matching: lower-case letters, digits and spaces, so
-- "A Fairy Tale I - Growing Pains" matches whatever dash or capitals the game
-- uses. A trailing "(miniquest)" or "(saga)" suffix, as in the game's quest
-- names ("Doric's Task I (miniquest)"), is removed too. The quest-index
-- sample taken on 2026-10-21 had no collisions after this; future names are
-- not guaranteed collision-free. core/planner.lua compares names the same way.
local function plainName(s)
    return (s:lower():gsub("%s*%((%a+)%)%s*$", function(kind)
        if kind == "miniquest" or kind == "saga" then return "" end
    end):gsub("[^%w ]", ""):gsub("%s+", " "))
end
local plainIndex, plainFrom = nil, nil

-- Finds a quest config by display name, then by the same name ignoring
-- capitals and punctuation, falling back to treating the string as a config
-- name. Returns nil if nothing matches.
local function questConfig(name)
    local configName = Detect.questIndex and Detect.questIndex[name] or nil
    if configName == nil and Detect.questIndex then
        if plainFrom ~= Detect.questIndex then
            plainIndex, plainFrom = {}, Detect.questIndex
            for display, cfgName in pairs(Detect.questIndex) do plainIndex[plainName(display)] = cfgName end
        end
        configName = plainIndex[plainName(name)]
    end
    local ok, cfg = pcall(function() return config.Quest[configName or name] end)
    if ok and cfg ~= nil then return cfg end
    return nil
end

-- Quest status plus the game's own prerequisites, so the planner doesn't need
-- hand-written requirements for quests. Returns nil if the quest isn't found.
--   finished, started, canStart : booleans
--   prereqSkills : { {skill = "crafting", level = 31, done = bool}, ... }
--   prereqQuests : { {name = "Lost City", done = bool}, ... }
-- The prerequisite lists and their completion flags explain blockers. A
-- failed prerequisite-list read becomes an empty list; the start, finish and
-- can-start flags are returned as the game gives them, never invented.
function Detect.quest(name)
    local cfg = questConfig(name)
    if cfg == nil then return nil end

    local prereqSkills = {}
    local ok = pcall(function()
        for i, req in ipairs(cfg.preReqSkills or {}) do
            local skill = skillNameFor(req.skillType)
            if skill then
                prereqSkills[#prereqSkills + 1] = {
                    skill = skill,
                    level = req.minimumLevel,
                    done = cfg.completedPreReqSkills[i] == true,
                }
            end
        end
    end)
    if not ok then prereqSkills = {} end

    local prereqQuests = {}
    ok = pcall(function()
        for i, q in ipairs(cfg.preReqQuests or {}) do
            prereqQuests[#prereqQuests + 1] = {
                name = q.name,
                done = cfg.completedPreReqQuests[i] == true,
            }
        end
    end)
    if not ok then prereqQuests = {} end

    return {
        finished = cfg.hasFinishedQuest,
        started = cfg.hasStartedQuest,
        canStart = cfg.canStartQuest,
        name = cfg.name,
        prereqSkills = prereqSkills,
        prereqQuests = prereqQuests,
    }
end

-- Achievements, like quests, are addressed by display name ("Easy As Pie")
-- and resolved through an index built once from config.Achievement.FromID.
-- There are a few thousand achievements, so the walk is longer than the
-- quest one; main.lua saves the result in PersistentDB.
Detect.achievementIndex = nil

-- `keepNames` (optional) is a set of display names; when given, only those
-- entries are kept, which keeps the persisted cache small. Saving the full
-- index failed in earlier testing; no fixed storage limit is established here.
function Detect.buildAchievementIndex(keepNames)
    local index, count, highest = walkConfigs(function(id) return config.Achievement.FromID(id) end, 2000)
    if keepNames then
        -- `false` records a requested name not found by the last scan. It
        -- does not trigger a rebuild by itself; a later rebuild searches all
        -- requested names again.
        local kept = {}
        for name in pairs(keepNames) do kept[name] = index[name] or false end
        index = kept
    end
    Detect.achievementIndex = index
    return count, highest
end

-- Resolve an achievement config by cached display name, with the config name
-- as a fallback. Nil means the lookup failed.
local function achievementConfig(name)
    local configName = Detect.achievementIndex and Detect.achievementIndex[name] or nil
    local ok, cfg = pcall(function() return config.Achievement[configName or name] end)
    if ok then return cfg end
    return nil
end

-- Complete means progress -2 (observed on the dev world, 19 October 2026,
-- across 188 items) or progress >= 10000 (the API docs' "complete" value).
-- Detect.achievement and the cape checklist reader (capeItem) share this one
-- rule, so they cannot disagree.
function Detect.isComplete(progress)
    return type(progress) == "number" and (progress == -2 or progress >= 10000)
end

function Detect.achievement(name)
    local cfg = achievementConfig(name)
    if cfg == nil then return nil end
    local p = cfg.progress
    return {
        done = Detect.isComplete(p),
        prereqsComplete = cfg.prereqsComplete,
        name = cfg.name,
    }
end

-- Known cape meta configs: Trimmed Completionist, Completionist and Master
-- Quest Cape. Each is an achievement whose requirements are other
-- achievements. Names and progress encodings were measured on the dev world
-- in October 2026; checklist sizes can change with game updates.
Detect.CAPES = {
    trim = "CHEEVO_TRIM_CAPE_META",
    comp = "CHEEVO_COMP_CAPE_META",
    mqc = "CHEEVO_MQC_META",
}

-- Every item on the Trim, Comp and MQC checklists, with its state and what it's
-- waiting on, read from the game. Rules measured on the dev world
-- (19 October 2026, 188 items):
--   progress -2      done (matched the cape lists' done flags exactly)
--   progress -1      locked; exactly the items with prereqsComplete = false
--   progress 0       not started
--   progress 1..9999 partly done, out of 10000
-- Cape metas are not steps: expand the known cape checklists separately.
-- MQC is required for Trim, including non-quest lore tasks the route does
-- not contain. Its already-routed quests are omitted to avoid duplicates.

-- Fallback skill names keyed by the zero-based numeric SkillType values seen
-- in achievement prerequisite records. Unknown values are shown as the raw
-- value rather than a guessed name.
local SKILL_BY_INDEX = { [0] = "attack", "defence", "strength", "constitution", "ranged", "prayer",
    "magic", "cooking", "woodcutting", "fletching", "fishing", "firemaking", "crafting",
    "smithing", "mining", "herblore", "agility", "thieving", "slayer", "farming",
    "runecrafting", "hunter", "construction", "summoning", "dungeoneering",
    "divination", "invention", "archaeology", "necromancy" }

-- Copy one achievement config into a plain table: state, progress, lifetime
-- tally, prerequisite completion records and incomplete requirement labels,
-- for Details and Progress. A missing lifetime tally is not reconstructed
-- from period-use counters.
local function capeItem(a, cape)
    local progress = a.progress or 0
    local item = {
        name = a.name, config = a.configName, cape = cape,
        -- Game category and subcategory, copied for classification. Category
        -- 4754 was observed to include activity achievements (Champions,
        -- Circus, Penguins, Ports, Clues ...); Views.isMinigame also uses
        -- Wiki metadata.
        category = a.category, subCategory = a.subCategory,
        state = (Detect.isComplete(progress) and "done") or (progress == -1 and "locked")
            or (progress > 0 and "partial") or "todo",
        pct = progress > 0 and progress / 10000 or 0,
        -- Whether the game gave a progress value at all: `pct` is 0 either
        -- way, so a long-run goal's count (core/views.lua goalProgress) can
        -- tell "not started" from "nothing read" and show no bar for the latter.
        hasProgress = type(a.progress) == "number",
        prereqs = { skills = {}, quests = {}, achievements = {} },
        remaining = {},
    }
    if a.tallyTarget and a.tallyTarget > 0 then
        item.tally = { have = a.tallyProgress, need = a.tallyTarget }
    end
    local pre = a.prereqs or {}
    for _, t in ipairs(pre.skills or {}) do
        local st = (t.skillTypes or {})[1]
        item.prereqs.skills[#item.prereqs.skills + 1] = {
            skill = SKILL_BY_INDEX[tonumber(tostring(st))] or tostring(st),
            level = t.totalLevels, done = t.isComplete == true }
    end
    for _, t in ipairs(pre.quests or {}) do
        item.prereqs.quests[#item.prereqs.quests + 1] = { name = t.quest and t.quest.name, done = t.isComplete == true }
    end
    for _, t in ipairs(pre.achievements or {}) do
        item.prereqs.achievements[#item.prereqs.achievements + 1] = { name = t.achievement and t.achievement.name, done = t.isComplete == true }
    end
    -- Sub-tasks still to do (boss kills, tackle boxes, ...), by name.
    local req = a.requirements or {}
    for _, kind in ipairs({ "achievements", "quests", "varTotals", "varTestBits" }) do
        for _, t in ipairs(req[kind] or {}) do
            if not t.isComplete then
                local label = (kind == "achievements" and t.achievement and t.achievement.name)
                    or (kind == "quests" and t.quest and t.quest.name) or t.description
                if label and label ~= "" then item.remaining[#item.remaining + 1] = label end
            end
        end
    end
    return item
end

-- Any achievement by name, in the same shape as a cape item: state
-- (done / locked / partial / todo), progress, and missing prerequisites.
-- Nil if the game doesn't know the name.
function Detect.achievementInfo(name)
    local cfg = achievementConfig(name)
    if cfg == nil then return nil end
    local ok, item = pcall(capeItem, cfg, nil)
    if ok then return item end
    return nil
end

-- Read the known cape metas' direct achievement requirements, deduplicated
-- by config name, leaving out nested metas and MQC quests already on the
-- route. A failed cape read is logged and a failed item read is skipped, so
-- the returned list can be incomplete.
function Detect.capeItems(route)
    local items, seen, routedQuests = {}, {}, {}
    for _, step in ipairs(route or {}) do
        if step.type == "quest" and step.quest then routedQuests[plainName(step.quest)] = true end
    end
    for _, cape in ipairs({ "trim", "comp", "mqc" }) do
        local ok = pcall(function()
            local cfg = config.Achievement[Detect.CAPES[cape]]
            for _, test in ipairs(cfg.requirements.achievements or {}) do
                local a = test.achievement
                local routed = cape == "mqc" and a and routedQuests[plainName(a.name)]
                if a and not routed and not seen[a.configName] and not a.configName:find("_META$") then
                    seen[a.configName] = true
                    local okItem, item = pcall(capeItem, a, cape == "mqc" and "trim" or cape)
                    if okItem then items[#items + 1] = item end
                end
            end
        end)
        if not ok then print("[Road to Trim] could not read the " .. cape .. " cape checklist") end
    end
    return items
end

-- Game time in whole minutes since 1970 UTC. Measured on the dev world:
-- 29873656 read at 14:16 UTC on 19 October 2026. Nil if unreadable.
function Detect.clockMinutes()
    local ok, v = pcall(function() return var.VarPlayer.CLOCK_TIME_DATE_MINUTES.value end)
    if ok and type(v) == "number" then return v end
    return nil
end

-- A game variable or varbit's value, by config name, falling back to its ID
-- (varbits use negative IDs in var.VarPlayer: varbit n is -(n+1), per the
-- RuneScape Wiki). Nil if neither reads.
function Detect.varValue(name, id)
    local ok, v = pcall(function() return var.VarPlayer[name].value end)
    if ok and type(v) == "number" then return v end
    if id then
        ok, v = pcall(function() return var.VarPlayer.FromID(id).value end)
        if ok and type(v) == "number" then return v end
    end
    return nil
end

-- Items are looked up by item ID (the number on the item's wiki page), not by
-- config name: Jagex's internal names aren't predictable, IDs are public.
-- Inv:GetTotal accepts an ID directly.

-- Count of an item in the backpack by item ID. Returns 0 if it is absent or
-- the read fails; this interface does not tell those cases apart.
function Detect.backpackCount(itemId)
    local ok, count = pcall(function()
        local inv = Inventory.Find(config.Inv.INV)
        return inv:GetTotal(itemId)
    end)
    if ok and count then return count end
    return 0
end

-- The bank is only readable while the bank interface is open (confirmed on the
-- dev world, 19 October 2026). So we remember what we saw the last time it
-- was open, keyed by item ID, and use that snapshot while it's closed.
-- Session memory only: main.lua never saves it (PersistentDB is shared by
-- every character on the computer) and empties it when a new session starts.
Detect.bankSnapshot = {}

-- True while the bank interface is open and its contents are readable.
-- Measured on the dev world: open = slotCount 1920 / usedSlotCount 955,
-- closed = both 0. `inv.valid` reads as nil either way, so don't rely on it.
local function bankOpen()
    local ok, inv = pcall(function() return Inventory.Find(config.Inv.BANK) end)
    return ok and inv ~= nil and (inv.slotCount or 0) > 0, inv
end

-- Diagnostic: what the API says about the bank right now, as one line.
-- An unused developer helper (no current caller), kept for bank checks.
function Detect.bankDebug(sampleItemId)
    local ok, inv = pcall(function() return Inventory.Find(config.Inv.BANK) end)
    if not ok then return "bank: Find errored (" .. tostring(inv) .. ")" end
    if inv == nil then return "bank: Find returned nil" end
    local okT, total = pcall(function() return inv:GetTotal(sampleItemId) end)
    return string.format("bank: valid=%s slots=%s used=%s free=%s item%d=%s",
        tostring(inv.valid), tostring(inv.slotCount), tostring(inv.usedSlotCount),
        tostring(inv.freeSlotCount), sampleItemId, okT and tostring(total) or ("err " .. tostring(total)))
end

-- Count of an item in the bank: live while the bank is open, otherwise the
-- session snapshot. Returns 0 when no count has been recorded.
function Detect.bankCount(itemId)
    local open, inv = bankOpen()
    if open then
        local ok, count = pcall(function() return inv:GetTotal(itemId) end)
        if ok and count then
            Detect.bankSnapshot[tostring(itemId)] = count
            return count
        end
    end
    return Detect.bankSnapshot[tostring(itemId)] or 0
end

-- Re-reads the bank count of each item ID into the snapshot, if the bank is
-- open right now. main.lua calls this on inventory events, before the
-- debounced evaluation, so a withdrawal is not counted twice (backpack plus
-- a stale bank count). Returns true if the bank was open.
function Detect.refreshBank(itemIds)
    if not bankOpen() then return false end
    for _, id in ipairs(itemIds) do Detect.bankCount(id) end
    return true
end

-- Items the player "has" = backpack + bank. Used by the readiness rule.
function Detect.itemCount(itemId)
    return Detect.backpackCount(itemId) + Detect.bankCount(itemId)
end

-- Account mode is not read from the game. The player selects it in
-- Settings > Account and main.lua saves it as a preference. A variable watch
-- on the dev world (19 October 2026) did not establish a reliable
-- account-mode read.

return Detect
