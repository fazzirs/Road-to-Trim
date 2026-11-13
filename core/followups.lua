-- core/followups.lua
-- "Just opened up": cape checklist achievements that a quest finished during
-- this session lists among its prerequisites. Route achievements (Easy As
-- Pie after Lunar Diplomacy) already follow their quest in data/steps.lua;
-- this is for the game's own checklist items, which the planner places
-- after an unfinished quest only, so they drop to the end once it's done.
--
-- State lives in caller-owned session memory; nothing is saved. A quest is
-- armed when observed started = true and finished = false; its dependent
-- achievements are added when finished = true follows. Unreadable flags are
-- ignored, and a quest already seen complete this session is never armed
-- again. Quests started and finished between two evaluations can be missed.
-- main.lua replaces the state on a new session.
--
-- No game API in here: it works on a Planner.evaluate result and
-- Detect.capeItems() output, so it's tested outside the game.

local Followups = {}

-- A new, empty session state.
--   inProgress : quest name -> true while last seen started and not finished
--   wasDone    : quest name -> true once seen finished this session
--   pending   : { { name = achievement, after = quest }, ... } in order found
--   dismissed : achievement name -> { name, after } (what "Dismiss these"
--               hid, with the quest it came after, so it can be brought back)
--   dismissedOrder : the dismissed entries, in the order they were dismissed
function Followups.new()
    return { inProgress = {}, wasDone = {}, pending = {}, dismissed = {}, dismissedOrder = {} }
end

-- Looks at one evaluation: reads every quest the route or a cape item names,
-- and for each one that was in progress last time and is finished now adds
-- the cape items that list it as a prerequisite to `pending` (unless a route
-- step already names that achievement, or it was dismissed or is already
-- pending).
--   evaluation : Planner.evaluate result (route quests, route achievements)
--   capeItems  : Detect.capeItems() (state, prereqs.quests = { name, ... })
--   quest      : function(name) -> { finished, started } or nil (Detect.quest)
function Followups.observe(state, evaluation, capeItems, quest)
    local names, routeAchievements = {}, {}
    for _, id in ipairs(evaluation.order) do
        local step = evaluation.results[id].step
        if step.type == "quest" and step.quest then names[step.quest] = true end
        if step.type == "achievement" and step.achievement then routeAchievements[step.achievement] = true end
    end
    for _, it in ipairs(capeItems or {}) do
        for _, q in ipairs(it.prereqs and it.prereqs.quests or {}) do
            if q.name then names[q.name] = true end
        end
    end

    local finished = {}
    for name in pairs(names) do
        local q = quest(name)
        -- Only real readings count: both flags must be booleans; anything
        -- else (quest not found, a flag missing) leaves what we knew alone.
        if q ~= nil and type(q.finished) == "boolean" and type(q.started) == "boolean" then
            if q.finished and state.inProgress[name] then finished[name] = true end
            state.inProgress[name] = (q.started and not q.finished and not state.wasDone[name]) or nil
            if q.finished then state.wasDone[name] = true end
        end
    end
    if next(finished) == nil then return end

    local known = {}
    for _, p in ipairs(state.pending) do known[p.name] = true end
    for _, it in ipairs(capeItems or {}) do
        for _, q in ipairs(it.prereqs and it.prereqs.quests or {}) do
            local name = it.name
            if finished[q.name] and name and not known[name] and not state.dismissed[name] and not routeAchievements[name] then
                state.pending[#state.pending + 1] = { name = name, after = q.name }
                known[name] = true
            end
        end
    end
end

-- The pending achievements to show now: the game says they're doable (todo
-- or partial), and they aren't the current step. Done ones leave `pending`.
-- Returns up to `max` entries { item = cape item, after = quest } and how
-- many more doable ones are waiting behind them.
function Followups.visible(state, capeItems, currentName, max)
    local byName = {}
    for _, it in ipairs(capeItems or {}) do if it.name then byName[it.name] = it end end
    local keep, shown, more = {}, {}, 0
    for _, p in ipairs(state.pending) do
        local it = byName[p.name]
        if not (it and it.state == "done") then keep[#keep + 1] = p end
        if it and (it.state == "todo" or it.state == "partial") and p.name ~= currentName then
            if #shown < max then shown[#shown + 1] = { item = it, after = p.after } else more = more + 1 end
        end
    end
    state.pending = keep
    return shown, more
end

-- Hides these achievements for the rest of the session ("Dismiss these").
-- Each keeps the quest it came after (from `pending`), so Settings > Skipped
-- and hidden can list it and bring it back (Followups.restore).
function Followups.dismiss(state, names)
    local after = {}
    for _, p in ipairs(state.pending) do after[p.name] = p.after end
    local gone = {}
    for _, n in ipairs(names or {}) do
        if not state.dismissed[n] then
            local entry = { name = n, after = after[n] }
            state.dismissed[n] = entry
            state.dismissedOrder[#state.dismissedOrder + 1] = entry
        end
        gone[n] = true
    end
    local keep = {}
    for _, p in ipairs(state.pending) do if not gone[p.name] then keep[#keep + 1] = p end end
    state.pending = keep
end

-- What was dismissed this session, in the order it was dismissed: entries
-- { name, after, done }, done = the game says it's finished now (then it
-- can't be brought back; there's nothing left to do for it).
--   capeItems : Detect.capeItems() output, for each achievement's state
function Followups.dismissedList(state, capeItems)
    local doneNow = {}
    for _, it in ipairs(capeItems or {}) do if it.name and it.state == "done" then doneNow[it.name] = true end end
    local out = {}
    for _, e in ipairs(state.dismissedOrder or {}) do
        out[#out + 1] = { name = e.name, after = e.after, done = doneNow[e.name] == true }
    end
    return out
end

-- How many dismissed entries can be brought back (not finished since).
function Followups.dismissedCount(state, capeItems)
    local n = 0
    for _, e in ipairs(Followups.dismissedList(state, capeItems)) do if not e.done then n = n + 1 end end
    return n
end

-- Brings a dismissed achievement back to JUST OPENED UP: off the dismissed
-- list, back on `pending` with the quest it came after. Not if the game says
-- it's finished now. True if it was brought back.
function Followups.restore(state, name, capeItems)
    local entry = state.dismissed[name]
    if not entry then return false end
    for _, it in ipairs(capeItems or {}) do
        if it.name == name and it.state == "done" then return false end
    end
    state.dismissed[name] = nil
    local keep = {}
    for _, e in ipairs(state.dismissedOrder) do if e.name ~= name then keep[#keep + 1] = e end end
    state.dismissedOrder = keep
    for _, p in ipairs(state.pending) do if p.name == name then return true end end
    state.pending[#state.pending + 1] = { name = name, after = entry.after }
    return true
end

return Followups
