-- data/travelicons.lua
-- Static sprite IDs and unlock metadata for the icons drawn beside
-- travel-reference names. No direct game API: main.lua checks unlocks
-- (core/detect.lua reads) and ui/panel.lua draws the icons.
-- From the RuneScape Wiki's image pages, read
-- 2026-10-20: each lodestone's "<Name> lodestone icon.png" carries
-- {{Sprite license|...|id=N}} (Category:Lodestone icon images), the fairy ring
-- and transport map icons {{Minimap icon license|...|id=N}}; both templates
-- give "datatype = sprite-id", so these are sprite IDs (ui.Sprite.spriteID),
-- not map element IDs.
-- The Wiki's lodestone pictures are the lodestone network's buttons, with a
-- square background, so they aren't drawn. A lodestone row (main.lua
-- startText) keeps the place name and shows one of three icons:
--   unlocked  the lodestone's coloured crest (lodestone[...].crest below)
--   locked    its grey crest (lodestone[...].locked), and "(locked)" in words
--   unknown   the standard spellbook's Home Teleport icon, when the unlock
--             can't be read, with "(if activated)" where the start data asks
-- Teleport spells show their own spellbook icon (standard, Ancient Magicks
-- and Lunar; see runescape.wiki/w/Teleportation). They are offered when they
-- pass main.lua spellReady's recorded quest and level checks, not a live
-- castability check.

local W = "https://runescape.wiki/w/File:"

return {
    -- Each lodestone the start data names: the unlocked icon when the player
    -- has it, the locked one when not. From the game's own sprite and
    -- variable tables, read with the developer icon picker on beta in
    -- October 2026:
    --   crest   RS3_ICON_LODESTONE_INSIGNIA_<n>: coloured, no background
    --   locked  RS3_ICON_LODESTONE_INSIGNIA_LOCKED_<n>: the same crest in grey
    --           The numbers aren't names; each was matched to its place by
    --           eye in beta (both colours agree). The matching spreadsheets
    --           are not shipped; these mappings are historical measurements.
    --   unlock  the THAS_ACTIVE_<PLACE> varbit, 1 once unlocked, by name and
    --           ID (Fort Forinthry: PLAYER_FORT_LODESTONE); none for Lunar Isle
    --           and Bandit Camp
    --   unlockQuest  where the Wiki says a quest unlocks it instead (a
    --                quest-completion proxy)
    -- The wiki's "lodestone icon" sprites (THAS_SHIELD_<PLACE>) have a square
    -- background and their _ALPHA twins are plain white shapes, so not those.
    lodestone = {
        ["Al Kharid"] = { crest = 22245, locked = 23009, unlock = "THAS_ACTIVE_AL_KHARID", unlockId = -29 },   -- INSIGNIA_12
        ["Ardougne"] = { crest = 22236, locked = 23000, unlock = "THAS_ACTIVE_ARDOUGNE", unlockId = -30 },   -- INSIGNIA_3
        ["Burthorpe"] = { crest = 22238, locked = 23002, unlock = "THAS_ACTIVE_BURTHORPE", unlockId = -31 },   -- INSIGNIA_5
        ["Canifis"] = { crest = 22248, locked = 23012, unlock = "THAS_ACTIVE_CANIFIS", unlockId = -18524 },   -- INSIGNIA_15
        ["Catherby"] = { crest = 22239, locked = 23003, unlock = "THAS_ACTIVE_CATHERBY", unlockId = -32 },   -- INSIGNIA_6
        ["Draynor Village"] = { crest = 22242, locked = 23006, unlock = "THAS_ACTIVE_DRAYNOR", unlockId = -33 },   -- INSIGNIA_9
        ["Eagles' Peak"] = { crest = 22249, locked = 23013, unlock = "THAS_ACTIVE_EAGLES", unlockId = -18525 },   -- INSIGNIA_16
        ["Edgeville"] = { crest = 22244, locked = 23008, unlock = "THAS_ACTIVE_EDGEVILLE", unlockId = -34 },   -- INSIGNIA_11
        ["Falador"] = { crest = 22235, locked = 22999, unlock = "THAS_ACTIVE_FALADOR", unlockId = -35 },   -- INSIGNIA_2
        -- PLAYER_FORT_LODESTONE (in PLAYER_FORT_PERM2) read 1 on a test
        -- account that has built it (2026-10-21); one account measured.
        ["Fort Forinthry"] = { crest = 27050, locked = 27104, unlock = "PLAYER_FORT_LODESTONE", unlockId = -52519 },   -- INSIGNIA_28
        ["Fremennik Province"] = { crest = 22251, locked = 23015, unlock = "THAS_ACTIVE_FREMENNIK", unlockId = -18526 },   -- INSIGNIA_18
        ["Lumbridge"] = { crest = 22233, locked = 22997, unlock = "THAS_ACTIVE_LUMBRIDGE", unlockId = -36 },   -- INSIGNIA_0
        -- Wiki, Lunar Isle lodestone: "automatically activated when the player
        -- completes Lunar Diplomacy and cannot be activated otherwise".
        ["Lunar Isle"] = { crest = 22247, locked = 23011, unlockQuest = "Lunar Diplomacy" },   -- INSIGNIA_14
        ["Menaphos"] = { crest = 31130, locked = 31132, unlock = "THAS_ACTIVE_MENAPHOS", unlockId = -36174 },   -- INSIGNIA_26
        ["Oo'glog"] = { crest = 22250, locked = 23014, unlock = "THAS_ACTIVE_OOGLOG", unlockId = -18528 },   -- INSIGNIA_17
        ["Port Sarim"] = { crest = 22241, locked = 23005, unlock = "THAS_ACTIVE_PORT_SARIM", unlockId = -37 },   -- INSIGNIA_8
        ["Seers' Village"] = { crest = 22240, locked = 23004, unlock = "THAS_ACTIVE_SEERS", unlockId = -38 },   -- INSIGNIA_7
        ["Taverley"] = { crest = 22237, locked = 23001, unlock = "THAS_ACTIVE_TAVERLEY", unlockId = -39 },   -- INSIGNIA_4
        ["Tirannwn"] = { crest = 22253, locked = 23017, unlock = "THAS_ACTIVE_TIRRANWN", unlockId = -18529 },   -- INSIGNIA_20
        ["Varrock"] = { crest = 22234, locked = 22998, unlock = "THAS_ACTIVE_VARROCK", unlockId = -40 },   -- INSIGNIA_1
        ["Yanille"] = { crest = 22243, locked = 23007, unlock = "THAS_ACTIVE_YANILLE", unlockId = -41 },   -- INSIGNIA_10
        -- Additional locations for the nearest-unlocked fallback
        -- (data/nearlodestones.lua); not named by any start yet. Matched the
        -- same way.
        ["Anachronia"] = { crest = 1080, locked = 1082 },   -- INSIGNIA_27
        ["Ashdale"] = { crest = 22255, locked = 23019, unlock = "THAS_ACTIVE_ASHDALE", unlockId = -22431 },   -- INSIGNIA_22
        -- Wiki, Bandit Camp (Kharidian Desert): "Use the Bandit camp lodestone
        -- and run north-west (this requires completion of Desert Treasure)".
        ["Bandit Camp"] = { crest = 22246, locked = 23010, unlockQuest = "Desert Treasure" },   -- INSIGNIA_13
        ["City of Um"] = { crest = 31775, locked = 31777, unlock = "THAS_ACTIVE_CITYOFUM", unlockId = -53271 },   -- INSIGNIA_29
        ["Karamja"] = { crest = 22252, locked = 23016, unlock = "THAS_ACTIVE_KARAMJA", unlockId = -18527 },   -- INSIGNIA_19
        ["Prifddinas"] = { crest = 24249, locked = 24251, unlock = "THAS_ACTIVE_PRIFDDINAS", unlockId = -24968 },   -- INSIGNIA_23
        ["Wendlewick"] = { crest = 35675, locked = 35678, unlock = "THAS_ACTIVE_WENDLEWICK", unlockId = -60740 },   -- INSIGNIA_30
        ["Wilderness"] = { crest = 22254, locked = 23018, unlock = "THAS_ACTIVE_WILDERNESS", unlockId = -18530 },   -- INSIGNIA_21
    },
    -- Home Teleport's standard-spellbook icon, by the game's own sprite name
    -- SPELL_ICON_STANDARD_TELEPORT_HOME, recorded from the beta id.Sprite
    -- table on 2026-10-21.
    homeTeleport = 36131,
    -- Teleport spells a start's way can name ({ spell = "<name>" }):
    -- [name] = { book = "standard" | "ancient" | "lunar", level = Magic level,
    --            quest = a quest the spell itself needs, sprite = icon ID,
    --            locked = its grey icon }.
    -- Sprites: the game's own SPELL_ICON_STANDARD_TELEPORT_* (standard),
    -- SPELL_ICON_ZAROS_TELEPORT_* (Ancient) and SPELL_ICON_LUNAR_TELEPORT_*
    -- (Lunar), not the _MOBILE copies; each picture was matched to its name
    -- by eye in beta. Most Lunar teleports weren't found under those names
    -- and are not listed. Historical quest and level requirements come from
    -- each spell's own Wiki page, 2026-10-21. Entries without a level are not
    -- offered by spellReady and remain icon metadata only: unlocked by
    -- something the game can't be read for (War's Retreat, Mazcab, the
    -- achievement teleports, Max Guild), landing in the Wilderness (Dareeyak,
    -- Carrallangar, Annakarl, Ghorrock), in a dungeon (Paddewwa), or at the
    -- player's own house.
    spells = {
        ["Lumbridge Teleport"] = { book = "standard", sprite = 36135, level = 31 },
        ["Varrock Teleport"] = { book = "standard", sprite = 36137, level = 25 },
        ["Falador Teleport"] = { book = "standard", sprite = 36132, level = 37 },
        ["Camelot Teleport"] = { book = "standard", sprite = 36130, level = 45 },
        ["Ardougne Teleport"] = { book = "standard", sprite = 35028, locked = 35037, level = 51, quest = "Plague City" },
        ["Watchtower Teleport"] = { book = "standard", sprite = 35033, locked = 35041, level = 58, quest = "Watchtower" },
        ["Trollheim Teleport"] = { book = "standard", sprite = 35032, locked = 35040, level = 61, quest = "Eadgar's Ruse" },
        ["Ape Atoll Teleport"] = { book = "standard", sprite = 35027, locked = 35036, level = 64, quest = "Recipe for Disaster: Freeing King Awowogei" },
        ["God Wars Dungeon Teleport"] = { book = "standard", sprite = 35029, locked = 35038, level = 61, quest = "The Mighty Fall" },
        ["Mazcab Teleport"] = { book = "standard", sprite = 35030, locked = 35039 },
        ["Taverley Teleport"] = { book = "standard", sprite = 35031, level = 19 },
        ["Wendlewick Teleport"] = { book = "standard", sprite = 35665, locked = 35666, level = 28, quest = "Visions of Havenhythe" },
        ["South Feldip Hills Teleport"] = { book = "standard", sprite = 36136, level = 10 },
        ["House Teleport"] = { book = "standard", sprite = 36133 },
        ["Lost Grove Teleport"] = { book = "standard", sprite = 11316, level = 85 },
        ["War's Retreat Teleport"] = { book = "standard", sprite = 35042, locked = 35043 },
        ["Skeletal Horror Teleport"] = { book = "standard", sprite = 36142, locked = 36148 },
        ["Kandarin Monastery Teleport"] = { book = "standard", sprite = 36143, locked = 36149 },
        ["Manor Farm Teleport"] = { book = "standard", sprite = 36144, locked = 36150 },
        ["Max Guild Teleport"] = { book = "standard", sprite = 36145, locked = 36147 },
        ["Paddewwa Teleport"] = { book = "ancient", sprite = 36128 },
        ["Senntisten Teleport"] = { book = "ancient", sprite = 36129, level = 60 },
        ["Kharyrll Teleport"] = { book = "ancient", sprite = 36126, level = 66 },
        ["Lassar Teleport"] = { book = "ancient", sprite = 36127, level = 72 },
        ["Dareeyak Teleport"] = { book = "ancient", sprite = 36124 },
        ["Carrallangar Teleport"] = { book = "ancient", sprite = 36123 },
        ["Annakarl Teleport"] = { book = "ancient", sprite = 36122 },
        ["Ghorrock Teleport"] = { book = "ancient", sprite = 36125 },
        ["Kharazi Jungle Teleport"] = { book = "lunar", sprite = 1779, locked = 1781, level = 81, quest = "Legends' Quest" },
        ["Mountain Camp Teleport"] = { book = "lunar", sprite = 1780, level = 83 },
    },
    -- The quest that opens each spellbook; the standard book needs none.
    -- (Wiki, each spellbook's page and every spell page, 2026-10-21.)
    spellbooks = { ancient = "Desert Treasure", lunar = "Lunar Diplomacy" },
    fairyRing = 132,      -- Fairy_Ring_map_icon.png
    transport = 20764,    -- Transportation_map_icon.png (spirit tree, magic carpet)
    source = W,
}
