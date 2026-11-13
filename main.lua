-- Road to Trim - main.lua
-- Entry point. Reads game state through core/detect.lua, builds the planner
-- and view results (core/planner.lua, core/views.lua) and updates the plugin
-- window (ui/panel.lua).
-- Game API used here: Event subscriptions, and PersistentDB for local
-- preferences and the quest/achievement config-name caches.
-- Guide rows print to the console only with Views.DEBUG or in the basic
-- fallback window. Optional developer diagnostics are switched off below.
--
-- Console: prf (rescan), pon trim-planner (enable), prl trim-planner (reload).

local Detect = require("core/detect")
local Planner = require("core/planner")
local Steps = require("data/steps")
local Methods = require("data/methods")
local masterAnglerIncomplete = false
-- One contextual lookup feeds Guide, compact and route Details alike.
local TrainingMethods = { lookup = function(skill, level, mode)
    local method = Methods.lookup(skill, level, mode)
    if skill == "fishing" and masterAnglerIncomplete then
        return { name = (method and (method.name .. "; ") or "")
            .. "also try Fish Flingers: fisherman outside the Fishing Guild; earn Fishing XP while working toward Master Angler's champion's tackle box",
            wiki = method and method.wiki or "Fish Flingers" }
    end
    return method
end }
local TimeGated = require("data/timegated")
local AchData = require("data/achievements")
local Icons = require("data/icons")
local ItemSources = require("data/itemsources")
local AchTargets = require("data/achievementtargets")
local AchGuidance = require("data/achievementguidance")
local LongAchievements = require("data/longachievements")
local QuestStarts = require("data/queststarts")
local TravelIcons = require("data/travelicons")
local NearLodestones = require("data/nearlodestones")
local NearSpells = require("data/nearspells")
local Phases = require("data/phases")
local Views = require("core/views")
local Path = require("core/path")
local Clock = require("core/clock")
local Alerts = require("core/alerts")
local Followups = require("core/followups")
local Panel = require("ui/panel")

-- Dev-world measurements (core/diagnostics.lua). Off for normal use.
local DIAGNOSTICS = false
-- The icon picker alone (core/diagnostics.lua dumpIcons): the teleport spell
-- and lodestone sprites, searched by the game's own sprite names, printed to
-- the console. nil = off; a search string turns it on for a dev session.
local ICON_PICKER = nil
local Diag = (DIAGNOSTICS or ICON_PICKER) and require("core/diagnostics") or nil
local diagDone = false

-- PersistentDB stores local preferences (settings) and the quest/achievement
-- display-name caches. The store is shared by every character on the
-- computer (Jagex developer docs, 20 October 2026), so character-specific
-- data (bank counts, skipped quests, "Done for now", dismissed follow-ups)
-- stays in memory for this session only.
-- New settings show the welcome until it is answered (welcomeSeen = false).
-- Settings saved by an older version have no welcomeSeen, so existing users
-- do not see it.
local settings = PersistentDB:GetStructuredData("settings") or {
    mode = "ironman",   -- "ironman" | "hardcore" | "group" | "main"; selected in Settings > Account
    welcomeSeen = false,
}
-- Startup migration: remove obsolete saved keys that older versions wrote.
-- settings.pathSkipped and settings.postponed held character data (skips);
-- settings.highlights belonged to removed world outlines; settings.guideStyle
-- belonged to a removed Guide-style choice. Settings are saved once, and only
-- if something changed; every other preference is kept as it was.
local settingsChanged = false
if settings.pathSkipped ~= nil or settings.postponed ~= nil or settings.highlights ~= nil
    or settings.guideStyle ~= nil then
    settings.pathSkipped, settings.postponed, settings.highlights, settings.guideStyle = nil, nil, nil, nil
    settingsChanged = true
end
-- Keep a recognised saved account mode; a missing or unsupported value
-- defaults to Ironman.
local ACCOUNT_MODES = { ironman = true, hardcore = true, group = true, main = true }
if not ACCOUNT_MODES[settings.mode] then
    settings.mode = "ironman"
    settingsChanged = true
end
-- Account labels (shown in Settings and on Progress) and the values saved in
-- `settings`. Hardcore and Group get Ironman advice; Main may get purchase
-- advice. Labels are short so all four fit the segmented row.
local MODE_CHOICES = { { "Ironman", "ironman" }, { "Hardcore", "hardcore" }, { "Group", "group" }, { "Main", "main" } }
local function labelOf(choices, value)
    for _, c in ipairs(choices) do if c[2] == value then return c[1] end end
    return nil
end
-- Activities filter, saved as settings.activityFilter. Use the saved value
-- if it is recognised; otherwise migrate the older timedFilter key;
-- otherwise use Views.DEFAULT_FILTER. Legacy labels are translated through
-- Views.FILTER_MIGRATION. An explicit saved "All" is kept. timedFilter is
-- deleted and the change is saved with the other migrations.
local FILTER_OK = {}
for _, f in ipairs(Views.FILTERS) do FILTER_OK[f] = true end
local function knownFilter(v)
    if FILTER_OK[v] then return v end
    return v ~= nil and Views.FILTER_MIGRATION[v] or nil
end
do
    local chosen = knownFilter(settings.activityFilter) or knownFilter(settings.timedFilter)
    if chosen ~= settings.activityFilter or settings.timedFilter ~= nil then
        settings.activityFilter, settings.timedFilter = chosen, nil
        settingsChanged = true
    end
end
-- The filter Activities shows: the saved choice, else Open now.
local function activityFilter() return settings.activityFilter or Views.DEFAULT_FILTER end
if settingsChanged then PersistentDB:SetStructuredData("settings", settings) end
for _, oldKey in ipairs({ "bankSnapshot", "manualDone" }) do
    if PersistentDB:Get(oldKey) ~= nil then PersistentDB:Delete(oldKey) end
end
-- What the bank held the last time it was open this session (Detect.bankCount).
Detect.bankSnapshot = {}
-- Time-gated "Done for now" on the Guide's card: activity -> game minute
-- it's hidden until (core/path.lua).
local pathSkipped = {}
-- Display name -> config name, for quests and achievements. Built once, then saved.
Detect.questIndex = PersistentDB:GetStructuredData("questIndex")
Detect.achievementIndex = PersistentDB:GetStructuredData("achievementIndex")
local warnedOnce = {}   -- warnings already printed this session

local lastEvaluation = nil
local lastInfo = nil        -- achievement lookup from the last evaluation, reused by clicks
local lastSignature = nil   -- what we showed last time; redraw only on change
-- Base compact row budget for the entry, its items and its timer
-- (ui/panel.lua COMPACT_MAX_LINES). The title's second line, the
-- instruction toggle and the instruction rows use separate UI pools
-- (ui/panel.lua COMPACT_INSTR_LINES).
local COMPACT_ROWS = 5
-- Entry key whose compact instructions are open, or nil when closed.
-- Session only: closes on reload or when the card moves to another entry,
-- but survives switching between the full and compact views.
local compactOpenKey = nil
local lastCompactKey = nil  -- the entry the card shows now, for the button's click
-- Skipped quests ("Skip until reset"): step id -> game minute of the next
-- daily reset (00:00 game time), when the quest comes back. Session only,
-- because PersistentDB is shared across characters. Cleared on plugin load
-- and by newSession below (GameStateChanged; may also fire on a world hop,
-- unverified). The startup migration removes legacy saved skips.
local postponed = {}
-- "Just opened up" achievements after a quest finished this session; in
-- memory only (core/followups.lua). lastFollowups = the names last shown,
-- for "Dismiss these".
local followups = Followups.new()
local lastFollowups = {}
-- The last evaluation's cape items (suggestable), so the dismissed list
-- (Settings > Skipped and hidden) can tell which ones are finished now.
local lastCapeItems = {}
local dirty = true          -- set by events; evaluated on the next server tick
local ticksSinceChange = 0  -- small debounce so a burst of events = one evaluation
local ticksDirty = 0        -- ticks since the pending work was first marked (the cap below)
-- Evaluate after three quiet server ticks, or after this many pending ticks
-- even if events keep arriving. Training or banking can fire an event every
-- tick, so this bounds the delay; the time in seconds depends on tick timing.
local MAX_DIRTY_TICKS = 5

-- Guide row budgets, counted after wrapping (the tab scrolls).
-- TOP_ROWS covers the progress line, the welcome, the DO THIS NOW card,
-- "Skipped: N" and THEN. GUIDE_ROWS adds the lower lists (ALSO AVAILABLE,
-- JUST OPENED UP, CAN DO NOW), which use what is left; the lowest list gives
-- way first. Both fit the 120 rows ui/panel.lua allocates for the Guide
-- (ROWS_PER_PAGE[1], also used by Details and the "+N more" lists).
local TOP_ROWS = 40
local GUIDE_ROWS = 70
-- Lower Guide list headings, and the maximum entries each shows before
-- "+N more". ALSO AVAILABLE status chips share the Guide's pill pool
-- (GUIDE_PILLS, ui/panel.lua SHAPE_POOLS[1].pills) with the current card's
-- chip, its action button and the timer chips.
local GUIDE_LISTS = { also = "ALSO AVAILABLE", new = "JUST OPENED UP", cando = "CAN DO NOW" }
local ALSO_MAX, NEW_MAX, CANDO_MAX = 3, 3, 5
local GUIDE_PILLS = 10
-- Each list's every entry from the last evaluation, for its "+N more" page
-- ("guidelist:also", "guidelist:new:2", ...): key -> { title, rows }.
local lastGuideLists = {}
local ACTIVITY_ROWS = 110   -- rows on the Activities tab (ui/panel.lua ROWS_PER_PAGE[2]); more aren't shown (Views.activities counts them)
local PROGRESS_ROWS = 88    -- rows on the Progress tab (ui/panel.lua ROWS_PER_PAGE[3]); the long-run goals take what's left
-- Details replace the list on the tab they were opened from: Guide (1),
-- Activities (2) or Progress (3), with a Back line to return. Settings is
-- tab 4 (ui/panel.lua TAB_NAMES). showingDetails tracks each tab's Details
-- state; nil means the tab shows its list.
local PROGRESS_PAGE = 3
local DETAIL_PAGES = 3      -- tabs that show Details in place: 1 to this
local detailPage = 1
local selectedName = nil
local showingDetails, listOffset = {}, {}   -- tab -> details shown on it; where its list was scrolled
-- A cape section's list on Progress ("section:Lore") that an achievement's
-- Details was opened from: "Back" returns to it, where it was scrolled,
-- then "Back" again to the Progress tab. { name, offset } or nil.
local detailParent = nil
local lastSections = nil    -- Views.sectionTallies from the last evaluation, for a section's list
local isMinigame = nil      -- set once the data is loaded (Views.isMinigame)
-- Normalise achievement names for matching: lower case, letters, digits and
-- single spaces only, so any kind of apostrophe still matches.
-- Long-run goals (data/longachievements.lua) are never suggested.
local function plainName(s) return (s:lower():gsub("[^%w ]", ""):gsub("%s+", " ")) end
local guidanceByName = {}
for name, instructions in pairs(AchGuidance) do guidanceByName[plainName(name)] = instructions end
local function guidanceFor(name) return name and guidanceByName[plainName(name)] or nil end
local longNames, longHow = {}, {}
for _, e in ipairs(LongAchievements) do
    local name = type(e) == "table" and e[1] or e
    longNames[plainName(name)] = true
    if type(e) == "table" and e.how then longHow[plainName(name)] = e.how end
end
local function isLong(it) return it.name ~= nil and longNames[plainName(it.name)] == true end
-- NEXT ACTIONS in an achievement's Details: its authored guidance
-- (data/achievementguidance.lua), else a long-run goal's "how" text
-- (data/longachievements.lua) as one action.
local function instructionsFor(name)
    local guide = guidanceFor(name)
    if guide then return guide end
    local how = name and longHow[plainName(name)]
    return how and { how } or nil
end
local achDesc = nil         -- data/achievements.lua descriptions by plain name, made when first needed
local function longDescOf(it)
    if achDesc == nil then
        achDesc = {}
        for name, a in pairs(AchData) do if a.desc then achDesc[plainName(name)] = a.desc end end
    end
    return it.name and achDesc[plainName(it.name)] or nil
end
local longReminded = false  -- the long-run goals' reminder pop-up shown this session
local DEFAULT_ALERTS = { reset = true, soon = true, unlock = true, long = true }
-- Default the newer long-run alert switch to on. Older switches are left
-- alone: an older version saved "off" by leaving the key out, so a missing
-- older key may mean off.
if settings.alertKinds and settings.alertKinds.long == nil then settings.alertKinds.long = true end

local function capitalise(s) return s:sub(1, 1):upper() .. s:sub(2) end

-- What the current step still needs: one short line each with a red
-- circle, and its wiki target. Quests get no wiki link (Quest Helper).
local function missingLines(r)
    local out = {}
    for _, m in ipairs(r.missing) do
        if m.kind == "skill" then
            local text = string.format("%s %d -> %d", capitalise(m.skill), m.have, m.need)
            if m.method then text = text .. "  -  " .. m.method.name end
            out[#out + 1] = { text, m.method and m.method.wiki or (capitalise(m.skill) .. " training") }
        elseif m.kind == "combat" then
            out[#out + 1] = { string.format("Combat level %d -> %d", m.have, m.need), "Combat level" }
        elseif m.kind == "quest" then
            out[#out + 1] = { m.name .. "  (quest first)", nil }
        elseif m.kind == "step" then
            out[#out + 1] = { Views.plainTitle(m) .. "  (first)", nil }
        elseif m.kind == "achievement" then
            out[#out + 1] = { m.name .. "  (first)", m.name }
        else
            out[#out + 1] = { m.text or "?", nil }
        end
    end
    for _, item in ipairs(r.items) do
        local have = item.have > 0 and string.format("  (have %d)", item.have) or ""
        out[#out + 1] = { string.format("%dx %s%s", item.need, item.name, have), item.name }
    end
    return out
end

-- The icon in front of a Guide entry: quest, recognised minigame, or
-- achievement. A missing quest icon stays nil instead of falling through to
-- the achievement icon.
local function markerFor(step)
    if step.type == "quest" then return Icons.quest end
    local name = step.achievement or step.title
    if isMinigame and name and isMinigame({ name = name }) then return Icons.minigame end
    return Icons.achievement
end

-- Offer a teleport spell as a travel reference when its recorded spellbook
-- quest (Ancient Magicks, Lunar), any quest the spell itself needs, and its
-- Magic level (uncapped) are met. Unknown reads exclude it. This does not
-- check present castability, the current spellbook, runes or travel
-- restrictions.
local function spellReady(name)
    local sp = TravelIcons.spells[name]
    if not (sp and sp.level) then return false end   -- no level read yet: not offered
    -- A book other than the standard one, with no quest on record, is locked.
    if sp.book ~= "standard" and not TravelIcons.spellbooks[sp.book] then return false end
    local function done(q)
        if not q then return true end
        local d = Detect.quest(q)
        return d ~= nil and d.finished == true
    end
    local level = Detect.skillLevel("magic")
    return done(TravelIcons.spellbooks[sp.book]) and done(sp.quest) and level ~= nil and level >= (sp.level or 1)
end

-- Whether the player has a lodestone unlocked, from the game's own flag
-- (TravelIcons.lodestone[...].unlock): true, false, or nil when it can't be
-- read or there's no flag for it.
local function lodestoneOpen(place)
    local L = TravelIcons.lodestone[place]
    if L and L.unlockQuest then
        local q = Detect.quest(L.unlockQuest)
        if q == nil or q.finished == nil then return nil end
        return q.finished == true
    end
    if not (L and L.unlock) then return nil end
    local v = Detect.varValue(L.unlock, L.unlockId)
    if v == nil then return nil end
    return v == 1
end

-- Where a quest starts (data/queststarts.lua): { "Start: ...", wiki = NPC
-- page, ways = travel rows }, or nil. Shown only when both game flags
-- explicitly say not started and not finished; unknown flags omit it here.
-- Details can still show the static references.
local function startText(step)
    local s = step.type == "quest" and QuestStarts[step.id]
    if not s then return nil end
    local q = step.quest and Detect.quest(step.quest)
    if not (q and q.started == false and q.finished == false) then return nil end
    local ways = {}
    for _, w in ipairs(s.ways or {}) do
        if not w.spell or spellReady(w.spell) then ways[#ways + 1] = w end
    end
    -- List nearer teleport references (data/nearspells.lua) that pass
    -- spellReady's recorded quest and level checks.
    for _, name in ipairs(NearSpells[step.id] or {}) do
        if spellReady(name) then ways[#ways + 1] = { spell = name } end
    end
    -- If a named lodestone is known to be locked, append one nearest unlocked
    -- alternative from data/nearlodestones.lua.
    local named, anyLocked = {}, false
    for _, w in ipairs(ways) do
        if w.lode then
            named[w.lode] = true
            if lodestoneOpen(w.lode) == false then anyLocked = true end
        end
    end
    if anyLocked then
        for _, place in ipairs(NearLodestones[step.id] or {}) do
            if not named[place] and lodestoneOpen(place) == true then
                ways[#ways + 1] = { lode = place, text = "the nearest you have unlocked" }
                break
            end
        end
    end
    -- Fairy ring reference: listed first once A Fairy Tale II is finished.
    -- While the quest is only started, list it with a condition, because the
    -- Fairy Godfather's permission stage is not read here.
    if s.ring then
        local ft = Detect.quest("A Fairy Tale II - Cure a Queen")
        if ft and ft.finished == true then
            table.insert(ways, 1, { ring = s.ring, text = "(dramen or lunar staff, unless Fairy Tale III is done)" })
        elseif ft and ft.started == true then
            ways[#ways + 1] = { ring = s.ring, text = "once the Fairy Godfather lets you in" }
        end
    end
    -- One row per travel reference, prefixed "Travel:" or "or", with the
    -- applicable icon beside the place name.
    local rows = {}
    for i, w in ipairs(ways) do
        local text, icon
        if w.ring then
            text, icon = "fairy ring " .. w.ring .. " " .. w.text, { sprite = TravelIcons.fairyRing }
        elseif w.lode then
            -- Unlocked: its coloured crest; locked: its grey one, said in words;
            -- not readable: the Home Teleport icon and "(if activated)".
            local L, open = TravelIcons.lodestone[w.lode], lodestoneOpen(w.lode)
            local sprite = (open == true and L and L.crest) or (open == false and L and L.locked) or TravelIcons.homeTeleport
            text = w.lode .. " lodestone" .. (w.text and (", " .. w.text) or "")
                .. (open == false and " (locked)" or (open == nil and w.activate) and " (if activated)" or "")
            icon = sprite and { sprite = sprite } or nil
        elseif w.spell then
            local sp = TravelIcons.spells[w.spell]
            text = w.spell .. (w.text and (", " .. w.text) or "")
            icon = sp and sp.sprite and { sprite = sp.sprite } or nil
        elseif w.item then
            text, icon = w.text, { item = w.item }
        else
            text, icon = w.text, { sprite = TravelIcons.transport }
        end
        rows[#rows + 1] = { (i == 1 and "Travel: " or "or ") .. text, icon = icon }
    end
    return { "Start: " .. s[1], wiki = s.wiki, ways = rows }
end

-- The Details view's static Travel lines: every way with its place's name, and the
-- quest's fairy ring code as an option once fairy rings are open.
local function travelInfo(s)
    local lines = {}
    for i, w in ipairs(s.ways or {}) do
        local sp = w.spell and TravelIcons.spells[w.spell]
        local text = w.lode and (w.lode .. " lodestone" .. (w.text and (", " .. w.text) or "") .. (w.activate and " (if activated)" or ""))
            or w.spell and (w.spell .. " (" .. (sp and sp.level or "?") .. " Magic)" .. (w.text and (", " .. w.text) or ""))
            or w.text
        lines[#lines + 1] = (i == 1 and "Travel: " or "or ") .. text
    end
    if s.ring then lines[#lines + 1] = "or fairy ring " .. s.ring .. ", once fairy rings are open" end
    return lines
end

local function selectFor(step)
    if step.type == "cape" then return step.title end
    if step.type == "achievement" then return step.achievement end
    return "step:" .. step.id      -- quests and other route steps
end

-- Wiki page for a step's line (right-click > Wiki). Quests too: the
-- walkthrough is Quest Helper's (a separate plugin, if it covers the quest);
-- the quest's Wiki page is there for anyone who wants it.
local function stepWiki(step)
    if step.type == "quest" then return step.quest end
    if step.type == "achievement" then return step.achievement end
    return step.title
end

-- Merge skill requirements for Details (`lists` are { { skill, level }, ... }
-- lists); a skill named twice keeps its highest target. Attach the player's
-- uncapped level (Detect.skillLevel). An unreadable level stays nil, shows as
-- "?" and never counts as met.
local function skillsSnapshot(lists)
    local targets, order = {}, {}
    for _, list in ipairs(lists) do
        for _, s in ipairs(list) do
            if type(s.skill) == "string" and type(s.level) == "number" then
                if targets[s.skill] == nil then order[#order + 1] = s.skill end
                targets[s.skill] = math.max(targets[s.skill] or 0, s.level)
            end
        end
    end
    local out = {}
    for _, skill in ipairs(order) do
        out[#out + 1] = { skill = skill, need = targets[skill], have = Detect.skillLevel(skill) }
    end
    return out
end
-- A route step's: the game's own prerequisites for its quest
-- (Detect.quest, which the planner also reads) and the route data's
-- (requires.skills, in name order so the list is stable).
local function stepSkills(r)
    local step = r.step
    local lists = {}
    if step.type == "quest" and step.quest then
        local q = Detect.quest(step.quest)
        lists[#lists + 1] = q and q.prereqSkills or {}
    end
    local fromRoute, names = {}, {}
    local required = step.requires and step.requires.skills or {}
    for skill in pairs(required) do names[#names + 1] = skill end
    table.sort(names)
    for _, skill in ipairs(names) do fromRoute[#fromRoute + 1] = { skill = skill, level = required[skill] } end
    lists[#lists + 1] = fromRoute
    return skillsSnapshot(lists)
end
-- An achievement's: its prerequisites as the game lists them.
local function achievementSkills(it)
    return skillsSnapshot({ it and it.prereqs and it.prereqs.skills or {} })
end

-- What was clicked, for its in-place Details view: a route step ("step:<id>", e.g. a
-- quest), the postponed list, or an achievement by name, from the last
-- evaluation. Cheap, so a click can call it directly instead of waiting for
-- the next evaluation.
local function buildSelected()
    if selectedName == "postponed" then   -- the Guide's "Skipped: N" line
        local list, now = {}, Detect.clockMinutes()
        for id, untilMin in pairs(postponed) do
            local r = lastEvaluation and lastEvaluation.results[id]
            list[#list + 1] = { id = id, untilMin = untilMin, title = r and Views.plainTitle(r.step) or id }
        end
        return Views.postponed(list, now)
    end
    -- Settings > Skipped and hidden > Dismissed "just opened up".
    if selectedName == "followups" then
        return Views.dismissedFollowups(Followups.dismissedList(followups, lastCapeItems))
    end
    -- The Guide's "+N more" under ALSO AVAILABLE, JUST OPENED UP or CAN DO
    -- NOW: that whole list, a page at a time ("guidelist:also" is its first
    -- page, "guidelist:cando:2" its second; Views.guideList).
    local listKey, listPage = (selectedName or ""):match("^guidelist:(%a+):?(%d*)$")
    if listKey and GUIDE_LISTS[listKey] then
        local l = lastGuideLists[listKey]
        return Views.guideList(listKey, GUIDE_LISTS[listKey], l and l.rows or {}, tonumber(listPage) or 1)
    end
    -- Progress > Cape achievements > a section: what's left in it, a page
    -- at a time ("section:Lore" is its first page, "section:Lore:3" its third).
    local sectionName = selectedName and selectedName:match("^section:(.+)$")
    if sectionName then
        local name, page = sectionName:match("^(.-):(%d+)$")
        name = name or sectionName
        for _, sec in ipairs(lastSections or {}) do
            if sec.name == name then return Views.sectionLeft(sec, tonumber(page) or 1) end
        end
        return { { "Nothing to show for that section yet: the checklist hasn't been read.", tone = "dim" } }
    end
    local stepId = selectedName and selectedName:match("^step:(.+)$")
    if stepId and lastEvaluation and lastEvaluation.results[stepId] then
        local s = QuestStarts[stepId]
        local r = lastEvaluation.results[stepId]
        return Views.stepDetails(r, settings.mode, TrainingMethods, ItemSources,
            s and { "Start: " .. s[1], wiki = s.wiki, travel = travelInfo(s) } or nil, stepSkills(r))
    end
    -- An achievement. One the game didn't return (a "?" member of a section's
    -- list on Progress) gets its static data under its name, marked not read.
    local it = selectedName and lastInfo and lastInfo(selectedName) or nil
    return Views.details(it, selectedName and AchData[selectedName], selectedName and AchTargets[selectedName], instructionsFor(selectedName),
        (selectedName and AchData[selectedName]) and selectedName or nil, it and achievementSkills(it) or nil)
end

-- What was clicked, in place of the list on the tab it was clicked on: a
-- "Back to ..." line, then the details; "help" is how the plugin works (from
-- the welcome, or the Help button). Nil when nothing is open.
-- The Back label names the parent: a cape section ("Back to Lore"), a lower
-- Guide list ("Back to Also available"), or the originating tab ("Back to
-- Guide", "Back to Activities", "Back to Progress").
local PAGE_NAMES = { "Guide", "Activities", "Progress" }
local function backLabel()
    local section = detailParent and detailParent.name:match("^section:([^:]+)")
    local list = detailParent and GUIDE_LISTS[detailParent.name:match("^guidelist:(%a+)") or ""]
    if list then section = list:sub(1, 1) .. list:sub(2):lower() end
    return "Back to " .. (section or PAGE_NAMES[detailPage] or "Guide")
end
local function buildDetails()
    if selectedName == nil then return nil end
    -- No leading "<": the client read it as markup and showed nothing in testing.
    local rows = { { backLabel(), tone = "link", select = "detail:back" }, { "" } }
    if selectedName == "help" then
        if settings.welcomeSeen == false then   -- opened from the welcome: the way on
            rows[1] = { "Start using the guide", tone = "good", select = "welcome:done" }
        end
        for _, r in ipairs(Views.help()) do rows[#rows + 1] = r end
        return rows
    end
    for _, r in ipairs(buildSelected()) do rows[#rows + 1] = r end
    return rows
end

-- Runs the planner and redraws the window when what it shows changes.
local function evaluateAndPrint()
    if not Detect.ready() then return end

    -- Developer diagnostics only (off by default): read the local player's
    -- grid coordinates and print them for manual measurements. Never used
    -- for world guidance.
    if Diag and not diagDone then
        diagDone = true
        if DIAGNOSTICS then pcall(function()
            local g = Player.GetEntity().coordGrid
            print(string.format("[Road to Trim] DIAG you are at x=%d z=%d level=%d (map square %d,%d tile %d,%d)",
                g.x, g.z, g.level, g.mapSquareX, g.mapSquareZ, g.localX, g.localZ))
        end) end
        local ok, err = pcall(Diag.dumpIcons, not DIAGNOSTICS and ICON_PICKER or nil, ICON_PICKER ~= nil)
        if not ok then print("[Road to Trim] DIAG icon dump failed: " .. tostring(err)) end
        if ICON_PICKER then
            local okV, errV = pcall(Diag.dumpLodestoneVars)
            if not okV then print("[Road to Trim] DIAG lodestone variables failed: " .. tostring(errV)) end
        end
    end

    -- Build and locally cache the game's quest display-name -> config-name
    -- mapping on first use.
    if Detect.questIndex == nil then
        local n, highest = Detect.buildQuestIndex()
        PersistentDB:SetStructuredData("questIndex", Detect.questIndex)
        Views.debug("indexed " .. n .. " quests from the game (highest ID " .. highest .. ")")
    end
    -- Persist only the display-name -> config-name mappings needed by route
    -- achievements and time-gated entries (not completion state). Rebuild
    -- when an expected name has no entry. An entry of false records a
    -- requested name not found by the last scan. It does not trigger a
    -- rebuild by itself; a later rebuild searches all requested names again.
    local needed, missingName = {}, false
    local function need(name)
        needed[name] = true
        if Detect.achievementIndex and Detect.achievementIndex[name] == nil then missingName = true end
    end
    for _, s in ipairs(Steps) do
        if s.achievement then need(s.achievement) end
    end
    for _, e in ipairs(TimeGated) do
        for _, n in ipairs(e.names) do need(n) end
    end
    if Detect.achievementIndex == nil or missingName then
        local n, highest = Detect.buildAchievementIndex(needed)
        PersistentDB:SetStructuredData("achievementIndex", Detect.achievementIndex)
        Views.debug("indexed " .. n .. " achievements from the game (highest ID " .. highest .. ")")
    end

    local capeItems = Detect.capeItems(Steps)
    masterAnglerIncomplete = false
    for _, it in ipairs(capeItems) do
        if plainName(it.name or "") == plainName("Master Angler") then
            masterAnglerIncomplete = it.state == "todo" or it.state == "partial" or it.state == "locked"
            break
        end
    end
    -- Exclude long-run goals (data/longachievements.lua) from suggestions.
    -- Progress and achievement Details still receive the full checklist.
    local suggestable = {}
    for _, it in ipairs(capeItems) do
        if not isLong(it) then suggestable[#suggestable + 1] = it end
    end
    lastEvaluation = Planner.evaluate(Steps, Detect, settings.mode, suggestable)
    lastCapeItems = suggestable
    -- Skipped quests ("Skip until reset", in memory this session): the ones whose
    -- time has come, or that are done, go; the rest aren't picked as the
    -- next step (what they unlock stays locked). An unreadable clock keeps
    -- them until it reads again (or the session ends).
    local clockNow = Detect.clockMinutes()
    Path.prune(postponed, clockNow)
    for id in pairs(postponed) do
        local r = lastEvaluation.results[id]
        if r == nil or r.status == "done" then postponed[id] = nil end
    end
    local guide = Planner.guide(lastEvaluation, TrainingMethods, 3, postponed)
    -- Quests finished since the last look, and what they opened up (JUST
    -- OPENED UP, below THEN; what's shown is decided once the queue is known).
    Followups.observe(followups, lastEvaluation, suggestable, Detect.quest)
    lastFollowups = {}

    -- Data problems (a quest name the game doesn't know) print once per session.
    for _, w in ipairs(lastEvaluation.warnings) do
        if not warnedOnce[w] then
            warnedOnce[w] = true
            print("[Road to Trim] WARNING " .. w)
        end
    end

    local guideRows = {}
    local function add(text, term, tone, dots) guideRows[#guideRows + 1] = { text, wiki = term, tone = tone, dots = dots } end
    -- Helper text under the entry above it: note colour, indented to the
    -- entry's text, not clickable (ui/panel.lua TONE.note).
    local function note(text, dots, pad)
        guideRows[#guideRows + 1] = { text, tone = "note", dots = dots, pad = pad or { icon = true } }
    end
    -- The Guide's rows are wrapped by measured pixels (the window does the
    -- same, Panel.showPage's `measured`), and counted the way they're shown.
    -- `limit`: the rows the part being built may reach, TOP_ROWS for the
    -- progress line, the card and THEN, then GUIDE_ROWS for the lists under
    -- them.
    local function wrapped(rows) return Views.wrapRows(rows, nil, nil, true) end
    local limit = TOP_ROWS
    local function rowsLeft() return limit - #wrapped(guideRows) end
    -- First use: a short welcome above the guide, which works as usual below
    -- it. "Show me how it works" opens the Help view; "Skip tutorial" (or
    -- "Start using the guide" there) hides it for good on this computer.
    local function addWelcome()
        if settings.welcomeSeen ~= false then return end
        add("WELCOME TO ROAD TO TRIM", nil, "head")
        add("A guide to your next quests and cape requirements.", nil, "default")
        guideRows[#guideRows + 1] = { "Show me how it works", tone = "good", select = "welcome:show" }
        guideRows[#guideRows + 1] = { "Skip tutorial", tone = "dim", select = "welcome:skip" }
    end
    -- The current step's block (Views.stepBlock): `left` (its tip, as short
    -- lines), then the items it needs (icon, green circle if
    -- held in backpack or bank, red if not, amount), then how to
    -- get each missing item (Ironman way, or buy it on a main). It gets
    -- what's left of the top's rows after wrapping, less `reserve` rows for
    -- what comes under it; what doesn't fit is counted on a line that opens
    -- the step's Details.
    local function addStepBlock(r, left, reserve)
        local hint = function(it)
            local h = Path.itemHint(it, settings.mode, ItemSources)
            return h and { h } or nil
        end
        local rows = Views.stepBlock(left, Path.stepItems(r), hint, rowsLeft() - reserve, selectFor(r.step))
        for _, row in ipairs(rows) do guideRows[#guideRows + 1] = row end
    end
    -- "Skipped: N" (quests put off with the card's "Skip until reset"),
    -- opening the list to see or undo them (Details).
    --   gap : a blank row first (under the card, so the card's edge and its
    --         padding end before this text)
    local function postponedRow(gap)
        local n = 0
        for _ in pairs(postponed) do n = n + 1 end
        if n > 0 then
            if gap then guideRows[#guideRows + 1] = { "" } end
            guideRows[#guideRows + 1] = { string.format("Skipped: %d", n), tone = "dim",
                select = "postpone:list", pad = { icon = true } }
        end
    end
    -- Nothing left but skipped quests: say so, not ALL DONE.
    local function allPostponed()
        add("", nil)
        add("NOTHING ELSE FOR NOW", nil, "head")
        local n = 0
        for _ in pairs(postponed) do n = n + 1 end
        add(string.format("Everything left is skipped (%d) or waits on a skipped quest (%d)",
            n, math.max(0, guide.postponed - n)), nil, "dim")
        postponedRow()
    end
    -- Nothing to suggest, but not everything is known to be complete:
    -- long-run goals (never suggested) or steps the game can't read remain.
    -- Under the same heading as allPostponed, which the compact card shows.
    local left = Planner.remaining(lastEvaluation, capeItems, isLong)
    local function stillLeft()
        if left.long + left.unknown == 0 then return false end
        local parts = {}
        if left.long > 0 then
            parts[#parts + 1] = string.format("%d long-run goal%s", left.long, left.long == 1 and "" or "s")
        end
        if left.unknown > 0 then
            parts[#parts + 1] = string.format("%d step%s the game can't read", left.unknown, left.unknown == 1 and "" or "s")
        end
        add("", nil)
        add("NOTHING ELSE FOR NOW", nil, "head")
        add("Still left: " .. table.concat(parts, " and "), nil, "warn")
        return true
    end
    -- A quest's Start and travel lines on the card (no walkthrough row: the
    -- quest's name has right-click > Wiki, and Quest Helper is a plugin of
    -- its own).
    local function travelRows(step)
        local start = startText(step)
        if not start then return end
        guideRows[#guideRows + 1] = { start[1], tone = "note", wiki = start.wiki, pad = { icon = true }, optional = true }
        for _, w in ipairs(start.ways) do
            guideRows[#guideRows + 1] = { w[1], tone = "travel", icon = w.icon, pad = (w.icon == nil) and { icon = true } or nil,
                optional = true }
        end
    end
    -- Missing levels, quests and earlier steps, full width under the step's
    -- title (at most `max`), leaving `reserve` rows below plus 2 for the
    -- item block (its header and one item, or the line that counts them). A
    -- line that wraps past that room is taken back.
    local function addNeeds(r, need, max, reserve)
        local keep = reserve + (#r.items > 0 and 2 or 0)
        for i = 1, math.min(max, #need - #r.items) do
            add(need[i][1], need[i][2], "warn", { "red" })
            if rowsLeft() - keep < 0 then
                guideRows[#guideRows] = nil
                break
            end
        end
    end
    -- A step's tip as short lines, one per sentence; optional, so they give
    -- way to the items when the page is short (Details has the full tip).
    local function tipLines(step)
        local out, tip = {}, Path.advice(step, settings.mode)
        -- Authored action lists must not split at the dot in "1. ...".
        if tip and tip:find("\n", 1, true) then
            for action in (tip .. "\n"):gmatch("([^\n]+)\n") do
                out[#out + 1] = { action, tone = "note", pad = { icon = true }, optional = true }
            end
            return out
        end
        for sentence in ((tip or "") .. ". "):gmatch("(.-)%.%s+") do
            if sentence ~= "" then out[#out + 1] = { "- " .. sentence, tone = "note", pad = { icon = true }, optional = true } end
        end
        return out
    end

    local function stepAdvice(r)
        if r.step.type == "cape" then return Views.achievementActions(r, guidanceFor(r.step.title)) end
        return tipLines(r.step)
    end

    -- Compact shows the first queue entry ({ kind = "route", r },
    -- { kind = "timegated", e } or { kind = "minigame", it }; nil when nothing
    -- is left), its requirements and items, and an eligible upcoming
    -- activity timer.
    local compactFirst = nil
    -- The first queue entry's route step, used for the Progress phase
    -- calculation; Views.routeProgress supplies the fallback phase.
    local progressCurrent = nil

    -- Time-gated achievement names: CAN DO NOW leaves them to Activities.
    local timedNames = {}
    for _, e in ipairs(TimeGated) do for _, n in ipairs(e.names) do timedNames[n] = true end end

    -- The Activities tab. Each achievement's state (done / locked and why /
    -- open) comes from the cape checklist if it's on it, else straight from
    -- the game.
    local itemByName = {}
    for _, it in ipairs(capeItems) do itemByName[it.name] = it end
    local infoCache = {}
    local function info(name)
        if itemByName[name] then return itemByName[name] end
        if infoCache[name] == nil then infoCache[name] = Detect.achievementInfo(name) or false end
        return infoCache[name] or nil
    end
    local now = Detect.clockMinutes()
    -- Activities (Views.activities) groups time-gated entries by reset, then
    -- lists minigames (a time-gated minigame such as Big Chinchompa appears
    -- only in its reset group), subject to the filter and row budget. A last
    -- line counts entries that did not fit; one row is left for the blank row
    -- ui/panel.lua adds at the end. Long-run goals are listed on Progress.
    local activityRows = Views.activities({ entries = TimeGated, info = info, now = now, readVar = Detect.varValue,
        filter = activityFilter(), capeItems = capeItems, isMinigame = isMinigame, timedNames = timedNames,
        max = ACTIVITY_ROWS - 1 })
    lastInfo = info

    -- Build the Guide queue (core/path.lua: route steps, time-gated
    -- activities and minigames as they open) shown as DO THIS NOW and THEN,
    -- then the lower lists: ALSO AVAILABLE, JUST OPENED UP and CAN DO NOW.
    do
        Path.prune(pathSkipped, now)
        local queue = Path.build({ guide = guide, timed = TimeGated, info = info, now = now,
            readVar = Detect.varValue, skipped = pathSkipped, capeItems = suggestable,
            isMinigame = isMinigame, max = 4 })
        addWelcome()
        -- THEN: the queue after the first entry, all of it (DO THIS NOW and
        -- THEN come first; the lists below leave out what they show).
        local thenList = {}
        local thenRows = 0   -- THEN's rows after wrapping (blank, heading, its entries), measured below
        for i = 2, #queue do thenList[#thenList + 1] = queue[i] end
        -- The first entry's route step id, for THEN's "after this" (Views.thenRight).
        local firstId = queue[1] and queue[1].kind == "route" and queue[1].result.step.id or nil
        -- The card's buttons (Views.buttonRows): as many rows as the buttons
        -- take at the card's width, then the note under them when a button
        -- can't act now; the rows' text stays empty, ui/panel.lua draws the
        -- buttons. Made before the card's other rows so their count can be
        -- kept out of the step block's room.
        local function buttonRow(rows) for _, row in ipairs(rows) do guideRows[#guideRows + 1] = row end end
        -- Render the first entry as the detailed DO THIS NOW card. Later
        -- queue entries are compact one-line THEN rows: icon and name (cut
        -- with "..." when long), with use circles or "after this" on the
        -- right (Views.thenRight).
        local function entryRows(q, first)
            local right = (not first) and Views.thenRight(q, firstId) or nil
            local oneLine = (not first) or nil
            if q.kind == "timegated" then
                local e = q.entry
                guideRows[#guideRows + 1] = { e.activity, wiki = e.wiki, tone = first and "title" or "good",
                    icon = Icons.timegated, select = e.names[1], oneLine = oneLine,
                    dots = right and right.dots or nil, dotsRight = (right and right.dots) and true or nil }
                if first then
                    compactFirst = { kind = "timegated", e = e }
                    local t = Clock.minutesUntil(e.reset, now)
                    local when = (e.reset == "halfhour" and t) and ("starts in " .. Clock.format(t))
                        or ("resets in " .. Clock.format(Clock.minutesUntil(e.period or e.reset, now) or 0))
                    note(when, q.uses and q.uses.dots or nil)
                    -- "Done for now" (hide until reset) takes the skip's place;
                    -- like it, it needs the clock (dim with a note without it).
                    buttonRow(Views.buttonRows({ skipKey = Path.skipKey(e), clock = clockNow ~= nil }))
                end
            elseif q.kind == "route" then
                local r = q.result
                if first then compactFirst = { kind = "route", r = r } end
                local rNeed = missingLines(r)
                -- The status chip in place of "Ready" (Views.statusChip).
                local chip = first and Views.statusChip(r) or nil
                -- The card's title is the step's title; a THEN line its name
                -- (an achievement's own name, not its description).
                guideRows[#guideRows + 1] = { first and Views.plainTitle(r.step) or Views.stepName(r.step), wiki = stepWiki(r.step),
                    tone = first and "title" or "good", icon = markerFor(r.step), select = selectFor(r.step), oneLine = oneLine,
                    right = chip and chip[1] or (right and right.text) or nil,
                    rightTone = chip and chip.tone or "dim", rightChip = chip and true or nil }
                if first then
                    -- The why line, travel lines, missing levels (up to 8),
                    -- then the tip and items. Before filling the card, reserve
                    -- the wrapped action rows (a quest's "Skip until reset"
                    -- and its clock note), the skipped count and THEN. Lower
                    -- lists use GUIDE_ROWS beyond TOP_ROWS, so the card does
                    -- not give way to them.
                    local why = Views.whyLine(r.step, Steps)
                    if why then guideRows[#guideRows + 1] = { why, tone = "note", pad = { icon = true }, optional = true } end
                    local nPostponed = 0
                    for _ in pairs(postponed) do nPostponed = nPostponed + 1 end
                    local buttons = Views.buttonRows({ stepId = r.step.id, quest = r.step.type == "quest", clock = clockNow ~= nil })
                    local reserve = thenRows + #wrapped(buttons) + (nPostponed > 0 and 2 or 0)   -- the blank and the Skipped row
                    if r.step.type == "quest" then travelRows(r.step) end
                    addNeeds(r, rNeed, 8, reserve)
                    addStepBlock(r, stepAdvice(r), reserve)
                    buttonRow(buttons)
                end
            else
                local it = q.item
                local pct = it.pct and it.pct > 0 and string.format("  %d%%", math.floor(it.pct * 100)) or ""
                guideRows[#guideRows + 1] = { it.name .. pct, wiki = it.name, tone = first and "title" or "good",
                    icon = Icons.minigame, select = it.name, oneLine = oneLine }
                if first then compactFirst = { kind = "minigame", it = it } end
                -- No button: a minigame has nothing to skip or hide; its name
                -- opens its Details.
                if first and it.remaining and #it.remaining > 0 then note("Next: " .. it.remaining[1]) end
            end
        end
        -- The Guide's top, above the welcome: the route progress line (phase
        -- N / last phase, a bar, quests done / on the route;
        -- Views.routeProgress), then timer chips for readable eligible
        -- activities within Views.CHIP_WINDOW (none without the game clock).
        local firstRoute = queue[1] and queue[1].kind == "route" and queue[1].result.step or nil
        progressCurrent = firstRoute
        local prog = Views.routeProgress(Steps, lastEvaluation.results, firstRoute)
        local top = { { string.format("Phase %d / %d", prog.phase, prog.maxPhase), tone = "dim",
            right = string.format("%d / %d quests", prog.done, prog.total), rightTone = "num", bar = { frac = prog.frac } } }
        local function timedOpen(e) return Views.isActionable(e, info) end
        -- At most four chips on two rows, whole or not at all (Views.timerChipRows).
        for _, chips in ipairs(Views.timerChipRows(Views.timerChips(TimeGated, timedOpen, now, pathSkipped, nil, true))) do
            top[#top + 1] = { "", chips = chips }
        end
        for k, row in ipairs(top) do table.insert(guideRows, k, row) end
        if #queue == 0 and guide.postponed > 0 then
            allPostponed()
        elseif #queue == 0 and stillLeft() then
            -- the counts line is all there is to show
        elseif #queue == 0 then
            add("", nil)
            add("ALL DONE", nil, "head")
            add("Nothing left on the route or the cape lists", nil, "good", { "green" })
        else
            add("", nil)
            add("DO THIS NOW", nil, "head")
            -- THEN's entries are one row each before wrapping; a long name
            -- takes two at this width, so they're measured, not counted.
            if #thenList > 0 then
                local saved = guideRows
                guideRows = {}
                for _, q in ipairs(thenList) do entryRows(q, false) end
                thenRows = 2 + #wrapped(guideRows)
                guideRows = saved
            end
            -- The card: every row of the first entry has `card` (ui/panel.lua
            -- fills behind them). Not `band`: the compact card takes band rows
            -- for item rows.
            local cardFrom = #guideRows + 1
            entryRows(queue[1], true)
            for k = cardFrom, #guideRows do guideRows[k].card = true end
            postponedRow(true)   -- keep "Skipped: N" below the card, with a blank row between
            if #thenList > 0 then
                add("", nil)
                -- Right-align the dim "In order" label on THEN.
                guideRows[#guideRows + 1] = { "THEN", tone = "head", right = "In order", rightTone = "dim" }
                for _, q in ipairs(thenList) do entryRows(q, false) end
            end
        end

        -- Lower lists, in order: ALSO AVAILABLE, JUST OPENED UP, CAN DO NOW,
        -- each shown only when non-empty. An entry is shown once: queue
        -- entries and anything already in an earlier list are excluded.
        -- Entries are compared by Path.identities keys (route step id, cape
        -- achievement name and config name, route achievement name, every
        -- name of a time-gated entry), so one achievement under two names
        -- still matches.
        local claimed = {}
        local function taken(keys)
            for _, k in ipairs(keys) do if claimed[k] then return true end end
            return false
        end
        local function claim(keys) for _, k in ipairs(keys) do claimed[k] = true end end
        for _, q in ipairs(queue) do claim(Path.identities(q)) end
        -- A cape item's keys, as the queue's minigame entries have them.
        local function itemKeys(it) return Path.identities({ kind = "minigame", item = it }) end
        -- Each list's whole eligible set first (the counts and the "+N
        -- more" page need all of it), then as many as fit are shown.
        local alsoAll = {}
        for _, r in ipairs(guide.alternatives or {}) do
            local keys = Path.identities({ kind = "route", result = r })
            if not taken(keys) then
                claim(keys)
                alsoAll[#alsoAll + 1] = r
            end
        end
        -- Collect all eligible pending follow-ups (core/followups.lua) before
        -- display limits. Queued entries are excluded without being
        -- dismissed, so they return here when the queue moves on.
        local newAll = {}
        for _, f in ipairs((Followups.visible(followups, suggestable, nil, math.huge))) do
            local keys = itemKeys(f.item)
            if not taken(keys) then
                claim(keys)
                newAll[#newAll + 1] = f
            end
        end
        -- CAN DO NOW: Trim/Comp achievements unlocked for this account right
        -- now (time-gated ones are Activities'), most progress first
        -- (Views.doableNow).
        local candoAll = {}
        for _, it in ipairs(Views.doableNow(suggestable, timedNames, math.huge)) do
            local keys = itemKeys(it)
            if not taken(keys) then
                claim(keys)
                candoAll[#candoAll + 1] = it
            end
        end

        -- The rows of an entry of each list.
        -- ALSO AVAILABLE: a THEN-like line (icon, name cut with "...") with
        -- its status chip (Views.statusChip: Ready / N missing / N steps first).
        local function alsoRow(r)
            local chip = Views.statusChip(r)
            return { Views.stepName(r.step), wiki = stepWiki(r.step), tone = "good", icon = markerFor(r.step),
                select = selectFor(r.step), oneLine = true,
                right = chip and chip[1] or nil, rightTone = chip and chip.tone or nil, rightChip = chip and true or nil }
        end
        local function newRow(f)
            return { f.item.name .. "  (after " .. f.after .. ")", wiki = f.item.name, tone = "good",
                select = f.item.name, icon = (isMinigame and isMinigame(f.item)) and Icons.minigame or Icons.achievement }
        end
        -- CAN DO NOW: the name, and on the right in gold how far along it is
        -- where the game says (Views.goalProgress: its own tally "12 / 40",
        -- or "~2 / 7" worked back from its percentage and the description's
        -- target), else a minigame's sub-tasks still to do ("3 left"), else
        -- the game's percentage; nothing made up. (A cape step's "Next: ..."
        -- is in its Details.)
        local function candoRow(it)
            local prog = Views.goalProgress(it, longDescOf(it))
            local mini = isMinigame and isMinigame(it)
            local right = prog and prog.text
                or (mini and it.remaining and #it.remaining > 0 and string.format("%d left", #it.remaining))
                or (it.pct and it.pct > 0 and string.format("%d%%", math.floor(it.pct * 100))) or nil
            return { it.name, wiki = it.name, tone = "good", select = it.name,
                icon = mini and Icons.minigame or Icons.achievement,
                right = right, rightTone = right and "num" or nil, rightWide = right and true or nil }
        end
        -- For the "+N more" page (Views.guideList): every entry's row.
        local function rowsOf(list, rowOf)
            local out = {}
            for k, e in ipairs(list) do out[k] = rowOf(e) end
            return out
        end
        lastGuideLists = {
            also = { title = GUIDE_LISTS.also, rows = rowsOf(alsoAll, alsoRow) },
            new = { title = GUIDE_LISTS.new, rows = rowsOf(newAll, newRow) },
            cando = { title = GUIDE_LISTS.cando, rows = rowsOf(candoAll, candoRow) },
        }

        -- The status chips on the rows so far (the card's, the timer chips,
        -- the card's button): ALSO AVAILABLE's chips take what's left of the
        -- Guide's pill pool (GUIDE_PILLS), so every chip gets its fill.
        local pills = 0
        for _, row in ipairs(guideRows) do
            if row.rightChip and row.right then pills = pills + 1 end
            pills = pills + #(row.chips or {}) + #(row.buttons or {})
        end
        -- One list: a blank, its heading, up to `cap` entries, "+N more"
        -- (opening the whole list) when some aren't shown, then `tail`
        -- under the entries (JUST OPENED UP's "Dismiss these"). As many
        -- entries as fit in the rows left (GUIDE_ROWS), whole ones only;
        -- with no room for one, the heading and "+N more"; with no room for
        -- those either, the list is left out. Returns how many were shown.
        limit = GUIDE_ROWS
        local function placeList(key, list, rowOf, cap, tail)
            if #list == 0 then return 0 end
            local room = rowsLeft()
            for k = math.min(cap, #list), 0, -1 do
                local rows = { { "" }, { GUIDE_LISTS[key], tone = "head" } }
                for i = 1, k do rows[#rows + 1] = rowOf(list[i]) end
                local more = #list - k
                if more > 0 then
                    rows[#rows + 1] = { string.format("+%d more", more), tone = "link", select = "guidelist:" .. key,
                        pad = { icon = true } }
                end
                if k > 0 and tail then rows[#rows + 1] = tail end
                if #wrapped(rows) <= room then
                    for _, row in ipairs(rows) do guideRows[#guideRows + 1] = row end
                    return k
                end
            end
            return 0
        end
        placeList("also", alsoAll, alsoRow, math.max(0, math.min(ALSO_MAX, GUIDE_PILLS - pills)))
        -- "Dismiss these" hides exactly the ones shown (lastFollowups).
        local shownNew = placeList("new", newAll, newRow, NEW_MAX, { "Dismiss these", tone = "dim", select = "followups:dismiss" })
        for i = 1, shownNew do lastFollowups[i] = newAll[i].item.name end
        placeList("cando", candoAll, candoRow, CANDO_MAX)

        -- Guide list headings use noBox to omit section frames (ui/panel.lua
        -- reads it on the heading row). The current-step card and the
        -- welcome keep their frames; Details and Help keep their section
        -- boxes.
        for _, row in ipairs(guideRows) do
            if row.tone == "head" and row[1] ~= "WELCOME TO ROAD TO TRIM" then row.noBox = true end
        end
    end

    -- Progress (Views.progressRows) uses the full checklist the game
    -- returned (capeItems, long-run goals included): the cape summary, route
    -- phase and quest count, a bar per cape section (totals from
    -- data/achievements.lua), unfinished time-gated goals from lifetime
    -- tallies, and long-run goals (a time-gated one is listed under
    -- TIME-GATED only). Period-use counters are not lifetime progress.
    lastSections = Views.sectionTallies(AchData, capeItems, plainName)
    local function descByName(n) return longDescOf({ name = n }) end
    local progressRows = Views.progressRows({
        cape = Views.capeTotal(capeItems),
        mode = labelOf(MODE_CHOICES, settings.mode),
        route = Views.routePhase(Steps, lastEvaluation.results, progressCurrent, Phases),
        sections = lastSections,
        timed = Views.timeGatedProgress(TimeGated, info, descByName),
        long = Views.longGoals({ capeItems = capeItems, isLong = isLong, descOf = descByName, exclude = timedNames }),
        max = PROGRESS_ROWS - 1,   -- less the blank row ui/panel.lua puts after the last
        ring = Panel.canRing ~= nil and Panel.canRing() == true,
    })

    local detailRows = buildDetails()

    -- Pop-up alerts: resets (one per reset seen, naming what opened again,
    -- core/alerts.lua), half-hour heads-ups, newly unlocked minigames.
    -- Only for activities that are available (not done, not locked).
    -- An activity the game doesn't know (no achievement positively open) gets none.
    local function isOpen(e) return Views.isActionable(e, info) end
    local alertsOn = settings.alertKinds or DEFAULT_ALERTS
    for _, a in ipairs(Alerts.check(TimeGated, isOpen, now, suggestable, isMinigame)) do
        if alertsOn[a.kind] then Panel.notify(a[1], a[2]) end
    end
    -- Offer one session reminder, after the checklist is read, that a
    -- long-run goal is available on Progress. The opportunity is used up
    -- even when its alert switch is off.
    if not longReminded and #capeItems > 0 then
        longReminded = true
        local a = Alerts.longReminder(capeItems, isLong)
        if a and alertsOn.long then Panel.notify(a[1], a[2]) end
    end

    -- Compact rows: the current entry and its status, its items, and the
    -- next eligible activity timer, within COMPACT_ROWS. The title can span
    -- two lines; instructions use separate rows behind a toggle. Overflow
    -- links ("+N more items", "Full details") open Details in the full window.
    local compactRows = {}
    -- Offer to restore skipped quests, because compact does not show their list.
    local function skippedRow()
        local n = 0
        for _ in pairs(postponed) do n = n + 1 end
        if n == 0 then return nil end
        return { string.format("Restore %d skipped quest%s", n, n == 1 and "" or "s"), tone = "link", select = "postpone:allback" }
    end
    if compactFirst == nil then
        -- Nothing to do: the Guide's closing group (ALL DONE, or NOTHING
        -- ELSE FOR NOW with what's postponed or still left), as its rows.
        -- No entry: no instructions to keep open.
        lastCompactKey, compactOpenKey = nil, nil
        local inGroup = false
        for _, row in ipairs(guideRows) do
            local t = row[1]
            if t == "ALL DONE" or t == "NOTHING ELSE FOR NOW" then inGroup = true
            elseif inGroup and t == "" then break end
            if inGroup and not row.optional then
                if row.select == "postpone:list" then
                    compactRows[#compactRows + 1] = skippedRow()
                else
                    local plain = {}
                    for key, v in pairs(row) do plain[key] = v end
                    plain.select, plain.wiki = nil, nil   -- nothing on the card opens the full planner's views
                    compactRows[#compactRows + 1] = plain
                end
            end
        end
    else
        -- (a) The entry: icon, name (wrapped to two lines by ui/panel.lua,
        -- cut with "..." beyond that) and status. Route steps use
        -- Views.statusChip; time-gated entries use a countdown in timer tone;
        -- minigames have no status chip here. Below it, only actions that
        -- work on the card: restore skipped quests, "Hide until reset".
        local f = compactFirst
        local items = {}
        local detailsOf = nil   -- what "+N more items" and "Full details" open: the entry's Details
        local key = nil         -- the entry's identity, for the instructions' open state
        local parts = {}        -- the instructions' parts, in order (Views.compactInstructions)
        local skipTexts = {}    -- what an instruction may not repeat
        local isQuestStep = false
        local function part(text, tone) if text and text ~= "" then parts[#parts + 1] = { text, tone = tone } end end
        -- An achievement's description, its "(X/55)" counter placeholder
        -- dropped (as Details drops it).
        local function descOf(name)
            local d = name and ((AchData[name] and AchData[name].desc) or longDescOf({ name = name }))
            return d and (d:gsub("%s*%(X/[%d,]+%)", "")) or nil
        end
        -- Who or what to go to for an achievement (data/achievementtargets.lua),
        -- as Details words it: "Talk to  Otto Godblessed", then where, text
        -- only. Its x, y and plane are never read: nothing on the card says
        -- where to stand or draws in the world.
        local function targetParts(name)
            for _, t in ipairs((name and AchTargets[name]) or {}) do
                local verb = (t.options and t.options[1]) or (t.kind == "npc" and "Talk to" or "Use")
                part(verb .. "  " .. t.name, "good")
                if t.where and t.where ~= "" then part(t.where, "note") end
            end
        end
        if f.kind == "route" then
            local r = f.r
            local chip = Views.statusChip(r)
            key = "route:" .. tostring(r.step.id)
            detailsOf = selectFor(r.step)
            -- Entry names open Details in the full window.
            compactRows[1] = { Views.stepName(r.step), icon = markerFor(r.step), tone = "title", wrapTitle = true,
                select = "compact:details:" .. detailsOf,
                right = chip and chip[1] or nil, rightTone = chip and chip.tone or nil, rightChip = chip and true or nil }
            compactRows[#compactRows + 1] = skippedRow()
            -- (b) Its items (Path.stepItems: the whole list, amounts as
            -- Views.itemTable writes them): the circle is green when it's in
            -- hand (backpack, or the bank as read this session), red when
            -- it's missing (the bank was read this session), grey with "?"
            -- for the amount when the bank hasn't been opened this session
            -- (it may be there).
            local stepItems = Path.stepItems(r)
            for k, row in ipairs(Views.itemTable(stepItems, nil)) do
                if k > 1 then
                    local it = stepItems[k - 1]
                    local colour = "green"
                    if row.dots[1] ~= "green" then
                        local bankRead = false   -- has the bank been read for this item this session?
                        for _, id in ipairs(it.ids or { it.id }) do
                            if Detect.bankSnapshot[tostring(id)] ~= nil then bankRead = true end
                        end
                        colour = bankRead and "red" or "grey"
                    end
                    local n = #items + 1
                    items[n] = { row[1], right = colour == "grey" and "?" or row.right,
                        rightTone = colour == "grey" and "dim" or row.rightTone, dots = { colour }, icon = row.icon, pad = row.pad,
                        band = n % 2 == 1 and 1 or 2, tone = "default", oneLine = true }
                end
            end
            -- Quest instructions show unmet requirements, then items the
            -- card has no row for (added below). No tips, travel or quest
            -- walkthrough; Quest Helper or the Wiki covers that.
            if r.step.type == "quest" then
                isQuestStep = true
                for _, m in ipairs(r.missing or {}) do
                    if m.kind == "skill" then
                        part(string.format("%s %d -> %d", capitalise(m.skill), m.have, m.need), "warn")
                    elseif m.kind == "quest" then part(m.name .. "  (quest)", "warn")
                    elseif m.kind == "step" then part(Views.plainTitle(m), "warn")
                    elseif m.kind == "combat" then part(string.format("Combat level %d -> %d", m.have, m.need), "warn")
                    else part(m.text or m.name, "warn") end
                end
            else
                -- An achievement on the route or the cape list (and any
                -- other route step): (a) what it is: the part of the route's
                -- title after the name, or the cape achievement's own
                -- description; (b) its numbered guidance (data/
                -- achievementguidance.lua, the first action in the step
                -- colour), else the route step's tip for this account mode;
                -- (c) who or what to go to.
                local name = r.step.type == "cape" and r.step.title or Views.stepName(r.step)
                if r.step.type == "cape" then
                    part(descOf(name), "note")
                else
                    part(Views.titleRemainder(Views.plainTitle(r.step), name), "note")
                end
                local actions = Views.achievementActions(r, guidanceFor(name))
                if #actions > 0 then
                    for _, a in ipairs(actions) do part(a[1], a.tone) end
                else
                    local tip = Path.advice(r.step, settings.mode)
                    if tip and tip:find("\n", 1, true) then
                        -- An authored action list keeps its lines.
                        for action in (tip .. "\n"):gmatch("([^\n]+)\n") do part(action, "note") end
                    elseif tip then
                        part(tip, "note")   -- prose: one part, wrapped on the card
                    end
                end
                targetParts(name)
                skipTexts = { Views.plainTitle(r.step), name }
            end
        elseif f.kind == "timegated" then
            local e = f.e
            key = "timegated:" .. tostring(Path.skipKey(e))
            detailsOf = e.names and e.names[1]
            local t = now and Clock.minutesUntil(e.reset == "halfhour" and "halfhour" or (e.period or e.reset), now) or nil
            compactRows[1] = { e.activity, icon = Icons.timegated, tone = "title", wrapTitle = true,
                select = detailsOf and ("compact:details:" .. detailsOf) or nil,
                right = t and ("in " .. Clock.format(t)) or nil, rightTone = t and Views.timerTone(e, t) or nil,
                rightChip = t and true or nil }
            -- "Done for now", as the Guide card's button, in its long form.
            compactRows[2] = { "Hide until reset", tone = "dim", select = "skip:" .. Path.skipKey(e) }
            -- Its rhythm (the wiki's note), then where to go for its first
            -- achievement (the one Details opens, as the Guide's).
            part(e.note, "note")
            targetParts(detailsOf)
            skipTexts = { e.activity }
        else
            local it = f.it
            local pct = it.pct and it.pct > 0 and string.format("  %d%%", math.floor(it.pct * 100)) or ""
            key = "minigame:" .. tostring(it.name)
            detailsOf = it.name
            compactRows[1] = { it.name .. pct, icon = Icons.minigame, tone = "title", wrapTitle = true,
                select = "compact:details:" .. it.name }
            -- What it is (its description), then what's next on its list.
            part(descOf(it.name), "note")
            if it.remaining and #it.remaining > 0 then part("Next: " .. it.remaining[1], "good") end
            skipTexts = { it.name }
        end
        -- (c) Show an eligible set-time activity timer within 15 minutes
        -- (Views.compactNext), truncated by measured font width
        -- (ui/panel.lua, `measured`).
        local nextRow = Views.compactNext({ entries = TimeGated, info = info, readVar = Detect.varValue, now = now,
            skipped = pathSkipped, exclude = f.kind == "timegated" and Path.skipKey(f.e) or nil })
        if nextRow then nextRow.measured = true end
        -- (b) Items use the rows left between (a) and (c): up to two item
        -- rows, plus a "+N more items" line (opens Details) when there are
        -- more. If the budget is short, item rows give way before the count
        -- line. The title's second line, the toggle and the instructions use
        -- separate pools (ui/panel.lua) and do not count here.
        local budget = COMPACT_ROWS - #compactRows - (nextRow and 1 or 0)
        local shown = math.min(#items, 2)
        local counted = #items > 2
        if shown + (counted and 1 or 0) > budget then shown = math.max(0, budget - (counted and 1 or 0)) end
        -- A quest's instructions list the items the card has no row for, with
        -- what's held and needed as the item rows write it.
        if isQuestStep then
            for k = shown + 1, #items do part(items[k][1] .. "  " .. tostring(items[k].right or ""), "default") end
        end
        local instructions = Views.compactInstructions(parts, skipTexts)
        -- The entry changed: its instructions close (a new entry starts closed).
        lastCompactKey = key
        if compactOpenKey ~= nil and compactOpenKey ~= key then compactOpenKey = nil end
        for k = 1, shown do compactRows[#compactRows + 1] = items[k] end
        if counted then
            local left = #items - shown
            compactRows[#compactRows + 1] = { string.format("+%d more item%s", left, left == 1 and "" or "s"), tone = "link",
                select = "compact:details:" .. detailsOf, pad = { icon = true }, oneLine = true }
        end
        if nextRow then compactRows[#compactRows + 1] = nextRow end
        -- When open, put the instructions and the "Full details" overflow
        -- link (ui/panel.lua shows it only when they don't all fit) before
        -- the final "Show/Hide instructions" toggle. No toggle when there is
        -- nothing to show.
        if #instructions > 0 then
            local open = compactOpenKey == key
            if open then
                for _, row in ipairs(instructions) do compactRows[#compactRows + 1] = row end
                compactRows[#compactRows + 1] = { "Full details", tone = "link", select = "compact:details:" .. tostring(detailsOf),
                    instrMore = true }
            end
            compactRows[#compactRows + 1] = { "", compactButton = { open and "Hide instructions" or "Show instructions",
                select = "compact:instructions" } }
        elseif compactOpenKey == key then
            compactOpenKey = nil   -- nothing to show any more: closed
        end
    end
    -- Redraw only when the visible-row signature changes. Countdowns change
    -- every minute; events and user actions may also change the display.
    local sig = Views.signature({ guideRows, activityRows, progressRows, detailRows or {}, compactRows, { { tostring(detailPage) } } })
    if sig == lastSignature then return end
    lastSignature = sig

    if Panel.isCompact() then
        Panel.showCompact(compactRows)
        return
    end

    -- Settings' counts (skipped, dismissed) as they are now.
    if Panel.refreshSettings then Panel.refreshSettings() end
    -- What was clicked shows in place of its tab's list.
    -- The Guide's list is wrapped by measured pixels (core/views.lua wrapRows
    -- `measured`); Details and Help by characters.
    local guideShowsList = not (detailRows and detailPage == 1)
    Panel.showPage(1, guideShowsList and guideRows or detailRows, { measured = guideShowsList })
    Panel.showPage(2, (detailRows and detailPage == 2) and detailRows or activityRows)   -- Activities: reset groups and minigames
    Panel.showPage(PROGRESS_PAGE, (detailRows and detailPage == PROGRESS_PAGE) and detailRows or progressRows)
    -- Restore a tab's previous list scroll offset when its Details close
    -- (by Back, by Details opening on another tab, or by answering the welcome).
    for page = 1, DETAIL_PAGES do
        if showingDetails[page] and not (detailRows and detailPage == page) then
            showingDetails[page] = nil
            Panel.scrollTo(page, listOffset[page] or 0)
        end
    end

    -- Print Guide rows to the console only with Views.DEBUG, or in the basic
    -- fallback window, whose last line points the player here for overflow
    -- (ui/panel_basic.lua).
    if Views.DEBUG or (Panel.isBasic and Panel.isBasic()) then
        for _, row in ipairs(guideRows) do print("[Road to Trim] " .. Views.plainText(row)) end
    end
end

-- Skill and variable transmissions mark results dirty; variable changes can
-- affect quests, achievements, travel unlocks and activity counters. The
-- ServerLogic tick below does the evaluation, so a burst is evaluated once.
local function markDirty()
    if not dirty then ticksDirty = 0 end   -- new pending work: its age starts now
    dirty = true; ticksSinceChange = 0
end

Event.SkillTransmit.Subscribe("trimplanner.skill", markDirty)
Event.VarTransmit.Subscribe("trimplanner.var", markDirty)         -- quests and achievements
-- Every item ID the route asks for, so the bank snapshot can be refreshed.
local ROUTE_ITEM_IDS = {}
for _, s in ipairs(Steps) do
    for _, it in ipairs(s.requires and s.requires.items or {}) do
        for _, itemId in ipairs(it.ids or { it.id }) do ROUTE_ITEM_IDS[#ROUTE_ITEM_IDS + 1] = itemId end
    end
end
-- On inventory events, refresh route-item bank counts immediately
-- (Detect.refreshBank), before the debounced evaluation. Otherwise closing
-- the bank first could leave a stale snapshot and count a withdrawn item
-- twice (backpack plus bank).
Event.InventoryUpdated.Subscribe("trimplanner.inv", function()
    Detect.refreshBank(ROUTE_ITEM_IDS)
    markDirty()
end)
-- A new session: character-specific session data starts over, since the
-- plugin cannot tell whether it is the same character (no character name is
-- read). Runs on
-- GameStateChanged and when the player becomes available again after not
-- being; neither has been measured on a real character switch, and either
-- may also fire on a world hop or loading screen (then the bank just needs
-- opening again).
local function newSession(why)
    for id in pairs(postponed) do postponed[id] = nil end
    for k in pairs(pathSkipped) do pathSkipped[k] = nil end
    Detect.bankSnapshot = {}
    followups = Followups.new()   -- also empties the dismissed list
    lastFollowups = {}
    longReminded = false
    print("[Road to Trim] new session (" .. why .. "): bank, skips and follow-ups start over; open your bank once")
    markDirty()
end
Event.GameStateChanged.Subscribe("trimplanner.state", function() newSession("game state changed") end)

-- On each ServerLogic tick (about every 600 ms): track player availability
-- and window movement. Evaluate after three quiet ticks, or after
-- MAX_DIRTY_TICKS pending ticks. Request a countdown refresh every 100 ticks
-- (about a minute). Intervals are tick-based; there is no separate
-- wall-clock timer.
local ticksSinceMinute = 0
local wasReady = nil   -- Detect.ready() at the last tick
Event.ServerLogic.Subscribe("trimplanner.tick", function()
    local ready = Detect.ready()
    if ready and wasReady == false then newSession("player available again") end
    wasReady = ready
    Panel.checkMoved()   -- a dragged window's new place is saved even if nothing redraws
    ticksSinceMinute = ticksSinceMinute + 1
    if ticksSinceMinute >= 100 then
        ticksSinceMinute = 0
        if not dirty then dirty = true; ticksSinceChange = 3; ticksDirty = 0 end
    end
    if not dirty then return end
    ticksSinceChange = ticksSinceChange + 1
    ticksDirty = ticksDirty + 1
    if ticksSinceChange >= 3 or ticksDirty >= MAX_DIRTY_TICKS then
        dirty = false
        ticksDirty = 0
        evaluateAndPrint()
    end
end)

-- Must be a global, not local, so the engine can call it on disable/close.
function PluginShutdown()
    Panel.destroy()
    PersistentDB:SetStructuredData("settings", settings)   -- preferences only (see the top of this file)
end

-- The alert switches (MODE_CHOICES is near the top).
local ALERT_CHOICES = { { "Resets", "reset" }, { "Starting soon (5 min)", "soon" }, { "Minigame unlocked", "unlock" },
                        { "Long-run reminders", "long" } }

local function saveSettings() PersistentDB:SetStructuredData("settings", settings) end
-- How many entries a set has (the skipped quests).
local function countOf(set)
    local n = 0
    for _ in pairs(set) do n = n + 1 end
    return n
end
-- Apply clicks and setting changes immediately when the game is ready,
-- instead of waiting for the tick debounce. During loading, keep a refresh
-- pending for the next eligible tick.
local function redraw()
    lastSignature = nil
    if Detect.ready() then dirty = false; ticksDirty = 0; evaluateAndPrint() else markDirty() end
end

local function alertSelected()
    local selected = {}
    for _, c in ipairs(ALERT_CHOICES) do
        if (settings.alertKinds or DEFAULT_ALERTS)[c[2]] then selected[#selected + 1] = c[2] end
    end
    return selected
end

isMinigame = Views.isMinigame(AchData)
Views.ICONS = Icons

-- Compact view (the Compact button / the card's "Expand" button):
-- remembered, so the plugin opens the way it was left.
-- It opens at the top-left of the screen the first time and then where it
-- was dragged (settings.compactPos, its own; the full window keeps
-- settings.panelPos). It stays until "Expand" is pressed.
-- After the full window is made again: its filters, then its contents.
local function refill()
    Panel.setFilter(2, activityFilter())
    redraw()
end
local function expand()
    settings.compact = false; saveSettings()
    Panel.closeCompact()
    refill()
end
local function compactMoved(x, y) settings.compactPos = { x = x, y = y }; saveSettings() end
-- If the compact card can't be made, the full planner stays (Panel says so in
-- the console) and the next load opens the full planner too.
local function openCompact()
    settings.compact = Panel.openCompact(settings.compactPos, expand, compactMoved) == true
    saveSettings()
end
local function compact()
    openCompact()
    redraw()
end

-- A click on a row (the window's onSelect, below): what was clicked opens in
-- its in-place Details view, or the click does what its name says. Named,
-- so the compact card's "+N more items" can hand its target back to it.
local onSelect
onSelect = function(name, page)
        -- Shows what was clicked now, from the last results, on its tab.
        local function showDetails()
            -- From the list: remember where it was scrolled, open at the top.
            if not showingDetails[detailPage] then listOffset[detailPage] = Panel.scrollOffset(detailPage) end
            showingDetails[detailPage] = true
            Panel.scrollTo(detailPage, 0)
            Panel.showPage(detailPage, buildDetails())
            Panel.showTab(detailPage)
            -- A full redraw puts another tab's list back (where it was
            -- scrolled) if that tab showed Details before.
            redraw()
        end
        -- The Help button ("info:help", ui/panel.lua): open the help.
        -- The first-use welcome: show the help, or skip / finish it (saved,
        -- so it doesn't come back), then the Guide.
        if name == "welcome:show" then
            selectedName, detailPage, detailParent = "help", 1, nil
            showDetails()
            return
        elseif name == "welcome:skip" or name == "welcome:done" then
            selectedName = nil   -- the help shown from the welcome closes with it
            settings.welcomeSeen = true
            saveSettings()
            -- Preserve the chosen full/compact view when answering the
            -- welcome: compact unless the full window was chosen.
            if settings.compact ~= false then compact() return end
            Panel.showTab(1)
            redraw()
            return
        end
        if name == "info:help" then
            selectedName, detailPage, detailParent = "help", 1, nil
            showDetails()
            lastSignature = nil
            return
        end
        -- "< Back": the tab's list again; from an achievement opened out of
        -- a cape section's list (Progress), that list, where it was scrolled.
        if name == "detail:back" then
            if detailParent then
                selectedName = detailParent.name
                local offset = detailParent.offset
                detailParent = nil
                lastSignature = nil
                Panel.showPage(detailPage, buildDetails())
                Panel.scrollTo(detailPage, offset or 0)
                redraw()
                return
            end
            selectedName = nil
            lastSignature = nil
            redraw()   -- the list, where it was scrolled (evaluateAndPrint)
            markDirty()
            return
        end
        -- Skip the current quest until the next daily reset, bring one or
        -- all back, or list them (Details). Existing skips keep their
        -- recorded expiry (Path.prune) or end with the session.
        local kind, sid = nil, nil
        if name then kind, sid = name:match("^postpone:(%a+):?(.*)$") end
        if kind then
            local now = Detect.clockMinutes()
            if kind == "list" then
                selectedName, detailPage = "postponed", 1
                showDetails()
                return
            elseif kind == "reset" and now then postponed[sid] = now + Clock.minutesUntil("daily", now)
            elseif kind == "back" then postponed[sid] = nil
            elseif kind == "allback" then for id in pairs(postponed) do postponed[id] = nil end
            end
            if selectedName == "postponed" then showDetails() end
            redraw()
            return
        end
        -- The compact card's "Show instructions" / "Hide instructions":
        -- open or close them for the entry it shows (session only, never
        -- saved), and redraw at once.
        if name == "compact:instructions" then
            compactOpenKey = (compactOpenKey == nil or compactOpenKey ~= lastCompactKey) and lastCompactKey or nil
            redraw()
            return
        end
        -- The compact card's "+N more items" and "Full details" lines: the
        -- full planner, then the entry's Details on it.
        local target = name and name:match("^compact:details:(.+)$")
        if target then
            if Panel.isCompact() then expand() end
            return onSelect(target, nil)
        end
        -- "Dismiss these" under JUST OPENED UP: hide the ones shown.
        if name == "followups:dismiss" then
            Followups.dismiss(followups, lastFollowups)
            redraw()
            return
        end
        -- Settings > Skipped and hidden: the dismissed list (Details, on the
        -- Guide), and a click on one there brings it back to JUST OPENED UP.
        if name == "followups:list" then
            selectedName, detailPage = "followups", 1
            showDetails()
            return
        end
        local restore = name and name:match("^followups:restore:(.+)$")
        if restore then
            Followups.restore(followups, restore, lastCapeItems)
            if selectedName == "followups" then showDetails() else redraw() end
            return
        end
        -- "Done for now" on a time-gated card: hide it until its reset.
        local skip = name and name:match("^skip:(.+)$")
        if skip then
            local now = Detect.clockMinutes()
            for _, e in ipairs(TimeGated) do
                if now and Path.skipKey(e) == skip then
                    pathSkipped[skip] = Path.skipUntil(e, now)
                end
            end
            saveSettings(); redraw()
            return
        end
        -- Opened from a section's list on Progress, or from one of the
        -- Guide's "+N more" lists: remember the list (its page), so "Back"
        -- returns to it (and "Back" again to the tab). A page link on that
        -- list is the list itself, not something opened from it: "Back" from
        -- any page goes to the tab.
        local function isList(n) return n:find("^section:") ~= nil or n:find("^guidelist:") ~= nil end
        local fromSection = selectedName ~= nil and isList(selectedName)
            and not isList(name) and showingDetails[detailPage] and (page == nil or page == detailPage)
        detailParent = fromSection and { name = selectedName, offset = Panel.scrollOffset(detailPage) } or nil
        selectedName = name
        -- On the tab it was clicked on; from the compact card, a route step on
        -- the Guide and an achievement on Activities.
        detailPage = page or (name:find("^step:") and 1 or 2)
        showDetails()
        lastSignature = nil                 -- keep the next full redraw in step
end

Panel.create({
    -- Refresh in the basic fallback window (ui/panel_basic.lua) forces a
    -- redraw despite an unchanged signature. The full window has no Refresh;
    -- it updates from game events and ticks.
    onRefresh = redraw,
    onCompact = compact,
    -- Clicking an achievement row opens it in its in-place Details view.
    onSelect = onSelect,
    -- The window's position is remembered when the user drags it.
    pos = settings.panelPos,
    onMoved = function(x, y) settings.panelPos = { x = x, y = y }; saveSettings() end,
    -- The filter chips at the top of Activities (2): All / Open now / Today /
    -- This week (Views.FILTERS).
    filters = {
        [2] = { names = Views.FILTERS, onPick = function(name)
            settings.activityFilter = name; saveSettings(); Panel.setFilter(2, name); redraw()
        end },
    },
    -- A function, so the window shows the current choices when it's made again.
    settings = function() return {
        -- Settings groups: a title, the current control, then a note
        -- explaining the current choice. The tab is rebuilt after every
        -- change, so the note follows the choice.
        { title = "Account", kind = "segment", choices = MODE_CHOICES, selected = settings.mode,
          note = (settings.mode == "main"
              and "Main: buy eligible items on the GE."
              or "Ironman, Hardcore and Group: gather your own items.")
              .. " Shared by all characters on this PC.",
          onChange = function(value) settings.mode = value; saveSettings(); redraw() end },
        -- One switch per alert kind (DEFAULT_ALERTS).
        { title = "Pop-up alerts", kind = "switch", choices = ALERT_CHOICES,
          selected = alertSelected(), note = "Pop-ups need the PrettyUI plugin; without it they only go to the console.",
          onChange = function(values)
              -- Every switch saved, off ones as false, so a switch added
              -- later can tell "never seen" from "turned off".
              local kinds = {}
              for _, c in ipairs(ALERT_CHOICES) do kinds[c[2]] = false end
              for _, v in ipairs(values or {}) do kinds[v] = true end
              settings.alertKinds = kinds
              saveSettings()
          end },
        -- What was put off or hidden, each opening its list in Details (on
        -- the Guide), with how many there are on the right.
        { title = "Skipped and hidden", kind = "links", choices = {
            { "Skipped quests", "postpone:list", countOf(postponed) },
            { "Dismissed \"just opened up\"", "followups:list", Followups.dismissedCount(followups, lastCapeItems) } } },
    } end,
})
-- Default to compact, except before the first-use welcome is answered (the
-- welcome and its help live in the full window) or when the full window was
-- the saved choice (settings.compact == false after "Expand"). An explicit
-- compact preference (true) is kept either way.
if settings.compact == true or (settings.compact == nil and settings.welcomeSeen ~= false) then openCompact() end
Panel.setFilter(2, activityFilter())

Views.debug("loaded. Waiting for the first game tick...")
