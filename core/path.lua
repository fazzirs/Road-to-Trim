-- core/path.lua
-- Builds the Guide queue from time-gated activities, the current route step
-- and available minigame achievements. The first entry becomes DO THIS NOW
-- and the following entries THEN; as things get done in game the queue
-- moves on by itself. No direct game API: callers supply lookup functions
-- and results.
--
-- Order:
--   1. Time-gated activities open right now with a use left this period,
--      soonest reset first (use them or lose them until the next reset).
--   2. The route's next step (Planner.guide current), with its prep.
--   3. Minigame achievements that are available, furthest along first.
--
-- Activities that start at set times (reset = "halfhour": Big Chinchompa,
-- Sinkholes) only join the queue in the last START_WINDOW minutes before
-- they start; earlier than that they're left out for now.
--
-- A time-gated activity whose use counter can't be read stays in the queue
-- until the player clicks "Done for now", which hides it until its next
-- reset (main.lua's in-memory pathSkipped table, this session only: never
-- saved, since settings are shared by every character). Tested outside the
-- game.

local Clock = require("core/clock")
local Views = require("core/views")

local Path = {}

-- Queue set-time activities during their final five minutes before the
-- start. Display chips use the separate Views.CHIP_WINDOW.
Path.START_WINDOW = 5

-- Key under which "Done for now" is remembered for an entry.
function Path.skipKey(e) return e.activity or e.names[1] end

-- Game minute until which "Done for now" hides an entry: the next reset of
-- entry.period if set, otherwise of entry.reset. An unknown period falls
-- back to one day.
function Path.skipUntil(e, now)
    local kind = e.period or e.reset
    return now + (Clock.minutesUntil(kind, now) or 1440)
end

-- Is a time-gated entry worth doing now?
local function timedOpen(e, info, now, readVar, skipped)
    if not (e.reset and e.uses) then return false end
    if skipped[Path.skipKey(e)] and now and skipped[Path.skipKey(e)] > now then return false end
    if not Views.isActionable(e, info) then return false end   -- unknown-only entries aren't suggested
    -- Set start times: only shortly before the start, not 50 minutes early.
    if e.reset == "halfhour" and (Clock.minutesUntil("halfhour", now) or 0) > Path.START_WINDOW then return false end
    local u = Views.uses(e, readVar)
    if u then
        local unknown, left = false, false
        for _, d in ipairs(u.dots) do
            if d == "grey" then unknown = true elseif d == "red" then left = true end
        end
        if not unknown and not left then return false end   -- used up this period
    end
    return true
end

-- What a queue entry stands for, as keys: "name:" an achievement's display
-- name, "config:" its config name, "step:" a route step id. Two entries
-- sharing a key are the same thing. A route quest has only its step id, so
-- unrelated route steps never match each other or an achievement.
function Path.identities(q)
    local keys = {}
    local function add(prefix, v) if v then keys[#keys + 1] = prefix .. v end end
    if q.kind == "timegated" then
        for _, n in ipairs(q.entry.names) do add("name:", n) end
    elseif q.kind == "route" then
        local step = q.result.step
        add("step:", step.id)
        if step.type == "cape" then
            add("name:", step.title)
            add("config:", step.id:match("^cape%-(.+)$"))
        elseif step.achievement then
            -- Route achievements name the achievement by display or config name.
            add("name:", step.achievement)
            add("config:", step.achievement)
        end
    elseif q.kind == "minigame" then
        add("name:", q.item.name)
        add("config:", q.item.config)
    end
    return keys
end

-- The queue.
--   o.guide     : Planner.guide(...) result (o.guide.current may be nil)
--   o.timed     : data/timegated.lua
--   o.info      : function(name) -> cape-item-shaped table or nil
--   o.now       : game minutes (nil = unknown; time-gated steps then skipped)
--   o.readVar   : function(name, id) -> number or nil
--   o.skipped   : { [skipKey] = until-minute }, may be nil
--   o.capeItems : Detect.capeItems()
--   o.isMinigame: Views.isMinigame(...)
--   o.max       : how many entries (default 4)
-- Returns { { kind = "timegated", entry = e, uses = Views.uses(...) }
--         | { kind = "route", result = r }
--         | { kind = "minigame", item = it }, ... }
function Path.build(o)
    local out, max = {}, o.max or 4
    local skipped = o.skipped or {}
    local timedNames = {}

    local timed = {}
    for _, e in ipairs(o.timed or {}) do
        for _, n in ipairs(e.names) do timedNames[n] = true end
        if o.now and timedOpen(e, o.info, o.now, o.readVar, skipped) then
            timed[#timed + 1] = { e = e, left = Clock.minutesUntil(e.period or e.reset, o.now) or 1440 }
        end
    end
    table.sort(timed, function(a, b)
        if a.left ~= b.left then return a.left < b.left end
        return Path.skipKey(a.e) < Path.skipKey(b.e)
    end)
    for _, t in ipairs(timed) do
        out[#out + 1] = { kind = "timegated", entry = t.e, uses = Views.uses(t.e, o.readVar) }
    end

    if o.guide and o.guide.current then out[#out + 1] = { kind = "route", result = o.guide.current } end

    local games = {}
    for _, it in ipairs(o.capeItems or {}) do
        if o.isMinigame and o.isMinigame(it) and not timedNames[it.name]
            and (it.state == "todo" or it.state == "partial") then
            games[#games + 1] = it
        end
    end
    table.sort(games, function(a, b)
        if (a.pct or 0) ~= (b.pct or 0) then return (a.pct or 0) > (b.pct or 0) end
        return a.name < b.name
    end)
    for _, it in ipairs(games) do out[#out + 1] = { kind = "minigame", item = it } end

    -- One entry per achievement: the route's current step can be the same
    -- cape achievement as a time-gated activity or a minigame. Earlier
    -- entries win (the order above), and a time-gated entry claims every
    -- achievement name it covers. Only then is the queue cut to `max`.
    local seen, unique = {}, {}
    for _, q in ipairs(out) do
        local keys = Path.identities(q)
        local dup = false
        for _, k in ipairs(keys) do if seen[k] then dup = true end end
        if not dup then
            for _, k in ipairs(keys) do seen[k] = true end
            unique[#unique + 1] = q
        end
    end
    out = unique

    while #out > max do table.remove(out) end
    return out
end

-- Shared with Details so both surfaces give the same account-mode advice.
Path.itemHint = Views.itemHint

-- Every item a route step asks for (data/steps.lua requires.items), in
-- order, each marked held or not. The planner's result lists only missing
-- ones (r.items, with how many are held); the rest are in the backpack or
-- bank already. Returns { { id, name, need, have, how, held }, ... }.
function Path.stepItems(r)
    local missing = {}
    for _, it in ipairs(r.items or {}) do missing[it.id or it.name] = it end
    local out = {}
    local req = r.step and r.step.requires and r.step.requires.items or {}
    for _, item in ipairs(req) do
        local m = missing[item.id or item.name]
        out[#out + 1] = { id = item.id, ids = item.ids, oneKind = item.oneKind, name = item.name, need = item.count or 1, how = item.how,
            have = m and m.have or nil, held = m == nil }
    end
    return out
end

-- The step's advice for this account mode (data/steps.lua `methods`).
function Path.advice(step, mode)
    local m = step.methods
    return m and (m[mode] or m.ironman) or nil
end

-- Drops "Done for now" marks whose reset has passed, so the table stays small.
function Path.prune(skipped, now)
    if not (skipped and now) then return end
    for k, untilMin in pairs(skipped) do
        if untilMin <= now then skipped[k] = nil end
    end
end

return Path
