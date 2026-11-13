-- core/clock.lua
-- Reset times, worked out from game time in whole minutes since 1970 UTC.
--
-- The game clock is the VarPlayer CLOCK_TIME_DATE_MINUTES (Detect.clockMinutes).
-- Measured on the dev world, 19 October 2026: 29873656 = 14:16 UTC that day.
-- Reset rules from the RuneScape Wiki (Distractions and Diversions page):
--   daily   every day at 00:00 UTC
--   weekly  every Wednesday at 00:00 UTC
--   monthly the 1st of each month at 00:00 UTC
-- plus two activity rhythms from the same table:
--   12h     00:00 and 12:00 game time (Invention tasks)
--   halfhour at half past every hour (Big Chinchompa, Sinkholes)
--
-- Pure arithmetic, no game API, so it's tested outside the game.

local Clock = {}

local DAY = 1440
local WEDNESDAY = 6   -- 1 January 1970 was a Thursday, so day 0 is weekday 0 = Thursday

-- Minutes until the next reset of the given kind, at game time `now`.
function Clock.minutesUntil(kind, now)
    if kind == "daily" then
        return DAY - now % DAY
    elseif kind == "12h" then
        return 720 - now % 720
    elseif kind == "halfhour" then
        local m = now % 60
        return m < 30 and 30 - m or 90 - m
    elseif kind == "weekly" then
        local tomorrow = math.floor(now / DAY) + 1
        local daysAfter = (WEDNESDAY - tomorrow % 7) % 7
        return (DAY - now % DAY) + daysAfter * DAY
    elseif kind == "monthly" then
        -- Walk forward day by day to the next 1st; at most 31 steps.
        local day = math.floor(now / DAY) + 1
        for _ = 1, 32 do
            if Clock.dayOfMonth(day) == 1 then return day * DAY - now end
            day = day + 1
        end
    end
    return nil
end

-- Day of the month (1-31) for a day number counted from 1 January 1970,
-- using Howard Hinnant's civil-from-days algorithm. The constants encode
-- 400-year eras, leap years and March-based month numbering; the arithmetic
-- is integer only.
function Clock.dayOfMonth(days)
    local z = days + 719468
    local era = (z >= 0 and z or z - 146096) // 146097
    local doe = z - era * 146097
    local yoe = (doe - doe // 1460 + doe // 36524 - doe // 146096) // 365
    local doy = doe - (365 * yoe + yoe // 4 - yoe // 100)
    local mp = (5 * doy + 2) // 153
    return doy - (153 * mp + 2) // 5 + 1
end

-- The resets as a heading writes them (Activities' WEEKLY and MONTHLY):
-- the rules above, in game time, which is UTC. No second calculation: the
-- countdowns still come from minutesUntil.
Clock.RESET_LABEL = { daily = "00:00", weekly = "Wed 00:00", monthly = "1st 00:00" }

-- "2d 6h", "3h 15m" or "45m".
function Clock.format(minutes)
    if minutes == nil then return "?" end
    local d, h, m = minutes // DAY, (minutes % DAY) // 60, minutes % 60
    if d > 0 then return string.format("%dd %dh", d, h) end
    if h > 0 then return string.format("%dh %dm", h, m) end
    return string.format("%dm", m)
end

return Clock
