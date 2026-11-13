-- core/alerts.lua
-- Decides when to notify the player. No game API: main.lua passes in what
-- the tabs already computed, and shows whatever this returns as pop-ups.
--
-- After initial priming, reports:
--   - countdown jumps (a reset): one pop-up per kind of reset seen in a
--     check ("Daily reset", "12-hour reset", "Weekly reset", "Monthly
--     reset"), naming the activities that opened again
--   - set-time activities entering their five-minute warning
--   - newly available minigame achievements (locked to unlocked)
-- The first check after loading only records the current state, so a
-- reload never produces a burst of alerts.

local Clock = require("core/clock")

local Alerts = {}

local HEADS_UP = 5   -- minutes before a half-past-the-hour activity

-- A reset's pop-up title, by the period it belongs to (data/timegated.lua
-- `period`, else `reset`), and the order they're listed in when several
-- resets fall in one check (midnight on a Wednesday: daily, 12-hour, weekly).
local RESET_TITLE = { daily = "Daily reset", ["12h"] = "12-hour reset", weekly = "Weekly reset", monthly = "Monthly reset" }
local RESET_ORDER = { "daily", "12h", "weekly", "monthly" }
-- At most this many names in a reset's pop-up, whole; the rest counted.
Alerts.RESET_NAMES = 3

-- "Sinkholes is open again", "Sinkholes and Big Chinchompa are open again",
-- "A, B, C and 2 more are open again": whole names, at most RESET_NAMES.
function Alerts.openAgain(names)
    local n, max = #names, Alerts.RESET_NAMES
    if n == 1 then return names[1] .. " is open again" end
    local shown = {}
    for i = 1, math.min(n, max) do shown[i] = names[i] end
    local text
    if n <= max then
        text = table.concat(shown, ", ", 1, n - 1) .. " and " .. shown[n]
    else
        text = table.concat(shown, ", ") .. " and " .. (n - max) .. " more"
    end
    return text .. " are open again"
end

local lastUntil = {}       -- activity -> minutes until reset at the last check
local lastMinigame = {}    -- item name -> state at the last check
local primed = false

-- Returns a list of { title, text, kind = "reset"|"soon"|"unlock" } to show.
--   timeGated : data/timegated.lua entries
--   isOpen    : function(entry) -> true if any of its achievements isn't done
--   now       : game time in minutes, or nil
--   capeItems : Detect.capeItems()
--   isMinigame: function(item) -> true for minigame achievements (Views.isMinigame)
function Alerts.check(timeGated, isOpen, now, capeItems, isMinigame)
    local out = {}
    local reset = {}   -- period -> the activities that reset in this check, in data order

    if now then
        for _, e in ipairs(timeGated) do
            if e.reset and isOpen(e) then
                -- Uses reset on `period` when set (Big Chinchompa: daily),
                -- else on `reset`. A half-past-the-hour start isn't a reset,
                -- or it would alert every hour; it gets the heads-up instead.
                local periodKind = e.period or e.reset
                if periodKind ~= "halfhour" then
                    local untilReset = Clock.minutesUntil(periodKind, now)
                    local before = lastUntil[e.activity .. "|reset"]
                    if primed and before and untilReset and untilReset > before then
                        reset[periodKind] = reset[periodKind] or {}
                        table.insert(reset[periodKind], e.activity)
                    end
                    lastUntil[e.activity .. "|reset"] = untilReset
                end
                if e.reset == "halfhour" then
                    local untilStart = Clock.minutesUntil("halfhour", now)
                    local before = lastUntil[e.activity .. "|start"]
                    if primed and before and before > HEADS_UP and untilStart <= HEADS_UP then
                        out[#out + 1] = { "STARTING SOON", string.format("%s starts in %d min", e.activity, untilStart), kind = "soon" }
                    end
                    lastUntil[e.activity .. "|start"] = untilStart
                end
            end
        end
    end
    -- One pop-up per reset seen, before the others (main.lua applies the
    -- "Resets" switch to all of them by their kind).
    local resets = {}
    for _, kind in ipairs(RESET_ORDER) do
        if reset[kind] then
            resets[#resets + 1] = { RESET_TITLE[kind], Alerts.openAgain(reset[kind]), kind = "reset" }
        end
    end
    for _, a in ipairs(out) do resets[#resets + 1] = a end
    out = resets

    for _, it in ipairs(capeItems or {}) do
        if isMinigame(it) then
            local before = lastMinigame[it.name]
            if primed and before == "locked" and it.state ~= "locked" and it.state ~= "done" then
                out[#out + 1] = { "MINIGAME UNLOCKED", it.name .. " can be worked on now", kind = "unlock" }
            end
            lastMinigame[it.name] = it.state
        end
    end

    primed = true
    return out
end

-- For tests: forget everything, as after a reload.
function Alerts.reset()
    lastUntil, lastMinigame, primed = {}, {}, false
end

-- Return one reminder pointing to Progress if any long-run goal
-- (data/longachievements.lua) is todo or partial (not done, not locked).
-- main.lua enforces the once-per-session limit and the alert preference.
--   isLong : function(item) -> true for a long-run achievement
-- Returns { title, text } or nil.
function Alerts.longReminder(capeItems, isLong)
    for _, it in ipairs(capeItems or {}) do
        if isLong(it) and (it.state == "todo" or it.state == "partial") then
            return { "Long-run goals", "see Progress" }
        end
    end
    return nil
end

return Alerts
