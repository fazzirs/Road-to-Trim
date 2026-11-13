-- data/longachievements.lua
-- Curated long-run cape goals: points, tokens, favour or reputation gathered
-- over many sessions, or every reward of a minigame. They are excluded from
-- Guide suggestions and listed on Progress under LONG-RUN GOALS, each with
-- its Details view. main.lua may show one generic reminder per session
-- pointing to Progress. Time-gated goals are not here (data/timegated.lua
-- covers them).
-- Names as the game's cape checklist gives them; capitals and punctuation
-- don't matter. Picked by hand from the Wiki descriptions in
-- data/achievements.lua, quoted after each name as historical descriptions;
-- this comment cleanup does not re-verify them.
-- An entry is a name or { name, how = "...", short = "..." }: `how` is the
-- fallback Details action; `short` is kept but not used by the current
-- reminder.
-- Static data: no game API, no persistence.

return {
    -- Done while doing herb runs. Historical source: RuneScape Wiki, Crux
    -- Eqal favour: earned harvesting any herb patch, more for the daily herb,
    -- once you've spoken to Polletix at the Garden of Kharid with 50 Farming.
    { "A Druid's Sidekick", how = "herb runs; talk to Polletix (Garden of Kharid, 50 Farming) first or they earn no favour",
      short = "herb runs; talk to Polletix first" },   -- Unlock the listed upgrades from Sydekix's Shop. (X/7)
    "Granny's Favourite Farmer",   -- Gain max reputation with the Farming Guild.
    "Out of this World",   -- Unlock everything in the Shooting Star Reward Shop. (X/3)
    "Conquered Everyone's Heart",   -- Reach maximum reputation with all Heart of Gielinor factions. (X/4)
    "War. What Is It Good For?",   -- Buy all unlocks and upgrades from War's store. (X/2)
    "My Goebie Homies",   -- Obtain maximum reputation with the goebies on Mazcab.
    "Death Effect",   -- Unlock all permanent effects from Death's Store. (X/7)
    "All Your Energies",   -- Unlock the energy-gathering scrimshaw scroll from Waiko ports reward shop.
    "Bone to Pick With You",   -- Unlock the bonecrusher upgrade from Waiko reward shop.
    "Don't Crush My Memories",   -- Unlock the memory-crushing scrimshaw scroll from the Waiko ports reward shop.
    "Mitts and Waders - Death Lotus",   -- Unlock the death lotus gloves and boots scrolls from the Waiko reward shop.
    "Mitts and Waders - Seasinger",   -- Unlock the seasinger gloves and boots scrolls from the Waiko reward shop.
    "Mitts and Waders - Tetsu",   -- Unlock the tetsu gloves and boots scrolls from the Waiko reward shop.
    "Upgrading Waiko I",   -- Purchase the first tier of upgrades in the Waiko reward shop.
    "Unlocking Waiko I",   -- Purchase unlocks from the Waiko reward shop.
    "Reputation - Class Crown",   -- Earn tier 10 reputation with the imperial faction in Menaphos.
    "Reputation - To the Bone",   -- Earn tier 10 reputation with the worker faction in Menaphos.
    "Reputation - Seagullible",   -- Earn tier 10 reputation with the ports faction in Menaphos.
    "Reputation - Lock, Stock and Barrel",   -- Earn tier 10 reputation with the merchant faction in Menaphos.
    "The Golden Crocodile Hunter",   -- Unlock all Hunter upgrades from Dundee's Shop.
    "The Crocodile Hunter",   -- Unlock all non-cosmetic Hunter upgrades from Dundee's Shop.
    "The Prodigal Spender",   -- Purchase all permanent unlocks from Ezreal's shop at the Archaeology Guild. (X/8)
    "Perky Like a Prawn",   -- Gain all possible Prawn Perk Points for your Aquarium. (X/2)
    "Kal'gerion Commander",   -- Unlock the Kal'gerion battle commendation titles.
    "Heal, Quickly",   -- Unlock the prayer 'Rapid Renewal' by purchasing the scroll of renewal from the Dungeoneering reward shop.
    "No Need to Pikkenchoose",   -- Unlock everything from Pikkenflix's Shrine of the Spirit Wolf shop south of Wendlewick.
    "Jack of the Circus",   -- Obtain all circus clothing from Balthazar Beauregard's Big Top Bonanza.
    "Master Angler",   -- Purchase the champion's tackle box from the Fish Flingers fisherman.
    "Globetrotter",   -- Purchase the full Globetrotter outfit.
    "Penguin Adoption Agency",   -- Adopt Sheldon the penguin by tracking penguin spies around the world.
    "Work on Your Artisan II",   -- Unlock all rewards from the Artisans' Workshop (including outfits and excluding auras).
    "Almost as Perky as a Prawn",   -- Unlock all the Prawn Perks from your Aquarium. (X/6)
    -- Done passively. Historical sources: Wiki agile equipment and advanced
    -- course pages (250 laps each; Barbarian Outpost needs the Bar Crawl
    -- miniquest); verify lap and level requirements when updating advice.
    { "Agile from Head to Toe", how = "250 laps each: advanced Barbarian Outpost (top, 90 Agility, Bar Crawl miniquest first), advanced Gnome Stronghold (legs, 85)",
      short = "laps on the advanced Barbarian and Gnome courses" },   -- Unlock the agile top and leg rewards from advanced Agility courses.
}
