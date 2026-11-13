-- data/icons.lua
-- Icon descriptors for the panel: game sprites, item IDs and local PNG
-- resources. Static data; no direct game API.
--
-- Sprites come from the game's id.Sprite table, dumped on the dev world on
-- 19 October 2026 (core/diagnostics.lua, dumpIcons). Items are by item ID
-- from the RuneScape Wiki.

return {
    -- Markers in front of entries, chosen by sprite name from the dump:
    --   achievement  the sprite the game's own achievement configs use
    --                (spriteID 30108 on all four cape achievements)
    --   minigame     the round minigame map icon, a local 32x32 resource
    --                (resources/icon_minigame.png), from the game / RuneScape
    --                Wiki like the plugin's other images.
    --   timegated    CLAN_ICON_HOURGLASS (5801)
    --   quest        the blue quest star (resources/icon_quest.png): the
    --                RuneScape Wiki's "Quest map icon" (23x23), resampled to
    --                32x32 (power-of-two side, like the 16x16 circles).
    --                Shipped as a file because its sprite ID isn't known.
    achievement = { sprite = 30108 },
    minigame = { image = "icon_minigame" },
    timegated = { sprite = 5801 },
    quest = { image = "icon_quest" },

}
