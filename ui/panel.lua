-- ui/panel.lua
-- Renders the full window and the compact entry card. The full window has
-- a draggable title bar, Compact / Help buttons and four tabs:
--
--   Guide       the current step, what it's missing, what else is doable
--   Activities  time-gated activities by reset, minigames
--   Progress    the cape summary, route phase, quests, a bar per cape
--               section, time-gated counts, long-run goals
--   Settings    account mode (segmented buttons), a switch per alert, what
--               was skipped or hidden
--
-- Game API used here: ui components (Layer, Rectangle, Text, Button) and
-- ui hooks, id.Font / id.Sprite icons, config.Font text measurement, plugin
-- resources and the plugin layer's geometry. Wiki targets attach through
-- opConfig.opWikiText (the client opens the page). Alert text is passed
-- locally to the optional PrettyUI plugin.
-- main.lua owns persistence and normal character reads; this module only
-- draws the rows it is given and reports user actions back. If the full
-- window can't be built, ui/panel_basic.lua takes its place.
--
-- No GroupBox: in the game its contents were drawn 32 px lower than placed,
-- under a header never set (seen in screenshots, 2026-10-22).
-- A row is { text, wiki = page or nil, tone = "head"|"good"|"warn"|"dim"|nil }.

local Basic = require("ui/panel_basic")
local Views = require("core/views")   -- Views.wrap / wrapRows for long lines

local Panel = {}

-- Fixed full-window size, matching the compact card's width.
local WIDTH, HEIGHT = 340, 500
local ROW_HEIGHT = 22
local ROW_X = 14              -- rows start 14 px into a tab
-- Frame order, top to bottom: the draggable title bar (title and buttons),
-- the tabs, then the tab's content page, 4 px in from the sides.
local PAD = 10
local BAR_H = 34                                  -- the title bar, the window's full width
local TITLE_Y, BUTTON_GAP = (BAR_H - ROW_HEIGHT) // 2, 4
local TABS_Y, TAB_H = BAR_H + 6, 24
local PAGE_X, PAGE_Y = 4, BAR_H + 6 + TAB_H + 6
local PAGE_W, PAGE_H = WIDTH - 2 * PAGE_X, HEIGHT - (BAR_H + 6 + TAB_H + 6) - 6
-- Shared tab indexes: Guide 1, Activities 2, Progress 3, Settings 4 (main.lua
-- addresses tabs by these). Details replace the list on the tab they were
-- opened from.
local TAB_NAMES = { "Guide", "Activities", "Progress", "Settings" }
local SETTINGS_PAGE = 4
local GUIDE_PAGE = 1          -- the Guide: the card's shapes (drawShapes)
local ACTIVITIES_PAGE = 2     -- Activities: the STARTING SOON card and its chips (drawShapes)
local PROGRESS_PAGE = 3       -- Progress: the cape ring and the bars (drawShapes)
-- Preallocated row capacity per tab, for lists, Help and Details. The
-- Guide also shows Details and Help in place, so it has more rows than its
-- list needs. Progress shows a cape section a page at a time (core/views.lua
-- SECTION_PAGE) and achievement Details; its rows are plain (PLAIN_PAGES, no
-- stripes) to reduce the component count. Keep these capacities consistent
-- with the view budgets and the offline checks in tests/run_tests.lua.
local ROWS_PER_PAGE = { 120, 110, 88, 50 }
-- Tabs whose rows show one circle and no icon (addDots): Settings' and
-- Progress' rows never need an icon, which keeps the window's component
-- count down.
local PLAIN_PAGES = { [SETTINGS_PAGE] = true, [PROGRESS_PAGE] = true }

-- Text colours (RGBA).
local TONE = {
    -- Default body text, in the compact card's colours.
    default = 0xE6E6E6FF,
    -- Section and table headings (ACCOUNT, DO THIS NOW, ...): a light steel
    -- blue, distinct from body text, links and notes. No bold font: see
    -- BODY_FONT.
    head = 0xD6EAF8FF,
    title = 0xFFFFFFFF,
    good = 0xB8E0A0FF,
    warn = 0xE8A07AFF,
    dim = 0xA89C84FF,
    -- Non-clickable subordinate info that belongs to the line above it (how
    -- to get an item, when an activity starts, where an NPC is).
    note = 0x9DB4C0FF,
    -- Clickable text that opens another view ("Full details").
    link = 0x8FC9F0FF,
    -- Static travel reference to a quest start ("Travel: ...").
    travel = 0xC9B6E4FF,
    -- Progress counts and percentages ("40%").
    pct = 0xF0C75EFF,
    -- The first guide action, the main thing to do; stands out from the
    -- tips under it (in "note").
    step = 0xF2DDB0FF,
    -- An instruction's number ("1."), drawn separately in gold.
    num = 0xF0C75EFF,
}
-- One font for everything: rows set to a title font (CINZEL_13PT_BOLD)
-- didn't show on the dev world, so headings are the body font in the
-- heading colour (TONE.head). Checked again 4 November 2026: the official
-- docs name only MUSEO_SANS_15PT_REGULAR (rs/game/config/fonttype.html,
-- rs/ui/decorative_components/text.html, rs/ui/common_types.html) and list
-- no bold font, so none is used rather than a guessed name.
local BODY_FONT = id.Font.MUSEO_SANS_15PT_REGULAR
-- Install FontType:GetStringWidth(text, ignoreTags) for the body font
-- (config.Font; official docs, rs/game/config/fonttype.html) as
-- Views.measureText, so layout (core/views.lua) and drawing here use the
-- same widths. If the call is missing or fails, Views uses its UNVERIFIED
-- per-character estimate (core/views.lua CHIP_CHAR_PX). The path taken is
-- logged at startup, and the first runtime failure is logged once.
do
    local okFont, err = pcall(function()
        local font = config.Font.MUSEO_SANS_15PT_REGULAR
        local probe = font:GetStringWidth("Wiki", true)
        if type(probe) ~= "number" or probe <= 0 then error("GetStringWidth gave " .. tostring(probe)) end
        local warned = false
        Views.measureText = function(text)
            local ok, w = pcall(font.GetStringWidth, font, text, true)
            if ok and type(w) == "number" and w >= 0 then return w end
            if not warned then
                warned = true
                print("[Road to Trim] text width: GetStringWidth failed, estimated from here on: " .. tostring(w))
            end
            return nil
        end
    end)
    if okFont then
        print("[Road to Trim] text width: measured (FontType:GetStringWidth)")
    else
        print("[Road to Trim] text width: estimated (" .. Views.CHIP_CHAR_PX .. " px a character, unverified): " .. tostring(err))
    end
end

local window = nil            -- { root = ui.Layer } while the full planner is open
local pages = {}              -- tab index -> { content = ui.Layer }
local strips = {}             -- "tabs" / page index -> a row of tabs (makeStrip): the tabs, a tab's filters
local shownRows = {}          -- page -> the rows last shown, for click handling
local pageBands = {}          -- page -> row -> table stripe (ui.Rectangle)
local hoverBars = {}          -- page -> highlight bar shown under the hovered row
local HOVER_BAR = 0x8FC9F033  -- faint light blue (the compact card's link colour), under the row
-- Table rows (row.band = 1 or 2): alternating stripes behind the row, so a
-- list of items reads as a table. row.right is a second column on the right
-- (an amount), in row.rightTone.
-- In the compact card's blue family, a step lighter than its 0x0A1F29.
local BAND = { [1] = 0x10293AFF, [2] = 0x163448FF, head = 0x1F4459FF }
local SCROLL_THUMB = 0x8FC9F066   -- the thin bar showing where a tab is scrolled to (the link blue, faint)
-- Reserve a separate scroll gutter so the thumb avoids section edges. A
-- tab's surface, and so its sections, stripes, hover bar and rows, is
-- SCROLL_GUTTER narrower than the page: the boxes end at
-- CONTENT_W - SECTION_INSET (322), the 4 px thumb sits at PAGE_W - 6 (326 to
-- 330), a 4 px gap between. The window's own size doesn't change.
local SCROLL_GUTTER, THUMB_W, THUMB_RIGHT = 8, 4, 2
local CONTENT_W = PAGE_W - SCROLL_GUTTER
-- Sections: each heading row (tone "head", not a table's own header) starts
-- a section that ends at the next one. Each is the compact card's dark
-- fill, with its 1 px edge drawn over the table stripes. The fill and edge
-- pools are fixed per tab and reused during redraws.
local SECTION_FILL, SECTION_EDGE = 0x0A1F29E6, 0x46545CFF
local SECTION_INSET = 2       -- from the tab's sides
local SECTION_GAP = 4         -- between one section and the next
local MAX_SECTIONS = 12
-- Progress needs fewer: its tab has four sections, a section's page one,
-- an achievement's Details at most six (core/views.lua Views.details).
local MAX_SECTIONS_ON = { [3] = 8 }   -- [PROGRESS_PAGE], declared below
local sectionBlocks = {}      -- page -> k -> { tint = ui.Rectangle, bar = ui.Rectangle }
-- The right edge of what a tab shows, in page content coordinates: the
-- page's width. A row's right-hand column (an item's amount, a step's
-- "Ready", row.right) ends EDGE_MARGIN before it, AMOUNT_WIDTH wide (room
-- for "1234 / 5250"). One column, as the compact card.
local DEFAULT_CONTENT_WIDTH, EDGE_MARGIN, AMOUNT_WIDTH = PAGE_W, 8, 90
local READY_WIDTH = 50        -- a step's "Ready" (row.rightFar), as on the compact card
local HOVER_TEXT = 0xFFFFFFFF -- the hovered row's text goes white

-- A row is clickable when it opens something (`select`): an entry's name
-- (a quest, achievement, activity or minigame, which opens its Details) or a
-- control line ("Back to Guide", "+N more items", "Skipped: N",
-- "Dismiss these", a Settings link). Clickable rows handle hover and
-- selection. Plain rows (a note, a Start or travel line, a missing level, an
-- item, a Details heading) stay non-interactive: no click, no hover and no
-- right-click Wiki, even with a wiki page.
local function clickable(row) return row ~= nil and row.select ~= nil end
-- The one exception: a Details view's title (row.titleWiki, the entry's own
-- name at the top) keeps its right-click > Wiki entry, so the entry's wiki
-- page is still there from its Details; it takes no left click and shows no
-- hover.
local function wikiMenu(row) return clickable(row) or (row ~= nil and row.titleWiki == true and row.wiki ~= nil) end
-- A row's text colour: its own (row.rgba, a Settings legend line), else its tone's.
local function rowColour(row) return row and row.rgba or TONE[row and row.tone or "default"] or TONE.default end
local onSelect = nil          -- called with a row's `select` value when it's clicked
local pageRows = {}           -- page index -> { ui.Text, ... }
local usingBasic = false
local lastX, lastY = nil, nil
local onMoved = nil

-- Circles at the start of a row (row.dots = { "green"|"red"|"grey", ... }):
-- uses this period in Activities' time-gated section, done/locked in its
-- minigames section.
-- Drawn as sprites from the plugin's own resources/dot_*.png; if those can't
-- load, as small filled ui.Rectangle squares in the same colours instead.
-- The row's text moves right by the width of its dots.
local MAX_DOTS = 3
local DOT, DOT_GAP = 14, 4
local DOT_RGBA = { green = 0x6FCF6FFF, red = 0xD9534FFF, grey = 0x77736AFF }
local dotImages = nil         -- colour -> plugin resource, or false if unavailable
local overlays = {}           -- page index -> row index -> { dots = {...}, x, y, line }
-- Scrolling on the content tabs, clamped to the content. Official API only:
-- each tab's rows sit on a Layer (surface)
-- inside another (view); the mouse wheel (ui.Hook.ONSCROLLWHEEL) moves the
-- surface, no further than the last row. Nothing cuts off what's outside
-- the view, so only the rows wholly inside it are drawn (applyScroll).
local scrollers = {}          -- page index -> { view, surface, thumb, offset, viewH, rows }
local FILTER_ROW_HEIGHT = 34  -- the filter buttons above Activities' rows
local WHEEL_STEP = 1          -- rows per wheel notch
-- Room left below the last row when scrolled to the end: the blank row
-- Panel.showPage puts after every page's last row (spaced) provides it.
local END_ROOM = 0
local wheelLogged = false

local function loadDotImages()
    if dotImages ~= nil then return dotImages end
    local ok = pcall(function()
        local res = Plugin.resources
        local imgs = {}
        for _, colour in ipairs({ "green", "red", "grey" }) do
            local r = res["dot_" .. colour] or res["dot_" .. colour .. ".png"]
            if r == nil then error("missing dot_" .. colour) end
            if not r.loaded then r:Load() end
            imgs[colour] = r
        end
        dotImages = imgs
    end)
    if not ok then dotImages = false end
    return dotImages
end

local function dotComponent(parent, x, y)
    local imgs = loadDotImages()
    local c
    if imgs then
        c = ui.Sprite.new(parent)
    else
        c = ui.Rectangle.new(parent)
        c.fill = true
    end
    c:SetPos(x, y)
    c:SetSize(DOT, DOT)
    c.clickthrough = true
    c.hidden = true
    return c
end

-- Row icons (row.icon = { sprite = id } or { item = objectID }): a game
-- sprite by ID (ui.Sprite.spriteID), or an item's own inventory icon via a
-- button showing its associated object (ui.Button:SetAssociatedObject with
-- showAssociatedObjectSprite, per the Button docs). Drawn before any dots.
local ICON = 20
local NUM_W = 18      -- room for a step's number ("2.") before its text

local function itemIcon(parent, x, y, size)
    local b = ui.Button.new(parent)
    b:SetPos(x, y)
    b:SetSize(size, size)
    b.showAssociatedObjectText = false
    b.showAssociatedObjectSprite = true
    b.clickthrough = true
    b.hidden = true
    return b
end

local function spriteIcon(parent, x, y, size)
    local c = ui.Sprite.new(parent)
    c:SetPos(x, y)
    c:SetSize(size, size)
    c.clickthrough = true
    c.hidden = true
    return c
end

-- An icon given by sprite name ({ spriteName = "..." }) resolves through
-- id.Sprite; a name the game doesn't have resolves to nothing (no icon).
local function spriteIdOf(icon)
    if icon == nil then return nil end
    if icon.sprite then return icon.sprite end
    if icon.spriteName then
        local ok, v = pcall(function() return id.Sprite[icon.spriteName] end)
        if ok and type(v) == "number" then return v end
    end
    return nil
end

-- Clear hover cursors only on components inside the plugin's root, so the
-- normal game pointer shows over the window. Every component under `root`
-- gets no mouse-over cursor:
-- ComponentCursorConfig.mouseOverCursor = -1, "no cursor is set" (Component
-- Configs, RuneScape Client API docs). Walks the children with the
-- documented IterateStaticComponents / IterateDynamicComponents; anything
-- that doesn't have them is skipped. Returns how many were changed.
function Panel.plainCursors(root)
    local changed = 0
    local function visit(c)
        if c == nil then return end
        pcall(function()
            local cfg = c.cursorConfig
            if cfg and cfg.mouseOverCursor ~= -1 then
                cfg.mouseOverCursor = -1
                c.cursorConfig = cfg
                changed = changed + 1
            end
        end)
        for _, m in ipairs({ "IterateStaticComponents", "IterateDynamicComponents" }) do
            pcall(function() c[m](c, function(child) visit(child) return false end) end)
        end
    end
    visit(root)
    return changed
end

-- A PNG shipped in resources/ ({ image = "icon_quest" }), loaded once, the
-- same way as the circles. Nil if it can't be loaded.
local imageCache = {}
local function imageOf(name)
    if imageCache[name] == nil then
        local ok, r = pcall(function()
            local res = Plugin.resources[name] or Plugin.resources[name .. ".png"]
            if res and not res.loaded then res:Load() end
            return res
        end)
        imageCache[name] = (ok and r) or false
        if not imageCache[name] then
            local keys = {}
            pcall(function() for k in pairs(Plugin.resources) do keys[#keys + 1] = tostring(k) end end)
            print("[Road to Trim] icon image '" .. name .. "' didn't load: " .. tostring(ok and "not in resources" or r)
                .. "; resources: " .. table.concat(keys, ", "))
        elseif r.loaded == false then
            print("[Road to Trim] icon image '" .. name .. "' found but not loaded")
        end
    end
    return imageCache[name] or nil
end

-- Puts `icon` ({ sprite = id } / { spriteName = name } / { item = id } /
-- { image = resource name } / nil) on an icon slot (sprite, item, image).
local function setIcon(pair, icon)
    local img = icon and icon.image and imageOf(icon.image)
    local sid = spriteIdOf(icon)
    if icon and not icon.item and sid == nil and img == nil then icon = nil end
    if sid then icon = { sprite = sid } end
    pair.sprite.hidden = not (icon and icon.sprite)
    pair.item.hidden = not (icon and icon.item)
    pair.image.hidden = img == nil
    if icon and icon.sprite then pair.sprite.spriteID = icon.sprite end
    if icon and icon.item then pair.item:SetAssociatedObject(icon.item) end
    if img then pair.image.sprite = img end
end


-- Right edge of a page's content (see DEFAULT_CONTENT_WIDTH), never wider.
local function contentRight(page)
    local ok, w = pcall(function() return page.width or page.content.width end)
    if ok and type(w) == "number" and w > 200 then return math.min(w, DEFAULT_CONTENT_WIDTH) end
    return DEFAULT_CONTENT_WIDTH
end

-- Every piece of a row: its text, icons, circles, stripe, right-hand text
-- and item column.
local function rowParts(o)
    local list = {}
    -- Only the parts this row has (a missing one in a table literal would
    -- end the list there for ipairs).
    for _, c in ipairs({ "line", "right", "band" }) do if o[c] then list[#list + 1] = o[c] end end
    for _, c in pairs(o.icon or {}) do list[#list + 1] = c end
    for _, c in ipairs(o.dots or {}) do list[#list + 1] = c end
    return list
end

local drawRow, showDots, showSections   -- defined below; applyScroll draws the rows coming into view with them
local drawControls            -- defined below: the Settings tab's segmented buttons and switches
local drawShapes              -- defined below: a tab's card, chips, buttons and bars
-- Read by drawRow too (see drawShapes): the card's sides, inside the
-- section's box; a progress line's count on the right ("334 / 334 quests");
-- a heading's reset on the right ("resets Wed 00:00", row.rightWide).
local CARD_X = SECTION_INSET + 4
local BAR_RIGHT_W = 112
local WIDE_RIGHT_W = 130
local pageShapes = {}         -- page -> { card = { fill, edge }, bars = { { track, edge, fill } }, pills = { ... }, area }
local spaced                  -- defined below: blank rows around the sections (Panel.showPage)
local hovered = {}            -- page index -> { first, last, at } rows lit by the mouse (at: the row it's on)
-- Find the contiguous visual rows of the wrapped name row r belongs to, for
-- a shared hover: the rows next to it with the same `span` table
-- (Views.wrapRows gives every line of
-- one wrapped name the same one), else just r. Only rows inside the scroll
-- view's first..last count, so a name half scrolled away lights only what
-- is shown.
local function spanRange(rows, r, first, last)
    local row = rows[r]
    local a, b = r, r
    if row and row.span then
        while rows[a - 1] and rows[a - 1].span == row.span and (first == nil or a - 1 >= first) do a = a - 1 end
        while rows[b + 1] and rows[b + 1].span == row.span and (last == nil or b + 1 <= last) do b = b + 1 end
    end
    return a, b
end
local lineKeys = setmetatable({}, { __mode = "k" })   -- a row's line -> what it shows (Panel.showPage)

-- A card right under its heading (the Guide's DO THIS NOW) starts CARD_GAP
-- px lower, so the heading's text doesn't sit on the card's top edge. The
-- gap applies to the card's edge, fill and child presentation together
-- (text, icons, chips, buttons, stripes, hover bar and click areas), and to
-- every row under it. Section boxes holding their own heading (the WELCOME
-- box), a card with no heading above it (Progress') and a card nested inside
-- a section's box (STARTING SOON, see boxedCardRows) don't move.
local CARD_GAP = 6
local MAX_CARD_GAPS = 2       -- room kept on a tab's surface for this many gaps (one card per tab today)
local rowShift = {}           -- page index -> { [r] = px rows r.. are moved down, total = px under the last row }
-- The column (px from ROW_X) a tab's labelled bars start at (Views.barLayout), nil when it has none.
local barColumn = {}

-- Whether row r is a card's first row right under a heading (a heading as
-- Panel.sections reads one: tone "head", not a table's own header row).
local function cardUnderHeading(rows, r)
    local row, above = rows[r], rows[r - 1]
    return row ~= nil and row.card == true and above ~= nil and not above.card
        and above.tone == "head" and above.band ~= "head"
end

-- Suppress a nested card frame when the enclosing section already supplies
-- one. A card whose rows lie inside a section's box (Activities' STARTING
-- SOON) draws no edge or fill
-- of its own and gets no CARD_GAP: the section's box already frames it. Its
-- content (icon, chip, note, circles, buttons, stripes inside CARD_X, hover,
-- clicks) stays as it is; only the card's own frame goes. Cards outside a
-- box (the Guide's DO THIS NOW under its plain `noBox` heading, Progress'
-- card above its first heading) keep their frame.
-- The rows of a tab's card that sit inside a section's box: a card row in a
-- section (Panel.sections, over the whole list the tab shows, not just the
-- rows in view, so a scrolled-away heading changes nothing) whose heading
-- isn't marked noBox (the same test showSections boxes it by).
local function boxedCardRows(rows, shown)
    local out = {}
    for _, s in ipairs(Panel.sections(rows, shown)) do
        if not rows[s.first].noBox then
            for r = s.first, s.last do
                if rows[r].card then out[r] = true end
            end
        end
    end
    return out
end

-- How far each row of a tab is moved down (Panel.showPage): CARD_GAP for
-- each framed card-under-a-heading at or above it (a card inside a section's
-- box has no frame, so no gap). out.boxed: the boxed card rows (above), read
-- by drawShapes so the frame and the gap follow the same decision.
local function shiftsOf(rows, shown)
    local out, px = {}, 0
    out.boxed = boxedCardRows(rows, shown)
    for r = 1, #rows do
        if cardUnderHeading(rows, r) and not out.boxed[r] then px = px + CARD_GAP end
        out[r] = px
    end
    out.total = px
    return out
end

-- Whether a tab's row r is a card row inside a section's box (no frame of its own).
local function cardBoxed(pageIndex, r)
    local sh = rowShift[pageIndex]
    return sh ~= nil and sh.boxed ~= nil and sh.boxed[r] == true
end

-- How far row r of a tab is moved down, and where its top is on the
-- tab's surface. Rows past the list's end take the last row's shift.
local function shiftAt(pageIndex, r)
    local sh = rowShift[pageIndex]
    if not sh then return 0 end
    return sh[r] or sh.total or 0
end
local function rowTop(pageIndex, r) return (r - 1) * ROW_HEIGHT + shiftAt(pageIndex, r) end

-- Puts a tab's rows where its scroll offset says. Only slots whose visible
-- rows change are updated: each row is drawn when it comes into view and
-- hidden when it leaves; s.drawn is nil after the rows change
-- (Panel.showPage), so all of them are gone through once.
local function applyScroll(pageIndex)
    local s = scrollers[pageIndex]
    if not s then return end
    local contentH = (s.rows or 0) * ROW_HEIGHT + shiftAt(pageIndex, s.rows or 0)
    -- Leave bottom padding below the final row: if the tab was cut short at
    -- a non-blank last row, the room is one row below it.
    local lastRow = shownRows[pageIndex] and shownRows[pageIndex][s.rows or 0]
    local endRoom = (lastRow and (lastRow[1] or "") ~= "") and ROW_HEIGHT or END_ROOM
    -- Rounded up to a whole row, so the end of the scroll doesn't cut the top row.
    local maxOffset = math.ceil(math.max(0, contentH + endRoom - s.viewH) / ROW_HEIGHT) * ROW_HEIGHT
    s.offset = math.max(0, math.min(s.offset or 0, maxOffset))
    pcall(function() s.surface:SetPos(0, -s.offset) end)
    -- Only the rows wholly inside the view are drawn: the view doesn't cut
    -- off what's outside it. Everything of the other rows is hidden.
    local first = s.offset // ROW_HEIGHT + 1
    local last = first + s.viewH // ROW_HEIGHT - 1
    -- A row moved down under a card's gap (CARD_GAP) may no longer fit
    -- wholly at the bottom: it waits for the next scroll.
    while last >= first and rowTop(pageIndex, last) + ROW_HEIGHT > s.offset + s.viewH do last = last - 1 end
    s.first, s.last = first, last
    local rows = shownRows[pageIndex] or {}
    -- Clear hover when a slot's row changes: the bar would move with the
    -- surface, maybe out of the view, and the lit row keep its white. The
    -- next ONMOUSEOVER lights the row under the cursor again.
    pcall(function() if hoverBars[pageIndex] then hoverBars[pageIndex].hidden = true end end)
    local lit = hovered[pageIndex]
    if lit and pageRows[pageIndex] then
        for r = lit[1], lit[2] do
            local line = pageRows[pageIndex][r]
            if line then pcall(function() line.rgba = rowColour(rows[r]) end) end
        end
    end
    hovered[pageIndex] = nil
    local full = s.drawn == nil
    s.drawn = s.drawn or {}
    local imgs = loadDotImages()
    for r, line in ipairs(pageRows[pageIndex] or {}) do
        local inView = r >= first and r <= last and rows[r] ~= nil
        if full or inView ~= (s.drawn[r] == true) then
            s.drawn[r] = inView or nil
            local o = overlays[pageIndex] and overlays[pageIndex][r]
            if inView then
                if o then o.shift = shiftAt(pageIndex, r); pcall(drawRow, o, rows[r], imgs) end
            elseif o then
                for _, c in ipairs(rowParts(o)) do pcall(function() c.hidden = true end) end
            end
            -- Hide offscreen rows and disable their click targets; the ones
            -- in view click as their row says.
            pcall(function()
                local canClick = inView and wikiMenu(rows[r])
                line.hidden = not inView
                line.enabled = canClick
                line.clickthrough = not canClick
            end)
        end
    end
    pcall(showSections, pageIndex, rows, first, last)
    if pageIndex == SETTINGS_PAGE then pcall(drawControls, first, last) end
    if pageShapes[pageIndex] then pcall(drawShapes, pageIndex, first, last) end
    pcall(function()
        if not s.thumb then return end
        s.thumb.hidden = maxOffset == 0
        if maxOffset > 0 then
            local h = math.max(20, math.floor(s.viewH * s.viewH / contentH))
            local vw = (type(s.view.width) == "number" and s.view.width > 0) and s.view.width or DEFAULT_CONTENT_WIDTH
            s.thumb:SetSize(THUMB_W, h)
            s.thumb:SetPos(vw - THUMB_RIGHT - THUMB_W, math.floor((s.viewH - h) * s.offset / maxOffset))
        end
    end)
end

-- Convert one mouse-wheel delta into a clamped row offset. The delta's sign
-- isn't documented; in client testing (2026-10-21) a positive delta was the
-- wheel turned down, so positive scrolls downward. The first one is printed
-- with Views.DEBUG on.
function Panel.scrollBy(pageIndex, delta)
    local s = scrollers[pageIndex]
    if not s or type(delta) ~= "number" or delta == 0 then return end
    if not wheelLogged then
        wheelLogged = true
        Views.debug("scroll: first wheel delta " .. tostring(delta))
    end
    s.offset = (s.offset or 0) + (delta > 0 and 1 or -1) * WHEEL_STEP * ROW_HEIGHT
    applyScroll(pageIndex)
end

-- Where a tab is scrolled to (pixels from the top), and scrolling it there:
-- Details open at the top so Back is visible, and Back puts the list where
-- it was.
function Panel.scrollOffset(pageIndex)
    return scrollers[pageIndex] and scrollers[pageIndex].offset or 0
end
function Panel.scrollTo(pageIndex, offset)
    local s = scrollers[pageIndex]
    if not s then return end
    s.offset = offset or 0
    applyScroll(pageIndex)
end

-- Settings and Progress rows have one circle and no icon (PLAIN_PAGES),
-- which keeps the window's component count near what it was.
local function addDots(pageIndex, page, rows)
    overlays[pageIndex] = {}
    local plain = PLAIN_PAGES[pageIndex] == true
    for i, line in ipairs(rows) do
        local o = { dots = {}, x = line.x, y = line.y, line = line, page = page, pageIndex = pageIndex }
        local iy = line.y + (ROW_HEIGHT - ICON) // 2
        if not plain then
            o.icon = { sprite = spriteIcon(page.content, line.x, iy, ICON), item = itemIcon(page.content, line.x, iy, ICON),
                       image = spriteIcon(page.content, line.x, iy, ICON) }
        end
        for k = 1, plain and 1 or MAX_DOTS do
            o.dots[k] = dotComponent(page.content, 0, line.y + (ROW_HEIGHT - DOT) // 2)
        end
        pcall(function()
            local band = pageBands[pageIndex] and pageBands[pageIndex][i]
            if band then band:SetPos(0, line.y); o.band = band end
            local t = ui.Text.new(page.content)
            t:SetSize(AMOUNT_WIDTH, ROW_HEIGHT)
            t.font = BODY_FONT
            t.maxLines = 1
            t.isShadowed = true
            t.clickthrough = true
            t:AlignTo(ui.AlignMode.TOPLEFT, ui.AlignMode.CENTRE)
            t.content = ""
            o.right = t
        end)
        overlays[pageIndex][i] = o
    end
end

-- Where each section starts and ends on a tab's rows: a heading row that
-- isn't a table's own header row (band "head") starts one.
function Panel.sections(rows, shown)
    local out = {}
    local n = math.min(#rows, shown or #rows)   -- only the rows the tab shows
    for i = 1, n do
        local row = rows[i]
        if row.tone == "head" and row.band ~= "head" then
            if #out > 0 then out[#out].last = i - 1 end
            out[#out + 1] = { first = i, last = n }
        end
    end
    return out
end

showSections = function(pageIndex, rows, first, last)
    local blocks = sectionBlocks[pageIndex]
    if not blocks then return end
    -- Hide out-of-viewport shapes explicitly: only the part of each section
    -- inside the view (first..last rows) is drawn, since the layer does not
    -- clip what's outside it.
    local secs = {}
    for n, s in ipairs(Panel.sections(rows, pageRows[pageIndex] and #pageRows[pageIndex] or nil)) do
        local a, b = math.max(s.first, first or 1), math.min(s.last, last or s.last)
        -- n: the section's own place on the tab, so its colour stays put when
        -- sections above it scroll away.
        -- A heading marked `noBox` (the Guide's list headings) gets no box
        -- or edge; Details and the other tabs keep theirs.
        if a <= b and not rows[s.first].noBox then secs[#secs + 1] = { first = a, last = b, n = n } end
    end
    for k, b in ipairs(blocks) do
        local s = secs[k]
        pcall(function()
            b.box.hidden = s == nil
            if b.edge then b.edge.hidden = s == nil end
            if s then
                local y = rowTop(pageIndex, s.first)
                local h = rowTop(pageIndex, s.last) + ROW_HEIGHT - y - SECTION_GAP
                b.box:SetPos(SECTION_INSET, y)
                b.box:SetSize(-2 * SECTION_INSET, h, 1.0, 0)
                if b.edge then
                    b.edge:SetPos(SECTION_INSET, y)
                    b.edge:SetSize(-2 * SECTION_INSET, h, 1.0, 0)
                end
            end
        end)
    end
end

-- Draws one row's parts (o, from addDots) for `row`: icon, circles, the
-- text's place, stripe, right-hand column; parts the row doesn't use hidden.
drawRow = function(o, row, imgs)
    local dots = row and row.dots or {}
    local icon = row and row.icon or nil
    if icon and not icon.item and not icon.image and spriteIdOf(icon) == nil then icon = nil end   -- unknown sprite name
    -- A wrapped row's later lines (Views.wrapRows) carry pad = { icon, dots }:
    -- indent as if the icon and circles were there, draw neither.
    local pad = row and row.pad or {}
    -- The row's top: its place, moved down under a card's gap (o.shift,
    -- CARD_GAP; set by applyScroll / showDots) with everything on it.
    local y = o.y + (o.shift or 0)
    if o.icon then
        setIcon(o.icon, icon)
        for _, c in pairs(o.icon) do c:SetPos(o.x, y + (ROW_HEIGHT - ICON) // 2) end
    end
    local x = o.x + ((icon or pad.icon) and (ICON + 6) or 0)
    -- Circles at the row's right end (row.dotsRight): they don't move the text.
    local dotsRight = row and row.dotsRight and #dots > 0
    local dotsX = dotsRight and (contentRight(o.page) - EDGE_MARGIN - #dots * (DOT + DOT_GAP) + DOT_GAP) or x
    for k, c in ipairs(o.dots) do
        local colour = dots[k]
        c.hidden = colour == nil
        if colour then
            c:SetPos(dotsX + (k - 1) * (DOT + DOT_GAP), y + (ROW_HEIGHT - DOT) // 2)
            if colour:find("^arrow_") then
                -- An arrow in a circle's place (a long-run goal's, after
                -- its achievement icon): the arrow picture, if circles
                -- are pictures here and it loads; otherwise none.
                local arrow = imgs and imageOf(colour)
                c.hidden = not arrow
                if arrow then c.sprite = arrow end
            elseif imgs then c.sprite = imgs[colour] else c.rgba = DOT_RGBA[colour] end
        end
    end
    -- Text starts after the icon and dots (plus a gap), or at the row start.
    local nDots = math.max(dotsRight and 0 or #dots, pad.dots or 0)
    if nDots > 0 then x = x + nDots * (DOT + DOT_GAP) + 4 end
    -- A numbered step: its number in its own colour, then the text. The
    -- number uses the row's right-hand text (a step has no amount), so the
    -- window keeps its component count (the game limits it).
    local num = row and not row.right and Views.splitNum(row[1])
    local numX = x
    if num or pad.num then x = x + NUM_W end
    -- Draw row.term (the Help's "DO THIS NOW:") separately in the emphasis
    -- colour, using the same right-hand text, with the rest of the line
    -- after it. Its room is the term and a space as the font measures
    -- them (Views.textWidth), so the line reads as one sentence. Only the
    -- first line of a wrapped row has a term; later lines start here.
    local term = not num and Views.splitTerm(row)
    local termW = term and math.ceil(Views.textWidth(term .. " ")) or 0
    x = x + termW
    -- A row's own extra indent in px (row.inset: the Progress card's text
    -- rows, to the right of its ring).
    if row and type(row.inset) == "number" then x = x + row.inset end
    o.line:SetPos(x, y)
    local col = barColumn[o.pageIndex]
    if row and col and Views.isLabelledBar(row) then
        -- Limit a labelled bar's label to the shared start column: its text
        -- box, and so its hover and click, ends where the tab's bars start
        -- (barColumn).
        o.line:SetSize(math.max(0, o.x + col - x), ROW_HEIGHT, 0, 0)
    elseif row and row.oneLine then
        -- A one-line row (a THEN entry): its text box ends where its right
        -- column or circles begin, the same room core/views.lua cut its
        -- text to (Views.lineRoom), so the text never runs under them.
        o.line:SetSize(Views.lineRoom(row), ROW_HEIGHT, 0, 0)
    else
        -- Its text box ends at the surface's right edge, wherever it starts,
        -- so no text runs into the thumb's gutter (SCROLL_GUTTER).
        o.line:SetSize(-x, ROW_HEIGHT, 1.0, 0)
    end
    -- Table stripe and right-hand column.
    local band = row and row.band
    local amountX = contentRight(o.page) - EDGE_MARGIN - AMOUNT_WIDTH   -- an item's amount, a step's "Ready"
    if o.band then
        o.band.hidden = not band
        if band then
            -- Keep the stripe inside its containing section's box, or inside
            -- the card's edge on a card row (drawShapes).
            local inset = (row.card and (CARD_X + 1)) or SECTION_INSET
            o.band.rgba = BAND[band] or BAND[1]
            o.band:SetPos(inset, y)
            o.band:SetSize(-2 * inset, ROW_HEIGHT, 1.0, 0)
        end
    end
    if o.right and num then
        o.right:SetPos(numX, y)
        o.right:SetSize(NUM_W, ROW_HEIGHT)
        o.right.content = num
        o.right.rgba = TONE.num
        o.right.hidden = false
    elseif o.right and term then
        o.right:SetPos(numX, y)
        o.right:SetSize(termW, ROW_HEIGHT)
        o.right.content = term
        o.right.rgba = TONE.num
        o.right.hidden = false
    elseif o.right then
        -- A progress line's count is wider than an amount (BAR_RIGHT_W), a
        -- heading's reset wider still (WIDE_RIGHT_W).
        local w = (row and row.rightFar) and READY_WIDTH or (row and row.bar) and BAR_RIGHT_W
            or (row and row.rightWide) and WIDE_RIGHT_W or AMOUNT_WIDTH
        o.right:SetPos(amountX + AMOUNT_WIDTH - w, y)
        o.right:SetSize(w, ROW_HEIGHT)
        o.right.content = row and row.right or ""
        o.right.rgba = TONE[row and row.rightTone or "default"] or TONE.default
        -- Back after a scroll hid it; a status chip's text is drawn on its chip.
        o.right.hidden = not (row and row.right) or (row.rightChip == true and pageShapes[o.pageIndex] ~= nil)
    end
end

-- Every row of a tab (without a scroll view to draw them as they come in).
showDots = function(pageIndex, rows)
    local imgs = loadDotImages()
    for i, o in pairs(overlays[pageIndex] or {}) do o.shift = shiftAt(pageIndex, i); pcall(drawRow, o, rows[i], imgs) end
end

-- The Settings tab, as rows like the other tabs: each setting a box of its
-- own, headed by its title, then its control, then a short note. The
-- renderer returns choices to main.lua and does not persist them. The kinds
-- (g.kind):
--   segment : one row of segmented buttons, the chosen one filled; a click
--             picks it
--   switch  : one row per choice, an on/off switch on the right;
--             a click on the row turns it on or off
--   links   : one row per choice { text, select, count }: the select goes to
--             onSelect (main.lua opens a list in Details), the count on the
--             right in gold
--   radio / check : one row per choice with a circle (green and white text:
--             chosen, grey: not), and optional coloured lines (g.legend =
--             { { text, rgba }, ... }: a colour's name written in it)
-- A choice's click (segment, switch, radio, check) is settings:<group>:<choice>,
-- handled here.
local settingsGroups = {}     -- the groups the Settings tab shows now
local function settingsRows(groups)
    local rows = {}
    for gi, g in ipairs(groups) do
        rows[#rows + 1] = { g.title:upper(), tone = "head" }
        local on = {}
        if g.kind == "radio" or g.kind == "segment" then on[g.selected or false] = true
        elseif g.kind ~= "links" then for _, v in ipairs(g.selected or {}) do on[v] = true end end
        if g.kind == "segment" then
            -- The row's own text stays empty: the segments draw their labels.
            local cells = {}
            for ci, c in ipairs(g.choices) do
                cells[ci] = { c[1], on = on[c[2]] == true, select = "settings:" .. gi .. ":" .. ci }
            end
            rows[#rows + 1] = { "", seg = cells }
        else
            for ci, c in ipairs(g.choices) do
                if g.kind == "switch" then
                    rows[#rows + 1] = { c[1], switch = on[c[2]] == true, tone = on[c[2]] and "title" or "default",
                        select = "settings:" .. gi .. ":" .. ci }
                elseif g.kind == "links" then
                    rows[#rows + 1] = { c[1], tone = "link", select = c[2], right = c[3] and tostring(c[3]) or nil, rightTone = "num" }
                else
                    rows[#rows + 1] = { c[1], dots = { on[c[2]] and "green" or "grey" }, tone = on[c[2]] and "title" or "default",
                        select = "settings:" .. gi .. ":" .. ci }
                end
            end
        end
        for _, l in ipairs(g.legend or {}) do rows[#rows + 1] = { l[1], rgba = l[2] } end
        if g.note then rows[#rows + 1] = { g.note, tone = "note" } end
    end
    return rows
end

-- A click on a choice: a radio or segment choice is picked, a check or
-- switch choice turned on or off; the group's onChange gets the value
-- (radio, segment) or the list of values on (check, switch), then the tab is
-- drawn again. False if it isn't a choice.
local function pickSetting(name, regroup)
    local gi, ci = tostring(name):match("^settings:(%d+):(%d+)$")
    local g = gi and settingsGroups[tonumber(gi)]
    local c = g and g.choices[tonumber(ci)]
    if not c then return false end
    if g.kind == "radio" or g.kind == "segment" then
        g.selected = c[2]
        g.onChange(c[2])
    else
        local on = {}
        for _, v in ipairs(g.selected or {}) do on[v] = true end
        on[c[2]] = not on[c[2]] or nil
        local values = {}
        for _, choice in ipairs(g.choices) do if on[choice[2]] then values[#values + 1] = choice[2] end end
        g.selected = values
        g.onChange(values)
    end
    settingsGroups = regroup() or settingsGroups
    Panel.showPage(SETTINGS_PAGE, settingsRows(settingsGroups))
    return true
end

-- Render pooled segment and switch controls for the Settings tab using
-- ui.Rectangle (https://developer.runescape.com/rs/ui/decorative_components/rectangle.html),
-- ui.Text and ONCLICK / ONMOUSEOVER / ONMOUSELEAVE hooks
-- (https://developer.runescape.com/rs/ui/component.html). Choices go back to
-- main.lua; the renderer does not persist anything. A small fixed pool is
-- placed on the rows in view each time they change (drawControls); unused
-- parts are hidden.
-- Layering: fills are created before the row text, labels after it, so text
-- draws over fills and labels take their own clicks. MoveToBack would hide
-- fills behind the window, so it is not used.
--   segment : a backing in the section edge colour, one fill per choice
--             with one-pixel gaps; the selected one BAND.head with white
--             text, the others BAND[1] with dim text, a step lighter under
--             the mouse
--   switch  : a track (green when on, slate when off), its 1 px edge, and a
--             knob, right when on, left when off; the row's own line takes
--             the click. Square corners: Rectangle has no rounding.
local SEG_POOL, SEG_MAX = 2, 4          -- allocated segment groups and choices per group; Account uses one group of four
local SWITCH_POOL = 6                   -- the four alert kinds, with room for two more
local SEG = { back = SECTION_EDGE, off = BAND[1], hover = BAND[2], on = BAND.head, text = TONE.dim, textOn = 0xFFFFFFFF }
local SWITCH = { w = 28, h = 14, knob = 10, off = 0x2A3A42FF, on = 0x2D5A3AFF, edgeOff = SECTION_EDGE, edgeOn = 0x5F9A6CFF,
                 knobOff = DOT_RGBA.grey, knobOn = TONE.good }
local CONTROL_X = ROW_X - 4             -- a segmented row spans the box, 10 px in from each side
local controls = nil                    -- { segs = { { back, cells = { { fill, text, on, select } } } }, switches = { { track, edge, knob } } }

local function controlRect(parent, rgba, outline)
    local r = ui.Rectangle.new(parent)
    r.fill = not outline
    if outline then r.outlineThickness = 1 end
    r.rgba = rgba
    r.clickthrough = true
    r.hidden = true
    return r
end

-- Before the tab's rows: every fill and the switches' parts.
local function makeControlFills(parent)
    controls = { segs = {}, switches = {} }
    for k = 1, SEG_POOL do
        local seg = { back = controlRect(parent, SEG.back), cells = {} }
        for c = 1, SEG_MAX do seg.cells[c] = { fill = controlRect(parent, SEG.off) } end
        controls.segs[k] = seg
    end
    for k = 1, SWITCH_POOL do
        controls.switches[k] = { track = controlRect(parent, SWITCH.off), edge = controlRect(parent, SWITCH.edgeOff, true),
                                 knob = controlRect(parent, SWITCH.knobOff) }
    end
end

-- After the tab's rows: the segments' labels, which take the clicks.
local function makeSegmentLabels(parent)
    for _, seg in ipairs(controls.segs) do
        for _, cell in ipairs(seg.cells) do
            local t = ui.Text.new(parent)
            t.font = BODY_FONT
            t.maxLines = 1
            t.isShadowed = true
            t:AlignTo(ui.AlignMode.CENTRE, ui.AlignMode.CENTRE)
            t.content = ""
            t.rgba = SEG.text
            t.clickthrough = false
            t.hidden = true
            t:Subscribe(ui.Hook.ONCLICK, "trimplanner.segpick", function()
                -- The segment that's already on does nothing: no change, no
                -- save, no redraw.
                if cell.select and not cell.on and onSelect then onSelect(cell.select, SETTINGS_PAGE) end
                return true
            end)
            t:Subscribe(ui.Hook.ONMOUSEOVER, "trimplanner.seghover", function()
                if not cell.on then cell.fill.rgba = SEG.hover end
                return true
            end)
            t:Subscribe(ui.Hook.ONMOUSELEAVE, "trimplanner.segunhover", function()
                cell.fill.rgba = cell.on and SEG.on or SEG.off
                return true
            end)
            t:Subscribe(ui.Hook.ONSCROLLWHEEL, "trimplanner.scroll", function(_, delta)
                Panel.scrollBy(SETTINGS_PAGE, delta)
                return true
            end)
            cell.text = t
        end
    end
end

-- One segmented row at y, its cells { { label, on, select }, ... }.
local function placeSegment(seg, cells, y)
    local w = CONTENT_W - 2 * CONTROL_X
    seg.back:SetPos(CONTROL_X, y + 1)
    seg.back:SetSize(w, ROW_HEIGHT - 2)
    seg.back.hidden = false
    local n = math.min(#cells, SEG_MAX)
    local inner = w - 2 - (n - 1)            -- inside the 1 px backing, less the 1 px gaps
    local cw = inner // n
    for k, cell in ipairs(seg.cells) do
        local c = cells[k]
        local shown = c ~= nil and k <= n
        cell.fill.hidden = not shown
        if cell.text then cell.text.hidden, cell.text.enabled = not shown, shown end
        if shown then
            local cx = CONTROL_X + 1 + (k - 1) * (cw + 1)
            local thisW = (k == n) and (CONTROL_X + w - 1 - cx) or cw   -- the last one takes what's left
            cell.on, cell.select = c.on == true, c.select
            cell.fill:SetPos(cx, y + 2)
            cell.fill:SetSize(thisW, ROW_HEIGHT - 4)
            cell.fill.rgba = cell.on and SEG.on or SEG.off
            if cell.text then
                cell.text:SetPos(cx, y + 2)
                cell.text:SetSize(thisW, ROW_HEIGHT - 4)
                cell.text.content = c[1]
                cell.text.rgba = cell.on and SEG.textOn or SEG.text
            end
        else
            cell.on, cell.select = false, nil
        end
    end
end

-- One switch at row y, on or off, at the right of the row.
local function placeSwitch(sw, on, y)
    local x = CONTENT_W - CONTROL_X - SWITCH.w
    local ty = y + (ROW_HEIGHT - SWITCH.h) // 2
    sw.track:SetPos(x, ty)
    sw.track:SetSize(SWITCH.w, SWITCH.h)
    sw.track.rgba = on and SWITCH.on or SWITCH.off
    sw.edge:SetPos(x, ty)
    sw.edge:SetSize(SWITCH.w, SWITCH.h)
    sw.edge.rgba = on and SWITCH.edgeOn or SWITCH.edgeOff
    sw.knob:SetPos(on and (x + SWITCH.w - SWITCH.knob - 2) or (x + 2), ty + (SWITCH.h - SWITCH.knob) // 2)
    sw.knob:SetSize(SWITCH.knob, SWITCH.knob)
    sw.knob.rgba = on and SWITCH.knobOn or SWITCH.knobOff
    sw.track.hidden, sw.edge.hidden, sw.knob.hidden = false, false, false
end

-- Puts the pool on the Settings rows first..last (the rows in view; all of
-- them without a scroll view) and hides the rest of it.
drawControls = function(first, last)
    if not controls then return end
    local rows = shownRows[SETTINGS_PAGE] or {}
    local nSeg, nSwitch = 0, 0
    for r = first or 1, math.min(last or #rows, #rows) do
        local row, y = rows[r], rowTop(SETTINGS_PAGE, r)
        if row and row.seg and nSeg < SEG_POOL then
            nSeg = nSeg + 1
            placeSegment(controls.segs[nSeg], row.seg, y)
        elseif row and row.switch ~= nil and nSwitch < SWITCH_POOL then
            nSwitch = nSwitch + 1
            placeSwitch(controls.switches[nSwitch], row.switch == true, y)
        end
    end
    for k = nSeg + 1, SEG_POOL do
        local seg = controls.segs[k]
        seg.back.hidden = true
        for _, cell in ipairs(seg.cells) do
            cell.fill.hidden = true
            if cell.text then cell.text.hidden, cell.text.enabled = true, false end
            cell.on, cell.select = false, nil
        end
    end
    for k = nSwitch + 1, SWITCH_POOL do
        local sw = controls.switches[k]
        sw.track.hidden, sw.edge.hidden, sw.knob.hidden = true, true, true
    end
end

-- Draw the Guide's card and chips, Activities' STARTING SOON shapes and
-- Progress' bars and ring from fixed per-tab pools (SHAPE_POOLS), using
-- filled and outlined ui.Rectangle
-- (https://developer.runescape.com/rs/ui/decorative_components/rectangle.html)
-- and ui.Text with ONCLICK / ONMOUSEOVER / ONMOUSELEAVE hooks
-- (https://developer.runescape.com/rs/ui/component.html). Visible shapes are
-- reused and repositioned for the rows in view (drawShapes); unused slots
-- are hidden, so a step change or Details opening leaves nothing behind.
-- Fills, edges and bars are created before the tab's text rows; chip and
-- button labels (which take the clicks) after them. MoveToBack would put
-- them behind the window, so it is not used.
--   row.card      : the row is inside a card (DO THIS NOW, STARTING SOON):
--                   card rows share one fill and edge behind the run of
--                   rows; its table stripes sit inside it. Inside a
--                   section's box (STARTING SOON) the section supplies the
--                   frame, so no fill or edge (boxedCardRows)
--   row.rightChip : row.right drawn as a status chip at the row's right end
--   row.chips     : { { text, tone }, ... } chips from the row's start (the
--                   timer chips), not clickable
--   row.buttons   : { { label, select, disabled }, ... } small framed
--                   buttons from the row's start (CARD_BUTTON); a click
--                   sends `select` to onSelect, and one with `disabled` is
--                   dim and takes nothing. No button offers Wiki: the
--                   entry's name has right-click > Wiki
--   row.bar       : { frac = 0..1, tone } a thin bar: on a row with text (the
--                   Guide's progress line) between the text and row.right;
--                   on a row of its own (a long-run goal's) from the text's
--                   indent to the right edge, or to row.right. Green, or
--                   gold with tone = "num"
--   row.dotsRight : row.dots at the row's right end (a THEN entry's uses,
--                   an activity's)
--   row.rightWide : row.right in a wider column (a heading's reset)
--   row.ring      : { frac = 0..1, text } the Progress card's ring, drawn at
--                   the card's left over this row and the two under it
--                   (RING px; the card's text rows carry row.inset)
-- Pool sizes per tab: the Guide has its progress bar and chips and buttons
-- (4 timer chips, a status chip, its one button and spares). Activities has
-- STARTING SOON chips and no bars. Progress has bars (the quests', one per
-- cape section, and the long-run goals': one for each of the 19 rows in
-- view, so any scroll position has enough), the ring and status slots. Each
-- tab that shows Details has at least three pills, enough for every
-- applicable Details chip ("N steps first", "Skills met", "N items missing").
-- Pools are small on purpose and created with the window: the official docs
-- give each component category a range of dynamic IDs (0-4096 under
-- category 0, 0-235 elsewhere; https://developer.runescape.com/rs/ui/index.html)
-- that other plugins may share. tests/run_tests.lua counts the window's
-- components against an offline 3,000-component budget (a test margin, not
-- an API cap) and checks the count doesn't grow with redraws, scrolls or
-- tab changes.
local SHAPE_POOLS = { [GUIDE_PAGE] = { bars = 1, pills = 10 }, [ACTIVITIES_PAGE] = { bars = 0, pills = 3 },
                      [PROGRESS_PAGE] = { bars = 19, pills = 3, ring = true } }
-- The Progress ring renders a fraction: a 64 px dark ring picture
-- (resources/ring_track.png, power-of-two as the game's loader needs) under
-- a ui.RadialProgressOverlay masked by the same ring in gold
-- (resources/ring_fill.png), progressing by hand from 0 to 100
-- (https://developer.runescape.com/rs/ui/decorative_components/radial_progress_overlay.html:
-- Start(initialValue, endValue) sets the range, curValue is written for a
-- manual indicator, maskSprite.sprite its picture). The percentage is a
-- text centred on it. If the overlay or the pictures can't be made, the
-- tab shows a gold bar and the percentage in the right column instead
-- (Panel.canRing; core/views.lua progressRows).
local RING = 64
local PILL_H = ROW_HEIGHT - 4
-- (CARD_X, BAR_RIGHT_W, WIDE_RIGHT_W and pageShapes are declared above drawRow, which reads them.)
-- Card, pill and button colours, using the panel palette (BAND / TONE).
local CARD = { fill = BAND[1], edge = 0x6B8A9CFF }
local PILL_EDGE = { good = 0x8AB873FF, warn = 0xA9705AFF, num = 0xB89A48FF }
local PILL_FILL = { num = 0x2A2A1CFF }  -- a gold timer chip's darker fill
local PILL = { fill = BAND[2], edge = SECTION_EDGE, text = TONE.default }
-- Card actions share the framed title-bar button style (frameButton): a
-- fill a step lighter than the card, the sections' thin edge, the label in
-- the default colour; the frame lights in the link blue on hover, and a
-- disabled action (the skip without the game clock) is dim and takes no
-- clicks. BUTTON_H is 2 px under ROW_HEIGHT so two rows of buttons don't
-- touch.
local CARD_BUTTON = { fill = BAND[2], edge = SECTION_EDGE, hoverEdge = TONE.link, text = TONE.default, dim = TONE.dim }
local BUTTON_H, BUTTON_Y = ROW_HEIGHT - 2, 1
local CARD_PAD_BOTTOM = 4               -- the card's edge this far under its last row (see drawShapes)
local BAR = { track = 0x07161EFF, edge = SECTION_EDGE, fill = TONE.good, h = 7 }
local BAR_FILL = { num = TONE.num }     -- a long-run goal's gold bar
-- Minimum bar column; a wider label moves the tab's bars right
-- (Views.barLayout). Keep it in sync with Views.BAR_LABEL_PX.
local BAR_LABEL_W = 96

-- Where a row's text starts, from the row's start (as drawRow places it):
-- after its icon, or the room kept for one, and its circles on the left, or
-- the room kept for them. For a bar on a row of its own.
local function textIndent(row)
    local pad = row and row.pad or {}
    local leftDots = (row and row.dots and not row.dotsRight) and #row.dots or 0
    local x = ((row and row.icon) or pad.icon) and (ICON + 6) or 0
    local nDots = math.max(leftDots, pad.dots or 0)
    if nDots > 0 then x = x + nDots * (DOT + DOT_GAP) + 4 end
    return x
end

-- Before a tab's rows: its card, bars and chip fills (SHAPE_POOLS).
local function makeShapeFills(pageIndex, area)
    local pool = SHAPE_POOLS[pageIndex]
    local s = { area = area, pills = {}, bars = {} }
    s.card = { fill = controlRect(area.content, CARD.fill), edge = controlRect(area.content, CARD.edge, true) }
    for k = 1, pool.bars do
        s.bars[k] = { track = controlRect(area.content, BAR.track), fill = controlRect(area.content, BAR.fill),
                      edge = controlRect(area.content, BAR.edge, true) }
    end
    for k = 1, pool.pills do
        s.pills[k] = { fill = controlRect(area.content, PILL.fill), edge = controlRect(area.content, PILL.edge, true) }
    end
    if pool.ring then
        -- Its own pcall: without the ring the tab still works (the bar instead).
        local okRing, errRing = pcall(function()
            local track, fill = imageOf("ring_track"), imageOf("ring_fill")
            if not (track and fill) then error("ring pictures didn't load") end
            local t = ui.Sprite.new(area.content)
            t:SetSize(RING, RING)
            t.sprite = track
            t.clickthrough = true
            t.hidden = true
            local r = ui.RadialProgressOverlay.new(area.content)
            r.maskSprite.sprite = fill
            r:SetSize(RING, RING)
            r:Start(0, 100)
            r.curValue = 0
            r.clickthrough = true
            r.hidden = true
            s.ring = { track = t, radial = r }
        end)
        if not okRing then print("[Road to Trim] panel: the Progress ring couldn't be made, a bar instead: " .. tostring(errRing)) end
    end
    pageShapes[pageIndex] = s
end

-- Whether the Progress tab draws its ring (else the bar takes its place).
function Panel.canRing()
    local s = pageShapes[PROGRESS_PAGE]
    return s ~= nil and s.ring ~= nil
end


-- Puts one pill (chip or button) at x, y, w with its label; `p` is its
-- pool slot, `c` what it shows, `button` whether it takes clicks.
local function placePill(p, c, x, y, w, button)
    p.c, p.button, p.x, p.y, p.w = c, button, x, y, w
    local tone = c.tone or "default"
    -- A button in the frame look (CARD_BUTTON), the full row less 2 px; a
    -- chip a pill, PILL_H tall, in its tone's colours.
    local live = button and not c.disabled
    p.fill.rgba = button and CARD_BUTTON.fill or (PILL_FILL[tone] or PILL.fill)
    p.edge.rgba = button and CARD_BUTTON.edge or (PILL_EDGE[tone] or PILL.edge)
    local top, h = button and BUTTON_Y or 2, button and BUTTON_H or PILL_H
    for _, r in ipairs({ p.fill, p.edge }) do
        r:SetPos(x, y + top)
        r:SetSize(w, h)
        r.hidden = false
    end
    if p.text then
        p.text:SetPos(x, y + top)
        p.text:SetSize(w, h)
        p.text.content = c[1] or ""
        p.text.rgba = button and (live and CARD_BUTTON.text or CARD_BUTTON.dim) or (TONE[tone] or TONE.default)
        p.text.hidden = false
        p.text.enabled = live == true
        p.text.clickthrough = not live
    end
end

local function hidePill(p)
    p.c, p.button = nil, nil
    p.fill.hidden, p.edge.hidden = true, true
    if p.text then p.text.hidden, p.text.enabled, p.text.clickthrough = true, false, true end
end

-- A centred text that takes no clicks (the ring's percentage).
local function plainLabel(parent)
    local t = ui.Text.new(parent)
    t.font = BODY_FONT
    t.maxLines = 1
    t.isShadowed = true
    t:AlignTo(ui.AlignMode.CENTRE, ui.AlignMode.CENTRE)
    t.content = ""
    t.clickthrough = true
    t.hidden = true
    return t
end

-- After the tab's rows: the pills' labels, which take the buttons' clicks;
-- the ring's percentage, which takes none.
local function makeShapeLabels(pageIndex, area)
    local s = pageShapes[pageIndex]
    if s.ring then s.ring.text = plainLabel(area.content) end
    for _, p in ipairs(pageShapes[pageIndex].pills) do
        local t = ui.Text.new(area.content)
        t.font = BODY_FONT
        t.maxLines = 1
        t.isShadowed = true
        t:AlignTo(ui.AlignMode.CENTRE, ui.AlignMode.CENTRE)
        t.content = ""
        t.clickthrough = true
        t.hidden = true
        t:Subscribe(ui.Hook.ONCLICK, "trimplanner.cardbutton", function()
            -- A dim button (c.disabled) does nothing.
            if p.button and p.c and not p.c.disabled and p.c.select and onSelect then onSelect(p.c.select, pageIndex) end
            return true
        end)
        t:Subscribe(ui.Hook.ONMOUSEOVER, "trimplanner.cardhover", function()
            if not (p.button and p.c) or p.c.disabled then return true end
            -- The frame lights in the link blue, as a row's hover bar does.
            -- Nothing else moves or hides.
            p.edge.rgba = CARD_BUTTON.hoverEdge
            return true
        end)
        t:Subscribe(ui.Hook.ONMOUSELEAVE, "trimplanner.cardunhover", function()
            if p.button then p.edge.rgba = CARD_BUTTON.edge end
            return true
        end)
        t:Subscribe(ui.Hook.ONSCROLLWHEEL, "trimplanner.scroll", function(_, delta)
            Panel.scrollBy(pageIndex, delta)
            return true
        end)
        p.text = t
    end
end

-- Puts a tab's pool on its rows first..last (the rows in view; all of them
-- without a scroll view) and hides the rest of it.
drawShapes = function(pageIndex, first, last)
    local s = pageShapes[pageIndex]
    if not s then return end
    local rows = shownRows[pageIndex] or {}
    local right = contentRight(s.area) - EDGE_MARGIN
    local nPill, nBar = 0, 0
    local cardFirst, cardLast = nil, nil
    local ringRow = nil     -- the row the ring is drawn on
    local function nextPill()
        if nPill >= #s.pills then return nil end
        nPill = nPill + 1
        return s.pills[nPill]
    end
    local function nextBar()
        if nBar >= #s.bars then return nil end
        nBar = nBar + 1
        return s.bars[nBar]
    end
    for r = first or 1, math.min(last or #rows, #rows) do
        local row, y = rows[r], rowTop(pageIndex, r)
        if row and row.card and not cardBoxed(pageIndex, r) then
            -- The card: the first run of framed card rows in view. Nested
            -- cards use the enclosing section's frame (cardBoxed).
            if cardFirst == nil then cardFirst, cardLast = r, r
            elseif cardLast == r - 1 then cardLast = r end
        end
        if row and row.rightChip and row.right then
            local p = nextPill()
            local w = Views.chipWidth(row.right)
            if p then placePill(p, { row.right, tone = row.rightTone }, right - w, y, w, false) end
        end
        for _, list in ipairs({ { row and row.chips, false }, { row and row.buttons, true } }) do
            -- From the row's start, each as wide as its label needs
            -- (Views.chipWidth: the same measure main.lua laid them out
            -- with), CHIP_GAP_PX apart.
            local x = ROW_X
            for _, c in ipairs(list[1] or {}) do
                local p = nextPill()
                if not p then break end
                local w = Views.chipWidth(c[1])
                placePill(p, c, x, y, w, list[2])
                x = x + w + Views.CHIP_GAP_PX
            end
        end
        if row and row.ring and s.ring and ringRow == nil then ringRow = { row = row, y = y } end
        local b = row and row.bar and nextBar() or nil
        if b then
            -- A row with text (the Guide's progress line): between its label
            -- and the count on the right. A row of its own (a long-run goal's):
            -- from the text's indent to the right edge, or to the count.
            local x0, x1
            if Views.isLabelledBar(row) then
                -- Align bars to the shared column after the widest label on
                -- the tab (barColumn, Views.barLayout), never before BAR_LABEL_W.
                x0, x1 = ROW_X + math.max(BAR_LABEL_W, barColumn[pageIndex] or 0), right - BAR_RIGHT_W - 6
            else
                x0, x1 = ROW_X + textIndent(row), right - (row.right and (BAR_RIGHT_W + 6) or 0)
            end
            local by = y + (ROW_HEIGHT - BAR.h) // 2
            b.track:SetPos(x0, by); b.track:SetSize(x1 - x0, BAR.h)
            b.edge:SetPos(x0, by); b.edge:SetSize(x1 - x0, BAR.h)
            local fw = math.floor((x1 - x0 - 2) * math.max(0, math.min(1, row.bar.frac or 0)) + 0.5)
            b.fill:SetPos(x0 + 1, by + 1); b.fill:SetSize(fw, BAR.h - 2)
            b.fill.rgba = BAR_FILL[row.bar.tone] or BAR.fill
            b.track.hidden, b.edge.hidden, b.fill.hidden = false, false, fw <= 0
        end
    end
    for k = nPill + 1, #s.pills do hidePill(s.pills[k]) end
    for k = nBar + 1, #s.bars do
        local b = s.bars[k]
        b.track.hidden, b.edge.hidden, b.fill.hidden = true, true, true
    end

    -- The ring at the card's left, over its row and the two under it; the
    -- overlay's value is the fraction of its 0..100 range.
    if s.ring then
        local r = s.ring
        r.track.hidden, r.radial.hidden = ringRow == nil, ringRow == nil
        if r.text then r.text.hidden = ringRow == nil end
        if ringRow then
            local x, y = CARD_X + 6, ringRow.y + 1
            r.track:SetPos(x, y)
            r.radial:SetPos(x, y)
            r.radial.curValue = 100 * math.max(0, math.min(1, ringRow.row.ring.frac or 0))
            if r.text then
                r.text:SetPos(x, y)
                r.text:SetSize(RING, RING)
                r.text.content = ringRow.row.ring.text or ""
                r.text.rgba = TONE.title
            end
        end
    end
    local card = s.card
    card.fill.hidden, card.edge.hidden = cardFirst == nil, cardFirst == nil
    if cardFirst then
        local y = rowTop(pageIndex, cardFirst)
        local h = rowTop(pageIndex, cardLast) + ROW_HEIGHT - y
        -- Add card-bottom padding under a card that ends on its buttons (the
        -- Guide's), only into the blank row main.lua leaves after the card,
        -- so the frame never crosses a row with text; not past the last row
        -- in view, and not when the card runs on below it. A card ending on
        -- text (Activities', Progress') gets no padding.
        local after = rows[cardLast + 1]
        local blankAfter = after ~= nil and (after[1] or "") == "" and not (after.card or after.chips or after.buttons or after.right
            or after.dots or after.icon or after.bar or after.ring or after.seg)
        if rows[cardLast].buttons and blankAfter and cardLast < math.min(last or #rows, #rows) then
            h = h + CARD_PAD_BOTTOM
        end
        local w = contentRight(s.area) - 2 * CARD_X
        for _, rect in ipairs({ card.fill, card.edge }) do
            rect:SetPos(CARD_X, y)
            rect:SetSize(w, h)
        end
    end
end

-- A row of tabs (the window's tabs, Activities' filters): one cell per name,
-- the chosen one lit with a light blue line under it, the others lighter
-- while the mouse is on them. A click calls onPick(name, k). In the compact
-- card's blue family (BAND), its text grey and white.
local STRIP = { off = BAND[1], hover = BAND[2], on = BAND.head, text = 0xB8C4CCFF, textOn = 0xFFFFFFFF, mark = TONE.link }
local function makeStrip(parent, x, y, w, h, names, onPick)
    local strip = { cells = {} }
    local gap = 4
    local cw = (w - (#names - 1) * gap) // #names
    for k, name in ipairs(names) do
        local cx = x + (k - 1) * (cw + gap)
        local bg = ui.Rectangle.new(parent)
        bg:SetPos(cx, y)
        bg:SetSize(cw, h)
        bg.fill = true
        bg.rgba = STRIP.off
        bg.clickthrough = true
        local mark = ui.Rectangle.new(parent)
        mark:SetPos(cx, y + h - 2)
        mark:SetSize(cw, 2)
        mark.fill = true
        mark.rgba = STRIP.mark
        mark.clickthrough = true
        mark.hidden = true
        local t = ui.Text.new(parent)
        t:SetPos(cx, y)
        t:SetSize(cw, h)
        t.font = BODY_FONT
        t.maxLines = 1
        t.isShadowed = true
        t:AlignTo(ui.AlignMode.CENTRE, ui.AlignMode.CENTRE)
        t.content = name
        t.rgba = STRIP.text
        t.clickthrough = false
        strip.cells[k] = { name = name, bg = bg, mark = mark, text = t }
        t:Subscribe(ui.Hook.ONCLICK, "trimplanner.strippick", function() onPick(name, k); return true end)
        t:Subscribe(ui.Hook.ONMOUSEOVER, "trimplanner.striphover", function()
            if strip.active ~= name then bg.rgba = STRIP.hover end
            return true
        end)
        t:Subscribe(ui.Hook.ONMOUSELEAVE, "trimplanner.stripunhover", function()
            bg.rgba = strip.active == name and STRIP.on or STRIP.off
            return true
        end)
    end
    function strip.set(active)
        strip.active = active
        for _, c in ipairs(strip.cells) do
            pcall(function()
                local on = c.name == active
                c.bg.rgba = on and STRIP.on or STRIP.off
                c.mark.hidden = not on
                c.text.rgba = on and STRIP.textOn or STRIP.text
            end)
        end
    end
    return strip
end

-- Moving a window (the full window, the compact card): a Button drag grip
-- under everything else consumes mouse input on the background inside the
-- plugin (text and rectangles let a click through to the game in client
-- testing; a button doesn't). It uses click, hold and release, as the basic
-- window's drag bar; their hook-local x, y are converted to absolute
-- coordinates with xyGlobal, the root is moved, and the final position is
-- reported through Panel.checkMoved. No drag delay or dead zone
-- (dragConfig, official Component Configs docs).
local function makeGrip(grip, root)
    local grab = nil              -- while held: where the mouse and the window were
    pcall(function()
        grip.dragConfig.dragDelayTicks = 0
        grip.dragConfig.deadZone = 0
    end)
    grip:Subscribe(ui.Hook.ONCLICK, "trimplanner.compactgrab", function(self, x, y)
        local g = self.xyGlobal
        grab = { x = x + g.x, y = y + g.y, rootX = root.x, rootY = root.y }
        return true
    end)
    grip:Subscribe(ui.Hook.ONHOLD, "trimplanner.compacthold", function(self, x, y)
        if grab == nil then return true end
        local g = self.xyGlobal
        local nx = grab.rootX + (x + g.x - grab.x)
        local ny = grab.rootY + (y + g.y - grab.y)
        if nx ~= root.x or ny ~= root.y then root:SetPos(nx, ny) end
        return true
    end)
    grip:Subscribe(ui.Hook.ONRELEASE, "trimplanner.compactrelease", function()
        grab = nil
        Panel.checkMoved()
        return true
    end)
end

-- The card's look, shared by the full planner (see the compact card below).
local CARD_BG, CARD_EDGE = 0x0A1F29FF, 0x46545CFF

-- Framed title-bar actions in the panel colours: a blue fill a step lighter
-- than the bar, the sections' thin edge, the text in the window's grey;
-- lighter, with white text, on hover. As wide as its word, so more of the
-- bar is left to drag the window by.
local BUTTON = { fill = BAND[2], hover = BAND.head, text = TONE.default, textHover = 0xFFFFFFFF }
local function buttonWidth(label) return #label * 7 + 18 end
-- The compact card uses the same style for Expand, at its own width (w).
local function frameButton(parent, label, x, y, onPress, w)
    w = w or buttonWidth(label)
    local bg = ui.Rectangle.new(parent)
    bg:SetPos(x, y)
    bg:SetSize(w, ROW_HEIGHT)
    bg.fill = true
    bg.rgba = BUTTON.fill
    bg.clickthrough = true
    local edge = ui.Rectangle.new(parent)
    edge:SetPos(x, y)
    edge:SetSize(w, ROW_HEIGHT)
    edge.fill = false
    edge.outlineThickness = 1
    edge.rgba = CARD_EDGE
    edge.clickthrough = true
    local t = ui.Text.new(parent)
    t:SetPos(x, y)
    t:SetSize(w, ROW_HEIGHT)
    t.font = BODY_FONT
    t.maxLines = 1
    t.isShadowed = true
    t:AlignTo(ui.AlignMode.CENTRE, ui.AlignMode.CENTRE)
    t.content = label
    t.rgba = BUTTON.text
    t.clickthrough = false   -- takes the press, so it doesn't drag the window
    t:Subscribe(ui.Hook.ONCLICK, "trimplanner.button", function() onPress(); return true end)
    t:Subscribe(ui.Hook.ONMOUSEOVER, "trimplanner.buttonhover", function()
        bg.rgba, t.rgba = BUTTON.hover, BUTTON.textHover
        return true
    end)
    t:Subscribe(ui.Hook.ONMOUSELEAVE, "trimplanner.buttonunhover", function()
        bg.rgba, t.rgba = BUTTON.fill, BUTTON.text
        return true
    end)
    return t
end

-- Builds the window. opts:
--   onRefresh : the basic fallback window's Refresh callback; the full
--               window updates through main.lua and has none
--   onCompact : called by the Compact button
--   onSelect  : called with (select, tab) when a row with `select` is clicked
--   pos       : optional {x = , y = } saved position
--   onMoved   : called with (x, y) when the window has been moved
--   filters   : { [tab] = { names = {...}, onPick = function(name) } }, the
--               filter tabs at the top of a tab (Activities)
--   settings  : the Settings tab (or a function returning it), a list of groups:
--               { title, kind = "segment"|"switch"|"links"|"radio"|"check",
--                 choices = { {text, value}, ... } (links: {text, select, count}),
--                 selected = value (segment, radio) or { value, ... } (switch, check),
--                 onChange = function(value or values), note = text,
--                 legend = { { text, rgba }, ... } }
local lastOpts = nil          -- Panel.create's opts, to rebuild after compact view
-- The Settings groups opts gives (a list, or a function returning one).
local function groupsOf(opts)
    return type(opts.settings) == "function" and opts.settings() or opts.settings
end

-- Closes the full planner, if open, and forgets its parts.
local function closeWindow()
    if window then pcall(function() window.root:Destroy() end) end
    window, pages, pageRows, strips = nil, {}, {}, {}
    pageShapes = {}
    overlays, hoverBars, shownRows, pageBands = {}, {}, {}, {}
end

function Panel.create(opts)
    if window or usingBasic then return true end
    lastOpts = opts
    onMoved = opts.onMoved
    local function groups() return groupsOf(opts) end
    onSelect = function(name, page)
        if pickSetting(name, groups) then return end
        if opts.onSelect then opts.onSelect(name, page) end
    end

    local parent = ui.Interfaces:GetComponent(id.Component.TOPLEVEL_V2__PLUGIN_BUILD_LAYER_TOP)
    if parent == nil then
        print("[Road to Trim] panel: plugin layer not found")
        return false
    end

    local ok, err = pcall(function()
        -- The frame, as the compact card: the drag grip under everything, the
        -- dark background, the 1 px edge.
        local root = ui.Layer.new(parent)
        window = { root = root }
        root:SetPos(opts.pos and opts.pos.x or 80, opts.pos and opts.pos.y or 80)
        root:SetSize(WIDTH, HEIGHT)
        local grip = ui.Button.new(root)
        grip:SetSize(WIDTH, HEIGHT)
        grip.label = ""
        grip.stylesheetID = id.StyleSheet.BUTTON_DEFAULT
        local bg = ui.Rectangle.new(root)
        bg:SetSize(WIDTH, HEIGHT)
        bg.fill = true
        bg.rgba = CARD_BG
        bg.clickthrough = true
        local edge = ui.Rectangle.new(root)
        edge:SetSize(WIDTH, HEIGHT)
        edge.fill = false
        edge.outlineThickness = 1
        edge.rgba = CARD_EDGE
        edge.clickthrough = true
        makeGrip(grip, root)
        -- The title bar: a step lighter than the window, inside its edge, so
        -- it reads as the handle. A press on it (or the title) reaches the
        -- grip under it.
        local bar = ui.Rectangle.new(root)
        bar:SetPos(1, 1)
        bar:SetSize(WIDTH - 2, BAR_H - 1)
        bar.fill = true
        bar.rgba = BAND[1]
        bar.clickthrough = true
        -- Title, then Compact / Help on the right.
        local title = ui.Text.new(root)
        title:SetPos(PAD, TITLE_Y)
        title:SetSize(WIDTH - 2 * PAD, ROW_HEIGHT)
        title.font = BODY_FONT
        title.maxLines = 1
        title.isShadowed = true
        title:AlignTo(ui.AlignMode.TOPLEFT, ui.AlignMode.CENTRE)
        title.content = "Road to Trim"
        title.rgba = TONE.title
        title.clickthrough = true   -- to the grip: the title drags the window
        local buttons = { { "Help", function() if onSelect then onSelect("info:help", 1) end end } }
        -- Compact: swap to the small card that shows only DO THIS NOW.
        if opts.onCompact then table.insert(buttons, 1, { "Compact", function() opts.onCompact() end }) end
        local bx = WIDTH - PAD - (#buttons - 1) * BUTTON_GAP
        for _, b in ipairs(buttons) do bx = bx - buttonWidth(b[1]) end
        for _, b in ipairs(buttons) do
            frameButton(root, b[1], bx, TITLE_Y, b[2])
            bx = bx + buttonWidth(b[1]) + BUTTON_GAP
        end
        strips.tabs = makeStrip(root, PAGE_X, TABS_Y, PAGE_W, TAB_H, TAB_NAMES, function(_, k) Panel.showTab(k) end)

        settingsGroups = {}
        for i = 1, #TAB_NAMES do
            local page = { content = ui.Layer.new(root) }
            page.content:SetPos(PAGE_X, PAGE_Y)
            page.content:SetSize(PAGE_W, PAGE_H)
            pages[i] = page
            pageRows[i] = {}
            -- Filter tabs above the rows, on tabs that have them.
            local f = opts.filters and opts.filters[i]
            if f then
                -- As wide as the sections under it (left of the thumb's gutter).
                strips[i] = makeStrip(page.content, SECTION_INSET, 4, CONTENT_W - 2 * SECTION_INSET, TAB_H, f.names,
                    function(name) f.onPick(name) end)
            end
            -- The view and its surface (see scrollers); everything on the
            -- tab's rows is made on the surface. Without them, the page.
            local viewTop = f and FILTER_ROW_HEIGHT or 0
            local area = { content = page.content, width = PAGE_W }
            pcall(function()
                -- A whole number of rows, so only text beyond the available
                -- room is cut and the bottom row never is.
                local viewH = math.floor((PAGE_H - viewTop) / ROW_HEIGHT) * ROW_HEIGHT
                local view = ui.Layer.new(page.content)
                view:SetPos(0, viewTop)
                view:SetSize(0, viewH, 1.0, 0)
                local surface = ui.Layer.new(view)
                surface:SetPos(0, 0)
                -- Left of the thumb's gutter (SCROLL_GUTTER), so nothing on
                -- the rows reaches the thumb.
                -- Plus the room the cards' gaps (CARD_GAP) move the rows down.
                surface:SetSize(CONTENT_W, ROWS_PER_PAGE[i] * ROW_HEIGHT + MAX_CARD_GAPS * CARD_GAP)
                local thumb = ui.Rectangle.new(view)
                thumb.fill = true
                thumb.rgba = SCROLL_THUMB
                thumb.clickthrough = true
                thumb.hidden = true
                local pageIndex = i
                for _, c in ipairs({ view, surface }) do
                    c:Subscribe(ui.Hook.ONSCROLLWHEEL, "trimplanner.scroll", function(_, delta)
                        Panel.scrollBy(pageIndex, delta)
                        return true
                    end)
                end
                scrollers[i] = { view = view, surface = surface, thumb = thumb, offset = 0, viewH = viewH, rows = 0 }
                area = { content = surface, width = CONTENT_W }
            end)
            -- Section tints first, so they draw behind the stripes and rows;
            -- their edges come after the stripes (below), since opaque
            -- stripes must precede text creation and would otherwise cover them.
            local blocks = {}
            pcall(function()
                for k = 1, MAX_SECTIONS_ON[i] or MAX_SECTIONS do
                    local box = ui.Rectangle.new(area.content)
                    box.fill = true
                    box.rgba = SECTION_FILL
                    box.clickthrough = true
                    box.hidden = true
                    blocks[k] = { box = box }
                end
            end)
            sectionBlocks[i] = blocks
            -- The Guide's and Activities' card fill and edge, chip and button
            -- fills and bars: over the section tint, before the stripes and
            -- rows (drawShapes).
            if SHAPE_POOLS[i] then
                local okCard, errCard = pcall(makeShapeFills, i, area)
                if not okCard then
                    pageShapes[i] = nil
                    print("[Road to Trim] panel: " .. TAB_NAMES[i] .. " shapes failed: " .. tostring(errCard))
                end
            end
            -- Table stripes, one per row, made before the rows so they draw
            -- behind the text but in front of the window (see BAND). Not on
            -- Progress: nothing it shows is a table (its rows are plain, see
            -- PLAIN_PAGES), and its rows would be as many more components.
            local bands = {}
            pcall(function()
                for r = 1, (i == PROGRESS_PAGE and 0 or ROWS_PER_PAGE[i]) do
                    local band = ui.Rectangle.new(area.content)
                    band:SetSize(0, ROW_HEIGHT, 1.0, 0)
                    band.fill = true
                    band.clickthrough = true
                    band.hidden = true
                    bands[r] = band
                end
            end)
            pageBands[i] = bands
            -- The sections' left bars, over the stripes' first 3 px (text
            -- starts at ROW_X, so they cover nothing).
            pcall(function()
                for _, b in ipairs(blocks) do
                    local edge = ui.Rectangle.new(area.content)
                    edge.fill = false
                    edge.outlineThickness = 1
                    edge.rgba = SECTION_EDGE
                    edge.clickthrough = true
                    edge.hidden = true
                    b.edge = edge
                end
            end)
            -- The hover bar too, for the same reason.
            pcall(function()
                local bar = ui.Rectangle.new(area.content)
                bar:SetSize(-2 * SECTION_INSET, ROW_HEIGHT, 1.0, 0)
                bar.rgba = HOVER_BAR
                bar.fill = true
                bar.clickthrough = true
                bar.hidden = true
                hoverBars[i] = bar
            end)
            -- The Settings controls' fills, before the rows (drawControls).
            if i == SETTINGS_PAGE then
                local okFills, errFills = pcall(makeControlFills, area.content)
                if not okFills then controls = nil; print("[Road to Trim] panel: settings controls failed: " .. tostring(errFills)) end
            end
            -- Fixed rows, one line each, so updating content never reflows.
            -- A click on a row with `select` (an achievement) opens it;
            -- hovering a clickable row lights it up.
            for r = 1, ROWS_PER_PAGE[i] do
                local line = ui.Text.new(area.content)
                line:SetPos(ROW_X, (r - 1) * ROW_HEIGHT)
                line:SetSize(-ROW_X, ROW_HEIGHT, 1.0, 0)   -- to the surface's right edge (see drawRow)
                line.font = BODY_FONT
                line.maxLines = 1
                line.isShadowed = true
                line:AlignTo(ui.AlignMode.TOPLEFT, ui.AlignMode.CENTRE)
                line.content = ""
                pageRows[i][r] = line
                local pageIndex, rowIndex = i, r
                pcall(function()
                    line:Subscribe(ui.Hook.ONSCROLLWHEEL, "trimplanner.scroll", function(_, delta)
                        Panel.scrollBy(pageIndex, delta)
                        return true
                    end)
                    line:Subscribe(ui.Hook.ONCLICK, "trimplanner.select", function()
                        local row = shownRows[pageIndex] and shownRows[pageIndex][rowIndex]
                        if row and row.select and onSelect then onSelect(row.select, pageIndex) end
                        return true
                    end)
                    -- Hover any piece of a wrapped name to highlight the
                    -- whole name (spanRange): every line's text white and
                    -- one bar stretched over all of them.
                    line:Subscribe(ui.Hook.ONMOUSEOVER, "trimplanner.hover", function()
                        local rows = shownRows[pageIndex] or {}
                        local row = rows[rowIndex]
                        local bar = hoverBars[pageIndex]
                        if clickable(row) then
                            -- Another name still lit (its leave not seen yet): back to its colour first.
                            local lit = hovered[pageIndex]
                            if lit then
                                for r = lit[1], lit[2] do
                                    local l = pageRows[pageIndex][r]
                                    if l then l.rgba = rowColour(rows[r]) end
                                end
                            end
                            local s = scrollers[pageIndex]
                            local a, b = spanRange(rows, rowIndex, s and s.first, s and s.last)
                            for r = a, b do
                                local l = pageRows[pageIndex][r]
                                if l then l.rgba = HOVER_TEXT end
                            end
                            hovered[pageIndex] = { a, b, at = rowIndex }
                            if bar then
                                local top = rowTop(pageIndex, a)
                                bar:SetPos(SECTION_INSET, top)
                                bar:SetSize(-2 * SECTION_INSET, rowTop(pageIndex, b) + ROW_HEIGHT - top, 1.0, 0)
                                bar.hidden = false
                            end
                        end
                        return true
                    end)
                    line:Subscribe(ui.Hook.ONMOUSELEAVE, "trimplanner.unhover", function()
                        local rows = shownRows[pageIndex] or {}
                        local lit = hovered[pageIndex]
                        if lit and lit.at == rowIndex then
                            -- Leaving the line that lit the name: all of it goes back.
                            for r = lit[1], lit[2] do
                                local l = pageRows[pageIndex][r]
                                if l then l.rgba = rowColour(rows[r]) end
                            end
                            hovered[pageIndex] = nil
                            if hoverBars[pageIndex] then hoverBars[pageIndex].hidden = true end
                        elseif not (lit and rowIndex >= lit[1] and rowIndex <= lit[2]) then
                            -- Not part of what's lit (the mouse is already on
                            -- another line, whose hover came first): only this line.
                            line.rgba = rowColour(rows[rowIndex])
                            if lit == nil and hoverBars[pageIndex] then hoverBars[pageIndex].hidden = true end
                        end
                        return true
                    end)
                end)
            end
            -- Rows on every content tab can show icons and circles.
            if ROWS_PER_PAGE[i] > 0 then
                local okDots, errDots = pcall(function() addDots(i, area, pageRows[i]) end)
                if not okDots then print("[Road to Trim] panel: icons/circles failed: " .. tostring(errDots)) end
            end
            -- The chip and button labels, over the rows, so the buttons take their clicks.
            if pageShapes[i] then
                local okCardLabels, errCardLabels = pcall(makeShapeLabels, i, area)
                if not okCardLabels then
                    pageShapes[i] = nil
                    print("[Road to Trim] panel: " .. TAB_NAMES[i] .. " buttons failed: " .. tostring(errCardLabels))
                end
            end
            -- The segments' labels, over the rows, so they take their clicks.
            if i == SETTINGS_PAGE and controls then
                local okLabels, errLabels = pcall(makeSegmentLabels, area.content)
                if not okLabels then controls = nil; print("[Road to Trim] panel: settings buttons failed: " .. tostring(errLabels)) end
            end
        end

        lastX, lastY = window.root.x, window.root.y
        Views.debug("mouse: game cursor kept on " .. Panel.plainCursors(window.root) .. " parts of the window")
    end)
    if not ok then
        print("[Road to Trim] panel: window failed: " .. tostring(err) .. "; using the basic window")
        -- Remove what was built, so the basic window isn't hidden behind an
        -- empty shell.
        closeWindow()
        usingBasic = true
        return Basic.create(opts.onRefresh, opts.pos, opts.onMoved)
    end
    -- Settings has its rows now; the Guide shows first.
    settingsGroups = groups() or {}
    Panel.showPage(SETTINGS_PAGE, settingsRows(settingsGroups))
    Panel.showTab(1)
    return true
end

-- Leave padding between section edges and text: a section's box ends a few
-- px before its last row does, so a section ending on text would touch the
-- box's edge. Each heading gets
-- a blank row before it (one that has one already keeps it), the page a
-- blank row after its last; blank rows at the very top are dropped, so a
-- tab starts with what it shows.
local function isBlank(row)
    return (row[1] or "") == "" and not row.right and not row.dots and not row.icon and not row.seg
        and not row.chips and not row.buttons and not row.bar and not row.ring
end
local function isHeading(row) return row.tone == "head" and row.band ~= "head" end
spaced = function(rows)
    local out = {}
    for _, r in ipairs(rows) do
        if #out > 0 or not isBlank(r) then
            if isHeading(r) and #out > 0 and not isBlank(out[#out]) then out[#out + 1] = { "" } end
            out[#out + 1] = r
        end
    end
    if #out > 0 and not isBlank(out[#out]) then out[#out + 1] = { "" } end
    return out
end

-- Fills one tab. Extra rows are dropped, missing ones cleared. A row with a
-- wiki page gets a "Wiki" entry in its right-click menu (opConfig.opWikiText,
-- which the game opens in its built-in browser).
--   opts.measured : wrap the rows by measured pixels (Views.wrapRows'
--                   `measured`; the Guide list), else by characters
function Panel.showPage(index, rows, opts)
    -- Calculate one bar column for the full tab before visible drawing; a
    -- label too wide for it is cut before the rows are wrapped.
    local col
    rows, col = Views.barLayout(rows)
    rows = spaced(Views.wrapRows(rows, nil, nil, opts and opts.measured == true))   -- long lines go onto the next row instead of being cut off
    if usingBasic then
        if index ~= 1 then return end
        local texts = {}
        for i, row in ipairs(rows) do texts[i] = Views.plainText(row) end   -- keeps item amounts
        return Basic.show(texts[1], { table.unpack(texts, 2) })
    end
    local list = pageRows[index]
    if not list then return end
    shownRows[index] = rows
    barColumn[index] = col
    rowShift[index] = shiftsOf(rows, #list)   -- a framed card under a heading moves down CARD_GAP px (cardUnderHeading)
    if scrollers[index] then scrollers[index].rows = math.min(#rows, #list) end
    -- No scroll view (it failed to build) means no scroll range: draw every
    -- row directly, since applyScroll has nothing to work with on that tab.
    if not scrollers[index] then
        pcall(showDots, index, rows)
        pcall(showSections, index, rows)
        if index == SETTINGS_PAGE then pcall(drawControls) end
        if pageShapes[index] then pcall(drawShapes, index) end
    end
    -- Rewrite text, styles and targets only when the displayed values
    -- change; applyScroll then shows, hides and enables them.
    for i, line in ipairs(list) do
        local row = rows[i]
        local key = table.concat({ row and row[1] or "", tostring(rowColour(row)), row and row.wiki or "", tostring(clickable(row)),
            tostring(wikiMenu(row)), tostring(row and row.term) }, "\0")
        if lineKeys[line] ~= key then
            lineKeys[line] = key
            pcall(function()
                local _, rest = Views.splitNum(row and not row.right and row[1])
                if not rest then _, rest = Views.splitTerm(row) end   -- and a leading term (drawRow)
                line.content = rest or (row and row[1]) or ""   -- a step's number is drawn on its own
                line.hidden = row == nil   -- rows past the end are hidden
                line.rgba = rowColour(row)
                local takesMouse = wikiMenu(row)   -- a click (select), or only the title's right-click Wiki
                line.enabled = takesMouse
                line.clickthrough = not takesMouse
                line.opConfig.opWikiText = (takesMouse and row.wiki) or ""
            end)
        end
    end
    if scrollers[index] then scrollers[index].drawn = nil end   -- the rows changed: go through them all once
    applyScroll(index)   -- after the rows: it also turns off clicks outside the view
    Panel.checkMoved()
end

-- The Settings tab made again from the current choices (its counts: the
-- postponed quests, the dismissed "just opened up"). main.lua calls it when
-- what the window shows changed.
function Panel.refreshSettings()
    if not window or not lastOpts then return end
    settingsGroups = groupsOf(lastOpts) or settingsGroups
    Panel.showPage(SETTINGS_PAGE, settingsRows(settingsGroups))
end

-- Switches to a tab (1 = Guide ... see TAB_NAMES): only its page shows.
function Panel.showTab(index)
    for k, page in pairs(pages) do pcall(function() page.content.hidden = k ~= index end) end
    if strips.tabs then strips.tabs.set(TAB_NAMES[index]) end
end

-- Lights the active filter on a tab.
function Panel.setFilter(page, active)
    if strips[page] then strips[page].set(active) end
end

-- Alerts. Every alert is printed to the console locally. When
-- PrettyUI.AchievementPopup is available (and the full window is in use),
-- the title and text are also queued locally and shown one at a time, the
-- next one started from the popup's onComplete callback. Sound is off and
-- the title is prefixed "Road to Trim:" so it isn't mistaken for a real
-- achievement or game message (plugin guidelines: must not mislead). No
-- HTTP API is invoked here.
local queue, showing = {}, false

local function showNext()
    local item = table.remove(queue, 1)
    if item == nil then showing = false; return end
    showing = true
    local ok = pcall(function()
        prettyui.AchievementPopup.show({
            title = item[1], text = item[2], sound = false,
            onComplete = function() showNext() end,
        })
    end)
    -- On popup failure, stop the current display attempt; the alert was
    -- already printed. Queued items wait until the next notify call.
    if not ok then showing = false end
end

function Panel.notify(title, text)
    print("[Road to Trim] " .. title .. ": " .. text)
    if usingBasic or prettyui == nil or prettyui.AchievementPopup == nil then return end
    queue[#queue + 1] = { "Road to Trim: " .. title, text }
    if not showing then showNext() end
end

-- The compact card (see Panel.openCompact below): declared here so the
-- move check can see it.
local compact = nil               -- { root, bg, edge, chip, lines, icons, bands, dots, amounts, texts, button, instrButton, hover } while it's open
local onCompactMoved, lastCX, lastCY = nil, nil, nil

-- Both windows are dragged by their grip (makeGrip); we notice the new
-- position afterwards and let main.lua save it.
-- Has either window been dragged since the last look? Then its callback
-- saves the new place. Only reads positions, never moves anything; main.lua
-- calls it every tick, and it runs before a window is closed.
function Panel.checkMoved()
    if window and window.root and onMoved then
        local x, y = window.root.x, window.root.y
        if x ~= lastX or y ~= lastY then
            lastX, lastY = x, y
            -- Recreate the full window at its latest dragged position.
            if lastOpts then lastOpts.pos = { x = x, y = y } end
            onMoved(x, y)
        end
    end
    if compact and onCompactMoved then
        pcall(function()
            local x, y = compact.root.x, compact.root.y
            if x ~= lastCX or y ~= lastCY then
                lastCX, lastCY = x, y
                onCompactMoved(x, y)
            end
        end)
    end
end

-- Compact view: a 340-pixel card with a title and drag bar ("Road to Trim"
-- on the left, Expand on the right) and a dark background inside a thin
-- edge, in the look of the game's pop-up alerts (colours read from a
-- screenshot; not measured in the game). It shows the entry and its status
-- chip, up to two item rows plus a "+N more items" link, and an eligible
-- activity timer: at most COMPACT_MAX_LINES rows, no scrolling or pages.
-- The card is as tall as the bar and the lines it shows.
-- Made of official components: a Layer holds the rest; a filled Rectangle
-- is the background and an outline Rectangle the edge (Rectangle docs:
-- fill, outlineThickness). Components are made once and reused.
-- The items are a see-through table: striped rows, each with the item's
-- icon, a circle for whether it's in hand (as the Guide's), its name and,
-- on the right, its amount.
-- Outside those COMPACT_MAX_LINES rows, an extra pool of plain text rows
-- (COMPACT_TEXT_LINES) holds a title's second line and up to
-- COMPACT_INSTR_LINES expandable instruction rows, plus one framed
-- instruction toggle; nothing is made when they open, close or change.
-- Lines are placed in the order main.lua gives the rows; the toggle stays
-- last, the instructions just before it.
-- Opening compact closes the full window; it is rebuilt on expansion.
local COMPACT_WIDTH, COMPACT_MAX_LINES = 340, 5
local COMPACT_INSTR_LINES = 5     -- instruction rows at most, the "Full details" link included
local COMPACT_TEXT_LINES = 1 + COMPACT_INSTR_LINES   -- the name's second line, then the instructions
local COMPACT_CHARS = 38          -- characters per line at that width
local COMPACT_PAD = 10            -- space inside the edge
local COMPACT_BAR_H = ROW_HEIGHT  -- the title bar row, above the lines
local COMPACT_BUTTON_W, COMPACT_BUTTON_H = 90, 22
local COMPACT_AMOUNT_W, COMPACT_AMOUNT_CHARS = 70, 9   -- the amount column ("1234 / 5250")
local COMPACT_READY_W, COMPACT_READY_CHARS = 50, 6     -- a step's "Ready", narrower
-- Pixels a character takes at this width (COMPACT_CHARS in the card's
-- inner width), to turn a chip's width (compactChipWidth, px) into the
-- characters it takes from the title.
local COMPACT_PX_PER_CHAR = (COMPACT_WIDTH - 2 * COMPACT_PAD) / COMPACT_CHARS
-- Compact chip width is estimated at 7 px per character plus 14 px of
-- padding. These are independent dimensions, not font measurements; the
-- full window uses Views.chipWidth.
local COMPACT_CHIP_CHAR_PX, COMPACT_CHIP_PAD_PX = 7, 14
local function compactChipWidth(text) return #(text or "") * COMPACT_CHIP_CHAR_PX + COMPACT_CHIP_PAD_PX end
local COMPACT_POS = { x = 10, y = 10 }   -- first time: top-left of the plugin layer
-- Compact tones distinguish the title (white), requirements (the planner's
-- orange), links (light blue), items (light grey) and amounts (a softer
-- grey).
local CARD_TONE = { default = 0xE6E6E6FF, head = 0xFFFFFFFF, title = 0xFFFFFFFF, link = 0x8FC9F0FF }
local CARD_AMOUNT = 0xB8C4CCFF
local CARD_BAND = { [1] = 0xFFFFFF0F, [2] = 0xFFFFFF1F }   -- see-through table stripes
local CARD_HOVER = 0xFFFFFF26     -- over whatever can be clicked, while the mouse is on it
local compactShown = {}            -- decorated line slot -> the row shown on it, for clicks
local compactTextShown = {}        -- plain text slot -> the row shown on it, for clicks
local compactSlotY = {}            -- decorated line slot -> its y now
local compactTextY = {}            -- plain text slot -> its y now

function Panel.isCompact() return compact ~= nil end
-- The basic fallback window (ui/panel_basic.lua) took the full window's
-- place: main.lua then prints the Guide's overflow to the console,
-- regardless of DEBUG; the basic window's last line points there.
function Panel.isBasic() return usingBasic end

local function compactHeight(lines) return 2 * COMPACT_PAD + COMPACT_BAR_H + lines * ROW_HEIGHT end
-- Where line k starts: under the title bar.
local function compactLineY(k) return COMPACT_PAD + COMPACT_BAR_H + (k - 1) * ROW_HEIGHT end
local function cardTone(row) return CARD_TONE[row and row.tone or "default"] or TONE[row and row.tone] or CARD_TONE.default end

-- The hover highlight: one see-through rectangle over what the mouse is on.
local function hoverOn(x, y, w, h)
    pcall(function()
        compact.hover:SetPos(x, y)
        compact.hover:SetSize(w, h)
        compact.hover.hidden = false
    end)
end
-- The current compact hover target: { at = the text it's on, row = its
-- source row }, or nil. The lines lit are every slot showing a line of that
-- row's entry (compactLitLines).
local compactLit = nil
local function hoverOff()
    compactLit = nil
    if compact then pcall(function() compact.hover.hidden = true end) end
end

-- Find the slots belonging to the same wrapped name as `row` (the two lines
-- of a wrapped title share row.group, made once per name in
-- Panel.showCompact), else just row's own: { { text, row, y }, ... }.
local function compactLitLines(row)
    local out = {}
    if not compact or not row then return out end
    for _, pool in ipairs({ { compact.lines, compactShown, compactSlotY }, { compact.texts or {}, compactTextShown, compactTextY } }) do
        for k, t in ipairs(pool[1]) do
            local r = pool[2][k]
            if r and (r == row or (row.group ~= nil and r.group == row.group)) then
                out[#out + 1] = { t, r, pool[3][k] or compactLineY(k) }
            end
        end
    end
    return out
end
-- Puts the lit lines back in their own colours and the highlight away.
local function compactUnlight()
    if compactLit then
        for _, l in ipairs(compactLitLines(compactLit.row)) do pcall(function() l[1].rgba = cardTone(l[2]) end) end
    end
    hoverOff()
end

-- A line that opens something (the entry's name, "+N more items", "Done
-- for now", "Full details") takes its own clicks, like the planner's rows:
-- lit up while the mouse is on it, a click sends its `select` to main.lua.
-- A wrapped name lights both its lines, under one highlight over them.
-- `shown` and `ys` are the slot tables it reads (the decorated lines' or
-- the plain ones').
local function makeClickable(t, k, shown, ys)
    t:Subscribe(ui.Hook.ONCLICK, "trimplanner.compactselect", function()
        local row = shown[k]
        if row and row.select and onSelect then onSelect(row.select) end
        return true
    end)
    t:Subscribe(ui.Hook.ONMOUSEOVER, "trimplanner.compacthover", function()
        local row = shown[k]
        if row and row.select then
            compactUnlight()   -- whatever was lit before (its leave not seen yet)
            local top, bottom = nil, nil
            for _, l in ipairs(compactLitLines(row)) do
                l[1].rgba = HOVER_TEXT
                top = math.min(top or l[3], l[3])
                bottom = math.max(bottom or l[3], l[3])
            end
            top = top or ys[k] or compactLineY(k)
            bottom = bottom or top
            hoverOn(4, top, COMPACT_WIDTH - 8, bottom - top + ROW_HEIGHT)
            compactLit = { at = t, row = row }
        end
        return true
    end)
    t:Subscribe(ui.Hook.ONMOUSELEAVE, "trimplanner.compactunhover", function()
        if compactLit and compactLit.at == t then
            compactUnlight()   -- the line that lit the name: all of it goes back
        elseif not compactLit then
            t.rgba = cardTone(shown[k])
        end
        -- Else the mouse is already on another line (its hover came first): that one stays lit.
        return true
    end)
end

-- Create the pooled instruction toggle in the current-action button style
-- (CARD_BUTTON: framed, a fill a step lighter than the card, the
-- frame lit in the link blue while the mouse is on it), its fill and edge
-- before its label. Hidden until a row asks for it; a click sends the row's
-- select to main.lua.
local function makeCompactButton(parent)
    local b = { fill = controlRect(parent, CARD_BUTTON.fill), edge = controlRect(parent, CARD_BUTTON.edge, true) }
    b.text = plainLabel(parent)
    b.text.rgba = CARD_BUTTON.text
    b.text:Subscribe(ui.Hook.ONCLICK, "trimplanner.compactbutton", function()
        if b.c and b.c.select and onSelect then onSelect(b.c.select) end
        return true
    end)
    b.text:Subscribe(ui.Hook.ONMOUSEOVER, "trimplanner.compactbuttonhover", function()
        if b.c then b.edge.rgba = CARD_BUTTON.hoverEdge end
        return true
    end)
    b.text:Subscribe(ui.Hook.ONMOUSELEAVE, "trimplanner.compactbuttonunhover", function()
        b.edge.rgba = CARD_BUTTON.edge
        return true
    end)
    return b
end

-- Opens the compact card at `pos` ({x, y}, or the top-left the first time);
-- onExpand is called by its "Expand" button, onMoved(x, y) after the
-- player drags it. A click on a line with a `select` goes to the same
-- onSelect as the planner's rows. If any part can't be made, what was made
-- is removed, the console says so, the full planner stays (it's closed
-- only once the card is made) and it returns false.
function Panel.openCompact(pos, onExpand, onMoved)
    if compact or usingBasic then return compact ~= nil end
    local parent = ui.Interfaces:GetComponent(id.Component.TOPLEVEL_V2__PLUGIN_BUILD_LAYER_TOP)
    local c = {}
    local ok, err = pcall(function()
        pos = pos or COMPACT_POS
        c.parent = parent
        c.root = ui.Layer.new(parent)
        c.root:SetPos(pos.x, pos.y)
        c.root:SetSize(COMPACT_WIDTH, compactHeight(1))
        c.grip = ui.Button.new(c.root)   -- first, so everything else draws over it
        c.grip:SetSize(COMPACT_WIDTH, compactHeight(1))
        c.grip.label = ""
        c.grip.stylesheetID = id.StyleSheet.BUTTON_DEFAULT
        c.bg = ui.Rectangle.new(c.root)
        c.bg:SetSize(COMPACT_WIDTH, compactHeight(1))
        c.bg.fill = true
        c.bg.rgba = CARD_BG
        c.bg.clickthrough = true
        c.edge = ui.Rectangle.new(c.root)
        c.edge:SetSize(COMPACT_WIDTH, compactHeight(1))
        c.edge.fill = false
        c.edge.outlineThickness = 1
        c.edge.rgba = CARD_EDGE
        c.edge.clickthrough = true
        compact = c   -- the hooks below need it
        makeGrip(c.grip, c.root)
        -- The hover highlight (see-through, over the background): create
        -- overlays before text, chips and buttons, so they all draw over it.
        c.hover = ui.Rectangle.new(c.root)
        c.hover.fill = true
        c.hover.rgba = CARD_HOVER
        c.hover.clickthrough = true
        c.hover.hidden = true
        -- The status chip's fill and edge (the same pill as the Guide card's,
        -- placePill): before the lines, so the chip's label, a text made
        -- after them, draws over it. Hidden until a row asks for a chip.
        c.chip = { fill = controlRect(c.root, PILL.fill), edge = controlRect(c.root, PILL.edge, true) }
        -- The title bar row: the plugin's name on the left (a press on it
        -- reaches the grip: it drags the card); the Expand button on
        -- the right is made after the lines, with the other clickable parts.
        c.title = ui.Text.new(c.root)
        c.title:SetPos(COMPACT_PAD, COMPACT_PAD)
        c.title:SetSize(COMPACT_WIDTH - 2 * COMPACT_PAD - COMPACT_BUTTON_W - 6, COMPACT_BAR_H)
        c.title.font = BODY_FONT
        c.title.maxLines = 1
        c.title.isShadowed = true
        c.title:AlignTo(ui.AlignMode.TOPLEFT, ui.AlignMode.CENTRE)
        c.title.content = "Road to Trim"
        c.title.rgba = TONE.title
        c.title.clickthrough = true
        c.lines, c.icons, c.bands, c.dots, c.amounts = {}, {}, {}, {}, {}
        for k = 1, COMPACT_MAX_LINES do
            local y = compactLineY(k)
            local band = ui.Rectangle.new(c.root)   -- before the line, so behind it
            band:SetPos(4, y)
            band:SetSize(COMPACT_WIDTH - 8, ROW_HEIGHT)
            band.fill = true
            band.clickthrough = true
            band.hidden = true
            c.bands[k] = band
            local t = ui.Text.new(c.root)
            t:SetPos(COMPACT_PAD, y)
            t:SetSize(COMPACT_WIDTH - 2 * COMPACT_PAD, ROW_HEIGHT)
            t.font = BODY_FONT
            t.maxLines = 1
            t.isShadowed = true
            t:AlignTo(ui.AlignMode.TOPLEFT, ui.AlignMode.CENTRE)
            t.content = ""
            t.hidden = true
            t.clickthrough = true   -- to the grip, unless it opens something
            makeClickable(t, k, compactShown, compactSlotY)
            c.lines[k] = t
            local iy = y + (ROW_HEIGHT - ICON) // 2
            c.icons[k] = { sprite = spriteIcon(c.root, COMPACT_PAD, iy, ICON), item = itemIcon(c.root, COMPACT_PAD, iy, ICON),
                           image = spriteIcon(c.root, COMPACT_PAD, iy, ICON) }
            c.dots[k] = dotComponent(c.root, COMPACT_PAD, y + (ROW_HEIGHT - DOT) // 2)
            local a = ui.Text.new(c.root)
            a:SetPos(COMPACT_WIDTH - COMPACT_PAD - COMPACT_AMOUNT_W, y)
            a:SetSize(COMPACT_AMOUNT_W, ROW_HEIGHT)
            a.font = BODY_FONT
            a.maxLines = 1
            a.isShadowed = true
            a:AlignTo(ui.AlignMode.TOPLEFT, ui.AlignMode.CENTRE)
            a.content = ""
            a.rgba = CARD_AMOUNT
            a.clickthrough = true
            a.hidden = true
            c.amounts[k] = a
        end
        -- Preallocate the title-continuation and instruction text rows.
        -- Text only, no stripe, icon or circle; a "Full
        -- details" link among them takes its clicks like the lines above.
        c.texts = {}
        for k = 1, COMPACT_TEXT_LINES do
            local t = ui.Text.new(c.root)
            t:SetPos(COMPACT_PAD, compactLineY(1))
            t:SetSize(COMPACT_WIDTH - 2 * COMPACT_PAD, ROW_HEIGHT)
            t.font = BODY_FONT
            t.maxLines = 1
            t.isShadowed = true
            t:AlignTo(ui.AlignMode.TOPLEFT, ui.AlignMode.CENTRE)
            t.content = ""
            t.hidden = true
            t.clickthrough = true
            makeClickable(t, k, compactTextShown, compactTextY)
            c.texts[k] = t
        end
        -- The chip's label, over its fill; it takes no clicks.
        c.chip.text = plainLabel(c.root)
        c.button = frameButton(c.root, "Expand", COMPACT_WIDTH - COMPACT_PAD - COMPACT_BUTTON_W,
            COMPACT_PAD + (COMPACT_BAR_H - COMPACT_BUTTON_H) // 2, function() onExpand() end, COMPACT_BUTTON_W)
        -- Create the instruction toggle with the other clickable controls.
        c.instrButton = makeCompactButton(c.root)
        onCompactMoved, lastCX, lastCY = onMoved, c.root.x, c.root.y
    end)
    if not ok then
        print("[Road to Trim] compact card failed: " .. tostring(err))
        if c.root then pcall(function() c.root:Destroy() end) end
        compact = nil
        if not window and lastOpts then Panel.create(lastOpts) end
        return false
    end
    closeWindow()
    return true
end

-- The plugin layer's height: read when it can be, else the full planner's
-- (HEIGHT). The card's bottom is kept inside it.
local function compactViewHeight()
    local height = HEIGHT
    pcall(function()
        local measured = compact.parent.height
        if type(measured) == "number" and measured > 0 then height = measured end
    end)
    return height
end

-- Fills the compact card: one line per row, no scrolling or pages. A row
-- marked `oneLine` (an item) is truncated with "..." by characters;
-- `measured` (the timer) is cut by the font's measured width
-- (Views.cutPx); `wrapTitle` (the entry's name) goes onto a second line
-- when it doesn't fit beside its chip, and is cut with "..." only where it
-- doesn't fit on two
-- (Views.wrapTwo); any other (the NOTHING ELSE FOR NOW lines) wraps, a
-- click target kept on every wrapped piece. A row's icon (the step's
-- marker, an item's own icon) and circle (row.dots) go before its first
-- line. Table rows (row.band = 1 or 2) get their stripe and their amount
-- (row.right) in the column on the right; the title's status chip
-- (row.rightChip) is drawn as a pill at the row's right end.
-- A row with `compactButton` ({ label, select }) is the instruction
-- toggle's line (the last row, at the content's left edge); rows with
-- `instr` are instructions, put just before it,
-- wrapped by measured width into the plain rows, at most
-- COMPACT_INSTR_LINES; when they don't all fit, the last of those is the
-- row marked `instrMore` ("Full details", which main.lua always sends with
-- them and which shows only then). The card is as tall as the lines it
-- shows and is moved up if it would run off the bottom of the plugin layer.
-- If the card would be taller than the plugin layer, remove the
-- instruction prose, then its overflow link, then extra item and other
-- optional rows as needed (see the shrink order below). The first title
-- line and the instruction toggle are kept; if it is still too tall, the
-- card is anchored at the layer's top.
function Panel.showCompact(rows)
    if not compact then return end
    hoverOff()   -- the hovered slot may now contain plain text or another row (every line's colour is written below)
    local lines, instr, more = {}, {}, nil
    -- Where an indented line's text starts, and the card's right edge.
    local indentX = COMPACT_PAD + ICON + 6
    local columnEnd = COMPACT_WIDTH - COMPACT_PAD
    for _, r in ipairs(Views.flatten(rows or {})) do   -- one column: items under the step's text
        -- A table row's amount, or a step's status (row.rightTone), goes in
        -- the right column in its own tone, not after the text; a status
        -- chip is a pill of its own.
        local chip = r.rightChip and r.right and { r.right, tone = r.rightTone } or nil
        local amount = (not chip and (r.band or r.rightTone)) and r.right or nil
        local text = (amount or chip) and (r[1] or "") or Views.plainText(r)
        local indent = r.icon ~= nil or (r.pad and r.pad.icon == true)
        if r.compactButton then
            lines[#lines + 1] = { kind = "button", c = r.compactButton }
        elseif r.instrMore then
            more = { r[1], tone = r.tone, select = r.select }
        elseif r.instr then
            -- Under the name's text, to the card's right edge, by measured width.
            for _, piece in ipairs(Views.wrapPx(text, columnEnd - indentX)) do
                instr[#instr + 1] = { piece, tone = r.tone }
            end
        else
            local pieces
            local x = COMPACT_PAD + (indent and (ICON + 6) or 0) + (r.dots and (DOT + 6) or 0)
            if r.wrapTitle then
                -- The first line ends before the chip (or the amount column),
                -- the second runs to the card's edge.
                local right = columnEnd - (chip and (compactChipWidth(chip[1]) + 6) or 0)
                    - (amount and ((r.band and COMPACT_AMOUNT_W or COMPACT_READY_W) + 4) or 0)
                pieces = Views.wrapTwo(text, right - x, columnEnd - x)
            elseif r.measured then
                pieces = { Views.cutPx(text, columnEnd - x) }
            else
                local room = COMPACT_CHARS - (indent and 4 or 0) - (r.dots and 2 or 0)
                    - (amount and (r.band and COMPACT_AMOUNT_CHARS or COMPACT_READY_CHARS) or 0)
                if chip then room = room - math.ceil((compactChipWidth(chip[1]) + 6) / COMPACT_PX_PER_CHAR) end
                pieces = r.oneLine and { Views.cut(text, math.max(4, room)) } or Views.wrap(text, math.max(4, room))
            end
            -- The lines of one name light together (makeClickable): one
            -- group table per row that wraps.
            local group = (#pieces > 1 and r.select ~= nil) and {} or nil
            for j, piece in ipairs(pieces) do
                -- A name's second line is a plain row, not one of the five.
                local plain = r.wrapTitle and j > 1
                lines[#lines + 1] = { piece, kind = plain and "text" or "deco", tone = r.tone, select = r.select, band = r.band, group = group,
                    indent = indent, icon = j == 1 and r.icon or nil, dots = j == 1 and r.dots or nil, padDot = r.dots ~= nil,
                    amount = j == 1 and amount or nil, amountTone = r.rightTone, chip = j == 1 and chip or nil,
                    amountW = r.band and COMPACT_AMOUNT_W or COMPACT_READY_W }
            end
        end
    end
    -- The five rows of the step, its items and what's next stay as before:
    -- at most COMPACT_MAX_LINES of them; at most one second line for the name.
    local kept, nDeco, nText = {}, 0, 0
    local instrAt = nil   -- where the instructions go: just before the toggle, which is last
    for _, l in ipairs(lines) do
        if l.kind == "deco" then
            nDeco = nDeco + 1
            if nDeco <= COMPACT_MAX_LINES then kept[#kept + 1] = l end
        elseif l.kind == "text" then
            nText = nText + 1
            if nText <= 1 then kept[#kept + 1] = l end
        else
            kept[#kept + 1] = l
            instrAt = #kept
        end
    end
    lines = kept
    -- The instructions: as many as fit COMPACT_INSTR_LINES and the screen.
    -- All of them when they fit; else the first ones and "Full details".
    -- Shrink order for a card too tall for the plugin layer, so the toggle
    -- stays inside it: the instruction prose, then the "Full details" link,
    -- then the item rows after the first (counted in "+N more items"), then
    -- the other optional rows from the bottom up. The title's first line and
    -- the toggle are never removed; when even they don't fit, the card is
    -- put at the layer's top (below).
    local height = compactViewHeight()
    local function fits(n) return compactHeight(#lines + n) + COMPACT_PAD <= height end
    local chosen = {}
    if #instr > 0 and instrAt then
        if #instr <= COMPACT_INSTR_LINES and fits(#instr) then
            for k = 1, #instr do chosen[k] = instr[k] end
        else
            -- As many prose rows as fit with the link under them, at most
            -- four; none at all when not even one fits: the link alone, and
            -- not even that when it doesn't fit either.
            local n = math.min(#instr, COMPACT_INSTR_LINES) - 1
            while n > 0 and not fits(n + 1) do n = n - 1 end
            for k = 1, n do chosen[k] = instr[k] end
            if more and fits(n + 1) then chosen[#chosen + 1] = more end
        end
    end
    -- Still too tall: the item rows after the first go, from the last,
    -- into the "+N more items" line (made when there wasn't one, with the
    -- name's click target, as main.lua's).
    if not fits(#chosen) then
        local items, countAt, countN = {}, nil, 0
        for k, l in ipairs(lines) do
            local n = l.kind == "deco" and type(l[1]) == "string" and l[1]:match("^%+(%d+) more item")
            if n then countAt, countN = k, tonumber(n)
            elseif l.kind == "deco" and l.band then items[#items + 1] = k end
        end
        local dropped = 0
        while #items > 1 and not fits(#chosen) do
            local k = table.remove(items)
            local l = table.remove(lines, k)
            if countAt and countAt > k then countAt = countAt - 1 end
            dropped = dropped + 1
            if not countAt then
                -- The count takes the dropped row's place.
                local target = nil
                for _, t in ipairs(lines) do if t.select then target = t.select; break end end
                table.insert(lines, k, { "", kind = "deco", tone = "link", select = target, indent = true })
                countAt = k
            end
            if l then countN = countN + 1 end
        end
        if dropped > 0 then
            local c = lines[countAt]
            c[1] = string.format("+%d more item%s", countN, countN == 1 and "" or "s")
        end
        -- Last resort: the rows between the name's first line and the
        -- button, from the bottom up (the name's first line still opens
        -- its Details).
        local k = #lines
        while not fits(#chosen) and k > 1 do
            if lines[k].kind ~= "button" then table.remove(lines, k) end
            k = k - 1
        end
    end
    -- The button's place after any rows went: the instructions go just before it.
    if #chosen > 0 then
        for k, l in ipairs(lines) do if l.kind == "button" then instrAt = k end end
        for k = #chosen, 1, -1 do
            local l = chosen[k]
            table.insert(lines, instrAt, { l[1], kind = "text", tone = l.tone, select = l.select, indent = true })
        end
    end
    local h = compactHeight(math.max(1, #lines))
    pcall(function()
        compact.root:SetSize(COMPACT_WIDTH, h)
        compact.grip:SetSize(COMPACT_WIDTH, h)
        compact.bg:SetSize(COMPACT_WIDTH, h)
        compact.edge:SetSize(COMPACT_WIDTH, h)
    end)
    -- Every row on screen: the card's bottom stays inside the plugin layer
    -- with the edge's padding under it; a card dragged lower is moved up
    -- (never above the layer's top).
    local bottom = math.max(0, height - h - COMPACT_PAD)
    if compact.root.y > bottom then compact.root:SetPos(compact.root.x, bottom) end
    local imgs = loadDotImages()
    local chipShown = false
    -- Each line to its pool, in order: the decorated slots, the plain rows,
    -- the button.
    local decoAt, textAt, buttonY = {}, {}, nil
    for k, l in ipairs(lines) do
        if l.kind == "deco" then decoAt[#decoAt + 1] = { row = l, y = compactLineY(k) }
        elseif l.kind == "text" then textAt[#textAt + 1] = { row = l, y = compactLineY(k) }
        else buttonY = { c = l.c, y = compactLineY(k) } end
    end
    for k, t in ipairs(compact.lines) do
        local slot = decoAt[k]
        local row = slot and slot.row
        compactShown[k] = row
        local y = slot and slot.y or compactLineY(k)
        compactSlotY[k] = y
        pcall(function()
            t.hidden = row == nil
            -- A numbered step's number is drawn on its own (below).
            local num, rest = Views.splitNum(row and not row.amount and row[1])
            t.content = rest or (row and row[1]) or ""
            t.rgba = cardTone(row)
            -- Only a line that opens something takes the mouse; the rest let
            -- it through to the grip under them, for dragging.
            local canClick = row ~= nil and row.select ~= nil
            t.enabled = canClick
            t.clickthrough = not canClick
            local band = compact.bands[k]
            band:SetPos(4, y)
            band.hidden = not (row and row.band)
            if row and row.band then band.rgba = CARD_BAND[row.band] or CARD_BAND[1] end
            local icon = row and row.icon
            if icon and not icon.item and not icon.image and spriteIdOf(icon) == nil then icon = nil end
            local iy = y + (ROW_HEIGHT - ICON) // 2
            for _, part in pairs(compact.icons[k]) do part:SetPos(COMPACT_PAD, iy) end
            setIcon(compact.icons[k], icon)
            -- Then the circle, then the text, ending before the amount
            -- column or the chip, and the edge's padding.
            local x = COMPACT_PAD + ((row and row.indent) and (ICON + 6) or 0)
            local dot, colour = compact.dots[k], row and row.dots and row.dots[1]
            dot.hidden = colour == nil
            if colour then
                dot:SetPos(x, y + (ROW_HEIGHT - DOT) // 2)
                if imgs then dot.sprite = imgs[colour] else dot.rgba = DOT_RGBA[colour] end
            end
            if row and row.padDot then x = x + DOT + 6 end
            -- A numbered step: its number in its own colour in the amount
            -- column's text (a step has no amount), then the text after it.
            local numX = x
            if num then x = x + NUM_W end
            -- The amount column ends at the edge's padding (the Expand
            -- button is on the title bar, above the lines).
            local a = compact.amounts[k]
            a.hidden = not (row and (row.amount or num))
            a.content = (row and row.amount) or num or ""
            a.rgba = num and TONE.num or (row and row.amountTone and TONE[row.amountTone]) or CARD_AMOUNT
            local aw = row and row.amountW or COMPACT_AMOUNT_W
            if num then
                a:SetPos(numX, y)
                a:SetSize(NUM_W, ROW_HEIGHT)
            else
                a:SetPos(columnEnd - aw, y)
                a:SetSize(aw, ROW_HEIGHT)
            end
            local right = columnEnd - ((row and row.amount) and (aw + 4) or 0)
            -- The status chip at the line's right end (one on the card: the
            -- step's), the text ending before it.
            if row and row.chip and not chipShown then
                local w = compactChipWidth(row.chip[1])
                placePill(compact.chip, row.chip, columnEnd - w, y, w, false)
                right = columnEnd - w - 6
                chipShown = true
            end
            t:SetPos(x, y)
            t:SetSize(right - x, ROW_HEIGHT)
        end)
    end
    if not chipShown then pcall(hidePill, compact.chip) end
    -- The plain rows: the name's second line and the instructions, under
    -- the name's text (after its icon), to the card's right edge.
    for k, t in ipairs(compact.texts or {}) do
        local slot = textAt[k]
        local row = slot and slot.row
        compactTextShown[k] = row
        local y = slot and slot.y or compactLineY(1)
        compactTextY[k] = y
        pcall(function()
            t.hidden = row == nil
            t.content = row and row[1] or ""
            t.rgba = cardTone(row)
            local canClick = row ~= nil and row.select ~= nil
            t.enabled = canClick
            t.clickthrough = not canClick
            local x = COMPACT_PAD + ((row and row.indent) and (ICON + 6) or 0)
            t:SetPos(x, y)
            t:SetSize(columnEnd - x, ROW_HEIGHT)
        end)
    end
    -- Place the instruction toggle at the content's left edge (the title
    -- icon's x) on the card's last row, as wide as its label needs
    -- (Views.chipWidth, measured); hide it when no control applies.
    local b = compact.instrButton
    if b then
        pcall(function()
            b.c = buttonY and buttonY.c or nil
            local shownB = b.c ~= nil
            for _, part in ipairs({ b.fill, b.edge, b.text }) do part.hidden = not shownB end
            b.edge.rgba = CARD_BUTTON.edge
            b.text.enabled = shownB
            b.text.clickthrough = not shownB
            if shownB then
                local w = Views.chipWidth(b.c[1])
                local x, y = COMPACT_PAD, buttonY.y + BUTTON_Y
                for _, part in ipairs({ b.fill, b.edge, b.text }) do
                    part:SetPos(x, y)
                    part:SetSize(w, BUTTON_H)
                end
                b.text.content = b.c[1]
                b.text.rgba = CARD_BUTTON.text
            else
                b.text.content = ""
            end
        end)
    end
end

-- Closes the compact card and rebuilds the full planner.
function Panel.closeCompact()
    Panel.checkMoved()   -- keep a drag made since the last redraw
    if compact then pcall(function() compact.root:Destroy() end) end
    compact = nil
    if lastOpts then Panel.create(lastOpts) end
end

function Panel.destroy()
    Panel.checkMoved()   -- keep a drag made since the last redraw
    if compact then pcall(function() compact.root:Destroy() end); compact = nil end
    if usingBasic then return Basic.destroy() end
    closeWindow()
end

return Panel
