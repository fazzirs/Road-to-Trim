-- ui/panel_basic.lua
-- Fallback window, used only when the full panel (ui/panel.lua) cannot be
-- built: a draggable GroupBox with a status line, plain Guide rows and a
-- Refresh button.
-- Game API used here: ui components (GroupBox, Panel, Text, Button) and ui
-- hooks, id.Component / id.Font / id.StyleSheet. Dragging uses ONCLICK,
-- ONHOLD and ONRELEASE, converting hook-local coordinates through xyGlobal.
-- main.lua saves the reported position and prints the Guide's overflow to
-- the console. It knows nothing about quests: main.lua hands it plain
-- strings.
--
-- Built from the UI reference on developer.runescape.com:
--   GroupBox   SetHeaderLayout takes Uint8 values (max 255); the header reduces
--              the content area, so children are laid out by a Panel instead of
--              by hand-placed coordinates.
--   Panel      isVertical + spacing; children sized with SetSize(0, h, 1.0, 0.0)
--              are full width and h tall, stacked top to bottom.

local Panel = {}

local LINE_COUNT = 8          -- suggestion lines shown
local WIDTH, HEIGHT = 520, 280
local ROW = 20                -- height of one text row
local HEADER_H = 32

local box, layout, status, lines, refreshButton, dragHandle = nil, nil, nil, {}, nil, nil
local onMoved = nil           -- callback(x, y) after a drag, so main.lua can save it

-- Wrap major construction steps in pcall so a failure (a missing font or
-- stylesheet id) is logged without stopping the rest of the plugin. API
-- access outside these blocks can still fail.
local function try(label, fn)
    local ok, err = pcall(fn)
    if not ok then print("[Road to Trim] panel: " .. label .. " failed: " .. tostring(err)) end
    return ok
end

-- One full-width text row inside the layout panel.
local function textRow(parent, font)
    local t = ui.Text.new(parent)
    t:SetSize(0, ROW, 1.0, 0.0)
    t.font = font
    t.maxLines = 1
    t:AlignTo(ui.AlignMode.TOPLEFT, ui.AlignMode.CENTRE)
    t.content = ""
    t.clickthrough = true     -- let the mouse reach the box underneath, for dragging
    return t
end

-- Builds the window.
--   onRefresh : called when the Refresh button is pressed
--   pos       : optional {x = , y = } saved position (absolute, on the game window)
--   movedCb   : called with (x, y) after the user drags the window
function Panel.create(onRefresh, pos, movedCb)
    if box then return true end
    onMoved = movedCb

    local parent = ui.Interfaces:GetComponent(id.Component.TOPLEVEL_V2__PLUGIN_BUILD_LAYER_TOP)
    if parent == nil then
        print("[Road to Trim] panel: plugin layer not found")
        return false
    end
    local font = id.Font.MUSEO_SANS_15PT_REGULAR

    if not try("group box", function()
        box = ui.GroupBox.new(parent)
        box.stylesheetID = id.StyleSheet.DEFAULT
        box:SetSize(WIDTH, HEIGHT)
        if pos and pos.x and pos.y then
            box:SetPos(pos.x, pos.y)
        else
            box:SetPos(0, 0, 0.6, 0.3)   -- default: right of centre; a saved position takes precedence
        end
        -- Header values are Uint8: keep them under 255.
        box:SetHeaderLayout(200, HEADER_H, 0, 0, ui.GroupBoxHeaderAlignMode.LEFT)
        box.headerText.content = "Road to Trim"
        box.headerText.font = font
    end) then box = nil; return false end

    -- Vertical panel fills the content area and stacks the rows.
    try("layout panel", function()
        layout = ui.Panel.new(box)
        layout:SetSize(0, 0, 1.0, 1.0)
        layout.isVertical = true
        layout.spacing = 2
        layout.clickthrough = true   -- the panel covers the whole box; pass mouse through
    end)
    local container = layout or box

    -- Drag handle: the group box itself gets no mouse input (checked on the
    -- dev world), buttons do. A thin button on the first row moves the box.
    try("drag handle", function()
        dragHandle = ui.Button.new(container)
        dragHandle:SetSize(0, 18, 1.0, 0.0)
        dragHandle.label = "::: drag to move :::"
        dragHandle.stylesheetID = id.StyleSheet.BUTTON_DEFAULT
        -- Moving uses the click/hold/release hooks. Their x,y are relative to
        -- the bar (measured on the dev world: x=226 y=9 inside a 512x18 bar),
        -- and the bar moves with the box, so convert to absolute with the
        -- bar's xyGlobal first. Then: box = box at grab + cursor movement.
        local grabX, grabY, boxX, boxY = nil, nil, nil, nil
        local function absolute(self, x, y)
            local g = self.xyGlobal
            return x + g.x, y + g.y
        end
        dragHandle:Subscribe(ui.Hook.ONCLICK, "trimplanner.grab", function(self, x, y)
            grabX, grabY = absolute(self, x, y)
            boxX, boxY = box.x, box.y
            return true
        end)
        dragHandle:Subscribe(ui.Hook.ONHOLD, "trimplanner.hold", function(self, x, y)
            if grabX == nil then return true end
            local ax, ay = absolute(self, x, y)
            local nx, ny = boxX + (ax - grabX), boxY + (ay - grabY)
            if nx ~= box.x or ny ~= box.y then box:SetPos(nx, ny) end
            return true
        end)
        dragHandle:Subscribe(ui.Hook.ONRELEASE, "trimplanner.release", function(self, x, y)
            if grabX ~= nil and onMoved then onMoved(box.x, box.y) end
            grabX, grabY = nil, nil
            return true
        end)
    end)

    try("status line", function() status = textRow(container, font) end)
    for i = 1, LINE_COUNT do
        try("line " .. i, function() lines[i] = textRow(container, font) end)
    end

    try("refresh button", function()
        refreshButton = ui.Button.new(container)
        refreshButton:SetSize(0, 24, 1.0, 0.0)   -- full width, 24 tall, like the docs' example
        refreshButton.label = "Refresh"
        refreshButton.stylesheetID = id.StyleSheet.BUTTON_DEFAULT
        refreshButton:Subscribe(ui.Hook.ONBUTTONPRESSED, function() onRefresh() end)
    end)

    return true
end

-- Fills the window. statusText is one line; lineTexts is a list of strings,
-- missing ones cleared. When there are more than fit, the last line says how
-- many are left out (main.lua prints them all to the console, whatever
-- Views.DEBUG is: Panel.isBasic).
function Panel.show(statusText, lineTexts)
    if not box then return end
    if status then status.content = statusText or "" end
    for i = 1, LINE_COUNT do
        local text = lineTexts[i] or ""
        if i == LINE_COUNT and #lineTexts > LINE_COUNT then
            text = string.format("+%d more lines: see the console", #lineTexts - LINE_COUNT + 1)
        end
        if lines[i] then lines[i].content = text end
    end
end

-- Removes the window (on plugin disable/reload, so no stale copies linger).
function Panel.destroy()
    if box then
        pcall(function() box:Destroy() end)
    end
    box, layout, status, lines, refreshButton, dragHandle = nil, nil, nil, {}, nil, nil
end

return Panel
