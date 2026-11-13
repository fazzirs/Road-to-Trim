-- core/views.lua
-- Builds the rows for the Guide, Activities, Progress, Details, Help and
-- auxiliary lists. No direct game API and no persistence: it works on the
-- cape items from Detect.capeItems() and on lookup functions the caller
-- supplies (those may read the game). ui/panel.lua renders the results.
-- Tested outside the game.
--
-- A row is { text, wiki = page or nil, tone = "title"|"head"|"good"|"warn"|"dim"|"note"|nil,
--            pad = { icon = bool, dots = n } (indent as if those were there),
--            dots = { "green"|"red"|"grey", ... } or nil }
-- ui/panel.lua draws `dots` as small circles at the start of the row, or at
-- its right end with dotsRight = true. The other fields it reads (right,
-- rightChip, bar, card, ...) are listed at Views.signature.
-- { "" } is a spacer.

local Clock = require("core/clock")

local Views = {}

-- How to get a missing item, in one short line. Ironman-first: the
-- gathering method from data/steps.lua. A main account is told to buy it
-- when the wiki confirms GE access (data/itemsources.lua); the plugin sees it in
-- the backpack or bank either way and moves on. Coins are never "bought".
function Views.itemHint(item, mode, sources)
    local src = sources and item.id and sources[item.id]
    if mode == "main" and src and src.tradeable == true and src.exchange == true and item.id ~= 995 then
        return "Buy on the Grand Exchange"
    end
    return item.how or "Bring your own: the quest doesn't give it"
end

-- Icons for rows (data/icons.lua), set by main.lua; nil in tests is fine.
Views.ICONS = {}

-- Wrap at spaces while preserving the action boundaries authored in the data.
function Views.wrap(text, width)
    local lines = {}
    for paragraph in (tostring(text) .. "\n"):gmatch("([^\n]*)\n") do
        local line = ""
        for word in paragraph:gmatch("%S+") do
            if line == "" then line = word
            elseif #line + 1 + #word <= width then line = line .. " " .. word
            else lines[#lines + 1] = line; line = word end
        end
        lines[#lines + 1] = line
    end
    return lines
end

-- About how many characters fit on one row of the 340 px window (ui/panel.lua
-- WIDTH, the compact card's: its 38 fit in 320 px; a tab's rows have about
-- 310). Rows with an icon or circles lose a few.
Views.ROW_CHARS = 37
-- The amount column (row.right, 90 px at the tab's right edge in
-- ui/panel.lua) starts about this many characters into the row; text before
-- it stops 1 short.
Views.RIGHT_COL_CHARS = 28

-- Text cut to `width` characters with "..." on the end (the card's why line,
-- the compact card's one-line rows). Shorter text comes back as it is.
function Views.cut(text, width)
    text = tostring(text or "")
    if #text <= width then return text end
    return (text:sub(1, math.max(1, width - 3)):gsub("%s+$", "")) .. "..."
end

-- Split a numbered instruction ("2. Talk to ...") into its number and text,
-- so the window can colour the number separately.
-- Nil for any other line.
function Views.splitNum(text)
    local num, rest = (text or ""):match("^(%d%d?%.)%s+(.+)$")
    return num, rest
end

-- Rows with text too long for one line become several rows: the first
-- keeps everything, the rest keep tone / wiki / select (so they're still
-- clickable) but not the icon or circles; `pad` tells ui/panel.lua to
-- indent them to line up with the first line's text. A row with an amount
-- column wraps before it, so a long item name doesn't run under the amount.
--   rightCol : where the amount column starts, in characters (default
--              RIGHT_COL_CHARS)
--   measured : true to wrap by measured pixels instead (Views.wrapPx into
--              Views.lineRoom's room: the icon, circles, number, inset and
--              every right-hand column as ui/panel.lua draws them). The
--              Guide list uses it; other callers use character limits.
function Views.wrapRows(rows, width, rightCol, measured)
    width = width or Views.ROW_CHARS
    local out = {}
    for _, r in ipairs(rows) do
        local pad = r.pad or {}
        local hasIcon = r.icon ~= nil or pad.icon == true
        -- Circles on the right (r.dotsRight, a THEN entry's uses) don't push
        -- the text in; they take room at the row's end instead.
        local leftDots = (r.dots and not r.dotsRight) and #r.dots or 0
        local nDots = math.max(leftDots, pad.dots or 0)
        local leading = (hasIcon and 4 or 0) + 3 * nDots
        local lineEnd = width
        if r.dots and r.dotsRight then lineEnd = width - (3 * #r.dots + 2) end
        if r.right and r.rightChip then lineEnd = width - (#r.right + 4)   -- a status chip (ui/panel.lua, Views.chipWidth)
        elseif r.right and r.rightFar then lineEnd = width - 7   -- "Ready" has a narrower column (ui/panel.lua READY_WIDTH)
        elseif r.right then lineEnd = math.min(width, (rightCol or Views.RIGHT_COL_CHARS) - 1) end
        local room = lineEnd - leading
        local lines
        if measured and not r.oneLine then
            lines = Views.wrapPx(r[1] or "", Views.lineRoom(r))
        else
            lines = Views.wrap(r[1] or "", room)
        end
        if r.oneLine then
            -- A oneLine row (such as a THEN entry) stays on one visual row:
            -- its text is cut with "..." to the pixels left after its icon,
            -- circles and right column (Views.lineRoom, the same width
            -- ui/panel.lua gives its text box).
            local cut = Views.cutPx(r[1] or "", Views.lineRoom(r))
            if cut == (r[1] or "") then
                out[#out + 1] = r
            else
                local one = {}
                for k, v in pairs(r) do one[k] = v end
                one[1] = cut
                out[#out + 1] = one
            end
        elseif (r[1] or "") == "" or (#lines <= 1 and (not measured or Views.textWidth(r[1] or "") <= Views.lineRoom(r))) then
            -- One line: the row as given, its spacing exactly as written. In
            -- character mode always (as before); in measured mode when the
            -- whole text fits its room, so only a cut over-wide word (below)
            -- replaces the text.
            out[#out + 1] = r
        else
            -- Several lines, or (measured) one line that isn't the text as
            -- given because an over-wide word was cut: the first keeps the row.
            local first = {}
            for k, v in pairs(r) do first[k] = v end
            first[1] = lines[1]
            -- Continuation rows keep the original click target, and the
            -- lines of one clickable name share one `span` table, so
            -- ui/panel.lua highlights all of them when the mouse is on any
            -- one and the whole wrapped name opens one entry. A fresh table
            -- per name: two
            -- entries next to each other with the same `select` stay apart.
            -- A row wrapped again (already a span's line) keeps its span.
            local span = r.span or (r.select ~= nil and {} or nil)
            first.span = span
            out[#out + 1] = first
            -- A numbered step's later lines start under its text, past the number.
            local numbered = Views.splitNum(r[1]) ~= nil or pad.num == true
            for i = 2, #lines do
                out[#out + 1] = { lines[i], tone = r.tone, wiki = r.wiki, select = r.select,
                    pad = { icon = hasIcon, dots = nDots, num = numbered or nil }, band = r.band, card = r.card,
                    optional = r.optional, span = span }
            end
        end
    end
    return out
end

-- Rows for a step's items as a table: a header, then per item its icon, a
-- green (held) / red (missing) circle, the name, and the amount in the
-- right column; under a missing one, `hint(item)` lines (how to get it),
-- inside the same stripe.
--   items : { { id, name, need, have, held, how }, ... } (Path.stepItems)
--   hint  : function(item) -> list of strings, may be nil
function Views.itemTable(items, hint)
    local rows = {}
    if #items == 0 then return rows end
    rows[#rows + 1] = { "Item", tone = "head", right = "Amount", rightTone = "head", band = "head", pad = { icon = true, dots = 1 } }
    for k, it in ipairs(items) do
        local band = (k % 2 == 1) and 1 or 2
        local amount = it.held and ("x" .. it.need)
            or (it.have and it.have > 0 and string.format("%d / %d", it.have, it.need) or ("0 / " .. it.need))
        rows[#rows + 1] = { it.name, wiki = it.name, tone = it.held and "good" or "warn",
            icon = it.id and { item = it.id } or nil, dots = { it.held and "green" or "red" },
            pad = (it.id == nil) and { icon = true } or nil,   -- no icon (any of several IDs): line up anyway
            right = amount, rightTone = it.held and "good" or "warn", band = band }
        if not it.held and hint then
            for _, h in ipairs(hint(it) or {}) do
                rows[#rows + 1] = { h, tone = "note", pad = { icon = true, dots = 1 }, band = band }
            end
        end
    end
    return rows
end

-- A row as one line of plain text, its right-hand column (an item's amount,
-- "Ready") on the end: for the compact and basic windows and the console,
-- which have no second column.
function Views.plainText(row)
    local text = row[1] or ""
    -- Chips and buttons (the Guide's card) as plain words.
    local pills = {}
    for _, c in ipairs(row.chips or row.buttons or {}) do pills[#pills + 1] = c[1] end
    if #pills > 0 then text = (text ~= "" and (text .. "  ") or "") .. table.concat(pills, "  |  ") end
    if row.right and row.right ~= "" then text = text .. "  " .. row.right end
    return text
end

-- Return a shallow copy of a row list; the row tables themselves stay
-- shared.
function Views.flatten(rows)
    local out = {}
    for i, row in ipairs(rows or {}) do out[i] = row end
    return out
end

-- DEBUG controls console lines that only report success (index counts,
-- "loaded", the mouse cursor count, the first wheel delta). Warnings,
-- failures, the alerts' console copy and the startup text-width line print
-- whatever DEBUG is.
Views.DEBUG = false
function Views.debug(text)
    if Views.DEBUG then print("[Road to Trim] " .. tostring(text)) end
end

-- Redraw signature (Views.signature below). Each value tagged with its type and, for text, its length, so no two
-- different rows can encode the same ("ab"+"c" vs "a"+"bc", 1 vs "1").
local function sigValue(v)
    local t = type(v)
    if v == nil then return "-" end
    if t == "string" then return "s" .. #v .. ":" .. v end
    if t == "number" then return "n" .. tostring(v) .. ";" end
    if t == "boolean" then return v and "T" or "F" end
    return "?" .. t   -- not expected in a row's fields
end
-- A small table of plain values (an icon, circles, pad, a colour), keys
-- sorted so two equal tables built separately give the same text. One level
-- only, on purpose: rows don't nest deeper.
local function sigTable(t)
    if type(t) ~= "table" then return sigValue(t) end
    local keys = {}
    for k in pairs(t) do keys[#keys + 1] = k end
    table.sort(keys, function(a, b)
        if type(a) ~= type(b) then return type(a) < type(b) end
        if type(a) == "number" or type(a) == "string" then return a < b end
        return tostring(a) < tostring(b)
    end)
    local parts = {}
    for _, k in ipairs(keys) do parts[#parts + 1] = sigValue(k) .. "=" .. sigValue(t[k]) end
    return "{" .. #keys .. ":" .. table.concat(parts) .. "}"
end
-- The row fields ui/panel.lua reads to draw a row or act on a click, in a
-- fixed order. A new field the panel starts reading belongs here too.
local SIG_FIELDS = { "right", "rightTone", "rightFar", "tone", "select", "wiki", "arrow", "band",
    "amount", "amountTone", "amountW", "indent", "padDot", "rightChip", "dotsRight", "card", "rightWide",
    "inset", "oneLine", "noBox",
    -- Compact title, instruction and measurement fields, plus the Details
    -- title's Wiki target.
    "wrapTitle", "instr", "instrMore", "measured", "titleWiki",
    -- A Help row's leading term, drawn separately in the emphasis colour.
    "term" }
-- ring = { frac, text } is the Progress tab's (Views.progressRows); one
-- level deep.
local SIG_TABLES = { "dots", "icon", "pad", "rgba", "bar", "ring", "compactButton" }
-- Lists of small tables: a row's chips and buttons ({ text, tone, select, wiki, hint }).
local SIG_LISTS = { "chips", "buttons" }
local function sigList(t)
    if type(t) ~= "table" then return sigValue(t) end
    local parts = {}
    for _, v in ipairs(t) do parts[#parts + 1] = sigTable(v) end
    return "[" .. #t .. ":" .. table.concat(parts) .. "]"
end

-- What's visible and clickable in a set of row lists, as one string:
-- main.lua redraws only when it changes, and the compact card goes back to
-- its first page. Each list and each row is counted, so where one list ends
-- and the next starts is part of the text.
function Views.signature(lists)
    local parts = { "lists" .. #lists }
    for _, rows in ipairs(lists) do
        parts[#parts + 1] = "list" .. #rows
        for _, row in ipairs(rows) do
            local p = { sigValue(row[1]) }
            for _, f in ipairs(SIG_FIELDS) do p[#p + 1] = sigValue(row[f]) end
            for _, f in ipairs(SIG_TABLES) do p[#p + 1] = sigTable(row[f]) end
            for _, f in ipairs(SIG_LISTS) do p[#p + 1] = sigList(row[f]) end
            parts[#parts + 1] = table.concat(p, "|")
        end
    end
    return table.concat(parts, "\n")
end

-- The current step's block on the Guide, one column (the window is the
-- compact card's width): its text (walkthrough line, missing levels, tips),
-- the items it needs under it (the Views.itemTable checklist), then how to
-- get each missing item. At most `max` rows on the page, after wrapping.
--   left   : rows; ones marked `optional` (tips, also in Details) give way
--            first when the page is short
--   items  : { { id, name, need, have, held, how }, ... } (Path.stepItems)
--   hint   : function(item) -> list of strings, may be nil
--   select : what a "click for Details" line opens (the step)
-- Whole items only: an item keeps its "how" lines. What doesn't fit is
-- counted on a line that opens its details, which list everything ("+2
-- more: details" after the items, "More tips: click for details" after the
-- text).
function Views.stepBlock(left, items, hint, max, select)
    -- An item's line wraps before its amount.
    local function cellRows(row) return Views.wrapRows({ row }) end
    -- The text: one group per row given, wrapped.
    local groups, nOptional = {}, 0
    for _, r in ipairs(left) do
        local rows = Views.wrapRows({ r })
        for _, w in ipairs(rows) do w.optional = r.optional end   -- every wrapped line of a tip is optional
        groups[#groups + 1] = { rows = rows, optional = r.optional }
        if r.optional then nOptional = nOptional + 1 end
    end
    -- The items: the checklist without its hint lines; the hints go after
    -- it instead, as "Name: how".
    local table_ = Views.itemTable(items, nil)
    local header = table_[1]
    local blocks = {}
    for k, it in ipairs(items) do
        local b = { cells = cellRows(table_[k + 1]), hints = {} }
        if not it.held and hint then
            for _, h in ipairs(hint(it) or {}) do
                for _, r in ipairs(Views.wrapRows({ { it.name .. ": " .. h, tone = "note", pad = { icon = true } } })) do
                    r.optional = true   -- every wrapped line of it (the compact view leaves them out)
                    b.hints[#b.hints + 1] = r
                end
            end
        end
        blocks[k] = b
    end

    -- Lays out the block with the first nItems items and nOpt optional left
    -- rows; returns the rows and their count.
    local function build(nItems, nOpt)
        local L, keptOpt = {}, 0
        for _, g in ipairs(groups) do
            local keep = not g.optional or keptOpt < nOpt
            if g.optional and keep then keptOpt = keptOpt + 1 end
            if keep then for _, r in ipairs(g.rows) do L[#L + 1] = r end end
        end
        if nOpt < nOptional then
            L[#L + 1] = { "More tips: click for details", tone = "dim", select = select, pad = { icon = true }, optional = true }
        end
        local R, H = {}, {}
        if nItems > 0 then R[1] = header end
        for k = 1, nItems do
            for _, c in ipairs(blocks[k].cells) do R[#R + 1] = c end
            for _, h in ipairs(blocks[k].hints) do H[#H + 1] = h end
        end
        local leftOut = #blocks - nItems
        if leftOut > 0 then
            local text = nItems == 0 and string.format("%d item%s: details", leftOut, leftOut == 1 and "" or "s")
                or string.format("+%d more: details", leftOut)
            for _, c in ipairs(cellRows({ text, tone = "dim", select = select, pad = { icon = true, dots = 1 } })) do R[#R + 1] = c end
        end
        local rows = {}
        for _, part in ipairs({ L, R, H }) do
            for _, r in ipairs(part) do rows[#rows + 1] = r end
        end
        return rows
    end

    -- Most items first, then most tips, that fit.
    for nItems = #blocks, 0, -1 do
        for nOpt = nOptional, 0, -1 do
            local rows = build(nItems, nOpt)
            if #rows <= max then return rows end
        end
    end
    -- Not even the required left lines fit: keep what does, then a Details line.
    local rows = build(0, 0)
    local cut = {}
    for k = 1, math.max(max, 1) - 1 do cut[k] = rows[k] end
    cut[#cut + 1] = { "More: click for details", tone = "dim", select = select, pad = { icon = true } }
    return cut
end

-- Uses this period for a time-gated entry, as circles.
--   readVar : function(name, id) -> number or nil (Detect.varValue)
-- Returns nil for entries without a per-period limit, else
-- { dots = {...}, unconfirmed = bool }: green per use done, red per use left,
-- all grey when the counter can't be read.
function Views.uses(e, readVar)
    if not e.uses then return nil end
    local used = nil
    if e.counter and readVar then
        local v = readVar(e.counter.name, e.counter.id)
        if v then used = math.max(0, math.min(e.uses, v)) end
    end
    local dots = {}
    for i = 1, e.uses do
        if used == nil then dots[i] = "grey"
        elseif i <= used then dots[i] = "green"
        else dots[i] = "red" end
    end
    return { dots = dots, unconfirmed = used ~= nil and e.counter and not e.counter.confirmed }
end

-- Shortest useful timing text: "next in 14m" for activities that start at
-- half past the hour, else "resets in 6h 16m".
local function timing(e, now)
    if not (e.reset and now) then return nil end
    local m = Clock.format(Clock.minutesUntil(e.reset, now))
    if e.reset == "halfhour" then return "next in " .. m end
    return "resets in " .. m
end

-- What's still missing to unlock an achievement, from the game's own
-- prerequisites (skills, quests, other achievements).
local function missingText(it)
    local parts = {}
    for _, sk in ipairs(it.prereqs.skills) do
        if not sk.done then parts[#parts + 1] = string.format("%s %d", sk.skill:sub(1, 1):upper() .. sk.skill:sub(2), sk.level) end
    end
    for _, q in ipairs(it.prereqs.quests) do
        if not q.done then parts[#parts + 1] = q.name end
    end
    for _, ach in ipairs(it.prereqs.achievements) do
        if not ach.done then parts[#parts + 1] = ach.name end
    end
    return table.concat(parts, ", ")
end
Views.missingText = missingText

-- Activities filters in display order; main.lua saves the selection:
--   All        everything: open entries, locked ones dim, done ones
--   Open now   what can be done now (Views.actionable) and the minigames
--              open to this account
--   Today      what can be done now and resets today: the daily,
--              twice-daily and set-time activities
--   This week  Today, plus the weekly ones
-- Monthly activities, the ones with no fixed reset and minigames show under
-- All and Open now only: they aren't due by a day.
Views.FILTERS = { "All", "Open now", "Today", "This week" }
-- Default to Open now unless a recognised choice was saved. An explicit
-- saved All is kept.
Views.DEFAULT_FILTER = "Open now"
-- Filters saved by older versions, as the new ones (main.lua rewrites a
-- saved one at start-up): Available was what's open; Locked and Done have
-- no filter of their own now, All lists them.
Views.FILTER_MIGRATION = { Available = "Open now", Locked = "All", Done = "All" }

-- An entry's state from its achievements:
--   done      every achievement done
--   locked    every unfinished one is locked; `why` says what's missing
--   available otherwise
-- `pick` is the achievement the entry's row opens: the first unfinished one
-- that isn't locked, else the first locked one, else the first name. So an
-- activity with several names (Player-owned port) opens Details for the
-- achievement selected by that priority.
local function entryState(e, info)
    local done, unknown, lockedReasons, open = 0, 0, {}, 0
    local firstOpen, firstLocked
    for _, n in ipairs(e.names) do
        local it = info(n)
        if it == nil then
            unknown = unknown + 1
        elseif it.state == "done" then
            done = done + 1
        else
            open = open + 1
            if it.state ~= "locked" then firstOpen = firstOpen or n end
            if it.state == "locked" then
                firstLocked = firstLocked or n
                local why = missingText(it)
                if why ~= "" then lockedReasons[#lockedReasons + 1] = why end
                lockedReasons.count = (lockedReasons.count or 0) + 1
            end
        end
    end
    local state = "available"
    if done == #e.names then state = "done"
    elseif open > 0 and (lockedReasons.count or 0) == open then state = "locked" end
    -- open: a known, unfinished, unlocked achievement exists. An entry the
    -- game knows nothing about (or only done + unknown names) still shows as
    -- available on the tab, but isn't suggested or alerted (Views.isActionable).
    return { state = state, done = done, unknown = unknown, why = lockedReasons[1],
        pick = firstOpen or firstLocked or e.names[1], open = firstOpen ~= nil }
end
Views.entryState = entryState

-- Worth suggesting (DO THIS NOW, the Path queue) or alerting about: shown as
-- available AND at least one of its achievements is positively known to be
-- open. Unknown names alone never count.
function Views.isActionable(e, info)
    local st = entryState(e, info)
    return st.state == "available" and st.open
end

-- Every use this period is done: all of its circles green. A counter that
-- can't be read (grey) isn't known to be used up.
function Views.usedUp(u)
    if not (u and u.dots and #u.dots > 0) then return false end
    for _, d in ipairs(u.dots) do if d ~= "green" then return false end end
    return true
end

-- Worth doing now, as the Activities tab sees it (its STARTING SOON card,
-- Open now, Today, This week): suggestable (Views.isActionable: available
-- with an achievement positively open) and not known to be used up this
-- period. One rule, from the state and uses already worked out, or from the
-- entry.
--   readVar : function(name, id) -> number or nil (Detect.varValue)
local function actionableState(st, u) return st.state == "available" and st.open and not Views.usedUp(u) end
function Views.actionable(e, info, readVar)
    return actionableState(entryState(e, info), Views.uses(e, readVar))
end

-- Activities minigame classification: cape achievements in the Wiki's
-- "Minigames" subcategory
-- (data/achievements.lua, from the Trim and Comp breakdown pages: Big
-- Chinchompa, Kiln Fighter, Stay Safe, Stay Secure, Whodunnit? I Dunnit!,
-- Raptor's Revenge). D&Ds, Ports and Treasure Trails are their own
-- subcategories and stay out.
function Views.isMinigame(achData)
    return function(it)
        local d = achData and achData[it.name]
        return d ~= nil and d.sub == "Minigames"
    end
end

-- Cape achievements that can be worked on right now: unlocked (prereqs
-- met), not done, and not on the time-gated list. Most progress first.
--   timedNames : set of names on data/timegated.lua
function Views.doableNow(capeItems, timedNames, max)
    local list = {}
    for _, it in ipairs(capeItems or {}) do
        if (it.state == "todo" or it.state == "partial") and not timedNames[it.name] then
            list[#list + 1] = it
        end
    end
    table.sort(list, function(a, b)
        if (a.pct or 0) ~= (b.pct or 0) then return (a.pct or 0) > (b.pct or 0) end
        return a.name < b.name
    end)
    local out = {}
    for i = 1, math.min(max or 5, #list) do out[i] = list[i] end
    return out
end

-- Reuse the game's state/counters; never infer completed substeps from a
-- percentage or remember progress locally. Advice is passive optional text
-- so the Guide can budget it and Details/compact can show it in full.
-- Distinct tones separate actions, notes and progress: the first step (the
-- main thing to do) in "step"; later steps (tips and catches) in "note";
-- what's still missing in "warn"; the counter in "pct".
function Views.achievementActions(it, instructions)
    if not (it and instructions) then return {} end
    local state = it.state or it.status
    if state == "done" then return {} end
    local rows = {}
    local function add(text, tone) rows[#rows + 1] = { text, tone = tone or "note", optional = true } end
    local function steps(list)
        for k, action in ipairs(list) do add(action, k == 1 and "step" or "note") end
    end
    if state == "locked" then
        add("Meet the listed requirements first, then follow these achievement actions.", "warn")
        steps(instructions.prepare or {})
        return rows
    end
    if it.remaining and it.remaining[1] then add("Next unchecked: " .. it.remaining[1], "warn") end
    local tally = it.tally
    if tally and tally.need and tally.have and tally.need > 0 then
        if tally.have >= tally.need then
            add("The target counter is reached; check the achievement journal for remaining requirements.", "pct")
            return rows
        end
        add(Views.commas(tally.need - tally.have) .. " left on the game's counter.", "pct")
    end
    steps(instructions)
    return rows
end

-- The Details tab for one achievement: what to do, where, progress, and
-- what's left or still needed.
--   it      : cape-item-shaped table (Detect.capeItems / achievementInfo)
--   achData : data/achievements.lua entry for it, or nil
-- Names that more than one RS3 achievement uses. Guides are found by name,
-- so a link by one of these names could open the wrong achievement's guide.
-- RuneScape Wiki "Relight My Fire" (disambiguation): Lore/Post-Quest ID 2201
-- (the Dragon Forge, our guide) and Combat/War's Retreat ID 1745.
Views.SHARED_NAMES = { ["Relight My Fire"] = true }

-- Details for an achievement.
--   it       : cape-item-shaped table (state, prereqs, remaining, ...)
--   achData  : data/achievements.lua entry (section, desc)
--   targets  : data/achievementtargets.lua entry: the NPCs and objects to go
--              to, each { kind, name, page, where, options }; may be nil
--   instructions: optional numbered guidance from data/achievementguidance.lua
--   name     : the achievement's name, for one the game didn't return (it =
--              nil): its Details are then the static data under that name
--              with "Not read from the game yet" (a "?" member of a cape
--              section's list on Progress), no state made up. Without a
--              name or data either, a generic line.
--   skills   : optional, the skills snapshot main.lua builds for the
--              achievement's requirements ({ { skill, need, have }, ... },
--              Views.detailChips): the status chips under the title and the
--              player's uncapped level in gold on the NEEDS FIRST skill lines
function Views.details(it, achData, targets, instructions, name, skills)
    local rows = {}
    name = (it and it.name) or name
    if it == nil and name == nil and achData == nil then
        rows[1] = { "Details", tone = "head" }
        rows[2] = { "" }
        rows[3] = { "Nothing to show for that. Click an achievement on the Guide or Activities tab.", tone = "dim" }
        return rows
    end
    local d = achData or {}
    local state = it and (({ done = "Done", locked = "Locked", partial = "In progress", todo = "Not started" })[it.state] or "")
        or "Not read from the game yet"
    -- titleWiki: its right-click > Wiki stays (ui/panel.lua wikiMenu), the one
    -- row without a click that keeps it.
    rows[#rows + 1] = { name or "Details", wiki = name, tone = "head", titleWiki = true }
    -- Where it sits in the game's achievement list: "Exploration - Menaphos".
    -- (A counted loop: ipairs would stop at a missing section.)
    local path, parts = {}, { d.section, d.sub, d.subsub }
    for k = 1, 3 do
        local part = parts[k]
        if part and part ~= "" and part ~= "N/A" then path[#path + 1] = part end
    end
    local where = #path > 0 and table.concat(path, "  -  ") or nil
    -- The circle: green done, grey locked or not read (as the section list's "?"), red otherwise.
    rows[#rows + 1] = { state .. (where and ("  -  " .. where) or ""), tone = "dim",
        dots = { (it and it.state == "done") and "green" or ((it == nil or it.state == "locked") and "grey" or "red") } }
    -- Build the applicable status chips from unmet prerequisites (the game's
    -- own) and "Skills met" from the snapshot. None for one that's done or
    -- not read.
    if it and it.state ~= "done" and it.prereqs then
        local blockers = 0
        for _, list in ipairs({ it.prereqs.skills or {}, it.prereqs.quests or {}, it.prereqs.achievements or {} }) do
            for _, p in ipairs(list) do if not p.done then blockers = blockers + 1 end end
        end
        for _, chips in ipairs(Views.chipRows(Views.detailChips(blockers, 0, skills))) do
            rows[#rows + 1] = { "", chips = chips }
        end
    end

    rows[#rows + 1] = { "" }
    rows[#rows + 1] = { "WHAT TO DO", tone = "head" }
    -- The wiki's one-line description, a sentence per line. "(X/55)" is its
    -- progress-counter placeholder; drop it. Descriptive prose is passive;
    -- the achievement title above owns its Wiki action.
    local desc = (d.desc or "See its wiki page."):gsub("%s*%(X/[%d,]+%)", "")
    for sentence in desc:gmatch("[^%.]+%.?") do
        sentence = sentence:gsub("^%s+", "")
        if sentence ~= "" then rows[#rows + 1] = { sentence } end
    end

    -- Not read: the guide's steps as for an achievement with no state read
    -- (no counter, nothing unchecked), so nothing is said about progress.
    local actions = Views.achievementActions(it or {}, instructions)
    if #actions > 0 then
        rows[#rows + 1] = { "" }
        rows[#rows + 1] = { "NEXT ACTIONS", tone = "head" }
        for _, row in ipairs(actions) do rows[#rows + 1] = row end
    end

    -- Who or what to go to: "Talk to  Otto Godblessed", then where (text only;
    -- nothing is drawn in the world).
    if (it == nil or it.state ~= "done") and targets and #targets > 0 then
        rows[#rows + 1] = { "" }
        rows[#rows + 1] = { "WHERE TO GO", tone = "head" }
        for _, t in ipairs(targets) do
            local verb = (t.options and t.options[1]) or (t.kind == "npc" and "Talk to" or "Use")
            rows[#rows + 1] = { verb .. "  " .. t.name, wiki = t.page, tone = "good" }
            if t.where and t.where ~= "" then rows[#rows + 1] = { t.where, tone = "note", pad = { icon = true } } end
        end
    end

    -- Progress and what's left: only from a game read.
    if it == nil then return rows end
    if it.state ~= "done" and (it.tally or (it.pct and it.pct > 0)) then
        rows[#rows + 1] = { "" }
        rows[#rows + 1] = { "PROGRESS", tone = "head" }
        local pct = math.floor((it.pct or 0) * 100)
        if it.tally then
            rows[#rows + 1] = { string.format("%s / %s  (%d%%)", Views.commas(it.tally.have), Views.commas(it.tally.need), pct),
                tone = "good" }
        else
            rows[#rows + 1] = { string.format("%d%% done", pct), tone = "good" }
        end
    end

    if it.state == "locked" then
        rows[#rows + 1] = { "" }
        rows[#rows + 1] = { "NEEDS FIRST", tone = "head" }
        for _, sk in ipairs(it.prereqs.skills) do
            if not sk.done then
                -- Show the player's skill level on the right in the progress
                -- colour, from the snapshot; "?" when it can't be read.
                local row = { string.format("%s %d", sk.skill:sub(1, 1):upper() .. sk.skill:sub(2), sk.level),
                    tone = "warn", dots = { "red" } }
                local have = Views.skillHave(skills, sk.skill)
                if have ~= nil then row.right, row.rightTone, row.rightFar = have, "num", true end
                rows[#rows + 1] = row
            end
        end
        for _, q in ipairs(it.prereqs.quests) do
            if not q.done then rows[#rows + 1] = { q.name .. "  (quest)", tone = "warn", dots = { "red" } } end
        end
        for _, a in ipairs(it.prereqs.achievements) do
            -- Attach each achievement's own guide to its name: a name two
            -- achievements share opens no Details, since it could show the
            -- other one's guide.
            local select = not Views.SHARED_NAMES[a.name] and a.name or nil
            if not a.done then rows[#rows + 1] = { a.name, wiki = a.name, tone = "warn", dots = { "red" }, select = select } end
        end
    elseif it.state ~= "done" and it.remaining and #it.remaining > 0 then
        rows[#rows + 1] = { "" }
        rows[#rows + 1] = { string.format("STILL TO DO (%d)", #it.remaining), tone = "head" }
        for i, r in ipairs(it.remaining) do
            if i > 20 then
                rows[#rows + 1] = { string.format("... and %d more", #it.remaining - 20), tone = "dim" }
                break
            end
            rows[#rows + 1] = { r, dots = { "red" } }
        end
    end
    return rows
end

-- The Details tab for a route step (usually a quest), from its planner
-- result: requirements met or missing, items to bring (with how to get
-- each), advice for the account mode, what it unlocks, and the cape
-- achievements it opens up.
--   r       : planner result (Planner.evaluate)
--   mode    : account mode, for the advice text
--   methods : data/methods.lua, for a training method per missing level
--   sources : data/itemsources.lua, for where to get each missing item
--   start   : optional, { "Start: ...", wiki = NPC page, travel = { "Travel: ...", "or ...", ... } }
--             (data/queststarts.lua)
--   skills  : optional, the step's skills snapshot from main.lua
--             ({ { skill, need, have }, ... }, Views.detailChips): the
--             status chips under the title and the player's uncapped level in
--             gold on the skill lines. Without it the level is the planner's
--             read (m.have).
function Views.stepDetails(r, mode, methods, sources, start, skills)
    local rows = {}
    local step = r.step
    local isQuest = step.type == "quest"
    local state = ({ done = "Done", doable = "Ready", prepare = "Get the items first", locked = "Locked" })[r.status] or ""
    -- Show the route phase ("Phase N", dim) beside a route step's Details
    -- title; a cape item's phase is synthetic, so it shows none.
    local onRoute = step.type ~= "cape" and type(step.phase) == "number"
    rows[#rows + 1] = { Views.plainTitle(step), wiki = step.quest or step.title, tone = "head", titleWiki = true,
        right = onRoute and ("Phase " .. step.phase) or nil, rightTone = "dim" }
    rows[#rows + 1] = { (isQuest and "Quest  -  " or "") .. state, tone = "dim",
        dots = { r.status == "done" and "green" or (r.status == "doable" and "green" or (r.status == "locked" and "grey" or "red")) } }
    -- The status chips: every one that applies (not the Guide card's single
    -- chip, Views.statusChip), on a second row when they don't fit one.
    if r.status ~= "done" and r.status ~= "unknown" then
        for _, chips in ipairs(Views.chipRows(Views.detailChips(#(r.missing or {}), #(r.items or {}), skills))) do
            rows[#rows + 1] = { "", chips = chips }
        end
    end

    rows[#rows + 1] = { "" }
    rows[#rows + 1] = { "REQUIREMENTS", tone = "head" }
    if #r.missing == 0 then
        rows[#rows + 1] = { "All met", tone = "good", dots = { "green" } }
    end
    for _, m in ipairs(r.missing) do
        if m.kind == "skill" then
            local cap = m.skill:sub(1, 1):upper() .. m.skill:sub(2)
            local how = methods and methods.lookup(m.skill, m.have, mode)
            -- The player's level on the right in gold: the snapshot's read
            -- ("?" when the game gives none), else the planner's.
            local have = skills and Views.skillHave(skills, m.skill) or tostring(m.have)
            rows[#rows + 1] = { string.format("%s %d -> %d", cap, m.have, m.need) .. (how and ("  -  " .. how.name) or ""),
                wiki = how and how.wiki or (cap .. " training"), tone = "warn", dots = { "red" },
                right = have, rightTone = "num", rightFar = true }
        elseif m.kind == "quest" then
            rows[#rows + 1] = { m.name .. "  (quest)", wiki = m.name, tone = "warn", dots = { "red" } }
        elseif m.kind == "step" then
            rows[#rows + 1] = { Views.plainTitle(m), tone = "warn", dots = { "red" } }
        elseif m.kind == "combat" then
            rows[#rows + 1] = { string.format("Combat level %d -> %d", m.have, m.need), tone = "warn", dots = { "red" } }
        else
            rows[#rows + 1] = { m.text or m.name or "?", tone = "warn", dots = { "red" } }
        end
    end

    local reqItems = step.requires and step.requires.items or {}
    if #reqItems > 0 then
        local missingById = {}
        for _, it in ipairs(r.items) do missingById[it.name] = it end
        rows[#rows + 1] = { "" }
        rows[#rows + 1] = { "ITEMS TO BRING", tone = "head" }
        -- The same table as the Guide: icon, held / missing circle, name,
        -- amount; under a missing item how to get it, who sells it, where it
        -- spawns.
        local list = {}
        for _, it in ipairs(reqItems) do
            local miss = missingById[it.name]
            list[#list + 1] = { id = it.id, name = it.name, need = miss and miss.need or (it.count or 1),
                have = miss and miss.have or nil, held = miss == nil, how = it.how }
        end
        local function hint(it)
            local out = {}
            local how = Views.itemHint(it, mode, sources)
            if how then out[#out + 1] = how end
            local src = sources and it.id and sources[it.id]
            if src and src.sellers and #src.sellers > 0 then
                local names = {}
                for k, sl in ipairs(src.sellers) do
                    if k > 3 then break end
                    names[#names + 1] = sl.npc .. (sl.where and (" (" .. sl.where .. ")") or "")
                end
                out[#out + 1] = "Sold by: " .. table.concat(names, ", ")
            end
            if src and src.spawns and #src.spawns > 0 then
                local places = {}
                for k, sp in ipairs(src.spawns) do
                    if k > 3 then break end
                    places[#places + 1] = sp.where
                end
                out[#out + 1] = "Spawns: " .. table.concat(places, ", ")
            end
            return out
        end
        for _, row in ipairs(Views.itemTable(list, hint)) do rows[#rows + 1] = row end
    end

    -- Quest Details list requirements and items, not a walkthrough (Quest
    -- Helper or the Wiki supplies that), so a quest gets no TIPS. Other
    -- route steps keep theirs.
    local advice = (not isQuest) and step.methods and (step.methods[mode] or step.methods.ironman)
    if advice then
        rows[#rows + 1] = { "" }
        rows[#rows + 1] = { "TIPS", tone = "head" }
        rows[#rows + 1] = { advice }
    end

    if r.opens and #r.opens > 0 then
        rows[#rows + 1] = { "" }
        rows[#rows + 1] = { "OPENS UP AFTER", tone = "head" }
        for _, name in ipairs(r.opens) do
            rows[#rows + 1] = { name, wiki = name, tone = "good", select = name }
        end
    end

    if isQuest then
        rows[#rows + 1] = { "" }
        if start then rows[#rows + 1] = { start[1], wiki = start.wiki, tone = "note" } end
        for _, line in ipairs(start and start.travel or {}) do rows[#rows + 1] = { line, tone = "travel" } end
        rows[#rows + 1] = { "Walkthrough: Quest Helper", tone = "dim" }
    end
    return rows
end

-- Build Help (the Help button) as five concise sections, one short point per
-- line. A line that explains a word on the screen leads with it ("DO THIS
-- NOW: ..."): `term` marks that emphasised leading label, which ui/panel.lua
-- draws in gold (TONE.num) and the rest in the normal colour
-- (Views.splitTerm). Keep it true to what the plugin does, no promises.
-- The help stays under 46 character-wrapped rows (tests/run_tests.lua).
function Views.help()
    local rows = { { "HOW IT WORKS", tone = "head" } }
    local function section(title, lines)
        rows[#rows + 1] = { "" }
        rows[#rows + 1] = { title, tone = "head" }
        for _, l in ipairs(lines) do rows[#rows + 1] = type(l) == "table" and l or { l } end
    end
    -- A "Term: explanation" line; the term (with its colon) is drawn gold.
    local function term(t, rest) return { t .. " " .. rest, term = t } end
    rows[#rows + 1] = { "Road to Trim picks your next step to the Trimmed Completionist cape." }
    rows[#rows + 1] = { "Finished quests and achievements drop off by themselves." }
    section("THE GUIDE", {
        term("DO THIS NOW:", "your next step."),
        term("THEN:", "what comes after it."),
        "Click a name for its details.",
        "Right-click a name for its wiki page.",
        term("Skip until reset:", "hide a quest until 00:00 game time."),
        term("Done for now:", "hide an activity until it resets."),
        term("Skipped: N", "lists skipped quests; click one to bring it back."),
    })
    -- Show the item-state icons (data/icons.lua) and circles with their
    -- meanings, one label per row, followed by the worn-item limitation. In
    -- tests Views.ICONS may be empty: the rows then have no icon, the labels
    -- stay.
    local icons = Views.ICONS or {}
    section("WHAT THE ICONS MEAN", {
        { "Quest", icon = icons.quest },
        { "Achievement", icon = icons.achievement },
        { "Minigame", icon = icons.minigame },
        { "Time-gated: daily or weekly limit", icon = icons.timegated },
        { "Have it", dots = { "green" } },
        { "Missing: how to get it is under it", dots = { "red" } },
        { "Can't tell: open your bank once", dots = { "grey" } },
        "Worn items aren't counted.",
    })
    section("OTHER PAGES", {
        term("Compact:", "your step in a small card."),
        term("Expand:", "back to the full window."),
        term("Activities:", "resets and minigames, what's open now."),
        term("Progress:", "route, cape achievements, long-run goals."),
    })
    -- The session: main.lua's newSession (and a reload) clear the bank's
    -- memory and the skips; the labels are Settings' own (MODE_CHOICES).
    section("GOOD TO KNOW", {
        term("Ironman, Hardcore, Group or Main:", "pick yours in Settings."),
        term("Open your bank", "once a session so items can be checked."),
        "Bank and skips last this session; a reload clears them.",
        term("PrettyUI:", "needed for pop-ups; otherwise they go to the console."),
    })
    return rows
end

-- A row's leading term (row.term, the help's "DO THIS NOW:") and the rest
-- of its text, so the window can draw the term in its own colour; nil when
-- the row has none or its text doesn't start with it (a wrapped row whose
-- first line broke inside the term: then it is drawn as plain text). Only
-- the first line of a wrapped row keeps `term` (Views.wrapRows copies it
-- to the first line only), so later lines start at the row's start.
function Views.splitTerm(row)
    local t = row and not row.right and row.term
    if type(t) ~= "string" or t == "" then return nil end
    local text = row[1] or ""
    if text:sub(1, #t) ~= t then return nil end
    return t, (text:sub(#t + 1):gsub("^%s+", ""))
end

-- The list of skipped quests ("Skip until reset" on the Guide; the Guide's
-- "Skipped: N" and Settings open it in Details), soonest back first; click
-- one to bring it back now.
--   entries : { { id, title, untilMin }, ... }
--   now     : game minute (Detect.clockMinutes) or nil if it can't be read
function Views.postponed(entries, now)
    local rows = { { "SKIPPED", tone = "head" } }
    if #entries == 0 then
        rows[#rows + 1] = { "Nothing is skipped", tone = "dim" }
        return rows
    end
    table.sort(entries, function(a, b) return a.untilMin < b.untilMin end)
    for _, e in ipairs(entries) do
        local when = now and ("back in " .. Clock.format(math.max(0, e.untilMin - now)))
            or "back time unknown (the game clock can't be read)"
        rows[#rows + 1] = { e.title .. "  -  " .. when, tone = "good", select = "postpone:back:" .. e.id }
    end
    rows[#rows + 1] = { "Click one to bring it back now. Skips also end when you log out or the plugin reloads.", tone = "dim" }
    rows[#rows + 1] = { "" }
    rows[#rows + 1] = { "Bring all back", tone = "dim", select = "postpone:allback" }
    return rows
end

-- Details for Settings > Skipped and hidden > Dismissed "just opened up":
-- what "Dismiss these" hid this session (Followups.dismissedList), in the
-- same row styles as the skipped list above. A click on one brings it back
-- to JUST OPENED UP; one finished since is listed dim, without a click.
--   entries : { { name, after, done }, ... }
function Views.dismissedFollowups(entries)
    local rows = { { "DISMISSED \"JUST OPENED UP\"", tone = "head" } }
    if #entries == 0 then
        rows[#rows + 1] = { "Nothing is dismissed", tone = "dim" }
        return rows
    end
    for _, e in ipairs(entries) do
        local text = e.after and (e.name .. "  (after " .. e.after .. ")") or e.name
        if e.done then
            rows[#rows + 1] = { text .. "  -  done", tone = "dim" }
        else
            rows[#rows + 1] = { text, tone = "good", select = "followups:restore:" .. e.name }
        end
    end
    rows[#rows + 1] = { "Click one to bring it back to JUST OPENED UP. The list empties when you log out or the plugin reloads.", tone = "dim" }
    return rows
end

-- 2443685 -> "2,443,685".
function Views.commas(n)
    local s = tostring(math.floor(n or 0))
    local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
    return (out:gsub("^,", ""))
end
-- ---------------------------------------------------------------------------
-- The Guide's DO THIS NOW card and the progress lines above it, built from
-- results the caller supplies (planner results and the route). Pure:
-- ui/panel.lua draws what these return.

-- How wide text is, in pixels, for laying out chips, buttons and one-line
-- rows. In the game ui/panel.lua installs Views.measureText, the font's own
-- FontType:GetStringWidth (official docs, rs/game/config/fonttype.html), so
-- the layout here and the drawing there use the same numbers. Without it
-- (the tests, or a client where the call fails) a per-character estimate of
-- 8.5 px for the 15pt body font. That estimate is UNVERIFIED (taken from one
-- in-game screenshot on 5 November 2026) and may overestimate or
-- underestimate a given string. The tests check that a layout is consistent
-- with itself (nothing overlaps or leaves its row), not that the real font
-- fits.
Views.CHIP_CHAR_PX = 8.5
Views.measureText = nil
function Views.textWidth(text)
    text = tostring(text or "")
    local measure = Views.measureText
    if measure then
        local n = measure(text)
        if type(n) == "number" and n >= 0 then return n end
    end
    return #text * Views.CHIP_CHAR_PX
end
-- How wide a chip or a small button is drawn (ui/panel.lua uses the same
-- numbers): its label plus CHIP_PAD_PX of room, half each side, so the
-- label never touches the pill's edge; CHIP_GAP_PX between two pills. The
-- compact card keeps its own, older numbers (ui/panel.lua compactChipWidth).
-- Rows wrap their text before a status chip (Views.wrapRows).
Views.CHIP_PAD_PX, Views.CHIP_GAP_PX = 16, 6
function Views.chipWidth(text) return math.ceil(Views.textWidth(text)) + Views.CHIP_PAD_PX end
-- Room for chips on one row: the Guide's surface (324 px, the page less the
-- scroll thumb's gutter, ui/panel.lua CONTENT_W) less the row's start
-- (ROW_X, 14 px) and the right margin (EDGE_MARGIN, 8 px). A row's text box
-- runs to the surface's edge (ROW_PX); a right column (an amount, "after
-- this") is RIGHT_COL_PX wide ending at the margin; an icon and a circle
-- take ICON_PX and DOT_PX each, as ui/panel.lua places them.
Views.CHIP_ROW_PX = 324 - 14 - 8
Views.ROW_PX = 324 - 14
Views.RIGHT_COL_PX, Views.ICON_PX, Views.DOT_PX, Views.COL_GAP_PX = 90, 26, 18, 6
-- The other right columns ui/panel.lua draws (READY_WIDTH, BAR_RIGHT_W,
-- WIDE_RIGHT_W) and a numbered step's number (NUM_W).
Views.READY_COL_PX, Views.BAR_COL_PX, Views.WIDE_COL_PX, Views.NUM_PX = 50, 112, 130, 18
-- Room for the card's buttons on one row: inside the card's edge (CARD_X, 6
-- px in from each side of the surface), from the row's start to the same
-- 8 px before the card's right edge.
Views.CARD_ROW_PX = (324 - 6) - 14 - 8

-- The pixels a row's text may take on one line: from where ui/panel.lua
-- starts it (after its icon, or the room kept for one, and its circles on
-- the left) to where its right column, or its circles on the right, begin,
-- or to the surface's edge. ui/panel.lua sizes a one-line row's text box by
-- the same rule, so what is cut here is what fits there.
-- Where a row's text starts, in px from the row's start (ROW_X), as
-- ui/panel.lua drawRow places it: after its icon, or the room kept for one,
-- its circles on the left, a numbered step's number and the row's own inset.
function Views.textStart(row)
    local pad = row.pad or {}
    local hasIcon = row.icon ~= nil or pad.icon == true
    local leftDots = (row.dots and not row.dotsRight) and #row.dots or 0
    local nDots = math.max(leftDots, pad.dots or 0)
    local start = (hasIcon and Views.ICON_PX or 0) + (nDots > 0 and (nDots * Views.DOT_PX + 4) or 0)
    -- A numbered step's number (NUM_PX) and a row's own inset (row.inset,
    -- the Progress card's text beside its ring) move the text in too.
    if pad.num == true or (not row.right and Views.splitNum(row[1]) ~= nil) then start = start + Views.NUM_PX end
    if type(row.inset) == "number" then start = start + row.inset end
    return start
end

function Views.lineRoom(row)
    local start = Views.textStart(row)
    -- Reserve room for everything drawn at the row's right end before
    -- computing the text width: circles on the right, plus a status chip or
    -- a right column (an amount, "after this", a bar's count, a heading's
    -- reset, "Ready"). Reserving all of them is safe when several are there.
    local reserved = 0
    if row.dots and row.dotsRight and #row.dots > 0 then reserved = reserved + #row.dots * Views.DOT_PX + Views.COL_GAP_PX end
    if row.right and row.rightChip then
        reserved = reserved + Views.chipWidth(row.right) + Views.COL_GAP_PX
    elseif row.right then
        local col = (row.rightFar and Views.READY_COL_PX) or (row.bar and Views.BAR_COL_PX) or (row.rightWide and Views.WIDE_COL_PX)
            or Views.RIGHT_COL_PX
        reserved = reserved + col + Views.COL_GAP_PX
    end
    local stop = reserved > 0 and (Views.CHIP_ROW_PX - reserved) or Views.ROW_PX
    return math.max(0, stop - start)
end

-- Labelled bars (a row with text and a bar, such as the Guide's progress
-- line or a Progress cape section) start at one shared column per tab:
-- after the widest label in the full list (not only the rows in view, so
-- scrolling never moves them) plus BAR_GAP_PX, and never before
-- BAR_LABEL_PX. The bar ends where the count column begins (BAR_COL_PX and
-- COL_GAP_PX before the row's end). The bar keeps at least BAR_MIN_PX of
-- width; labels too wide for that are cut with "..." (Views.cutPx). Widths
-- come from Views.textWidth, which ui/panel.lua also uses. Unlabelled bars
-- (QUESTS, a long-run goal, the ring's fallback) keep their normal width.
Views.BAR_LABEL_PX, Views.BAR_GAP_PX, Views.BAR_MIN_PX = 96, 8, 40

-- Whether a row is a labelled bar row (text and a bar on one row).
function Views.isLabelledBar(row)
    return row ~= nil and row.bar ~= nil and (row[1] or "") ~= ""
end

-- The column (px from the row's start, ROW_X) the labelled bars of `rows`
-- start at, and the rows with any label too wide for it cut (copies: the
-- given rows are shared). The cut copy keeps every other field (select,
-- wiki, span), so a click, Details and the right-click Wiki still use the
-- whole name. Nil column when no row has a labelled bar.
function Views.barLayout(rows)
    local col, any = Views.BAR_LABEL_PX, false
    for _, row in ipairs(rows or {}) do
        if Views.isLabelledBar(row) then
            any = true
            col = math.max(col, Views.textStart(row) + math.ceil(Views.textWidth(row[1])) + Views.BAR_GAP_PX)
        end
    end
    if not any then return rows, nil end
    -- The furthest the bars may start and still be BAR_MIN_PX long.
    local maxCol = Views.CHIP_ROW_PX - Views.BAR_COL_PX - Views.COL_GAP_PX - Views.BAR_MIN_PX
    col = math.min(col, maxCol)
    local out = {}
    for i, row in ipairs(rows) do
        out[i] = row
        if Views.isLabelledBar(row) then
            local start = Views.textStart(row)
            if start + math.ceil(Views.textWidth(row[1])) + Views.BAR_GAP_PX > col then
                local cut = {}
                for k, v in pairs(row) do cut[k] = v end
                cut[1] = Views.cutPx(row[1], col - Views.BAR_GAP_PX - start)
                out[i] = cut
            end
        end
    end
    return out, col
end

-- Wrap at spaces by measured pixels (Views.textWidth): as many words on a
-- line as fit in `px`. A single word wider than the line stays whole on
-- its own (as Views.wrap keeps a long word). Paragraph breaks kept.
function Views.wrapPx(text, px)
    local lines = {}
    for paragraph in (tostring(text) .. "\n"):gmatch("([^\n]*)\n") do
        local line, made = "", 0   -- made: lines this paragraph produced
        for word in paragraph:gmatch("%S+") do
            if line ~= "" and Views.textWidth(line .. " " .. word) <= px then
                line = line .. " " .. word
            else
                if line ~= "" then lines[#lines + 1] = line; made = made + 1 end
                if Views.textWidth(word) > px then
                    -- Truncate a single overwide word with "..." on a line
                    -- of its own, so no drawn line is wider than its box.
                    lines[#lines + 1] = Views.cutPx(word, px)
                    made, line = made + 1, ""
                else
                    line = word
                end
            end
        end
        -- The paragraph's last line; an empty paragraph keeps its blank line.
        if line ~= "" or made == 0 then lines[#lines + 1] = line end
    end
    return lines
end

-- Text cut to `px` pixels (Views.textWidth) with "..." on the end; shorter
-- text comes back as it is. Whole words are kept where there's room for
-- one, else characters.
function Views.cutPx(text, px)
    text = tostring(text or "")
    if Views.textWidth(text) <= px then return text end
    local dots = "..."
    local keep = #text
    while keep > 0 and Views.textWidth(text:sub(1, keep):gsub("%s+$", "") .. dots) > px do keep = keep - 1 end
    if keep <= 0 then return dots end
    -- Back to the last whole word, when the cut lands inside one and a
    -- whole word is left.
    local head = text:sub(1, keep)
    if keep < #text and not text:sub(keep + 1, keep + 1):match("%s") then
        local atWord = head:match("^(.-)%s+%S+$")
        if atWord and atWord ~= "" then head = atWord end
    end
    return (head:gsub("%s+$", "")) .. dots
end

-- The status chip on the card's title row, or nil when there's nothing
-- certain to say.
--   r : the first entry's planner result (Planner.evaluate), or nil when
--       the first entry isn't a route step (a time-gated activity, a minigame)
-- Precedence:
--   unknown result, or no route step  -> no chip
--   any unmet requirement that isn't an item (skill, combat, quest, step,
--   achievement, other prerequisites: r.missing) -> "N steps first", N =
--   how many of those are unmet
--   else missing items (r.items)      -> "N missing", N = item kinds missing
--   else                              -> "Ready"
-- Returns { text, tone = "good"|"warn"|"dim" } (ui/panel.lua TONE).
function Views.statusChip(r)
    if r == nil or r.status == "unknown" or r.status == "done" then return nil end
    local hard = #(r.missing or {})
    if hard > 0 then return { string.format("%d step%s first", hard, hard == 1 and "" or "s"), tone = "dim" } end
    local items = #(r.items or {})
    if items > 0 then return { string.format("%d missing", items), tone = "warn" } end
    return { "Ready", tone = "good" }
end

-- Build all applicable Details status chips (not the card's single chip).
--   blockers : unmet requirements that aren't items (skills, combat, quests,
--              steps, achievements, other prerequisites): "N steps first" (dim)
--   items    : item kinds missing: "N items missing" (warn)
--   skills   : the step's skill requirements with the player's level,
--              { { skill, need, have = level or nil }, ... } (main.lua's
--              snapshot, from the game's own quest prerequisites, the route
--              data and the achievement's prerequisites): "Skills met" (good)
--              only when there's at least one, every one is met and every
--              level could be read; an unreadable level withholds it rather
--              than guessing
-- Returns { { text, tone }, ... }, possibly empty.
function Views.detailChips(blockers, items, skills)
    local chips = {}
    if (blockers or 0) > 0 then
        chips[#chips + 1] = { string.format("%d step%s first", blockers, blockers == 1 and "" or "s"), tone = "dim" }
    end
    if skills and #skills > 0 then
        local met = true
        for _, s in ipairs(skills) do
            if type(s.have) ~= "number" or type(s.need) ~= "number" or s.have < s.need then met = false end
        end
        if met then chips[#chips + 1] = { "Skills met", tone = "good" } end
    end
    if (items or 0) > 0 then
        chips[#chips + 1] = { string.format("%d item%s missing", items, items == 1 and "" or "s"), tone = "warn" }
    end
    return chips
end

-- The player's level for `skill` in a snapshot (Views.detailChips), as
-- text for the gold right-hand column: the number, "?" when it couldn't be
-- read, nil when the snapshot doesn't list the skill.
function Views.skillHave(skills, skill)
    for _, s in ipairs(skills or {}) do
        if s.skill == skill then return s.have ~= nil and tostring(s.have) or "?" end
    end
    return nil
end

-- The compact card's timer line: return the soonest eligible set-time
-- activity timer within CHIP_WINDOW, "<activity> in Nm" (the same rule as
-- DO THIS NOW's timer chips and STARTING SOON). Eligible means it can be done
-- now (Views.actionable: open to this account, not used up this period) and
-- is not hidden with "Done for now" or excluded; the activity's name breaks
-- a tie. Daily and weekly resets never count. Returns nil without the game
-- clock or an eligible timer.
--   o.entries  data/timegated.lua
--   o.info     function(name) -> cape-item-shaped table or nil
--   o.readVar  function(name, id) -> number or nil (the use counters)
--   o.now      game minutes, or nil
--   o.skipped  { [Path skip key] = until-minute } ("Done for now"), may be nil
--   o.exclude  a skip key not to count (the card's own activity, when a
--              time-gated entry is the step itself), may be nil
-- Returns a row ({ text, tone, icon }) or nil.
function Views.compactNext(o)
    if o.now then
        local best = nil
        for _, e in ipairs(o.entries or {}) do
            local key = e.activity or (e.names and e.names[1])
            local hidden = o.skipped and key and o.skipped[key] and o.skipped[key] > o.now
            if e.reset == "halfhour" and key ~= o.exclude and not hidden and Views.actionable(e, o.info, o.readVar) then
                local t = Clock.minutesUntil("halfhour", o.now)
                if t and t <= Views.CHIP_WINDOW and (best == nil or t < best.t or (t == best.t and key < best.key)) then
                    best = { e = e, t = t, key = key }
                end
            end
        end
        if best then
            return { (best.e.activity or best.key) .. " in " .. Clock.format(best.t), tone = "num", icon = Views.ICONS.timegated,
                oneLine = true }
        end
    end
    -- No eligible timer: no additional compact row.
    return nil
end

-- A step's title as the window writes it: a route quest's without the
-- "Complete " that data/steps.lua's quest() puts in front of the quest's
-- name, told by the step's type, never by the words of the title: the
-- achievements "Complete Trekky" and "Complete History of Droalak" keep
-- their names. Takes a step, or a planner requirement with `title` and
-- `stepType` (the step it names, kind "step").
function Views.plainTitle(s)
    local title = s.title or s.id or ""
    if (s.type or s.stepType) == "quest" then return (title:gsub("^Complete ", "")) end
    return title
end

-- A step's name as the card writes it: a quest without "Complete ", an
-- achievement by its own name (its title has a description after ":").
-- Also used by THEN names.
function Views.stepName(s)
    if s.achievement then return s.achievement end
    return Views.plainTitle(s)
end
local stepName = Views.stepName

-- What a route step's title says after its name, for the compact card's
-- instructions: "Easy As Pie: bake a pie with the Bake Pie
-- spell" with the name "Easy As Pie" gives "bake a pie with the Bake Pie
-- spell". Remove only the exact name prefix and the separator after it
-- (": " or " - "), so a name with its own colon or dash is
-- never split inside; nil when the title is just the name, or doesn't start
-- with it.
function Views.titleRemainder(title, name)
    if type(title) ~= "string" or type(name) ~= "string" or name == "" then return nil end
    if title:sub(1, #name) ~= name then return nil end
    local rest = title:sub(#name + 1)
    local after = rest:match("^:%s+(.-)%s*$") or rest:match("^%s+%-%s+(.-)%s*$")
    if after == nil or after == "" then return nil end
    return after
end

-- Two lines for a name, by measured pixels (Views.textWidth): as many words
-- on the first as fit in px1 (beside the status chip), the rest on the
-- second in px2 (the card's full width). Only overflow beyond the second
-- line is cut with "...". A first word wider than px1 isn't cut: line 1
-- stays empty (the icon and chip are still on it) and the whole name goes on
-- line 2, cut there only if it's wider than px2, so no characters are lost
-- when the name fits.
-- Returns { line1 } or { line1, line2 }.
function Views.wrapTwo(text, px1, px2)
    text = tostring(text or "")
    if Views.textWidth(text) <= px1 then return { text } end
    local words = {}
    for w in text:gmatch("%S+") do words[#words + 1] = w end
    local line, i = "", 1
    while i <= #words do
        local try = line == "" and words[i] or (line .. " " .. words[i])
        if Views.textWidth(try) > px1 then break end
        line, i = try, i + 1
    end
    if line == "" then return { "", Views.cutPx(text, px2) } end
    if i > #words then return { line } end
    local rest = table.concat(words, " ", i)
    return { line, Views.cutPx(rest, px2) }
end

-- Build compact instruction rows from the parts main.lua supplies, in its
-- order, without empty ones and without any that only repeat
-- the title, the name or an earlier part (compared as lower-case letters,
-- digits and spaces). Each part's text is kept as written.
--   parts : { { text, tone }, ... }
--   skip  : { "title", "name", ... } texts no part may repeat
-- Returns { { text, tone, instr = true }, ... }.
function Views.compactInstructions(parts, skip)
    local function plain(s) return (tostring(s or ""):lower():gsub("[^%w ]", ""):gsub("%s+", " "):gsub("^ ", ""):gsub(" $", "")) end
    local seen, out = {}, {}
    for _, s in ipairs(skip or {}) do seen[plain(s)] = true end
    for _, p in ipairs(parts or {}) do
        local text = p[1] and tostring(p[1]):gsub("^%s+", ""):gsub("%s+$", "") or ""
        local key = plain(text)
        if key ~= "" and not seen[key] then
            seen[key] = true
            out[#out + 1] = { text, tone = p.tone or "note", instr = true }
        end
    end
    return out
end

-- Is an unlock label already readable text? The route's labels are mostly
-- ids ("lumbridge-catacombs"); those aren't written out, so nothing is
-- invented from them.
local function readableLabel(u) return type(u) == "string" and not u:match("^[%l%d%-]+$") end

-- The card's one-line "why" under the title: what the step opens (its
-- `unlocks`: route steps by name, other labels only if already readable),
-- then what needs it next (the first later step in the route whose
-- requires.steps names it), e.g. "Opens Rune Memories." / "Needed for Lunar
-- Diplomacy." Nil when there's neither. Cut with "..." to `width`
-- characters (one row; default the note row's room, Views.ROW_CHARS less the
-- icon's indent).
--   step  : the route step (data/steps.lua entry)
--   steps : the route (data/steps.lua)
function Views.whyLine(step, steps, width)
    if not (step and steps) then return nil end
    width = width or (Views.ROW_CHARS - 4)
    local byId, index = {}, nil
    for i, s in ipairs(steps) do
        byId[s.id] = s
        if s.id == step.id then index = i end
    end
    local needed = nil
    for i = (index or #steps) + 1, #steps do
        for _, id in ipairs(steps[i].requires and steps[i].requires.steps or {}) do
            if id == step.id then needed = steps[i] break end
        end
        if needed then break end
    end
    local opens = {}
    for _, u in ipairs(step.unlocks or {}) do
        local s = byId[u]
        if s and s ~= needed then opens[#opens + 1] = stepName(s)
        elseif s == nil and readableLabel(u) then opens[#opens + 1] = u end
    end
    local parts = {}
    if #opens > 0 then parts[#parts + 1] = "Opens " .. table.concat(opens, ", ") .. "." end
    if needed then parts[#parts + 1] = "Needed for " .. stepName(needed) .. "." end
    if #parts == 0 then return nil end
    return Views.cut(table.concat(parts, " "), width)
end

-- The thin progress line at the top of the Guide: the phase the
-- player is in, out of the route's last phase, and how many of the route's
-- quests the game says are done.
--   steps   : the route (data/steps.lua); its highest `phase` is the count,
--             not a fixed 47
--   results : Planner.evaluate(...).results (step id -> result); a step the
--             game can't read ("unknown") counts as not done
--   current : the first entry's route step, or nil when the first entry
--             isn't a route step or nothing is left. A cape item (type
--             "cape") isn't on the route: its phase is made up, so it's
--             ignored.
-- Phase: the current step's; else the lowest phase with a quest not done;
-- all done: the last phase. Returns { phase, maxPhase, done, total, frac }
-- (frac = phase / maxPhase for the Guide's phase bar, not a quest completion
-- percentage).
function Views.routeProgress(steps, results, current)
    local maxPhase, done, total, lowest = 0, 0, 0, nil
    local onRoute = {}
    for _, s in ipairs(steps or {}) do
        onRoute[s.id] = true
        if (s.phase or 0) > maxPhase then maxPhase = s.phase end
        if s.type == "quest" then
            total = total + 1
            local r = results and results[s.id]
            if r and r.status == "done" then
                done = done + 1
            elseif s.phase and (lowest == nil or s.phase < lowest) then
                lowest = s.phase
            end
        end
    end
    local phase
    if current and current.type ~= "cape" and onRoute[current.id] and current.phase then
        phase = current.phase
    else
        phase = lowest or maxPhase
    end
    return { phase = phase, maxPhase = maxPhase, done = done, total = total,
             frac = maxPhase > 0 and math.max(0, math.min(1, phase / maxPhase)) or 0 }
end

-- Display set-time activities as starting soon within 15 minutes: the timer
-- chip turns gold and the activity joins Activities' STARTING SOON card. The
-- Guide queue uses the separate Path.START_WINDOW.
Views.CHIP_WINDOW = 15

-- A timer chip's colour: gold (TONE.num) when a set-time activity
-- (reset "halfhour") starts within CHIP_WINDOW minutes, dim otherwise
-- (the compact card's chip; the Guide's chips are all gold, timerChips'
-- soonOnly).
function Views.timerTone(e, minutes)
    if e and e.reset == "halfhour" and minutes and minutes <= Views.CHIP_WINDOW then return "num" end
    return "dim"
end

-- The timer chips under the progress line: one per time-gated activity
-- that's open to this account, soonest first, "<name> in <time>" (the
-- start for set-time ones, the reset for the rest; core/clock.lua). The
-- name is the entry's `short` name when it has one (data/timegated.lua,
-- such as "Port in 11h 15m" for "Player-owned port"), else its activity.
--   entries : data/timegated.lua
--   isOpen  : function(e) -> true when it may be suggested (Views.isActionable)
--   now     : game minutes (Detect.clockMinutes); nil = no clock: no chips,
--             so no countdown is made up
--   skipped : { [Path skip key] = until-minute } ("Done for now"), may be nil
--   max     : at most this many (default: all of them; Views.timerChipRows
--             places at most CHIP_MAX)
--   soonOnly: restrict timers to CHIP_WINDOW minutes (a start or a reset),
--             every one gold, as the Guide uses it. Without it (the
--             default), every countdown, in timerTone's colour.
-- Returns { { text, tone, short = text without " in " }, ... }.
function Views.timerChips(entries, isOpen, now, skipped, max, soonOnly)
    if now == nil then return {} end
    local list = {}
    for _, e in ipairs(entries or {}) do
        local key = e.activity or (e.names and e.names[1])
        local hidden = skipped and key and skipped[key] and skipped[key] > now
        if e.reset and not hidden and isOpen(e) then
            local t = Clock.minutesUntil(e.reset == "halfhour" and "halfhour" or (e.period or e.reset), now)
            if t and not (soonOnly and t > Views.CHIP_WINDOW) then list[#list + 1] = { e = e, t = t, key = key or "" } end
        end
    end
    table.sort(list, function(a, b)
        if a.t ~= b.t then return a.t < b.t end
        return a.key < b.key
    end)
    local out = {}
    for i = 1, math.min(#list, max or #list) do
        local x = list[i]
        local name = x.e.short or x.e.activity or x.key
        out[i] = { name .. " in " .. Clock.format(x.t), tone = soonOnly and "num" or Views.timerTone(x.e, x.t),
            short = name .. " " .. Clock.format(x.t) }
    end
    return out
end

-- How many timer chips the Guide shows at most, on at most CHIP_MAX_ROWS rows.
Views.CHIP_MAX, Views.CHIP_MAX_ROWS = 4, 2

-- Pack whole timer chips into the Guide's chip rows: the candidates in
-- their order (soonest first, so a gold chip is always
-- first); each goes on the first of the CHIP_MAX_ROWS rows where it fits
-- after the chips already there (Views.chipWidth, CHIP_GAP_PX between
-- them) in `px` (default CHIP_ROW_PX); one that fits on neither row, or is
-- wider than a whole row, is dropped, and a later shorter one may still
-- fill the space; at most CHIP_MAX are placed. Nothing is ever cut: a
-- chip's label is drawn whole or not at all.
-- Compare the long labels ("<name> in <time>") with the short ones
-- ("<name> <time>", chip.short) and use the form that fits more entries, for
-- all of them; the same choice is made for the same candidates every time.
--   chips : Views.timerChips' list
-- Returns { { chip, ... }, ... }: only the rows that hold a chip.
function Views.timerChipRows(chips, px)
    px = px or Views.CHIP_ROW_PX
    local function place(label)
        local rows, used, placed = {}, {}, 0
        for r = 1, Views.CHIP_MAX_ROWS do rows[r], used[r] = {}, 0 end
        for _, c in ipairs(chips or {}) do
            if placed >= Views.CHIP_MAX then break end
            local w = Views.chipWidth(label(c))
            for r = 1, Views.CHIP_MAX_ROWS do
                local need = used[r] + (#rows[r] > 0 and Views.CHIP_GAP_PX or 0) + w
                if need <= px then
                    local chip = {}
                    for k, v in pairs(c) do chip[k] = v end
                    chip[1] = label(c)
                    rows[r][#rows[r] + 1] = chip
                    used[r], placed = need, placed + 1
                    break
                end
            end
        end
        local out = {}
        for r = 1, Views.CHIP_MAX_ROWS do if #rows[r] > 0 then out[#out + 1] = rows[r] end end
        return out, placed
    end
    local long, nLong = place(function(c) return c[1] end)
    local short, nShort = place(function(c) return c.short or c[1] end)
    if nShort > nLong then return short end
    return long
end

-- Chips (or buttons) as rows: as many on a row as fit in `px` (default
-- Views.CHIP_ROW_PX), the rest on the next; nothing is dropped (the
-- Details views' status chips, the card's buttons: Views.CARD_ROW_PX).
-- Returns { { chip, ... }, ... }.
function Views.chipRows(chips, px)
    px = px or Views.CHIP_ROW_PX
    local rows, cur, used = {}, {}, 0
    for _, c in ipairs(chips or {}) do
        local w = Views.chipWidth(c[1])
        if #cur > 0 and used + Views.CHIP_GAP_PX + w > px then
            rows[#rows + 1] = cur
            cur, used = {}, 0
        end
        used = used + (#cur > 0 and Views.CHIP_GAP_PX or 0) + w
        cur[#cur + 1] = c
    end
    if #cur > 0 then rows[#rows + 1] = cur end
    return rows
end

-- Why "Skip until reset", or "Done for now", can't act without the game
-- clock (the note under it).
Views.NO_CLOCK_NOTE = "Can't skip: game time unavailable."
Views.NO_CLOCK_DONE_NOTE = "Can't hide: game time unavailable."

-- Offer one card action at most: skip a quest until the daily reset (00:00
-- game time), or hide a time-gated activity until its reset ("Done for
-- now"); nothing for anything else. Names open Details, and right-click >
-- Wiki on the name opens its page, so there are no buttons for those.
-- Without the game clock the applicable action stays visible but disabled,
-- with a `why` note under it.
--   o.stepId   : the route step's id, for the skip
--   o.quest    : true for a quest (only quests are skipped)
--   o.clock    : true when the game clock reads (both need it)
--   o.skipKey  : a time-gated entry's "Done for now" key (Path.skipKey); it
--                takes the skip's place
-- Returns { { label, select = ..., disabled = true, why = ... } } or {}.
function Views.cardButtons(o)
    local out = {}
    local off = (not o.clock) or nil
    if o.skipKey then
        out[#out + 1] = { "Done for now", select = "skip:" .. o.skipKey, disabled = off, why = off and Views.NO_CLOCK_DONE_NOTE or nil }
    elseif o.quest and o.stepId then
        out[#out + 1] = { "Skip until reset", select = "postpone:reset:" .. o.stepId, disabled = off,
            why = off and Views.NO_CLOCK_NOTE or nil }
    end
    return out
end

-- The card's button rows: the actions wrapped to CARD_ROW_PX
-- (Views.chipRows), each row a card row with no text of its own, then one
-- disabled-reason note row (tone "note") when an action can't act now.
--   o : Views.cardButtons' argument
-- Returns { rows..., }; no rows when no action applies.
function Views.buttonRows(o)
    local buttons = Views.cardButtons(o)
    local rows = {}
    for _, group in ipairs(Views.chipRows(buttons, Views.CARD_ROW_PX)) do
        rows[#rows + 1] = { "", buttons = group, card = true }
    end
    for _, b in ipairs(buttons) do
        if b.disabled and b.why then
            rows[#rows + 1] = { b.why, tone = "note", pad = { icon = true }, card = true }
            break
        end
    end
    return rows
end

-- What a THEN entry shows on the right: a time-gated entry's use circles
-- (green used, red left, grey unread), or a dim "after this" when it's a
-- route step that needs the current step first (its requires.steps). Only
-- entries the queue already has (core/path.lua isn't changed). Nil: nothing.
--   q       : a queue entry (Path.build)
--   firstId : the first entry's route step id, or nil
-- Returns { dots = {...} } or { text = "after this" } or nil.
function Views.thenRight(q, firstId)
    if q.kind == "timegated" then
        return (q.uses and q.uses.dots and #q.uses.dots > 0) and { dots = q.uses.dots } or nil
    end
    if q.kind == "route" and firstId then
        for _, id in ipairs(q.result.step.requires and q.result.step.requires.steps or {}) do
            if id == firstId then return { text = "after this" } end
        end
    end
    return nil
end

-- ---------------------------------------------------------------------------
-- The Activities tab: time-gated activities grouped by reset, soonest
-- first, then minigames, each row's use circles at its right end so they
-- line up. Long-run goals belong to Progress. Pure: main.lua supplies the
-- data and the game reads, ui/panel.lua draws what it returns.

-- The target in a wiki description's progress placeholder: "(X/3)" -> 3,
-- "(X/4,100,000)" -> 4100000 (digits, or groups of three with commas). Nil
-- without one, or when it isn't a whole number written that way ("(X/Y)",
-- "(X/1,00)", "(X/0)").
function Views.countOf(desc)
    local y = type(desc) == "string" and desc:match("%(X/([%d,]+)%)") or nil
    if not y then return nil end
    -- Every piece between commas, empty ones included, so ",100", "1,,0"
    -- and "100," don't pass.
    local groups = {}
    for g in (y .. ","):gmatch("([^,]*),") do groups[#groups + 1] = g end
    if #groups == 1 then
        if not y:match("^%d+$") then return nil end
    else
        if not groups[1]:match("^%d%d?%d?$") then return nil end
        for k = 2, #groups do if not groups[k]:match("^%d%d%d$") then return nil end end
    end
    local n = tonumber((y:gsub(",", "")))
    return (n and n > 0) and n or nil
end

-- How far along a long-run goal is, as a count, where the game gives one:
--   it.tally  { have, need }: the game's own counter, exact ("12 / 40")
--   else      the "(X/Y)" target from its wiki description (Views.countOf)
--             with a real progress read (it.hasProgress, core/detect.lua: not
--             the zero made up when the game gives none): the count worked
--             back from the percentage, so marked approximate ("~2 / 7")
-- Returns { have, need, frac = 0..1, approx, text } or nil (then no bar).
-- The approximate count is floor(pct * Y): never rounded up, so it can't
-- claim the target before 100%. The game's
-- progress is in whole ten-thousandths, so one of three reads as 0.3333 and
-- shows "~0 / 3": one short, which is what the "~" is for.
function Views.goalProgress(it, desc)
    if not it then return nil end
    local t = it.tally
    if t and type(t.need) == "number" and t.need > 0 and type(t.have) == "number" then
        local have = math.max(0, t.have)
        return { have = have, need = t.need, frac = math.max(0, math.min(1, have / t.need)), approx = false,
                 text = Views.commas(have) .. " / " .. Views.commas(t.need) }
    end
    local need = Views.countOf(desc)
    if need and it.hasProgress == true and type(it.pct) == "number" then
        local frac = math.max(0, math.min(1, it.pct))
        local have = math.min(need, math.floor(frac * need))
        return { have = have, need = need, frac = frac, approx = true,
                 text = "~" .. Views.commas(have) .. " / " .. Views.commas(need) }
    end
    return nil
end

-- Which section a time-gated entry's rhythm puts it in: set-time (halfhour)
-- and twice-daily ones count as daily (their `period`); no reset, "none".
local SECTION_OF = { daily = "daily", ["12h"] = "daily", halfhour = "daily", weekly = "weekly", monthly = "monthly" }
local function sectionOf(e) return SECTION_OF[e.period or e.reset] or "none" end

-- A section's reset for its heading: "resets Wed 00:00" (Clock.RESET_LABEL).
local function resetLabel(kind)
    local label = Clock.RESET_LABEL[kind]
    return label and ("resets " .. label) or nil
end

-- The line that counts what didn't fit on the page (whole entries only).
local function overflowText(n)
    return string.format("+%d more %s", n, n == 1 and "activity" or "activities")
end

-- The Activities tab's rows.
--   o.entries    data/timegated.lua
--   o.info       function(name) -> cape-item-shaped table (Detect.achievementInfo)
--                or nil if the game doesn't know the name
--   o.now        game time in minutes (Detect.clockMinutes); nil = no clock:
--                no countdowns and no STARTING SOON card, nothing made up
--   o.readVar    function(name, id) -> number or nil, for uses this period
--   o.filter     one of Views.FILTERS; this helper defaults to "All", while
--                main.lua passes the saved or default filter
--   o.capeItems  Detect.capeItems()
--   o.isMinigame function(item) -> true for a minigame achievement
--   o.timedNames set of the achievement names on o.entries: a minigame
--                that's time-gated (Big Chinchompa) is listed above only
--   o.max        rows the page holds after wrapping (ui/panel.lua); whole
--                entries only, a last line counts what didn't fit
-- Sections, in order, each only when it has something: STARTING SOON (a
-- card: set-time activities that can be done and start within CHIP_WINDOW
-- minutes), DAILY / 12 HOURS, WEEKLY (the reset in its heading), MONTHLY,
-- NO FIXED RESET, MINIGAMES. STARTING SOON entries are not repeated in their
-- reset groups.
-- Within a section the open entries come first, soonest reset first, then
-- the locked ones (dim, "locked" on the right, why under it), then the done
-- ones.
function Views.activities(o)
    local filter, now, info, readVar = o.filter or "All", o.now, o.info, o.readVar
    local timedNames = o.timedNames or {}
    local function capitalise(s) return s:sub(1, 1):upper() .. s:sub(2) end
    -- An entry's name as its row writes it: the activity and, for several
    -- achievements, how many are done ("Sinkholes   1/2").
    local function nameOf(e, st)
        local count = #e.names > 1 and string.format("   %d/%d", st.done, #e.names) or ""
        return e.activity .. count
    end

    -- The time-gated entries with their state, uses, section and countdown.
    local timed = {}
    for _, e in ipairs(o.entries or {}) do
        local st = entryState(e, info)
        local u = Views.uses(e, readVar)
        timed[#timed + 1] = { e = e, st = st, u = u, section = sectionOf(e), actionable = actionableState(st, u),
            left = (e.reset and now) and Clock.minutesUntil(e.reset, now) or nil }
    end
    local RANK = { available = 0, locked = 1, done = 2 }
    table.sort(timed, function(a, b)
        if RANK[a.st.state] ~= RANK[b.st.state] then return RANK[a.st.state] < RANK[b.st.state] end
        local la, lb = a.left or math.huge, b.left or math.huge
        if la ~= lb then return la < lb end
        return a.e.activity < b.e.activity
    end)
    -- Which entries the filter lists (STARTING SOON's are actionable by
    -- definition and show under every filter).
    local DUE = { ["Today"] = { daily = true }, ["This week"] = { daily = true, weekly = true } }
    local function listed(t)
        if filter == "All" then return true end
        if not t.actionable then return false end
        return filter == "Open now" or (DUE[filter] ~= nil and DUE[filter][t.section] == true)
    end
    local dueOnly = DUE[filter] ~= nil   -- Today / This week: what isn't due by a day stays out

    -- The rows of one time-gated entry: its name row, then a note under it.
    local function entryRows(t, card)
        local e, st, u = t.e, t.st, t.u
        local icon = Views.ICONS.timegated
        local rows = {}
        if card then
            -- STARTING SOON: the name with a gold "in 12m" chip, then its
            -- rhythm with the use circles on the right, all on the card.
            rows[1] = { nameOf(e, st), wiki = e.wiki, tone = "title", icon = icon, select = st.pick, card = true,
                right = "in " .. Clock.format(t.left), rightTone = "num", rightChip = true }
            local text = e.limit and capitalise(e.limit) or e.note or ""
            if text ~= "" or u then
                rows[2] = { text, tone = "note", pad = { icon = true }, card = true,
                    dots = u and u.dots or nil, dotsRight = u and true or nil }
            end
            return rows
        end
        if st.state == "locked" then
            rows[1] = { nameOf(e, st), wiki = e.wiki, tone = "dim", icon = icon, select = st.pick,
                right = "locked", rightTone = "dim", rightFar = true }
            if st.why then rows[2] = { "Needs " .. st.why, tone = "note", pad = { icon = true } } end
            return rows
        end
        if st.state == "done" then
            rows[1] = { e.activity, wiki = e.wiki, tone = "dim", icon = icon, select = st.pick,
                dots = { "green" }, dotsRight = true }
            return rows
        end
        rows[1] = { nameOf(e, st), wiki = e.wiki, tone = "good", icon = icon, select = st.pick,
            dots = u and u.dots or nil, dotsRight = u and true or nil }
        -- The wiki's note and the countdown ("resets in 6h 12m"; "next in
        -- 14m" for set-time ones); "?" while the use counter is unconfirmed.
        local parts = {}
        if e.note then parts[#parts + 1] = e.note end
        local when = timing(e, now)
        if when then parts[#parts + 1] = when end
        local text = table.concat(parts, "  -  ")
        if u and u.unconfirmed then text = text ~= "" and (text .. "  ?") or "?" end
        if text ~= "" then rows[#rows + 1] = { text, tone = "note", pad = { icon = true } } end
        if st.unknown > 0 then rows[#rows + 1] = { "Progress unavailable", tone = "warn", pad = { icon = true } } end
        return rows
    end

    -- The sections, each a list of groups (one entry's rows) laid out below.
    local sections = {}
    local function section(title, right)
        local s = { title = title, right = right, groups = {} }
        sections[#sections + 1] = s
        return s
    end
    local soon = section("STARTING SOON")
    local onCard = {}   -- the entries STARTING SOON shows (by entry): not listed again below
    if now then
        for _, t in ipairs(timed) do
            if t.e.reset == "halfhour" and t.actionable and t.left and t.left <= Views.CHIP_WINDOW then
                soon.groups[#soon.groups + 1] = entryRows(t, true)
                onCard[t.e] = true
            end
        end
    end
    for _, sec in ipairs({ { "daily", "DAILY / 12 HOURS" }, { "weekly", "WEEKLY", resetLabel("weekly") },
                            { "monthly", "MONTHLY", resetLabel("monthly") }, { "none", "NO FIXED RESET" } }) do
        local s = section(sec[2], sec[3])
        for _, t in ipairs(timed) do
            if t.section == sec[1] and listed(t) and not onCard[t.e] then s.groups[#s.groups + 1] = entryRows(t, false) end
        end
    end

    -- MINIGAMES: the cape achievements in the wiki's Minigames subcategory
    -- (Views.isMinigame) that aren't time-gated: open ones first, furthest
    -- along first, then locked, then done; Open now lists the open ones.
    local games = section("MINIGAMES")
    if not dueOnly then
        local list = {}
        for _, it in ipairs(o.capeItems or {}) do
            if o.isMinigame and o.isMinigame(it) and not timedNames[it.name]
                and (filter == "All" or it.state == "todo" or it.state == "partial") then
                list[#list + 1] = it
            end
        end
        local STATE_RANK = { locked = 1, done = 2 }
        table.sort(list, function(a, b)
            local ra, rb = STATE_RANK[a.state] or 0, STATE_RANK[b.state] or 0
            if ra ~= rb then return ra < rb end
            if (a.pct or 0) ~= (b.pct or 0) then return (a.pct or 0) > (b.pct or 0) end
            return a.name < b.name
        end)
        for _, it in ipairs(list) do
            local rows, icon = {}, Views.ICONS.minigame
            if it.state == "locked" then
                rows[1] = { it.name, wiki = it.name, tone = "dim", icon = icon, select = it.name,
                    right = "locked", rightTone = "dim", rightFar = true }
                local need = missingText(it)
                if need ~= "" then rows[2] = { "Needs " .. need, tone = "note", pad = { icon = true } } end
            elseif it.state == "done" then
                rows[1] = { it.name, wiki = it.name, tone = "dim", icon = icon, select = it.name,
                    dots = { "green" }, dotsRight = true }
            else
                local pct = (it.pct and it.pct > 0) and string.format("%d%%", math.floor(it.pct * 100)) or nil
                rows[1] = { it.name, wiki = it.name, tone = "good", icon = icon, select = it.name,
                    right = pct, rightTone = pct and "pct" or nil, rightFar = pct and true or nil }
                if it.remaining and it.remaining[1] then
                    rows[2] = { "Next: " .. it.remaining[1], tone = "note", pad = { icon = true } }
                end
            end
            games.groups[#games.groups + 1] = rows
        end
    end

    -- The page: a section's blank line and heading, then its entries, as
    -- many whole entries as fit in o.max rows after wrapping (one row kept
    -- for the line that counts the rest while any remain).
    local rows = {}
    local max = o.max or math.huge
    if now == nil then rows[1] = { "Game clock not readable", tone = "warn" } end
    local used = #rows
    local total, placed = 0, 0
    for _, s in ipairs(sections) do total = total + #s.groups end
    local cut = false
    for _, s in ipairs(sections) do
        for k, g in ipairs(s.groups) do
            local head = {}
            if k == 1 then
                head = { { "" }, { s.title, tone = "head", right = s.right, rightTone = s.right and "dim" or nil,
                    rightWide = s.right and true or nil } }
            end
            local need = #head + #Views.wrapRows(g)
            local remaining = total - placed
            if used + need > max - (remaining > 1 and 1 or 0) then cut = true break end
            for _, r in ipairs(head) do rows[#rows + 1] = r end
            for _, r in ipairs(g) do rows[#rows + 1] = r end
            used, placed = used + need, placed + 1
        end
        if cut then break end
    end
    if placed < total then rows[#rows + 1] = { overflowText(total - placed), tone = "dim" } end
    if total == 0 then rows[#rows + 1] = { "Nothing here", tone = "dim" } end
    return rows
end

-- ---------------------------------------------------------------------------
-- The Progress tab, built from account and checklist data the caller
-- supplies. Pure: ui/panel.lua draws the rows these return (the ring and
-- bars are renderer fields: `ring`, `bar`, listed at Views.signature).

-- The top card's count: cape requirements done over the checklist as the
-- game returned it. `items` is Detect.capeItems' union of the Trimmed
-- Completionist, Completionist and Master Quest Cape requirements (the
-- planner's Trimmed Completionist goal), long-run goals included; not the
-- suggestable subset main.lua keeps for the Guide. The summary covers only
-- the checklist the game returned: failed reads can make it incomplete (a
-- smaller total), and nothing returned gives known = false, shown as "?",
-- never as 100%.
-- Returns { done, total, known, frac, pct }; pct is a whole number, 100
-- only when everything is done (it is capped at 99 otherwise).
function Views.capeTotal(items)
    local done, total = 0, 0
    for _, it in ipairs(items or {}) do
        total = total + 1
        if it.state == "done" then done = done + 1 end
    end
    if total == 0 then return { done = 0, total = 0, known = false, frac = 0 } end
    local pct = math.floor(100 * done / total + 0.5)
    if done < total then pct = math.min(99, pct) end
    return { done = done, total = total, known = true, frac = done / total, pct = pct }
end

-- The Progress ROUTE label: the current phase out of the route's last
-- phase, with that phase's name from data/phases.lua.
--   steps, results, current : as Views.routeProgress (the current phase is
--                             its rule: the first entry's route step, else
--                             the lowest phase with a quest not done; every
--                             route quest done, the last phase)
--   names : data/phases.lua (phase -> name), or nil
-- Returns { text, phase, maxPhase, name, allDone, done, total, frac } where
-- text is "Phase N / M: <name>" ("Phase N / M" for a phase without a name;
-- "Route done: ..." when every route quest is done) and done / total / frac
-- are the route's quests (the QUESTS bar).
function Views.routePhase(steps, results, current, names)
    local prog = Views.routeProgress(steps, results, current)
    local allDone = prog.total > 0 and prog.done == prog.total
    local name = names and names[prog.phase] or nil
    local text = string.format("Phase %d / %d", prog.phase, prog.maxPhase) .. (name and (": " .. name) or "")
    if allDone then text = "Route done: " .. text end
    return { text = text, phase = prog.phase, maxPhase = prog.maxPhase, name = name, allDone = allDone,
             done = prog.done, total = prog.total, frac = prog.total > 0 and prog.done / prog.total or 0 }
end

-- CAPE ACHIEVEMENTS: the sections of data/achievements.lua, in display
-- order. Section denominators come from that static Wiki snapshot, not from
-- the subset the game returned, so a checklist read short still shows the
-- full denominators.
Views.SECTIONS = { "Lore", "Skills", "Exploration", "Activities", "Combat", "Completionist", "Area Tasks" }

-- One tally per section: { name, total, done, unknown, frac, left = { { name, item }, ... } }.
--   achData : data/achievements.lua
--   items   : Detect.capeItems (the game's checklist, with each item's state)
--   plain   : the name normalisation to join the two by (main.lua's
--             plainName: lower-case letters, digits and spaces), or nil
-- A member the game didn't return counts as not done (unknown), and stays
-- on the left list marked "?": it isn't silently done or dropped. The left
-- list is in name order.
function Views.sectionTallies(achData, items, plain)
    plain = plain or function(s) return s end
    local byName = {}
    for _, it in ipairs(items or {}) do if it.name then byName[plain(it.name)] = it end end
    local out, index = {}, {}
    for k, name in ipairs(Views.SECTIONS) do
        out[k] = { name = name, total = 0, done = 0, unknown = 0, left = {} }
        index[name] = out[k]
    end
    local names = {}
    for name in pairs(achData or {}) do names[#names + 1] = name end
    table.sort(names)
    for _, name in ipairs(names) do
        local sec = index[achData[name].section]
        if sec then
            sec.total = sec.total + 1
            local it = byName[plain(name)]
            if it and it.state == "done" then
                sec.done = sec.done + 1
            else
                if it == nil then sec.unknown = sec.unknown + 1 end
                sec.left[#sec.left + 1] = { name = name, item = it }
            end
        end
    end
    for _, sec in ipairs(out) do sec.frac = sec.total > 0 and sec.done / sec.total or 0 end
    return out
end

-- The Details list of what's left in a section (a click on its bar), in
-- pages of SECTION_PAGE members (a large section in one list would need
-- more rows than the tab's row pool should hold): a heading with the
-- count and "Page N of M" on its right, a "Previous page" link, one
-- clickable row per member not done with its state in the narrow right
-- column ("N%" in gold while in progress, "locked" dim, "?" dim for one
-- the game didn't return: not read), a "Next page" link. Each member row
-- opens that achievement's own Details, as elsewhere; the page links open
-- "section:<name>:<page>" (main.lua). A page out of range shows page 1.
Views.SECTION_PAGE = 60
function Views.sectionPages(sec) return math.max(1, math.ceil(#sec.left / Views.SECTION_PAGE)) end
function Views.sectionLeft(sec, page)
    local rows = {}
    local n, pages = #sec.left, Views.sectionPages(sec)
    page = (type(page) == "number" and page >= 1 and page <= pages) and math.floor(page) or 1
    rows[#rows + 1] = { string.format("%s: %d LEFT", sec.name:upper(), n), tone = "head",
        right = pages > 1 and string.format("Page %d of %d", page, pages) or nil, rightTone = "dim" }
    if n == 0 then
        rows[#rows + 1] = { "Everything in this section is done", tone = "good", dots = { "green" } }
        return rows
    end
    local function link(text, to) return { text, tone = "link", select = "section:" .. sec.name .. ":" .. to } end
    if page > 1 then rows[#rows + 1] = link("Previous page", page - 1) end
    local unread = false
    for k = (page - 1) * Views.SECTION_PAGE + 1, math.min(n, page * Views.SECTION_PAGE) do
        local m = sec.left[k]
        local it = m.item
        local row = { m.name, wiki = m.name, select = m.name, dots = { "red" }, rightFar = true }
        if it == nil then
            row.right, row.rightTone, row.dots = "?", "dim", { "grey" }
            unread = true
        elseif it.state == "locked" then
            row.right, row.rightTone, row.tone, row.dots = "locked", "dim", "dim", { "grey" }
        elseif it.state == "partial" and it.pct and it.pct > 0 then
            row.right, row.rightTone = string.format("%d%%", math.floor(it.pct * 100)), "num"
        end
        rows[#rows + 1] = row
    end
    if page < pages then rows[#rows + 1] = link("Next page", page + 1) end
    if unread then
        rows[#rows + 1] = { "? = progress unavailable; counted as unfinished.", tone = "note" }
    end
    return rows
end

-- Build a full lower-Guide list (the "+N more" under ALSO AVAILABLE, JUST
-- OPENED UP or CAN DO NOW) from the saved rows: its heading with how many
-- there are, a page at a time, "Previous page" / "Next page" links.
-- Each entry row is as the Guide made it, its name opening its Details; a
-- status chip becomes plain coloured text on the right here (the Guide's
-- chip pool is for the Guide's own rows), and a name wraps whole rather
-- than being cut. A page out of range shows page 1.
--   key   : "also" | "new" | "cando", for the page links ("guidelist:<key>:<page>")
--   title : the heading ("ALSO AVAILABLE")
--   rows  : one row per entry, in the Guide's order
-- Pages are sized by the rows the entries take once wrapped, not by a
-- count, preserving whole entries within the tab's budget: the page is
-- shown in Details on the
-- Guide, whose pool has Views.LIST_POOL_ROWS rows (ui/panel.lua
-- ROWS_PER_PAGE[1]), and the rows it can't show are lost past the end. So
-- each page keeps Views.LIST_RESERVED of them for main.lua's "Back to
-- Guide" and the blank under it, the heading, "Previous page", "Next page"
-- and the blank ui/panel.lua adds after the last row; the entries get the
-- rest, whole entries only. An entry is counted by the larger of the two
-- wrapping rules (characters, as Details is drawn, and measured pixels),
-- so it fits whichever the window uses.
Views.LIST_POOL_ROWS = 120
Views.LIST_RESERVED = 6
local function listEntry(r)
    local row = {}
    for f, v in pairs(r) do row[f] = v end
    row.rightChip, row.oneLine, row.rightFar = nil, nil, nil
    if row.right then row.rightWide = true end   -- room for "3 steps first" or "~1,234 / 5,000"
    return row
end
-- The pages: { { first, last }, ... } (entry indexes), at least one.
function Views.guideListPages(rows)
    local room = Views.LIST_POOL_ROWS - Views.LIST_RESERVED
    local pages, first, used = {}, 1, 0
    for k, r in ipairs(rows or {}) do
        local e = listEntry(r)
        local need = math.max(#Views.wrapRows({ e }), #Views.wrapRows({ e }, nil, nil, true))
        if used > 0 and used + need > room then
            pages[#pages + 1] = { first, k - 1 }
            first, used = k, 0
        end
        used = used + need
    end
    pages[#pages + 1] = { first, #(rows or {}) }
    return pages
end
function Views.guideList(key, title, rows, page)
    rows = rows or {}
    local n = #rows
    local bounds = Views.guideListPages(rows)
    local pages = #bounds
    page = (type(page) == "number" and page >= 1 and page <= pages) and math.floor(page) or 1
    local out = { { string.format("%s: %d", title or "LIST", n), tone = "head",
        right = pages > 1 and string.format("Page %d of %d", page, pages) or nil, rightTone = "dim" } }
    if n == 0 then
        out[#out + 1] = { "Nothing here any more.", tone = "dim" }
        return out
    end
    local function link(text, to) return { text, tone = "link", select = "guidelist:" .. key .. ":" .. to } end
    if page > 1 then out[#out + 1] = link("Previous page", page - 1) end
    for k = bounds[page][1], bounds[page][2] do out[#out + 1] = listEntry(rows[k]) end
    if page < pages then out[#out + 1] = link("Next page", page + 1) end
    return out
end

-- TIME-GATED: unfinished time-gated progress from lifetime achievement
-- tallies, for each entry of data/timegated.lua.
--   entries : data/timegated.lua
--   info    : function(name) -> cape-item-shaped table, or nil
--   descOf  : optional, function(name) -> the wiki's description (for an
--             approximate count, Views.goalProgress)
-- Each achievement of an entry that isn't done gets a row (one the game
-- didn't return, or with no count to read, counts as unfinished: "?"; no
-- lifetime count absent from the game reads is invented), and an entry
-- whose every achievement is done disappears; done ones are still in the
-- cape totals above (CAPE
-- ACHIEVEMENTS, Views.capeTotal), never listed here.
-- The count on the right is the achievement's own lifetime tally from the
-- game (Views.goalProgress: exact "12 / 40", or approximate "~2 / 7" from
-- a description's target and the game's percentage), never the entry's
-- `counter`, which counts this period's uses. Without a game count: "? /
-- 40" with the data's `need` (a one-achievement entry), else "?".
-- Under a count, "<activity>: about N weeks left at <rate>" only when the
-- count is exact and the data has perReset and rate: N = ceil((need - have)
-- / perReset) with the game's need, nothing when N is 0.
-- Returns rows (name rows with select and wiki, notes under them).
local PERIOD_WORD = { weekly = "week", monthly = "month", daily = "day" }
function Views.timeGatedProgress(entries, info, descOf)
    local rows = {}
    for _, e in ipairs(entries or {}) do
        local goals = {}
        for _, n in ipairs(e.names or {}) do
            local it = info and info(n) or nil
            local c = it and Views.goalProgress(it, descOf and descOf(n) or nil) or nil
            goals[#goals + 1] = { name = n, it = it, count = c }
        end
        local need = (#goals == 1 and type(e.need) == "number") and e.need or nil
        do
            for _, g in ipairs(goals) do
                if not (g.it and g.it.state == "done") then
                    local row = { g.name, wiki = e.wiki, select = g.name }
                    rows[#rows + 1] = row
                    local count = g.count
                    if count then
                        row.right, row.rightTone = count.text, "num"
                        local per = e.perReset
                        if not count.approx and type(per) == "number" and per > 0 and e.rate then
                            local left = math.ceil(math.max(0, count.need - count.have) / per)
                            local word = PERIOD_WORD[e.reset] or "reset"
                            if left > 0 then
                                rows[#rows + 1] = { string.format("%s: about %d %s%s left at %s", e.activity or g.name, left, word,
                                    left == 1 and "" or "s", e.rate), tone = "note" }
                            end
                        end
                    elseif need then
                        row.right, row.rightTone = "? / " .. Views.commas(need), "dim"
                    else
                        row.right, row.rightTone = "?", "dim"
                    end
                end
            end
        end
    end
    return rows
end

-- LONG-RUN GOALS on Progress: every long-run achievement (data/
-- longachievements.lua) that isn't done, the open ones first, furthest
-- along first, then the locked ones by name. One that's time-gated is under
-- TIME-GATED only (o.exclude). Each is a group of rows:
--   its name (opens its Details, whose Back returns to Progress), dim when
--   locked, with on the right "locked", the count where the game gives one
--   (Views.goalProgress: exact "12 / 40" or approximate "~2 / 7"; too long
--   for the column, the percentage there and the count under the bar), the
--   percentage, or "?" when nothing is read;
--   locked: what it still needs, under it;
--   a gold bar where there's a count.
-- No icons: Progress' rows are plain (ui/panel.lua PLAIN_PAGES).
--   o.capeItems Detect.capeItems (the whole checklist)
--   o.isLong    function(item) -> true for a long-run achievement
--   o.descOf    optional, function(name) -> the wiki's description
--   o.exclude   optional, set of names not to list (the time-gated ones)
-- Returns { { row, ... }, ... }: one group per goal (Views.progressRows
-- places as many whole groups as fit).
function Views.longGoals(o)
    local open, locked = {}, {}
    for _, it in ipairs(o.capeItems or {}) do
        if o.isLong and o.isLong(it) and it.state ~= "done" and not (o.exclude and o.exclude[it.name]) then
            if it.state == "locked" then locked[#locked + 1] = it else open[#open + 1] = it end
        end
    end
    table.sort(open, function(a, b)
        if (a.pct or 0) ~= (b.pct or 0) then return (a.pct or 0) > (b.pct or 0) end
        return a.name < b.name
    end)
    table.sort(locked, function(a, b) return a.name < b.name end)
    local groups = {}
    local function add(it)
        local desc = o.descOf and o.descOf(it.name) or nil
        local p = it.state ~= "locked" and Views.goalProgress(it, desc) or nil
        local right, rightTone, far, countRow = "?", "dim", true, nil
        if it.state == "locked" then
            right = "locked"
        elseif p and #p.text <= 12 then
            -- "1 / 3" fits the narrow column, "1,234 / 5,250" the wide one.
            right, rightTone, far = p.text, "pct", (#p.text <= 6) or nil
        elseif p or (it.pct and it.pct > 0) then
            right, rightTone = string.format("%d%%", math.floor((p and p.frac or it.pct) * 100)), "pct"
            if p then countRow = p.text end
        end
        local rows = { { it.name, wiki = it.name, tone = it.state == "locked" and "dim" or "good", select = it.name,
            right = right, rightTone = rightTone, rightFar = far } }
        if it.state == "locked" then
            local need = it.prereqs and missingText(it) or ""
            if need ~= "" then rows[#rows + 1] = { "Needs " .. need, tone = "note" } end
        end
        if p then rows[#rows + 1] = { "", bar = { frac = p.frac, tone = "num" } } end
        if countRow then rows[#rows + 1] = { countRow, tone = "pct" } end
        groups[#groups + 1] = rows
    end
    for _, it in ipairs(open) do add(it) end
    for _, it in ipairs(locked) do add(it) end
    return groups
end

-- The ring's place on the card: ui/panel.lua draws a 64 px ring at the
-- card's left; the card's text rows start after it (row.inset, px).
Views.RING_INSET = 78

-- The Progress tab's rows.
--   o.cape     Views.capeTotal
--   o.mode     the account mode's label, as Settings shows it ("Ironman")
--   o.route    Views.routePhase
--   o.sections Views.sectionTallies
--   o.timed    Views.timeGatedProgress rows
--   o.long     Views.longGoals groups
--   o.max      rows the tab holds after wrapping (ui/panel.lua
--              ROWS_PER_PAGE); the long-run goals take what's left, whole
--              goals only, and a last line counts the ones that don't fit
--   o.ring     true when the window can draw the ring (ui/panel.lua
--              Panel.canRing); else the card shows a gold bar and the
--              percentage in the right column instead
function Views.progressRows(o)
    local rows = {}
    local cape, route = o.cape or Views.capeTotal({}), o.route
    -- The Progress summary card: checklist totals, then the account label.
    local pctText = cape.known and (cape.pct .. "%") or "?"
    local countText = cape.known and string.format("%d of %d requirements done", cape.done, cape.total)
        or "requirements not read yet"
    local modeText = o.mode or "?"
    if o.ring then
        rows[#rows + 1] = { "Trimmed Completionist", tone = "title", card = true, inset = Views.RING_INSET,
            ring = { frac = cape.frac, text = pctText } }
        rows[#rows + 1] = { countText, tone = "note", card = true, inset = Views.RING_INSET }
        rows[#rows + 1] = { modeText, tone = "dim", card = true, inset = Views.RING_INSET }
    else
        rows[#rows + 1] = { "Trimmed Completionist", tone = "title", card = true, right = pctText, rightTone = "num", rightFar = true }
        rows[#rows + 1] = { countText, tone = "note", card = true }
        rows[#rows + 1] = { "", card = true, bar = { frac = cape.frac, tone = "num" } }
        rows[#rows + 1] = { modeText, tone = "dim", card = true }
    end
    -- ROUTE: "Phase N / M: <name>", one logical line (it wraps whole).
    if route then
        rows[#rows + 1] = { "" }
        rows[#rows + 1] = { "ROUTE", tone = "head" }
        rows[#rows + 1] = { route.text, tone = route.allDone and "good" or "default" }
        -- QUESTS: done / on the route, with a bar.
        rows[#rows + 1] = { "" }
        rows[#rows + 1] = { "QUESTS", tone = "head" }
        rows[#rows + 1] = { "Quests on the route", right = string.format("%d / %d", route.done, route.total), rightTone = "num" }
        rows[#rows + 1] = { "", bar = { frac = route.frac } }
    end
    -- CAPE ACHIEVEMENTS: a bar per section; a click lists what's left.
    if o.sections then
        local total = 0
        for _, sec in ipairs(o.sections) do total = total + sec.total end
        rows[#rows + 1] = { "" }
        rows[#rows + 1] = { "CAPE ACHIEVEMENTS", tone = "head", right = tostring(total), rightTone = "dim" }
        for _, sec in ipairs(o.sections) do
            rows[#rows + 1] = { sec.name, bar = { frac = sec.frac }, right = string.format("%d / %d", sec.done, sec.total),
                rightTone = "num", select = "section:" .. sec.name }
        end
        rows[#rows + 1] = { "Click a section to list what's left in it.", tone = "note" }
    end
    -- TIME-GATED: the counters.
    if o.timed and #o.timed > 0 then
        rows[#rows + 1] = { "" }
        rows[#rows + 1] = { "TIME-GATED", tone = "head", right = "can't be rushed", rightTone = "dim", rightWide = true }
        for _, r in ipairs(o.timed) do rows[#rows + 1] = r end
    end
    -- LONG-RUN GOALS: as many whole goals as the tab still holds, the last
    -- row kept for "+N more long-run goals" while any are left out.
    local long = o.long or {}
    if #long > 0 then
        local max = o.max or math.huge
        local used = #Views.wrapRows(rows) + 2   -- with the blank and the heading below
        rows[#rows + 1] = { "" }
        rows[#rows + 1] = { "LONG-RUN GOALS", tone = "head", right = tostring(#long), rightTone = "dim" }
        local placed = 0
        for k, g in ipairs(long) do
            local need = #Views.wrapRows(g)
            if used + need > max - (k < #long and 1 or 0) then break end
            for _, r in ipairs(g) do rows[#rows + 1] = r end
            used, placed = used + need, placed + 1
        end
        if placed < #long then
            local left = #long - placed
            rows[#rows + 1] = { string.format("+%d more long-run goal%s", left, left == 1 and "" or "s"), tone = "dim" }
        end
    end
    return rows
end

return Views
