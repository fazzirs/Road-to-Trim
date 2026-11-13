-- data/steps.lua
-- Static route entries, with a small pure helper (quest(), below) that
-- supplies common quest fields. No game API or persistence.
--
-- Quests are named by their in-game display name ("Lunar Diplomacy"). The
-- plugin resolves names to the game's config at runtime, and reads each
-- quest's skill and quest prerequisites from the game itself. So a quest step
-- only needs: id, phase, title, quest, and what the game doesn't track:
-- required items (by wiki item ID), route ordering (requires.steps), what it
-- unlocks, and per-mode advice.
--
-- Route field reference, consumed by core/planner.lua and main.lua:
--   id          unique string
--   phase       1-47, used for ordering and progress
--   title       what the player sees
--   type        "quest" | "skill" | "achievement" | "unlock"
--   quest       quest display name, for type = quest
--   skill/level skill name + target, for type = skill (rare: training is
--               normally derived from the quest that needs it)
--   achievement achievement display name, for type = achievement
--   modes       which account modes this applies to; omit for all
--   requires    { skills = {name = level}, combat = level, quests = {display name},
--                 steps = {id}, items = {{id | ids, count, name, how}} }
--               item id = the number on the item's wiki page
--   unlocks     ids or labels this opens (counts toward the unlock score)
--   methods     per-mode route advice; the account mode can also affect
--               item acquisition hints elsewhere (core/views.lua itemHint)
--   trimReq     true when it's on the Trim checklist itself
--   wiki        link for the "how"
--
-- Phase 1-2 order follows the early Ironman route; the exact lists come from
-- the RuneScape Wiki as of 19 October 2026. Phases 4 (Morytania), 5
-- (gnome and fairy travel), 6 (Ape Atoll, the way to the elves) and 7 (the
-- elves after Regicide, the balloons), 8 (Rimmington, Port Sarim and
-- Draynor), 9 (Varrock, Lumbridge and Edgeville) and 10 (Falador, Taverley
-- and Al Kharid) as of 20 October 2026; 11 (free quests with 30+ skills, the
-- free saga), 12 (Kandarin novice quests), 13 (Wendlewick and Havenhythe)
-- 14 (Temple Knights), 15 (Kharidian Desert I), 16 (Lumbridge and Varrock,
-- members), 17 (Keldagrim and Dorgesh-Kaan), 18 (Morytania I, Rum Deal) and
-- 19 (Elder God Wars I, Anachronia), 20 (Fremennik Province I), 21
-- (Karamja and Feldip), 22 (Kandarin II), 23 (Varrock, members, II), 24
-- (Fort Forinthry), 25 (Legacy of Zamorak and Summer), 26 (Trolls and the
-- Fremennik Isles), 27 (City of Um), 28 (Heroes, Legends and early Mahjarrat)
-- 29 (Penguins, gnomes and fairies), 30 (Sliske's Game opening and Mos
-- Le'Harmless), 31 (Kharidian Desert II), 32 (Daemonheim and the sagas) and 33
-- (Doric's and Boric's later tasks, and the Thieves' Guild), 34 (The elves and
-- East Ardougne), 35 (Piscatoris, the Wise Old Man and Rellekka), 36 (Red Axe
-- dwarves and the Myreque) and 37 (Desert Treasure, Recipe for Disaster and
-- Dimension of Disaster), 38 (Senliten's tomb to Menaphos, and the Void
-- Knights), 39 (Elder God Wars II and Anachronia) and 40 (The First Necromancer,
-- Fort Forinthry II and Menaphos), 41 (TzHaar and the end of the Elder God
-- Wars), 42 (Mahjarrat III), 43 (Grandmaster odds and ends), 44 (Tales of the
-- Arc I), 45 (Tales of the Arc II), 46 (Sliske's Game II) and 47 (Nomad and
-- Sliske's Endgame) as of 21 October 2026.

local W = "https://runescape.wiki/w/"

-- Small helper so the early quests stay one line each.
local function quest(id, phase, name, extra)
    local s = { id = id, phase = phase, title = "Complete " .. name, type = "quest", quest = name,
                trimReq = true, wiki = W .. name:gsub(" ", "_") }
    for k, v in pairs(extra or {}) do s[k] = v end
    return s
end

return {
    ---------------------------------------------------------------------------
    -- Phase 1: Lumbridge and the free-to-play starters. No requirements, lots
    -- of XP, and they open lodestones, Necromancy and the Lumbridge area.
    ---------------------------------------------------------------------------
    quest("q-blood-pact", 1, "The Blood Pact", { unlocks = { "lumbridge-catacombs" } }),
    quest("q-cooks-assistant", 1, "Cook's Assistant", { unlocks = { "lumbridge-range" } }),
    quest("q-buyers-and-cellars", 1, "Buyers and Cellars", { unlocks = { "thieves-guild" } }),
    quest("q-restless-ghost", 1, "The Restless Ghost", { unlocks = { "ghostspeak-amulet" } }),
    quest("q-necromancy", 1, "Necromancy!", { unlocks = { "city-of-um", "necromancy-skill" } }),
    quest("q-ernest-the-chicken", 1, "Ernest the Chicken"),
    quest("q-impressing-the-locals", 1, "Impressing the Locals", { unlocks = { "shattered-worlds", "port-sarim" } }),
    quest("q-shadow-over-ashdale", 1, "A Shadow over Ashdale", { unlocks = { "ashdale-lodestone" } }),
    quest("q-death-plateau", 1, "Death Plateau", { unlocks = { "burthorpe", "dwarven-army-axe" } }),
    quest("q-let-them-eat-pie", 1, "Let Them Eat Pie"),
    quest("q-wolf-whistle", 1, "Wolf Whistle", { unlocks = { "summoning" } }),
    quest("q-druidic-ritual", 1, "Druidic Ritual", { unlocks = { "herblore" } }),
    quest("q-violet-is-blue", 1, "Violet is Blue"),
    quest("q-rune-mysteries", 1, "Rune Mysteries", { unlocks = { "runecrafting", "q-rune-memories" } }),
    quest("q-rune-memories", 1, "Rune Memories", { requires = { steps = { "q-rune-mysteries" } } }),
    quest("q-imp-catcher", 1, "Imp Catcher"),
    quest("q-demon-slayer", 1, "Demon Slayer"),
    quest("q-goblin-diplomacy", 1, "Goblin Diplomacy"),
    quest("q-gertrudes-cat", 1, "Gertrude's Cat", { unlocks = { "kitten" } }),
    quest("q-vampyre-slayer", 1, "Vampyre Slayer"),
    quest("q-myths-of-the-white-lands", 1, "Myths of the White Lands", { unlocks = { "explorers-ring" } }),

    ---------------------------------------------------------------------------
    -- Phase 2: early members quests that open regions and the mid-game chains.
    ---------------------------------------------------------------------------
    quest("q-priest-in-peril", 2, "Priest in Peril", { unlocks = { "morytania", "canifis-lodestone" } }),
    quest("q-waterfall-quest", 2, "Waterfall Quest", { unlocks = { "big-attack-strength-xp" } }),
    quest("q-tree-gnome-village", 2, "Tree Gnome Village", { unlocks = { "spirit-trees" } }),
    quest("q-fight-arena", 2, "Fight Arena"),
    quest("q-merlins-crystal", 2, "Merlin's Crystal", { unlocks = { "q-holy-grail", "excalibur" } }),
    quest("q-holy-grail", 2, "Holy Grail", { requires = { steps = { "q-merlins-crystal" } } }),
    quest("q-dragon-slayer", 2, "Dragon Slayer", { unlocks = { "rune-platebody" } }),
    quest("q-lost-city", 2, "Lost City", {
        unlocks = { "zanaris", "dramen-staff", "cosmic-runes", "q-lunar-diplomacy" },
        methods = {
            ironman = "Fight the Dramen tree spirit (level 63) with gear made on Entrana, or a hatchet taken off the tool belt",
            main = "Fight the Dramen tree spirit (level 63) with gear made on Entrana, or a hatchet taken off the tool belt; bring food and prayer potions if low level",
        },
    }),
    quest("q-fremennik-trials", 2, "The Fremennik Trials", {
        requires = {
            items = {
                { id = 383, name = "Raw shark (or raw manta ray / sea turtle)", count = 1,
                  how = "Ironman: 68 Fishing at the Deep Sea Fishing hub, 32 Slayer (Mogres), 72 Thieving (Ardougne chests), or Temple Trekking after In Aid of the Myreque" },
                { id = 995, name = "Coins", count = 5250, how = "Any money-making; sell Pyramid Plunder loot or drops to shops" },
            },
        },
        unlocks = { "rellekka", "waterbirth", "enchanted-lyre", "q-lunar-diplomacy" },
    }),

    ---------------------------------------------------------------------------
    -- Phase 3: the Lunar chain and desert quests.
    ---------------------------------------------------------------------------
    quest("q-lunar-diplomacy", 3, "Lunar Diplomacy", {
        requires = {
            steps = { "q-fremennik-trials", "q-lost-city" },
            items = {
                { id = 772, name = "Dramen staff", count = 1, how = "Use a knife on a dramen branch from Entrana (31 Crafting, Lost City)" },
                { id = 952, name = "Spade", count = 1, how = "Buy from a Farming shop; the tool belt one doesn't count" },
                -- List only items the player must bring; guam, marrentill and thread
                -- can be got in the quest, so they belong in the tip, not here.
            },
        },
        unlocks = { "lunar-spellbook", "q-dream-mentor", "ach-easy-as-pie", "ach-runes-on-the-moon", "ach-out-into-the-ourania" },
        -- Talismans aren't item checks: a wicked hood or the Abyss gets you to
        -- the altars just as well (wiki).
        methods = {
            ironman = "Air, earth, fire and water altars: talismans, tiaras, a wicked hood or the Abyss all work. Bring about 1,000 coins and combat runes; you can't wield an elemental staff. Thread and herbs can be got in the quest",
            main = "Air, earth, fire and water altars: talismans or tiaras from the Grand Exchange, a wicked hood or the Abyss all work. Bring about 1,000 coins and combat runes; you can't wield an elemental staff. Thread and herbs can be got in the quest",
        },
    }),
    {
        id = "ach-easy-as-pie", phase = 3,
        title = "Easy As Pie: bake a pie with the Bake Pie spell",
        type = "achievement", achievement = "Easy As Pie",
        requires = { steps = { "q-lunar-diplomacy" } },
        trimReq = true, wiki = W .. "Easy_As_Pie",
    },
    {
        id = "ach-runes-on-the-moon", phase = 3,
        title = "Runes on the Moon: mine pure essence on Lunar Isle",
        type = "achievement", achievement = "Runes on the Moon",
        requires = { steps = { "q-lunar-diplomacy" } },
        trimReq = true, wiki = W .. "Runes_on_the_Moon",
    },
    quest("q-dream-mentor", 3, "Dream Mentor", {
        requires = {
            steps = { "q-lunar-diplomacy" },
            items = { { id = 9075, name = "Astral rune", count = 1, how = "Trade Baba Yaga on Lunar Isle, or craft at the astral altar" } },
        },
        unlocks = { "lunar-spells-9", "npc-contact-random" },
        methods = {
            ironman = "Bring 20 food of 3 kinds (6 + 7 + 7); cakes work for all three",
            main = "Bring 20 food of 3 kinds (6 + 7 + 7); cakes work for all three, so buy 20 cakes",
        },
    }),
    quest("q-in-pyre-need", 3, "In Pyre Need", { unlocks = { "phoenix-lair", "ach-arise-from-the-ash" } }),
    {
        id = "ach-arise-from-the-ash", phase = 3,
        title = "Arise from the Ash: defeat the phoenix after In Pyre Need",
        type = "achievement", achievement = "Arise from the Ash",
        requires = { skills = { slayer = 51 }, steps = { "q-in-pyre-need" } },
        trimReq = true, wiki = W .. "Arise_from_the_Ash",
    },
    -- The chain into Dealing with Scabaras (wiki, 20 October 2026): Stolen
    -- Hearts -> Diamond in the Rough -> Icthlarin's Little Helper (also
    -- Gertrude's Cat, phase 1) -> Contact!. The game supplies these
    -- prerequisites; the tips are shown in every account mode.
    quest("q-stolen-hearts", 3, "Stolen Hearts"),
    quest("q-diamond-in-the-rough", 3, "Diamond in the Rough"),
    quest("q-icthlarins-little-helper", 3, "Icthlarin's Little Helper", {
        requires = {
            items = {
                { id = 1519, name = "Willow logs", count = 1, how = "Cut a willow tree (20 Woodcutting)" },
                { id = 4687, name = "Bucket of sap", count = 1, how = "Use a knife on an evergreen with an empty bucket in your backpack; trees are just north of Falador lodestone" },
            },
        },
        unlocks = { "sophanem", "pyramid-plunder" },
        methods = {
            ironman = "Bring your cat or kitten from Gertrude's Cat (any cat works) and a salt shaker (the tool belt one works). Linen can be bought in the quest for 30 coins. The Possessed Priest is level 56",
        },
    }),
    quest("q-contact", 3, "Contact!", {
        unlocks = { "sophanem-bank", "keris" },
        methods = {
            ironman = "Bring a light source (a torch can be got in the quest). The giant scarab is level 86: bring food and antipoison; 43 Prayer helps",
        },
    }),
    quest("q-dealing-with-scabaras", 3, "Dealing with Scabaras", {
        requires = {
            items = {
                { id = 4601, name = "Bucket of Ugthanki dung", count = 1, how = "Use red hot sauce on the camel trough in Pollnivneach, then collect the dung in a bucket" },
                { id = 6970, name = "Pyramid top", count = 1, how = "Reach the top of the Agility Pyramid once" },
                { ids = { 9032, 9034, 9042, 9036, 9038, 9040 }, name = "Gold artefacts from Pyramid Plunder (any mix of 10)", count = 10,
                  how = "Pyramid Plunder in Sophanem; keep them unnoted" },
            },
        },
        unlocks = { "enchanted-water-tiara", "simon-templeton-notes" },
        methods = {
            ironman = "Make the bronze items yourself (up to 36) or buy them from Horvik; bring high-healing food",
            main = "Buy the bronze items; bring high-healing food",
        },
    }),

    ---------------------------------------------------------------------------
    -- Phase 4: Morytania. Outside this phase the quests here need only
    -- Priest in Peril, The Restless Ghost and Ernest the Chicken (phases 1-2);
    -- the Myreque pair also needs Nature Spirit, then In Search of the Myreque,
    -- from earlier in this phase. The game supplies all of those
    -- prerequisites. Opens Mort Myre, the ectophial teleport, Ava's device,
    -- Burgh de Rott and Temple Trekking. Requirements and item IDs
    -- from the RuneScape Wiki as of 20 October 2026. The ghostspeak amulet is
    -- left out of the item lists: it's worn, and only the backpack and bank
    -- are counted.
    ---------------------------------------------------------------------------
    quest("q-nature-spirit", 4, "Nature Spirit", {
        unlocks = { "mort-myre", "barrows", "altar-of-nature", "silver-sickle" },
        methods = {
            ironman = "Wear the ghostspeak amulet. Filliman lets you craft the silver sickle partway through: 18 Crafting, and a silver bar (20 Mining or 22 Divination, 20 Smithing)",
            main = "Wear the ghostspeak amulet; buy a silver sickle on the Grand Exchange",
        },
    }),
    quest("q-ghosts-ahoy", 4, "Ghosts Ahoy", {
        requires = {
            items = {
                { id = 952, name = "Spade", count = 1, how = "Buy from a Farming shop; the tool belt one doesn't count" },
                { id = 845, name = "Oak longbow", count = 1, how = "Fletch one at 15 Fletching, or a Ranged shop" },
                { id = 1734, name = "Thread", count = 1, how = "Crafting shop (Fidelio in Canifis, Dommik in Al Kharid), or the Jolly Boar Inn spawn" },
                { id = 950, name = "Silk", count = 1, how = "Silk trader in Al Kharid, or steal from a silk stall (20 Thieving)" },
                { id = 1927, name = "Bucket of milk", count = 1, how = "Milk a dairy cow with a bucket" },
            },
        },
        unlocks = { "ectophial", "port-phasmatys" },
        methods = {
            ironman = "Wear the ghostspeak amulet. Also bring nettle tea (or a bowl of water and gloves to brew it), 3 each of red, blue and yellow dye, about 1,000 coins, and 2 ecto-tokens per walk into Port Phasmatys",
            main = "Wear the ghostspeak amulet. Buy 3 each of red, blue and yellow dye; nettle tea doesn't trade, so brew it. Bring about 1,000 coins",
        },
    }),
    quest("q-creature-of-fenkenstrain", 4, "Creature of Fenkenstrain", {
        requires = {
            items = {
                { id = 1794, name = "Bronze wire", count = 3, how = "Smith from bronze bars (1 Smithing)" },
                { id = 1733, name = "Needle", count = 1, how = "Crafting shop; the tool belt and dwarven army axe needles don't count" },
                { id = 1734, name = "Thread", count = 5, how = "Crafting shop (Fidelio in Canifis, Dommik in Al Kharid), or the Jolly Boar Inn spawn" },
            },
        },
        unlocks = { "ring-of-charos", "werewolf-agility-course" },
        methods = {
            ironman = "Wear the ghostspeak amulet. Bring a silver bar (the metal bank works; 20 Mining and 20 Smithing) and 50 coins or Telekinetic Grab runes",
            main = "Wear the ghostspeak amulet. Bring a silver bar and 50 coins or Telekinetic Grab runes",
        },
    }),
    quest("q-animal-magnetism", 4, "Animal Magnetism", {
        requires = {
            items = {
                { id = 1355, name = "Mithril hatchet", count = 1, how = "Smith a mithril bar at an anvil (30 Smithing); bring a real hatchet, not the tool belt's, to make the blessed hatchet" },
                { id = 2351, name = "Iron bar", count = 5, how = "Smelt iron ore (10 Smithing); unnoted" },
                { id = 1718, name = "Holy symbol", count = 1, how = "1. Cast a silver bar with a holy mould (16 Crafting).\n2. String the symbol with a ball of wool.\n3. Ask Brother Jered upstairs in Edgeville Monastery to bless it (31 Prayer)." },
                { id = 10496, name = "Polished buttons", count = 1, how = "Get buttons from H.A.M. guards, H.A.M. members or the Dig Site, then polish them" },
                { id = 1743, name = "Hard leather", count = 1, how = "A tanner turns a cowhide into hard leather for 3 coins" },
                { id = 4278, name = "Ecto-token", count = 20, how = "Worship at the Ectofuntus: 5 tokens each time" },
            },
        },
        unlocks = { "avas-device", "blessed-hatchet" },
        methods = {
            ironman = "Wear the ghostspeak amulet (the hard Morytania achievement reward one doesn't work)",
            main = "Wear the ghostspeak amulet (the hard Morytania achievement reward one doesn't work); buy the bars, hatchet and leather on the Grand Exchange",
        },
    }),
    quest("q-in-search-of-the-myreque", 4, "In Search of the Myreque", {
        requires = {
            items = {
                { id = 45441, name = "Steel dagger", count = 1, how = "Smith 2 steel bars per weapon at a forge and anvil (20 Smithing); not +1 or off-hand" },
                { id = 45443, name = "Steel mace", count = 1, how = "Smith 2 steel bars per weapon at a forge and anvil (20 Smithing); not +1 or off-hand" },
                { id = 45445, name = "Steel sword", count = 2, how = "Smith 2 steel bars per weapon at a forge and anvil (20 Smithing); not +1 or off-hand" },
                { id = 45449, name = "Steel longsword", count = 1, how = "Smith 2 steel bars per weapon at a forge and anvil (20 Smithing); not +1 or off-hand" },
                { id = 45451, name = "Steel warhammer", count = 1, how = "Smith 2 steel bars per weapon at a forge and anvil (20 Smithing); not +1 or off-hand" },
                { id = 1539, name = "Steel nails", count = 75, how = "Smith 75 from one steel bar (20 Smithing)" },
                { id = 960, name = "Plank", count = 6, how = "Turn normal logs into planks at a sawmill; protean planks don't work" },
            },
        },
        unlocks = { "mortton-swamp-boat", "myreque-hideout" },
        methods = {
            ironman = "Bring a druid pouch with at least 5 charges; fill it with the blessed silver sickle from Nature Spirit",
            main = "Bring a druid pouch with at least 5 charges; fill it with the blessed silver sickle from Nature Spirit. Buy the steel weapons, nails and planks",
        },
    }),
    quest("q-in-aid-of-the-myreque", 4, "In Aid of the Myreque", {
        unlocks = { "burgh-de-rott", "temple-trekking" },
        methods = {
            ironman = "Bring a silver weapon (not silver bolts or havensilver) and armour for vampyres up to level 68, 10 bronze hatchets, 2 steel bars and a coal; a mithril bar for the rod needs 30 Mining and 30 Smithing. Planks, nails, buckets and food can be found during the quest",
            main = "Bring a silver weapon (not silver bolts or havensilver) and armour for vampyres up to level 68, 10 bronze hatchets, 2 steel bars and a coal; a mithril bar for the rod needs 30 Mining and 30 Smithing. Planks, nails, buckets and food can be found during the quest; buy what you don't have",
        },
    }),

    ---------------------------------------------------------------------------
    -- Phase 5: gnome and fairy travel. Ardougne teleport and West Ardougne,
    -- gnome gliders and the whole spirit tree network, eagle transport, the
    -- crystal saw and singing bowls, then the fairy ring network. Outside this
    -- phase they need only Lost City, Nature Spirit, Priest in Peril and The
    -- Restless Ghost (earlier phases); The Eyes of Glouphrie needs The Grand
    -- Tree and Fairy Tale II needs Fairy Tale I, from this phase. The game
    -- supplies all prerequisites and levels. Items and IDs from the RuneScape
    -- Wiki as of 20 October 2026. The
    -- dramen or lunar staff is wielded and Eagles' Peak's coins may sit in the
    -- money pouch, so they're in the tips, not the item lists (only the
    -- backpack and bank are counted). Tips name what to bring, never how to
    -- fight a boss: tips describe preparation; Quest Helper and the Wiki
    -- supply the walkthrough.
    ---------------------------------------------------------------------------
    quest("q-plague-city", 5, "Plague City", {
        requires = {
            items = {
                { id = 2126, name = "Dwellberries", count = 1, how = "Spawns in McGrubor's Wood (guard dogs inside), or grow them at 36 Farming" },
                { id = 954, name = "Rope", count = 1, how = "Ned in Draynor Village, for 15 coins or 4 balls of wool" },
                { id = 1975, name = "Chocolate dust", count = 1, how = "Grind a chocolate bar with a knife or pestle and mortar; bars spawn in Zanaris and the Cooking Guild (32 Cooking)" },
                { id = 231, name = "Snape grass", count = 1, how = "Spawns on Hobgoblin Peninsula" },
                { id = 1927, name = "Bucket of milk", count = 1, how = "Milk a dairy cow with a bucket" },
            },
        },
        unlocks = { "ardougne-teleport", "west-ardougne" },
        methods = {
            ironman = "No fighting. 4 buckets of water are got during the quest. The scroll at the end unlocks Ardougne Teleport (51 Magic)",
            main = "No fighting; buy the dwellberries, snape grass and chocolate. 4 buckets of water are got during the quest. The scroll at the end unlocks Ardougne Teleport (51 Magic)",
        },
    }),
    quest("q-fairy-tale-1", 5, "A Fairy Tale I - Growing Pains", {
        unlocks = { "magic-secateurs" },
        methods = {
            ironman = "1. Wield a dramen or lunar staff.\n2. Secateurs (not the tool belt's) are got during the quest from Vanessa in Catherby.\n3. You'll need 3 or 4 items from a random list (your quest journal shows yours); some, like dragon bones, blue dragon scales or rare herbs, take a while.\n4. Bring combat gear and food for a fight",
            main = "Wield a dramen or lunar staff. Secateurs (not the tool belt's) are got during the quest from Vanessa in Catherby. Buy the 3 or 4 random items your quest journal lists. Bring combat gear and food for a fight",
        },
    }),
    quest("q-grand-tree", 5, "The Grand Tree", {
        unlocks = { "gnome-gliders", "spirit-tree-network" },
        methods = {
            ironman = "No items needed. Bring combat gear and food for a demon at the end, and a teleport out",
            main = "No items needed. Bring combat gear and food for a demon at the end, and a teleport out",
        },
    }),
    quest("q-eagles-peak", 5, "Eagles' Peak", {
        requires = {
            items = {
                { id = 1765, name = "Yellow dye", count = 1, how = "Aggie in Draynor Village: 2 onions and 5 coins" },
                { id = 1939, name = "Swamp tar", count = 1, how = "Spawns in Lumbridge Swamp" },
            },
        },
        unlocks = { "eagle-transport" },
        methods = {
            ironman = "Also bring 50 coins. Hardly any fighting",
            main = "Also bring 50 coins; buy the dye and tar. Hardly any fighting",
        },
    }),
    quest("q-eyes-of-glouphrie", 5, "The Eyes of Glouphrie", {
        requires = {
            items = {
                { id = 9594, name = "Ground mud runes", count = 1, how = "Grind a mud rune with a pestle and mortar; mud runes need 13 Runecrafting" },
                { id = 1517, name = "Maple logs", count = 1, how = "Cut a maple tree (40 Woodcutting)" },
                { id = 1521, name = "Oak logs", count = 1, how = "Cut an oak tree" },
                { id = 4687, name = "Bucket of sap", count = 1, how = "Use a bucket on an evergreen tree, with a knife on the tool belt (evergreens north of the Falador lodestone)" },
            },
        },
        unlocks = { "crystal-saw", "singing-bowls" },
        methods = {
            ironman = "Bring a ranged or magic weapon for a few weak creatures",
            main = "Bring a ranged or magic weapon for a few weak creatures; buy the logs and a mud rune",
        },
    }),
    quest("q-fairy-tale-2", 5, "A Fairy Tale II - Cure a Queen", {
        requires = {
            items = {
                { id = 227, name = "Vial of water", count = 1, how = "Fill a vial at a fountain or sink; ordinary wells do not work" },
            },
        },
        unlocks = { "fairy-rings" },
        methods = {
            ironman = "Wield a dramen or lunar staff. Fairy rings open once you've started this quest and the Fairy Godfather gives permission (wiki); finishing it is the step. Bring combat gear and food",
            main = "Wield a dramen or lunar staff. Fairy rings open once you've started this quest and the Fairy Godfather gives permission (wiki); finishing it is the step. Bring combat gear and food",
        },
    }),

    ---------------------------------------------------------------------------
    -- Phase 6: Ape Atoll and the way to the elves. Monkey Madness (Ape Atoll,
    -- the dragon scimitar), Biohazard (the West Ardougne gate), Underground
    -- Pass, the two Elemental Workshops, then Regicide (the Tirannwn lodestone
    -- and Port Tyras charters). Outside this phase they need only The Grand
    -- Tree, Tree Gnome Village and Plague City (earlier phases). The game
    -- supplies all prerequisites and levels. Items and IDs from the RuneScape
    -- Wiki as of 20 October 2026; "a
    -- few" of something goes in the tip. Tips say what to bring, never how to
    -- fight or do the quest: quest advice stays a reference, not an
    -- automated action.
    ---------------------------------------------------------------------------
    quest("q-monkey-madness", 6, "Monkey Madness", {
        requires = {
            items = {
                { id = 2357, name = "Gold bar", count = 1, how = "Smelt gold ore at a furnace" },
                { id = 1759, name = "Ball of wool", count = 1, how = "Spin wool on a spinning wheel" },
                { id = 3183, ids = { 3183, 3166, 4034 }, name = "Monkey bones", count = 1,
                  how = "From a monkey on Karamja (they always drop them); a monkey corpse or skull works too, monkey zombies' bones don't" },
            },
        },
        unlocks = { "ape-atoll", "dragon-scimitar" },
        methods = {
            ironman = "A very long quest. 5 bananas are got during the quest on Ape Atoll. Bring combat gear and food for a demon, and antipoison",
            main = "A very long quest. 5 bananas are got during the quest on Ape Atoll. Bring combat gear and food for a demon, and antipoison",
        },
    }),
    quest("q-biohazard", 6, "Biohazard", {
        requires = {
            items = {
                { id = 426, name = "Priest gown (top)", count = 1, how = "Buy from Thessalia's Fine Clothes in Varrock" },
                { id = 428, name = "Priest gown (bottom)", count = 1, how = "Buy from Thessalia's Fine Clothes in Varrock" },
            },
        },
        unlocks = { "west-ardougne-gate" },
        methods = {
            ironman = "Only one easy fight; bring some food",
            main = "Only one easy fight; bring some food",
        },
    }),
    quest("q-underground-pass", 6, "Underground Pass", {
        wiki = W .. "Underground_Pass_(quest)",
        requires = {
            items = {
                { id = 954, name = "Rope", count = 1, how = "West Ardougne general store or Aemad's in East Ardougne; bring a second" },
                -- Any shortbow or longbow (plain, oak, willow, maple, yew, magic);
                -- alternative IDs from historical Wiki infobox research; chargebows
                -- are excluded.
                { id = 841, ids = { 841, 843, 849, 853, 857, 861, 839, 845, 847, 851, 855, 859 }, name = "Any shortbow or longbow", count = 1,
                  how = "Not a chargebow; Gulluck and Sons at the Grand Tree sell shortbows" },
            },
        },
        unlocks = { "regicide-path" },
        methods = {
            ironman = "Also a few arrows (any metal). Hard fights around level 80: combat gear, food and an emergency teleport. No pets or followers",
            main = "Also a few arrows (any metal). Hard fights around level 80: combat gear, food and an emergency teleport. No pets or followers",
        },
    }),
    quest("q-elemental-workshop-1", 6, "Elemental Workshop I", {
        requires = {
            items = {
                { id = 1734, name = "Thread", count = 1, how = "Crafting shop (Dommik in Al Kharid, Fancy Clothes Store in Varrock)" },
                { id = 453, name = "Coal", count = 4, how = "Mine coal" },
            },
        },
        unlocks = { "elemental-workshop" },
        methods = {
            ironman = "Leather is got during the quest from a crate in the workshop. One fight with an earth elemental; no familiars. Turn off the Sign of the porter, or the ore goes to the bank",
            main = "Leather is got during the quest from a crate in the workshop. One fight with an earth elemental; no familiars. Turn off the Sign of the porter, or the ore goes to the bank",
        },
    }),
    quest("q-elemental-workshop-2", 6, "Elemental Workshop II", {
        requires = {
            items = {
                { id = 453, name = "Coal", count = 8, how = "Mine coal; 12 to also make a mind shield" },
                { id = 2887, name = "Battered key", count = 1, how = "From Elemental Workshop I; a spare is in the bookcase just south of the workshop" },
            },
        },
        unlocks = { "mind-helmet" },
        methods = {
            ironman = "A few earth elemental fights",
            main = "A few earth elemental fights",
        },
    }),
    quest("q-regicide", 6, "Regicide", {
        requires = {
            items = {
                { id = 954, name = "Rope", count = 1, how = "Get rope from Ned in Draynor Village; for going back through the Underground Pass; bring spares" },
                { id = 841, ids = { 841, 843, 849, 853, 857, 861, 839, 845, 847, 851, 855, 859 }, name = "Any shortbow or longbow", count = 1, how = "Fletch logs and a bowstring (1 Fletching); not a chargebow, for the Underground Pass again" },
                { id = 3211, name = "Limestone", count = 1, how = "Mine it near Paterdomus (10 Mining), or Razmire in Mort'ton; not limestone brick" },
                { id = 453, name = "Coal", count = 6, how = "Mine coal; up to 30 may be needed, not in an ore box" },
                { id = 1931, name = "Empty pot", count = 1, how = "Rimmington general store, or found in the elf camp" },
                { id = 3224, name = "Strip of cloth", count = 1, how = "2 balls of wool on a loom" },
                { id = 3228, name = "Cooked rabbit", count = 1, how = "Kill a rabbit in Tirannwn and cook it, or raw rabbit from a charter trader" },
            },
        },
        unlocks = { "tirannwn-lodestone", "port-tyras" },
        methods = {
            ironman = "Starts with a message from King Lathas's messenger some time after Underground Pass. Also a few arrows and a pestle and mortar. 56 Agility can be boosted. Activate the Tirannwn lodestone when you reach it",
            main = "Starts with a message from King Lathas's messenger some time after Underground Pass. Also a few arrows and a pestle and mortar; about 6,400 coins for charters. 56 Agility can be boosted. Activate the Tirannwn lodestone when you reach it",
        },
    }),

    ---------------------------------------------------------------------------
    -- Phase 7: the elves after Regicide, and the balloons. Sheep Herder and
    -- Big Chompy Bird Hunting (both needed for Mourning's End Part I), Roving
    -- Elves, Mourning's End Part I (Lletya, its bank, the crystal teleport
    -- seed), Catapult Construction (needed later for Plague's End), then
    -- Enlightened Journey (the balloon network). Outside this phase they need
    -- only Regicide and Waterfall Quest (earlier phases). The game supplies all
    -- prerequisites and levels. Items and IDs from the RuneScape Wiki as of
    -- 20 October 2026. Items got during
    -- a quest are in its tip, not the list, so they don't hold the step back.
    -- Tips describe preparation (what to bring) rather than a walkthrough.
    ---------------------------------------------------------------------------
    quest("q-sheep-herder", 7, "Sheep Herder", {
        methods = {
            ironman = "Bring 100 coins (paid back at the end). No fighting needed",
            main = "Bring 100 coins (paid back at the end). No fighting needed",
        },
    }),
    quest("q-big-chompy", 7, "Big Chompy Bird Hunting", {
        methods = {
            ironman = "Bring plenty of feathers (100 to be safe; 25 can be bought in Rantz's cave). Wolf bones and achey logs are got during the quest. Don't wear magic or melee armour for the chompy",
            main = "Bring plenty of feathers (100 to be safe; 25 can be bought in Rantz's cave). Wolf bones and achey logs are got during the quest. Don't wear magic or melee armour for the chompy",
        },
    }),
    quest("q-roving-elves", 7, "Roving Elves", {
        requires = {
            items = {
                { id = 954, name = "Rope", count = 1, how = "Not needed if you've built a rope rack; Aemad's in East Ardougne sells it" },
            },
        },
        methods = {
            ironman = "Master difficulty. Glarial's pebble, the key and Glarial's amulet are got during the quest (Golrie gives the pebble back). One fight with no weapons, armour or runes allowed",
            main = "Master difficulty. Glarial's pebble, the key and Glarial's amulet are got during the quest (Golrie gives the pebble back). One fight with no weapons, armour or runes allowed",
        },
    }),
    quest("q-mournings-end-1", 7, "Mourning's End Part I", {
        requires = {
            items = {
                { id = 950, name = "Silk", count = 2, how = "Silk trader in Al Kharid, or steal from a silk stall (20 Thieving); 4 if you'll do Within the Light" },
                { id = 1929, name = "Bucket of water", count = 1, how = "Fill a bucket at a water source" },
                { id = 314, name = "Feather", count = 1, how = "Fishing shops, or from chickens" },
                { id = 1741, name = "Leather", count = 1, how = "A tanner turns a cowhide into leather" },
                { id = 2217, ids = { 2217, 2243 }, name = "Toad crunchies", count = 1,
                  how = "Gnome cooking (10 Cooking), or premade from the gnome waiter in the Grand Tree; bring extras" },
                { id = 6332, name = "Mahogany log", count = 1, how = "Cut a mahogany tree (60 Woodcutting, boostable), or from Managing Miscellania" },
                { id = 3221, name = "Barrel of naphtha", count = 1,
                  how = "1. Fill a barrel with tar south of the Tirannwn lodestone.\n2. Take it to the still outside the Chemist's House in Rimmington.\n3. Distil it with coal; bring 6 or more coal." },
            },
        },
        unlocks = { "lletya", "crystal-teleport-seed" },
        methods = {
            ironman = "Master difficulty. Bear fur, the four dyes, a rotten apple, an empty barrel and the ogre bellows are got during the quest (Oronwen in Lletya sells dyes). A fight with a mourner around level 80",
            main = "Master difficulty. Bear fur, the four dyes, a rotten apple, an empty barrel and the ogre bellows are got during the quest (Oronwen in Lletya sells dyes). A fight with a mourner around level 80",
        },
    }),
    quest("q-catapult-construction", 7, "Catapult Construction", {
        requires = {
            items = {
                -- Mithril nails "or better" (wiki): mithril, adamant and rune nails.
                { id = 4822, ids = { 4822, 4823, 4824 }, name = "Mithril nails (or better)", count = 90,
                  how = "75 nails per mithril bar (30 Smithing); also found in rubble in In Aid of the Myreque" },
                { id = 8782, name = "Mahogany plank", count = 10, how = "Mahogany logs (60 Woodcutting) at a sawmill, or 10 from Carnillean Rising; protean planks don't work" },
            },
        },
        methods = {
            ironman = "Master difficulty, no fighting. The catapult parts and a sailor's hat are got during the quest",
            main = "Master difficulty, no fighting. The catapult parts and a sailor's hat are got during the quest",
        },
    }),
    quest("q-enlightened-journey", 7, "Enlightened Journey", {
        requires = {
            items = {
                { id = 970, name = "Papyrus", count = 3, how = "Aemad's in East Ardougne or Ali's in Al Kharid, 10 coins" },
                { id = 1759, name = "Ball of wool", count = 1, how = "Spin wool on a spinning wheel" },
                { id = 1765, name = "Yellow dye", count = 1, how = "Aggie in Draynor Village: 2 onions and 5 coins" },
                { id = 1763, name = "Red dye", count = 1, how = "Aggie in Draynor Village: 3 redberries and 5 coins" },
                { id = 5418, name = "Empty sack", count = 9, how = "Head Farmer Jones in Taverley, or Alice at the Port Phasmatys farm; 1 for the potatoes, 8 filled with sand during the quest" },
                { id = 950, name = "Silk", count = 10, how = "Silk trader in Al Kharid, or steal from a silk stall (20 Thieving)" },
            },
        },
        unlocks = { "balloon-transport" },
        methods = {
            ironman = "Entrana: no weapons or armour. 12 willow branches: grow the sapling Auguste gives you (a willow takes 4 hours; secateurs), so start, plant it, and finish later. 10 logs, a candle (20 Thieving in the Entrana church), potatoes and a bowl are got during the quest",
            main = "Entrana: no weapons or armour. Buy 12 willow branches, or grow the sapling Auguste gives you (4 hours). 10 logs, a candle (20 Thieving in the Entrana church), potatoes and a bowl are got during the quest",
        },
    }),
    ---------------------------------------------------------------------------
    -- Phase 8: Rimmington, Port Sarim and Draynor, all free and with no skill
    -- requirements. There's No Place Like Home... (the player-owned house and
    -- House Teleport), Witch's Potion (miniquest), Song from the Depths
    -- (Remora's necklace), Once Upon a Slime, Pirate's Treasure (needed for
    -- Cabin Fever), Duck Quest (Paddlington), Swept Away, then Purple Cat
    -- (miniquest; needs Swept Away and Gertrude's Cat, phase 1). The game
    -- supplies all prerequisites. Items and IDs from the RuneScape Wiki as of
    -- 20 October 2026. The miniquests'
    -- wiki pages carry "(miniquest)"; the game's own names are not measured.
    ---------------------------------------------------------------------------
    quest("q-no-place-like-home", 8, "There's No Place Like Home...", {
        unlocks = { "player-owned-house", "house-teleport" },
        methods = {
            ironman = "No items or fighting. Alfred gives 2 logs once (cut more nearby if you lose them); the planks and chair are made during the quest. The workbench may need you to bank everything you wear and carry",
            main = "No items or fighting. Alfred gives 2 logs once (cut more nearby if you lose them); the planks and chair are made during the quest. The workbench may need you to bank everything you wear and carry",
        },
    }),
    quest("q-witchs-potion", 8, "Witch's Potion", {
        wiki = W .. "Witch's_Potion_(miniquest)",
        requires = {
            items = {
                { id = 2146, name = "Burnt meat", count = 1, how = "Cook raw beef or rat meat, then cook it again to burn it; a range is north of Hetty's house" },
                { id = 221, name = "Eye of newt", count = 1, how = "Betty's shop in Port Sarim, 3 coins" },
                { id = 1957, name = "Onion", count = 1, how = "The field just north of Rimmington" },
            },
        },
        methods = {
            ironman = "Miniquest. The rat's tail is got during the quest from a level 1 rat in Rimmington",
            main = "Miniquest. The rat's tail is got during the quest from a level 1 rat in Rimmington",
        },
    }),
    quest("q-song-from-the-depths", 8, "Song from the Depths", {
        unlocks = { "remoras-necklace" },
        methods = {
            ironman = "No items needed; keep 4 backpack spaces free and bring food (the acid hurts). The sleep potion, sapling and coral crossbow are got during the quest. Remora's necklace afterwards teleports to the Grotworm Lair by Rimmington",
            main = "No items needed; keep 4 backpack spaces free and bring food (the acid hurts). The sleep potion, sapling and coral crossbow are got during the quest. Remora's necklace afterwards teleports to the Grotworm Lair by Rimmington",
        },
    }),
    quest("q-once-upon-a-slime", 8, "Once Upon a Slime", {
        methods = {
            ironman = "No items or fighting. Two trips to Varrock (Thessalia, then Eva); the hats, goop and bucket are got during the quest",
            main = "No items or fighting. Two trips to Varrock (Thessalia, then Eva); the hats, goop and bucket are got during the quest",
        },
    }),
    quest("q-pirates-treasure", 8, "Pirate's Treasure", {
        methods = {
            ironman = "1. Bring 60 coins (the boat to Karamja and the rum) and a white apron (one spawns on the wall of Gerrant's shop in Port Sarim).\n2. The 10 bananas are picked on Karamja during the quest.\n3. The Easter quest Great Egg-spectations blocks it while active.\n4. While in Falador Park, take duck food from the sack south of the park for Duck Quest",
            main = "1. Bring 60 coins (the boat to Karamja and the rum) and a white apron (one spawns on the wall of Gerrant's shop in Port Sarim).\n2. The 10 bananas are picked on Karamja during the quest.\n3. The Easter quest Great Egg-spectations blocks it while active.\n4. While in Falador Park, take duck food from the sack south of the park for Duck Quest",
        },
    }),
    quest("q-duck-quest", 8, "Duck Quest", {
        requires = {
            items = {
                { id = 49318, name = "Duck food", count = 1, how = "The sack south of Falador Park, by the castle moat" },
                { id = 227, name = "Vial of water", count = 1, how = "Fill an empty vial at any water source but a well; Jatix in Taverley sells them" },
            },
        },
        unlocks = { "paddlington" },
        methods = {
            ironman = "No fighting. The trail runs from Draynor through Lumbridge to west of the Champions' Guild; the Draynor, Falador and Varrock lodestones help",
            main = "No fighting. The trail runs from Draynor through Lumbridge to west of the Champions' Guild; the Draynor, Falador and Varrock lodestones help",
        },
    }),
    quest("q-swept-away", 8, "Swept Away", {
        methods = {
            ironman = "No items or fighting; keep 1 backpack space free. It visits Aggie (Draynor), Betty (Port Sarim) and Hetty (Rimmington); the broomstick and the rest are got during the quest",
            main = "No items or fighting; keep 1 backpack space free. It visits Aggie (Draynor), Betty (Port Sarim) and Hetty (Rimmington); the broomstick and the rest are got during the quest",
        },
    }),
    quest("q-purple-cat", 8, "Purple Cat", {
        wiki = W .. "Purple_Cat_(miniquest)",
        methods = {
            ironman = "Miniquest, no fighting. Bring a cat or kitten only if you want it dyed purple (a hellcat turns back into a normal cat); the slate and unguent are got during the quest",
            main = "Miniquest, no fighting. Bring a cat or kitten only if you want it dyed purple (a hellcat turns back into a normal cat); the slate and unguent are got during the quest",
        },
    }),
    ---------------------------------------------------------------------------
    -- Phase 9: Varrock, Lumbridge and Edgeville, all free, none needing
    -- another quest. Sheep Shearer (miniquest), Shield of Arrav (solo: both
    -- gangs; needed for Heroes' Quest), Heartstealer, Gunnar's Ground (5
    -- Crafting), The Death of Chivalry (Skull of Remembrance), Missing,
    -- Presumed Death (the invitation box to Silvarea), Broken Home (next to
    -- it), then Gower Quest (34 quest points). The game supplies all
    -- prerequisites. From the RuneScape Wiki as of 20 October 2026. None lists an item the quest doesn't give;
    -- coins and worn items are in the tips.
    ---------------------------------------------------------------------------
    quest("q-sheep-shearer", 9, "Sheep Shearer", {
        wiki = W .. "Sheep_Shearer_(miniquest)",
        methods = {
            ironman = "Miniquest, no fighting (rams in the pen can hit). The 20 balls of wool are got during the quest from Fred's sheep and the spinning wheel in Lumbridge Castle; black wool doesn't count. Shears on the tool belt work. Talk to Fred again afterwards for 1,940 more coins",
            main = "Miniquest, no fighting (rams in the pen can hit). The 20 balls of wool are got during the quest from Fred's sheep and the spinning wheel in Lumbridge Castle; black wool doesn't count. Shears on the tool belt work. Talk to Fred again afterwards for 1,940 more coins",
        },
    }),
    quest("q-shield-of-arrav", 9, "Shield of Arrav", {
        methods = {
            ironman = "Bring 20 coins. Done solo: you join both gangs. One level 1 fight. The book, the report, both shield halves and the crossbows are got during the quest. Your gang matters for Heroes' Quest later and can be changed",
            main = "Bring 20 coins. Done solo: you join both gangs. One level 1 fight. The book, the report, both shield halves and the crossbows are got during the quest. Your gang matters for Heroes' Quest later and can be changed",
        },
    }),
    quest("q-heartstealer", 9, "Heartstealer", {
        methods = {
            ironman = "No items or fighting; Caelyn pays for the masks. The tasks are in Varrock (Thessalia, the museum). The Scarlet Thief's mask, worn later, and the plans are got during the quest",
            main = "No items or fighting; Caelyn pays for the masks. The tasks are in Varrock (Thessalia, the museum). The Scarlet Thief's mask, worn later, and the plans are got during the quest",
        },
    }),
    quest("q-gunnars-ground", 9, "Gunnar's Ground", {
        methods = {
            ironman = "No items needed (a chisel on the tool belt works). The poem and rings are got during the quest; a normal gold ring won't do. The fight with Haakon is optional",
            main = "No items needed (a chisel on the tool belt works). The poem and rings are got during the quest; a normal gold ring won't do. The fight with Haakon is optional",
        },
    }),
    quest("q-death-of-chivalry", 9, "The Death of Chivalry", {
        unlocks = { "skull-of-remembrance" },
        methods = {
            ironman = "Keep 5 backpack spaces free; bring food and combat gear later (fights scale to your level; a bank chest is in the ritual chamber). The black knight captain's suit is got and worn during the quest: no overrides active. Dismiss pets and familiars before the fortress",
            main = "Keep 5 backpack spaces free; bring food and combat gear later (fights scale to your level; a bank chest is in the ritual chamber). The black knight captain's suit is got and worn during the quest: no overrides active. Dismiss pets and familiars before the fortress",
        },
    }),
    quest("q-missing-presumed-death", 9, "Missing, Presumed Death", {
        unlocks = { "invitation-box" },
        methods = {
            ironman = "No items needed; bring food and combat gear (fights scale to your level). The notebook, ring and invitation box are got during the quest; the Draynor lodestone is nearest the Wizards' Tower",
            main = "No items needed; bring food and combat gear (fights scale to your level). The notebook, ring and invitation box are got during the quest; the Draynor lodestone is nearest the Wizards' Tower",
        },
    }),
    quest("q-broken-home", 9, "Broken Home", {
        methods = {
            ironman = "Bank everything first, worn gear too, and dismiss followers: nothing can be taken in (a deposit box is nearby). No food inside; the mystery meat found there heals. Life points don't regenerate in the mansion",
            main = "Bank everything first, worn gear too, and dismiss followers: nothing can be taken in (a deposit box is nearby). No food inside; the mystery meat found there heals. Life points don't regenerate in the mansion",
        },
    }),
    quest("q-gower-quest", 9, "Gower Quest", {
        methods = {
            ironman = "1. Experienced. No items needed; keep 7 backpack spaces free and bring food and combat gear (the last fight scales to you and is safe).\n2. The cabbagespeak amulet is made and worn during the quest, not in a cramulet.\n3. Afterwards, don't search the crate at the Gower farm: it resets the quest and takes its quest point",
            main = "1. Experienced. No items needed; keep 7 backpack spaces free and bring food and combat gear (the last fight scales to you and is safe).\n2. The cabbagespeak amulet is made and worn during the quest, not in a cramulet.\n3. Afterwards, don't search the crate at the Gower farm: it resets the quest and takes its quest point",
        },
    }),
    ---------------------------------------------------------------------------
    -- Phase 10: Falador, Taverley and Al Kharid, all free. The Knight's Sword
    -- (its Smithing lamp helps the Doric tasks), What's Mine is Yours, Doric's
    -- Task I (miniquest), Perils of Ice Mountain, Doric's Task II (miniquest;
    -- also needs Death Plateau, phase 1), Violet is Blue Too (needs Violet is
    -- Blue, phase 1), Witch's House, then One Piercing Note. The game supplies
    -- all prerequisites; the wiki's extra Ironman skills (to make the items
    -- yourself) are in the ironman tips. From the RuneScape Wiki as of 20
    -- October 2026.
    ---------------------------------------------------------------------------
    quest("q-knights-sword", 10, "The Knight's Sword", {
        requires = {
            items = {
                { id = 2325, name = "Redberry pie", count = 1, how = "Redberries in a pie shell, cooked on a range (10 Cooking); redberries from Wydin in Port Sarim or a bush" },
                { id = 2351, name = "Iron bar", count = 2, how = "Smelt iron ore at a furnace (10 Smithing); metal bank bars can be taken out at Thurgo's anvil" },
            },
        },
        methods = {
            ironman = "1. Intermediate. Ironman: 10 Cooking for the pie and 10 Smithing for the bars.\n2. A pickaxe on the tool belt; the blurite ore and the portrait are got during the quest (mine a spare blurite for Defender of Varrock).\n3. The dungeon's ice warriors and giants are aggressive.\n4. Take off a ring of charos.\n5. Rub the Smithing lamp: the Master Quest Cape needs it used",
            main = "Intermediate. A pickaxe on the tool belt; the blurite ore and the portrait are got during the quest (mine a spare blurite for Defender of Varrock). The dungeon's ice warriors and giants are aggressive. Take off a ring of charos. Rub the Smithing lamp: the Master Quest Cape needs it used",
        },
    }),
    quest("q-whats-mine-is-yours", 10, "What's Mine is Yours", {
        methods = {
            ironman = "No items needed; a pickaxe and hammer on the tool belt. The ores, bars and the rest are got during the quest. Four level 1 fights, one at each mine. Don't back out of the father-and-son talk: it starts again",
            main = "No items needed; a pickaxe and hammer on the tool belt. The ores, bars and the rest are got during the quest. Four level 1 fights, one at each mine. Don't back out of the father-and-son talk: it starts again",
        },
    }),
    quest("q-dorics-task-1", 10, "Doric's Task I", {
        wiki = W .. "Doric's_Task_I_(miniquest)",
        requires = {
            items = {
                { id = 2351, name = "Iron bar", count = 4, how = "Or 2 iron bars and an iron full helm. Smelt iron ore at a furnace (10 Smithing)" },
            },
        },
        methods = {
            ironman = "Miniquest. Ironman: 10 Mining. Smith the iron full helm + 1 yourself on Doric's anvil; no other anvil works. A hammer on the tool belt. Deliver it to Aksel at the Artisans' Workshop, Falador",
            main = "Miniquest. Smith the iron full helm + 1 yourself on Doric's anvil; no other anvil works. A hammer on the tool belt. Deliver it to Aksel at the Artisans' Workshop, Falador",
        },
    }),
    quest("q-perils-of-ice-mountain", 10, "Perils of Ice Mountain", {
        requires = {
            items = {
                { id = 6032, ids = { 6032, 6034 }, name = "Bucket of compost", count = 1, how = "Farming shops (Heskel in Falador Park, Elstan south-east of Falador) or Head Farmer Jones in Taverley, 20 coins; or a compost bin" },
                { id = 960, name = "Plank", count = 2, how = "Sawmill Co. in Rimmington, 100 coins; protean planks don't work" },
                -- Nails "of any metal" (wiki): bronze, iron, steel, mithril, adamant, rune.
                { id = 1539, ids = { 4819, 4820, 1539, 4822, 4823, 4824 }, name = "Nails (any metal)", count = 2,
                  how = "75 nails per bar, smithed at an anvil (bronze from 1 Smithing); free players use steel or lower" },
            },
        },
        methods = {
            ironman = "Bring a watering can with water (one on the tool belt works). Needs 5 Farming, Hunter and Thieving (not boostable). No fighting. The crate, letter, key, icefiend net (wielded), icefiends, tent and plans are got during the quest",
            main = "Bring a watering can with water (one on the tool belt works). Needs 5 Farming, Hunter and Thieving (not boostable). No fighting. The crate, letter, key, icefiend net (wielded), icefiends, tent and plans are got during the quest",
        },
    }),
    quest("q-dorics-task-2", 10, "Doric's Task II", {
        wiki = W .. "Doric's_Task_II_(miniquest)",
        requires = {
            items = {
                { id = 2353, name = "Steel bar", count = 10, how = "Iron ore and coal at a furnace (20 Smithing)" },
                { id = 2349, name = "Bronze bar", count = 2, how = "Copper and tin ore at a furnace" },
            },
        },
        methods = {
            ironman = "Miniquest. Ironman: 20 Mining. Smith the 2 steel chainbodies only after taking the task: armour made before doesn't count. Bars must be in the backpack, not the metal bank. Commander Denulth is in Burthorpe",
            main = "Miniquest. Smith the 2 steel chainbodies only after taking the task: armour made before doesn't count. Bars must be in the backpack, not the metal bank. Commander Denulth is in Burthorpe",
        },
    }),
    quest("q-violet-is-blue-too", 10, "Violet is Blue Too", {
        methods = {
            ironman = "No items or fighting. The snow impling is got during the quest. Afterwards the Land of Snow portal also goes to Violet's house and both Yeti towns",
            main = "No items or fighting. The snow impling is got during the quest. Afterwards the Land of Snow portal also goes to Violet's house and both Yeti towns",
        },
    }),
    quest("q-witchs-house", 10, "Witch's House", {
        methods = {
            ironman = "Intermediate, 4 quest points. Bring food and combat gear: one fight with four forms back to back, up to a level 49 wolf. The leather gloves (worn) and the cheese are got in the house",
            main = "Intermediate, 4 quest points. Bring food and combat gear: one fight with four forms back to back, up to a level 49 wolf. The leather gloves (worn) and the cheese are got in the house",
        },
    }),
    quest("q-one-piercing-note", 10, "One Piercing Note", {
        methods = {
            ironman = "No items or fighting; keep 11 backpack spaces free. The cabbage, keys, notes and robes are got during the quest. Read the hymn book by the choir, or the Holy Cithara can't be taken afterwards",
            main = "No items or fighting; keep 11 backpack spaces free. The cabbage, keys, notes and robes are got during the quest. Read the hymn book by the choir, or the Holy Cithara can't be taken afterwards",
        },
    }),
    ---------------------------------------------------------------------------
    -- Phase 11: the free quests with 30-40 skills, and the free saga.
    -- Learning the Ropes (the tutorial since 19 October 2026; the wiki says
    -- it completes itself on login for accounts past a tutorial, so this is a
    -- check), Beneath Cursed Tides (eight skills at 30), Doric's Tasks III and
    -- IV (miniquests), Chef's Assistant, A Soul's Bane, then Three's Company
    -- (saga; Skaldrun must be freed in Daemonheim first, which the game
    -- doesn't track as a quest). The game supplies all prerequisites; the
    -- wiki's Ironman alternatives are in the ironman tips. From the RuneScape
    -- Wiki as of 21 October 2026.
    ---------------------------------------------------------------------------
    quest("q-learning-the-ropes", 11, "Learning the Ropes", {
        methods = {
            ironman = "Should already be done: the game completes it on login for accounts that did a tutorial before 19 October 2026. If it still shows unfinished, the wiki gives no way to do it outside Tutorial Island",
            main = "Should already be done: the game completes it on login for accounts that did a tutorial before 19 October 2026. If it still shows unfinished, the wiki gives no way to do it outside Tutorial Island",
        },
    }),
    quest("q-beneath-cursed-tides", 11, "Beneath Cursed Tides", {
        methods = {
            ironman = "No items needed; 30 Attack, Cooking, Firemaking, Magic, Mining, Smithing, Strength and Woodcutting. Before diving at Mudskipper Point, unequip weapons and dismiss followers. Everything on the island is got during the quest. Its 10,000 XP combat lamp helps with A Soul's Bane",
            main = "No items needed; 30 Attack, Cooking, Firemaking, Magic, Mining, Smithing, Strength and Woodcutting. Before diving at Mudskipper Point, unequip weapons and dismiss followers. Everything on the island is got during the quest. Its 10,000 XP combat lamp helps with A Soul's Bane",
        },
    }),
    quest("q-dorics-task-3", 11, "Doric's Task III", {
        wiki = W .. "Doric's_Task_III_(miniquest)",
        requires = {
            items = {
                { id = 2359, name = "Mithril bar", count = 8, how = "Or 4 bars and a mithril longsword and warhammer. Mithril ore and coal at a furnace (30 Smithing)" },
            },
        },
        methods = {
            ironman = "Miniquest. Ironman: 30 Mining (8 mithril ore and 8 coal). Smith the mithril longsword + 1 and warhammer + 1 only after taking the task: ones made before are refused. A hammer on the tool belt",
            main = "Miniquest. Smith the mithril longsword + 1 and warhammer + 1 only after taking the task: ones made before are refused. A hammer on the tool belt",
        },
    }),
    quest("q-dorics-task-4", 11, "Doric's Task IV", {
        wiki = W .. "Doric's_Task_IV_(miniquest)",
        requires = {
            items = {
                { id = 2361, name = "Adamant bar", count = 48, how = "Or the five adamant + 2 armour pieces. Adamantite ore and luminite at a furnace (40 Smithing)" },
            },
        },
        methods = {
            ironman = "Miniquest. Ironman: 40 Mining (48 adamantite ore and 48 luminite). Make the whole adamant burial set at the Burial Anvil in the Artisans' Workshop: pieces made one by one as burial armour don't count (Suak explains burial armour). The set is used up",
            main = "Miniquest. Make the whole adamant burial set at the Burial Anvil in the Artisans' Workshop: pieces made one by one as burial armour don't count (Suak explains burial armour). The set is used up",
        },
    }),
    quest("q-chefs-assistant", 11, "Chef's Assistant", {
        requires = {
            items = {
                { id = 1511, name = "Logs", count = 1, how = "Normal logs only; cut a tree" },
                { id = 2353, name = "Steel bar", count = 1, how = "Iron ore and coal at a furnace (20 Smithing)" },
                { id = 1927, name = "Bucket of milk", count = 1, how = "Milk a cow, or the milk seller at the Falador farm, 12 coins; 2 more to churn your own butter and cream" },
                { id = 1933, name = "Pot of flour", count = 1, how = "Mess Sergeant Ramsey by the Taverley bank or Wydin in Port Sarim, or mill grain" },
                { id = 6697, name = "Pat of butter", count = 1, how = "Churn a bucket of milk at a dairy churn (38 Cooking)" },
                { id = 2130, name = "Pot of cream", count = 1, how = "Churn a bucket of milk at a dairy churn (21 Cooking)" },
            },
        },
        methods = {
            ironman = "Ironman: 38 Cooking (to churn the butter), or after starting Visions of Havenhythe (phase 13). Wear a chef's hat (the Cooks' Guild needs it and 32 Cooking). A cake tin is upstairs in the guild. The cream cheese, biscuits and cheesecake are made during the quest",
            main = "Wear a chef's hat (the Cooks' Guild needs it and 32 Cooking). A cake tin is upstairs in the guild. The cream cheese, biscuits and cheesecake are made during the quest",
        },
    }),
    quest("q-souls-bane", 11, "A Soul's Bane", {
        methods = {
            ironman = "No items needed; bring food and armour (fights up to level 45). The anger weapons are got during the quest and wielded alone: take off all your own gear. Leaving the rift or logging out restarts any unfinished room",
            main = "No items needed; bring food and armour (fights up to level 45). The anger weapons are got during the quest and wielded alone: take off all your own gear. Leaving the rift or logging out restarts any unfinished room",
        },
    }),
    quest("q-threes-company", 11, "Three's Company", {
        wiki = W .. "Three's_Company_(saga)",
        methods = {
            ironman = "1. Saga: get a ring of kinship from the Dungeoneering tutor in Daemonheim.\n2. Finish one dungeon to unlock high complexity.\n3. At high complexity, free Skaldrun from the ice on a frozen floor (1-11).\n4. Find the bear pelt, then talk to Skaldrun about it before Start Saga.\n5. Nothing can be taken in. Have 30 Attack, Magic and Ranged for the unabridged version; Bridge over Fremmy Waters needs it.\n6. Don't Home Teleport inside.",
            main = "1. Saga: get a ring of kinship from the Dungeoneering tutor in Daemonheim.\n2. Finish one dungeon to unlock high complexity.\n3. At high complexity, free Skaldrun from the ice on a frozen floor (1-11).\n4. Find the bear pelt, then talk to Skaldrun about it before Start Saga.\n5. Nothing can be taken in. Have 30 Attack, Magic and Ranged for the unabridged version; Bridge over Fremmy Waters needs it.\n6. Don't Home Teleport inside.",
        },
    }),
    ---------------------------------------------------------------------------
    -- Phase 12: the members' Novice quests in Kandarin, none needing another
    -- quest. Fishing Contest (10 Fishing; the White Wolf Mountain shortcut),
    -- Dwarf Cannon (the multicannon), Murder Mystery, Hazeel Cult, Clock
    -- Tower, Monk's Friend, Tower of Life (10 Construction), then Observatory
    -- Quest. The game supplies all prerequisites. From the RuneScape Wiki as
    -- of 21 October 2026.
    ---------------------------------------------------------------------------
    quest("q-fishing-contest", 12, "Fishing Contest", {
        requires = {
            items = {
                { id = 1550, name = "Garlic", count = 1, how = "Spawns on a table in a Seers' Village house, or in an upstairs drawer of Morgan's house in Draynor Village" },
            },
        },
        unlocks = { "white-wolf-mountain-shortcut" },
        methods = {
            ironman = "Bring 5 coins (the entry fee). A fishing rod and spade on the tool belt work; the 3 red vine worms are dug up in McGrubor's Wood during the quest (level 33 guard dogs inside). Unlocks the White Wolf Mountain shortcut",
            main = "Bring 5 coins (the entry fee). A fishing rod and spade on the tool belt work; the 3 red vine worms are dug up in McGrubor's Wood during the quest (level 33 guard dogs inside). Unlocks the White Wolf Mountain shortcut",
        },
    }),
    quest("q-dwarf-cannon", 12, "Dwarf Cannon", {
        unlocks = { "dwarf-multicannon" },
        methods = {
            ironman = "No items needed. Below about combat 29, bring food and armour for the goblin cave's giant bats. Don't let the last talk with Captain Lawgof be interrupted: he takes the mould without finishing the quest. Ends with Nulodion north-east of Falador",
            main = "No items needed. Below about combat 29, bring food and armour for the goblin cave's giant bats. Don't let the last talk with Captain Lawgof be interrupted: he takes the mould without finishing the quest. Ends with Nulodion north-east of Falador",
        },
    }),
    quest("q-murder-mystery", 12, "Murder Mystery", {
        requires = {
            items = {
                { id = 1931, name = "Empty pot", count = 1, how = "Or 7 pots of flour. General stores sell empty pots" },
            },
        },
        methods = {
            ironman = "Keep 11-16 backpack spaces free. The murderer is different on every account. The dagger, threads, flypaper and silver items are got during the quest. No fighting",
            main = "Keep 11-16 backpack spaces free. The murderer is different on every account. The dagger, threads, flypaper and silver items are got during the quest. No fighting",
        },
    }),
    quest("q-hazeel-cult", 12, "Hazeel Cult", {
        methods = {
            ironman = "No items needed. You choose a side: either completes it, and Carnillean Rising follows both. The Carnillean side has one fight (level 9)",
            main = "No items needed. You choose a side: either completes it, and Carnillean Rising follows both. The Carnillean side has one fight (level 9)",
        },
    }),
    quest("q-clock-tower", 12, "Clock Tower", {
        requires = {
            items = {
                { id = 1929, ids = { 1929, 1937, 1921 }, name = "Bucket of water (or a jug or bowl)", count = 1,
                  how = "Or wear ice gloves. Endless buckets of water in the Carnillean mansion basement (Hazeel Cult); a bucket respawns at the well south of the zoo" },
            },
        },
        methods = {
            ironman = "Level 67 ogres guard one cog; bring armour if you're low level. The cogs and rat poison are got during the quest; only one cog can be carried at a time",
            main = "Level 67 ogres guard one cog; bring armour if you're low level. The cogs and rat poison are got during the quest; only one cog can be carried at a time",
        },
    }),
    quest("q-monks-friend", 12, "Monk's Friend", {
        requires = {
            items = {
                { id = 1937, name = "Jug of water", count = 1, how = "A jug from a general store (East Ardougne, Port Khazard), filled at a well or sink" },
                { id = 1511, name = "Logs", count = 1, how = "Normal logs; plenty of trees by the monastery" },
            },
        },
        methods = {
            ironman = "No fighting needed (the thieves are optional). The child's blanket is got during the quest",
            main = "No fighting needed (the thieves are optional). The child's blanket is got during the quest",
        },
    }),
    quest("q-tower-of-life", 12, "Tower of Life", {
        requires = {
            items = {
                { id = 1917, name = "Beer", count = 1, how = "The Poison Arrow pub in East Ardougne, 2 coins; it can't be brewed" },
            },
        },
        unlocks = { "creature-creation" },
        methods = {
            ironman = "A hammer and saw on the tool belt. The builder's outfit (worn) and the machine parts are got during the quest. Keep 14 backpack spaces free. No fighting",
            main = "A hammer and saw on the tool belt. The builder's outfit (worn) and the machine parts are got during the quest. Keep 14 backpack spaces free. No fighting",
        },
    }),
    quest("q-observatory-quest", 12, "Observatory Quest", {
        requires = {
            items = {
                { id = 960, name = "Plank", count = 3, how = "Normal logs and 100 coins each at a sawmill (Rimmington)" },
                { id = 2349, name = "Bronze bar", count = 1, how = "Copper and tin ore at a furnace" },
                { id = 1775, name = "Molten glass", count = 1, how = "A bucket of sand and soda ash at a furnace (1 Crafting)" },
            },
        },
        methods = {
            ironman = "Fights are optional: a level 28 goblin guard, and poison spiders in some chests (antipoison helps). The goblin kitchen key and lens mould are got during the quest",
            main = "Fights are optional: a level 28 goblin guard, and poison spiders in some chests (antipoison helps). The goblin kitchen key and lens mould are got during the quest",
        },
    }),
    ---------------------------------------------------------------------------
    -- Phase 13: Wendlewick and Havenhythe. Bringing Home the Bacon (by the
    -- Falador farm), Visions of Havenhythe (free; the Wendlewick lodestone
    -- and Wendlewick Teleport), Hearts of Sanguine (free), Hermit Permits,
    -- Wiz Kid, then Secrets of Amberfell (needs Hearts of Sanguine). The game
    -- supplies all prerequisites. Starts and items from the RuneScape Wiki's
    -- pages as of 21 October 2026.
    ---------------------------------------------------------------------------
    quest("q-bringing-home-the-bacon", 13, "Bringing Home the Bacon", {
        methods = {
            ironman = "Keep 10 backpack spaces free (3 or more for Eli's planks). The 5 wheat are got during the quest (the patch east of Draynor); pick the 5 onions only after Eli asks, ones you already have don't count",
            main = "Keep 10 backpack spaces free (3 or more for Eli's planks). The 5 wheat are got during the quest (the patch east of Draynor); pick the 5 onions only after Eli asks, ones you already have don't count",
        },
    }),
    quest("q-visions-of-havenhythe", 13, "Visions of Havenhythe", {
        unlocks = { "wendlewick-lodestone", "wendlewick-teleport" },
        methods = {
            ironman = "No items; keep 10 backpack spaces free. The mead and the limestone are got during the quest (12 Crafting helps; otherwise Adam chisels it). Unlocks the Wendlewick lodestone and Wendlewick Teleport",
            main = "No items; keep 10 backpack spaces free. The mead and the limestone are got during the quest (12 Crafting helps; otherwise Adam chisels it). Unlocks the Wendlewick lodestone and Wendlewick Teleport",
        },
    }),
    quest("q-hearts-of-sanguine", 13, "Hearts of Sanguine", {
        methods = {
            ironman = "Bring a few coins (the ale is 6) and melee armour. The 10 copper and 10 tin ore and the ale are got during the quest; ores must be un-noted. The fight is safe",
            main = "Bring a few coins (the ale is 6) and melee armour. The 10 copper and 10 tin ore and the ale are got during the quest; ores must be un-noted. The fight is safe",
        },
    }),
    quest("q-hermit-permits", 13, "Hermit Permits", {
        requires = {
            items = {
                { id = 1759, name = "Ball of wool", count = 1, how = "Spin wool on a spinning wheel" },
                { id = 954, name = "Rope", count = 3, how = "East Ardougne general store; or a Lorehound pet" },
            },
        },
        methods = {
            ironman = "The 6 seaweed are got during the quest, on the beach by the crabs. The crabulet is made and worn during the quest",
            main = "The 6 seaweed are got during the quest, on the beach by the crabs. The crabulet is made and worn during the quest",
        },
    }),
    quest("q-wiz-kid", 13, "Wiz Kid", {
        requires = {
            items = {
                { id = 556, name = "Air rune", count = 8, how = "Rune shops, or Runecrafting" },
                { id = 555, name = "Water rune", count = 6, how = "Rune shops, or Runecrafting" },
                { id = 557, name = "Earth rune", count = 4, how = "Rune shops, or Runecrafting" },
                { id = 561, name = "Nature rune", count = 2, how = "Rune shops, or Runecrafting" },
                { id = 563, name = "Law rune", count = 4, how = "Rune shops, or Runecrafting" },
            },
        },
        methods = {
            ironman = "The 2 bones are got during the quest. It switches you to the standard spellbook, and the farm part has no bank",
            main = "The 2 bones are got during the quest. It switches you to the standard spellbook, and the farm part has no bank",
        },
    }),
    quest("q-secrets-of-amberfell", 13, "Secrets of Amberfell", {
        requires = {
            items = {
                { id = 954, name = "Rope", count = 2, how = "East Ardougne general store; or a Lorehound pet" },
                -- Core logs (wiki, Logs (type)): normal, oak, willow, teak, maple, acadia,
                -- mahogany, yew, magic, elder, eternal magic; the count can't tell kinds apart.
                { id = 1511, ids = { 1511, 1521, 1519, 6333, 1517, 40285, 6332, 1515, 1513, 29556, 58250 }, name = "Logs (one core kind)", count = 10, oneKind = true,
                  how = "Cut the appropriate trees; 10 of the same core log kind" },
                -- Nails "of same kind" (wiki): bronze to rune; the count can't tell kinds apart.
                { id = 4820, ids = { 4819, 4820, 1539, 4822, 4823, 4824 }, name = "Nails (one kind)", count = 20, oneKind = true, how = "75 nails per bar at an anvil; 20 of the same metal" },
                { id = 10010, ids = { 10010, 11259, 60698 }, name = "Butterfly net", count = 1, how = "Buy from a Hunter shop in Taverley, Yanille or Nardah; a magic butterfly net or Tellervo's net also works" },
                { id = 10029, ids = { 10029, 10092 }, name = "Teasing stick or ferret", count = 1, how = "The Groundskeeper north-west of the burrows sells teasing sticks" },
                { id = 229, name = "Vial", count = 1, how = "Blow molten glass into a vial with a glassblowing pipe (33 Crafting)" },
                { id = 60689, ids = { 60689, 60687 }, name = "Antisanguine (3 or 4 doses)", count = 1,
                  how = "Mix a marrentill potion (unf) with sanguine matter (15 Herblore, after Hearts of Sanguine); sanguine matter drops from sanguine creatures around Havenhythe" },
            },
        },
        methods = {
            ironman = "Intermediate. Also bring 5 cooked fish (not for combat; a fishing spot is on the beach south), food and combat gear, ideally a havensilver weapon (others do half damage); the fight is safe. Keep 6 backpack spaces free at the end for the reward",
            main = "Intermediate. Also bring 5 cooked fish (not for combat; a fishing spot is on the beach south), food and combat gear, ideally a havensilver weapon (others do half damage); the fight is safe. Keep 6 backpack spaces free at the end for the reward",
        },
    }),
    ---------------------------------------------------------------------------
    -- Phase 14: the Temple Knights. Recruitment Drive, Enter the Abyss
    -- (miniquest), Wanted!, Sea Slug, The Slug Menace, Kennith's Concerns,
    -- then Quiet Before the Swarm (the Void Knights; 35 Attack, 42 Strength).
    -- The game supplies all prerequisites (Wanted!'s 33 quest points were
    -- removed on 19 February 2024, per the wiki). Starts and items from the
    -- wiki's pages as of 21 October 2026.
    ---------------------------------------------------------------------------
    quest("q-recruitment-drive", 14, "Recruitment Drive", {
        methods = {
            ironman = "No items: the tests start only with nothing worn or carried. Failing a test sends you back to the start. Only a female character can land the last hit on Sir Leye: change at the Makeover Mage (free), or Home Teleport out (progress kept). Not a safe death for Hardcore",
            main = "No items: the tests start only with nothing worn or carried. Failing a test sends you back to the start. Only a female character can land the last hit on Sir Leye: change at the Makeover Mage (free), or Home Teleport out (progress kept)",
        },
    }),
    quest("q-enter-the-abyss", 14, "Enter the Abyss", {
        wiki = W .. "Enter_the_Abyss_(miniquest)",
        methods = {
            ironman = "Miniquest. No items; the scrying orb is given. The Mage won't talk while you wear Saradomin or Guthix items. The Burthorpe tutor's essence teleport doesn't count",
            main = "Miniquest. No items; the scrying orb is given. The Mage won't talk while you wear Saradomin or Guthix items. The Burthorpe tutor's essence teleport doesn't count",
        },
    }),
    quest("q-wanted", 14, "Wanted!", {
        wiki = W .. "Wanted!",
        methods = {
            ironman = "Bring 10,000 coins, or an enchanted gem, molten glass and a law rune, for the commorb. The 20 rune or pure essence can be got during the quest. Take off a ring of life: it's destroyed. No Saradomin or Guthix items for the Mage of Zamorak",
            main = "Bring 10,000 coins, or an enchanted gem, molten glass and a law rune, for the commorb. The 20 rune or pure essence can be got during the quest. Take off a ring of life: it's destroyed. No Saradomin or Guthix items for the Mage of Zamorak",
        },
    }),
    quest("q-sea-slug", 14, "Sea Slug", {
        requires = {
            items = {
                { id = 1941, name = "Swamp paste", count = 1, how = "Mix flour with swamp tar, then cook on a fire, not a range; or buy at Port Khazard's general stores" },
            },
        },
        methods = {
            ironman = "The broken glass, damp sticks and torch are got on the platform",
            main = "The broken glass, damp sticks and torch are got on the platform",
        },
    }),
    quest("q-slug-menace", 14, "The Slug Menace", {
        requires = {
            items = {
                { id = 1941, name = "Swamp paste", count = 1, how = "Mix flour with swamp tar, then cook on a fire, not a range; or buy at Port Khazard's general stores" },
                { id = 7936, ids = { 7936, 1436 }, name = "Pure or rune essence", count = 5, how = "Mine essence via Aubury in Varrock (30 Mining for pure essence); bring 10-15, it can break during the quest" },
            },
        },
        methods = {
            ironman = "Also access to the air, earth, water, fire and mind altars: their talismans or tiaras, an elemental and a mind talisman, an omni-talisman, a charged wicked hood, or the Abyss (Enter the Abyss). Melee gear for the level 51 Slug Prince. The commorb is given. Keep 5 backpack spaces free",
            main = "Also access to the air, earth, water, fire and mind altars: their talismans or tiaras, an elemental and a mind talisman, an omni-talisman, a charged wicked hood, or the Abyss (Enter the Abyss). Melee gear for the level 51 Slug Prince. The commorb is given. Keep 5 backpack spaces free",
        },
    }),
    quest("q-kenniths-concerns", 14, "Kennith's Concerns", {
        methods = {
            ironman = "No items listed; a pickaxe on the tool belt (the quest has you mine). Take off an active sign of the porter: it banks the rubium. Logging out during Kimberly's part starts it again",
            main = "No items listed; a pickaxe on the tool belt (the quest has you mine). Take off an active sign of the porter: it banks the rubium. Logging out during Kimberly's part starts it again",
        },
    }),
    quest("q-quiet-before-the-swarm", 14, "Quiet Before the Swarm", {
        methods = {
            ironman = "Bring nothing: you're asked to bank everything worn and carried, and to dismiss familiars. Have no pet following on the ship (it can trap you there). The two fights are out of body: you can't die",
            main = "Bring nothing: you're asked to bank everything worn and carried, and to dismiss familiars. Have no pet following on the ship (it can trap you there). The two fights are out of body: you can't die",
        },
    }),
    ---------------------------------------------------------------------------
    -- Phase 15: the Kharidian Desert, first part. The Jack of Spades, Call of
    -- the Ancestors, The Tourist Trap, Rune Mechanics, The Golem, Missing My
    -- Mummy, The Feud, then Spirits of the Elid (the highest levels). The game
    -- supplies all prerequisites. Starts and items from the RuneScape Wiki as
    -- of 21 October 2026.
    ---------------------------------------------------------------------------
    quest("q-jack-of-spades", 15, "The Jack of Spades", {
        methods = {
            ironman = "No items. Before the carpet ride, nothing in your main or off hand and no follower",
            main = "No items. Before the carpet ride, nothing in your main or off hand and no follower",
        },
    }),
    quest("q-call-of-the-ancestors", 15, "Call of the Ancestors", {
        methods = {
            ironman = "No items or coins",
            main = "No items or coins",
        },
    }),
    quest("q-tourist-trap", 15, "The Tourist Trap", {
        requires = {
            items = {
                { id = 314, name = "Feather", count = 10, how = "Regular feathers only; the Shantay Pass shop sells them" },
                { id = 2349, name = "Bronze bar", count = 1, how = "Copper and tin ore at a furnace; in your backpack" },
            },
        },
        methods = {
            ironman = "Also bring a desert shirt, robe and boots (the Shantay Pass shop sells them; black ones don't work) and 200 coins. Keep 15 backpack spaces free. Inside the camp wear no armour, jewellery or weapons: putting any on gets you jailed",
            main = "Also bring a desert shirt, robe and boots (the Shantay Pass shop sells them; black ones don't work) and 200 coins. Keep 15 backpack spaces free. Inside the camp wear no armour, jewellery or weapons: putting any on gets you jailed",
        },
    }),
    quest("q-rune-mechanics", 15, "Rune Mechanics", {
        requires = {
            items = {
                { id = 4694, name = "Steam rune", count = 4, how = "The Mage Training Arena shop, north of Het's Oasis; a fifth is crafted in the quest" },
                { id = 554, ids = { 554, 555 }, name = "Fire or water rune", count = 1, how = "Buy from rune shops; to craft the steam rune, bring 5 fire or water runes to craft all five" },
                { id = 558, name = "Mind rune", count = 5, how = "Aubury's Rune Shop in Varrock, or the mind altar" },
                { id = 559, name = "Body rune", count = 5, how = "The body altar (20 Runecrafting)" },
                { id = 1605, name = "Emerald", count = 2, how = "Cut an uncut emerald with a chisel (27 Crafting)" },
                { id = 7936, ids = { 7936, 1436 }, name = "Pure or rune essence", count = 21, how = "Mine at the Rune Essence Mine; un-noted; the item list says 21, the walkthrough 20" },
            },
        },
        methods = {
            ironman = "Also a progress hat and 5 or more Mage Training Arena pizazz points. One steam rune is crafted during the quest; the fire and water talismans and a binding necklace are given",
            main = "Also a progress hat and 5 or more Mage Training Arena pizazz points. One steam rune is crafted during the quest; the fire and water talismans and a binding necklace are given",
        },
    }),
    quest("q-golem", 15, "The Golem", {
        requires = {
            items = {
                { id = 229, name = "Vial", count = 1, how = "Blow molten glass into a vial with a glassblowing pipe (33 Crafting)" },
                { id = 1761, name = "Soft clay", count = 4, how = "Add water to clay at any water source" },
                { id = 970, name = "Papyrus", count = 1, how = "Shops, 10 coins; or the desk spawn in the Legends' Guild office" },
            },
        },
        methods = {
            ironman = "The phoenix feather and black mushroom are got during the quest; a pestle and mortar on the tool belt. A sign of the porter, or grace of the elves set to porter, sends the feather to your bank",
            main = "The phoenix feather and black mushroom are got during the quest; a pestle and mortar on the tool belt. A sign of the porter, or grace of the elves set to porter, sends the feather to your bank",
        },
    }),
    quest("q-missing-my-mummy", 15, "Missing My Mummy", {
        requires = {
            items = {
                { id = 1519, name = "Willow logs", count = 1, how = "Cut a willow tree (20 Woodcutting)" },
                { id = 554, name = "Fire rune", count = 20, how = "Buy from rune shops; runes only: a fire staff doesn't count" },
                { id = 1993, name = "Jug of wine", count = 1, how = "Grapes in a jug of water (35 Cooking)" },
                { id = 2007, name = "Spice", count = 1, how = "The spice seller in Ardougne market, or a spice stall (65 Thieving)" },
                { id = 1947, name = "Wheat", count = 1, how = "Pick it in a wheat field" },
                { id = 1931, name = "Empty pot", count = 1, how = "Shape soft clay on a potter's wheel, then fire the pot in a pottery oven (1 Crafting)" },
            },
        },
        methods = {
            ironman = "Bring food: fights up to level 70. Use the standard spellbook. Restoring the mummy fully is optional here, but later quests need it (after Garden of Tranquillity). The scroll, jar and hand are got during the quest",
            main = "Bring food: fights up to level 70. Use the standard spellbook. Restoring the mummy fully is optional here, but later quests need it (after Garden of Tranquillity). The scroll, jar and hand are got during the quest",
        },
    }),
    quest("q-the-feud", 15, "The Feud", {
        methods = {
            ironman = "Bring 1,000 coins (carpets, disguise, beers) and leather gloves to wear (combat gloves work). The disguise and 3 beers are bought in Pollnivneach, and a bucket spawns in Sami's shop. If Isma'il already gave you red hot sauce, bring it: he won't give another. Combat gear for two level 54 fights",
            main = "Bring 1,000 coins (carpets, disguise, beers) and leather gloves to wear (combat gloves work). The disguise and 3 beers are bought in Pollnivneach, and a bucket spawns in Sami's shop. If Isma'il already gave you red hot sauce, bring it: he won't give another. Combat gear for two level 54 fights",
        },
    }),
    quest("q-spirits-of-the-elid", 15, "Spirits of the Elid", {
        requires = {
            items = {
                { id = 563, name = "Law rune", count = 1, how = "Buy from rune shops; for Telekinetic Grab" },
                { id = 556, name = "Air rune", count = 1, how = "Buy from rune shops; for Telekinetic Grab" },
                { id = 954, name = "Rope", count = 1, how = "Ned in Draynor Village: 15 coins or 4 balls of wool" },
                { id = 1734, name = "Thread", count = 2, how = "Pick up thread at the Jolly Boar Inn; one or two, to repair the torn robes" },
            },
        },
        methods = {
            ironman = "Also a light source; a melee weapon for each of stab, crush and slash and a way to attack at range; a pickaxe and knife on the tool belt. The standard spellbook (or Spellbook Swap) for Telekinetic Grab. The Robes of Elidinis are made and worn during the quest",
            main = "Also a light source; a melee weapon for each of stab, crush and slash and a way to attack at range; a pickaxe and knife on the tool belt. The standard spellbook (or Spellbook Swap) for Telekinetic Grab. The Robes of Elidinis are made and worn during the quest",
        },
    }),
    ---------------------------------------------------------------------------
    -- Phase 16: Lumbridge and Varrock, members' quests. The Lost Tribe, Tears
    -- of Guthix, From Tiny Acorns and Lost Her Marbles (Thieves' Guild
    -- miniquests), Once Upon a Time in Gielinor, Garden of Tranquillity (the
    -- ring of charos (a)), Rat Catchers, then A Tail of Two Cats. The game
    -- supplies all prerequisites. From the RuneScape Wiki as of 21 October
    -- 2026.
    ---------------------------------------------------------------------------
    quest("q-lost-tribe", 16, "The Lost Tribe", {
        methods = {
            ironman = "Bring a light source, ideally covered (an oil lantern, a Seer's headband or a bullseye lantern). A pickaxe on the tool belt works",
            main = "Bring a light source, ideally covered (an oil lantern, a Seer's headband or a bullseye lantern). A pickaxe on the tool belt works",
        },
    }),
    quest("q-tears-of-guthix", 16, "Tears of Guthix", {
        wiki = W .. "Tears_of_Guthix_(quest)",
        requires = {
            items = {
                { id = 4548, ids = { 4548, 4550 }, name = "Bullseye lantern (oil)", count = 1, how = "The Lorehound gives one at 50 quest points; or make it (20 Smithing, 49 Crafting)" },
                { id = 1607, name = "Sapphire", count = 1, how = "Cut an uncut sapphire (20 Crafting)" },
            },
        },
        methods = {
            ironman = "Ironman: 20 Smithing, and 49 Crafting to make the lantern or 50 quest points for the Lorehound's. Also a rope if it's your first time in the Lumbridge Swamp Caves and you don't go in from Lumbridge Castle. Take off your weapon and shield before telling Juna a story",
            main = "Also a rope if it's your first time in the Lumbridge Swamp Caves and you don't go in from Lumbridge Castle. Take off your weapon and shield before telling Juna a story",
        },
    }),
    quest("q-from-tiny-acorns", 16, "From Tiny Acorns", {
        wiki = W .. "From_Tiny_Acorns_(miniquest)",
        methods = {
            ironman = "Miniquest. No items",
            main = "Miniquest. No items",
        },
    }),
    quest("q-lost-her-marbles", 16, "Lost Her Marbles", {
        wiki = W .. "Lost_Her_Marbles_(miniquest)",
        methods = {
            ironman = "Miniquest. No items",
            main = "Miniquest. No items",
        },
    }),
    quest("q-once-upon-a-time", 16, "Once Upon a Time in Gielinor", {
        methods = {
            ironman = "No items or coins. Its Fortunes part is a safe fight that allows no food or gear",
            main = "No items or coins. Its Fortunes part is a safe fight that allows no food or gear",
        },
    }),
    quest("q-garden-of-tranquillity", 16, "Garden of Tranquillity", {
        requires = {
            items = {
                { id = 6032, ids = { 6032, 6034 }, name = "Bucket of compost", count = 2, how = "Make compost in a compost bin; or supercompost" },
                { id = 1436, ids = { 1436, 7936 }, name = "Rune or pure essence", count = 1, how = "Mine at the Rune Essence Mine via an essence teleport; members mine pure essence from 30 Mining. Crush it into rune dust during the quest" },
                { id = 6036, name = "Plant cure", count = 2, how = "A farming shop, 40 coins; the Cure Plant spell won't do" },
                { id = 307, ids = { 307, 309 }, name = "Fishing rod", count = 1, how = "Buy from a fishing shop; a fly fishing rod also works, but not an oily rod or the tool belt's" },
                { id = 5354, name = "Plant pot (filled)", count = 1, how = "Farming shops in Catherby, Port Phasmatys, Ardougne and south of Falador, 1 coin" },
            },
        },
        methods = {
            ironman = "Also a ring of charos to wear (pickpocket Dr Fenkenstrain after Creature of Fenkenstrain) and a watering can. The seeds can be got during the quest. Secateurs on the tool belt",
            main = "Also a ring of charos to wear (pickpocket Dr Fenkenstrain after Creature of Fenkenstrain) and a watering can. The seeds can be got during the quest. Secateurs on the tool belt",
        },
    }),
    quest("q-rat-catchers", 16, "Rat Catchers", {
        requires = {
            items = {
                { id = 24, name = "Rat poison", count = 1, how = "Found in the Clock Tower Dungeon (north-west section); or made in the quest from an empty vial, clean kwuarm and red spiders' eggs" },
                { id = 1985, name = "Cheese", count = 4, how = "Wydin's Food Store in Port Sarim; or a bucket of milk at a dairy churn (48 Cooking)" },
                { id = 235, name = "Unicorn horn dust", count = 1, how = "A unicorn horn ground with a pestle and mortar" },
                { id = 251, name = "Clean marrentill", count = 1, how = "Zahur in Nardah cleans grimy herbs" },
                { id = 1927, name = "Bucket of milk", count = 1, how = "Milk a dairy cow with an empty bucket" },
                { id = 6771, name = "Pot of weeds", count = 1, how = "An empty pot with weeds raked from a farming patch" },
            },
        },
        methods = {
            ironman = "Also your cat or hellcat following you (not an overgrown cat at first), a catspeak amulet to wear, and about 600 coins (about 300 with the ring of charos (a)). The snake charm can be got during the quest. Your cat may die on this quest",
            main = "Also your cat or hellcat following you (not an overgrown cat at first), a catspeak amulet to wear, and about 600 coins (about 300 with the ring of charos (a)). The snake charm can be got during the quest. Your cat may die on this quest",
        },
    }),
    quest("q-tail-of-two-cats", 16, "A Tail of Two Cats", {
        requires = {
            items = {
                { id = 560, name = "Death rune", count = 5, how = "Ironman: trade an adult cat to a civilian in West Ardougne, or a Slayer shop (crafting needs Mourning's End Part II)" },
                { id = 1897, name = "Chocolate cake", count = 1, how = "A reward from Gertrude's Cat, or bake one (50 Cooking); don't eat it" },
                { id = 1927, name = "Bucket of milk", count = 1, how = "Milk a dairy cow with an empty bucket" },
                { id = 227, ids = { 227, 229 }, name = "Vial of water (or an empty vial)", count = 1, how = "Fill a vial at a fountain or sink; a vial is more reliable: a sink is right where it's needed, and water dries up in the desert" },
            },
        },
        methods = {
            ironman = "Also your cat following you and a catspeak amulet to wear (not a cramulet), and white robes to wear (desert shirt and robe, or druid's robes). Logs and potato seeds can be got near Unferth's house. Shears on the tool belt",
            main = "Also your cat following you and a catspeak amulet to wear (not a cramulet), and white robes to wear (desert shirt and robe, or druid's robes). Logs and potato seeds can be got near Unferth's house. Shears on the tool belt",
        },
    }),
    ---------------------------------------------------------------------------
    -- Phase 17: Keldagrim and Dorgesh-Kaan. Death to the Dorgeshuun, The Giant
    -- Dwarf, Forgettable Tale of a Drunken Dwarf, Between a Rock..., Another
    -- Slice of H.A.M., Land of the Goblins, then The Chosen Commander. The
    -- game supplies all prerequisites. From the RuneScape Wiki as of 21
    -- October 2026.
    ---------------------------------------------------------------------------
    quest("q-death-to-the-dorgeshuun", 17, "Death to the Dorgeshuun", {
        requires = {
            items = {
                { id = 4302, name = "H.A.M. hood", count = 2, how = "Ironman: pickpocket H.A.M. members or H.A.M. Guard drops; one set may be worn" },
                { id = 4298, name = "H.A.M. shirt", count = 2, how = "Ironman: pickpocket H.A.M. members or H.A.M. Guard drops; one set may be worn" },
                { id = 4300, name = "H.A.M. robe", count = 2, how = "Ironman: pickpocket H.A.M. members or H.A.M. Guard drops; one set may be worn" },
                { id = 4308, name = "H.A.M. gloves", count = 2, how = "Ironman: pickpocket H.A.M. members or H.A.M. Guard drops; one set may be worn" },
                { id = 4310, name = "H.A.M. boots", count = 2, how = "Ironman: pickpocket H.A.M. members or H.A.M. Guard drops; one set may be worn" },
                { id = 4304, name = "H.A.M. cloak", count = 2, how = "Ironman: pickpocket H.A.M. members or H.A.M. Guard drops; one set may be worn" },
                { id = 4306, name = "H.A.M. logo", count = 2, how = "Ironman: pickpocket H.A.M. members or H.A.M. Guard drops; one set may be worn" },
            },
        },
        methods = {
            ironman = "Also a light source and a melee, magic or necromancy weapon. One H.A.M. set is worn at the hideout",
            main = "Also a light source and a melee, magic or necromancy weapon. One H.A.M. set is worn at the hideout",
        },
    }),
    quest("q-giant-dwarf", 17, "The Giant Dwarf", {
        requires = {
            items = {
                { id = 1511, ids = { 1511, 1521, 1519, 6333, 1517, 40285, 6332, 1515, 1513, 29556, 58250 }, name = "Logs (any)", count = 1, how = "Any logs you can set fire to; dead trees are right outside the cave" },
                { id = 453, name = "Coal", count = 1, how = "Rocks in the north-east of Keldagrim" },
                { id = 2351, name = "Iron bar", count = 1, how = "Smelt iron ore at a furnace (10 Smithing); for Thurgo" },
                { id = 563, name = "Law rune", count = 1, how = "Buy from rune shops; for Telekinetic Grab" },
                { id = 556, name = "Air rune", count = 1, how = "Buy from rune shops; for Telekinetic Grab" },
                { id = 1607, name = "Sapphire", count = 3, how = "Cut uncut sapphires (20 Crafting)" },
            },
        },
        methods = {
            ironman = "Ironman: 20 Mining and 10 Smithing. Also 200 coins (about 10,000 is recommended for the delivery tasks, which may need about 10 of various ores and clay in the bank) and a tinderbox on the tool belt. The standard spellbook for Telekinetic Grab, and weigh under 30 kg",
            main = "Also 200 coins (about 10,000 is recommended for the delivery tasks, which may need about 10 of various ores and clay in the bank) and a tinderbox on the tool belt. The standard spellbook for Telekinetic Grab, and weigh under 30 kg",
        },
    }),
    quest("q-forgettable-tale", 17, "Forgettable Tale of a Drunken Dwarf", {
        requires = {
            items = {
                { id = 6008, name = "Barley malt", count = 2, how = "Barley on a range" },
                { id = 1929, name = "Bucket of water", count = 2, how = "Fill buckets at a water source; two buckets; refilling one doesn't count" },
                { id = 1917, name = "Beer", count = 2, how = "The Laughing Miner or the King's Axe Inn in Keldagrim, 2 coins" },
                { id = 1919, name = "Beer glass", count = 1, how = "Or buy a third beer and drink it (with empty glasses kept)" },
                { id = 1971, name = "Kebab", count = 1, how = "Kjut in Keldagrim, south-east of the north bridge" },
            },
        },
        methods = {
            ironman = "Also about 400 coins and a rake on the tool belt. The empty pot can be got during the quest",
            main = "Also about 400 coins and a rake on the tool belt. The empty pot can be got during the quest",
        },
    }),
    quest("q-between-a-rock", 17, "Between a Rock...", {
        requires = {
            items = {
                { id = 2357, name = "Gold bar", count = 4, how = "Gold ore at a furnace (40 Smithing); 3 must be in the backpack, not the metal bank" },
            },
        },
        methods = {
            ironman = "Also 50 coins and an ammo mould (the tool belt one works). The gold helmet is made and worn during the quest. Fights up to level 56",
            main = "Also 50 coins and an ammo mould (the tool belt one works). The gold helmet is made and worn during the quest. Fights up to level 56",
        },
    }),
    quest("q-another-slice-of-ham", 17, "Another Slice of H.A.M.", {
        methods = {
            ironman = "Bring a light source (not a bug lantern) and magic, ranged or necromancy gear: the level 28 H.A.M. mage and archer can't be hurt by melee. A rope if you've never entered the Lumbridge Swamp Caves from the surface. Keep 3 to 8 backpack spaces free",
            main = "Bring a light source (not a bug lantern) and magic, ranged or necromancy gear: the level 28 H.A.M. mage and archer can't be hurt by melee. A rope if you've never entered the Lumbridge Swamp Caves from the surface. Keep 3 to 8 backpack spaces free",
        },
    }),
    quest("q-land-of-the-goblins", 17, "Land of the Goblins", {
        requires = {
            items = {
                { id = 3002, name = "Toadflax potion (unf)", count = 1, how = "A clean toadflax in a vial of water" },
                { id = 288, name = "Goblin mail", count = 1, how = "Any colour; goblins drop it, and three are in crates in Goblin Village" },
                { id = 1765, name = "Yellow dye", count = 1, how = "Take 2 onions to Aggie (5 coins) or Rana the dyer (25 coins)" },
                { id = 1767, name = "Blue dye", count = 1, how = "2 woad leaves to Aggie (5 coins) or Rana (25); woad leaves from Wyson in Falador Park" },
                { id = 1769, name = "Orange dye", count = 1, how = "Red dye and yellow dye combined" },
                { id = 1773, name = "Purple dye", count = 1, how = "Blue dye and red dye combined; one respawns north of the battlefield, near the spirit tree south of East Ardougne" },
                { id = 3379, name = "Raw slimy eel", count = 1, how = "A regular fishing rod and fishing bait catch them" },
            },
        },
        methods = {
            ironman = "Also 5 coins (Aggie, for the bleach), a light source, an empty vial for the black mushroom ink, and room in the backpack to take off everything you wear. The ink and the whitefish are got during the quest. Ironman: clean toadflax from the Brimhaven Agility Arena",
            main = "Also 5 coins (Aggie, for the bleach), a light source, an empty vial for the black mushroom ink, and room in the backpack to take off everything you wear. The ink and the whitefish are got during the quest",
        },
    }),
    quest("q-chosen-commander", 17, "The Chosen Commander", {
        methods = {
            ironman = "Bring a light source (a covered one stays lit if you fall in the swamp cave water). A new H.A.M. outfit is given; wear only it at the hideout. Keep 5,000 coins in case you accuse the wrong merchant. Fights up to level 75",
            main = "Bring a light source (a covered one stays lit if you fall in the swamp cave water). A new H.A.M. outfit is given; wear only it at the hideout. Keep 5,000 coins in case you accuse the wrong merchant. Fights up to level 75",
        },
    }),
    ---------------------------------------------------------------------------
    -- Phase 18: Morytania, first part, and Rum Deal. Shades of Mort'ton (its
    -- temple makes the sacred oil Legacy of Seergaze needs), The Darkness of
    -- Hallowvale, Haunted Mine, Lair of Tarn Razorlor (miniquest), Legacy of
    -- Seergaze, then Rum Deal and Cabin Fever at Port Phasmatys. The game
    -- supplies all prerequisites. From the RuneScape Wiki as of 21 October
    -- 2026.
    ---------------------------------------------------------------------------
    quest("q-shades-of-mortton", 18, "Shades of Mort'ton", {
        methods = {
            ironman = "Bring 1,000 or more coins and spare clean tarromin (the quest's drop is uncommon). The vials, ashes, tarromin and logs can be got during the quest. Five level 58 shades",
            main = "Bring 1,000 or more coins and spare clean tarromin (the quest's drop is uncommon). The vials, ashes, tarromin and logs can be got during the quest. Five level 58 shades",
        },
    }),
    quest("q-darkness-of-hallowvale", 18, "The Darkness of Hallowvale", {
        requires = {
            items = {
                { id = 4820, ids = { 4819, 4820, 1539, 4821, 4822, 4823 }, name = "Nails (not rune)", count = 8, how = "Any metal but rune; 75 per bar at an anvil" },
                { id = 960, ids = { 960, 8778, 8780, 8782 }, name = "Plank", count = 2, how = "Normal, oak, teak or mahogany; the sawmill or plank maker in Rimmington" },
            },
        },
        methods = {
            ironman = "The standard spellbook for Telekinetic Grab; its law and air runes, the charcoal and the papyrus are got during the quest. No fighting",
            main = "The standard spellbook for Telekinetic Grab; its law and air runes, the charcoal and the papyrus are got during the quest. No fighting",
        },
    }),
    quest("q-haunted-mine", 18, "Haunted Mine", {
        methods = {
            ironman = "No items. One fight, level 63",
            main = "No items. One fight, level 63",
        },
    }),
    quest("q-lair-of-tarn", 18, "Lair of Tarn Razorlor", {
        wiki = W .. "Lair_of_Tarn_Razorlor_(miniquest)",
        methods = {
            ironman = "Miniquest. No items; bring combat gear and food for Tarn (level 79, two forms)",
            main = "Miniquest. No items; bring combat gear and food for Tarn (level 79, two forms)",
        },
    }),
    quest("q-legacy-of-seergaze", 18, "Legacy of Seergaze", {
        requires = {
            items = {
                { id = 6211, ids = { 6211, 10808, 3444, 6213, 12583, 3446, 3448, 29635 }, name = "Pyre logs (teak or higher)", count = 1,
                  how = "Three doses of sacred oil (made in Shades of Mort'ton) on teak logs (30 Woodcutting); 40 Firemaking to light" },
            },
        },
        methods = {
            ironman = "Ironman: Shades of Mort'ton started, to make the sacred oil for teak pyre logs. Bring combat gear (fights up to level 77). The nails, coal, enchanting runes, mithril and silver bars, blessed sickle and emerald are got during the quest",
            main = "Bring combat gear (fights up to level 77). The nails, coal, enchanting runes, mithril and silver bars, blessed sickle and emerald are got during the quest",
        },
    }),
    quest("q-rum-deal", 18, "Rum Deal", {
        methods = {
            ironman = "Bring armour and food: a level 56 melee monster and a level 70 ranged one",
            main = "Bring armour and food: a level 56 melee monster and a level 70 ranged one",
        },
    }),
    quest("q-cabin-fever", 18, "Cabin Fever", {
        methods = {
            ironman = "No items: everything comes from the ship's lockers. The level 26 pirates attack whatever your level",
            main = "No items: everything comes from the ship's lockers. The level 26 pirates attack whatever your level",
        },
    }),
    ---------------------------------------------------------------------------
    -- Phase 19: the Elder God Wars begin, and Anachronia. You Are It, The
    -- Needle Skips, Desperate Times, Desperate Measures, Desperate Creatures,
    -- Raksha (quest), Father and Son and Benedict's World Tour (miniquests).
    -- The Anachronia base camp tutorial isn't a quest and can't be read, so
    -- the tips of the quests that need it say so. The game supplies the rest.
    -- From the RuneScape Wiki as of 21 October 2026.
    ---------------------------------------------------------------------------
    quest("q-you-are-it", 19, "You Are It", {
        requires = {
            items = {
                { id = 954, name = "Rope", count = 1, how = "Ned in Draynor Village: 15 coins or 4 balls of wool; or the Lorehound" },
            },
        },
        methods = {
            ironman = "Wear nothing at all for the Duke Horacio step. No fighting",
            main = "Wear nothing at all for the Duke Horacio step. No fighting",
        },
    }),
    quest("q-needle-skips", 19, "The Needle Skips", {
        methods = {
            ironman = "No items or fighting",
            main = "No items or fighting",
        },
    }),
    quest("q-desperate-times", 19, "Desperate Times", {
        requires = {
            items = {
                { id = 2363, name = "Rune bar", count = 3, how = "Runite ore and luminite at a furnace (50 Smithing)" },
                { id = 44808, name = "Runite stone spirit", count = 2, how = "Magpie implings (65 Hunter) or King Black Dragon drops; keep in your backpack, not an ore box" },
                { id = 558, name = "Mind rune", count = 10, how = "Aubury's Rune Shop in Varrock, or the mind altar" },
                { id = 29318, name = "Gleaming energy", count = 10, how = "The gleaming wisp in central Karamja, north-east of the nature altar (50 Divination)" },
            },
        },
        methods = {
            ironman = "Also gear that lets you into the Black Knights' Fortress, or the Skull of Remembrance (The Death of Chivalry) to teleport inside. The old necklace from You Are It turns into the necklace of Charos during the quest. Five level 50 fights",
            main = "Also gear that lets you into the Black Knights' Fortress, or the Skull of Remembrance (The Death of Chivalry) to teleport inside. The old necklace from You Are It turns into the necklace of Charos during the quest. Five level 50 fights",
        },
    }),
    quest("q-desperate-measures", 19, "Desperate Measures", {
        methods = {
            ironman = "First do the Anachronia base camp tutorial (not a quest; board the Stormbreaker at the Varrock Dig Site; no requirements). The 100 orthenglass can be got during the quest (Anachronia's north dig site) and the Measure is given. Both hands empty for Thok's stick. One safe fight, level 91",
            main = "First do the Anachronia base camp tutorial (not a quest; board the Stormbreaker at the Varrock Dig Site; no requirements). The 100 orthenglass can be got during the quest (Anachronia's north dig site) and the Measure is given. Both hands empty for Thok's stick. One safe fight, level 91",
        },
    }),
    quest("q-desperate-creatures", 19, "Desperate Creatures", {
        methods = {
            ironman = "No items or fighting",
            main = "No items or fighting",
        },
    }),
    quest("q-raksha-quest", 19, "Raksha, the Shadow Colossus", {
        wiki = W .. "Raksha,_the_Shadow_Colossus_(quest)",
        methods = {
            ironman = "First do the Anachronia base camp tutorial (not a quest; board the Stormbreaker at the Varrock Dig Site; no requirements). No items; some food if you have under 1,000 life points",
            main = "First do the Anachronia base camp tutorial (not a quest; board the Stormbreaker at the Varrock Dig Site; no requirements). No items; some food if you have under 1,000 life points",
        },
    }),
    quest("q-father-and-son", 19, "Father and Son", {
        wiki = W .. "Father_and_Son_(miniquest)",
        methods = {
            ironman = "First do the Anachronia base camp tutorial (not a quest; board the Stormbreaker at the Varrock Dig Site; no requirements). Miniquest. No items",
            main = "First do the Anachronia base camp tutorial (not a quest; board the Stormbreaker at the Varrock Dig Site; no requirements). Miniquest. No items",
        },
    }),
    quest("q-benedicts-world-tour", 19, "Benedict's World Tour", {
        wiki = W .. "Benedict's_World_Tour_(miniquest)",
        methods = {
            ironman = "Miniquest. No items. Needs Stolen Hearts started and the Anachronia base camp tutorial started (board the Stormbreaker at the Varrock Dig Site). 7 of its 16 places are members-only",
            main = "Miniquest. No items. Needs Stolen Hearts started and the Anachronia base camp tutorial started (board the Stormbreaker at the Varrock Dig Site). 7 of its 16 places are members-only",
        },
    }),
    ---------------------------------------------------------------------------
    -- Phase 20: the Fremennik Province, first part. Bar Crawl (miniquest),
    -- Horror from the Deep, Mountain Daughter, Olaf's Quest, The Tale of the
    -- Muspah, then Throne of Miscellania and Royal Trouble on Miscellania.
    -- The game supplies all prerequisites. From the RuneScape Wiki as of 21
    -- October 2026.
    ---------------------------------------------------------------------------
    quest("q-bar-crawl", 20, "Bar Crawl", {
        wiki = W .. "Bar_Crawl_(miniquest)",
        methods = {
            ironman = "Miniquest. Bring 208 coins for the drinks, plus fares and teleports between the bars",
            main = "Miniquest. Bring 208 coins for the drinks, plus fares and teleports between the bars",
        },
    }),
    quest("q-horror-from-the-deep", 20, "Horror from the Deep", {
        requires = {
            items = {
                { id = 1539, name = "Steel nails", count = 60, how = "75 from a steel bar at an anvil (20 Smithing)" },
                { id = 1775, name = "Molten glass", count = 1, how = "A bucket of sand and soda ash at a furnace, or Superglass Make" },
                { id = 1939, name = "Swamp tar", count = 1, how = "Spawns in Lumbridge Swamp" },
                { id = 554, name = "Fire rune", count = 1, how = "Buy from rune shops; lost during the quest" },
                { id = 555, name = "Water rune", count = 1, how = "Buy from rune shops; lost during the quest" },
                { id = 557, name = "Earth rune", count = 1, how = "Buy from rune shops; lost during the quest" },
                { id = 556, name = "Air rune", count = 1, how = "Buy from rune shops; lost during the quest" },
            },
        },
        methods = {
            ironman = "Also a sword and an arrow of any kind you're willing to lose (not ogre or training arrows). The 2 planks can be got just north of the Barbarian Outpost. Fights up to level 100",
            main = "Also a sword and an arrow of any kind you're willing to lose (not ogre or training arrows). The 2 planks can be got just north of the Barbarian Outpost. Fights up to level 100",
        },
    }),
    quest("q-mountain-daughter", 20, "Mountain Daughter", {
        requires = {
            items = {
                { id = 954, name = "Rope", count = 1, how = "Ned in Draynor Village: 15 coins or 4 balls of wool" },
            },
        },
        methods = {
            ironman = "Also leather gloves to wear (most gloves work). The rope is needed just to climb into the camp. The plank, pole and muddy rocks can be got in the camp",
            main = "Also leather gloves to wear (most gloves work). The rope is needed just to climb into the camp. The plank, pole and muddy rocks can be got in the camp",
        },
    }),
    quest("q-olafs-quest", 20, "Olaf's Quest", {
        methods = {
            ironman = "No items; an axe and tinderbox on the tool belt. Fights up to level 49",
            main = "No items; an axe and tinderbox on the tool belt. Fights up to level 49",
        },
    }),
    quest("q-tale-of-the-muspah", 20, "The Tale of the Muspah", {
        methods = {
            ironman = "Bring 4 cut sapphires, or mine and cut them in the cave during the quest (20 Crafting). Lvl-1 Enchant cast 8 times: 8 cosmic and 8 water runes, 8 cosmic runes and a water staff, or 8 Lvl-1 enchant tablets",
            main = "Bring 4 cut sapphires, or mine and cut them in the cave during the quest (20 Crafting). Lvl-1 Enchant cast 8 times: 8 cosmic and 8 water runes, 8 cosmic runes and a water staff, or 8 Lvl-1 enchant tablets",
        },
    }),
    quest("q-throne-of-miscellania", 20, "Throne of Miscellania", {
        requires = {
            items = {
                { id = 2351, name = "Iron bar", count = 1, how = "Iron ore at a furnace (10 Smithing)" },
                { id = 1635, ids = { 1635, 1637, 1639, 1641, 1643, 1645, 2570 }, name = "Metal ring", count = 1, how = "Cast a gold bar with a ring mould at a furnace (5 Crafting); a gold, sapphire, emerald, ruby, diamond or dragonstone ring, or ring of life works" },
            },
        },
        methods = {
            ironman = "Also a cake if you'll woo Prince Brand, or any bow you'll lose if you'll woo Princess Astrid. Logs and flowers (15 coins each, from the Flower Girl) can be got on the island. 75% approval is needed",
            main = "Also a cake if you'll woo Prince Brand, or any bow you'll lose if you'll woo Princess Astrid. Logs and flowers (15 coins each, from the Flower Girl) can be got on the island. 75% approval is needed",
        },
    }),
    quest("q-royal-trouble", 20, "Royal Trouble", {
        methods = {
            ironman = "No items: the coal and ropes are got during the quest. One fight, a level 63 sea snake that poisons",
            main = "No items: the coal and ropes are got during the quest. One fight, a level 63 sea snake that poisons",
        },
    }),
    ---------------------------------------------------------------------------
    -- Phase 21: Karamja and Feldip. Tribal Totem, Jungle Potion, Tai Bwo
    -- Wannai Trio, Shilo Village, One Small Favour, Zogre Flesh Eaters, then
    -- As a First Resort. The game supplies all prerequisites. From the
    -- RuneScape Wiki as of 21 October 2026.
    ---------------------------------------------------------------------------
    quest("q-tribal-totem", 21, "Tribal Totem", {
        methods = {
            ironman = "No items; about 90 coins is recommended (the ship to Ardougne is 30). No fighting",
            main = "No items; about 90 coins is recommended (the ship to Ardougne is 30). No fighting",
        },
    }),
    quest("q-jungle-potion", 21, "Jungle Potion", {
        methods = {
            ironman = "No items: the five herbs are found and cleaned during the quest. Be able to fend off monsters up to level 63",
            main = "No items: the five herbs are found and cleaned during the quest. Be able to fend off monsters up to level 63",
        },
    }),
    quest("q-tai-bwo-wannai-trio", 21, "Tai Bwo Wannai Trio", {
        requires = {
            items = {
                { id = 3032, name = "Agility potion (4)", count = 1, how = "1. Mix toadflax and toad's legs in a vial of water (34 Herblore).\n2. Combine doses to make a four-dose potion." },
                { id = 1239, ids = { 1239, 1241, 1243, 1245, 1247, 1249 }, name = "Spear (iron or better)", count = 1, how = "Used up; Scavvo's Rune Store sells a rune spear" },
            },
        },
        methods = {
            ironman = "Ironman: make the agility potion (34 Herblore); 65 Fishing only if you burn the karambwan you're given. Also the Karamjan rum, bought on Karamja (Zembo at Musa Point): it can't leave the island or be teleported with. The karambwanji, sliced banana, seaweed and jogre bones are got during the quest",
            main = "Also the Karamjan rum, bought on Karamja (Zembo at Musa Point): it can't leave the island or be teleported with. The karambwanji, sliced banana, seaweed and jogre bones are got during the quest",
        },
    }),
    quest("q-shilo-village", 21, "Shilo Village", {
        requires = {
            items = {
                { id = 1794, ids = { 1794, 2349 }, name = "Bronze wire (or a bronze bar)", count = 1, how = "A bronze bar on an anvil; one is just north of the village" },
                { id = 954, name = "Rope", count = 1, how = "Jiminua's Jungle Store sells it" },
                { id = 1755, name = "Chisel", count = 1, how = "A real one: the tool belt's won't do for the bone beads; Jiminua's Jungle Store sells it" },
            },
        },
        methods = {
            ironman = "Also any light source, which you'll lose. The 3 bones are got during the quest. The beads of the dead are made and worn during it. Fights up to level 53",
            main = "Also any light source, which you'll lose. The 3 bones are got during the quest. The beads of the dead are made and worn during it. Fights up to level 53",
        },
    }),
    quest("q-one-small-favour", 21, "One Small Favour", {
        requires = {
            items = {
                { id = 2353, name = "Steel bar", count = 4, how = "Un-noted; iron ore and coal at a furnace (20 Smithing)" },
                { id = 2349, name = "Bronze bar", count = 1, how = "Smelt copper and tin ore at a furnace; for the weather vane" },
                { id = 2351, name = "Iron bar", count = 1, how = "Smelt iron ore at a furnace (10 Smithing); for the weather vane" },
                { id = 1931, name = "Empty pot", count = 1, how = "Shape a pot on a potter's wheel, then fire it in an oven (1 Crafting); sealed into an airtight pot during the quest" },
                { id = 251, name = "Clean marrentill", count = 1, how = "Clean a grimy marrentill (9 Herblore)" },
                { id = 255, name = "Clean harralander", count = 1, how = "Clean a grimy harralander (20 Herblore)" },
                { id = 227, name = "Vial of water", count = 1, how = "A vial on a water source, or a store" },
            },
        },
        methods = {
            ironman = "Ironman: 20 Herblore to clean the harralander, 20 Mining for the coal. The pigeon cages are got south of the Ardougne north bank during the quest. Coins for Captain Shanks' ticket (26-45). Fights up to level 63",
            main = "The pigeon cages are got south of the Ardougne north bank during the quest. Coins for Captain Shanks' ticket (26-45). Fights up to level 63",
        },
    }),
    quest("q-zogre-flesh-eaters", 21, "Zogre Flesh Eaters", {
        methods = {
            ironman = "No items; keep about 10 backpack spaces free. Fights up to level 58",
            main = "No items; keep about 10 backpack spaces free. Fights up to level 58",
        },
    }),
    quest("q-as-a-first-resort", 21, "As a First Resort", {
        requires = {
            items = {
                { id = 10008, name = "Box trap", count = 1, how = "Aleck's Hunter Emporium in Yanille, 38 coins" },
                { id = 10006, name = "Bird snare", count = 1, how = "Aleck in Yanille, Artimeus in Nardah, Ayleth Beaststalker in Taverley" },
                { id = 10029, name = "Teasing stick", count = 1, how = "Buy from a Hunter shop; not needed only if buying the 8 larupia furs" },
                { id = 5016, ids = { 5016, 1237, 1239, 1241, 1243, 1245, 1247, 1249 }, name = "Spears (all one type)", count = 4, oneKind = true, how = "Bone spears work (Nardok's Bone Weapons after The Lost Tribe); not poisoned or leaf-bladed" },
                { id = 1511, ids = { 1511, 1521, 1519, 6333, 1517, 40285, 6332, 1515, 1513, 29556, 58250 }, name = "Logs (any)", count = 1, how = "Cut the appropriate trees; for the traps" },
            },
        },
        methods = {
            ironman = "Ironman: Big Chompy Bird Hunting started. The logs, chompies, feathers, bones, furs and plants are got around Oo'glog. Take off your main-hand weapon for the smouldering method. Avoid the level 11 wolves if low level",
            main = "The logs, chompies, feathers, bones, furs and plants are got around Oo'glog. Take off your main-hand weapon for the smouldering method. Avoid the level 11 wolves if low level",
        },
    }),
    ---------------------------------------------------------------------------
    -- Phase 22: Kandarin, second part. Elemental Workshop III and IV,
    -- Scorpion Catcher, King's Ransom, Making History, Meeting History, The
    -- Hand in the Sand, then Watchtower. The game supplies all prerequisites.
    -- From the RuneScape Wiki as of 21 October 2026.
    ---------------------------------------------------------------------------
    quest("q-elemental-workshop-3", 22, "Elemental Workshop III", {
        requires = {
            items = {
                { id = 453, name = "Coal", count = 12, how = "Un-noted, not in an ore box; the coal trucks west of Seers' Village" },
            },
        },
        methods = {
            ironman = "The 3 elemental ores and the soft clay can be got in the workshop. Three level 44 earth elementals. Below 66 Defence, bring Defence or restore potions",
            main = "The 3 elemental ores and the soft clay can be got in the workshop. Three level 44 earth elementals. Below 66 Defence, bring Defence or restore potions",
        },
    }),
    quest("q-elemental-workshop-4", 22, "Elemental Workshop IV", {
        requires = {
            items = {
                { id = 555, name = "Water rune", count = 1, how = "Buy from rune shops; about 5 each is advised; one of each is used" },
                { id = 557, name = "Earth rune", count = 1, how = "Buy from rune shops; about 5 each is advised; one of each is used" },
                { id = 556, name = "Air rune", count = 1, how = "Buy from rune shops; about 5 each is advised; one of each is used" },
                { id = 554, name = "Fire rune", count = 1, how = "Buy from rune shops; about 5 each is advised; one of each is used" },
                { id = 453, name = "Coal", count = 8, how = "Mine coal rocks (20 Mining); carried, un-noted, not in an ore box; 28 for the full chaos set" },
            },
        },
        methods = {
            ironman = "Also a real knife: the tool belt's won't work (one lies by the bookcase). The elemental ores are got in the quest, and the cosmic gloves are made and worn in it",
            main = "Also a real knife: the tool belt's won't work (one lies by the bookcase). The elemental ores are got in the quest, and the cosmic gloves are made and worn in it",
        },
    }),
    quest("q-scorpion-catcher", 22, "Scorpion Catcher", {
        methods = {
            ironman = "No items: the dusty key is got during the quest (not needed with 70 Agility). One level 39 fight; antipoison helps",
            main = "No items: the dusty key is got during the quest (not needed with 70 Agility). One level 39 fight; antipoison helps",
        },
    }),
    quest("q-kings-ransom", 22, "King's Ransom", {
        requires = {
            items = {
                { id = 6979, ids = { 6979, 6981, 6983, 6583 }, name = "Granite (any) or a ring of stone", count = 1, how = "Granite is mined at the Desert Quarry" },
            },
        },
        methods = {
            ironman = "1. Also an iron chainbody and a bronze med helm to wear into the fortress (a helm respawns in Draynor Manor's south-east corner).\n2. The standard spellbook and 33 Magic for Telekinetic Grab (its runes are given), or a lockpick on the tool belt.\n3. The animate rock scroll is given unless you have one in the bank",
            main = "1. Also an iron chainbody and a bronze med helm to wear into the fortress (a helm respawns in Draynor Manor's south-east corner).\n2. The standard spellbook and 33 Magic for Telekinetic Grab (its runes are given), or a lockpick on the tool belt.\n3. The animate rock scroll is given unless you have one in the bank",
        },
    }),
    quest("q-making-history", 22, "Making History", {
        requires = {
            items = {
                { id = 952, name = "Spade", count = 1, how = "A real one: the tool belt's can't dig; Richard's Farming Shop sells them" },
                { id = 1694, name = "Sapphire amulet (strung)", count = 1, how = "Gold bar, cut sapphire and an amulet mould at a furnace (24 Crafting), then strung; un-enchanted" },
            },
        },
        methods = {
            ironman = "Ironman: 24 Crafting to make the sapphire amulet. Also a ghostspeak amulet to wear (not needed after the hard Morytania achievements). Port Phasmatys by ecto-tokens or the charter ship; Ghosts Ahoy done is enough",
            main = "Also a ghostspeak amulet to wear (not needed after the hard Morytania achievements). Port Phasmatys by ecto-tokens or the charter ship; Ghosts Ahoy done is enough",
        },
    }),
    quest("q-meeting-history", 22, "Meeting History", {
        methods = {
            ironman = "Nothing worn or carried but the enchanted key (Jorral gives it again if lost, and banks the rest)",
            main = "Nothing worn or carried but the enchanted key (Jorral gives it again if lost, and banks the rest)",
        },
    }),
    quest("q-hand-in-the-sand", 22, "The Hand in the Sand", {
        requires = {
            items = {
                { id = 1917, name = "Beer", count = 1, how = "Or 2 coins at the Dragon Inn in Yanille" },
                { id = 1783, ids = { 1783, 1925 }, name = "Bucket of sand (or a bucket)", count = 1, how = "An empty bucket can be filled at Bert's sandpit" },
                { id = 4542, name = "Lantern lens", count = 1, how = "Molten glass and a glassblowing pipe (49 Crafting); not an emerald lens" },
                { id = 557, name = "Earth rune", count = 5, how = "Craft essence at the earth altar north-east of Varrock (9 Runecrafting), or buy from rune shops" },
                { id = 229, name = "Vial", count = 1, how = "Two spawn in Frincos's herb store on Entrana, and one in a Mort'ton house" },
                { id = 1951, name = "Redberries", count = 1, how = "Two wild bushes south-east of Varrock" },
                { id = 239, name = "White berries", count = 1, how = "Grown from a whiteberry seed in a bush patch (59 Farming)" },
            },
        },
        methods = {
            ironman = "Also about 500 coins for boat trips. Bring a second vial for the teleport to Port Sarim",
            main = "Also about 500 coins for boat trips. Bring a second vial for the teleport to Port Sarim",
        },
    }),
    quest("q-watchtower", 22, "Watchtower", {
        requires = {
            items = {
                { id = 536, name = "Dragon bones", count = 1, how = "Dropped by most adult dragons" },
                { id = 2391, ids = { 2391, 530 }, name = "Ground bat bones (or bat bones)", count = 1, how = "Bat bones ground with a pestle and mortar; bats drop them" },
                { id = 91, name = "Guam potion (unf)", count = 1, how = "A clean guam in a vial of water" },
                { id = 954, name = "Rope", count = 1, how = "Get rope from Ned in Draynor Village; one of the two; the other spawns on Toban's island" },
                { id = 2357, name = "Gold bar", count = 1, how = "Gold ore at a furnace (40 Smithing); a separate one from Toban's" },
            },
        },
        methods = {
            ironman = "Also 20 coins for the bridge and armoured gloves to wear (they need an armour bonus). The light source, jangerberries, death rune and cave nightshade can be got during the quest; Toban's gold bar only counts for Og. One level 53 fight",
            main = "Also 20 coins for the bridge and armoured gloves to wear (they need an armour bonus). The light source, jangerberries, death rune and cave nightshade can be got during the quest; Toban's gold bar only counts for Og. One level 53 fight",
        },
    }),
    ---------------------------------------------------------------------------
    -- Phase 23: Varrock members' quests, second part. The Dig Site, What Lies
    -- Below, All Fired Up, Rag and Bone Man, Fur 'n Seek, Family Crest, then
    -- Tortle Combat (miniquest; needs the player-owned farm tutorial, which
    -- isn't a quest, so its tip says so). The game supplies the rest. From the
    -- RuneScape Wiki as of 21 October 2026.
    ---------------------------------------------------------------------------
    quest("q-dig-site", 23, "The Dig Site", {
        requires = {
            items = {
                { id = 229, name = "Vial", count = 1, how = "Blow molten glass into a vial with a glassblowing pipe (33 Crafting)" },
                { id = 954, name = "Rope", count = 2, how = "Pickpocket the Dig Site workmen; or Ned in Draynor Village" },
            },
        },
        methods = {
            ironman = "The charcoal, cup of tea and an uncut opal can be got during the quest. No fighting",
            main = "The charcoal, cup of tea and an uncut opal can be got during the quest. No fighting",
        },
    }),
    quest("q-what-lies-below", 23, "What Lies Below", {
        requires = {
            items = {
                { id = 1923, name = "Bowl", count = 1, how = "Shape soft clay on a potter's wheel, then fire the unfired bowl in a pottery oven (8 Crafting)" },
                { id = 562, ids = { 562, 7936 }, name = "Chaos runes or pure essence", count = 15, how = "Craft at the chaos altar (35 Runecrafting), or mine pure essence; bring unnoted, chaos runes stack" },
            },
        },
        methods = {
            ironman = "Also a way into the chaos altar: a chaos talisman, a wicked hood holding it, or the Abyss (Enter the Abyss). Fights up to level 47",
            main = "Also a way into the chaos altar: a chaos talisman, a wicked hood holding it, or the Abyss (Enter the Abyss). Fights up to level 47",
        },
    }),
    quest("q-all-fired-up", 23, "All Fired Up", {
        requires = {
            items = {
                { id = 1511, ids = { 1511, 1521, 1519, 6333, 1517, 6332, 1515, 1513, 29556 }, name = "Logs you can burn", count = 45, how = "Cut the appropriate trees; two sets of 20 and one of 5, each set one kind; not acadia, corrupted or eternal magic logs" },
            },
        },
        methods = {
            ironman = "Seer's headband helps",
            main = "Seer's headband helps",
        },
    }),
    quest("q-rag-and-bone-man", 23, "Rag and Bone Man", {
        requires = {
            items = {
                { id = 1931, name = "Empty pot", count = 8, how = "Shape a pot on a potter's wheel, then fire it in an oven (1 Crafting); pots can be reused" },
            },
        },
        methods = {
            ironman = "Also about 40 coins (vinegar) and any light source. The 8 logs can be got during the quest (bring a hatchet). Fights up to level 23",
            main = "Also about 40 coins (vinegar) and any light source. The 8 logs can be got during the quest (bring a hatchet). Fights up to level 23",
        },
    }),
    quest("q-fur-n-seek", 23, "Fur 'n Seek", {
        requires = {
            items = {
                { id = 4161, ids = { 4161, 4689 }, name = "Bag of salt", count = 9, how = "Any Slayer Master sells them; a pile of salt works too" },
                { id = 1511, ids = { 1511, 1521, 1519, 6333, 1517, 40285, 6332, 1515, 1513, 29556 }, name = "Logs", count = 8, how = "Trees south of the Odd Old Man's hut" },
            },
        },
        methods = {
            ironman = "Also a mirror shield to wear (or a Mask of Stone, Helm of Petrification or sunglasses). Antipoison helps; fights up to level 47",
            main = "Also a mirror shield to wear (or a Mask of Stone, Helm of Petrification or sunglasses). Antipoison helps; fights up to level 47",
        },
    }),
    quest("q-family-crest", 23, "Family Crest", {
        requires = {
            items = {
                { id = 315, name = "Shrimps", count = 1, how = "Cook raw shrimps on a fire or range (1 Cooking)" },
                { id = 329, name = "Salmon", count = 1, how = "Cook raw salmon on a fire or range (25 Cooking)" },
                { id = 361, name = "Tuna", count = 1, how = "Cook raw tuna on a fire or range (30 Cooking)" },
                { id = 365, name = "Bass", count = 1, how = "Cook raw bass on a fire or range (43 Cooking)" },
                { id = 373, name = "Swordfish", count = 1, how = "Cook raw swordfish on a fire or range (45 Cooking)" },
                { id = 1603, name = "Ruby", count = 2, how = "Cut; uncut rubies from the Al Kharid mine's gem rock" },
                { id = 2446, ids = { 179, 177, 175, 2446, 185, 183, 181, 2448 }, name = "Antipoison (any)", count = 1, how = "Any dose; marrentill, vial of water and unicorn horn dust (13 Herblore)" },
            },
        },
        methods = {
            ironman = "Ironman: 45 Cooking and 50 Fishing for the fish, unless you get them as drops. To beat Chronozon: 59 Magic, the standard spellbook and runes for Air, Water, Earth and Fire Blast (extra advised), or a deathtouched dart. Fights up to level 92 on the way",
            main = "To beat Chronozon: 59 Magic, the standard spellbook and runes for Air, Water, Earth and Fire Blast (extra advised), or a deathtouched dart. Fights up to level 92 on the way",
        },
    }),
    quest("q-tortle-combat", 23, "Tortle Combat", {
        wiki = W .. "Tortle_Combat_(miniquest)",
        requires = {
            items = {
                { id = 960, name = "Plank", count = 16, how = "Normal planks only (a plank box works); the sawmill in Rimmington" },
                { id = 4820, name = "Iron nails", count = 60, how = "Iron only; 10 Smithing, an iron bar and a hammer" },
                { id = 5418, name = "Empty sack", count = 1, how = "Farming shops, 1 coin" },
                { id = 1783, name = "Bucket of sand", count = 2, how = "An empty bucket on a sandpit (Yanille, Zanaris)" },
                { id = 954, name = "Rope", count = 3, how = "Ned in Draynor Village: 15 coins or 4 balls of wool" },
                { id = 43595, name = "Common brown rabbit (adult or elder)", count = 1, how = "From your player-owned farm" },
                { id = 43949, name = "Dense honeycomb", count = 1, how = "Rosemary in a farm beehive, with insect repellent" },
                { id = 1971, name = "Kebab", count = 1, how = "Karim in western Al Kharid, 1 coin" },
                { id = 563, name = "Law rune", count = 2, how = "Craft pure essence at the law altar on Entrana (54 Runecrafting), or buy from rune shops" },
                { id = 1761, name = "Soft clay", count = 1, how = "Clay with water" },
            },
        },
        methods = {
            ironman = "Miniquest. Ironman: 25 Farming for the dense honeycomb. First do the player-owned farm tutorial (not a quest: Granny Potterington on Manor Farm, by the Ardougne lodestone; 17 Farming, 20 Construction). Keep 1 backpack space free",
            main = "Miniquest. First do the player-owned farm tutorial (not a quest: Granny Potterington on Manor Farm, by the Ardougne lodestone; 17 Farming, 20 Construction). Keep 1 backpack space free",
        },
    }),
    ---------------------------------------------------------------------------
    -- Phase 24: Fort Forinthry. New Foundations, Murder on the Border, Princess
    -- and the Pauper, Unwelcome Guests, Dead and Buried, Ancient Awakening,
    -- Battle of Forinthry. The fort buildings two of them need aren't quests and
    -- can't be read, so their tips name them. From the RuneScape Wiki as of
    -- 21 October 2026.
    ---------------------------------------------------------------------------
    quest("q-new-foundations", 24, "New Foundations", {
        requires = {
            items = {
                { id = 960, name = "Plank", count = 20, how = "Normal logs and 100 coins each at a sawmill (Rimmington)" },
                { id = 54460, name = "Stone wall segment", count = 88, how = "At the stonecutter from 4 limestone bricks each (12 Crafting for the bricks)" },
                { id = 54452, name = "Wooden frame", count = 8, how = "Make 3 refined planks per frame at the woodworking bench (12 normal planks each)" },
            },
        },
        methods = {
            ironman = "Fights up to level 21",
            main = "Fights up to level 21",
        },
    }),
    quest("q-murder-on-the-border", 24, "Murder on the Border", {
        requires = {
            items = {
                { id = 54460, name = "Stone wall segment", count = 6, how = "At the stonecutter from 4 limestone bricks each (12 Crafting for the bricks)" },
                { id = 54848, name = "Willow frame", count = 12, how = "Make 3 refined willow planks per frame at the woodworking bench; 144 willow planks for 12 frames" },
            },
        },
        methods = {
            ironman = "Ironman: 20 Woodcutting for the willow logs. First build the Town Hall (10 Construction), Command Centre (25), Workshop (1) and Chapel (15) at Tier 1 in Fort Forinthry: not quests",
            main = "First build the Town Hall (10 Construction), Command Centre (25), Workshop (1) and Chapel (15) at Tier 1 in Fort Forinthry: not quests",
        },
    }),
    quest("q-princess-and-the-pauper", 24, "Princess and the Pauper", {
        requires = {
            items = {
                { id = 1921, name = "Bowl of water", count = 1, how = "A bowl on a water source" },
                { id = 331, name = "Raw salmon", count = 1, how = "30 Fishing, a fly fishing rod and feathers" },
                { id = 2347, name = "Hammer", count = 1, how = "In the backpack: the tool belt one won't work. Free from the crate in the Lumbridge smithy" },
                { id = 54452, name = "Wooden frame", count = 2, how = "Make 3 refined planks per frame at the woodworking bench (12 normal planks each)" },
                { id = 960, name = "Plank", count = 6, how = "Normal logs and 100 coins each at a sawmill (Rimmington)" },
                { id = 1539, name = "Steel nails", count = 10, how = "20 Smithing, a steel bar on an anvil (75 nails)" },
                { id = 8790, name = "Bolt of cloth", count = 2, how = "Bill's Construction Supplies in Fort Forinthry, 650 coins" },
                { id = 1737, name = "Wool", count = 2, how = "Not balls of wool: shear sheep" },
            },
        },
        methods = {
            ironman = "Also raw meat (raw beef can be got during the quest)",
            main = "Also raw meat (raw beef can be got during the quest)",
        },
    }),
    quest("q-unwelcome-guests", 24, "Unwelcome Guests", {
        requires = {
            items = {
                { id = 54850, name = "Maple frame", count = 14, how = "Make 3 refined maple planks per frame at the woodworking bench; 168 maple planks for 14 frames" },
                { id = 54460, name = "Stone wall segment", count = 6, how = "At the stonecutter from 4 limestone bricks each (12 Crafting for the bricks)" },
            },
        },
        methods = {
            ironman = "Ironman: 40 Woodcutting if you chop maple logs for the planks. Fights up to level 66",
            main = "Fights up to level 66",
        },
    }),
    quest("q-dead-and-buried", 24, "Dead and Buried", {
        requires = {
            items = {
                { id = 54460, name = "Stone wall segment", count = 6, how = "At the stonecutter from 4 limestone bricks each (12 Crafting for the bricks)" },
                { id = 54852, name = "Acadia frame", count = 14, how = "Make 3 refined acadia planks per frame at the woodworking bench; 168 acadia planks for 14 frames" },
            },
        },
        methods = {
            ironman = "Ironman: 50 Woodcutting for the acadia logs. Fights scale to your combat level",
            main = "Fights scale to your combat level",
        },
    }),
    quest("q-ancient-awakening", 24, "Ancient Awakening", {
        methods = {
            ironman = "Bring combat gear: fights up to level 300",
            main = "Bring combat gear: fights up to level 300",
        },
    }),
    quest("q-battle-of-forinthry", 24, "Battle of Forinthry", {
        methods = {
            ironman = "First build the Grove cabin (50 Construction, after Unwelcome Guests and meeting Oak, the fort's new visitor) and the Botanist's Workbench (54 Construction) at Tier 1 in Fort Forinthry: not quests. Bring dragonfire protection: fights up to level 789",
            main = "First build the Grove cabin (50 Construction, after Unwelcome Guests and meeting Oak, the fort's new visitor) and the Botanist's Workbench (54 Construction) at Tier 1 in Fort Forinthry: not quests. Bring dragonfire protection: fights up to level 789",
        },
    }),
    ---------------------------------------------------------------------------
    -- Phase 25: Legacy of Zamorak and Summer. Daughter of Chaos, Civil War I,
    -- II and III (miniquests), Succession, Spirit of Summer, Summer's End. From
    -- the RuneScape Wiki as of 21 October 2026.
    ---------------------------------------------------------------------------
    quest("q-daughter-of-chaos", 25, "Daughter of Chaos", {
        methods = {
            ironman = "Nothing to bring: you can't take food, equipment or familiars into the fights",
            main = "Nothing to bring: you can't take food, equipment or familiars into the fights",
        },
    }),
    quest("q-civil-war-1", 25, "Civil War I", {
        wiki = W .. "Civil_War_I_(miniquest)",
        methods = {
            ironman = "Miniquest. It includes the Gross Misconduct achievement, 144 demons in the Wilderness (you can do it first)",
            main = "Miniquest. It includes the Gross Misconduct achievement, 144 demons in the Wilderness (you can do it first)",
        },
    }),
    quest("q-civil-war-2", 25, "Civil War II", {
        wiki = W .. "Civil_War_II_(miniquest)",
        methods = {
            ironman = "Miniquest",
            main = "Miniquest",
        },
    }),
    quest("q-civil-war-3", 25, "Civil War III", {
        wiki = W .. "Civil_War_III_(miniquest)",
        methods = {
            ironman = "Miniquest",
            main = "Miniquest",
        },
    }),
    quest("q-succession", 25, "Succession", {
        methods = {
            ironman = "Needs the Infernal Puzzle Box at tier 5, which Civil War III unlocks. Nothing to bring: you can't take your own food or equipment into the fights",
            main = "Needs the Infernal Puzzle Box at tier 5, which Civil War III unlocks. Nothing to bring: you can't take your own food or equipment into the fights",
        },
    }),
    quest("q-spirit-of-summer", 25, "Spirit of Summer", {
        requires = {
            items = {
                { id = 12047, name = "Spirit wolf pouch", count = 1, how = "Infuse a pouch, 7 spirit shards, a gold charm and wolf bones at a Summoning obelisk (1 Summoning); bring 1-3, more if slow" },
                { id = 12049, name = "Desert wyrm pouch", count = 1, how = "Infuse a pouch, 45 shards, a green charm and a bucket of sand at a Summoning obelisk (18 Summoning); bring 1-3, more if slow" },
                { id = 12055, name = "Spirit scorpion pouch", count = 1, how = "Infuse a pouch, 57 shards, a crimson charm and bronze claws at a Summoning obelisk (19 Summoning); bring 1-3, more if slow" },
            },
        },
        methods = {
            ironman = "Also a ghostspeak amulet or cramulet to wear (not needed once you've claimed the hard Morytania achievements reward), and at least 4 summoning points (full is better). The steel nails, planks, bucket, limpwurt seed, skull and bones can be got during the quest",
            main = "Also a ghostspeak amulet or cramulet to wear (not needed once you've claimed the hard Morytania achievements reward), and at least 4 summoning points (full is better). The steel nails, planks, bucket, limpwurt seed, skull and bones can be got during the quest",
        },
    }),
    quest("q-summers-end", 25, "Summer's End", {
        requires = {
            items = {
                { id = 12067, ids = { 12067, 12063, 12800 }, name = "Summoning pouch made with a blue charm", count = 1, how = "1. Bring a pouch, 75 shards, a blue charm and raw rat meat.\n2. Infuse an albino rat pouch at a Summoning obelisk (23 Summoning).\n3. Spirit kalphite (25) or giant chinchompa (29) also counts. Bring spares." },
            },
        },
        methods = {
            ironman = "Also Jennica's ring (a Spirit of Summer reward) and a ghostspeak amulet or cramulet to wear (not needed once you've claimed the hard Morytania achievements reward). Keep 5-15 spaces free for logs",
            main = "Also Jennica's ring (a Spirit of Summer reward) and a ghostspeak amulet or cramulet to wear (not needed once you've claimed the hard Morytania achievements reward). Keep 5-15 spaces free for logs",
        },
    }),
    ---------------------------------------------------------------------------
    -- Phase 26: Trolls and the Fremennik Isles. Troll Stronghold, Eadgar's Ruse,
    -- Troll Romance, My Arm's Big Adventure, The Fremennik Isles, Glorious
    -- Memories. From the RuneScape Wiki as of 21 October 2026.
    ---------------------------------------------------------------------------
    quest("q-troll-stronghold", 26, "Troll Stronghold", {
        methods = {
            ironman = "Bring climbing boots or rock climbing boots to wear (or 12 coins to buy them), and keep 4 backpack spaces free",
            main = "Bring climbing boots or rock climbing boots to wear (or 12 coins to buy them), and keep 4 backpack spaces free",
        },
    }),
    quest("q-eadgars-ruse", 26, "Eadgar's Ruse", {
        requires = {
            items = {
                { id = 2015, name = "Vodka", count = 1, how = "Heckel Funch at the Gnome Stronghold sells it, and a pineapple" },
                { id = 2116, name = "Pineapple chunks", count = 1, how = "Slice a pineapple and choose chunks" },
                { id = 1947, name = "Wheat", count = 10, how = "Unnoted; wheat fields, e.g. north of East Ardougne" },
                { id = 2138, name = "Raw chicken", count = 5, how = "Kill chickens or roosters for raw chicken; keep it unnoted" },
                { id = 1511, name = "Logs", count = 1, how = "Cut the appropriate trees; normal logs" },
                { id = 99, name = "Ranarr potion (unfinished)", count = 1, how = "A clean ranarr in a vial of water" },
            },
        },
        methods = {
            ironman = "Also climbing boots or rock climbing boots to wear (not needed after Love Story, if you can make Trollheim teleport tablets)",
            main = "Also climbing boots or rock climbing boots to wear (not needed after Love Story, if you can make Trollheim teleport tablets)",
        },
    }),
    quest("q-troll-romance", 26, "Troll Romance", {
        requires = {
            items = {
                { id = 2351, name = "Iron bar", count = 1, how = "Smelt two iron ore at a furnace (10 Smithing)" },
                { id = 1517, ids = { 1517, 1515 }, name = "Maple or yew logs", count = 1, how = "Cut a maple tree (40 Woodcutting); maple or yew" },
                { id = 954, name = "Rope", count = 1, how = "Ned in Draynor Village: 15 coins or 4 balls of wool" },
                { id = 1887, name = "Cake tin", count = 1, how = "Most general stores" },
                { id = 1939, name = "Swamp tar", count = 1, how = "Spawns in Lumbridge Swamp" },
                { id = 30, name = "Bucket of wax", count = 1, how = "A beehive, with an empty bucket and insect repellent" },
            },
        },
        methods = {
            ironman = "Ironman: 40 Woodcutting, 10 Mining and 10 Smithing for the logs and the bar. Also climbing boots (or a Trollheim Teleport or tablet). If you did Death Plateau before the Troll Warzone update, it must be done again first",
            main = "Also climbing boots (or a Trollheim Teleport or tablet). If you did Death Plateau before the Troll Warzone update, it must be done again first",
        },
    }),
    quest("q-my-arms-big-adventure", 26, "My Arm's Big Adventure", {
        requires = {
            items = {
                { id = 4601, name = "Bucket of Ugthanki dung", count = 3, how = "Use red hot sauce on the camel trough in Pollnivneach, then collect the dung in a bucket" },
                { id = 6034, name = "Supercompost", count = 7, how = "Supercompostable items in a compost bin; take it out with a bucket" },
            },
        },
        methods = {
            ironman = "Also some coins, and climbing boots or rock climbing boots to wear (or a Trollheim teleport). The bucket, rake, seed dibber, spade and plant cure can be got during the quest (a tool leprechaun there sells them)",
            main = "Also some coins, and climbing boots or rock climbing boots to wear (or a Trollheim teleport). The bucket, rake, seed dibber, spade and plant cure can be got during the quest (a tool leprechaun there sells them)",
        },
    }),
    quest("q-fremennik-isles", 26, "The Fremennik Isles", {
        requires = {
            items = {
                { id = 447, ids = { 438, 453, 447 }, name = "Ores for your Mining level", count = 8, how = "Mine the required ore in the cave under Jatizso. Bring 8 tin (Mining 1-10), 7 coal (11-54) or 6 mithril (55+); noted is fine. Counted as 8 here" },
            },
        },
        methods = {
            ironman = "The raw tuna, ropes, split logs, yak-hide armour and round shield can be got during the quest",
            main = "The raw tuna, ropes, split logs, yak-hide armour and round shield can be got during the quest",
        },
    }),
    quest("q-glorious-memories", 26, "Glorious Memories", {
        requires = {
            items = {
                { id = 259, name = "Clean irit", count = 1, how = "Clean a grimy irit (40 Herblore)" },
                { id = 229, name = "Vial", count = 1, how = "Blow molten glass into a vial with a glassblowing pipe (33 Crafting)" },
                { id = 557, name = "Earth rune", count = 10, how = "Buy from rune shops; or a magic weapon that gives earth runes, such as a staff of earth (not counted here)" },
                { id = 564, name = "Cosmic rune", count = 1, how = "Craft pure essence at the cosmic altar in Zanaris (27 Runecrafting, after Lost City)" },
            },
        },
        methods = {
            ironman = "Needs the standard spellbook (or Spellbook Swap). The plank and a staff or pole can be got during the quest. Keep 4 backpack spaces free",
            main = "Needs the standard spellbook (or Spellbook Swap). The plank and a staff or pole can be got during the quest. Keep 4 backpack spaces free",
        },
    }),
    ---------------------------------------------------------------------------
    -- Phase 27: City of Um. Kili Row, Rune Mythos, Soul Searching, That Old
    -- Black Magic, Vessel of the Harbinger, The Spirit of War, Housing of
    -- Parliament. From the RuneScape Wiki as of 21 October 2026.
    ---------------------------------------------------------------------------
    quest("q-kili-row", 27, "Kili Row", {
        requires = {
            items = {
                { id = 55595, name = "Regular ghostly ink", count = 2, how = "20 lesser necroplasm with a vial of water and ashes; or have the glyphs drawn already" },
                { id = 55594, name = "Basic ghostly ink", count = 7, how = "Lupe's Soul Supplies in the City of Um; or have the glyphs drawn already" },
            },
        },
        methods = {
            ironman = "First collect a set of necromancer robes from Sostratus at Buried Bargains (not a quest). Also 4 light sources for the ritual, unless it's set up already",
            main = "First collect a set of necromancer robes from Sostratus at Buried Bargains (not a quest). Also 4 light sources for the ritual, unless it's set up already",
        },
    }),
    quest("q-rune-mythos", 27, "Rune Mythos", {
        methods = {
            ironman = "Nothing to bring",
            main = "Nothing to bring",
        },
    }),
    quest("q-soul-searching", 27, "Soul Searching", {
        requires = {
            items = {
                { id = 753, name = "Cadava berries", count = 3, how = "Pick from cadava bushes south-east of Varrock" },
                { id = 313, name = "Fishing bait", count = 10, how = "Pick up fishing bait by the dead troll south of Taverley, or buy from a fishing shop" },
                { id = 175, name = "Antipoison (3)", count = 1, how = "Mix marrentill potion (unf) with unicorn horn dust (13 Herblore); bring three doses" },
                { id = 973, name = "Charcoal", count = 1, how = "Buy from Jiminua's Jungle Store in Tai Bwo Wannai, or Obli's General Store after Shilo Village" },
                { id = 970, name = "Papyrus", count = 1, how = "Various shops, 10 coins" },
            },
        },
        methods = {
            ironman = "No skill levels needed",
            main = "No skill levels needed",
        },
    }),
    quest("q-that-old-black-magic", 27, "That Old Black Magic", {
        requires = {
            items = {
                { id = 49768, name = "Everlight trumpet (restored)", count = 1, how = "Excavate amphitheatre debris at Everlight (51 Archaeology); restore the damaged trumpet with 28 everlight silvthril and 24 goldrune" },
                { id = 55594, name = "Basic ghostly ink", count = 13, how = "Lupe's Soul Supplies in the City of Um; or have the glyphs drawn already" },
                { id = 55595, name = "Regular ghostly ink", count = 2, how = "20 lesser necroplasm with a vial of water and ashes; or have the glyphs drawn already" },
                { id = 55338, name = "Bone rune", count = 520, how = "The bone altar in the Necromantic Rune Temple (20 Runecrafting, after Rune Mythos)" },
                { id = 55339, name = "Flesh rune", count = 360, how = "The flesh altar in the Necromantic Rune Temple (40 Runecrafting, after Rune Mythos)" },
            },
        },
        methods = {
            ironman = "Four parts, at 32, 45, 50 and 65 Necromancy; the whole quest also needs 51 Archaeology. The animated drumsticks can be got during the quest",
            main = "Four parts, at 32, 45, 50 and 65 Necromancy; the whole quest also needs 51 Archaeology. The animated drumsticks can be got during the quest",
        },
    }),
    quest("q-vessel-of-the-harbinger", 27, "Vessel of the Harbinger", {
        requires = {
            items = {
                { id = 4286, name = "Bucket of slime", count = 1, how = "The Pool of Slime, lowest floor of the Ectofuntus basement" },
                { id = 55336, name = "Ectoplasm", count = 1, how = "All Necromancy rituals make it" },
                { id = 1925, name = "Bucket", count = 1, how = "Pick up the bucket in Lumbridge Castle cellar" },
                { id = 55594, name = "Basic ghostly ink", count = 11, how = "Lupe's Soul Supplies in the City of Um; or have the glyphs drawn already" },
                { id = 55595, name = "Regular ghostly ink", count = 2, how = "20 lesser necroplasm with a vial of water and ashes; or have the glyphs drawn already" },
            },
        },
        methods = {
            ironman = "Also a ghostspeak amulet or cramulet to wear (not needed after the hard Morytania achievements), Necromancy weapons including a conduit, and 4 light sources for the ritual",
            main = "Also a ghostspeak amulet or cramulet to wear (not needed after the hard Morytania achievements), Necromancy weapons including a conduit, and 4 light sources for the ritual",
        },
    }),
    quest("q-spirit-of-war", 27, "The Spirit of War", {
        methods = {
            ironman = "First earn 3,000 City of Um vessel souls (communion rituals at the Um ritual site; not a quest). Bring Necromancy combat gear and keep 2 backpack spaces free",
            main = "First earn 3,000 City of Um vessel souls (communion rituals at the Um ritual site; not a quest). Bring Necromancy combat gear and keep 2 backpack spaces free",
        },
    }),
    quest("q-housing-of-parliament", 27, "Housing of Parliament", {
        requires = {
            items = {
                { id = 1929, name = "Bucket of water", count = 2, how = "A bucket on a water source" },
                { id = 2162, name = "King worm", count = 1, how = "Pickpocket gnomes (75 Thieving), or the swamp near the Grand Tree" },
                { id = 3369, ids = { 3369, 3371, 3373 }, name = "Snail meat (any)", count = 2, how = "Kill blamish snails in Morytania and cook the meat; thin snail meat needs 12 Cooking. Thin, lean or fat works" },
                { id = 55302, ids = { 55302, 55300 }, name = "Raw ghostly sole (or cooked)", count = 1, how = "The City of Um graveyard spot, 66 Fishing with bait and a rod" },
            },
        },
        methods = {
            ironman = "Ironman: 66 Fishing for the ghostly sole (boostable). The beetle bits can be bought at a pet shop during the quest",
            main = "The beetle bits can be bought at a pet shop during the quest",
        },
    }),
    ---------------------------------------------------------------------------
    -- Phase 28: Heroes, Legends and early Mahjarrat. Temple of Ikov, Heroes'
    -- Quest, Legends' Quest, Defender of Varrock, The Hunt for Surok
    -- (miniquest), Devious Minds. From the RuneScape Wiki as of 21 October 2026.
    ---------------------------------------------------------------------------
    quest("q-temple-of-ikov", 28, "Temple of Ikov", {
        requires = {
            items = {
                { id = 225, name = "Limpwurt root", count = 20, how = "Grow limpwurt seeds in a flower patch (26 Farming); keep roots unnoted" },
            },
        },
        methods = {
            ironman = "Also a light source (a Seer's headband works) or the boots of lightness, and a bow that uses ammunition; the arrows come during the quest",
            main = "Also a light source (a Seer's headband works) or the boots of lightness, and a bow that uses ammunition; the arrows come during the quest",
        },
    }),
    quest("q-heroes-quest", 28, "Heroes' Quest", {
        requires = {
            items = {
                { id = 97, name = "Harralander potion (unfinished)", count = 1, how = "A clean harralander in a vial of water" },
            },
        },
        methods = {
            ironman = "Also lockpicks or a hair clip (tool belt works) to do it solo. Black Arm Gang: black full helm, platebody and platelegs (not a plateskirt), and 25 Defence; Phoenix Gang: 1,000 coins or a ring of charos (a). The ice gloves, fishing rod and bait can be got during the quest",
            main = "Also lockpicks or a hair clip (tool belt works) to do it solo. Black Arm Gang: black full helm, platebody and platelegs (not a plateskirt), and 25 Defence; Phoenix Gang: 1,000 coins or a ring of charos (a). The ice gloves, fishing rod and bait can be got during the quest",
        },
    }),
    quest("q-legends-quest", 28, "Legends' Quest", {
        requires = {
            items = {
                { id = 954, name = "Rope", count = 1, how = "Ned in Draynor Village: 15 coins or 4 balls of wool" },
                { id = 229, name = "Vial", count = 1, how = "Blow molten glass with a glassblowing pipe (33 Crafting); empty" },
                { id = 227, name = "Vial of water", count = 1, how = "A vial on a water source" },
                { id = 973, name = "Charcoal", count = 1, how = "Buy from Jiminua's Jungle Store in Tai Bwo Wannai" },
                { id = 567, name = "Unpowered orb", count = 1, how = "Blow molten glass with a glassblowing pipe (46 Crafting); bring two if taking the easy way" },
                { id = 2357, name = "Gold bar", count = 2, how = "Smelt gold ore at a furnace (40 Smithing); more in case smithing fails; the metal bank doesn't work" },
                { id = 1609, name = "Opal", count = 1, how = "Cut an uncut opal with a chisel (1 Crafting)" },
                { id = 1611, name = "Jade", count = 1, how = "Cut an uncut jade with a chisel (13 Crafting)" },
                { id = 1613, name = "Red topaz", count = 1, how = "Cut an uncut red topaz with a chisel (16 Crafting)" },
                { id = 1607, name = "Sapphire", count = 1, how = "Cut an uncut sapphire with a chisel (20 Crafting)" },
                { id = 1605, name = "Emerald", count = 1, how = "Cut an uncut emerald with a chisel (27 Crafting)" },
                { id = 1603, name = "Ruby", count = 1, how = "Cut an uncut ruby with a chisel (34 Crafting)" },
                { id = 1601, name = "Diamond", count = 1, how = "Cut an uncut diamond with a chisel (43 Crafting)" },
                { id = 566, name = "Soul rune", count = 1, how = "Buy from Baba Yaga on Lunar Isle or the Wizards' Guild in Yanille (access required)" },
                { id = 558, name = "Mind rune", count = 1, how = "Buy from Aubury's Rune Shop in Varrock, or craft at the mind altar" },
                { id = 557, name = "Earth rune", count = 1, how = "Craft at the earth altar (9 Runecrafting)" },
                { id = 563, name = "Law rune", count = 2, how = "Craft at the law altar on Entrana (54 Runecrafting)" },
            },
        },
        methods = {
            ironman = "Also runes for two Charge Orb casts (bring spares), a lockpick or hair clip, and a rune hatchet or better (tool belt works for both). The papyrus, clean ardrigal and clean snake weed can be got during the quest. The runes listed are for the English game",
            main = "Also runes for two Charge Orb casts (bring spares), a lockpick or hair clip, and a rune hatchet or better (tool belt works for both). The papyrus, clean ardrigal and clean snake weed can be got during the quest. The runes listed are for the English game",
        },
    }),
    quest("q-defender-of-varrock", 28, "Defender of Varrock", {
        methods = {
            ironman = "First claim Kudos from Historian Minas in the Varrock Museum for Shield of Arrav (not a quest). Also a light source, a spade and gear for the Wilderness. The blurite ore can be got during the quest",
            main = "First claim Kudos from Historian Minas in the Varrock Museum for Shield of Arrav (not a quest). Also a light source, a spade and gear for the Wilderness. The blurite ore can be got during the quest",
        },
    }),
    quest("q-hunt-for-surok", 28, "The Hunt for Surok", {
        wiki = W .. "The_Hunt_for_Surok_(miniquest)",
        requires = {
            items = {
                { id = 1452, ids = { 1452, 5543, 13637, 13649 }, name = "Chaos talisman (or tiara, talisman staff, omni-talisman)", count = 1, how = "Buy a chaos talisman from the Runecrafting Guild; a tiara, talisman staff or omni-talisman also works. A wicked hood holding a chaos talisman works too (not counted here)" },
            },
        },
        methods = {
            ironman = "Miniquest",
            main = "Miniquest",
        },
    }),
    quest("q-devious-minds", 28, "Devious Minds", {
        requires = {
            items = {
                { id = 45484, name = "Mithril 2h sword", count = 1, how = "Smith 4 mithril bars at a forge and anvil (30 Smithing); not the +1 or +2 versions" },
                { id = 1777, name = "Bowstring", count = 1, how = "Spin flax on a spinning wheel (1 Crafting)" },
                { id = 5512, name = "Large pouch", count = 1, how = "Kill abyssal monsters, or buy from Wizard Korvak in the Runecrafting Guild for 25,000 coins. It must hold 9 essence; repair it first. Lost during the quest" },
            },
        },
        methods = {
            ironman = "The large pouch is lost during the quest",
            main = "The large pouch is lost during the quest",
        },
    }),
    ---------------------------------------------------------------------------
    -- Phase 29: Penguins, gnomes and fairies. Cold War, Hunt for Red Raktuber,
    -- Some Like It Cold, Back to the Freezer, The Path of Glouphrie, The
    -- Prisoner of Glouphrie, A Fairy Tale III. From the RuneScape Wiki as of
    -- 21 October 2026.
    ---------------------------------------------------------------------------
    quest("q-cold-war", 29, "Cold War", {
        requires = {
            items = {
                { id = 8778, name = "Oak plank", count = 10, how = "Turn oak logs into planks at a sawmill, or pay Bill or a plank maker; not protean planks, and a plank box doesn't work" },
                { id = 1539, name = "Steel nails", count = 10, how = "20 Smithing, a steel bar on an anvil (75 nails)" },
                { id = 960, name = "Plank", count = 1, how = "Turn normal logs into planks at a sawmill; a normal plank; protean and other planks don't work" },
                { id = 8782, name = "Mahogany plank", count = 1, how = "Turn mahogany logs into planks at a sawmill; not protean" },
                { id = 950, name = "Silk", count = 1, how = "Buy from the silk trader in Al Kharid, or steal from a silk stall (20 Thieving)" },
                { id = 8792, ids = { 8792, 2353 }, name = "Clockwork (or a steel bar)", count = 1, how = "Craft a steel bar at clockmaker's bench 2 in your house (8 Crafting); a steel bar to craft one in the quest works too" },
                { id = 1939, name = "Swamp tar", count = 1, how = "Spawns in Lumbridge Swamp" },
                { id = 314, name = "Feather", count = 5, how = "Buy from a fishing shop or kill chickens; not coloured ones" },
                { id = 1741, name = "Leather", count = 1, how = "Take a cowhide to a tanner, such as the one in Al Kharid" },
                { id = 341, ids = { 341, 4202, 6465 }, name = "Raw cod (or a ring of charos)", count = 1, how = "Big-net fish at Catherby (23 Fishing); an inactive ring of charos works too" },
            },
        },
        methods = {
            ironman = "1. Ironman: 20 Mining and 20 Smithing for the steel bar, and 23 Fishing for the cod.\n2. Get mahogany at 60 Woodcutting, or use Carnillean Rising's 10 mahogany planks.\n3. Use clockmaker's bench 3 or 4 in a player-owned house, or bring 12 oak planks and 3 molten glass to build one.\n4. For the cowbells later, have 15 Thieving (boostable) or Zanaris access.",
            main = "1. Use clockmaker's bench 3 or 4 in a player-owned house, or bring 12 oak planks and 3 molten glass to build one.\n2. For the cowbells later, have 15 Thieving (boostable) or Zanaris access.",
        },
    }),
    quest("q-hunt-for-red-raktuber", 29, "Hunt for Red Raktuber", {
        requires = {
            items = {
                { id = 10595, ids = { 10595, 10596 }, name = "Clockwork suit", count = 1, how = "At the Cold War crafting stage, use clockmaker's bench 3 with silk, plank and clockwork (30 Crafting)" },
                { id = 950, name = "Silk", count = 8, how = "Buy from the silk trader in Al Kharid, or steal from a silk stall (20 Thieving)" },
                { id = 960, name = "Plank", count = 4, how = "Turn normal logs into planks at a sawmill; protean planks don't work" },
                { id = 1734, name = "Thread", count = 1, how = "Buy from a Crafting shop, or pick up the spawn at the Jolly Boar Inn north-east of Varrock" },
            },
        },
        methods = {
            ironman = "Keep 6 backpack spaces free and nothing in your main-hand, off-hand and back slots",
            main = "Keep 6 backpack spaces free and nothing in your main-hand, off-hand and back slots",
        },
    }),
    quest("q-some-like-it-cold", 29, "Some Like It Cold", {
        requires = {
            items = {
                { id = 10595, ids = { 10595, 10596 }, name = "Clockwork suit", count = 1, how = "Craft silk, plank and clockwork at clockmaker's bench 3 (30 Crafting); not needed if you make the costumes at a clockmaker's bench in your house (not counted here)" },
            },
        },
        methods = {
            ironman = "Keep at least 5 backpack spaces free. You'll have to deposit all your items and worn items at one point",
            main = "Keep at least 5 backpack spaces free. You'll have to deposit all your items and worn items at one point",
        },
    }),
    quest("q-back-to-the-freezer", 29, "Back to the Freezer", {
        requires = {
            items = {
                { id = 6696, name = "Ice cooler", count = 1, how = "Buy from any Slayer master; bring the item, an ice shaker won't work" },
                { id = 29314, name = "Flickering energy", count = 50, how = "Harvest flickering wisps east of Falador lodestone (10 Divination)" },
                { id = 29315, name = "Bright energy", count = 50, how = "Harvest bright wisps west of Varrock Dig Site (20 Divination)" },
                { id = 29317, name = "Sparkling energy", count = 50, how = "Harvest sparkling wisps by the golden tree south-east of Rellekka (40 Divination)" },
                { id = 29318, name = "Gleaming energy", count = 50, how = "Harvest gleaming wisps in central Karamja, north-east of the nature altar (50 Divination)" },
            },
        },
        methods = {
            ironman = "Also combat equipment and insulated boots, and 8-12 backpack spaces. A clockwork suit is given if you don't have one",
            main = "Also combat equipment and insulated boots, and 8-12 backpack spaces. A clockwork suit is given if you don't have one",
        },
    }),
    quest("q-path-of-glouphrie", 29, "The Path of Glouphrie", {
        requires = {
            items = {
                { id = 9626, ids = { 9626, 9625 }, name = "Small crystal seed or crystal saw", count = 1, how = "Eyes of Glouphrie reward; reclaim from Brimstail in the south-west Gnome Stronghold cave. A crystal saw works; tools from crystal tool seeds don't" },
            },
        },
        methods = {
            ironman = "Ironman: 59 Fletching (boostable) for the mithril grapple, or kill some dried zombies. Also a crossbow and a mithril grapple (tool belt works), and A key from the Waterfall Quest (it can be got again during the quest)",
            main = "Also a crossbow and a mithril grapple (tool belt works), and A key from the Waterfall Quest (it can be got again during the quest)",
        },
    }),
    quest("q-prisoner-of-glouphrie", 29, "The Prisoner of Glouphrie", {
        methods = {
            ironman = "Nothing to bring",
            main = "Nothing to bring",
        },
    }),
    quest("q-fairy-tale-3", 29, "A Fairy Tale III - Battle at Ork's Rift", {
        requires = {
            items = {
                { id = 9025, name = "Nuff's certificate", count = 1, how = "From A Fairy Tale II; if dropped, another is in Fairy Nuff's grotto" },
                { id = 1927, name = "Bucket of milk", count = 1, how = "In Zanaris: a bucket west of the mill, a dairy cow east of the wheat field" },
            },
        },
        methods = {
            ironman = "Also a dramen or lunar staff. The secateurs and hammer can be got during the quest (the tool belt ones won't work)",
            main = "Also a dramen or lunar staff. The secateurs and hammer can be got during the quest (the tool belt ones won't work)",
        },
    }),
    ---------------------------------------------------------------------------
    -- Phase 30: Sliske's Game opening and Mos Le'Harmless. Carnillean Rising,
    -- Heart of Stone, Dishonour among Thieves, Kindred Spirits, The Great Brain
    -- Robbery, Rocking Out. From the RuneScape Wiki as of 21 October 2026.
    ---------------------------------------------------------------------------
    quest("q-carnillean-rising", 30, "Carnillean Rising", {
        methods = {
            ironman = "Keep 23 backpack spaces free for what you collect",
            main = "Keep 23 backpack spaces free for what you collect",
        },
    }),
    quest("q-heart-of-stone", 30, "Heart of Stone", {
        methods = {
            ironman = "Bring food and combat gear (Ranged or Magic is best): fights at levels 35-56",
            main = "Bring food and combat gear (Ranged or Magic is best): fights at levels 35-56",
        },
    }),
    quest("q-dishonour-among-thieves", 30, "Dishonour among Thieves", {
        requires = {
            items = {
                { id = 29742, name = "Invitation box", count = 1, how = "Reclaim from Brother Samwell in Silvarea after Missing, Presumed Death" },
            },
        },
        methods = {
            ironman = "The invitation box takes you to the Empyrean Citadel",
            main = "The invitation box takes you to the Empyrean Citadel",
        },
    }),
    quest("q-kindred-spirits", 30, "Kindred Spirits", {
        methods = {
            ironman = "Nothing to bring",
            main = "Nothing to bring",
        },
    }),
    quest("q-great-brain-robbery", 30, "The Great Brain Robbery", {
        requires = {
            items = {
                { id = 1718, name = "Holy symbol", count = 1, how = "1. Cast a silver bar with a holy mould (16 Crafting).\n2. String the symbol with a ball of wool.\n3. Ask Brother Jered upstairs in Edgeville Monastery to bless it (31 Prayer)." },
                { id = 4202, name = "Ring of charos", count = 1, how = "Pickpocket Dr Fenkenstrain after Creature of Fenkenstrain; find him in his castle, or on Harmony Island after The Great Brain Robbery" },
                { id = 4820, ids = { 4820, 1539, 4821, 4822, 4823, 4824 }, name = "Nails, iron or better", count = 38, how = "Smith nails from metal bars at an anvil; bring extra, they bend; nails above rune aren't counted here" },
                { id = 10891, name = "Wooden cat", count = 10, how = "Craft at clockmaker's bench 1 after talking to Rufus (10 Crafting); for 10 cats, bring 10 bear fur and 10 normal planks, not protean" },
                { id = 960, name = "Plank", count = 8, how = "Turn normal logs into planks at a sawmill; regular planks, not from a plank box" },
                { id = 2347, name = "Hammer", count = 1, how = "Take a hammer from the crate in Lumbridge furnace; in the backpack: the tool belt one won't work" },
            },
        },
        methods = {
            ironman = "Ironman: a clockmaker's bench 1 or better in your house. First do Recipe for Disaster: Freeing Pirate Pete (part of Recipe for Disaster; after Another Cook's Quest, 31 Cooking). Also a fishbowl helmet and diving apparatus. The tinderbox can be got during the quest (the tool belt one won't work)",
            main = "First do Recipe for Disaster: Freeing Pirate Pete (part of Recipe for Disaster; after Another Cook's Quest, 31 Cooking). Also a fishbowl helmet and diving apparatus. The tinderbox can be got during the quest (the tool belt one won't work)",
        },
    }),
    quest("q-rocking-out", 30, "Rocking Out", {
        requires = {
            items = {
                { id = 1794, name = "Bronze wire", count = 2, how = "Smith a bronze bar into wire at a forge and anvil (1 Smithing)" },
            },
        },
        methods = {
            ironman = "1. Bring 3 pieces of pirate clothing (Dodgy Mike in Mos Le'Harmless), a fishbowl helmet and diving apparatus.\n2. Bring a ghostspeak amulet or cramulet (not needed after the hard Morytania achievements), and 20 coins or more for travel.\n3. You deposit everything before jail; fetch these from the bank after.\n4. The Book o' piracy and charcoal can be got during the quest.",
            main = "1. Bring 3 pieces of pirate clothing (Dodgy Mike in Mos Le'Harmless), a fishbowl helmet and diving apparatus.\n2. Bring a ghostspeak amulet or cramulet (not needed after the hard Morytania achievements), and 20 coins or more for travel.\n3. You deposit everything before jail; fetch these from the bank after.\n4. The Book o' piracy and charcoal can be got during the quest.",
        },
    }),
    ---------------------------------------------------------------------------
    -- Phase 31: Kharidian Desert II. Shadow of the Storm, Smoking Kills, Desert
    -- Slayer Dungeon (miniquest), Enakhra's Lament, The Vault of Shadows, Evil
    -- Dave's Big Day Out. From the RuneScape Wiki as of 21 October 2026.
    ---------------------------------------------------------------------------
    quest("q-shadow-of-the-storm", 31, "Shadow of the Storm", {
        requires = {
            items = {
                { id = 2355, name = "Silver bar", count = 1, how = "Smelt silver ore at a furnace (20 Smithing); the metal bank works" },
            },
        },
        methods = {
            ironman = "Also 3 pieces of a black outfit (the desert robe and shirt can be dyed during the quest), and an empty vial if Silverlight isn't dyed black yet. Silverlight and the strange implement can be got again during the quest",
            main = "Also 3 pieces of a black outfit (the desert robe and shirt can be dyed during the quest), and an empty vial if Silverlight isn't dyed black yet. Silverlight and the strange implement can be got again during the quest",
        },
    }),
    quest("q-smoking-kills", 31, "Smoking Kills", {
        methods = {
            ironman = "Bring a catspeak amulet, a ghostspeak amulet, earmuffs and a face mask; a kitten, cat, overgrown cat, hellcat, wily cat or lazy cat; and Ranged, Magic or Necromancy (the skeletons can't be killed with melee)",
            main = "Bring a catspeak amulet, a ghostspeak amulet, earmuffs and a face mask; a kitten, cat, overgrown cat, hellcat, wily cat or lazy cat; and Ranged, Magic or Necromancy (the skeletons can't be killed with melee)",
        },
    }),
    quest("q-desert-slayer-dungeon", 31, "Desert Slayer Dungeon", {
        wiki = W .. "Desert_Slayer_Dungeon_(miniquest)",
        methods = {
            ironman = "Miniquest. Slayer 10, 40, 55 and 70 are needed along the way. Bring a slayer helmet (or masked earmuffs or a face mask), a leaf-bladed sword or spear (or a slayer staff with Slayer Dart runes) and a mirror shield",
            main = "Miniquest. Slayer 10, 40, 55 and 70 are needed along the way. Bring a slayer helmet (or masked earmuffs or a face mask), a leaf-bladed sword or spear (or a slayer staff with Slayer Dart runes) and a mirror shield",
        },
    }),
    quest("q-enakhras-lament", 31, "Enakhra's Lament", {
        requires = {
            items = {
                { id = 6975, name = "Sandstone (5kg)", count = 10, how = "Mine sandstone at the Desert Quarry; any mix making a 32 kg and a 20 kg set works. This is the advised set" },
                { id = 6973, name = "Sandstone (2kg)", count = 1, how = "Mine sandstone at the Desert Quarry; 2 kg blocks are part of the advised set" },
                { id = 36, name = "White candle", count = 1, how = "Buy from the Candle Shop in Catherby; not a black or red candle" },
                { id = 1511, name = "Logs", count = 1, how = "Cut the appropriate trees; normal logs" },
                { id = 1521, name = "Oak logs", count = 1, how = "Cut an oak tree (10 Woodcutting)" },
                { id = 1519, name = "Willow logs", count = 1, how = "Cut a willow tree (20 Woodcutting)" },
                { id = 1517, name = "Maple logs", count = 1, how = "Cut a maple tree (40 Woodcutting)" },
                { id = 1761, name = "Soft clay", count = 1, how = "Add water to clay; two if you want a camel mask" },
                { id = 453, name = "Coal", count = 1, how = "Mine coal rocks (20 Mining); it can be taken from the metal bank during the quest" },
            },
        },
        methods = {
            ironman = "Also bread, a pie, a cake, a pizza or a topped baked potato (not burnt), and a wand or staff with air and fire runes (standard spellbook). The two 5 kg granite blocks can be got during the quest (45 Mining)",
            main = "Also bread, a pie, a cake, a pizza or a topped baked potato (not burnt), and a wand or staff with air and fire runes (standard spellbook). The two 5 kg granite blocks can be got during the quest (45 Mining)",
        },
    }),
    quest("q-vault-of-shadows", 31, "The Vault of Shadows", {
        methods = {
            ironman = "Needs Time Served done (or an ancient timepiece to do it), and all eight shadow anchors powered or Protection of Zaros for one step. Also the pontifex signet ring (tool belt works) and 500 vibrant or better memories",
            main = "Needs Time Served done (or an ancient timepiece to do it), and all eight shadow anchors powered or Protection of Zaros for one step. Also the pontifex signet ring (tool belt works) and 500 vibrant or better memories",
        },
    }),
    quest("q-evil-daves-big-day-out", 31, "Evil Dave's Big Day Out", {
        methods = {
            ironman = "First do Recipe for Disaster: Freeing Evil Dave (part of Recipe for Disaster; needs a cat and up to 10 bowls of stew, 25 Cooking). Go with an empty backpack and no familiar or pet",
            main = "First do Recipe for Disaster: Freeing Evil Dave (part of Recipe for Disaster; needs a cat and up to 10 bowls of stew, 25 Cooking). Go with an empty backpack and no familiar or pet",
        },
    }),
    ---------------------------------------------------------------------------
    -- Phase 32: Daemonheim and the sagas. Curse of the Black Stone, Salt in the
    -- Wound, then the sagas Vengeance, Nadir and Thok It To 'Em (Skaldrun is
    -- already freed for Three's Company). From the RuneScape Wiki as of 21
    -- October 2026.
    ---------------------------------------------------------------------------
    quest("q-curse-of-the-black-stone", 32, "Curse of the Black Stone", {
        requires = {
            items = {
                { id = 1631, name = "Uncut dragonstone", count = 1, how = "Open a crystal chest with a crystal key for an uncut dragonstone" },
                { id = 954, name = "Rope", count = 1, how = "Ned in Draynor Village: 15 coins or 4 balls of wool" },
                { id = 563, name = "Law rune", count = 1, how = "Craft pure essence at the law altar on Entrana (54 Runecrafting), or buy from rune shops" },
            },
        },
        methods = {
            ironman = "To finish it you need the Temple of Aminishi, Dragonkin Laboratory and the Shadow Reef done (any mode). Also any raw fish, and a set of equipment that lets you into the Black Knights' Fortress, with no cosmetic override on (a pat of butter is optional)",
            main = "To finish it you need the Temple of Aminishi, Dragonkin Laboratory and the Shadow Reef done (any mode). Also any raw fish, and a set of equipment that lets you into the Black Knights' Fortress, with no cosmetic override on (a pat of butter is optional)",
        },
    }),
    quest("q-salt-in-the-wound", 32, "Salt in the Wound", {
        methods = {
            ironman = "Nothing to bring",
            main = "Nothing to bring",
        },
    }),
    quest("q-vengeance", 32, "Vengeance", {
        wiki = W .. "Vengeance_(saga)",
        methods = {
            ironman = "Saga. Wear your ring of kinship and find a collection of swords on the abandoned floors 12-17 of Daemonheim, then ask Skaldrun to share the story",
            main = "Saga. Wear your ring of kinship and find a collection of swords on the abandoned floors 12-17 of Daemonheim, then ask Skaldrun to share the story",
        },
    }),
    quest("q-nadir", 32, "Nadir", {
        wiki = W .. "Nadir_(saga)",
        methods = {
            ironman = "Saga. Wear your ring of kinship and find the damaged device on the furnished floors 18-22 of Daemonheim, then ask Skaldrun. Use the standard spellbook",
            main = "Saga. Wear your ring of kinship and find the damaged device on the furnished floors 18-22 of Daemonheim, then ask Skaldrun. Use the standard spellbook",
        },
    }),
    quest("q-thok-it-to-em", 32, "Thok It To 'Em", {
        wiki = W .. "Thok_It_To_%27Em_(saga)",
        methods = {
            ironman = "Saga. Wear your ring of kinship and find the scribbled notes on the abandoned floors 30-35 of Daemonheim, then ask Skaldrun",
            main = "Saga. Wear your ring of kinship and find the scribbled notes on the abandoned floors 30-35 of Daemonheim, then ask Skaldrun",
        },
    }),
    ---------------------------------------------------------------------------
    -- Phase 33: Doric's and Boric's later tasks, and the Thieves' Guild. Boric's
    -- Task I-III, Doric's Task V-VIII, A Guild of Our Own (all miniquests). From
    -- the RuneScape Wiki as of 21 October 2026.
    ---------------------------------------------------------------------------
    quest("q-borics-task-1", 33, "Boric's Task I", {
        wiki = W .. "Boric's_Task_I_(miniquest)",
        requires = {
            items = {
                { id = 453, name = "Coal", count = 30, how = "Mine coal rocks (20 Mining)" },
            },
        },
        methods = {
            ironman = "Miniquest",
            main = "Miniquest",
        },
    }),
    quest("q-borics-task-2", 33, "Boric's Task II", {
        wiki = W .. "Boric's_Task_II_(miniquest)",
        methods = {
            ironman = "Miniquest",
            main = "Miniquest",
        },
    }),
    quest("q-borics-task-3", 33, "Boric's Task III", {
        wiki = W .. "Boric's_Task_III_(miniquest)",
        methods = {
            ironman = "Miniquest",
            main = "Miniquest",
        },
    }),
    quest("q-dorics-task-5", 33, "Doric's Task V", {
        wiki = W .. "Doric's_Task_V_(miniquest)",
        requires = {
            items = {
                { id = 2363, name = "Rune bar", count = 12, how = "Smelt runite ore and luminite at a furnace (50 Smithing); or 6 bars and 3 rune swords (not counted here)" },
                { id = 2353, name = "Steel bar", count = 20, how = "Smelt iron ore and coal at a furnace (20 Smithing); or 4 steel platebodies (not counted here)" },
            },
        },
        methods = {
            ironman = "Miniquest. Ironman: 50 Mining",
            main = "Miniquest",
        },
    }),
    quest("q-dorics-task-6", 33, "Doric's Task VI", {
        wiki = W .. "Doric's_Task_VI_(miniquest)",
        requires = {
            items = {
                { id = 44838, name = "Orikalkum bar", count = 16, how = "Smelt orichalcite ore and drakolith at a furnace (60 Smithing); or 8 bars and an orikalkum warhammer + 2 (not counted here)" },
            },
        },
        methods = {
            ironman = "Miniquest. Ironman: 60 Mining",
            main = "Miniquest",
        },
    }),
    quest("q-dorics-task-7", 33, "Doric's Task VII", {
        wiki = W .. "Doric's_Task_VII_(miniquest)",
        methods = {
            ironman = "Miniquest",
            main = "Miniquest",
        },
    }),
    quest("q-dorics-task-8", 33, "Doric's Task VIII", {
        wiki = W .. "Doric's_Task_VIII_(miniquest)",
        requires = {
            items = {
                { id = 44840, name = "Necronium bar", count = 20, how = "Smelt necrite ore and phasmatite at a furnace (70 Smithing)" },
            },
        },
        methods = {
            ironman = "Miniquest. Ironman: 70 Mining. Keep 2 backpack spaces free",
            main = "Miniquest. Keep 2 backpack spaces free",
        },
    }),
    quest("q-guild-of-our-own", 33, "A Guild of Our Own", {
        wiki = W .. "A_Guild_of_Our_Own_(miniquest)",
        requires = {
            items = {
                { id = 101, name = "Irit potion (unfinished)", count = 1, how = "Mix clean irit with a vial of water (40 Herblore); separate clean irit and water also work (not counted here)" },
                { id = 1871, name = "Chopped onion", count = 1, how = "Use a bowl on an onion with a knife; separate bowl and onion also work (not counted here)" },
            },
        },
        methods = {
            ironman = "Miniquest. Needs The Feud partly done. Also a blackjack (not the rubber one) and a lockpick or hair clip",
            main = "Miniquest. Needs The Feud partly done. Also a blackjack (not the rubber one) and a lockpick or hair clip",
        },
    }),
    ---------------------------------------------------------------------------
    -- Phase 34: The elves and East Ardougne. Mourning's End Part II, Within the
    -- Light, Plague's End, Back to my Roots, One Foot in the Grave (miniquest),
    -- Grim Tales. From the RuneScape Wiki as of 21 October 2026.
    ---------------------------------------------------------------------------
    quest("q-mournings-end-2", 34, "Mourning's End Part II", {
        requires = {
            items = {
                { id = 954, name = "Rope", count = 1, how = "Ned in Draynor Village: 15 coins or 4 balls of wool" },
            },
        },
        methods = {
            ironman = "Also a full set of mourner gear. 50 assorted items from the wiki's list are needed unless you have a death talisman, a fed wicked hood or another way into the death altar (the Abyss doesn't count)",
            main = "Also a full set of mourner gear. 50 assorted items from the wiki's list are needed unless you have a death talisman, a fed wicked hood or another way into the death altar (the Abyss doesn't count)",
        },
    }),
    quest("q-within-the-light", 34, "Within the Light", {
        methods = {
            ironman = "Bring two sets of mourner outfit with gas masks (one is lost; the second is easy to get during the quest) and a way into the death altar (a death talisman can be got during the quest). If the new key, tarnished key, colour wheel, notes or crystal trinket are in your bank, bring them",
            main = "Bring two sets of mourner outfit with gas masks (one is lost; the second is easy to get during the quest) and a way into the death altar (a death talisman can be got during the quest). If the new key, tarnished key, colour wheel, notes or crystal trinket are in your bank, bring them",
        },
    }),
    quest("q-plagues-end", 34, "Plague's End", {
        requires = {
            items = {
                { id = 2363, name = "Rune bar", count = 1, how = "Smelt runite ore and luminite at a furnace (50 Smithing)" },
                { id = 6036, name = "Plant cure", count = 1, how = "Buy plant cure from a Farming shop; or runes for Cure Plant (Lunar, 66 Magic; not counted here)" },
                { id = 1513, name = "Magic logs", count = 10, how = "Cut magic trees (80 Woodcutting)" },
                { id = 12183, name = "Spirit shards", count = 200, how = "Buy from Pikkupstix in Taverley for 25 coins each" },
                { id = 12158, name = "Gold charm", count = 1, how = "Kill gelatinous abominations; Wolf Whistle also rewards 275 gold charms" },
                { id = 12159, name = "Green charm", count = 1, how = "Kill level 11 cave bugs for green charms, not the level 6 ones" },
                { id = 12160, name = "Crimson charm", count = 1, how = "Kill waterfiends or dagannoths for crimson charms" },
                { id = 12163, name = "Blue charm", count = 1, how = "Kill exiled kalphite guardians or marauders, or catch blue spirit moths (64 Hunter)" },
                { id = 12155, name = "Pouch", count = 1, how = "Buy blank pouches from a Summoning shop, such as Pikkupstix or Magestix" },
                { id = 163, name = "Super defence (3)", count = 1, how = "Mix cadantine potion (unf) with white berries (66 Herblore); bring three doses" },
            },
        },
        methods = {
            ironman = "Also a full mourner outfit",
            main = "Also a full mourner outfit",
        },
    }),
    quest("q-back-to-my-roots", 34, "Back to my Roots", {
        requires = {
            items = {
                { id = 5354, name = "Plant pot (with soil)", count = 1, how = "Fill an empty plant pot at a Farming patch; a filled plant pot" },
                { id = 1761, name = "Soft clay", count = 1, how = "Add water to clay; for the pot lid, made during the quest; a bought lid or one made before won't work" },
                { id = 1931, name = "Empty pot", count = 1, how = "Shape a pot on a potter's wheel, then fire it in an oven (1 Crafting); not a plant pot" },
            },
        },
        methods = {
            ironman = "Also a hatchet (rune or better is advised; tool belt works), and a melee weapon if the hatchet is on your tool belt",
            main = "Also a hatchet (rune or better is advised; tool belt works), and a melee weapon if the hatchet is on your tool belt",
        },
    }),
    quest("q-one-foot-in-the-grave", 34, "One Foot in the Grave", {
        wiki = W .. "One_Foot_in_the_Grave_(miniquest)",
        requires = {
            items = {
                { id = 11763, name = "Hand (Clarence's)", count = 1, how = "From Back to my Roots; if lost, creatures at the jade vine maze drop it" },
            },
        },
        methods = {
            ironman = "Miniquest. Needs Back to my Roots partly done",
            main = "Miniquest. Needs Back to my Roots partly done",
        },
    }),
    quest("q-grim-tales", 34, "Grim Tales", {
        requires = {
            items = {
                { id = 227, name = "Vial of water", count = 2, how = "A vial on a water source" },
                { id = 253, name = "Clean tarromin", count = 2, how = "Clean grimy tarromin (5 Herblore)" },
                { id = 5340, ids = { 5340, 18682 }, name = "Watering can (8) or magic watering can", count = 1, how = "Buy a watering can at a Farming shop and fill it at a water source; bring 8 charges or a magic watering can. Keep it in your backpack, not on the tool belt" },
            },
        },
        methods = {
            ironman = "The leather gloves can be got during the quest",
            main = "The leather gloves can be got during the quest",
        },
    }),
    ---------------------------------------------------------------------------
    -- Phase 35: Piscatoris, the Wise Old Man and Rellekka. Swan Song, Love
    -- Story, Stellar Born, Deadliest Catch, Hero's Welcome, The World Wakes,
    -- Heralds of Crimson. From the RuneScape Wiki as of 21 October 2026.
    ---------------------------------------------------------------------------
    quest("q-swan-song", 35, "Swan Song", {
        requires = {
            items = {
                { id = 4695, name = "Mist rune", count = 10, how = "At the air altar: pure essence, water runes and a water talisman (6 Runecrafting); talisman is consumed, success not guaranteed" },
                { id = 4699, name = "Lava rune", count = 10, how = "At the earth altar: pure essence, fire runes and a fire talisman (23 Runecrafting); talisman is consumed, success not guaranteed" },
                { id = 565, name = "Blood rune", count = 5, how = "Buy from the Mage of Zamorak, or craft at the blood altar (77 Runecrafting, after Legacy of Seergaze)" },
                { id = 1931, name = "Empty pot", count = 1, how = "Shape soft clay on a potter's wheel, then fire the pot in a pottery oven (1 Crafting)" },
                { id = 4440, name = "Pot lid", count = 1, how = "Shape soft clay into an unfired pot lid at a potter's wheel, then fire it in a pottery oven (25 Crafting)" },
            },
        },
        methods = {
            ironman = "The 7 bones, 5 iron bars and logs can be got during the quest",
            main = "The 7 bones, 5 iron bars and logs can be got during the quest",
        },
    }),
    quest("q-love-story", 35, "Love Story", {
        requires = {
            items = {
                { id = 2353, ids = { 2353, 8792 }, name = "Steel bar or clockwork", count = 1, how = "Smelt iron ore and coal at a furnace (20 Smithing)" },
                { id = 2359, name = "Mithril bar", count = 1, how = "Smelt mithril ore and coal at a furnace (30 Smithing)" },
                { id = 8778, name = "Oak plank", count = 2, how = "Turn oak logs into planks at a sawmill, or pay Bill or a plank maker" },
            },
        },
        methods = {
            ironman = "Also weapons and armour for at least 2 combat styles (or Necromancy)",
            main = "Also weapons and armour for at least 2 combat styles (or Necromancy)",
        },
    }),
    quest("q-stellar-born", 35, "Stellar Born", {
        requires = {
            items = {
                { id = 564, name = "Cosmic rune", count = 152, how = "Craft pure essence at the cosmic altar in Zanaris (27 Runecrafting, after Lost City)" },
                { id = 9075, name = "Astral rune", count = 52, how = "Buy from Baba Yaga on Lunar Isle, or craft pure essence at the astral altar (40 Runecrafting, after Lunar Diplomacy)" },
                { id = 2054, ids = { 2054, 2040 }, name = "Wizard Blizzard (or premade)", count = 1, how = "1. Shake 2 vodka, gin, orange, lime and lemon in a cocktail shaker.\n2. Pour into a cocktail glass with lime slices and pineapple chunks.\n3. A premade Wizard Blizzard also works." },
            },
        },
        methods = {
            ironman = "First complete the Wing Out mystery (Archaeology, not a quest)",
            main = "First complete the Wing Out mystery (Archaeology, not a quest)",
        },
    }),
    quest("q-deadliest-catch", 35, "Deadliest Catch", {
        methods = {
            ironman = "Nothing to bring",
            main = "Nothing to bring",
        },
    }),
    quest("q-heros-welcome", 35, "Hero's Welcome", {
        requires = {
            items = {
                { id = 1761, name = "Soft clay", count = 1, how = "Clay with water" },
                { id = 2359, name = "Mithril bar", count = 1, how = "Smelt mithril ore and coal at a furnace (30 Smithing)" },
            },
        },
        methods = {
            ironman = "Needs access to the Ancient Cavern from Barbarian Training (not a quest). Also dragonfire protection, and 875 coins for the Brimhaven Dungeon unless you own Karamja gloves 3 or a Dungeoneering cape",
            main = "Needs access to the Ancient Cavern from Barbarian Training (not a quest). Also dragonfire protection, and 875 coins for the Brimhaven Dungeon unless you own Karamja gloves 3 or a Dungeoneering cape",
        },
    }),
    quest("q-world-wakes", 35, "The World Wakes", {
        methods = {
            ironman = "Nothing to bring",
            main = "Nothing to bring",
        },
    }),
    quest("q-heralds-of-crimson", 35, "Heralds of Crimson", {
        requires = {
            items = {
                { id = 1517, name = "Maple logs", count = 1, how = "Cut a maple tree (40 Woodcutting)" },
                { id = 60296, name = "Havensilver bar", count = 4, how = "Smelt havensilver ore at a furnace after learning how in Hearts of Sanguine (1 Smithing); the metal bank works" },
                { id = 105, name = "Kwuarm potion (unfinished)", count = 1, how = "Mix clean kwuarm with a vial of water (54 Herblore)" },
                { id = 60338, name = "Silver spines", count = 1, how = "Kill Silverquill, the Dreadhog for silver spines" },
                { id = 60339, name = "Sanguine spines", count = 1, how = "Kill Silverquill, the Dreadhog for sanguine spines" },
            },
        },
        methods = {
            ironman = "Also combat gear",
            main = "Also combat gear",
        },
    }),
    ---------------------------------------------------------------------------
    -- Phase 36: Red Axe dwarves and the Myreque. Forgiveness of a Chaos Dwarf,
    -- King of the Dwarves, The Branches of Darkmeyer, The Lord of Vampyrium,
    -- The Lost Toys (miniquest), River of Blood, In Memory of the Myreque
    -- (miniquest). From the RuneScape Wiki as of 21 October 2026.
    ---------------------------------------------------------------------------
    quest("q-forgiveness-of-a-chaos-dwarf", 36, "Forgiveness of a Chaos Dwarf", {
        methods = {
            ironman = "Keep at least 6 backpack spaces free",
            main = "Keep at least 6 backpack spaces free",
        },
    }),
    quest("q-king-of-the-dwarves", 36, "King of the Dwarves", {
        requires = {
            items = {
                { id = 1761, name = "Soft clay", count = 6, how = "Clay with water" },
                { id = 2359, name = "Mithril bar", count = 6, how = "Smelt mithril ore and coal at a furnace (30 Smithing); real bars: the metal bank doesn't work" },
            },
        },
        methods = {
            ironman = "Nothing else to bring",
            main = "Nothing else to bring",
        },
    }),
    quest("q-branches-of-darkmeyer", 36, "The Branches of Darkmeyer", {
        methods = {
            ironman = "Nothing to bring",
            main = "Nothing to bring",
        },
    }),
    quest("q-lord-of-vampyrium", 36, "The Lord of Vampyrium", {
        methods = {
            ironman = "Bring your Darkmeyer disguise and blisterwood weaponry or an Ivandis flail",
            main = "Bring your Darkmeyer disguise and blisterwood weaponry or an Ivandis flail",
        },
    }),
    quest("q-lost-toys", 36, "The Lost Toys", {
        wiki = W .. "The_Lost_Toys_(miniquest)",
        methods = {
            ironman = "Miniquest. Nothing to bring",
            main = "Miniquest. Nothing to bring",
        },
    }),
    quest("q-river-of-blood", 36, "River of Blood", {
        requires = {
            items = {
                { id = 7660, ids = { 7660, 7662, 7664, 7666, 23555, 23557, 23559, 23561, 23563, 23565 }, name = "Guthix balance (potion or flask)", count = 1, how = "After starting In Aid of the Myreque, add garlic and silver dust to a three-dose restore potion (22 Herblore); any final dose works" },
                { id = 3026, name = "Super restore (3)", count = 1, how = "Mix snapdragon potion (unf) with red spiders' eggs (63 Herblore); bring three doses" },
                { id = 45459, name = "Steel med helm", count = 3, how = "Smith 2 steel bars at a forge and anvil (20 Smithing)" },
                { id = 45462, name = "Steel platebody", count = 3, how = "Smith 5 steel bars at a forge and anvil (20 Smithing)" },
                { id = 45460, name = "Steel platelegs", count = 3, how = "Smith 3 steel bars at a forge and anvil (20 Smithing)" },
                { id = 35695, name = "Blisterwood sickle", count = 2, how = "Fletch blisterwood logs with an unblessed silver sickle (70 Fletching), after unlocking it in The Lord of Vampyrium" },
                { id = 21582, name = "Blisterwood polearm", count = 1, how = "Fletch blisterwood logs with 2 unblessed silver sickles (70 Fletching, The Branches of Darkmeyer); make an extra polearm to fight with, this one is handed over" },
                { id = 21600, name = "Blisterwood logs", count = 3, how = "Cut the rejuvenated Blisterwood Tree in Darkmeyer (76 Woodcutting), after the relevant Branches of Darkmeyer stage" },
            },
        },
        methods = {
            ironman = "Also a weapon that can harm vampyres (blisterwood, for example). The wolfbane and sunspear can be got during the quest",
            main = "Also a weapon that can harm vampyres (blisterwood, for example). The wolfbane and sunspear can be got during the quest",
        },
    }),
    quest("q-in-memory-of-the-myreque", 36, "In Memory of the Myreque", {
        wiki = W .. "In_Memory_of_the_Myreque_(miniquest)",
        requires = {
            items = {
                { id = 35695, name = "Blisterwood sickle", count = 10, how = "Fletch blisterwood logs with an unblessed silver sickle (70 Fletching), after unlocking it in The Lord of Vampyrium" },
                { id = 6983, name = "Granite (5kg)", count = 20, how = "Mine granite at the Western desert mining site; take a 5 kg block and protection from desert heat" },
                { id = 3361, name = "Blamish blue shell (pointed)", count = 1, how = "Kill pointed-shell bruise blamish snails in Mort Myre; keep the shell, not the snelm made from it" },
                { id = 10937, name = "Nail beast nails", count = 1, how = "Kill nail beasts in Temple Trekking encounters" },
                { id = 6322, name = "Snakeskin body", count = 1, how = "Craft 15 snakeskins with a needle and thread (53 Crafting)" },
                { id = 13117, ids = { 13117, 13118, 13119, 13120, 13121, 13122, 13123, 13124, 13125, 13126, 13127, 13128, 13129, 13130, 13131, 13132, 13133, 13134, 13135, 13136, 13137, 13138, 13139, 13140, 13141, 13142, 13143, 13144, 13145, 13146 }, name = "Ivandis flail", count = 1, how = "From Legacy of Seergaze" },
                { id = 45547, name = "Rune armoured boots", count = 1, how = "Smith a rune bar at a forge and anvil (50 Smithing)" },
                { id = 2974, name = "Mort myre pear", count = 1, how = "Use Bloom near small Mort Myre bushes with a blessed silver sickle or Ivandis flail, then pick the pear" },
                { id = 2955, name = "Moonlight mead", count = 1, how = "Brew with water, barley malt, bittercap mushrooms and ale yeast (44 Cooking); not mature moonlight mead (m)" },
                { id = 35703, name = "Blisterwood stake-thrower crossbow", count = 1, how = "1. After The Lord of Vampyrium unlock, make silvthril limbs at a furnace (70 Crafting).\n2. Attach the limbs to a blisterwood stock (73 Fletching).\n3. Add a crossbow string." },
                { id = 7634, name = "Histories of the Hallowland", count = 1, how = "After In Aid of the Myreque, reclaim from a bookcase in your house" },
                { id = 732, name = "Holy water", count = 1, how = "1. After the Legends' Quest stage, use the binding book on empty vials to enchant them.\n2. Have Gujuo bless a gold bowl.\n3. Use a hollow reed at the Kharazi pool to fill the bowl with water.\n4. Use the filled bowl on the enchanted vials." },
            },
        },
        methods = {
            ironman = "Miniquest",
            main = "Miniquest",
        },
    }),
    ---------------------------------------------------------------------------
    -- Phase 37: Desert Treasure, and finishing Recipe for Disaster and
    -- Dimension of Disaster. The Curse of Arrav, Desert Treasure, Curse of the
    -- Empty Lord, The General's Shadow, Hopespear's Will (miniquests),
    -- Dimension of Disaster, Recipe for Disaster. From the RuneScape Wiki as of
    -- 21 October 2026.
    ---------------------------------------------------------------------------
    quest("q-curse-of-arrav", 37, "The Curse of Arrav", {
        requires = {
            items = {
                { id = 2126, name = "Dwellberries", count = 3, how = "Pick up dwellberries in McGrubor's Wood, or grow them in a bush patch (36 Farming)" },
                { id = 2570, name = "Ring of life", count = 1, how = "Enchant a diamond ring with Lvl-4 Enchant, or use the reward from The Lost Tribe; it is used up" },
            },
        },
        methods = {
            ironman = "1. Ironman: 59 Fletching for the mithril grapple, and 57 Magic and 43 Crafting for the ring of life, unless you get them otherwise.\n2. Fully restore Senliten in Missing My Mummy, partly complete Garden of Tranquillity, and get access to Trollheim.\n3. Bring a crossbow and mithril grapple, or an enhanced grappling hook on the tool belt.\n4. Bring insulated boots and a familiar with remote view: a macaw (41 Summoning) or ravenous locust (70).\n5. Bring combat gear for a level 91 monster.",
            main = "1. Fully restore Senliten in Missing My Mummy, partly complete Garden of Tranquillity, and get access to Trollheim.\n2. Bring a crossbow and mithril grapple, or an enhanced grappling hook on the tool belt.\n3. Bring insulated boots and a familiar with remote view: a macaw (41 Summoning) or ravenous locust (70).\n4. Bring combat gear for a level 91 monster.",
        },
    }),
    quest("q-desert-treasure", 37, "Desert Treasure", {
        requires = {
            items = {
                { id = 592, name = "Ashes", count = 1, how = "Burn logs and collect ashes after the fire burns out" },
                { id = 565, name = "Blood rune", count = 1, how = "Buy from the Mage of Zamorak, or craft at the blood altar (77 Runecrafting, after Legacy of Seergaze)" },
                { id = 526, name = "Bones", count = 1, how = "Kill animals or humanoid monsters that drop regular bones" },
                { id = 973, name = "Charcoal", count = 1, how = "Buy from Jiminua's Jungle Store in Tai Bwo Wannai, or Obli's General Store after Shilo Village" },
                { id = 1775, name = "Molten glass", count = 6, how = "Use sand and soda ash at a furnace (1 Crafting); noted is fine" },
                { id = 1513, name = "Magic logs", count = 12, how = "Cut magic trees (80 Woodcutting); noted is fine" },
                { id = 2353, name = "Steel bar", count = 6, how = "Smelt iron ore and coal at a furnace (20 Smithing); noted is fine" },
                { id = 1891, ids = { 1891, 1893, 1895, 1897, 1899, 1901, 1973, 1955, 2301 }, name = "Cake (or a slice)", count = 1, how = "Steal cake from a bakery stall (5 Thieving), or bake egg, milk and flour in a cake tin (40 Cooking); a slice, chocolate cake, chocolate bar, cooking apple or pineapple pizza also works" },
                { id = 1550, name = "Garlic", count = 1, how = "Pick up garlic upstairs in Morgan's house in Draynor Village" },
                { id = 2355, name = "Silver bar", count = 1, how = "Smelt silver ore at a furnace (20 Smithing); not from the metal bank" },
                { id = 2007, name = "Spice", count = 1, how = "Buy from the spice seller in Ardougne market, or steal from a spice stall (65 Thieving)" },
            },
        },
        methods = {
            ironman = "1. Ironman: 80 Woodcutting for magic logs, unless you get them as drops.\n2. Bring 650 coins and a face mask, masked earmuffs, slayer helmet or gas mask.\n3. Bring lockpicks (up to 100), hair clips or a master thief's lockpick.\n4. Bring ice gloves or another way to beat Fareed, and climbing boots or a Trollheim teleport.\n5. Get spiked boots: Dunstan makes them from an iron bar and climbing boots.",
            main = "1. Bring 650 coins and a face mask, masked earmuffs, slayer helmet or gas mask.\n2. Bring lockpicks (up to 100), hair clips or a master thief's lockpick.\n3. Bring ice gloves or another way to beat Fareed, and climbing boots or a Trollheim teleport.\n4. Get spiked boots: Dunstan makes them from an iron bar and climbing boots.",
        },
    }),
    quest("q-curse-of-the-empty-lord", 37, "Curse of the Empty Lord", {
        wiki = W .. "Curse_of_the_Empty_Lord_(miniquest)",
        methods = {
            ironman = "Miniquest. Needs Desert Treasure partly done. Wear a ring of visibility and a ghostspeak amulet or cramulet (not needed after the hard Morytania achievements)",
            main = "Miniquest. Needs Desert Treasure partly done. Wear a ring of visibility and a ghostspeak amulet or cramulet (not needed after the hard Morytania achievements)",
        },
    }),
    quest("q-generals-shadow", 37, "The General's Shadow", {
        wiki = W .. "The_General's_Shadow_(miniquest)",
        methods = {
            ironman = "Miniquest. Wear a ring of visibility, the full ghostly robe outfit and a ghostspeak amulet or cramulet (not needed after the hard Morytania achievements). Also 40 coins (70 if you take the boat to Karamja)",
            main = "Miniquest. Wear a ring of visibility, the full ghostly robe outfit and a ghostspeak amulet or cramulet (not needed after the hard Morytania achievements). Also 40 coins (70 if you take the boat to Karamja)",
        },
    }),
    quest("q-hopespears-will", 37, "Hopespear's Will", {
        wiki = W .. "Hopespear's_Will_(miniquest)",
        requires = {
            items = {
                { id = 11809, ids = { 11809, 11810, 11811, 11812 }, name = "Goblin potion", count = 1, how = "Mix toadflax potion (unf) with pharmakos berries (37 Herblore, Land of the Goblins); any dose lets you past the temple guards" },
            },
        },
        methods = {
            ironman = "1. Miniquest. Needs A Fairy Tale II and Desert Treasure partly done.\n2. You must beat five foes up to level 36 with no armour or weapons, no magic and no familiar.\n3. Also a dramen or lunar staff (not after A Fairy Tale III), a ring of visibility or Sliske's gift, and a ghostspeak amulet (dismantle a cramulet first, or take it off before the fights)",
            main = "1. Miniquest. Needs A Fairy Tale II and Desert Treasure partly done.\n2. You must beat five foes up to level 36 with no armour or weapons, no magic and no familiar.\n3. Also a dramen or lunar staff (not after A Fairy Tale III), a ring of visibility or Sliske's gift, and a ghostspeak amulet (dismantle a cramulet first, or take it off before the fights)",
        },
    }),
    quest("q-dimension-of-disaster", 37, "Dimension of Disaster", {
        requires = {
            items = {
                { id = 34338, name = "Zemomark", count = 652, how = "In New Varrock, sell local items to shops or pickpocket citizens; get these beforehand to buy the subquests' items" },
            },
        },
        methods = {
            ironman = "Ten subquests. Be on the standard spellbook and prayers. Also 1 coin; the rest is got during the quest",
            main = "Ten subquests. Be on the standard spellbook and prayers. Also 1 coin; the rest is got during the quest",
        },
    }),
    quest("q-recipe-for-disaster", 37, "Recipe for Disaster", {
        requires = {
            items = {
                { id = 221, name = "Eye of newt", count = 1, how = "Buy from Betty's shop in Port Sarim" },
                { id = 1909, name = "Greenman's ale", count = 1, how = "Buy from the Dragon Inn in Yanille for 10 coins; not from your house, it disappears when you leave" },
                { id = 2518, name = "Rotten tomato", count = 1, how = "Buy from the crate next to Seers' Village lodestone or Varrock pillory (Buy option)" },
                { id = 592, name = "Ashes", count = 1, how = "Burn logs and collect ashes after the fire burns out" },
                { id = 2084, name = "Fruit Blast", count = 1, how = "1. Shake pineapple, lemon and orange in a cocktail shaker (6 Cooking).\n2. Pour into a cocktail glass with lemon slices. Not the premade one." },
            },
        },
        methods = {
            ironman = "Ten chapters; these items are for the first. The whole quest needs 48 Agility, 70 Cooking (boostable), 20 Firemaking and 176 quest points, plus each chapter's own quests and items (the wiki's summary lists them)",
            main = "Ten chapters; these items are for the first. The whole quest needs 48 Agility, 70 Cooking (boostable), 20 Firemaking and 176 quest points, plus each chapter's own quests and items (the wiki's summary lists them)",
        },
    }),
    ---------------------------------------------------------------------------
    -- Phase 38: Senliten's tomb to Menaphos, and the Void Knights. Crocodile
    -- Tears, Do No Evil, Our Man in the North, 'Phite Club, A Void Dance, The
    -- Void Stares Back. From the RuneScape Wiki as of 21 October 2026.
    ---------------------------------------------------------------------------
    quest("q-crocodile-tears", 38, "Crocodile Tears", {
        requires = {
            items = {
                { id = 954, name = "Rope", count = 1, how = "Ned in Draynor Village: 15 coins or 4 balls of wool" },
                { id = 313, name = "Fishing bait", count = 20, how = "20-30 advised, for one beltfish; not needed with Tier 1 prawn perks. Some is sold during the quest" },
            },
        },
        methods = {
            ironman = "Needs Leela brought to Senliten's tomb and Senliten fully restored (Missing My Mummy), and Garden of Tranquillity partly done. Also a cat or kitten and at least 28,000 coins for croc ice. Items for Crondis only count if you get them after she asks",
            main = "Needs Leela brought to Senliten's tomb and Senliten fully restored (Missing My Mummy), and Garden of Tranquillity partly done. Also a cat or kitten and at least 28,000 coins for croc ice. Items for Crondis only count if you get them after she asks",
        },
    }),
    quest("q-do-no-evil", 38, "Do No Evil", {
        requires = {
            items = {
                { id = 1963, name = "Banana", count = 10, how = "Pick bananas from natural banana trees at Musa Point" },
                { id = 8780, name = "Teak plank", count = 6, how = "Turn teak logs into planks at a sawmill, or pay a sawmill operator" },
                { id = 8790, name = "Bolt of cloth", count = 10, how = "Bill's Construction Supplies in Fort Forinthry, 650 coins" },
                { id = 954, name = "Rope", count = 3, how = "Ned in Draynor Village: 15 coins or 4 balls of wool" },
                { id = 946, name = "Knife", count = 3, how = "Pick up a knife in Lumbridge Castle kitchen or cellar" },
            },
        },
        methods = {
            ironman = "1. Bring Leela to Senliten's tomb and fully restore Senliten (Missing My Mummy).\n2. Partly complete Garden of Tranquillity and complete Recipe for Disaster: Freeing King Awowogei (a chapter that needs Monkey Madness).\n3. Bring a cat, kitten or hellcat; a desert shirt, robe and boots; masked earmuffs or a slayer helmet.\n4. Bring a gorilla greegree, ring of charos (a), Ava's accumulator and monkeyspeak amulet.\n5. Bring a ghostspeak amulet; the Morytania effect won't do.\n6. Bring runes for 20+ Ice spells (not Ice Rush) and at least 1,000 coins; 11,000+ is advised.\n7. The spade, uncut gems, waterskins and amulet mould can be got during the quest.",
            main = "1. Bring Leela to Senliten's tomb and fully restore Senliten (Missing My Mummy).\n2. Partly complete Garden of Tranquillity and complete Recipe for Disaster: Freeing King Awowogei (a chapter that needs Monkey Madness).\n3. Bring a cat, kitten or hellcat; a desert shirt, robe and boots; masked earmuffs or a slayer helmet.\n4. Bring a gorilla greegree, ring of charos (a), Ava's accumulator and monkeyspeak amulet.\n5. Bring a ghostspeak amulet; the Morytania effect won't do.\n6. Bring runes for 20+ Ice spells (not Ice Rush) and at least 1,000 coins; 11,000+ is advised.\n7. The spade, uncut gems, waterskins and amulet mould can be got during the quest.",
        },
    }),
    quest("q-our-man-in-the-north", 38, "Our Man in the North", {
        methods = {
            ironman = "Nothing to bring",
            main = "Nothing to bring",
        },
    }),
    quest("q-phite-club", 38, "'Phite Club", {
        methods = {
            ironman = "Nothing to bring",
            main = "Nothing to bring",
        },
    }),
    quest("q-void-dance", 38, "A Void Dance", {
        methods = {
            ironman = "Also 65 coins (less with Karamja gloves 3, a ring of charos (a) or an amulet of glory) and 16 free backpack spaces for one part. The commorb and onion can be got during the quest",
            main = "Also 65 coins (less with Karamja gloves 3, a ring of charos (a) or an amulet of glory) and 16 free backpack spaces for one part. The commorb and onion can be got during the quest",
        },
    }),
    quest("q-void-stares-back", 38, "The Void Stares Back", {
        methods = {
            ironman = "Keep 8 backpack spaces free. The hard leather, limestone brick and logs can be got during the quest",
            main = "Keep 8 backpack spaces free. The hard leather, limestone brick and logs can be got during the quest",
        },
    }),
    ---------------------------------------------------------------------------
    -- Phase 39: Elder God Wars II and Anachronia. Azzanadra's Quest, Battle of
    -- the Monolith, City of Senntisten, Eye of Het I and II, Sins of the
    -- Father, Osseous Rex, Helping Laniakea (miniquest). From the RuneScape
    -- Wiki as of 21 October 2026.
    ---------------------------------------------------------------------------
    quest("q-azzanadras-quest", 39, "Azzanadra's Quest", {
        requires = {
            items = {
                { id = 10952, name = "Slayer bell", count = 1, how = "Buy from any Slayer master for 150 coins" },
            },
        },
        methods = {
            ironman = "Nothing else to bring",
            main = "Nothing else to bring",
        },
    }),
    quest("q-battle-of-the-monolith", 39, "Battle of the Monolith", {
        methods = {
            ironman = "Nothing to bring",
            main = "Nothing to bring",
        },
    }),
    quest("q-city-of-senntisten", 39, "City of Senntisten", {
        requires = {
            items = {
                { id = 1615, name = "Dragonstone", count = 1, how = "Cut an uncut dragonstone with a chisel (55 Crafting)" },
            },
        },
        methods = {
            ironman = "Also combat gear, a rock hammer (tool belt works) and ways to heal (food, an enhanced Excalibur)",
            main = "Also combat gear, a rock hammer (tool belt works) and ways to heal (food, an enhanced Excalibur)",
        },
    }),
    quest("q-eye-of-het-1", 39, "Eye of Het I", {
        methods = {
            ironman = "Nothing to bring",
            main = "Nothing to bring",
        },
    }),
    quest("q-eye-of-het-2", 39, "Eye of Het II", {
        methods = {
            ironman = "Nothing to bring",
            main = "Nothing to bring",
        },
    }),
    quest("q-sins-of-the-father", 39, "Sins of the Father", {
        methods = {
            ironman = "Needs 85 in one of Crafting, Runecrafting, Smithing or Invention",
            main = "Needs 85 in one of Crafting, Runecrafting, Smithing or Invention",
        },
    }),
    quest("q-osseous-rex", 39, "Osseous Rex", {
        requires = {
            items = {
                { id = 49454, name = "Orthenglass", count = 20, how = "Some can be got during the quest; material storage counts in game (not here)" },
            },
        },
        methods = {
            ironman = "Needs the Anachronia base camp tutorial (not a quest)",
            main = "Needs the Anachronia base camp tutorial (not a quest)",
        },
    }),
    quest("q-helping-laniakea", 39, "Helping Laniakea", {
        wiki = W .. "Helping_Laniakea_(miniquest)",
        requires = {
            items = {
                { id = 47948, ids = { 47948, 383 }, name = "Raw arcane apoterrasaur meat (Ironman: raw shark)", count = 1, how = "Hunt arcane apoterrasaurs (75 Hunter, 55 Slayer) using raw shark bait; Ironmen can start with 1-3 raw sharks for the quest" },
            },
        },
        methods = {
            ironman = "Miniquest. Ironman: 75 Hunter and 55 Slayer, and 1-3 raw sharks instead of the meat. Needs the Anachronia base camp tutorial (not a quest)",
            main = "Miniquest. Needs the Anachronia base camp tutorial (not a quest)",
        },
    }),
    ---------------------------------------------------------------------------
    -- Phase 40: The First Necromancer, Fort Forinthry II and Menaphos. Tomes of
    -- the Warlock, Requiem for a Dragon, Ode of the Devourer, Remains of the
    -- Necrolord, Alpha vs Omega, Beneath Scabaras' Sands, Pharaoh's Folly,
    -- Eclipse of the Heart. From the RuneScape Wiki as of 21 October 2026.
    ---------------------------------------------------------------------------
    quest("q-tomes-of-the-warlock", 40, "Tomes of the Warlock", {
        requires = {
            items = {
                { id = 49886, name = "Necromantic focus (restored)", count = 1, how = "Excavate the Orcus altar at Kharid-et (86 Archaeology); restore with 30 ancient vis, 26 blood of Orcus and 20 imperial steel" },
            },
        },
        methods = {
            ironman = "Also 120 ancient vis, 104 blood of Orcus and 80 imperial steel in your material storage (the plugin can't read it)",
            main = "Also 120 ancient vis, 104 blood of Orcus and 80 imperial steel in your material storage (the plugin can't read it)",
        },
    }),
    quest("q-requiem-for-a-dragon", 40, "Requiem for a Dragon", {
        requires = {
            items = {
                { id = 55612, name = "Greater ensouled bar", count = 5, how = "Use Greater ensoul material on a greater unensouled bar (80 Necromancy, after Kili Row); Thalmund's Wares only sells them when in stock" },
                { id = 55594, name = "Basic ghostly ink", count = 4, how = "Lupe's Soul Supplies in the City of Um; or have the glyphs drawn already" },
                { id = 55595, name = "Regular ghostly ink", count = 10, how = "20 lesser necroplasm with a vial of water and ashes; or have the glyphs drawn already" },
                { id = 55596, name = "Greater ghostly ink", count = 16, how = "Craft 20 greater necroplasm with a vial of water and ashes (60 Necromancy); or have the glyphs drawn already" },
                { id = 55634, ids = { 55634, 55635, 55636 }, name = "Ritual candle (basic or better)", count = 12, how = "Buy basic ritual candles from Lupe's Soul Supplies in the City of Um; or have the light sources set up already" },
            },
        },
        methods = {
            ironman = "Ironman: 80 Smithing and 80 Necromancy (boostable) for the greater ensouled bars, unless bought from Thalmund's Wares. Also 30 white marble and 30 white oak (material storage works)",
            main = "Also 30 white marble and 30 white oak (material storage works)",
        },
    }),
    quest("q-ode-of-the-devourer", 40, "Ode of the Devourer", {
        methods = {
            ironman = "Nothing to bring",
            main = "Nothing to bring",
        },
    }),
    quest("q-remains-of-the-necrolord", 40, "Remains of the Necrolord", {
        methods = {
            ironman = "Needs the unabridged Vengeance and Nadir sagas at 100%. Also a ghostspeak amulet or cramulet (not needed after the hard Morytania achievements) and combat gear",
            main = "Needs the unabridged Vengeance and Nadir sagas at 100%. Also a ghostspeak amulet or cramulet (not needed after the hard Morytania achievements) and combat gear",
        },
    }),
    quest("q-alpha-vs-omega", 40, "Alpha vs Omega", {
        methods = {
            ironman = "First earn 30,000 City of Um vessel souls (not a quest). Bring Necromancy combat gear",
            main = "First earn 30,000 City of Um vessel souls (not a quest). Bring Necromancy combat gear",
        },
    }),
    quest("q-beneath-scabaras-sands", 40, "Beneath Scabaras' Sands", {
        methods = {
            ironman = "Bring a restored Zarosian artefact (it's lost)",
            main = "Bring a restored Zarosian artefact (it's lost)",
        },
    }),
    quest("q-pharaohs-folly", 40, "Pharaoh's Folly", {
        methods = {
            ironman = "Nothing to bring",
            main = "Nothing to bring",
        },
    }),
    quest("q-eclipse-of-the-heart", 40, "Eclipse of the Heart", {
        requires = {
            items = {
                { id = 55597, name = "Powerful ghostly ink", count = 20, how = "Craft 20 powerful necroplasm with a vial of water and ashes (90 Necromancy); or have the glyphs drawn already" },
                { id = 55596, name = "Greater ghostly ink", count = 31, how = "Craft 20 greater necroplasm with a vial of water and ashes (60 Necromancy); or have the glyphs drawn already" },
                { id = 55595, name = "Regular ghostly ink", count = 18, how = "20 lesser necroplasm with a vial of water and ashes; or have the glyphs drawn already" },
                { id = 55634, ids = { 55634, 55635, 55636 }, name = "Ritual candle (basic or better)", count = 16, how = "Buy basic ritual candles from Lupe's Soul Supplies in the City of Um; or have the light sources set up already" },
            },
        },
        methods = {
            ironman = "Also a cat or kitten, and a monkeyspeak amulet or cramulet",
            main = "Also a cat or kitten, and a monkeyspeak amulet or cramulet",
        },
    }),
    ---------------------------------------------------------------------------
    -- Phase 41: TzHaar and the end of the Elder God Wars. TokTz-Ket-Dill, The
    -- Elder Kiln, The Brink of Extinction, Wandering Ga'al (miniquest),
    -- Extinction, Twilight of the Gods, Aftermath. From the RuneScape Wiki as
    -- of 21 October 2026.
    ---------------------------------------------------------------------------
    quest("q-toktz-ket-dill", 41, "TokTz-Ket-Dill", {
        requires = {
            items = {
                { id = 8778, name = "Oak plank", count = 14, how = "Turn oak logs into planks at a sawmill, or pay Bill or a plank maker" },
            },
        },
        methods = {
            ironman = "Also an adamant pickaxe or better (the tool belt one works for the fight only with a melee weapon equipped), a magic weapon with water-spell runes or a Necromancy weapon, a ranged weapon (the last lava monster takes only ranged) and a melee weapon. The 17 stone slabs come during the quest",
            main = "Also an adamant pickaxe or better (the tool belt one works for the fight only with a melee weapon equipped), a magic weapon with water-spell runes or a Necromancy weapon, a ranged weapon (the last lava monster takes only ranged) and a melee weapon. The 17 stone slabs come during the quest",
        },
    }),
    quest("q-elder-kiln", 41, "The Elder Kiln", {
        methods = {
            ironman = "Bring an adamant pickaxe or better (or a melee weapon if it's on the tool belt) and melee, magic or ranged gear: Necromancy doesn't work on TokTz-Ket-Dill, no multicannon, and no familiar in the last fight",
            main = "Bring an adamant pickaxe or better (or a melee weapon if it's on the tool belt) and melee, magic or ranged gear: Necromancy doesn't work on TokTz-Ket-Dill, no multicannon, and no familiar in the last fight",
        },
    }),
    quest("q-brink-of-extinction", 41, "The Brink of Extinction", {
        methods = {
            ironman = "Bring any pickaxe (tool belt works)",
            main = "Bring any pickaxe (tool belt works)",
        },
    }),
    quest("q-wandering-gaal", 41, "Wandering Ga'al", {
        wiki = W .. "Wandering_Ga'al_(miniquest)",
        requires = {
            items = {
                { id = 6583, name = "Ring of stone", count = 1, how = "Buy from TzHaar-Hur-Lek for 303,000 Tokkul, or obtain from TzHaar drops; not used up" },
                { id = 4657, name = "Ring of visibility", count = 1, how = "Reclaim from Rasolo after Desert Treasure; bring the physical ring, Sliske's gift won't work" },
            },
        },
        methods = {
            ironman = "Miniquest. Needs Desert Treasure partly done. Use the ring of visibility on the ring of stone to see TzHaar-Ga'al-Kot",
            main = "Miniquest. Needs Desert Treasure partly done. Use the ring of visibility on the ring of stone to see TzHaar-Ga'al-Kot",
        },
    }),
    quest("q-extinction", 41, "Extinction", {
        methods = {
            ironman = "Bring The Measure (if destroyed, Mr Mordaut gives another during the quest) and keep 6 backpack spaces free for the Erebus part",
            main = "Bring The Measure (if destroyed, Mr Mordaut gives another during the quest) and keep 6 backpack spaces free for the Erebus part",
        },
    }),
    quest("q-twilight-of-the-gods", 41, "Twilight of the Gods", {
        methods = {
            ironman = "Needs the Eyes in Their Stars mystery done and Naressa met in Senntisten (not quests). Keep 3 backpack spaces free; the infernal ashes and vial can be got during the quest",
            main = "Needs the Eyes in Their Stars mystery done and Naressa met in Senntisten (not quests). Keep 3 backpack spaces free; the infernal ashes and vial can be got during the quest",
        },
    }),
    quest("q-aftermath", 41, "Aftermath", {
        methods = {
            ironman = "Nothing to bring",
            main = "Nothing to bring",
        },
    }),
    ---------------------------------------------------------------------------
    -- Phase 42: Mahjarrat III, While Guthix Sleeps and the Ritual. The Temple at
    -- Senntisten, While Guthix Sleeps, Blood Runs Deep, Ritual of the
    -- Mahjarrat, Rebuilding Edgeville, Koschei's Troubles and Tales of the God
    -- Wars (the last three miniquests). From the RuneScape Wiki as of 21
    -- October 2026.
    ---------------------------------------------------------------------------
    quest("q-temple-at-senntisten", 42, "The Temple at Senntisten", {
        methods = {
            ironman = "Needs 125 Kudos (Varrock Museum; not a quest). Bring air and law runes for several Telekinetic Grab casts (one of each per cast; standard spellbook)",
            main = "Needs 125 Kudos (Varrock Museum; not a quest). Bring air and law runes for several Telekinetic Grab casts (one of each per cast; standard spellbook)",
        },
    }),
    quest("q-while-guthix-sleeps", 42, "While Guthix Sleeps", {
        requires = {
            items = {
                { id = 4702, name = "Sapphire lantern (lit)", count = 1, how = "1. Replace a bullseye lantern lens with a cut sapphire.\n2. Add lamp oil.\n3. Light it with a tinderbox (49 Firemaking)." },
                { id = 556, name = "Air rune", count = 11, how = "Rune shops; 3 for the quest, 8 for NPC Contact" },
                { id = 557, name = "Earth rune", count = 1, how = "Buy from rune shops" },
                { id = 554, name = "Fire rune", count = 1, how = "Buy from rune shops" },
                { id = 555, name = "Water rune", count = 1, how = "Buy from rune shops" },
                { id = 558, name = "Mind rune", count = 1, how = "Buy from Aubury's Rune Shop in Varrock" },
                { id = 563, name = "Law rune", count = 1, how = "Buy from rune shops" },
                { id = 560, name = "Death rune", count = 1, how = "Trade an adult cat to a West Ardougne civilian" },
                { id = 9075, name = "Astral rune", count = 4, how = "Baba Yaga, Lunar Isle; 4 for NPC Contact" },
                { id = 564, name = "Cosmic rune", count = 7, how = "Craft at cosmic altar (27 Runecrafting); 4 for NPC Contact, 3 for Charge Orb" },
                { id = 1511, ids = { 1511, 1521, 1519, 6333, 1517, 6332, 1515, 1513, 29556, 40338 }, name = "Logs (not acadia or eternal magic)", count = 1, how = "Cut trees; any logs except acadia or eternal magic" },
                { id = 4542, name = "Lantern lens", count = 1, how = "Blow molten glass with a glassblowing pipe (49 Crafting)" },
                { id = 567, name = "Unpowered orb", count = 1, how = "Blow molten glass with a glassblowing pipe (46 Crafting)" },
            },
        },
        methods = {
            ironman = "1. Meet Warriors' Guild entry: Attack plus Strength 130, or 99 in either.\n2. Bring a ring of charos (a) or 5,000 coins, and equipment to enter the Black Knights' Fortress.\n3. Bring 30 runes of one element for a Charge Orb spell, and gear for two attack styles (or Necromancy).\n4. Bring a snapdragon seed or 100 coins.\n5. The charcoal, papyrus and Mort myre fungus can be got during the quest.",
            main = "1. Meet Warriors' Guild entry: Attack plus Strength 130, or 99 in either.\n2. Bring a ring of charos (a) or 5,000 coins, and equipment to enter the Black Knights' Fortress.\n3. Bring 30 runes of one element for a Charge Orb spell, and gear for two attack styles (or Necromancy).\n4. Bring a snapdragon seed or 100 coins.\n5. The charcoal, papyrus and Mort myre fungus can be got during the quest.",
        },
    }),
    quest("q-blood-runs-deep", 42, "Blood Runs Deep", {
        methods = {
            ironman = "Bring weapons for melee, ranged and magic, and all four elemental Blast, Wave or Surge spells. The rope comes during the quest",
            main = "Bring weapons for melee, ranged and magic, and all four elemental Blast, Wave or Surge spells. The rope comes during the quest",
        },
    }),
    quest("q-ritual-of-the-mahjarrat", 42, "Ritual of the Mahjarrat", {
        requires = {
            items = {
                { id = 4657, name = "Ring of visibility", count = 1, how = "Reclaim from Rasolo after Desert Treasure; from Desert Treasure" },
                { id = 954, name = "Rope", count = 1, how = "Ned in Draynor Village: 15 coins or 4 balls of wool" },
            },
        },
        methods = {
            ironman = "Also a catspeak amulet (e) or cramulet. The spade can be got during the quest (the tool belt one won't work)",
            main = "Also a catspeak amulet (e) or cramulet. The spade can be got during the quest (the tool belt one won't work)",
        },
    }),
    quest("q-rebuilding-edgeville", 42, "Rebuilding Edgeville", {
        wiki = W .. "Rebuilding_Edgeville_(miniquest)",
        requires = {
            items = {
                { id = 6004, name = "Bittercap mushroom", count = 5, how = "Grow bittercap mushroom spores in a mushroom patch (53 Farming)" },
                { id = 960, name = "Plank", count = 20, how = "Turn normal logs into planks at a sawmill; not protean planks" },
                { id = 8778, name = "Oak plank", count = 10, how = "Turn oak logs into planks at a sawmill; not protean planks" },
                { id = 8782, name = "Mahogany plank", count = 10, how = "Turn mahogany logs into planks at a sawmill; not protean planks" },
                { id = 1775, name = "Molten glass", count = 1, how = "Use a bucket of sand and soda ash at a furnace (1 Crafting)" },
                { id = 8786, name = "Marble block", count = 1, how = "Buy from the Stonemason in Keldagrim for 325,000 coins" },
                { id = 555, name = "Water rune", count = 100, how = "Craft essence at the water altar (5 Runecrafting), or buy from rune shops" },
            },
        },
        methods = {
            ironman = "Miniquest. Also a magic watering can (tool belt works)",
            main = "Miniquest. Also a magic watering can (tool belt works)",
        },
    }),
    quest("q-koscheis-troubles", 42, "Koschei's Troubles", {
        wiki = W .. "Koschei's_Troubles_(miniquest)",
        requires = {
            items = {
                { id = 15403, name = "Balmung", count = 1, how = "From Blood Runs Deep" },
            },
        },
        methods = {
            ironman = "Miniquest",
            main = "Miniquest",
        },
    }),
    quest("q-tales-of-the-god-wars", 42, "Tales of the God Wars", {
        wiki = W .. "Tales_of_the_God_Wars_(miniquest)",
        methods = {
            ironman = "Miniquest. Needs 60 Strength or 60 Agility, and access to the God Wars Dungeon (not a quest)",
            main = "Miniquest. Needs 60 Strength or 60 Agility, and access to the God Wars Dungeon (not a quest)",
        },
    }),
    ---------------------------------------------------------------------------
    -- Phase 43: Grandmaster odds and ends. A Clockwork Syringe, Pieces of Hate,
    -- Birthright of the Dwarves, The Firemaker's Curse, Thok Your Block Off
    -- (saga). From the RuneScape Wiki as of 21 October 2026.
    ---------------------------------------------------------------------------
    quest("q-clockwork-syringe", 43, "A Clockwork Syringe", {
        methods = {
            ironman = "Keep at least six backpack spaces free. The diving apparatus and fishbowl helmet can be got during the quest",
            main = "Keep at least six backpack spaces free. The diving apparatus and fishbowl helmet can be got during the quest",
        },
    }),
    quest("q-pieces-of-hate", 43, "Pieces of Hate", {
        requires = {
            items = {
                { id = 1741, name = "Leather", count = 2, how = "Take a cowhide to a tanner, such as the one in Al Kharid" },
                { id = 2357, name = "Gold bar", count = 1, how = "Smelt gold ore at a furnace (40 Smithing)" },
                { id = 2064, ids = { 2064, 9520, 2028 }, name = "Blurberry Special (or premade)", count = 1, how = "Buy a premade Blurberry Special at Blurberry's Bar on the south-east upper floor of the Grand Tree; the premade one works" },
                { id = 2092, ids = { 2092, 2032 }, name = "Drunk Dragon (or premade)", count = 1, how = "1. Shake vodka, gin and dwellberries (32 Cooking).\n2. Pour into a cocktail glass.\n3. Add pineapple chunks and cream, then heat at a range.\n4. The premade Drunk Dragon works too." },
                { id = 2074, ids = { 2074, 2030 }, name = "Chocolate Saturday (or premade)", count = 1, how = "Pick up a premade Chocolate Saturday in Brimstail's cave at the Tree Gnome Stronghold; the premade one works" },
            },
        },
        methods = {
            ironman = "You deposit everything before jail, so you fetch these from the bank after",
            main = "You deposit everything before jail, so you fetch these from the bank after",
        },
    }),
    quest("q-birthright-of-the-dwarves", 43, "Birthright of the Dwarves", {
        methods = {
            ironman = "Keep 7 backpack spaces free",
            main = "Keep 7 backpack spaces free",
        },
    }),
    quest("q-firemakers-curse", 43, "The Firemaker's Curse", {
        methods = {
            ironman = "Keep 4 backpack spaces free",
            main = "Keep 4 backpack spaces free",
        },
    }),
    quest("q-thok-your-block-off", 43, "Thok Your Block Off", {
        wiki = W .. "Thok_Your_Block_Off_(saga)",
        methods = {
            ironman = "Saga. Wear your ring of kinship and find the rock and twine bundle on the occult floors 36-40 of Daemonheim, then ask Skaldrun. The ring can't be taken into the saga",
            main = "Saga. Wear your ring of kinship and find the rock and twine bundle on the occult floors 36-40 of Daemonheim, then ask Skaldrun. The ring can't be taken into the saga",
        },
    }),
    ---------------------------------------------------------------------------
    -- Phase 44: Tales of the Arc I. Flag Fall, Head of the Family, Spiritual
    -- Enlightenment, Jed Hunter, Eye for an Eye (all miniquests). From the
    -- RuneScape Wiki as of 21 October 2026.
    ---------------------------------------------------------------------------
    quest("q-flag-fall", 44, "Flag Fall", {
        wiki = W .. "Flag_Fall_(miniquest)",
        methods = {
            ironman = "Miniquest. Bring up to 1,000+ chimes for supplies. The 5 driftwood come during the miniquest",
            main = "Miniquest. Bring up to 1,000+ chimes for supplies. The 5 driftwood come during the miniquest",
        },
    }),
    quest("q-head-of-the-family", 44, "Head of the Family", {
        wiki = W .. "Head_of_the_Family_(miniquest)",
        requires = {
            items = {
                { id = 37770, name = "Bamboo", count = 5, how = "Cut bamboo stalks on Waiko or Tuai Leit (90 Woodcutting), or pick up ground spawns on Uncharted Isles" },
                { id = 37734, name = "Fish oil", count = 15, how = "Cook 9 raw tarpon, 6 raw seerfish or 3 raw sillago into fish oil (91 Cooking)" },
            },
        },
        methods = {
            ironman = "Miniquest. Also 450 chimes",
            main = "Miniquest. Also 450 chimes",
        },
    }),
    quest("q-spiritual-enlightenment", 44, "Spiritual Enlightenment", {
        wiki = W .. "Spiritual_Enlightenment_(miniquest)",
        methods = {
            ironman = "Miniquest. Needs the 'Meet the Assassin' voyage done in your player-owned port (not a quest)",
            main = "Miniquest. Needs the 'Meet the Assassin' voyage done in your player-owned port (not a quest)",
        },
    }),
    quest("q-jed-hunter", 44, "Jed Hunter", {
        wiki = W .. "Jed_Hunter_(miniquest)",
        requires = {
            items = {
                { id = 37759, name = "Driftwood", count = 10, how = "Pick up driftwood on Uncharted Isles" },
                { id = 38602, name = "Sea shell", count = 5, how = "Pick up sea shells on Uncharted Isles" },
                { id = 37745, name = "Tortle shell bowl", count = 2, how = "Craft 4 shell chippings into a tortle shell bowl (91 Crafting)" },
                { id = 37758, name = "Taijitu", count = 1, how = "Find taijitu in treasure chests or washed up on Uncharted Isles, or use rewards from earlier Tales of the Arc miniquests" },
                { id = 38804, name = "Uncharted island map", count = 1, how = "Buy from Daemonheim Rewards for 15,000 Dungeoneering tokens, or find one while gaining XP outside the Arc; used to kill 3 Gu ronin" },
            },
        },
        methods = {
            ironman = "Miniquest. Also 200+ chimes for supplies",
            main = "Miniquest. Also 200+ chimes for supplies",
        },
    }),
    quest("q-eye-for-an-eye", 44, "Eye for an Eye", {
        wiki = W .. "Eye_for_an_Eye_(miniquest)",
        requires = {
            items = {
                { id = 37772, ids = { 37772, 37773 }, name = "Sea salt (or alaea sea salt)", count = 30, how = "Mine salty crabletines on Cyclosis or salty crablets on Uncharted Isles (90 Mining); alaea sea salt also works. Untradeable" },
            },
        },
        methods = {
            ironman = "Miniquest. Needs the island of Cyclosis discovered in your player-owned port (not a quest)",
            main = "Miniquest. Needs the island of Cyclosis discovered in your player-owned port (not a quest)",
        },
    }),
    ---------------------------------------------------------------------------
    -- Phase 45: Tales of the Arc II. Harbinger, Damage Control, Ghosts from the
    -- Past, Tuai Leit's Own, Final Destination (all miniquests). From the
    -- RuneScape Wiki as of 21 October 2026.
    ---------------------------------------------------------------------------
    quest("q-harbinger", 45, "Harbinger", {
        wiki = W .. "Harbinger_(miniquest)",
        methods = {
            ironman = "Miniquest. Nothing to bring",
            main = "Miniquest. Nothing to bring",
        },
    }),
    quest("q-damage-control", 45, "Damage Control", {
        wiki = W .. "Damage_Control_(miniquest)",
        methods = {
            ironman = "Miniquest. Bring 2,500 chimes",
            main = "Miniquest. Bring 2,500 chimes",
        },
    }),
    quest("q-ghosts-from-the-past", 45, "Ghosts from the Past", {
        wiki = W .. "Ghosts_from_the_Past_(miniquest)",
        methods = {
            ironman = "Miniquest. Nothing to bring",
            main = "Miniquest. Nothing to bring",
        },
    }),
    quest("q-tuai-leits-own", 45, "Tuai Leit's Own", {
        wiki = W .. "Tuai_Leit's_Own_(miniquest)",
        requires = {
            items = {
                { id = 38627, name = "Rumberry", count = 30, how = "Pick from wild rumberry bushes on Tuai Leit or Goshima (86 Farming)" },
                { id = 38612, name = "Positive energy", count = 30, how = "Harvest positive springs on Cyclosis or the third island of Islands That Once Were Turtles (90 Divination)" },
                { id = 37731, name = "Spirit dragon charm", count = 1, how = "Kill Slayer creatures on Aminishi, or find charms on Uncharted Isles; at least one is needed, bring extras for time in the Spirit Realm" },
            },
        },
        methods = {
            ironman = "Miniquest",
            main = "Miniquest",
        },
    }),
    quest("q-final-destination", 45, "Final Destination", {
        wiki = W .. "Final_Destination_(miniquest)",
        methods = {
            ironman = "Miniquest. Nothing to bring",
            main = "Miniquest. Nothing to bring",
        },
    }),
    ---------------------------------------------------------------------------
    -- Phase 46: Sliske's Game II. Fate of the Gods, One of a Kind, The Light
    -- Within, Children of Mah, Mahjarrat Memories (miniquest). From the
    -- RuneScape Wiki as of 21 October 2026.
    ---------------------------------------------------------------------------
    quest("q-fate-of-the-gods", 46, "Fate of the Gods", {
        methods = {
            ironman = "Nothing to bring",
            main = "Nothing to bring",
        },
    }),
    quest("q-one-of-a-kind", 46, "One of a Kind", {
        requires = {
            items = {
                { id = 1605, ids = { 1605, 1621 }, name = "Emerald (cut or uncut)", count = 1, how = "Cut an uncut emerald with a chisel (27 Crafting); an uncut gem also works" },
            },
        },
        methods = {
            ironman = "Also a catspeak amulet (e) or cramulet, a ghostspeak amulet or cramulet (not needed after the hard Morytania achievements), and 875 coins for the Brimhaven Dungeon (not needed after the hard Karamja achievements)",
            main = "Also a catspeak amulet (e) or cramulet, a ghostspeak amulet or cramulet (not needed after the hard Morytania achievements), and 875 coins for the Brimhaven Dungeon (not needed after the hard Karamja achievements)",
        },
    }),
    quest("q-light-within", 46, "The Light Within", {
        requires = {
            items = {
                { id = 13591, name = "Enchanted key", count = 1, how = "From Meeting History; Jorral gives it back for 6,000 coins" },
                { id = 33006, name = "Grand defence potion (6)", count = 1, how = "Unlock the Meilyr recipe (100,000 coins); mix super defence (4) and defence (4) in a crystal flask (79 Herblore). Only the 6-dose potion works" },
                { id = 32609, name = "Light core", count = 3, how = "Convert shadow cores at the Amlodd light rift in Prifddinas (71, 81 or 91 Divination by core); a light core is not guaranteed" },
            },
        },
        methods = {
            ironman = "1. Ironman: As a First Resort, 89 Crafting and 81 Mining (both boostable) to make the crystal flask for the grand defence potion.\n2. Also the Trahaearn exoskeleton set (from Plague's End) and a way into the Baxtorian Falls resource dungeon: Glarial's amulet and a rope, or a hoardstalker ring or Dungeoneering cape if you've been before",
            main = "Also the Trahaearn exoskeleton set (from Plague's End) and a way into the Baxtorian Falls resource dungeon: Glarial's amulet and a rope, or a hoardstalker ring or Dungeoneering cape if you've been before",
        },
    }),
    quest("q-children-of-mah", 46, "Children of Mah", {
        methods = {
            ironman = "Nothing to bring",
            main = "Nothing to bring",
        },
    }),
    quest("q-mahjarrat-memories", 46, "Mahjarrat Memories", {
        wiki = W .. "Mahjarrat_Memories_(miniquest)",
        requires = {
            items = {
                { id = 29742, name = "Invitation box", count = 1, how = "Reclaim from Brother Samwell in Silvarea; from Missing, Presumed Death; for Sliske's memory" },
                { id = 12071, ids = { 12071, 12820 }, name = "Macaw or ravenous locust pouch", count = 1, how = "Infuse a pouch, 78 shards, a green charm and clean guam at an obelisk (41 Summoning); a ravenous locust pouch also works for Zemouregal's memory" },
            },
        },
        methods = {
            ironman = "Miniquest. Also insulated boots. The 7,500 vibrant or better memories are collected during the miniquest (enriched ones count double)",
            main = "Miniquest. Also insulated boots. The 7,500 vibrant or better memories are collected during the miniquest (enriched ones count double)",
        },
    }),
    ---------------------------------------------------------------------------
    -- Phase 47: Nomad and Sliske's Endgame. The Mighty Fall, Nomad's Requiem,
    -- Nomad's Elegy, Tales of Nomad (miniquest), Sliske's Endgame. The last
    -- route phase. From the RuneScape Wiki as of 21 October 2026.
    ---------------------------------------------------------------------------
    quest("q-mighty-fall", 47, "The Mighty Fall", {
        methods = {
            ironman = "Bring a light source",
            main = "Bring a light source",
        },
    }),
    quest("q-nomads-requiem", 47, "Nomad's Requiem", {
        methods = {
            ironman = "Needs the Knight Waves in Camelot and the Soul Wars tutorial done (not quests). Bring a magic weapon and air and fire runes for a fire spell, or runes for a fire Ancient Magicks spell (a staff alone won't do)",
            main = "Needs the Knight Waves in Camelot and the Soul Wars tutorial done (not quests). Bring a magic weapon and air and fire runes for a fire spell, or runes for a fire Ancient Magicks spell (a staff alone won't do)",
        },
    }),
    quest("q-nomads-elegy", 47, "Nomad's Elegy", {
        methods = {
            ironman = "Keep 2 backpack spaces free",
            main = "Keep 2 backpack spaces free",
        },
    }),
    quest("q-tales-of-nomad", 47, "Tales of Nomad", {
        wiki = W .. "Tales_of_Nomad_(miniquest)",
        methods = {
            ironman = "Miniquest. Nothing to bring",
            main = "Miniquest. Nothing to bring",
        },
    }),
    quest("q-sliskes-endgame", 47, "Sliske's Endgame", {
        methods = {
            ironman = "Bring a disguise that gets you into the Black Knights' Fortress (or the Dulcin armour override, the Skull of Remembrance teleport, or the communication device from Dishonour among Thieves)",
            main = "Bring a disguise that gets you into the Black Knights' Fortress (or the Dulcin armour override, the Skull of Remembrance teleport, or the communication device from Dishonour among Thieves)",
        },
    }),
}
