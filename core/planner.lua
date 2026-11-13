-- core/planner.lua
-- One guide, in order, that adapts to the account.
--
-- The guide is the route in data/steps.lua with the game's own Trimmed,
-- Completionist and Master Quest Cape checklist items merged in: an item goes
-- right after the last unfinished route quest among its prerequisites, and
-- the rest go at the end (see Planner.evaluate). Long-run goals are kept out
-- by main.lua. The planner gives every step a status from the game,
-- then picks:
--   current   - the first step in guide order that isn't done
--   missing   - for a blocked current step: levels (with a training method),
--               quests, earlier steps, achievements and items it still needs
--   meanwhile - the next few steps further down the guide that are doable now
-- Done steps skip themselves, including ones done out of order.
--
-- No game API in here: it takes a "detect" table of functions (core/detect.lua,
-- or a fake one in tests), so it runs and is tested outside the game.
--
-- Statuses:
--   done     - the game says it's complete (quest finished, level reached, ...)
--   doable   - every requirement is met and every required item is in hand
--   prepare  - requirements met, but one or more items are missing
--   locked   - a skill level, quest or earlier step is still missing
--   unknown  - the game doesn't know the quest/achievement name in the data

local Planner = {}

-- Normalise quest names like core/detect.lua: ignore case and punctuation,
-- and drop an optional "(miniquest)" or "(saga)" suffix, so the route's
-- "Koschei's Troubles" matches the game's "Koschei's Troubles (miniquest)".
local function plainName(s)
    return s and (s:lower():gsub("%s*%((%a+)%)%s*$", function(kind)
        if kind == "miniquest" or kind == "saga" then return "" end
    end):gsub("[^%w ]", ""):gsub("%s+", " ")) or nil
end

-- Does the game say this step is already done? Returns done, known.
-- known = false means the game couldn't find the quest/achievement at all.
local function isDone(step, detect)
    if step.type == "quest" and step.quest then
        local q = detect.quest(step.quest)
        if q == nil then return false, false end
        return q.finished, true
    elseif step.type == "skill" and step.skill then
        local lvl = detect.skillLevel(step.skill)
        return lvl ~= nil and lvl >= step.level, true
    elseif step.type == "achievement" and step.achievement then
        local a = detect.achievement(step.achievement)
        if a == nil then return false, false end
        return a.done, true
    end
    -- A step type without a supported completion reader (an unlock or a
    -- note) stays unfinished; completion is never inferred.
    return false, true
end

-- How many of a required item are held, with count(id) giving the number of
-- one item ID. An item is one ID, or a list of IDs that all count toward the
-- same requirement (e.g. "any 10 gold artefacts", a mix, so they add up).
-- oneKind = true in the data: the quest wants that many of ONE kind (10 logs
-- of the same kind), so only the largest single-ID count counts; 5 normal and
-- 5 oak logs are 5, not 10.
function Planner.itemHave(item, count)
    local have = 0
    for _, id in ipairs(item.ids or { item.id }) do
        local n = count(id) or 0
        if item.oneKind then
            if n > have then have = n end
        else
            have = have + n
        end
    end
    return have
end

-- Adds a missing-skill entry unless one for the same skill is already there,
-- keeping the higher target.
local function addMissingSkill(missing, skill, need, have)
    for _, m in ipairs(missing) do
        if m.kind == "skill" and m.skill == skill then
            if need > m.need then m.need = need end
            return
        end
    end
    missing[#missing + 1] = { kind = "skill", skill = skill, need = need, have = have }
end

-- Collects what's missing for a route step. Returns two lists: hard
-- requirements (levels, quests, steps) and missing items.
local function missingFor(step, detect, stepsById)
    local missing, items = {}, {}
    local req = step.requires or {}

    -- The game's own prerequisites for a quest come first; the data only
    -- needs to add what the game doesn't track (items, route ordering).
    if step.type == "quest" and step.quest then
        local q = detect.quest(step.quest)
        if q then
            for _, s in ipairs(q.prereqSkills or {}) do
                if not s.done then
                    addMissingSkill(missing, s.skill, s.level, detect.skillLevel(s.skill) or 0)
                end
            end
            for _, pq in ipairs(q.prereqQuests or {}) do
                if not pq.done then
                    missing[#missing + 1] = { kind = "quest", quest = pq.name, name = pq.name }
                end
            end
            -- Quest points or anything else the game checks that we don't model.
            if q.canStart == false and #missing == 0 and not q.started then
                missing[#missing + 1] = { kind = "prereq", text = "other requirements (see the quest journal)" }
            end
        end
    end

    for skill, level in pairs(req.skills or {}) do
        local have = detect.skillLevel(skill) or 0
        if have < level then addMissingSkill(missing, skill, level, have) end
    end

    if req.combat then
        local have = detect.combatLevel() or 0
        if have < req.combat then
            missing[#missing + 1] = { kind = "combat", need = req.combat, have = have }
        end
    end

    for _, questName in ipairs(req.quests or {}) do
        local q = detect.quest(questName)
        if not (q and q.finished) then
            missing[#missing + 1] = { kind = "quest", quest = questName, name = q and q.name or questName }
        end
    end

    -- A route step that's a quest the game already listed above (Holy Grail
    -- needs Merlin's Crystal both ways) isn't listed twice.
    local listed = {}
    for _, m in ipairs(missing) do if m.kind == "quest" and m.quest then listed[plainName(m.quest)] = true end end   -- a nameless one can't match
    for _, stepId in ipairs(req.steps or {}) do
        local other = stepsById[stepId]
        if other and not isDone(other, detect) and not (other.quest and listed[plainName(other.quest)]) then
            -- Its type too, so the window strips the route's "Complete " from
            -- a quest's title only (Views.plainTitle).
            missing[#missing + 1] = { kind = "step", step = stepId, title = other.title, stepType = other.type }
        end
    end

    for _, item in ipairs(req.items or {}) do
        local have = Planner.itemHave(item, detect.itemCount)
        if have < (item.count or 1) then
            items[#items + 1] = { id = item.id, name = item.name, need = item.count or 1, have = have, how = item.how }
        end
    end

    return missing, items
end

-- A cape checklist item (Detect.capeItems) as a guide result. The game
-- supplies the state; a locked item gets the same missing-list shape as a
-- route step. Comp items are phase 6, Trim items phase 7.
local CAPE_PHASE = { comp = 6, trim = 7 }

local function capeResult(it, detect)
    local step = {
        id = "cape-" .. it.config, phase = CAPE_PHASE[it.cape] or 7,
        title = it.name, type = "cape", cape = it.cape, trimReq = true,
    }
    local r = { step = step, status = "locked", missing = {}, items = {},
                pct = it.pct, remaining = it.remaining, tally = it.tally }
    if it.state == "done" then
        r.status = "done"
    elseif it.state == "locked" then
        for _, s in ipairs(it.prereqs.skills) do
            if not s.done then addMissingSkill(r.missing, s.skill, s.level, detect.skillLevel(s.skill) or 0) end
        end
        for _, q in ipairs(it.prereqs.quests) do
            if not q.done then r.missing[#r.missing + 1] = { kind = "quest", quest = q.name, name = q.name } end
        end
        for _, a in ipairs(it.prereqs.achievements) do
            if not a.done then r.missing[#r.missing + 1] = { kind = "achievement", name = a.name } end
        end
    else
        r.status = "doable"
    end
    return r
end

-- Gives every step in the guide a status.
--   steps     : list from data/steps.lua, in guide order
--   detect    : table of functions (see core/detect.lua)
--   mode      : "ironman" | "hardcore" | "group" | "main"
--   capeItems : optional, Detect.capeItems(); each goes after the last
--               unfinished route quest among its prerequisites, the rest at
--               the end, in the order given
-- Returns { results = {id -> result}, order = {id, ...}, warnings = {...},
--           phase = n, mode = mode }
function Planner.evaluate(steps, detect, mode, capeItems)
    local stepsById = {}
    for _, s in ipairs(steps) do stepsById[s.id] = s end

    local results, order, warnings = {}, {}, {}
    local currentPhase = nil

    for _, step in ipairs(steps) do
        -- Skip steps that don't apply to this account mode.
        local applies = true
        if step.modes then
            applies = false
            for _, m in ipairs(step.modes) do if m == mode then applies = true end end
        end

        if applies then
            local r = { step = step, status = "locked", missing = {}, items = {} }
            local done, known = isDone(step, detect)
            if not known then
                r.status = "unknown"
                warnings[#warnings + 1] = "Game doesn't know: " .. (step.quest or step.achievement or step.id)
            elseif done then
                r.status = "done"
            else
                r.missing, r.items = missingFor(step, detect, stepsById)
                if #r.missing == 0 and #r.items == 0 then
                    r.status = "doable"
                elseif #r.missing == 0 then
                    r.status = "prepare"
                end
                if currentPhase == nil or (step.phase or 1) < currentPhase then
                    currentPhase = step.phase or 1
                end
            end
            results[step.id] = r
            order[#order + 1] = step.id
        end
    end

    -- Cape items go right after the last route quest among their
    -- prerequisites that ISN'T done yet, so an achievement that opens up
    -- after a quest is the next thing in the guide once that quest is done.
    -- Quests already done don't count: anchoring to one placed long grinds
    -- ahead of the route (seen on an Ironman account: a Slayer achievement
    -- tied to an early quest jumped ahead of Lunar Diplomacy). Those, and the
    -- rest, go at the end; the Guide lists the unlocked ones under CAN DO NOW.
    local questStep = {}
    for _, step in ipairs(steps) do
        local r = results[step.id]
        if step.type == "quest" and step.quest and r and r.status ~= "done" then questStep[plainName(step.quest)] = step.id end
    end
    local position = {}
    for i, id in ipairs(order) do position[id] = i end
    local after, tail = {}, {}
    for _, it in ipairs(capeItems or {}) do
        local r = capeResult(it, detect)
        if results[r.step.id] == nil then
            results[r.step.id] = r
            local anchor = nil
            for _, q in ipairs(it.prereqs and it.prereqs.quests or {}) do
                local sid = questStep[plainName(q.name)]
                if sid and (anchor == nil or position[sid] > position[anchor]) then anchor = sid end
            end
            r.afterQuest = anchor and results[anchor].step.title or nil
            if anchor then
                after[anchor] = after[anchor] or {}
                table.insert(after[anchor], r.step.id)
            else
                tail[#tail + 1] = r.step.id
            end
            if r.status ~= "done" and currentPhase == nil then currentPhase = r.step.phase end
        end
    end
    local merged = {}
    for _, id in ipairs(order) do
        merged[#merged + 1] = id
        for _, cid in ipairs(after[id] or {}) do merged[#merged + 1] = cid end
    end
    for _, cid in ipairs(tail) do merged[#merged + 1] = cid end
    order = merged

    -- Which cape achievements each route quest opens up, for its Details.
    for anchor, list in pairs(after) do
        results[anchor].opens = {}
        for _, cid in ipairs(list) do table.insert(results[anchor].opens, results[cid].step.title) end
    end

    return { results = results, order = order, warnings = warnings,
             phase = currentPhase or 1, mode = mode }
end

-- Reads the guide off an evaluation.
--   methods : optional, data/methods.lua; names a training method for each
--             missing level on the current step
--   max     : how many "meanwhile" steps to return (default 3)
--   postponed : optional, step id -> anything: steps the player put off for
--               now ("Skip until reset"). They aren't picked as current or
--               meanwhile, and neither is anything still waiting on one
--               (Easy As Pie after a skipped Lunar Diplomacy), directly or
--               through another; their status is as evaluated, so nothing
--               they unlock opens up early.
-- Returns { current = result or nil, position = n, total = n,
--           done = n, meanwhile = {result, ...}, postponed = n (put off or
--           waiting on one), alternatives = {result, ...} }
-- alternatives (the Guide's ALSO AVAILABLE) begins with current, including
-- a cape step, followed by unfinished route steps in guide order that are
-- doable, wait only on items, or wait only on earlier route steps and
-- quests. Later cape steps (CAN DO NOW lists those), skipped steps and their
-- dependants, unknown steps and steps blocked by a level, combat level or
-- unknown requirement are excluded. main.lua removes entries already queued
-- and caps the display.
function Planner.guide(evaluation, methods, max, postponed)
    max = max or 3
    -- Put off: the postponed steps, then whatever still needs one of them,
    -- by step id or by quest name, until nothing more is added.
    local off, offQuest = {}, {}
    for id in pairs(postponed or {}) do
        local r = evaluation.results[id]
        if r and r.status ~= "done" then
            off[id] = true
            if r.step.quest then offQuest[plainName(r.step.quest)] = true end
        end
    end
    local grew = next(off) ~= nil
    while grew do
        grew = false
        for _, id in ipairs(evaluation.order) do
            local r = evaluation.results[id]
            if not off[id] and r.status ~= "done" then
                for _, m in ipairs(r.missing or {}) do
                    if (m.kind == "step" and off[m.step]) or (m.kind == "quest" and offQuest[plainName(m.name or m.quest)]) then
                        off[id] = true
                        if r.step.quest then offQuest[plainName(r.step.quest)] = true end
                        grew = true
                        break
                    end
                end
            end
        end
    end
    local current, position, done, put = nil, 0, 0, 0
    local meanwhile, alternatives = {}, {}
    -- Waits only on earlier route steps or quests (or on nothing but items).
    local function onlySteps(r)
        for _, m in ipairs(r.missing or {}) do
            if m.kind ~= "step" and m.kind ~= "quest" then return false end
        end
        return true
    end
    for i, id in ipairs(evaluation.order) do
        local r = evaluation.results[id]
        if r.status == "done" then
            done = done + 1
        elseif off[id] then
            put = put + 1
        elseif r.status ~= "unknown" then
            if current == nil then
                current, position = r, i
                -- Always include current first, even a locked cape
                -- achievement; later cape entries are excluded below.
                alternatives[#alternatives + 1] = r
            else
                if r.status == "doable" and #meanwhile < max then
                    meanwhile[#meanwhile + 1] = r
                end
                if r.step.type ~= "cape" and onlySteps(r) then alternatives[#alternatives + 1] = r end
            end
        end
    end
    -- Attach a training method to each missing level of the current step.
    if current and methods then
        for _, m in ipairs(current.missing) do
            if m.kind == "skill" then m.method = methods.lookup(m.skill, m.have, evaluation.mode) end
        end
    end
    return { current = current, position = position, total = #evaluation.order,
             done = done, meanwhile = meanwhile, postponed = put, alternatives = alternatives }
end

-- What's left that the guide never suggests, for completion accounting:
-- "nothing to suggest" is not "all done". Counts
--   long    : long-run cape checklist items (isLong) not done, locked ones
--             included; they're kept out of the evaluation on purpose
--   unknown : route steps the game doesn't know (status "unknown"), which
--             Planner.guide skips
-- Each achievement or quest is counted once, by name, across both.
--   capeItems : the full Detect.capeItems() list (not just the suggestable ones)
-- Counts cover only checklist entries the detector returned: a cape list or
-- item that failed to read is missing from capeItems and cannot be counted.
-- Returns { long = n, unknown = n }.
function Planner.remaining(evaluation, capeItems, isLong)
    local seen, long, unknown = {}, 0, 0
    for _, it in ipairs(capeItems or {}) do
        local key = plainName(it.name or it.config or "")
        if isLong(it) and it.state ~= "done" and not seen[key] then
            seen[key] = true
            long = long + 1
        end
    end
    for _, id in ipairs(evaluation.order) do
        local r = evaluation.results[id]
        local key = plainName(r.step.achievement or r.step.quest or r.step.title or id)
        if r.status == "unknown" and not seen[key] then
            seen[key] = true
            unknown = unknown + 1
        end
    end
    return { long = long, unknown = unknown }
end

return Planner
