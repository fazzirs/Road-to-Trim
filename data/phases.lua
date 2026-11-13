-- data/phases.lua
-- Route phase names for the Progress tab's ROUTE label ("Phase 2 / 47:
-- early members quests that open regions and the mid-game chains"). Each
-- is copied word for word from the "-- Phase N: ..." comment
-- heading that phase's block in data/steps.lua: the text after "Phase N: "
-- up to its first full stop, joined over the comment's following lines
-- where the sentence wraps (phases 8, 9, 12 and 37). The comments stay in
-- data/steps.lua; tests/run_tests.lua reads both and checks they agree, so
-- a renamed phase shows up as a failing test, not a stale name.
-- A phase with no name here shows as just "Phase N".
-- Static data: no game API.

return {
    [1] = "Lumbridge and the free-to-play starters",
    [2] = "early members quests that open regions and the mid-game chains",
    [3] = "the Lunar chain and desert quests",
    [4] = "Morytania",
    [5] = "gnome and fairy travel",
    [6] = "Ape Atoll and the way to the elves",
    [7] = "the elves after Regicide, and the balloons",
    [8] = "Rimmington, Port Sarim and Draynor, all free and with no skill requirements",
    [9] = "Varrock, Lumbridge and Edgeville, all free, none needing another quest",
    [10] = "Falador, Taverley and Al Kharid, all free",
    [11] = "the free quests with 30-40 skills, and the free saga",
    [12] = "the members' Novice quests in Kandarin, none needing another quest",
    [13] = "Wendlewick and Havenhythe",
    [14] = "the Temple Knights",
    [15] = "the Kharidian Desert, first part",
    [16] = "Lumbridge and Varrock, members' quests",
    [17] = "Keldagrim and Dorgesh-Kaan",
    [18] = "Morytania, first part, and Rum Deal",
    [19] = "the Elder God Wars begin, and Anachronia",
    [20] = "the Fremennik Province, first part",
    [21] = "Karamja and Feldip",
    [22] = "Kandarin, second part",
    [23] = "Varrock members' quests, second part",
    [24] = "Fort Forinthry",
    [25] = "Legacy of Zamorak and Summer",
    [26] = "Trolls and the Fremennik Isles",
    [27] = "City of Um",
    [28] = "Heroes, Legends and early Mahjarrat",
    [29] = "Penguins, gnomes and fairies",
    [30] = "Sliske's Game opening and Mos Le'Harmless",
    [31] = "Kharidian Desert II",
    [32] = "Daemonheim and the sagas",
    [33] = "Doric's and Boric's later tasks, and the Thieves' Guild",
    [34] = "The elves and East Ardougne",
    [35] = "Piscatoris, the Wise Old Man and Rellekka",
    [36] = "Red Axe dwarves and the Myreque",
    [37] = "Desert Treasure, and finishing Recipe for Disaster and Dimension of Disaster",
    [38] = "Senliten's tomb to Menaphos, and the Void Knights",
    [39] = "Elder God Wars II and Anachronia",
    [40] = "The First Necromancer, Fort Forinthry II and Menaphos",
    [41] = "TzHaar and the end of the Elder God Wars",
    [42] = "Mahjarrat III, While Guthix Sleeps and the Ritual",
    [43] = "Grandmaster odds and ends",
    [44] = "Tales of the Arc I",
    [45] = "Tales of the Arc II",
    [46] = "Sliske's Game II",
    [47] = "Nomad and Sliske's Endgame",
}
