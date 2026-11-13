-- data/methods.lua
-- Static training bands per skill, by level and account mode, with a pure
-- lookup function (M.lookup). No game API or persistence.
--
-- When the planner suggests "Train X to N", it looks up the band that covers
-- the player's current level and shows that method, with its wiki page as the
-- right-click Wiki target. Pages are named exactly as on runescape.wiki so the
-- in-game Wiki option resolves them.
--
-- Shape: skill -> list of bands, each { from, to, ironman = {...}, main = {...} }
--   from/to  level range the band applies to (inclusive)
--   ironman  { name = "shown in the window", wiki = "Wiki page title" }
--   main     same; omit to reuse the ironman entry
--
-- Only skills the current route needs are filled in. Add bands as the route grows.

local M = {}

M.magic = {
    { from = 1,  to = 19, ironman = { name = "combat spells on low-level monsters", wiki = "Magic training" } },
    { from = 20, to = 64, ironman = { name = "Shattered Worlds", wiki = "Shattered Worlds" } },
    { from = 65, to = 99, ironman = { name = "Shattered Worlds or Slayer with magic", wiki = "Magic training" } },
}

M.crafting = {
    { from = 1,  to = 19, ironman = { name = "leather gloves and boots from cowhides", wiki = "Crafting training" },
                          main    = { name = "leather items from bought leather", wiki = "Crafting training" } },
    { from = 20, to = 45, ironman = { name = "gold jewellery from your own gold bars", wiki = "Crafting training" },
                          main    = { name = "gold jewellery from bought gold bars", wiki = "Crafting training" } },
    { from = 46, to = 99, ironman = { name = "molten glass from Entrana sand and seaweed, or cut gems from Mining", wiki = "Crafting training" },
                          main    = { name = "cut bought gems or craft battlestaves", wiki = "Crafting training" } },
}

M.woodcutting = {
    { from = 1,  to = 29, ironman = { name = "normal then oak trees", wiki = "Woodcutting training" } },
    { from = 30, to = 59, ironman = { name = "willows (keep the logs for Fletching and Firemaking)", wiki = "Woodcutting training" } },
    { from = 60, to = 99, ironman = { name = "maples at Seers' Village, or ivy", wiki = "Woodcutting training" } },
}

M.fletching = {
    { from = 1,  to = 24, ironman = { name = "arrow shafts and shortbows from your own logs", wiki = "Fletching training" },
                          main    = { name = "shortbows from bought logs", wiki = "Fletching training" } },
    { from = 25, to = 99, ironman = { name = "unstrung bows from the logs you cut", wiki = "Fletching training" },
                          main    = { name = "unstrung bows from bought logs", wiki = "Fletching training" } },
}

M.firemaking = {
    { from = 1,  to = 29, ironman = { name = "burn the logs you cut", wiki = "Firemaking training" } },
    { from = 30, to = 99, ironman = { name = "bonfires with willow or maple logs", wiki = "Bonfire" } },
}

M.mining = {
    { from = 1,  to = 29, ironman = { name = "copper and tin, then iron", wiki = "Mining training" } },
    { from = 30, to = 99, ironman = { name = "iron then coal at the Mining Guild", wiki = "Mining training" } },
}

M.herblore = {
    { from = 1,  to = 99, ironman = { name = "potions from herbs you farm (Herblore needs Druidic Ritual)", wiki = "Herblore training" },
                          main    = { name = "potions from bought herbs and secondaries", wiki = "Herblore training" } },
}

M.defence = {
    { from = 1, to = 99, ironman = { name = "set combat XP to Defence and fight Slayer tasks", wiki = "Defence training" } },
}

M.strength = {
    { from = 1, to = 99, ironman = { name = "set combat XP to Strength and fight Slayer tasks", wiki = "Strength training" } },
}

M.agility = {
    { from = 1,  to = 29, ironman = { name = "Burthorpe Agility Course", wiki = "Burthorpe Agility Course" } },
    { from = 30, to = 84, ironman = { name = "Gnome Stronghold then Barbarian Outpost course, or the weekly Circus", wiki = "Agility training" } },
    -- Advanced laps also contribute to the long-run agile-equipment goal
    -- (Agile from Head to Toe). Historical Wiki source and requirements:
    -- advanced Gnome Stronghold 85 Agility, 250 laps for the legs; advanced
    -- Barbarian Outpost 90 Agility (Bar Crawl miniquest for the outpost), 250
    -- laps for the top.
    { from = 85, to = 89, ironman = { name = "the advanced Gnome Stronghold course (laps count towards the agile legs)",
                                      wiki = "Gnome Stronghold Agility Course" } },
    { from = 90, to = 99, ironman = { name = "the advanced Barbarian Outpost (Bar Crawl miniquest first) or Gnome Stronghold course (laps count towards the agile top and legs)",
                                      wiki = "Barbarian Outpost Agility Course" } },
}

M.thieving = {
    { from = 1,  to = 37, ironman = { name = "pickpocket men, then stalls in Ardougne", wiki = "Thieving training" } },
    { from = 38, to = 99, ironman = { name = "pickpocket Master Farmers (also gives seeds)", wiki = "Master Farmer" } },
}

M.slayer = {
    { from = 1, to = 99, ironman = { name = "Slayer tasks from the highest master you can use", wiki = "Slayer training" } },
}

-- Cooking follows the RS3 Wiki training guide's recommended start levels,
-- rather than recipe unlocks. Intervals end just before the next start level.
-- The lookup only knows Cooking level and mode: supply/access/equipment
-- conditions stay explicit rather than pretending to have checked them.
M.cooking = {
    { from = 1, to = 14, ironman = { name = "cook crayfish you catch (1 Fishing)", wiki = "Free-to-play Cooking training" },
                         main = { name = "cook bought raw crayfish", wiki = "Free-to-play Cooking training" } },
    { from = 15, to = 27, ironman = { name = "cook your raw trout, or crayfish if unavailable", wiki = "Pay-to-play Cooking training" },
                          main = { name = "cook bought raw trout; some will burn", wiki = "Pay-to-play Cooking training" } },
    { from = 28, to = 51, ironman = { name = "cook your sweetcorn, or lower-level catches if unavailable", wiki = "Pay-to-play Cooking training" },
                          main = { name = "cook bought sweetcorn; some will burn", wiki = "Pay-to-play Cooking training" } },
    { from = 52, to = 79, ironman = { name = "cook desert sole (supply: 52 Fishing and Menaphos access), or lower catches; burning possible", wiki = "Pay-to-play Cooking training" },
                          main = { name = "cook bought raw desert sole; burning possible", wiki = "Pay-to-play Cooking training" } },
    { from = 80, to = 89, ironman = { name = "cook beltfish (supply: 72 Fishing and Menaphos access), or lower catches; high burns without cooking gauntlets", wiki = "Pay-to-play Cooking training" },
                          main = { name = "cook bought raw beltfish; high burns without cooking gauntlets", wiki = "Pay-to-play Cooking training" } },
    { from = 90, to = 92, ironman = { name = "cook your raw sharks if supplied, or lower catches; cooking gauntlets reduce burns", wiki = "Pay-to-play Cooking training" },
                          main = { name = "cook bought raw sharks; cooking gauntlets reduce burns", wiki = "Pay-to-play Cooking training" } },
    { from = 93, to = 94, ironman = { name = "cook your raw rocktails if supplied, or lower catches; burning possible", wiki = "Pay-to-play Cooking training" },
                          main = { name = "cook bought raw rocktails; burning possible", wiki = "Pay-to-play Cooking training" } },
    { from = 95, to = 99, ironman = { name = "cook your raw blue blubber jellyfish if supplied, or lower catches; burning possible", wiki = "Pay-to-play Cooking training" },
                          main = { name = "cook bought raw blue blubber jellyfish; burning possible", wiki = "Pay-to-play Cooking training" } },
}

M.fishing = {
    { from = 1, to = 19, ironman = { name = "catch crayfish at Lumbridge with a crayfish cage (no bait)", wiki = "Free-to-play Fishing training" } },
    { from = 20, to = 29, ironman = { name = "lure trout at Lumbridge with a fly fishing rod and feathers", wiki = "Free-to-play Fishing training" } },
    { from = 30, to = 99, ironman = { name = "lure trout and salmon at Lumbridge with a fly fishing rod and feathers", wiki = "Free-to-play Fishing training" } },
}

M.farming = {
    { from = 1, to = 8, ironman = { name = "plant potatoes in allotments (three seeds per patch)", wiki = "Farming training" } },
    { from = 9, to = 14, ironman = { name = "grow guam herbs and allotment crops between other tasks", wiki = "Farming training" } },
    { from = 15, to = 99, ironman = { name = "grow oak trees, then higher trees as unlocked; grow herbs between tasks", wiki = "Farming training" } },
}

M.runecrafting = {
    { from = 1, to = 32, ironman = { name = "siphon creatures and nodes on Runespan's lower level", wiki = "Runespan" } },
    { from = 33, to = 65, ironman = { name = "siphon creatures and nodes on Runespan's middle level", wiki = "Runespan" } },
    { from = 66, to = 99, ironman = { name = "siphon creatures and nodes on Runespan's upper level", wiki = "Runespan" } },
}

-- Finds the method for a skill at a given level and mode. Returns
-- { name, wiki } or nil when there's no entry.
function M.lookup(skill, level, mode)
    local bands = M[skill]
    if type(bands) ~= "table" then return nil end
    for _, band in ipairs(bands) do
        if level >= band.from and level <= band.to then
            if mode ~= "ironman" and mode ~= "hardcore" and mode ~= "group" and band.main then
                return band.main
            end
            return band.ironman
        end
    end
    return nil
end

return M
