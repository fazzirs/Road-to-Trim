-- data/achievementguidance.lua
-- Hand-authored next actions by achievement name, shown in achievement
-- Details and the compact card's instructions; separate from the generated
-- descriptions and targets. core/detect.lua owns completion and counts.
-- Static data: no game API, no persistence.
-- Historical sources: RuneScape Wiki achievement articles and their
-- activity / NPC guides; attach source links and dates to future factual
-- edits.
return {
    ["A Druid's Sidekick"] = {
        "1. Buy every upgrade at Sydekix's Shop of Balance with Crux Eqal favour from herb runs.",
        "2. At 50 Farming, talk to Polletix at the Garden of Kharid first, or herbs earn no favour.",
        "3. Full completion needs 110 Farming and Power Planter II.",
        prepare = {
            "At 50 Farming, talk to Polletix at the Garden of Kharid, then harvest herbs for favour.",
            "Full completion needs 110 Farming and Power Planter II.",
        },
    },
    ["Granny's Favourite Farmer"] = {
        "1. Reach 2,500,000 Farming reputation at Manor Farm, north of Ardougne.",
        "2. Start with Granny Potterington's tutorial (17 Farming, 20 Construction).",
        "3. Harvest, check patch health, collect produce or fill Farming Requests; planting gives none.",
    },
    ["Aereck's Old Bones"] = {
        "1. Talk to Father Aereck in Lumbridge Church.",
    },
    ["Azacorax's Rewards"] = {
        "1. After Rune Memories, talk to Azacorax in the Wizards' Tower, one floor above ground level.",
        "2. Needs 50 Magic and 50 Prayer. Claim the reward; just visiting him doesn't count.",
    },
    ["Buy and Sell Some XP"] = {
        "1. After Buyers and Cellars, with 62 Thieving, talk to Darren Lightfinger in the Thieves' Guild.",
        "2. Agree to teach him tips, then pickpocket Mark 1, finishing the chat after each try.",
    },
    ["Globetrotter"] = {
        "1. Buy the five Globetrotter pieces from Zaida, south of the Grand Exchange: 4,950 points.",
        "2. Earn Treasure Trail Points from clues. Zaida's Reclaim returns a lost piece.",
    },
    ["Master Angler"] = {
        "1. Buy the upgrades in order; earn tokens and medals by playing Fish Flingers outside the Fishing Guild.",
    },
    ["All Your Energies"] = {
        "1. Buy the energy-gathering scrimshaw scroll from Boni in Waiko market: 5,000 chimes, 5 taijitu.",
        "2. Needs Impressing the Locals, 80 Divination and an upgraded Player-owned Ports workshop.",
        "3. Arc chimes come from Waiko merchants; they aren't your Player-owned Ports chimes.",
    },
    ["Don't Crush My Memories"] = {
        "1. Buy the memory-crushing scrimshaw scroll from Boni in Waiko market: 5,000 chimes, 5 taijitu.",
        "2. Needs Impressing the Locals, 80 Divination and an upgraded Player-owned Ports workshop.",
        "3. Arc chimes come from Waiko merchants; they aren't your Player-owned Ports chimes.",
    },
    ["Bone to Pick With You"] = {
        "1. Buy the bonecrusher upgrade from Boni in Waiko market: 25,000 chimes and 25 taijitu.",
        "2. Needs Impressing the Locals and 25 Dungeoneering. You don't need to own a bonecrusher.",
    },
    ["Mitts and Waders - Death Lotus"] = {
        "1. Buy the Death Lotus gloves and boots scrolls from Boni in Waiko market.",
        "2. Each costs 2,500 chimes and 3 taijitu. Needs Impressing the Locals and 90 Crafting.",
    },
    ["Mitts and Waders - Seasinger"] = {
        "1. Buy the seasinger gloves and boots scrolls from Boni in Waiko market.",
        "2. Each costs 2,500 chimes and 3 taijitu. Needs Impressing the Locals and 90 Runecrafting.",
    },
    ["Mitts and Waders - Tetsu"] = {
        "1. Buy the tetsu gloves and boots scrolls from Boni in Waiko market.",
        "2. Each costs 2,500 chimes and 3 taijitu. Needs Impressing the Locals and 90 Smithing.",
    },
    ["Upgrading Waiko I"] = {
        "1. Buy tier 1 of all five upgrades from Boni in Waiko market: 17,000 chimes, 16 taijitu.",
        "2. Needs Impressing the Locals. Only tier 1 counts here; higher tiers are Upgrading Waiko II.",
    },
    ["Unlocking Waiko I"] = {
        "1. Buy the five unlocks from Boni in Waiko market: 7,750 chimes and 5 taijitu in total.",
        "2. Needs Impressing the Locals. Follow the achievement's unchecked list.",
    },
    ["Out of this World"] = {
        "1. Buy the telescope upgrades, title and pet from Wizard Rosalina: 28,000 stardust in total.",
        "2. She is two floors above ground level in the Wizards' Tower. Mine shooting stars for stardust.",
    },
    ["Heal, Quickly"] = {
        "1. Buy the scroll of renewal from Marmaros, south of Daemonheim, for 38,000 tokens.",
        "2. Read it: buying it without reading doesn't count.",
    },
    ["Cook's Delights"] = {
        "1. After Cook's Assistant, talk to the Cook in Lumbridge Castle's kitchen to claim the extra reward.",
    },
    ["Any Odd Chicken"] = {
        "1. After Ernest the Chicken, talk to Professor Oddenstein on Draynor Manor's top floor.",
        "2. Claim any unreceived eggs and feathers.",
    },
    ["Cecilia, I'm Begging You, Please..."] = {
        "1. After One Piercing Note, talk to Sister Cecilia in the Abbey of St. Elspeth Citharede.",
        "2. Tell her to leave or stay; either answer counts.",
    },
    ["Blinded by Ramarno's Teaching"] = {
        "1. Give Ramarno a redberry pie at the Sacred Forge, through the hole on top of Ice Mountain.",
        "2. Needs access from Defender of Varrock; bring a light source.",
    },
    ["Claiming the Knight's Experience"] = {
        "1. After The Knight's Sword, rub its Smithing XP lamp; just having it doesn't count.",
        "2. Lost it? Squire Asrol in the White Knights' Castle courtyard gives it back.",
    },
    ["Daero Take This Experience?"] = {
        "1. After Monkey Madness, ask Daero for training at Blurberry's Bar, one floor above ground level.",
        "2. Choose your combat skills and finish the conversation.",
    },
    ["Claiming Azzanadra's Heart"] = {
        "1. Talk to Azzanadra in the Senntisten Temple and claim the medium XP lamp.",
        "2. Needs Heart of Stone and The Temple at Senntisten.",
    },
    ["Chilling with Arrav"] = {
        "1. After Ritual of the Mahjarrat, put Arrav to rest beside the Ice Fortress wall.",
        "2. Take fairy ring DKQ to the Glacor Cave and go north through it.",
    },
    ["Complete History of Droalak"] = {
        "1. After Making History, talk to Droalak behind the Port Phasmatys general store to free him.",
        "2. Wear a ghostspeak amulet unless the Hard Morytania achievements let you understand ghosts.",
    },
    ["Angs Off My Ring"] = {
        "1. Give Angof the ancient elven wedding ring on Tarddiad, via the World Gate.",
        "2. Kill Crystal shapeshifter monsters there for the ring. Needs The Light Within.",
    },
    ["Cower Behind the Chosen Commander"] = {
        "1. In Goblin Village, ask General Wartface or General Bentnoze.",
    },
    ["Carnillean Riches"] = {
        "1. After Carnillean Rising, give Lady Henryeta her necklace or open Sir Ceril's money pouch.",
        "2. Either one counts. Missing item? Search the chest beside Ceril in the mansion.",
    },
    ["Cran Door's Secret"] = {
        "1. Open the hidden wall beyond Elvarg's lair from the Crandor side to make the shortcut.",
        "2. Do it during Dragon Slayer, or later via the Karamja Volcano dungeon.",
    },
    ["As Clear as a Crystal Seed"] = {
        "1. Add the Temple of Light teleport to a charged crystal teleport seed.",
        "2. Ask Eluned in Isafdar, or Islwyn in Prifddinas after The Light Within.",
        "3. Carry exactly one seed; bank the others.",
    },
    ["Chippy Transport"] = {
        "1. After Love Story, ask Runvastr in Keldagrim about mining for the miner's diary.",
        "2. Take the diary to the Wise Old Man in Draynor Village.",
    },
    ["For the Love of Mabel"] = {
        "1. After Love Story, return Mabel's ring to Mabel in the barn north-east of Draynor Village.",
        "2. Also chop down the tree the guard is stuck in, in Draynor Village.",
        "3. Lost the ring? Zenevivia in Draynor Village replaces it.",
    },
    ["Claus is Rising"] = {
        "1. After Carnillean Rising, kill the Cave Wolf Matriarch and give her skull to Claus the chef.",
        "2. He's below the Carnillean mansion; ask about returning to reach her. The kill alone isn't enough.",
    },
    ["Nano to Kipple, Come in Kipple"] = {
        "1. After Heart of Stone, ask Ariane at the Wizards' Tower about Kipple.",
    },
    ["Fred's Shearings"] = {
        "1. After Sheep Shearer, talk to Fred the Farmer north of Lumbridge to claim the extra coins.",
    },
    ["Pure Newbstalgia"] = {
        "1. After Beneath Cursed Tides, play Lev's old music box.",
        "2. Destroyed it unplayed? Ask Wizard Myrtle near the Wizards' Tower.",
    },
    ["Let's Hope it Doesn't Un-Shrink"] = {
        "1. After Once Upon a Slime, claim King Slime's Top Hat from Eva, south of Varrock east bank.",
    },
    ["Curses!"] = {
        "1. After The Temple at Senntisten, read the ancient hymnal.",
        "2. Lost it? Ask Azzanadra in the Senntisten Temple for another.",
    },
    ["Goulash! Get Your Free Goulash!"] = {
        "1. After Swept Away, drink all ten goulash portions from Maggie's cauldron, north of Draynor.",
        "2. Fill an empty bowl at the cauldron; you can hold only one at a time.",
    },
    ["Rusty Reward"] = {
        "1. After Rocking Out, ask the Bartender in Port Sarim's Rusty Anchor about rum for the refund.",
    },
    ["That'll Teach Bill"] = {
        "1. Bill Teach is in Port Phasmatys' Green Ghost inn.",
    },
    ["Scorpvino"] = {
        "1. The Observatory assistant is in the reception building north of the Observatory.",
        "2. Drinking the wine isn't needed.",
    },
    ["Shadow Hanging Over Me"] = {
        "1. Collect every dungeon chest's treasure in A Shadow over Ashdale.",
        "2. Missed some? After the quest, ask Gudrik in Port Sarim.",
    },
    ["Learning from Mr Mordaut"] = {
        "1. Mr. Mordaut's office is in Varrock Museum, through the door behind the stairs on the lowest floor.",
    },
    ["Legal Entitlement"] = {
        "1. After Vessel of the Harbinger, tell the Old man on the shipwreck what happened to his mother.",
        "2. The wreck is north of Alice's farm in Morytania.",
    },
    ["Jas not Meant for Mortal Hands"] = {
        "1. Talk to the Submerged Statue off Entrana's north-west shore and confirm a bonus XP skill.",
        "2. Needs One of a Kind and Ritual of the Mahjarrat. Bank weapons and armour for Entrana.",
    },
    ["Naturally Muspah"] = {
        "1. After The Tale of the Muspah, answer the Natural historian's questions for the antique lamp.",
        "2. He's north-east of the Rellekka Hunter area.",
    },
    ["Redistribution of Knowledge"] = {
        "1. Needs 20 Thieving. Caelyn Kadaan is one floor above ground in the house north of Edgeville bank.",
    },
    ["Resting Lich Place"] = {
        "1. Dig at the Necromancer Tower's south-east corner (fairy ring DJP), then talk to Rasial.",
        "2. Needs the Nom-Nom-Nom-Nom research (86 Archaeology) from Tomes of the Warlock.",
        "3. Carry a spade; the tool-belt spade doesn't work.",
    },
    ["Unholy Crafting"] = {
        "1. After Observatory Quest, talk to the Spirit of Scorpius north of the Observatory.",
    },
    ["Bane Tuner"] = {
        "1. Read the tune bane scroll in the Kethsi library (fairy rings DIR then AKS).",
        "2. It's in the south-east bookcase of the west island library. Needs Ritual of the Mahjarrat.",
    },
    ["Out into the Ourania"] = {
        "1. After Lunar Diplomacy, talk to Baba Yaga on Lunar Isle while on the Lunar spellbook.",
    },
    ["Mazcab Teleport"] = {
        "1. Buy and read the Mazcab teleport codex from the Armoursmith for 2,000 teci.",
        "2. Earn teci from Liberation of Mazcab raid rewards.",
    },
    ["Peachy Bones"] = {
        "1. Buy Bones to Peaches at the Mage Training Arena, north-east of Het's Oasis.",
        "2. Needs points from all four rooms: 200 Telekinetic, 300 Alchemist, 2,000 Enchantment, 200 Graveyard.",
        "3. Needs 33 Magic and a progress hat from the Entrance Guardian.",
    },
    ["An Essential Accessory"] = {
        "1. Make the expansive essence pouch, starting with a hungry hood from Wizard Rinsit (20,000 points).",
        "2. Needs 105 Runecrafting and 95 Divination without boosts.",
        "3. The Wiki lists the ten steps; the last is filling the pouch in the Rune Essence mine.",
    },
    ["Absolute Planker"] = {
        "1. Buy the plank box and both upgrades from the Estate Agents Shop: 500 contract credits.",
        "2. Earn credits from Construction Contracts (40 Construction). Buy only what you still need.",
    },
    ["Bag of Herbs"] = {
        "1. Buy the herb bag and its upgrade at Herby Werby, Anachronia: 400 spirit points.",
        "2. Earn points by playing weekly. Playing alone doesn't buy the rewards.",
    },
    ["Power Planter II"] = {
        "1. Buy all four Plant Power tiers from Sydekix's Shop of Balance: 33,950 favour.",
        "2. Talk to Polletix at 50 Farming first. Tier 4 needs 110 Farming without boosts.",
        prepare = {
            "At 50 Farming, speak to Polletix at the Garden of Kharid, then do herb runs for favour.",
            "Tier 4 needs 110 Farming without boosts and the earlier Plant Power tiers.",
        },
    },
    ["Brutal Stuffsies"] = {
        "1. After Zogre Flesh Eaters, sell Uglug Nar a 3- or 4-dose Relicym's balm outside Jiggig.",
        "2. Ask Sithik Ints in Yanille about the disease first, to learn about the balm.",
    },
    ["Buying Up Ancient Artefacts"] = {
        "1. After Desert Treasure, buy the ancient staff from Eblis near the Bandit Camp for 80,000 coins.",
    },
    ["Brothers Gower"] = {
        "1. After Gower Quest, claim each lamp from Ian, Paul and Andrew at the Life altar.",
        "2. Use the disk of returning in a bank. Lost? Crate of Returning at the Gower farm.",
    },
    ["Chompy Massacre"] = {
        "1. Needs Big Chompy Bird Hunting. Use an ogre bow in the Feldip Hills swamps.",
        "2. Inflate swamp toads with bellows as bait for each Chompy bird.",
        "3. Count on from the achievement's reported progress.",
    },
    ["Guthix and the Chamber of Secrets"] = {
        "1. Read the five core memories in the Hall of Memories: Aagi, Seren, Juna, Sword of Edicts, Cres.",
        "2. Fill the plinths with core memory fragments, or Archive a returned bot with the Archivist.",
        "3. Needs 70 Divination to enter from the Memorial to Guthix.",
    },
    ["Data Recovery"] = {
        "1. Fill and return all five named memory bots to The Archivist in the Hall of Memories.",
        "2. Aagi lustrous (70), Seren brilliant (80), Juna radiant (85), Edicts luminous (90), Cres incandescent (95).",
        "3. Core memory playback doesn't fill these bots.",
    },
    ["The Crocodile Hunter"] = {
        "1. Dundee is at Het's Oasis; the upgrades need 3,000 total catches.",
        "2. Catch whirligigs with a crocodile. Unlock each upgrade by hand; catches aren't spent.",
    },
    ["The Golden Crocodile Hunter"] = {
        "1. Unlock every upgrade in Dundee's shop, including the golden crocodile: 5,000 total catches.",
        "2. Reaching a threshold doesn't unlock it; buy each one in the shop.",
    },
    ["God of the Grind"] = {
        "1. It is in Het's Oasis: four repairs, 50 pieces of Het each.",
        "2. Get pieces by skilling around the oasis. Continue from repairs already done.",
    },

    ["Maria, You Gotta See Her"] = {
        "1. After Broken Home, replay it via Maria: no deaths, at most one healing item, under 37 minutes.",
        "2. Enter with no follower, equipment or items. All three can be done in one replay.",
    },
    ["White Knight Rises"] = {
        "1. After Wanted!, reach Master rank: 1,300 credited black knight kills.",
        "2. Kill black knights in south Taverley Dungeon; killing white knights removes credit.",
    },
    ["Under Croc and Key"] = {
        "1. After Crocodile Tears, with 80 Constitution, enter the Crondis tomb.",
        "2. Portmaster Kags takes you to the pyramid; swim the tunnel east of the entrance.",
    },

    ["Work For Idol Hands"] = {
        "1. Collect the six demon statuettes in the Lumbridge Catacombs and sell them to Xenia.",
        "2. The diamond one needs you to defeat Dragith Nurn. After Heart of Stone, give them to Ilona.",
        "3. Needs The Blood Pact. Sold statuettes can't be collected again.",
    },
    ["You Mistag This Brooch"] = {
        "1. After The Lost Tribe, give the brooch to Mistag in the Dorgeshuun Mines.",
        "2. The brooch lies near Kazgar, through the hole east of Lumbridge Castle's cellar.",
    },
    ["Triple Trouble"] = {
        "1. After Tai Bwo Wannai Trio, claim the rewards from Tiadeche, Tinsay and Tamayu.",
        "2. They live in the huts along the village's southern wall. All three are needed.",
    },

    ["Two Rites Don't Make a Wrong"] = {
        "1. In Icthlarin's Little Helper, return the canopic jar and talk to Klenter in Sophanem.",
        "2. Both are needed, in either order. Wear a ghostspeak amulet or cramulet.",
    },
    ["Ultimate Codex"] = {
        "1. After The Dig Site, get it from Terry Balando at the Exam Centre.",
        "2. Needs one of 75 Attack, 75 Ranged, 75 Magic or 91 Constitution.",
    },
    ["Uzer Master"] = {
        "1. After Missing My Mummy, open the shortcut through the Uzer Mastaba's second scarab cavern.",
        "2. Go through two uninviting holes past the scarab tunnel. Bring food.",
    },

    ["Rogue Down"] = {
        "1. After Summer's End, free the Rogue from the Rogues' Castle prison.",
        "2. Use Jennica's ring in the courtyard to close the prison doors in the Spirit Realm first.",
    },
    ["Supply and Demand"] = {
        "1. After Death Plateau, deliver five supply crates from Commander Denulth to the Ambush Commander.",
        "2. Each run needs a higher combat level: 10, 12, 14, 16, then 18.",
    },
    ["Tasty Bobbles"] = {
        "1. After Gower Quest, ask Tim and Crunchy Behind the Scenes to see the world with you.",
        "2. Use the disk of returning in a bank. Lost? Crate of Returning at the Gower farm.",
    },

    ["The Firemaker's Pet"] = {
        "1. After The Firemaker's Curse, with 91 Firemaking, take a fire creature pet in Char's cave.",
        "2. Never finished Char's training? Finish it first, with the Book of Char and pitch can.",
    },
    ["Trials of the Heart"] = {
        "1. Needs 300 quest points; Xenia at Lumbridge graveyard hands it out.",
        "2. After Heart of Stone, Wizard Ilona hands it out instead.",
    },
    ["Squeal for Coins"] = {
        "1. In The Mighty Fall, open Yelps's very own cash bag after you fight Yelps.",
        "2. Killed him or lost it? Search Yelps's chest in Yu'biusk.",
    },

    ["Oyster Mash"] = {
        "1. After Beneath Cursed Tides, feed the giant oyster a sea cucumber and delicious seaweed.",
        "2. Wizard Myrtle dives you there. Fish west of the oyster; the seaweed patch is north of it.",
    },
    ["Ornate Crockery"] = {
        "1. After Tears of Guthix, give Juna an ornate bowl from the magic stone mine.",
        "2. Needs 80 Mining and 80 Crafting without boosts and a lit sapphire lantern.",
        "3. Ask Juna about another bowl first, or you can't mine the rock.",
    },
    ["Impressing Char"] = {
        "1. After The Firemaker's Curse, light the Zaros pattern in Char's training cave.",
        "2. Needs 91 Firemaking, the Book of Char and the pitch can. The Wiki shows the grid.",
    },

    ["Shell-Shocked"] = {
        "1. After Tortle Combat, talk to Edvard in the inner Abyss, beside the Dark mage.",
    },
    ["Stealing Sedridor's Stones"] = {
        "1. After Rune Memories, take all the pure essence from the rune chest by Archmage Sedridor.",
        "2. Needs 99 Runecrafting. Earlier withdrawals count toward the 24,750.",
    },
    ["Respect the Balance"] = {
        "1. After The World Wakes: four torches are around the monument, one below it.",
        "2. Torches need 74 Firemaking; paying respects needs 90 Prayer.",
    },

    ["Scribbling in the Depths"] = {
        "1. After Song from the Depths, read both ancient writings in the cave south of Rimmington mine.",
        "2. Needs 80 Constitution to swim the second acid pool.",
    },
    ["Red Sky All the Time, Shepherds Confused"] = {
        "1. After River of Blood, claim the bloodstone from Vanescula Drakan on Castle Drakan's roof.",
        "2. Shake it to turn the sky red; just claiming it isn't enough.",
    },
    ["To Thaw a Frozen Heart"] = {
        "1. After Violet is Blue, thaw the four snow implings in Yeti town.",
        "2. They need 20, 40, 60 and 80 in all non-elite skills, without boosts.",
        prepare = {
            "After Violet is Blue, thaw implings early: crate at all skills 20, well 40, barrel 60, no boosts.",
            "The cart's impling needs all non-elite skills at 80.",
        },
    },

    ["One Man's Junk...Is Mine"] = {
        "1. Empty all four piles in Movario's storage room: fire runes, death runes, coal, magic logs.",
        "2. Needs While Guthix Sleeps access. Bring an ore box and a wood box; notepaper doesn't work.",
        "3. The trapped treasure pile in the study doesn't count.",
    },
    ["I Presume These Rewards Are Mine, Death?"] = {
        "1. After Missing, Presumed Death, claim every reward from Death's statue in the Empyrean Citadel.",
        "2. Some need 75 or 80 in a skill. Leave backpack space; the lamps can't be banked.",
    },
    ["Reliquary of Cithara"] = {
        "1. After One Piercing Note, take the Holy Cithara from the abbey's basement reliquary.",
        "2. Wear six Saradomin items plus your ring and amulet; empty backpack. The Wiki lists them.",
        "3. Then use its Play option.",
    },

    ["After the Close"] = {
        "1. After Once Upon a Time in Gielinor, unlock Closure's robes from his clue trail.",
        "2. Find the clue in Closure's drawers, take it to Relomia in Draynor and dig beside her.",
    },
    ["Animalingual"] = {
        "1. Store every speaking amulet in your cramulet. Inspect it to see which are missing.",
        "2. Needed: camulet, catspeak, crocspeak, cabbagespeak and the crabulet (Hermit Permits).",
    },
    ["Is He Chipped?"] = {
        "1. During or after Ritual of the Mahjarrat, return Bob's collar to Bob the Cat.",
        "2. Wear catspeak; the enchanted amulet's whisker controls point to him.",
    },

    ["Icthlarin's Little Chest"] = {
        "1. Loot the 50-coin chest in Klenter's Pyramid, Sophanem, with a cat or Kitten.",
        "2. Needs Icthlarin's Little Helper and an object-pet cat; a cosmetic pet doesn't work.",
    },
    ["Here Was a Scabaras Mask"] = {
        "1. After Diamond in the Rough, with 80 Mining, enter the Scabaras tomb.",
        "2. Mine the crack in the sundial room past the Kalphite Nursery, then climb into the fissure.",
    },
    ["Are You Needing Access?"] = {
        "1. After Do No Evil, with 80 Agility, enter the Apmeken tomb.",
        "2. The opening is in the cliff just south of the monkey colony east of the Bandit Camp.",
    },

    ["I Dig This Transportation"] = {
        "1. After The Dig Site, clean finds in Varrock Museum until you get a clean necklace.",
        "2. Wear boots and gloves, carry trowel, rock pick and brush. Give the necklace to an archaeologist.",
    },
    ["Gunning for Jewellery"] = {
        "1. After Gunnar's Ground, engrave three pieces of jewellery for Dororan.",
        "2. Ruby bracelet at 42 Crafting, dragonstone necklace at 72, onyx amulet at 90; boosts work.",
        prepare = {
            "After Gunnar's Ground, Dororan (south of the Grand Exchange) has tasks at 42 and 72 Crafting.",
            "The onyx amulet task needs 90 Crafting; boosts work.",
        },
    },
    ["Hello, I Like Money"] = {
        "1. After Hermit Permits, claim 1,000 coins from Grocer Hannah in Wendlewick.",
        "2. If you recently stole from nearby stalls, come back later.",
    },

    ["Free Beer Here"] = {
        "1. After The Feud, find Faisal the Barman in Pollnivneach.",
    },

    ["Culinary Exchange"] = {
        "1. Give Longramble real tangled toads' legs, east of the Poison Waste Slayer Dungeon.",
        "2. Needs The Path of Glouphrie. The item called premade ttl doesn't work.",
        "3. To cook it: 40 Cooking and Aluft Gianne senior's tutorial.",
    },

    ["Now That's What I Call a Dead Parrot"] = {
        "1. After Rocking Out, with 71 Summoning, make the ex-ex-parrot pet in Mos Le'Harmless.",
        "2. Cage from Bill Teach, ex-parrot from 50 Ships Mufassah; use the cage on the slab.",
    },

    ["Fly You Fool"] = {
        "1. Free Velrak from his cell in Taverley Dungeon and talk him into escaping.",
        "2. The jailer drops the key. Opening the cell alone doesn't count.",
    },

    ["Are You The Keymaster?"] = {
        "1. Add all eleven keys to the tool belt's Key Ring. Check its interface for missing ones.",
        "2. Needs One Small Favour. The Wiki says where each key comes from.",
        "3. One-use keys such as crystal keys don't count.",
    },

    ["Haul Comes to Templeton"] = {
        "1. After Dealing with Scabaras, ask Simon Templeton about the little job.",
        "2. Then talk to the Guardian mummy at Pyramid Plunder about artefacts.",
    },

    ["Met Het Yet?"] = {
        "1. After Our Man in the North, with 80 Strength, enter the Het tomb.",
        "2. Pry open the hidden door behind the statue in Het's Oasis. Boosts work.",
    },

    ["Master Bogreman"] = {
        "1. Kill 30 Chompy bird targets in Feldip Hills, then claim the ogre bowman hat from Rantz.",
        "2. Needs Big Chompy Bird Hunting, ogre bellows and an ogre bow.",
    },

    ["Chivalry is Threads"] = {
        "1. Search a tomb coffin for Templar.",
        "2. Use the Skull of Remembrance on Dawn's body and defeat her.",
    },

    ["Deep and Bloody Experience"] = {
        "1. After Blood Runs Deep, claim all three 150,000 XP rewards from Brundt the Chieftain.",
        "2. Each goes to a skill at level 75 or higher.",
    },

    ["Experience the Fate of the Gods"] = {
        "1. Azzanadra is in Senntisten and Wahisietel in Nardah.",
        "2. Needs Fate of the Gods, The Temple at Senntisten and Ritual of the Mahjarrat.",
        "3. Azzanadra's lamp: three uses on combat skills at 80+; not Prayer or Summoning.",
    },

    ["Epi Logueque Experience"] = {
        "1. After While Guthix Sleeps, watch the epilogue and claim all four 100,000 XP rewards.",
        "2. Talk to Idria, or later Silif in the White Knights' Castle when he is in Surok's room.",
    },

    ["Chivalry is Dead"] = {
        "1. After The Death of Chivalry, claim every Tomb of the Fallen reward.",
        "2. Loot the supply crate, use both coffin lamps and kick the gilded cabbage 30 times.",
        "3. The Prayer lamp needs 80 Strength and 65 Prayer without boosts.",
    },

    ["Chivalry is Fed"] = {
        "1. After The Death of Chivalry, plant 12 cabbage seeds at Edgeville Monastery's scorch marks.",
        "2. Needs 7 Farming.",
    },

    ["Diamonds in the Dung"] = {
        "1. After Diamond in the Rough, slice dung kalphites in the Kalphite Nursery for Uraeus and Aten.",
        "2. Bring a slash weapon; the nursery is via the well north-west of the Kalphite Hive (ring BIQ).",
        "3. Banked these before June 2017? Wear both to unlock instead of searching again.",
    },

    ["Do No Elite"] = {
        "1. After Do No Evil, wear Ava's alerter, carry a spade and search the four possible clue sites.",
        "2. Remove metal chest armour; the tool-belt spade doesn't work. Only one site holds your clue.",
        "3. Dig where it bwuks four times and claim the elite clue from the crate.",
    },

    ["Sliske's New Game Plus"] = {
        "1. After Sliske's Endgame, ask Relomia in Draynor Village to replay it and finish the replay.",
        "2. Choose 'No - Keep the reward' when offered a skip; you need the Agent of the Eldest outfit.",
        "3. Complete every combat encounter; skipping away the reward doesn't count.",
    },

    ["Miniature Monolith Maestro"] = {
        "1. After Desperate Measures, make the cosmic accumulator from your cosmic focus (90 Archaeology).",
        "2. Restore the ceremonial dragonkin device and tablet, then give both to Giles's collection.",
        "3. Combine the cosmic pyramid reward with the cosmic focus. Lost the focus? Giles has it.",
    },

    ["Milky Teeth"] = {
        "1. After A Fairy Tale III, give the Tooth Fairy five teeth in Zanaris's throne room.",
        "2. Teeth: kebbit, suqah, an old tooth (Varrock Dig Site), monkey dentures, a child's tooth.",
        "3. Give them to claim the pet; selling teeth to her does not count.",
    },

    ["Load of Bakulla"] = {
        "1. After The Fremennik Trials, talk to a Fremennik in the Rellekka longhall.",
        "2. Watch the whole Epic of Bukalla cutscene (about five minutes, can't be skipped).",
    },

    ["Argh, it burns!"] = {
        "1. After Secrets of Amberfell and Priest in Peril, use Wolfbane or a used Sunspear on six Amberfell NPCs.",
        "2. They are Ash, Heywood, Rosemary, Farmer Rowan, Sorrel and the female Villager.",
    },

    ["Out of the Past"] = {
        "1. After Extinction and Sins of the Father, give the Pastkeeper amulet to Sharrigan in the Dream of Iaia.",
        "2. Lost it? Reclaim it from Vicendithas. Her base-camp version can't take it.",
    },

    ["Ape A'hollow"] = {
        "1. With Monkey Madness and 48 Agility, clear the hollow log at the top of the Ape Atoll Agility Course.",
        "2. Then use fairy ring ALP, go north of the cavern and clear the tunnel's rocks with a pickaxe.",
        "3. Both the log and the tunnel must be cleared.",
    },

    ["As Taxed as a Yak"] = {
        "1. During or after The Fremennik Isles, pay Vanligga Gastfrihet's 5,000-coin taxes in Jatizso.",
        "2. Collected her tax in the quest? Repay her, then talk to her again after the quest.",
    },

    ["Distorted Div"] = {
        "1. After Mahjarrat Memories, get the engrammeter from Kharshai in Rellekka and fully charge it.",
        "2. Charge it with 500 vibrant or higher memories, or 250 enriched ones (memories, not energy).",
        "3. Operate it in Freneskae through the World Gate; the Children of Mah site doesn't work.",
    },

    ["Measure of Old"] = {
        "1. After Fate of the Gods, place the Measure at four places and interact with each elder chronicle.",
        "2. Entrana's north-west statue, TzHaar City's entrance, atop Ullek's stairs, the Oracle on Ice Mountain.",
        "3. Lost the Measure? It's in the Elder Halls, west of the energy rift.",
    },

    ["Gift from Sliske"] = {
        "1. After the listed quests, meet Sliske in the Empyrean Citadel throne room via the invitation box.",
        "2. Also have the Guthixian High Druid add the World Gate teleport to your Sixth-Age circuit.",
        "3. Both unlocks are required.",
    },

    ["Caving into the Gains"] = {
        "1. After Myths of the White Lands, claim the three cave rewards in the Land of Snow.",
        "2. Needs 30 Crafting, 55 Agility and 80 Woodcutting; take the reward detours, not the skips.",
        "3. Also claim 5,000 coins from Explorer Jack north of Lumbridge Castle.",
    },

    ["Dishonourable Gains"] = {
        "1. During or after Dishonour among Thieves, loot the three XP chests in Zamorak's hideout.",
        "2. They need levels 50, 70 and 90; they're separate from the Dishonourable Loot chests.",
    },

    ["Dishonourable Loot"] = {
        "1. During or after Dishonour among Thieves, loot the five hideout-route coin-and-gem chests.",
        "2. Zamorak's hideout, Uzer, Daquarius's base, Zemouregal's fort and south of Barrows.",
        "3. The sixth chest in Jerrod's cell is not required.",
    },

    ["Fires are Mostly Harmless"] = {
        "1. After A Fairy Tale III, with 85 Firemaking and 85 Herblore unboosted, light the everlasting fire.",
        "2. Use 8 willow logs on the spent campfire on the island near Mos Le'Harmless (ring DIP).",
        "3. Then search the mushroom patch in Shredflesh's Cave (ring ALP); both are required.",
    },

    ["Last of the Summer Swine"] = {
        "1. After Bringing Home the Bacon, upgrade the pig creation machine at the Falador farm to tier 3.",
        "2. Tier 2 needs 44 and tier 3 needs 84 Construction, Crafting and Summoning.",
        "3. No achievement? Change the machine's pig type and check again.",
    },

    ["Looting the Demon Throne"] = {
        "1. During or after The Golem, use a chisel on the demon throne in Thammaron's throne room.",
        "2. It's beneath Uzer's temple; you also need a hammer (the tool-belt one works).",
    },

    ["Lurgon's Run"] = {
        "1. After Death to the Dorgeshuun, agree to Lurgon's food-trading plan in Dorgesh-Kaan.",
        "2. Then ask the councillor he names for permission; talking only to Lurgon is not enough.",
    },

    ["My Adze is Bigger Than Yours"] = {
        "1. After All Fired Up, light all fourteen beacons at once, then speak to King Roald.",
        "2. Each beacon takes 20 unnoted logs of one type.",
        "3. Equip the inferno adze with a real 92 Firemaking (no boost) and talk to King Roald again.",
    },

    ["To Dream, Perchance to Keep"] = {
        "1. After Extinction and Sins of the Father, unlock all six Dream of Iaia worker stories.",
        "2. Each station needs 75 in its skill (no boosts) and 50,000 of each base-camp resource.",
        "3. Train at each station until its tale is recounted to Sharrigan.",
    },

    ["Advanced Sweeping"] = {
        "1. After Swept Away, get all five broomstick enchantments.",
        "2. They are the Sorceress's apprentice, Maysa, Netty, Baba Yaga and Kardia (33/53/73/93 Magic).",
        "3. Use the broomstick on Kardia in the Underground Pass; talking alone doesn't enchant it.",
    },

    ["Ali the Trader"] = {
        "1. After The Feud, do Ali Morrisane's merchandise errands in Al Kharid.",
        "2. Bring 100 coins, 3 dyes and 3 unnoted cowhides; Sophanem access is needed for the last ones.",
        "3. Return to Ali after each errand until every category is unlocked.",
    },

    ["Around the World in Six Ways"] = {
        "1. After Enlightened Journey, fly the first balloon flight to each of the four new destinations.",
        "2. Firemaking 30, 40, 50 and 60; store logs with a pilot for charges.",
        "3. A crash uses the remaining charges and sends you back to Entrana.",
    },

    ["Banking History"] = {
        "1. After Meeting History, finish both enchanted-key treasure hunts: Making History first.",
        "2. Feel the key and dig where it is steaming; carry a backpack spade.",
        "3. The Meeting History hunt has a fixed order; use the Wiki maps.",
    },

    ["Am I a good boy yet?"] = {
        "1. After Princess and the Pauper, feed the stray dog by Fort Forinthry's chapel five bones, meat or fish.",
        "2. Then search its kennel for the gift; feeding alone is not enough.",
    },

    ["Clue's in the Monkey Drool"] = {
        "1. During or after Monkey Madness, take an Ardougne Zoo monkey and feed it bananas by hand.",
        "2. Needs a regular monkey greegree and a monkeyspeak amulet; teleporting loses the monkey.",
        "3. Keep going until it spits out a medium clue; auto-eaten bananas don't count.",
    },

    ["Final Destination Unlocked"] = {
        "1. After The Spirit of War, talk to the ferryman at each ferry point.",
    },

    ["Many Shades of a Cure"] = {
        "1. Use a dose of Serum 208 on Razmire Keelgan and on Ulsquire Shauncy in Mort'ton.",
        "2. Make it on Flamtaer's lit fire altar (20% sanctity, 15 Herblore); Serum 207 doesn't count.",
    },

    ["Mixing in Ancient Circles"] = {
        "1. Plant five bittercap mushrooms at the broken ring BJQ, at the lower level's west end.",
        "2. Bring a spade; use harvested mushrooms, not spores.",
    },

    ["Mysteries of the TokHaar"] = {
        "1. After speaking to Hannibus in One of a Kind, read the Animate Rock scroll at four statues and rotate each.",
        "2. Statues: east of Seers' bank, south of the Fishing Guild, north of Tower of Life, west of Brimhaven.",
        "3. Lost the scroll? Remake it in Robert the Strong's library, Burthorpe.",
    },

    ["Trickster's Trinkets"] = {
        "1. After You Are It, dig up the five trinkets with the old necklace.",
        "2. Then combine all five with the necklace; finding them is not enough.",
    },

    ["Paint It Red"] = {
        "1. After River of Blood, speak to Vanescula Drakan on Castle Drakan's roof in Darkmeyer.",
        "2. Read Haemalchemy (Vol. 2) from her, then claim your free blood essence.",
    },

    ["Annihilator"] = {
        "1. After Fate of the Gods, replay the nihil fight in the Pit on Freneskae.",
        "2. Engage all four nihil before killing any, then defeat all four. Slayer nihil don't count.",
    },

    ["Gross Misconduct"] = {
        "1. Kill 144 demons in the Wilderness, counting from your current total.",
        "2. The Chaos Elemental does not count.",
    },

    ["Another One Scabarites The Dust"] = {
        "1. After Beneath Scabaras' Sands, kill 200 elite profane scabarites in the Temple of Isolation.",
        "2. The primed keris must be equipped for each killing blow; ordinary profane scabarites don't count.",
    },

    ["Bloodstained Treasure"] = {
        "1. After Legacy of Seergaze, search the broken rune case and the corpse in the Meiyerditch laboratory.",
        "2. Both locations are required.",
    },

    ["Deadlier Catch"] = {
        "1. After Deadliest Catch, talk to Jones outside the Fishing Guild bank and hunt Thalassus again.",
        "2. Ten more hunts are needed; continue from your current progress.",
    },

    ["Mask of Dragith Nurn"] = {
        "1. After The Blood Pact, collect the five mask parts from Lumbridge Catacombs monsters.",
        "2. Part 5 is from Dragith Nurn, summoned by the diamond statuette in the final room.",
        "3. Combine all five parts; collecting them alone is not enough.",
    },

    ["I Want a New Duck"] = {
        "1. After the Duck Quest, fish the three pea spots in Paddlington's pond (ten peas each).",
        "2. Fish them in order: under the first waterfall, just west, then north-east. The last unlocks Waddles.",
    },

    ["Keeping Up with the Carnilleans"] = {
        "1. After Carnillean Rising, talk to Ceril Carnillean, then follow Philipe to his eight places.",
        "2. Each stop needs more quest points and combat (50 QP/30 combat up to 400 QP/120 combat).",
        "3. Claim and use all eight lamps; the ninth lamp in the City of Um is not required.",
    },

    ["Myreque in Memoriam"] = {
        "1. Complete In Memory of the Myreque and River of Blood.",
        "2. Then tell Veliaf Hurtz at the Myreque memorial sundial north of Canifis about Safalaan.",
    },

    ["Got a Vyre Reputation"] = {
        "1. During or after The Branches of Darkmeyer, raise Darkmeyer status to the maximum.",
        "2. Do the citizen and sentinel tasks in each tier; the quest's access level alone isn't enough.",
        "3. Keep going until you get the Vyrelord or Vyrelady title.",
    },

    ["Lamp of Luxury"] = {
        "1. Pick a skill for each listed lamp; just holding a lamp does not count.",
    },

    ["Koschei's Cache"] = {
        "1. After Koschei's Troubles, take Balmung to Kharshai in Rellekka and unlock all three jewel memories.",
        "2. Blue: cut. Red: crush (90 Strength). Green: check for curses (90 Prayer).",
        "3. Speak to Kharshai with each colour; changing Balmung's look alone is not enough.",
    },

    ["Bandos's Memories"] = {
        "1. After The Mighty Fall, capture thirteen more chronicles in Bandos' Arena on Yu'biusk.",
        "2. Enter by the green portal east of Goblin Village; walk close to each spot to make it appear.",
    },

    ["Seren Memories"] = {
        "1. After Fate of the Gods, tag the active pillar 80 times on Freneskae to unlock four Seren crystals.",
        "2. Collect them before leaving, deposit them in the Sanctum's memoriam device.",
        "3. Then claim the Crest of Seren from the western alcove's storage.",
    },

    ["Zarosian Memories"] = {
        "1. After Fate of the Gods, collect the twelve Zarosian crystals on Freneskae.",
        "2. Use the Wiki crystal map for each one; z12 is in the Elder Halls.",
        "3. Deposit them in the Sanctum's memoriam device, then take the Helm of Zaros from the east alcove.",
    },

    ["A Sliver of Silver Helps the Sanguine Go Down"] = {
        "1. After Hearts of Sanguine, talk to Liat in her Wendlewick smithy about havensilver.",
        "2. Read Metals: A musing upstairs for a key, then open the chest behind the waterfall north of Ivar.",
        "3. Return the schematic to Liat.",
    },

    ["Challenge Maria"] = {
        "1. After Broken Home, speak to Maria and finish all three replay challenges.",
        "2. No deaths, then at most one healing item, then under 37 minutes. Also open all nine temporal chests.",
        "3. Tier 1-2 chests are on the ground floor; tier 9 is in Ingram's bathroom one floor above ground.",
    },

    ["Draugr Me to Hela"] = {
        "1. After Remains of the Necrolord, free all fourteen listless dead around above-ground Daemonheim.",
        "2. They have no minimap dots; use the Wiki map. Free them, don't just talk to them.",
    },

    ["EEEEAGLE!"] = {
        "1. After Eagles' Peak and Back to my Roots, unlock the desert and Feldip eyries from outside.",
        "2. Desert: push the boulder east of the Dominion Tower (45 Strength).",
        "3. Feldip: use a teasing stick, garden cane or thatch spar on the vine; it takes about 40 minutes.",
    },

    ["I Can See For Miles and Miles"] = {
        "1. After All Fired Up, give a macaw pouch to each of the twelve beacon keepers.",
        "2. Some want an extra item first, e.g. white tree fruit for Ube or a lava eel for Crate.",
        "3. No beacon-lighting run is needed.",
    },

    ["I Know. I Was There..."] = {
        "1. After Ritual of the Mahjarrat, get Bruce's bad break from Bruce in Edgeville.",
        "2. Then inspect the Edgeville furnace for Froggi, the smithy's apprentice. Both books are needed.",
    },

    ["Ice Ice Chimpy"] = {
        "1. After Do No Evil, buy chimp ice from the chimp ice chimp and deliver it to Awowogei on Ape Atoll.",
        "2. Keep it frozen with Ice Burst, Blitz or Barrage (not Ice Rush); teleports melt it.",
        "3. Do 25 post-quest deliveries; the quest's delivery does not count.",
    },

    ["It's Like God Book Illuminations in Here"] = {
        "1. After One Piercing Note, illuminate all six god books at the Abbey of St. Elspeth Citharede.",
        "2. Needs 60 Crafting and 60 Prayer; Jossik at the Lighthouse has missing books.",
        "3. Order: Copy text, Embellish initial capitals, Add colour, Add gold leaf.",
    },

    ["Ivan is Flailing"] = {
        "1. During or after Legacy of Seergaze, cremate 500 vyre corpses in the Columbarium beneath Paterdomus.",
        "2. Kill vyres with the Ivandis flail or blisterwood; Sunspear kills don't give corpses.",
        "3. Use teak pyre logs or better, not ordinary logs.",
    },

    ["Diaries of the Clans"] = {
        "1. After Plague's End, run the Hefin Agility Course (77 Agility) until all eight clan pages are found.",
        "2. A page comes every twenty laps.",
    },

    ["Long Live the Queen"] = {
        "1. Needs 60 Summoning. Take the journal from her reward coffer.",
        "2. It is guaranteed on your first kill; only that one is needed.",
    },

    ["A bug in the system"] = {
        "1. Search the papers on the table in the cavern, north-west of Pollnivneach.",
    },

    ["After the Flood"] = {
        "1. After Ode of the Devourer, defeat The Gate of Elidinis until Elidinis' memoir drops.",
        "2. Read the book; owning it unread does not count.",
    },

    ["Aged Journal"] = {
        "1. With 103 Archaeology and 95 Dungeoneering, complete On the Threshold of the Mind research.",
        "2. Pass the imposing door with a restored friendship bracelet (tool belt works).",
        "3. Take the journal one floor above ground on the north-east ledge and read it.",
    },

    ["An Exploration of Havenhythe"] = {
        "1. Take each book directly, not through area loot.",
        "2. Volume III is in an Amberfell house during Secrets of Amberfell.",
    },

    ["Azdaran Birthright"] = {
        "1. After Birthright of the Dwarves, mine the ten statues in the Ancient Keldagrim ruins.",
        "2. They need 81 to 95 Mining; boosts work, Summoning familiar boosts do not.",
    },

    ["Behemoth Notes"] = {
        "1. In Daemonheim, get the five Behemoth note parts from their bosses and pick each one up.",
        "2. Part 5 is from the hope devourer on floors 51-60 (101 Dungeoneering).",
    },

    ["Bugs in the Walls"] = {
        "1. After Beneath Scabaras' Sands, kill elite Profane Scabarites until Priest's Notes drops.",
        "2. Read the notes before destroying them.",
    },

    ["Centaur of Attention"] = {
        "1. With 42 Archaeology and 102 Mining, give Roberta 100 porcelain clay at the Everlight mine.",
        "2. Hand in all 100 at once, then read On the Origin of Centaurs.",
    },

    ["Collection of Zamorakian Notes"] = {
        "1. Collect the five Zamorakian notes from black knights, Dagon'hai monks and greater demons.",
        "2. Also from monks of Zamorak and Zamorakian mages.",
    },

    ["Daemonology of Celerity"] = {
        "1. Ask Brother Celerity at the Edgeville Monastery for the Malleus daemoniorum.",
        "2. Main accounts may first need to join a Demon Flash Mob; Ironmen don't.",
    },

    ["Death to the Mahjarrat"] = {
        "1. During or after Children of Mah, inspect all four deathstones on the route to Mah's ritual marker.",
        "2. Inspect each one; walking past does not count.",
    },

    ["Diary of Oreb"] = {
        "1. With 88 Slayer, kill Sophanem Slayer Dungeon monsters for The Magister's Journal.",
        "2. Read each journal at once; the five drop in order. The Jack of Spades is not required.",
    },

    ["Diary of the Gods"] = {
        "1. Kill Zilyana, Graardor, Kree'arra, K'ril and Nex.",
        "2. After each kill check the ground; the books don't appear in area loot.",
    },

    ["Divine Ichor"] = {
        "1. During Heralds of Crimson, collect and transcribe the seven Divine Ichor tablets around Havenhythe.",
        "2. Tablet V needs a bogolin telepearl for Runnynose.",
        "3. Read the completed Divine Ichor book.",
    },

    ["Do a Minion, Take Notes"] = {
        "1. Fight Dominion Tower bosses (20 quests needed) for all twenty journal pages.",
        "2. Add pages to the Dominion journal; destroying it loses the pages it holds.",
    },

    ["Don't Fear the Ripper"] = {
        "1. With 96 Slayer, kill Ripper Demons in the Dark Tunnel east of Al Kharid for six books.",
        "2. Read each book before the next can drop.",
    },

    ["Dragon Ink"] = {
        "1. In the Dragonkin Laboratory, get Diary of an Overzealous Gnome from Astellarn.",
        "2. Get Redacted Dragonkin Research from Verak Lith; story mode also works.",
    },

    ["Dragonkin Logs"] = {
        "1. After Hero's Welcome, kill adamant dragons for Sakirth's, Strisath's and Kalibath's journals.",
        "2. Also Phalaks' experiment log. Read all four.",
    },

    ["Dusting Murial"] = {
        "1. With 80 Firemaking and 70 Defence, take the Dragonkin Primer from beneath Unferth's house, Burthorpe.",
        "2. Cleanse and translate the murals in the adamant dragon dungeon and on Kethsi.",
        "3. Wear a fully charged dragonfire shield for each; cleansing alone doesn't finish it.",
    },

    ["Enough of the Crazy Walking"] = {
        "1. Earn 50 Honour Points at Barbarian Assault.",
        "2. Buy The Account of Aesa Fellsdottir parts 1 and 2 from Commander Connad.",
    },

    ["Explore for Nestor"] = {
        "1. In Keldagrim Library, go upstairs one floor above ground.",
        "2. Search the only bookcase without a ladder for the explorer's notes and read them.",
    },

    ["Forcae's Mettle"] = {
        "1. Kill adamant or rune dragons for Forcae's journal pages.",
        "2. Pick up every page until all ten fill the journal.",
    },

    ["Goebie Relics"] = {
        "1. On Mazcab, collect the five stone fragments around the graveyard, Nemi Forest, Otot and Kanatah.",
        "2. Use all five on the ancient statue in the south of the graveyard.",
    },

    ["Grave Records"] = {
        "1. After Soul Searching, collect and inspect eleven crumpled pages in the Sanctum of Rebirth.",
        "2. Bring Telekinetic Grab (33 Magic); several pages need it.",
        "3. Get each area's pages before moving on; going back needs a dungeon reset.",
    },

    ["Grondaban's Legacy"] = {
        "1. After Dishonour among Thieves, enter the stalker dungeon in Zamorak's hideout.",
        "2. Pick up Grondaban's stalker notes beside the portal at its north end.",
    },

    ["Heavy Metal"] = {
        "1. After What's Mine is Yours, mine each metal type for the eight entries of Boric's Book of Metal.",
        "2. Primal needs 100 Mining, outside Daemonheim's floors.",
        "3. Then read the finished book through Boric beneath Doric's hut.",
    },

    ["Herbi's Flax"] = {
        "1. After Shades of Mort'ton, take Herbi Flax's diary from the ruined house in south-west Mort'ton.",
        "2. Hand it to the Varrock apothecary; reading it alone does not count.",
    },

    ["History of Bilrach"] = {
        "1. Collect all thirty mysterious chronicles from Daemonheim bosses.",
        "2. Part N drops on floor 2N-1 or 2N; pick it up by the exit ladder.",
    },

    ["Kaiki's Tusks"] = {
        "1. With 92 Slayer, kill airut on the Piscatoris Peninsula.",
        "2. Pages don't show in loot; check the ground. Rush of Blood airut don't drop them.",
    },

    ["Kal'gerion Notes"] = {
        "1. Collect the five Kal'gerion note parts from their Daemonheim bosses.",
        "2. Pick each up by the exit ladder; part 5 needs 113 Dungeoneering.",
    },

    ["Let Us Give Ugthanks"] = {
        "1. With 96 Slayer, kill camel warriors east of Sophanem until The Ugthanatos drops.",
        "2. Read the book.",
    },

    ["Library of Nex"] = {
        "1. Survive a Nex, Angel of Death kill in the Ancient Prison.",
        "2. Search the exit teleport crystal for The Promised Gift and The Praesul, then read both.",
    },

    ["Lovingly Crafted"] = {
        "1. Needs Cabin Fever and the Fur 'n Seek wish list.",
        "2. Festering needs 78 Slayer; the rotten one comes from the Odd Old Man's riddle.",
        "3. The blasphemous journal must be last.",
    },

    ["Madness and Malediction"] = {
        "1. In the Zamorakian Undercity, get the Berserk Archaeologist below half health and wait.",
        "2. He throws Archaeology Journal - H.F.A.; killing him too fast prevents it.",
        "3. Pick up and read the journal.",
    },

    ["Marmaros and Thok Letters"] = {
        "1. Collect the ten M. and Thok letters from monsters on their Daemonheim floors.",
        "2. Part 10 is on floors 54-60 (107 Dungeoneering).",
    },

    ["Meeting your Idols"] = {
        "1. Investigate a cleared overgrown idol on Karamja (not Anachronia) for The End of Gara-Dul.",
        "2. Clearing the vines needs 81 Woodcutting, or wait for another player to clear it.",
    },

    ["Memoirs of the Devourer"] = {
        "1. After Eclipse of the Heart, defeat the full boss (not the quest version).",
        "2. The book is guaranteed on the first full kill.",
    },

    ["Message from the Abyss"] = {
        "1. With 115 Slayer, kill abyssal lords in the Senntisten Asylum until Scions of Erebus drops.",
        "2. Read it; an unread copy is not enough.",
    },

    ["Miscellaneous Notes"] = {
        "1. Collect miscellaneous Dungeoneering journals 1-15 from their Daemonheim bosses.",
        "2. Pick them up by the exit ladder; parts 13-15 need 95 Dungeoneering.",
    },

    ["Ocellus Virius Notus"] = {
        "1. With 81 Slayer, collect 22 order journal pages in the Monastery of Ascension.",
        "2. Four are on bookshelves and a lectern; the rest drop from monsters (check the ground).",
    },

    ["Of Kraken Ink"] = {
        "1. In the Shadow Reef, defeat the Crassian Leviathan for The Last Offering.",
        "2. Defeat Taraket the Necromancer for Kranon's Ancient Journal.",
    },

    ["One Final Ride"] = {
        "1. Kill the King Black Dragon until Last Riders drops, then read it.",
        "2. The ordinary boss counts, not the Wilderness Flash Event.",
    },

    ["Otto the Ancient"] = {
        "1. Rummage the three skeleton remains in the Ancient Cavern for 26 different ancient pages.",
        "2. Copy each new page at once; hop worlds after all three remains.",
        "3. Cavern access: start Otto's Barbarian Firemaking (35 Firemaking).",
    },

    ["Quiet But Deadly Lore"] = {
        "1. Needs 60 Summoning. Take each journal from the reward coffer and read all four.",
    },

    ["Roake Kal"] = {
        "1. After Pieces of Hate, decipher the four murals in Ulthven Kreath, south-west of Mos Le'Harmless.",
        "2. Needs 85 Agility, Construction, Firemaking and Thieving; start with the southernmost mural.",
    },

    ["Scabigail"] = {
        "1. Needs Dealing with Scabaras (during or after); Lead archaeologist Abigail gives the book.",
        "2. Kill scabaras lancers, rangers and mages for notes; copy each at once.",
        "3. Hand all 19 to Abigail; if refused, ask the High Priest of Scabaras.",
    },

    ["Scribblings of a Dragonkin"] = {
        "1. After Plague's End, with 115 Dungeoneering, enter the Edimmu resource dungeon in Prifddinas.",
        "2. Search the dragonkin altar for Vicendithas' Scribblings.",
    },

    ["Selene's Lessons"] = {
        "1. Talk to Raz under the Highweald Forest waterfall for Selene's Lessons.",
        "2. Find and copy all nine pages around Havenhythe, then give the book back to Raz.",
    },

    ["Sentient Letters"] = {
        "1. Train in the Empty Throne Room east of the Varrock Dig Site for Senntisten scrolls.",
        "2. Take each to Celia Diggory to translate and copy; there are five letters, in order.",
    },

    ["Soft Dragon, Warm Dragon"] = {
        "1. After Requiem for a Dragon, carry The Shadow Realm and Zorgoth's Journal to the Reflection Pool.",
        "2. Approach Vorkath and read him both stories.",
    },

    ["Some Old Dusty Journals"] = {
        "1. After The Light Within, collect and read the three Tarddian journals in Tarddiad.",
        "2. Search the house boulder, the crystal formation and the northernmost bushes.",
    },

    ["Stalker Notes"] = {
        "1. Collect the five Stalker note parts from their Daemonheim bosses.",
        "2. Pick each up by the exit ladder.",
    },

    ["Tactless Analysis"] = {
        "1. Inspect each note as you find it.",
        "2. Bring Telekinetic Grab (33 Magic) for the page near the lava strykewyrms.",
    },

    ["Take it to Sir Tiffy in a Jiffy"] = {
        "1. Get the knight's notes from the dying knight outside the God Wars Dungeon.",
        "2. Deliver them to Sir Tiffy Cashien in Falador Park.",
    },

    ["The Book of Elei"] = {
        "1. After Impressing the Locals, inspect each page as you find it.",
        "2. Bring Telekinetic Grab (33 Magic) for two of them.",
    },

    ["The History of Slayer"] = {
        "1. After The Jack of Spades, with 99 Slayer, capture 110 different souls for Faiza's Slayer Codex.",
        "2. Read each of the six murals and finish Faiza's dialogue as they unlock.",
    },

    ["The Journal of Fell Arnessen"] = {
        "1. Kill the Arch-Glacor in normal mode; hard mode is not the route for this book.",
    },

    ["The Many Hands That Write"] = {
        "1. After Impressing the Locals, defeat the Sanctum Guardian for Crassian Allegiance.",
        "2. Defeat Masuta the Ascended for Himiko's Vision.",
    },

    ["The Tale of Hawthorn"] = {
        "1. In Amberfell, search the ground-floor bookcase in the house by the canoe station for the book.",
        "2. Another copy is one floor above ground in the house on the bank's north side.",
        "3. Read the book; finding it unread is not enough.",
    },

    ["The Worst Witch's Grimoire"] = {
        "1. Collect all twenty-two burnt pages in the Zamorakian Undercity (Wiki location map).",
        "2. Bring 33 Magic, the standard spellbook and runes for five Telekinetic Grab casts.",
        "3. Inspect every page; holding loose pages does not finish it.",
    },

    ["Tome Raider"] = {
        "1. After Soul Searching, defeat the three Sanctum of Rebirth bosses for their books.",
        "2. Vermyx and Kezalam drop two books; Nakatra drops Death and Devourers.",
        "3. Repeat bosses whose book is still missing.",
    },

    ["Umbral Diplomacy"] = {
        "1. Collect all twenty-two waterlogged scraps in the Shadow Reef elite dungeon (Wiki map).",
        "2. Bring 33 Magic and runes for two Telekinetic Grab casts on the third level.",
        "3. Inspect each scrap to add it to the journal.",
    },

    ["On a Rune High"] = {
        "1. After The Feud, talk to Ali Morrisane in Al Kharid, then Aubury in Varrock, then Ali again.",
        "2. Open a large rune casket by solving its RuneSudoku (Examine Lock).",
        "3. A small casket does not count; you must open a large one.",
    },

    ["What's Mine is Also Doric's"] = {
        "1. After What's Mine is Yours: eight for Doric and three for Boric, north of Falador.",
        "2. Accept each job before making its items; pre-made goods generally do not count.",
        "3. Full completion needs unboosted 70 Smithing and 60 Mining.",
    },

    ["A Cultist's Journey"] = {
        "1. Talk to the Curator north of Burthorpe lodestone and agree to find Johanhus Ulsbrecht.",
        "2. Find him at the Exam Centre, Feldip Hills, Senntisten cathedral and the Nodon Front, in order.",
        "3. Report to the Curator and talk again after each find, or he will not move on.",
    },

    ["Challenging Chat"] = {
        "1. In the Borehole north of Falador, cross the floating-rock gaps to Vorago's lobby.",
        "2. Talk to Vorago: What are you doing here?, then Can I face you?",
        "3. Finish that dialogue; you do not have to fight him.",
    },

    ["Mage Arena"] = {
        "1. With an actual 60 Magic, defeat Kolodion at the Mage Arena in the deep Wilderness, using magic only.",
        "2. Then enter the sparkling pool and pray at a god statue for its cape.",
        "3. Speak to the chamber guardian for the god staff; the kill alone does not finish it.",
    },

    ["Milk of Chocolate, Snape of Grass"] = {
        "1. Needs 20 Cooking. Skippy is south-east of Rimmington.",
        "2. Bring a bucket of water, nettle tea and a hangover cure (milk, chocolate dust, snape grass).",
        "3. Use Sober-Up with the water, then give him the tea, then the cure.",
    },

    ["On a Mission from...the Gods"] = {
        "1. Join a god emissary (e.g. Julienne in Falador Park) and finish all three task tracks.",
        "2. Some items must be made after accepting the task; follow the God Emissaries Tasks Wiki checklist.",
        "3. Finish by claiming the relic helm from your emissary.",
    },

    ["Skeletal Wishes"] = {
        "1. After Rag and Bone Man and Fur 'n Seek, complete both extra wish lists for the Odd Old Man.",
        "2. Defeat the skeletal horror once, burying its arms and tail during the fight.",
        "3. Then ask the Odd Old Man to rebuild it; that is required.",
    },

    ["Kudos to You"] = {
        "1. Earn all 198 Kudos at Varrock Museum; ask the Information clerk which you still lack.",
        "2. Clean finds (after The Dig Site), do Orlando Smith's or Mark Brodie's quiz, tell Historian Minas quests.",
        "3. Also finish the Dahmaroc statue once and report Dragonkin lore to Mr Mordaut.",
    },

    ["Penny For Your Life"] = {
        "1. After Dimension of Disaster, buy every permanent entry in Aris' Reward Shop with silver pennies.",
        "2. Replay the quest for pennies; the full shop costs thirty, including the Zemouregal shortcut.",
        "3. The repeatable weekly XP lamp is not required.",
    },

    ["Pulling on the Threads"] = {
        "1. After The Needle Skips, reveal every missing memory fragment in all chapters.",
        "2. One matching keyword per fragment is enough.",
        "3. Leave the replay area and claim the large XP lamp from Megan.",
    },

    ["Summary Spirits"] = {
        "1. After Summer's End, wear Jennica's ring and operate it at all eight Wilderness Spirit Realm portals.",
        "2. Each portal has its own level (e.g. 50 Farming, 80 Defence); two portals are invisible (Wiki map).",
        "3. Visiting without operating the worn ring does not count.",
    },

    ["You're Not My Real Mah"] = {
        "1. After Fate of the Gods, capture elder chronicles in the Elder Halls on Freneskae.",
        "2. Offer one hundred to Guthix's monument in the Guthixian ruins.",
        "3. Chronicles put in the energy rift give no progress.",
    },

    ["Master Builder"] = {
        "1. Upgrade every building to tier three through Giles's Base Camp Management.",
        "2. Rare materials come from the Agility Course, hunting and Slayer on Anachronia.",
        "3. Also build the bank chest and activate the lodestone; the remote totem plot is not needed.",
    },

    ["Jurassic Perk"] = {
        "1. Collect all three pieces of Anachronia's seven original totems; Remototem pieces are excluded.",
        "2. Sources: Big Game Hunter, the Agility Course, Slayer, zygomites, Herby Werby and rubble.",
        "3. Helping Laniakea gives the Intimidation middle; use the Jurassic Perk Wiki rubble map.",
    },

    ["Remotely Possible"] = {
        "1. After Desperate Measures, assemble the Remototem from its base, top and middle.",
        "2. Upgrade the town hall and storehouse to tier three; gather 150,000 each of stone, vines and wood.",
        "3. Have Giles unlock the remote totem plot by the lodestone and build it.",
    },

    ["Who Will Be Her Lover?"] = {
        "1. After Plague's End, add pairs of golden rocks to Rhiannon's statue in the Tower of Voices.",
        "2. Each finished statue adds a piece to the replica; finish thirty-two statues.",
        "3. Golden rocks are not Dahmaroc's strange rocks.",
    },

    ["Sort of Crystally"] = {
        "1. Unlock the seventeen Prifddinas titles needed for Dark Lord; use the achievement's unchecked list.",
        "2. These include the eight clan titles, Elven, Dark Elf, Lorehound, the Famous and Lord of the Wait.",
        "3. Many other elven titles are not required.",
    },

    ["Elder Wisdom"] = {
        "1. After Dead and Buried, with 95 Fletching and a tier-three Ranger's Workroom, unlock all four perks.",
        "2. Imbue dinarrows with Bik, Ful, Wen and Jas anima in full sets of fifteen.",
        "3. Smaller sets cannot finish a perk.",
    },

    ["Um Pop"] = {
        "1. They unlock with quests and Necromancy (full: 101 Necromancy).",
        "2. Includes saluting Slayer masters at the owlery, eight ghost rats at 92 and gifts for Dominique and Austin.",
        "3. Use the game list and the Um Pop Wiki table for unfinished interactions.",
    },

    ["Elven Titles"] = {
        "1. After Plague's End, unlock all eight clan-named titles.",
        "2. Each clan has its own task (e.g. one hundred corrupted ore for Trahaearn, Lord Amlodd's scroll).",
        "3. Check progress in Customisations, Titles, with the filter off.",
    },

    ["Family Spirit Tree"] = {
        "1. After Plague's End and The Prisoner of Glouphrie, grow and health-check spirit trees in four patches.",
        "2. Inform Glouron in Prifddinas after the first two, before planting the third and fourth.",
        "3. Then speak to Glouron and claim the Farming XP lamp.",
    },

    ["I'm Forever Washing Shadows"] = {
        "1. After Plague's End, cleanse fifteen each of truthful, blissful and manifest shadow cores in Amlodd.",
        "2. Pick cores up yourself; pet or agility-course cores do not count.",
        "3. Claim the lamp from Lord Amlodd (75 Divination to use it).",
    },

    ["Imping Around"] = {
        "1. After Plague's End, accept Daffyd's checklist in the Amlodd district, then catch its sixteen implings.",
        "2. Bought jars, other players' catches and catches before Prifddinas access do not count.",
        "3. Full access needs 95 Hunter and Rocking Out.",
    },

    ["Make Them Bleed"] = {
        "1. After Plague's End, with 85 Slayer, ask Morvran about Rush of Blood and clear twenty waves.",
        "2. A trial run counts.",
        "3. Then claim Morvran's Slayer XP lamp.",
    },

    ["Potion For a Lady"] = {
        "1. After Plague's End, ask Lady Meilyr about combination potions, then find an unreadable page in Daemonheim.",
        "2. Buy the super melee recipe and, at 81 Herblore, make the potion yourself in a crystal flask.",
        "3. Bring it to Lady Meilyr and claim the lamp.",
    },

    ["Potion Mixer Master I"] = {
        "1. After Plague's End, unlock every recipe on Lady Meilyr's first list in the Meilyr Recipe Shop.",
        "2. Nine recipes need unreadable pages from Daemonheim (75 Dungeoneering).",
        "3. You unlock the recipes; brewing each potion is not needed.",
    },

    ["Potion Mixer Master II"] = {
        "1. After Plague's End, buy the spiritual prayer, elder overload and elder overload salve recipes.",
        "2. Harmony pillar farmer or Lady Meilyr opens the Meilyr Recipe Shop; no pages are needed.",
    },

    ["Rhian in Gold - The Original"] = {
        "1. After Plague's End, finish one golden-rock statue of Rhiannon in the Tower of Voices.",
        "2. Golden rocks come from the Prifddinas-related skills (Wiki list).",
    },

    ["Sing for the Lady"] = {
        "1. After Plague's End, give Lady Ithell a fully charged crystal staff, orb, wand and ward, one at a time.",
        "2. She returns each seed, so a weapon seed can be reused.",
        "3. Then ask Is there anything else I can do for you? to claim the lamp.",
    },

    ["Troublesome Crystals"] = {
        "1. After Plague's End, collect Prifddinas' sixteen numbered memoriam crystals (Wiki locations).",
        "2. Some need preparation: grown Crwys bush, Meilyr tree, ten buckets, 77 Agility, Fate of the Gods.",
        "3. Deposit them in the Tower of Voices device; Arianwyn can reset lost crystals.",
    },

    ["Uncorrupted Ore"] = {
        "1. After Plague's End, smelt one hundred corrupted ore in the Trahaearn district furnace (89 Smithing).",
        "2. Then speak to Lady Trahaearn and claim the Smithing XP lamp.",
    },

    ["Top Town Hall"] = {
        "1. Upgrade it to tier three through Giles.",
        "2. The storehouse and sleeping quarters must reach tier two first.",
        "3. Tier three costs seventy thousand each of wood, vines and stone.",
    },

    ["Dinosaur Hunter"] = {
        "1. Complete one Big Game Hunter takedown of each of Anachronia's nine dinosaur species.",
        "2. Each needs its own raw bait; levels run from 75 Hunter and 55 Slayer to 96 and 76.",
        "3. Finish the hunt and skin the dinosaur; once per species is enough.",
    },

    ["Stacks on Stacks"] = {
        "1. Build any one complete totem and place it on a totem pedestal.",
        "2. Owning the pieces without placing it does not count.",
    },

    ["Ancient Eastern Tortle Portals"] = {
        "1. After Impressing the Locals, with 90 Divination, activate the three portals on the turtle islands.",
        "2. The second and third portals cost fifty ancestral energy each.",
        "3. Tuai Leit's Own gives fifty energy.",
    },

    ["A Fort Of My Own"] = {
        "1. Bring all nine Fort Forinthry buildings to tier three, starting with New Foundations.",
        "2. Build each tier from the blueprints table by the Workshop, lower tiers first.",
        "3. Starting a blueprint without finishing the building does not count.",
    },

    ["Minor Wisdom"] = {
        "1. After Dead and Buried, unlock one Wisdom of Anima perk at the Ranger's Workroom (95 Fletching).",
        "2. Imbue dinarrows with one anima type in full batches of fifteen until its perk unlocks.",
    },

    ["Mystical Moonstone"] = {
        "1. At 50 Necromancy, bring a moonstone to the Former Master Crafter west of Um's smithy.",
        "2. Wear a brown apron with the torso cosmetic override off, then learn moonstone jewellery.",
    },

    ["A New Direction"] = {
        "1. Search the damaged backpack at Anachronia's west-coast shipwreck for a broken compass.",
        "2. Show it to Irwinsson, then get a compass arrow from skinning Big Game Hunter dinosaurs.",
        "3. Fix the compass and return it to Irwinsson.",
    },

    ["Birds of Prey"] = {
        "1. After Housing of Parliament, find Um's fourteen owls for Deryn as your Necromancy unlocks them.",
        "2. Levels cannot be boosted; the last owl needs 120.",
        "3. Use the Birds of Prey Wiki map for hard-to-see perches.",
    },

    ["Dragonkin Diary"] = {
        "1. With 92 Slayer, kill Nodon dragonkin at the Nodon Front until Naressa's journal drops.",
        "2. Give it to Naressa south-west of Senntisten's cathedral, not her Effigy Incubator version.",
    },

    ["Heroes of the Graveyard"] = {
        "1. At 88 Fishing, Hunter, Mining or Woodcutting, train in Senntisten's Croesus Front graveyard.",
        "2. Collect and read all four books there.",
        "3. Gorvek near the entrance replaces a book destroyed before reading.",
    },

    ["The Elder Ring"] = {
        "1. After City of Senntisten, make the pontifex shadow ring and charge it to tier six.",
        "2. Gather six thousand each of Jas, Wen, Bik and Ful anima.",
        "3. Give Wahisietel the last five thousand of each to overcharge it; tier six alone is not enough.",
    },

    ["One Ten-Thousandth of a Milly"] = {
        "1. With 65 Mining, mine Exalted Quarry essence nodes for one hundred colossal legs, then see Azur.",
    },

    ["Canoe Fix It? Yes You Can!"] = {
        "1. Use planks and steel nails (20-80 Construction).",
        "2. You need 18 willow, 6 maple, 6 yew and 6 magic planks and 120 steel nails in total.",
        "3. Higher-tier planks or nails cannot substitute.",
    },

    ["Cracking"] = {
        "1. Crack the first layer of each of Exalted Quarry's fifteen colossus essence nodes.",
        "2. Veins need 65 Mining, deposits 85 and large deposits 105.",
        "3. Mining the same node again does not count.",
    },

    ["Mama-Rummer-Totummer"] = {
        "1. At the Fenmoor Totems: a toad, mollusc and elemental totem, made yourself.",
        "2. They need 65, 85 and 105 Fletching; the elemental needs petrified logs.",
        "3. A head start does not finish a totem.",
    },

    ["Bogolin Dichromacy"] = {
        "1. After Heralds of Crimson, cook Waterface's stews for Bloodnose in Globin and Linbog.",
        "2. Reap n Creep needs sanguine bear meat and sanguine bark; ordinary bear meat does not work.",
        "3. Finish by telling Waterface that Bloodnose loved the stew.",
    },

    ["Fates of the Colossi"] = {
        "1. With 77 Divination, get a memory stone from Aurriel at Divine Fall and fill it at the remnants.",
        "2. Deposit it at its mural; teleports are blocked while it is charged.",
        "3. Get both lore drops from all seven murals (Wiki mural map).",
    },

    ["Finding Tali"] = {
        "1. After Visions of Havenhythe, talk to Reuben, then find Tali north of Wendlewick watchtower.",
        "2. Bring her the mattock, brush and journal from the giant camp and cave.",
        "3. Then tell Reuben she is waiting.",
    },

    ["Gift of Buggies"] = {
        "1. Make buggy mush by filling a farm trough only with insects such as flies.",
        "2. Use it on Aurora at the bottom of Exalted Quarry; talking to her is not enough.",
    },

    ["Lost and...Found?"] = {
        "1. Needs Heralds of Crimson. Start each search from the ancient willow; follow the Wiki directions.",
        "2. Leave the instance after each site before starting the next.",
    },

    ["Maya Use Your Fish Farm?"] = {
        "1. After Trader Woes, with 25 Farming and 45 Fishing, help Maya run her lobster pool.",
        "2. Bring ten raw lobsters and ten raw fish no higher than rainbow fish for the food hatch.",
        "3. Clear the algae with clams, fish the pool empty and talk to Maya.",
    },

    ["The Lute of Love"] = {
        "1. After Visions of Havenhythe, with 20 Crafting and 40 Fletching, help Dalia west of the Shrine of Inanna.",
        "2. Fletch the lute from Adam's blueprint with three yew and ten maple logs.",
        "3. String it with fifteen sinew (not bowstrings) and return it to Dalia.",
    },

    ["Trader Woes"] = {
        "1. After Visions of Havenhythe, speak to Banker Nathan at Wendlewick bank and follow his errands.",
        "2. Bring thirty iron nails to repair Maya's boat; higher-tier nails do not work.",
        "3. Finish by returning to Nathan.",
    },

    ["Master Otto"] = {
        "1. After Tai Bwo Wannai Trio, finish all of Otto Godblessed's barbarian training west of Baxtorian Falls.",
        "2. It covers Firemaking, Fishing, Smithing and Herblore lessons.",
        "3. Report back to Otto after each lesson.",
    },

    ["Champions. What Champions?"] = {
        "1. With 33 quest points, collect the thirteen lower champions' scrolls and duel each at the Champions' Guild.",
        "2. Then defeat Leon d'Cour, and finally Glophren.",
        "3. Familiars and pouches are not allowed; full completion needs 60 Slayer.",
    },

    ["Jack of the Circus"] = {
        "1. There are twenty-eight pieces; each costume comes from a different score band.",
        "2. Top scores alone will not collect them all.",
        "3. The firemaker pieces need The Firemaker's Curse.",
    },

    ["Penguin Adoption Agency"] = {
        "1. Spy on eighty penguins in Penguin Hide and Seek across weekly resets.",
        "2. It is a spy count, not penguin points; Sheldon then unlocks as a pet.",
    },

    ["Nomad's Mirage"] = {
        "1. After Nomad's Elegy, defeat the harder Memory of Nomad in one attempt via Death's office.",
        "2. Avoid Soul Split: it heals Nomad.",
        "3. Loot a bounty chest outside the gates afterwards.",
    },

    ["Eastern Explorer"] = {
        "1. Reach four million one hundred thousand voyage distance in your Player-Owned Port.",
        "2. Check it on the Captain's Log; story missions add no distance.",
    },

    ["Get Tooled Up"] = {
        "1. Add each tool with Add-to-tool belt; banking it does not count.",
        "2. Some need Dungeoneering tokens, Slayer points or pilfer points (Wiki tool-belt table).",
        "3. Check the tool belt for the slots still missing.",
    },

    ["Scrolling in the Deep"] = {
        "1. Unlock every Player-Owned Port scroll recipe by choosing it as your scroll focus.",
        "2. This includes Walking the Reef's reefwalker's cape.",
        "3. You unlock recipes; crafting the items is not needed.",
    },

    ["Build Them All!"] = {
        "1. Build all fifty-eight Treasure Trail hidey-holes; the board beside Zaida shows which are missing.",
        "2. Each needs four planks and ten matching nails; master holes also need gold leaf (88 Construction).",
        "3. Filling them is a separate achievement.",
    },

    ["Raptor's Revenge"] = {
        "1. After Ancient Awakening, beat the twelve-wave activity at Ungael's imposing statue in hard mode.",
        "2. Finish standard mode first to unlock hard mode; the quest fight does not count.",
    },

    ["All Rise"] = {
        "1. After King's Ransom, complete all sixteen Court Cases with summons taken to the Clerk in Seers' Village.",
        "2. Then claim both the gavel and the Detective title from the Clerk.",
    },

    ["Arise from the Ash"] = {
        "1. After In Pyre Need, with 51 Slayer, defeat the phoenix in the Phoenix Lair.",
        "2. Build its pyre from twig ribbons and light it, then talk to the reborn phoenix.",
    },

    ["Balanced Combat Triangle"] = {
        "1. From a master clue, solved yourself; a skipping ticket does not count.",
        "2. Make every tile show the same symbol.",
    },

    ["Slide To The Left"] = {
        "1. From a hard or elite clue, solved yourself; a skipping ticket does not count.",
    },

    ["Towering Over Us All"] = {
        "1. From a master clue, solved yourself; a skipping ticket does not count.",
    },

    ["Untangled"] = {
        "1. Solve it yourself from an elite clue, until every crossing turns green.",
    },

    ["Tiers of Treasure"] = {
        "1. Easy, medium, hard, elite and master: several trails of one tier do not replace a missing tier.",
    },

    ["Big Chinchompa"] = {
        "1. Games run twice daily, at half past the hour; scores from separate games do not add up.",
        "2. Catch moths and empty the jar into the nest for competence points.",
    },

    ["Stay Safe"] = {
        "1. Pull back the poster in the second jail cell at the Stronghold of Player Safety.",
        "2. Pull the old lever on the upper level, then open the secure sector's treasure chest.",
    },

    ["Stay Secure"] = {
        "1. Claim all four reward containers in the Stronghold of Security under Barbarian Village.",
        "2. Reaching the bottom or opening only the last chest is not enough.",
    },

    ["Whodunnit? I Dunnit!"] = {
        "1. After Ancient Awakening, defeat all twelve waves at Ungael's imposing statue in standard mode.",
        "2. The quest fight alone does not count.",
    },

    ["Like Farming Fish in a Pool - Swordfish"] = {
        "1. After Maya Use Your Fish Farm, fish Maya's swordfish pool.",
        "2. Repair the pool (unboosted 55 Fishing); consumed catches from the Fury shark outfit do not count.",
    },

    ["Like Farming Fish in a Pool - Shark"] = {
        "1. After Maya Use Your Fish Farm, catch 250 shark from Maya's shark pool.",
        "2. Repair the pool (unboosted 79 Fishing); consumed catches from the Fury shark outfit do not count.",
    },

    ["Like Farming Fish in a Pool - Giant Crayfish"] = {
        "1. After Maya Use Your Fish Farm, fish Maya's crayfish pool.",
        "2. Repair the pool (unboosted 84 Fishing); consumed catches from the Fury shark outfit do not count.",
    },

    ["Agile from Head to Toe"] = {
        "1. Earn the agile legs and agile top: 250 perfect laps each on the advanced Gnome and Barbarian courses.",
        "2. The courses need 85 and 90 Agility; the Barbarian one needs the Bar Crawl miniquest.",
    },

    ["The Prodigal Spender"] = {
        "1. Buy every permanent unlock from Ezreal at the Archaeology Guild with chronotes.",
        "2. This includes the auto-screener blueprint, both outfits and the extra relic loadout.",
        "3. Full completion needs 99 Archaeology and the Guildmaster qualification.",
    },

    ["Perky Like a Prawn"] = {
        "1. Earn all eighteen prawn perk points with the Prawnbroker in your house Aquarium (63 Construction).",
        "2. Points come from fourteen golden fish eggs and the prawn-ball milestones.",
    },

    ["Stone's Throw Away"] = {
        "1. Earn all thirty replica pieces by completing the Dahmaroc statue in Varrock Museum.",
        "2. Build the statue plinth in your house (55 Construction) and add the pieces in pairs.",
    },

    ["Hard as Daemons"] = {
        "1. Complete all sixty Daemonheim floors on hard mode (the last needs 119 Dungeoneering).",
        "2. Unlock hard mode yourself through the elite Daemonheim achievements; a host's unlock does not count.",
    },

    ["Kal'gerion Commander"] = {
        "1. Read all five Kal'gerion battle commendations from ordinary Kal'gerion demons, in order.",
        "2. Each needs its Daemonheim boss defeated first; Shadow Reef demons do not drop them.",
        "3. You can own only one commendation at a time.",
    },

    ["Scrolling with Power"] = {
        "1. Buy and read the eight permanent scrolls in the Daemonheim Rewards shop.",
        "2. Unread scrolls in the bank do not count; the scroll of gathering is not needed.",
    },

    ["Rank: Master Finix"] = {
        "1. Earn Runespan points and buy every esteem rank from Wizard Finix up to rank one.",
        "2. Having the points without buying rank one does not count.",
    },

    ["Ferocious Upgrade"] = {
        "1. After Plague's End, with 90 Slayer, buy the ferocious ring upgrade from Morvran for one hundred points.",
        "2. Other Slayer Masters cannot sell it.",
    },

    ["Special Slayer Delivery"] = {
        "1. Buy the five Slayer ability unlocks from any Slayer Master's rewards shop.",
        "2. They cost 1,900 points from scratch; you do not have to make the items.",
    },

    ["To Be a Master"] = {
        "1. Capture each missing creature's soul in an ushabti (from Faiza, 99 Slayer).",
        "2. Kills in player-owned Slayer dungeons do not fill ushabti.",
        "3. Deposit each in the Chest of Souls or your dungeon to record it.",
    },

    ["Work on Your Artisan II"] = {
        "1. Buy the Necturion, Invictum and Aetherium outfits from Egil at the Artisans' Workshop in Falador.",
        "2. They need three hundred percent respect from scratch.",
        "3. The earlier Work on Your Artisan reward list is not required for this achievement.",
    },

    ["Bipedal Mask"] = {
        "1. Build a Tuska mask from five pieces dropped by airut while on an airut Slayer task.",
    },

    ["Famous"] = {
        "1. Get Morvran's special Slayer challenge in Prifddinas (or pay one hundred Slayer points once a week).",
        "2. Kill each listed boss once, solo, carrying every dark crystal you collect.",
        "3. Deathtouched darts do not count.",
    },

    ["Slayer Master"] = {
        "1. After Plague's End, clear all twenty waves of platinum Rush of Blood (99 Slayer, 90 Dungeoneering).",
        "2. Platinum also needs eight quests (Wiki list); reaching wave twenty is not enough.",
        "3. A trial run counts.",
    },

    ["Abyssal Shortcut"] = {
        "1. Use a gate key from abyssal lords on the Senntisten Asylum gate, then rope the broken railing.",
        "2. Opening the gate alone does not finish it.",
    },

    ["A Place For My Heads"] = {
        "1. The Raptor gives one trophy per special challenge; ordinary undead tasks give no trophy.",
        "2. Mount them in the Guardhouse at Fort Forinthry.",
    },

    ["Here to Slay"] = {
        "1. The lens drops from Profane Scabarites; ensouling it needs 80 Necromancy and Smoking Kills.",
        "2. Upgrade a worn mighty helmet with a corrupted gem and 1,000 Slayer points (70 Defence).",
        "3. Re-equip the helmet after the lens is attached.",
    },

    ["Finished unpacking!"] = {
        "1. After Eclipse of the Heart, buy the fourth Sunken Pyramid room for 3,000 Slayer points.",
        "2. Then enter that room in your Slayer dungeon.",
    },

    ["Student Becomes the Master"] = {
        "1. Needs 20 Necromancy and Kili Row; Kili is in the City of Um.",
        "2. Tiers 70 to 90 need The Spirit of War; power tasks also need boss drops.",
        "3. Keep her soul urn in your backpack while collecting souls.",
    },

    ["In Rituals We Trust"] = {
        "1. Thirteen rituals, once each, at the City of Um ritual site.",
        "2. Levels run up to 95 Necromancy; essence rituals need Rune Mythos, ensoul ones Kili Row.",
    },

    ["Unliving on a Prayer"] = {
        "1. After Necromancy!, learn every listed prayer and curse from Selene in the City of Um chapel.",
        "2. Curses need The Temple at Senntisten; Sorrow needs 90 Necromancy.",
        "3. Sanctity needs King's Ransom and Knight Waves; the Leech curses need 70 Necromancy. Not Ruination.",
    },

    ["Talented in Necromancy"] = {
        "1. Unlock all twenty-one talents at the Well of Souls in the City of Um.",
        "2. Talent points come only from Necromancy combat; the last talent needs 99 Necromancy.",
        "3. Some talents need Rune Mythos, Tomes of the Warlock or The Temple at Senntisten.",
    },

    ["A Reptile's Dysfunction"] = {
        "1. After Requiem for a Dragon, wear the ring and speak to the Archivist there first.",
        "2. It upgrades within about one hundred rituals.",
    },

    ["Honourary Imcando"] = {
        "1. Upgrade every Death Skull and deathwarden piece through each tier at the City of Um soul forge.",
        "2. Also make deathdealer robes from a second tier 60 deathwarden set and upgrade them to 90.",
    },

    ["Mysteries - Kharid-et"] = {
        "1. Eight mysteries; your Archaeology journal tracks them.",
        "2. The last ones need 107 Archaeology; The Vault of Shadows also needs the shadow anchors or pylon.",
    },

    ["Mysteries - Infernal Source"] = {
        "1. Four mysteries, 24 to 68 Archaeology. Contract Claws needs 35 Prayer and part of Land of the Goblins.",
        "2. Ironmen also need 49 Farming, 60 Construction and Bringing Home the Bacon.",
        "3. Ironmen also need 33 Fishing, 28 Hunter or part of Back to my Roots.",
    },

    ["Mysteries - Everlight"] = {
        "1. Solve all seven Everlight mysteries (42 to 105 Archaeology, all boostable).",
        "2. The Everlight also needs 40 Construction.",
    },

    ["Mysteries - Stormguard Citadel"] = {
        "1. Solve all six Stormguard mysteries (70 to 95 Archaeology).",
        "2. Howl's Floating Workshop needs an unboosted 95.",
    },

    ["Mysteries - Warforge"] = {
        "1. Solve all six Warforge mysteries (76 to 110 Archaeology).",
        "2. Into the Forge also needs 35 Dungeoneering and 28 Fishing.",
    },

    ["Mysteries - Orthen"] = {
        "1. Solve all eight Orthen mysteries (90 to 120 Archaeology).",
        "2. Start by talking to Mr. Mordaut about the dig site with the Associate qualification.",
        "3. Teleport Node On needs 70 Runecrafting, Crafting and Divination and an unboosted 90.",
    },

    ["Mysteries - Senntisten"] = {
        "1. Solve all three Senntisten mysteries (66 and 67 Archaeology).",
    },

    ["Mysteries - Daemonheim"] = {
        "1. Solve all three Daemonheim mysteries (87 and 113 Archaeology, 95 Dungeoneering).",
        "2. A New Age also needs Thought Process and Twilight of the Gods.",
    },

    ["Mysteries - Moonrise"] = {
        "1. After Secrets of Amberfell, solve the five Moonrise mysteries (52 to 88 Archaeology).",
        "2. A Tangled Web is not needed.",
    },

    ["Mysteries - Guild"] = {
        "1. At 40 Archaeology (Assistant), solve Secrets of the Monolith at the Archaeology Guild.",
        "2. Writings on the Walls: 99 Archaeology, Guildmaster, Time Served, Eyes in Their Stars, Into the Forge.",
        "3. It also needs Hallowed Be... far enough to open the underwater cave.",
    },

    ["Research - Kharid-et"] = {
        "1. Study each research object at Kharid-et, then send it from the Exam Centre research notes table.",
        "2. Your base level counts, not boosts. Lockdown is found during The Vault of Shadows.",
        "3. Nom-Nom-Nom-Nom needs part of Tomes of the Warlock; Shadow Play needs pylons or shadow anchors on.",
    },

    ["Research - Infernal Source"] = {
        "1. Study each research object at Infernal Source, then send it from the Exam Centre research notes table.",
        "2. Your base level counts, not boosts. All six are required (levels 40, 68 and 98).",
    },

    ["Research - Everlight"] = {
        "1. Study each research object at Everlight, then send it from the Exam Centre research notes table.",
        "2. Your base level counts, not boosts. Two of the seven are in the underwater cave.",
    },

    ["Research - Stormguard Citadel"] = {
        "1. Study each research object at Stormguard, then send it from the Exam Centre research notes table.",
        "2. Your base level counts, not boosts. Night and Day and The Aetherium Giant need wingsuit v2.",
        "3. Howl's workshop research needs a Stormguard gerege on your tool belt.",
    },

    ["Research - Warforge"] = {
        "1. Study each research object at Warforge, then send it from the Exam Centre research notes table.",
        "2. Your base level counts, not boosts. Big High War Chest needs You Have Chosen... first.",
    },

    ["Research - Orthen"] = {
        "1. Study each research object at Orthen, then send it from the Exam Centre research notes table.",
        "2. Your base level counts, not boosts. Let Sleeping Kin Lie needs Desperate Measures (during or after).",
    },

    ["Research - Senntisten"] = {
        "1. Study each research object at Senntisten, then send it from the Exam Centre research notes table.",
        "2. Your base level counts, not boosts.",
        "3. Crossing that Bridge needs page 5 of the Inquisitor's memoirs from Secrets of the Inquisition.",
    },

    ["Research - Daemonheim"] = {
        "1. Study each research object in Daemonheim, then send it from the Exam Centre research notes table.",
        "2. Your base level counts, not boosts. The statue is one floor above ground; two are in the Depths.",
    },

    ["Research - Moonrise"] = {
        "1. Study the three research objects at the Moonrise Temple, then send them from the Exam Centre.",
        "2. Your base level counts, not boosts (75, 82 and 88).",
    },

    ["Research - Guild"] = {
        "1. The Mysterious Monolith research unlocks with the Assistant, Associate and Professor qualifications.",
        "2. At 99, buy the energised meteorite shard to start Philosophy.",
        "3. In the master archaeologist's outfit, study the strange writing at the five main dig sites.",
    },

    ["Research Director"] = {
        "1. Most are unlocked by showing them a specific restored artefact.",
        "2. Anna Jones needs the Guildmaster qualification, and Tali needs Finding Tali.",
        "3. The six dig-site managers each unlock when you finish their dig site's mysteries.",
    },

    ["Mastery - Kharid-et"] = {
        "1. Finish Mysteries - Kharid-et and Research - Kharid-et.",
        "2. Excavate there with the pylons active, and power all eight shadow anchors.",
    },

    ["Mastery - Infernal Source"] = {
        "1. Finish Mysteries - Infernal Source and Research - Infernal Source.",
        "2. Loot every abandoned chest in the Star Lodge.",
    },

    ["Mastery - Everlight"] = {
        "1. Finish Mysteries - Everlight and Research - Everlight.",
        "2. Complete No Secrets Left to Steal and catch the golden butterfly.",
    },

    ["Mastery - Stormguard Citadel"] = {
        "1. Finish Mysteries - Stormguard Citadel and Research - Stormguard Citadel.",
        "2. Activate every portal in the citadel and complete Home is Where the God is.",
    },

    ["Mastery - Warforge"] = {
        "1. Finish Mysteries - Warforge and Research - Warforge.",
    },

    ["Mastery - Orthen"] = {
        "1. Finish Mysteries - Orthen and Research - Orthen.",
    },

    ["Mastery - Daemonheim"] = {
        "1. Finish Mysteries - Daemonheim and Research - Daemonheim.",
    },

    ["Mastery - Moonrise"] = {
        "1. Finish Mysteries - Moonrise and Research - Moonrise (88 Archaeology).",
    },

    ["Mastery - Senntisten"] = {
        "1. Finish Mysteries - Senntisten and Research - Senntisten.",
        "2. Complete Pane in the Glass: repair the four cathedral windows.",
    },

    ["Dream Team"] = {
        "1. Reach the Guildmaster qualification for a research team of five.",
        "2. Recruit five dig-site managers as consultants by finishing their site's mysteries.",
        "3. Send all five consultants on a research contract. Intern Jimmy does not count.",
    },

    ["Relic-weary"] = {
        "1. The monolith is on the Archaeology Campus.",
        "2. Relics come from collections, dig sites and NPCs. Reclaim a lost relic from Easty.",
    },

    ["Qualification - Guildmaster"] = {
        "1. Finish Qualification - Professor and reach 99 Archaeology.",
        "2. Restore 1,000 artefacts, finish 25 collections, solve 20 mysteries, research for 168 hours.",
        "3. No ceremony needed. Talk to Acting Guildmaster Reiniger afterwards for free supplies.",
    },

    ["Armadylean Expert"] = {
        "1. Restore every Armadylean artefact from the Stormguard Citadel Dig Site at an archaeologist's workbench.",
        "2. The Armadylean I, II and III collections list them.",
    },

    ["Bandosian Expert"] = {
        "1. Restore at least one of each of the 27 Warforge Dig Site artefacts at an archaeologist's workbench.",
        "2. The Bandosian I, II and III collections list them.",
    },

    ["Dragonkin Expert"] = {
        "1. Use an archaeologist's workbench; the Dragonkin I to VII collections list them.",
    },

    ["Guthixian Expert"] = {
        "1. Restore at least one of each Moonrise Dig Site artefact at an archaeologist's workbench.",
        "2. The Guthixian I and II collections list them.",
    },

    ["Saradominist Expert"] = {
        "1. Restore all 31 Everlight Dig Site artefacts at an archaeologist's workbench.",
        "2. The Saradominist I to IV collections list them.",
    },

    ["Zamorakian Expert"] = {
        "1. Restore every Infernal Source Dig Site artefact at an archaeologist's workbench.",
        "2. The Zamorakian I to IV collections list them.",
    },

    ["Zarosian Expert"] = {
        "1. Restore all 52 Kharid-et and Senntisten artefacts at an archaeologist's workbench.",
        "2. The Zarosian I to VII collections list them.",
    },

    ["Home is Where the God is"] = {
        "1. Restore the aviansie dreamcoat (from the Deer-ly Departed research).",
        "2. Give it to Armadyl at the top of Armadyl's Tower.",
        "3. If Armadyl is missing, finish or replay Sliske's Endgame first.",
    },

    ["No Secrets Left to Steal"] = {
        "1. At Everlight, restore, fill and open all four statues (40 Construction).",
        "2. Each needs ten unnoted white marble and one restored artefact.",
        "3. Hallowed lantern (Hebe), Everlight harp (Mesomedes), Dominion torch, Rod of Asclepius.",
    },

    ["Pane in the Glass"] = {
        "1. Needs 80 Crafting; the cathedral is in Senntisten.",
        "2. Each takes 100 ancient glass shards from excavating at the Senntisten Dig Site.",
    },

    ["Dark Reading Material"] = {
        "1. Find the five books at Infernal Source: Star Lodge cellar chests and Dungeon of Disorder shelves.",
        "2. Keep each book until the achievement completes: reading one destroys it for good.",
    },

    ["Collectors Assemble"] = {
        "1. Hand restored artefacts to the collectors; thirty are Velucia's museum collections.",
        "2. Check your collection log for unfinished ones.",
    },





    ["Sandy"] = {
        "1. Reach tier 10 reputation in all four Menaphos districts.",
        "2. Finish the six other Menaphos achievements and Jack of all Menaphos.",
        "3. Then talk to Urluk the camel in the Merchant district for the Sandy title.",
    },


    ["Salty"] = {
        "1. Complete every section of the Arc journal.",
        "2. Buy every permanent Waiko Reward Shop unlock, including all upgrade tiers.",
        "3. Claim the berry, bird and kami rewards, and get Flippers McGraw to join your crew.",
    },

    ["Flippers"] = {
        "1. After Impressing the Locals, give Flippers McGraw a raw seerfish, tarpon, sillago or wobbegong.",
    },

    ["Castaways of the Arc"] = {
        "1. Find a message in a bottle, then ask Quartermaster Gully to sail to that castaway; talk to them.",
        "2. Bottles change at the daily reset. Talk to every castaway.",
        "3. Aminishi spirit realm: Spiritual Enlightenment, 90 Slayer, Meet the Assassin; turtles: 90 Divination.",
    },

    ["Stone Cold Observers"] = {
        "1. They are south-west, by the volcano, south-east, north-east and east (not the base camp one).",
    },

    ["Through the Eye of the Needle"] = {
        "1. At Senntisten, enter the Colosseum gateway (west end of the Nodon Front) and watch the cutscene.",
    },

    ["Friend of the Imcando"] = {
        "1. Talk to Thalmund, south of the smithy in the City of Um, on seven different Wednesdays.",
        "2. He is only there on Wednesdays. You don't have to finish the conversation.",
    },

    ["Port Life"] = {
        "1. Reach 90 in any of the twelve listed skills first.",
    },

    ["Eastern Adventurer: Eastern Curiosities"] = {
        "1. In your port, finish each adventurer's own voyages first.",
        "2. Then send the trio's story voyages as they arrive, up to the final one.",
    },

    ["Eastern Adventurer: Guardians of the World"] = {
        "1. In your port, finish each adventurer's own voyages first.",
        "2. Then send the trio's story voyages as they arrive, up to the final one.",
    },

    ["Eastern Adventurer: Hyu-Ji"] = {
        "1. In your port, finish each adventurer's own voyages first.",
        "2. Then send the trio's story voyages as they arrive, up to the final one.",
    },

    ["Eastern Adventurer: Quin"] = {
        "1. In your port, finish each adventurer's own voyages first.",
        "2. Then send the trio's story voyages as they arrive, up to the final one.",
    },

    ["Kiln Fighter"] = {
        "1. Needs The Elder Kiln and a fire cape from the TzHaar Fight Cave to enter; thirty-seven waves.",
    },

    ["Three's a Kiln"] = {
        "1. Finish the Fight Kiln with mostly Melee, Ranged and Magic once each for all three capes.",
        "2. Give all three to TzHaar-Mej-Jeh in TzHaar City. The capes are destroyed.",
    },

    ["Circus of Fire"] = {
        "1. After The Firemaker's Curse, complete any act in Balthazar Beauregard's Big Top Bonanza.",
    },

    ["Following In The Footsteps"] = {
        "1. Take part in the Effigy Incubator encounter twelve times (once a month).",
        "2. After Extinction, Vicendithas can accelerate a chapter for base camp resources.",
        "3. Then ask Vicendithas: About your research..., What have you learned?",
    },

    ["Music Maestro"] = {
        "1. Unlock every music track the achievement counts. The music player shows which are locked.",
    },

    ["Bill & Ben's Egg/Salon Joint Venture"] = {
        "1. After Extinction, complete the six farm achievements around the Anachronia dinosaur farm.",
        "2. Elder God arrows and dinosaur propellant are needed for the last ones.",
    },

    ["Potting Is Such Sweet Sorrow"] = {
        "1. After Mycomanagement, get Bill's magic pot back from his brother Ben.",
        "2. Give Ben an empty plant pot, then return the magic pot to Bill.",
    },

    ["Everything Is Oresome"] = {
        "1. Mine one hundred of each listed ore, copper up to dark animica.",
        "2. Banite from the Glacor cavern mine does not count.",
    },

    ["Everything Is Still Oresome"] = {
        "1. Mine one hundred of each listed ore, novite up to promethium.",
    },

    ["Everything Is Treemendous"] = {
        "1. At 90 Woodcutting, cut one hundred of each listed log, regular up to elder.",
        "2. Miscellania and Etceteria trees, divine locations, Scraps and Furnace perks don't count.",
    },

    ["Everything Is Still Treemendous"] = {
        "1. At 100 Woodcutting, cut one hundred eternal magic logs.",
        "2. Logs burned straight away (Superheat Form, inferno adze, Always Adze) don't count.",
    },


    ["It Still Should Have Been Called Aetherium"] = {
        "1. Smith every piece of a full primal armour set up to +5.",
    },

    ["It Should Have Been Called Ancestral"] = {
        "1. Craft every piece of a full starbloom armour set up to +5.",
    },


    ["Fletch Quest"] = {
        "1. Make an eternal magic shortbow, a primal crossbow and an off-hand primal crossbow, all Mk. 5.",
        "2. Every step must be made once; the off-hand needs a second stock and limbs.",
    },

    ["Crafting to Your Own Rune"] = {
        "1. Make an eternal magic staff, wand and orb, and imbue each one to 100%.",
    },

    ["Maximum Poolpulation"] = {
        "1. At Maya's fish farm, stock and feed all four pools, then run the food dispenser.",
        "2. Clam away algae as it appears until every pool is full.",
    },

    ["My Precious!"] = {
        "1. Fish at the Deep Sea Fishing hub until the ring turns up (very rare).",
        "2. Return it to Gregg 'Groggy' Herring at the hub.",
    },

    ["Memories of Guthix"] = {
        "1. At the Memorial to Guthix, do Orla Fairweather's tutorial.",
        "2. Find, charge and hand in every engram around Gielinor.",
    },

    ["Memorialised More Than Once"] = {
        "1. Complete the Memorial to Guthix, then prestige at the fountain of energy.",
        "2. Collect and hand in every engram again each time. Prestige three times.",
    },

    ["E-I-E-I-O"] = {
        "1. Breed every listed animal breed at Manor Farm to fill all the breeding logs.",
        "2. Only animals bred on your farm count; buying an animal does not tick its entry.",
        "3. With E-I-E-DI-NO, click Sam the sheepdog or Stan the sheepdog for the Old Mc title.",
    },

    ["E-I-E-DI-NO"] = {
        "1. Breed every listed breed at the Anachronia Dinosaur Farm to fill all its breeding logs.",
        "2. With E-I-E-I-O, click Sam the sheepdog or Stan the sheepdog for the Old Mc title.",
    },

    ["Draught Includer"] = {
        "1. Discover every Invention blueprint at an inventor's workbench as your level unlocks them.",
    },

    ["Gaps, Traps and Laps"] = {
        "1. Complete one lap of every listed agility course.",
        "2. Werewolf: finish the deathslide without falling. Brimhaven: earn an Agility Arena ticket.",
        "3. Dorgesh-Kaan: get Turgall both boiler parts, by the agility and grapple routes.",
    },

    ["Almost as Perky as a Prawn"] = {
        "1. Earn prawn perk points in your house Aquarium.",
        "2. Then talk to the Prawnbroker and choose Prawn perks.",
    },

    ["Draconic Decoctions"] = {
        "1. Excavate at Orthen for recipe fragments, then complete and read all five potion recipes.",
    },

    ["Yaktwee's a Charm"] = {
        "1. Catch one thousand charm sprites with the yaktwee stick.",
        "2. Then talk to Yaktwee to upgrade to the enhanced yaktwee stick.",
    },

    ["Pious Prayers"] = {
        "1. After King's Ransom, beat all eight Knight Waves in Camelot castle (top floor).",
        "2. Each hit drains a combat stat; Necromancy is not drained.",
    },

    ["Lunar Master"] = {
        "1. Earn produce points at the Livid Farm on the Lunar spellbook.",
        "2. Unlock all eleven Livid Farm spells, in order.",
    },

    ["Count All Light Fingers"] = {
        "1. After Buyers and Cellars, finish From Tiny Acorns, Lost Her Marbles and A Guild of Our Own.",
    },

    ["From Ardougne with Love"] = {
        "1. Track forty penguin spies in total in the weekly Penguin Hide and Seek.",
    },

    ["Trip to the East"] = {
        "1. In your port, finish one trio storyline: Quin, Hyu-Ji, Eastern Curiosities or Guardians of the World.",
    },

    ["Walking the Reef"] = {
        "1. In Port management, select the Reefwalker's cape scroll.",
        "2. Send the scroll voyages as they appear until four succeed.",
    },

    ["Bean There, Done That"] = {
        "1. Buy every listed upgrade from the Manor Farm Farmers' Market (38,600 beans in total).",
    },

    ["Bean There, Done That, Got the Postcard"] = {
        "1. Buy every listed upgrade from the Anachronia Farmers' Market (35,100 beans in total).",
    },

    ["Shadows Below"] = {
        "1. Defeat all six brothers in Barrows: Rise of the Six (needs a Barrows totem).",
        "2. Loot the chest, then escape the collapsing tunnel.",
    },

    ["Telos If You're Angry II"] = {
        "1. Lower enrage does not count.",
    },

    ["Finish Him!"] = {
        "1. Fight Vorago and land the final blow yourself with the maul of omens.",
        "2. The maul's pieces come in phases 1, 2 and 4; anyone can collect them.",
    },

    ["A Song of Ice and Ire II"] = {
        "1. Kills of the Arch-Glacor at lower enrage do not count.",
    },

    ["Jail break"] = {
        "1. Kill Osseous for three jail cell keys (about 1 in 400 each).",
        "2. Free the three baby rex from the jail cells. Needs part of Osseous Rex.",
    },

    ["A Mini Shipment"] = {
        "1. Get the azure key on Goshima and the trunk key on Aminishi (Curse of the Black Stone, started).",
        "2. The trunk is in the azure room.",
    },

    ["God Wars"] = {
        "1. Enter the God Wars Dungeon.",
    },

    ["My Last Resort"] = {
        "1. Kill bosses: there are seven, and the last needs 2,000 boss kills.",
    },

    ["Reaper Crew"] = {
        "1. There are fifty-five; some need high levels and quests, and the Wiki list shows which.",
    },

    ["Death Effect"] = {
        "1. Pay with Reaper points from Soul Reaper tasks, at most three hundred a week.",
    },

    ["War. What Is It Good For?"] = {
        "1. Complete My Last Resort and the combat Relight My Fire (War's Retreat bonfire upgrades).",
        "2. They take 2,000 boss kills, 7,000 Marks of War and 1,000 each of seven kinds of log.",
    },

    ["Conquered Everyone's Heart"] = {
        "1. Earn it with ingression fragments, enemy generals' seals and Feng's bounties.",
    },

    ["My Goebie Homies"] = {
        "1. Earn five thousand goebie reputation on Mazcab.",
        "2. Each day, do Trinks's three tasks and the nine Nemi Forest activities.",
    },

    ["Undead to Rites"] = {
        "1. Cast the Ungael Teleport incantation (Rune Mythos, Requiem for a Dragon, 75 Necromancy).",
    },

    ["No Need to Pikkenchoose"] = {
        "1. Make summoning pouches at an empowered obelisk for 5,000 Blessings of the Wolf.",
        "2. That unlocks everything at Pikkenflix's shrine. Scrolls give no blessings.",
    },

    ["Bridge over Fremmy Waters"] = {
        "1. Talk to Skaldrun; needs 71 Dungeoneering.",
        "2. Missing a hidden side objective gives only the abridged tome; follow a walkthrough.",
    },

    ["Invention Gives Me the Blues"] = {
        "1. Buy every blueprint in both the cave goblin and the dwarven technology trees.",
        "2. Currency comes from Invention tasks (40 Invention), new at 00:00 and 12:00.",
    },

    ["Da Vinci Who?"] = {
        "1. Read the Ancient Gizmos, Ancient Tools and Ancient XP Capacitor blueprints (85 Invention).",
        "2. Craft them from torn blueprint fragments in Howl's workshop at Stormguard.",
    },

    ["The Greatest Gift of All"] = {
        "1. Give Lea, outside the Invention Guild, a new pickpocketing bag, then a new crystal binding rod.",
    },

    ["Complete Trekky"] = {
        "1. Level all six Temple Trekking companions to 99.",
        "2. Needs In Aid of the Myreque and The Darkness of Hallowvale.",
    },

    ["Goebie One with the Wildlife"] = {
        "1. Catch a popoca, choloa, kerrit and snuffle on Mazcab (55-70 Hunter).",
        "2. Hand each to Arod the environmentalist in the south-east of Otot.",
    },

    ["Power of Three Spirits"] = {
        "1. Talk to Glouron by the Prifddinas spirit tree to unlock three spirit trees.",
        "2. Needs Plague's End, The Prisoner of Glouphrie and 89 Farming.",
    },

    ["New Varrock Set Tasks - Easy"] = {
        "1. Complete every easy New Varrock achievement, then claim from Tiny Zemouregal.",
        "2. New Varrock opens with Dimension of Disaster; his pocket book lists the tasks.",
    },

    ["New Varrock Set Tasks - Medium"] = {
        "1. Complete every medium New Varrock achievement, then claim from Tiny Zemouregal.",
        "2. New Varrock opens with Dimension of Disaster; his pocket book lists the tasks.",
    },

    ["New Varrock Set Tasks - Hard"] = {
        "1. Complete every hard New Varrock achievement, then claim from Tiny Zemouregal.",
        "2. New Varrock opens with Dimension of Disaster; his pocket book lists the tasks.",
    },

    ["New Varrock Set Tasks - Elite"] = {
        "1. Complete every elite New Varrock achievement, then claim from Tiny Zemouregal.",
        "2. New Varrock opens with Dimension of Disaster; his pocket book lists the tasks.",
    },

    ["Quest Cape"] = {
        "1. Complete every quest in the Quests interface.",
    },

    ["Master Quest Cape"] = {
        "1. Complete all 312 achievements in the master quest cape group.",
        "2. Ones still in an active grace period don't block the cape.",
    },

    ["Completionist Cape"] = {
        "1. Complete all 102 achievements in the completionist cape group.",
        "2. Ones still in an active grace period don't block the cape.",
    },

    ["Task Master"] = {
        "1. Complete every Area Tasks set: Easy to Elite in each area, Beginner to Hard in Lumbridge.",
    },

    ["Master Skiller"] = {
        "1. Reach 99 in every skill, 110 in eight skills and 120 in thirteen.",
        "2. The achievement's list shows which levels you still need.",
    },

    ["I've Got a Little List (of Miniquests)"] = {
        "1. Complete every miniquest in the Quests interface. Sagas are not included.",
    },

    -- Two RS3 achievements share this name. This is the Lore one (ID 2201,
    -- master quest cape). The War's Retreat one (Combat, ID 1745) is not a
    -- cape item of its own: it sits inside War. What Is It Good For?, whose
    -- guide covers it (core/detect.lua reads only the capes' first level).
    ["Relight My Fire"] = {
        "1. Get the strange key teeth and loop from Movario's base (While Guthix Sleeps, 75 Magic).",
        "2. Needs part of Barbarian Firemaking. Use both parts on a mithril dragon you have hit to fuse the key.",
        "3. Open the mithril door and light all three dragon heads inside.",
    },

}
