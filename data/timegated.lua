-- data/timegated.lua
-- Cape achievements limited by real time, and when each one can be worked on.
-- Static data: no game API, no persistence (main.lua and core/views.lua
-- read the live state through core/detect.lua).
--
-- Source: the "Time gated" table on the RuneScape Wiki page
-- "Completionist Cape (achievement)/Breakdown" (read 19 October 2026), with
-- reset rhythms from the wiki's Distractions and Diversions table. The
-- Trimmed Completionist breakdown has no time-gated section.
-- Where neither page gives a rhythm, `reset` is omitted and only the note
-- is shown; don't fill one in without a source.
--
--   names     achievement name(s) as the game spells them (looked up live)
--   activity  what to do
--   reset     "daily" | "weekly" | "12h" | "halfhour" (see core/clock.lua)
--   limit     how often per reset, as the wiki states it
--   note      the wiki's note
--   wiki      page to open with right-click > Wiki
--   uses      times per reset period (wiki D&D table "Frequency" column);
--             shown as that many circles, green = used, red = not yet
--   counter   the varbit counting uses this period, by config name and the
--             ID it was found under (dev-world dump, 19 October 2026). The
--             meaning is read from the name; `confirmed` stays false until a
--             play-through shows it count up. Omitted = can't tell, grey circles.
--   need      the lifetime target from this entry's own text ("40 penguins
--             needed in total" -> 40). Live progress comes only from the
--             game's own achievement tally (Detect.capeItem's tally), never
--             from `counter`, which counts this period's uses.
--   perReset  how many of `need` one reset period allows, from the same
--             text ("up to 12 penguins" -> 12; "once a week" -> 1)
--   rate      that pace in words, for the Progress tab's "about N more
--             weeks at <rate>" note; only with need and perReset
--   short     optional timer-chip abbreviation ("Port in 11h 15m"), so two
--             chips share a row; other views keep `activity`. Omitted means
--             `activity`.

return {
    { names = { "From Ardougne with Love" }, activity = "Penguin Hide and Seek", short = "Penguins", reset = "weekly",
      limit = "once weekly, up to 12 penguins", note = "40 penguins needed in total", wiki = "Penguin Hide and Seek",
      uses = 1, need = 40, perReset = 12, rate = "up to 12 a week" },
    { names = { "Invention Gives Me the Blues" }, activity = "Invention tasks", short = "Invention", reset = "12h",
      limit = "new tasks at 00:00 and 12:00", note = "tasks stack to 5", wiki = "Invention Gives Me the Blues" },
    { names = { "Big Chinchompa" }, activity = "Big Chinchompa", reset = "halfhour", period = "daily",
      limit = "twice daily, at half past each hour", wiki = "Big Chinchompa",
      uses = 2, counter = { name = "DNDTRACKER_BIGCHINCHOMPA_GAME_PLAYED", id = -20754, confirmed = false } },
    { names = { "Sinking Fast", "Totem Pole Position" }, activity = "Sinkholes", reset = "halfhour", period = "daily",
      limit = "twice daily, at half past each hour", wiki = "Sinkholes",
      uses = 2, counter = { name = "RAND_DND_DAILY_GAMES", id = -17934, confirmed = false } },
    { names = { "Bag of Herbs" }, activity = "Herby Werby", reset = "weekly", limit = "once weekly", wiki = "Herby Werby",
      uses = 1, counter = { name = "DINO_HERBLORE_DND_COMPLETED", id = -44350, confirmed = false } },
    { names = { "Make Them Bleed", "Properly Metal" }, activity = "Rush of Blood", reset = "weekly",
      limit = "once weekly", note = "needs Plague's End and 85 Slayer", wiki = "Rush of Blood",
      uses = 1 },
    { names = { "Trip to the East", "Walking the Reef" }, activity = "Player-owned port", short = "Port", reset = "daily",
      limit = "voyage rerolls refresh daily", wiki = "Player-owned port" },
    -- Additional activities with real-time limits, from the linked historical
    -- Wiki pages (added 26 October 2026; not on the breakdown's time-gated
    -- table):
    -- Friend of the Imcando: Thalmund is in the City of Um only on Wednesdays,
    -- seven different weeks needed; the weekly reset is Wednesday 00:00 UTC.
    -- It has a weekly reference but no `uses` field, so it does not enter the
    -- immediate-use queue (without a counter it would be suggested every day);
    -- the weekly reset alert lands on Wednesday, when he's there.
    { names = { "Friend of the Imcando" }, activity = "Thalmund (City of Um)", short = "Thalmund", reset = "weekly",
      limit = "Wednesdays only, once a week", note = "7 different weeks needed", wiki = "Friend of the Imcando",
      need = 7, perReset = 1, rate = "once a week" },
    -- Castaways page: the visible messages in bottles change at the daily
    -- reset (00:00 UTC), each on its own cycle of a few days.
    { names = { "Castaways of the Arc" }, activity = "Arc castaway bottles", short = "Arc bottles", reset = "daily",
      limit = "bottles change at the daily reset", wiki = "Castaways" },
    -- Effigy Incubator page: monthly D&D, hard reset the 1st at 00:00 UTC,
    -- after Sins of the Father; 12 encounters needed (Following In The Footsteps).
    { names = { "Following In The Footsteps" }, activity = "Effigy Incubator", short = "Effigy", reset = "monthly",
      limit = "once a month", note = "12 encounters; needs Sins of the Father", wiki = "Effigy Incubator",
      uses = 1, need = 12, perReset = 1, rate = "once a month" },
    { names = { "Top Town Hall" }, activity = "Anachronia base camp", wiki = "Anachronia base camp" },
    { names = { "A Periodic Table" }, activity = "Managing Miscellania", note = "mahogany logs (needs Royal Trouble)",
      wiki = "Managing Miscellania" },
    { names = { "Power Planter II" }, activity = "Garden of Kharid", note = "33,950 Crux Eqal favour", wiki = "Garden of Kharid" },
    { names = { "Bean There, Done That" }, activity = "Manor Farm", note = "38,600 beans", wiki = "Manor Farm" },
    { names = { "Bean There, Done That, Got the Postcard" }, activity = "Anachronia Dinosaur Farm", note = "35,100 beans",
      wiki = "Anachronia Dinosaur Farm" },
    { names = { "Sing-Along-a-Seren Verse 1", "Sing-Along-a-Seren Verse 2", "Sing-Along-a-Seren Verse 3",
                "Sing-Along-a-Seren Verse 4", "Sing-Along-a-Seren Verse 5", "Sing-Along-a-Seren Verse 6",
                "Sing-Along-a-Seren Verse 7" },
      activity = "Voice of Seren", note = "part of the Tirannwn hard set tasks", wiki = "Voice of Seren" },
}
