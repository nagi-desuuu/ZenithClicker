---@class Achievement
---@field name string
---@field desc string
---@field quote string
---@field credit? string
---@field comp? '<' | '>' | fun(newScore, oldScore):boolean
---@field rank? 'floor' | fun(score):number
---@field scoreSimp? fun(score):string
---@field scoreFull? fun(score):string
---@field noScore? number
---@field hide? fun():boolean

local ilLerp = MATH.ilLerp
local function floorRank(l0, l1, l2, l3, l4, l5)
    local l = {
        Floors[l0 - 1].top,
        Floors[l1 - 1].top,
        Floors[l2 - 1].top,
        Floors[l3 - 1].top,
        Floors[l4 - 1].top,
        Floors[l5 - 1].top,
    }
    return function(h) return 5 * ilLerp(l, h) end
end
local function numberRank(...)
    local l = { ... }
    return function(s) return 5 * (6 - #l + ilLerp(l, s)) end
end
local function heightFloor(h)
    for i = 9, 0, -1 do
        if h >= Floors[i].top then
            return "F" .. (i + 1)
        end
    end
end
local function heightNumber(score)
    return string.format("%.1fm", score)
end

---@type Map<Achievement>
Achievements = {
    ---------------------------
    -- Original from TETR.IO --
    ---------------------------

    -- Single Mod
    EX = {
        name = "The Emperor",
        desc = [[HFD with EX]],
        quote = [[A display of power for those willing to bear its burden.]],
    },
    NH = {
        name = "Temperance",
        desc = [[HFD with NH]],
        quote = [[Use each piece as they come and embrace the natural flow of stacking.]],
    },
    MS = {
        name = "Wheel of Fortune",
        desc = [[HFD with MS]],
        quote = [[The only constant in life is change.]],
    },
    GV = {
        name = "The Tower",
        desc = [[HFD with GV]],
        quote = [[What will you do when it all comes crumbling down?]],
    },
    VL = {
        name = "Strength",
        desc = [[HFD with VL]],
        quote = [[Match great obstacles with greater determination.]],
    },
    DH = {
        name = "The Devil",
        desc = [[HFD with DH]],
        quote = [[Redifine your limits or succumb to his chains.]],
    },
    IN = {
        name = "The Hermit",
        desc = [[HFD with IN]],
        quote = [[When the outside world fails you, trust the voice within to light a path.]],
    },
    AS = {
        name = "The Magician",
        desc = [[HFD with AS]],
        quote = [[Inspiration is nothing short of magic.]],
    },
    DP = {
        name = "The Lovers",
        desc = [[HFD with DP]],
        quote = [[Love, and resign yourself to the fate of another.]],
    },
    rEX = {
        name = "The Tyrant",
        desc = [[HFD with rEX]],
        quote = [[Fear, oppression, and limitless ambition.]],
        hide = function() return GAME.completion.EX > 0 end,
    },
    rNH = {
        name = "Asceticism",
        desc = [[HFD with rNH]],
        quote = [[A detachment from even that which is moderate.]],
        hide = function() return GAME.completion.NH > 0 end,
    },
    rMS = {
        name = "Loaded Dice",
        desc = [[HFD with rMS]],
        quote = [[In a rigged game, your mind is the only fair advantage.]],
        hide = function() return GAME.completion.MS > 0 end,
    },
    rGV = {
        name = "Freefall",
        desc = [[HFD with rGV]],
        quote = [[In retrospect, the ground you stood on never existed in the first place.]],
        hide = function() return GAME.completion.GV > 0 end,
    },
    rVL = {
        name = "Last Stand",
        desc = [[HFD with rVL]],
        quote = [[Strength isn't necessary for those with nothing to lose.]],
        hide = function() return GAME.completion.VL > 0 end,
    },
    rDH = {
        name = "Damnation",
        desc = [[HFD with rDH]],
        quote = [[No more second chances.]],
        hide = function() return GAME.completion.DH > 0 end,
    },
    rIN = {
        name = "The Exile",
        desc = [[HFD with rIN]],
        quote = [[Never underestimate blind faith.]],
        hide = function() return GAME.completion.IN > 0 end,
    },
    rAS = {
        name = "The Warlock",
        desc = [[HFD with rAS]],
        quote = [[Into realms beyond heaven and earth.]],
        hide = function() return GAME.completion.AS > 0 end,
    },
    rDP = {
        name = "Bleeding Hearts",
        desc = [[HFD with rDP]],
        quote = [[Even as we bleed, we keep holding on...]],
        hide = function() return GAME.completion.DP > 0 end,
    },

    -- Mod Combo
    GVNH = {
        name = "A Modern Classic",
        desc = [[HFD with NH GV]],
        quote = [[Times were different back then...]],
    },
    DHMSNH = {
        name = "Deadlock",
        desc = [[HFD with NH MS DH]],
        quote = [["Escape has become a distant dream, yet still we struggle..."]],
    },
    ASDHMS = {
        name = "The Escape Artist",
        desc = [[HFD with MS DH AS]],
        quote = [["An impossible situation! A daring illusionist! Will he make it out alive?"]],
    },
    GVIN = {
        name = "The Grandmaster",
        desc = [[HFD with GV IN]],
        quote = [[When the world descends into chaos, the grandmaster remains at peace.]],
    },
    DHEXNH = {
        name = "Emperor's Decadence",
        desc = [[HFD with EX NH DH]],
        quote = [[The Devil's lesson in humility.]],
    },
    DHEXMSVL = {
        name = "Divine Mastery",
        desc = [[HFD with EX MS VL DH]],
        quote = [[The universe is yours.]],
    },
    ASNH = {
        name = "The Starving Artist",
        desc = [[HFD with NH AS]],
        quote = [[Creativity cultivated trough limitation.]],
    },
    ASEXVL = {
        name = "The Con Artist",
        desc = [[HFD with EX VL AS]],
        quote = [[Would the perfect lie not be an art worthy of admiration ?]],
    },
    DPEX = {
        name = "Trained Professionals",
        desc = [[HFD with EX DP]],
        quote = [[Partners in expertise.]],
    },
    EXMS = {
        name = "Block Rationing",
        desc = [[HFD with EX MS]],
        quote = [[Adversity favors the resourceful.]],
    },
    swamp_water_lite = {
        name = "Swamp Water Lite",
        desc = [[HFD while using all 7/8 of the difficulty mods ("Duo" not allowed)]],
        quote = [[Comes in 8 different flavors!]],
    },
    swamp_water = {
        name = "Swamp Water",
        desc = [[HFD while using all mods other then "Duo" at the same time]],
        quote = [[The worst of all worlds.]],
    },

    -- General
    zenith_explorer = {
        name = "Zenith Explorer",
        desc = [[HFD without any mods]],
        quote = [[Uncover the mysteries of the Zenith Tower.]],
    },
    zenith_speedrun = {
        name = "Zenith Speedrun",
        desc = [[Reach F10 AFAP while retaining GIGASPEED without any mods]],
        quote = [[F10 Hyper%]],
        comp = '<',
        noScore = 1560,
        scoreSimp = function(time) return string.format("%.2fs", time) end,
        scoreFull = NULL,
        -- rank = TODO,
    },
    supercharged = {
        name = "Supercharged",
        desc = [[Highest Back-to-Back chain discovered without any mods]],
        quote = [["With this divine power, we'll be unstoppable!" -Mathis, Core Engineer]],
        scoreSimp = function(b2b) return b2b .. "x" end,
        scoreFull = NULL,
        rank = numberRank(0, 20, 40, 65, 85, 100),

    },
    the_responsible_one = {
        name = "The Responsible One",
        desc = [[Highest amount of revivals performed in a single duo run]],
        quote = [["Could you please stop dying?"]],
    },
    guardian_angel = {
        name = "Guardian Angel",
        desc = [[Highest altitude to perform a successful revive at]],
        quote = [[An angel's intervention.]],
        scoreSimp = heightNumber,
        scoreFull = NULL,
    },
    talentless = {
        name = "Talentless",
        desc = [[HFD with AS but mouse-only]],
        quote = [[Reaching deep down but coming back empty every time.]],
        -- TODO
    },

    -- Activity
    lovers_promise = {
        name = "Lover's Promise",
        desc = [[Highest altitude reached with DP on day 14 of each month]],
        quote = [[The impossible promise of an eternity just like this moment.]],
        scoreSimp = heightNumber,
        scoreFull = NULL,
    },



    -----------------------------------------------
    -- Extended Achievements from Zenith Clicker --
    -----------------------------------------------

    -- Rev Swamp Water Series
    blight = {
        name = "Blight",
        desc = [[HFD with 8+ mod points]],
        quote = [[The world starts withering...]],
        hide = function() return TABLE.countAll(GAME.completion, 0) <= 7 end,
        rank = floorRank(1, 4, 6, 8, 9, 10),
    },
    desolation = {
        name = "Desolation",
        desc = [[HFD with 9+ mod points]],
        quote = [[Vitality has faded from the world's palette...]],
        hide = function() return TABLE.countAll(GAME.completion, 0) <= 7 end,
        rank = floorRank(1, 4, 6, 8, 9, 10),
    },
    havoc = {
        name = "Havoc",
        desc = [[HFD with 10+ mod points]],
        quote = [[The world is in chaos...]],
        hide = function() return TABLE.countAll(GAME.completion, 0) <= 7 end,
        rank = floorRank(1, 3, 5, 8, 9, 10),
    },
    pandemonium = {
        name = "Pandemonium",
        desc = [[HFD with 11+ mod points]],
        quote = [[Several realms began to collide...]],
        hide = function() return TABLE.countAll(GAME.completion, 0) <= 7 end,
        rank = floorRank(1, 2, 4, 7, 8, 9),
    },
    inferno = {
        name = "Inferno",
        desc = [[HFD with 12+ mod points]],
        quote = [[Everything is burning and melting...]],
        hide = function() return TABLE.countAll(GAME.completion, 0) <= 6 end,
        rank = floorRank(1, 2, 4, 6, 7, 8),
    },
    purgatory = {
        name = "Purgatory",
        desc = [[HFD with 13+ mod points]],
        quote = [[Nobody knows their destination...]],
        hide = function() return TABLE.countAll(GAME.completion, 0) <= 5 end,
        rank = floorRank(1, 1, 3, 5, 6, 7),
    },
    perdition = {
        name = "Perdition",
        desc = [[HFD with 14+ mod points]],
        quote = [[There's no way back...]],
        hide = function() return TABLE.countAll(GAME.completion, 0) <= 4 end,
        rank = floorRank(1, 1, 3, 4, 5, 6),
    },
    cataclysm = {
        name = "Cataclysm",
        desc = [[HFD with 15+ mod points]],
        quote = [[The real disaster is yet to come...]],
        hide = function() return TABLE.countAll(GAME.completion, 0) <= 3 end,
        rank = floorRank(1, 1, 2, 3, 4, 5),
    },
    annihilation = {
        name = "Annihilation",
        desc = [[HFD with 16+ mod points]],
        quote = [[The whole universe is trembling...]],
        hide = function() return TABLE.countAll(GAME.completion, 0) <= 2 end,
        rank = floorRank(1, 1, 1, 2, 3, 4),
    },
    armageddon = {
        name = "Armageddon",
        desc = [[HFD with 17+ mod points]],
        quote = [[Big crunch is real...]],
        hide = function() return TABLE.countAll(GAME.completion, 0) <= 1 end,
        rank = floorRank(1, 1, 1, 1, 2, 3),
    },
    abyss = {
        name = "Abyss",
        desc = [[HFD with 18 mod points]],
        quote = [[.]],
        hide = function() return TABLE.countAll(GAME.completion, 0) <= 0 end,
        rank = floorRank(1, 1, 1, 1, 1, 2),
    },

    -- Swamp Water Extended
    swamp_water_pro = {
        name = "Swamp Water Pro",
        desc = [[HFD with all 9/9 mods]],
        quote = [[How did you find someone as insane as you to do it together?]],
        hide = function() return STAT.maxFloor >= 9 end,
    },
    swamp_water_lite_plus = {
        name = "Swamp Water Lite+",
        desc = [[HFD with 1rev+6 mods ("Duo" not allowed)]],
        quote = [[Comes in...... 252 different flavors?]],
        hide = function() return TABLE.countAll(GAME.completion, 0) < 9 end,
    },
    swamp_water_plus = {
        name = "Swamp Water+",
        desc = [[HFD with 1rev+7 mods ("Duo" not allowed)]],
        quote = [[Less choices but still a lot to try.]],
        hide = function() return TABLE.countAll(GAME.completion, 0) < 9 end,
    },
    swamp_water_pro_plus = {
        name = "Swamp Water Pro+",
        desc = [[HFD with 1rev+8 mods]],
        quote = [[The cup is about to overflow!]],
        hide = function() return TABLE.countAll(GAME.completion, 0) < 9 end,
    },

    -- Mod Combo Extended
    EXGVMSNH = {
        name = "Atlas' Lament",
        desc = [[HFD with EX NH MS GV]],
        quote = [[A thankless job, yet our existence lies in his balance...]],
        credit = "@cat_noises",
    },
    ASDPNHVL = {
        name = "Midnight Meal",
        desc = [[HFD with NH VL AS DP]],
        quote = [[You came to eat up these mods, so you'd best be hungry.]],
        credit = "@GameTilDead",
    },
    rGVrNHrVL = {
        name = "Sweatshop",
        desc = [[HFD with rNH rGV rVL]],
        quote = [[Carefree life is not for the asking, someone else is carrying the burden for you.]],
        hide = function() return GAME.completion.NH > 0 and GAME.completion.GV > 0 and GAME.completion.VL > 0 end,
        credit = "@obsidian",
    },
    NHrAS = {
        name = "Pristine",
        desc = [[HFD with NH rAS]],
        quote = [[The pearl of your gameplay requires perfection for a clean finish.]],
        hide = function() return GAME.completion.AS > 0 end,
        credit = "@GameTilDead",
    },
    rDPrEX = {
        name = "Tyrannical Dyarchy",
        desc = [[HFD with rEX rDP]],
        quote = [[Live in fear and despair.]],
        hide = function() return GAME.completion.EX > 0 and GAME.completion.DP > 0 end,
        rank = floorRank(1, 2, 4, 6, 7, 8),
    },
    VLrDPrIN = {
        name = "Painful Relapse",
        desc = [[HFD with VL rIN rDP]],
        quote = [["I miss my ex..."]],
        hide = function() return GAME.completion.IN > 0 and GAME.completion.DP > 0 end,
        rank = floorRank(1, 2, 4, 5, 6, 7),
        credit = "@obsidian",
    },
    rDHrIN = {
        name = "Brain Capacity",
        desc = [[HFD with rDH rIN]],
        quote = [[How long can you keep up in this forsaken memory game?]],
        hide = function() return GAME.completion.DH > 0 and GAME.completion.IN > 0 end,
        rank = floorRank(1, 1, 2, 3, 4, 5),
        credit = "@GameTilDead",
    },
    DHEXrGV = {
        name = "Demonic Speed",
        desc = [[HFD with EX rGV DH]],
        quote = [[Prove your hellish capabilities to the world.]],
        hide = function() return GAME.completion.GV > 0 end,
        credit = "@GameTilDead",
    },
    DHGVVLrNH = {
        name = "Grand-Master! Rounds",
        desc = [[HFD with rNH GV VL DH]],
        quote = [[YOU AER GRAND-MASTER! ROUNDS]],
        hide = function() return GAME.completion.NH > 0 end,
        credit = "TGM4",
    },
    rINrNH = {
        name = "Instant Memory",
        desc = [[HFD with rNH rIN]],
        quote = [[In the twinkling of a eye.]],
        hide = function() return GAME.completion.NH > 0 and GAME.completion.IN > 0 end,
    },
    EXGVNHrMS = {
        name = "Bnuuy",
        desc = [[HFD with EX NH rMS GV]],
        quote = [[Look at them hopping around! Too bad they don't want to be picked up...]],
        hide = function() return GAME.completion.MS > 0 end,
        credit = "@GameTilDead",
    },
    rASrDH = {
        name = "Do I Have to Memorize All of Them?",
        desc = [[HFD with rDH rAS]],
        quote = [[Believe it or not, no.]],
        hide = function() return GAME.completion.DH > 0 and GAME.completion.AS > 0 end,
    },
    -- --['ASDHNHVLrGV']={
    --     name = "Stenography",
    --     desc = [[HFD with NH rGV VL DH AS]],
    --     quote = [["Let your plans be dark and impenetrable as night, and when you move, fall like a thunderbolt." - Sun Tzu, The Art of War]],
    --     hide = function() return GAME.completion.GV > 0 end,
    --     credit = "@obsidian",
    -- },

    -- Supercharged
    supercharged_plus = {
        name = "Supercharged+",
        desc = [[Highest Back-to-Back chain reached]],
        quote = [[Supercharged Any%]],
        scoreSimp = function(b2b) return b2b .. "x" end,
        scoreFull = NULL,
        rank = numberRank(0, 20, 40, 65, 85, 100),
    },
    clicker_speedrun = {
        name = "Clicker Speedrun",
        desc = [[Minimal time on 40 quests]],
        quote = [[Supercharged Q40%]],
        comp = '<',
        noScore = 1560,
    },
    perfect_speedrun = {
        name = "Perfect Speedrun",
        desc = [[Reach 75 Back-to-Back AFAP]],
        quote = [[Supercharged B75%]],
        comp = '<',
        noScore = 1560,
        scoreSimp = function(time) return string.format("%.2fs", time) end,
        scoreFull = NULL,
        -- rank = TODO,
    },
    the_perfectionist = {
        name = "The Perfectionist",
        desc = [[HFD with no imperfect pass or getting hurt]],
        quote = [[Supercharged Perf%]],
    },
    museum_heist = {
        name = "Museum Heist",
        desc = [[Shortest time spent in F5 with DH DP (20/12/6.2/2.6)]],
        quote = [[Less time, less evidence.]],
        comp = '<',
        noScore = 1560,
        scoreSimp = function(time) return string.format("%.2fs", time) end,
        scoreFull = NULL,
        -- rank = TODO,
    },
    ultra_dash = {
        name = "Ultra Dash",
        desc = [[Shortest time spent in F9 (26/16/12/6.2/4.2)]],
        quote = [[Probably a good strategy for speedrunning 1.2x faster.]],
        comp = '<',
        noScore = 1560,
        scoreSimp = function(time) return string.format("%.2fs", time) end,
        scoreFull = NULL,
        -- rank = TODO,
    },

    -- Others
    zenith_explorer_plus = {
        name = "Zenith Explorer+",
        desc = [[HFD]],
        quote = [[Uncover the mysteries of the Zenith Tower.]],
        credit = ""
    },
    zenith_speedrun_plus = {
        name = "Zenith Speedrun+",
        desc = [[Reach F10 AFAP while retaining GIGASPEED]],
        quote = [[F10 Any%]],
        comp = '<',
        noScore = 1560,
        scoreSimp = function(time) return string.format("%.2fs", time) end,
        scoreFull = NULL,
        -- rank = TODO,
    },
    zenith_challenger = {
        name = "Zenith Challenger",
        desc = [[Total best altitude with 1 mod enabled]],
        quote = [[Challenge the reality of the Zenith Tower.]],
        credit = "@5han",
        rank = (function()
            local l = { 0, 16000, 26000, 32000, 40000, 42000 }
            return function(h) return 5 * ilLerp(l, h) end
        end)(),
    },
    divine_challenger = {
        name = "Divine Challenger",
        desc = [[Total best altitude with 1 rev mod enabled]],
        quote = [[Expose the darkness of the Zenith Tower.]],
        hide = function() return TABLE.countAll(GAME.completion, 0) < 9 end,
        rank = (function()
            local l = { 0, 10000, 16000, 20000, 24000, 26000 }
            return function(h) return 5 * ilLerp(l, h) end
        end)(),
    },
    indolency = {
        name = "Indolency",
        desc = [[Highest attack total in F1 with rEX]],
        quote = [[Those glorious laurels, allowing you to stay where it's comfortable.]],
        credit = "@Flowerling",
        hide = function() return GAME.completion.EX > 0 end,
    },
    final_defiance = {
        name = "Final Defiance",
        desc = [[Meet the final fatigue effect]],
        quote = [["This is not the end!"]],
        -- TODO,
    },
    royal_resistance = {
        name = "Royal Resistance",
        desc = [[Meet the final fatigue effect with rEX]],
        quote = [["History will prove me right!!"]],
        hide = function() return GAME.completion.EX > 0 end,
        -- TODO,
    },
    fel_magic = {
        name = "Fel Magic",
        desc = [[Quest passed with wound triggered during GIGASPEED, with rAS]],
        quote = [["And what, Gul'dan, must we give it return?"]],
        credit = "WoW",
        hide = function() return GAME.completion.AS > 0 end,
        -- TODO,
    },
    -- the_pacifist = {
    --     name = "The Pacifist",
    --     desc = [[Minimum attack before reaching F10]],
    --     quote = [[Give evil nothing to oppose and it will disappear by itself.]],
    --     credit = "@wah",
    -- },
    multitasker = {
        name = "Multitasker",
        desc = [[Highest altitude*modPoints]],
        quote = [[Master doing everything, then master doing everything.]],
        credit = "@Flowerling",
        rank = (function()
            local l = { 0, 2600, 4200, 6200, 10000, 16200 }
            return function(zp) return 5 * ilLerp(l, zp) end
        end)(),
    },
    effective = {
        name = "Effective",
        desc = [[Highest altitude*ZPmul]],
        quote = [[Master doing everything efficiently.]],
        rank = (function()
            local l = { 0, 2600, 4200, 6200, 10000, 16200 }
            return function(zp) return 5 * ilLerp(l, zp) end
        end)(),
    },
    teraspeed = {
        name = "TeraSpeed",
        desc = [[Highest rank reached]],
        quote = [[Speed is the key.]],
        rank = numberRank(8, 12, 13, 14, 15, 16),
        scoreSimp = function(rank) return "Rank " .. rank end,
        scoreFull = NULL,
    },
    -- tailgater = {
    --     name = "Tailgater",
    --     desc = [[HFD without losing rank]],
    --     quote = [["I slow down for no one!"]],
    --     credit = "@Axye",
    -- },
    carried = {
        name = "Carried",
        desc = [[HFD with DP but only one player]],
        quote = [["I have no idea how to play the game, can you unlock the mods for me?"]],
        credit = "@obsidian",
    },
    honeymoon = {
        name = "Honeymoon",
        desc = [[HFD with every commit shares at least one mod with previous]],
        quote = [["Can we be together forever?"]],
        -- TODO
    },
    break_up = {
        name = "Break Up",
        desc = [[HFD without commiting any mod twice in a row]],
        quote = [["Never let me see you again."]],
        -- TODO
    },
    arrogance = {
        name = "Arrogance",
        desc = [[HFD with rAS and no perfect pass]],
        quote = [[Maintaining arrogance at all times is also not easy.]],
        hide = function() return GAME.completion.AS > 0 end,
    },
    -- the_pacifist_ii = {
    --     name = "The Pacifist II",
    --     desc = [[HFD without building up surge]],
    --     quote = [["We have a similar goal to climb the Zenith Tower in many ways."]],
    --     credit = "@cmdingo",
    -- },
    psychokinesis = {
        name = "Psychokinesis",
        desc = [[HFD with 0 flip count increasing in statistics]],
        quote = [[Real magic exists!]],
        rank = floorRank(1, 1, 1, 1, 2, 3),
    },
    divine_rejection = {
        name = "Divine Rejection",
        desc = [[Finish the run exactly before F10]],
        quote = [["And in the end, it doesn't even matter..."]],
        rank = numberRank(1626, 1645, 1649),
    },
    -- moon_struck = {
    --     name = "Moon Struck",
    --     desc = [[Finish the run at exactly 2202.8m (±10/±5/±2/±0.5/±0)]],
    --     quote = [[TODO]],
    --     credit = "@osk",
    -- },
    patience_is_a_virtue = {
        name = "Patience is a Virtue",
        desc = [[HFD without manually commit]],
        quote = [[Good things come to those who wait.]],
        credit = "@The_111thBlitzer",
        hide = function() return GAME.completion.GV > 0 end,
    },

    -- Issued, easy
    intended_glitch = {
        name = "Intended Glitch",
        desc = [[Play Duo]],
        quote = [[This is not a bug, it's a feature.]],
    },
    zenith_traveler = {
        name = "Zenith Traveler",
        desc = [[Enter traveler mode]],
        quote = [[Also known as background debugging mode]],
        hide = TRUE,
    },
    speedrun_speedruning = {
        hide = function() return GAME.completion.EX > 0 end,
        name = "Speedrun Speedruning",
        desc = [[Enter GIGASPEED on F1]],
        quote = [[Not much of a speedrun]],
    },
    fruitless_effort = {
        hide = function() return GAME.completion.EX > 0 end,
        name = "Fruitless Effort",
        desc = [[Finish a game with bonus over 260%]],
        quote = [[Effort is pointless if you are not strong enough.]],
    },
    worn_out = {
        name = "Worn Out",
        desc = [[Reach F10 in over 5 minutes while retaining GIGASPEED]],
        quote = [[You alright over there? You seem a bit tired from all that "speed "running...]],
        credit = "@GameTilDead",
    },
    identity = {
        name = "Identity",
        desc = [[Change ID or about-me]],
        quote = [[Is this free?]],
        hide = TRUE,
    },
    respectful = {
        name = "Respectful",
        desc = [[Stay in ABOUT page for 26s]],
        quote = [[Press F2 to pay respect]],
        credit = "COD11",
    },
    somersault = {
        name = "Somersault",
        desc = [[Rev animation ended at non-rev activated state]],
        quote = [[Elegant backflip]],
        hide = TRUE,
    },
    dark_force = {
        name = "Dark Force",
        desc = [[Interrupt font loading with rev mod]],
        quote = [[The darkness overflows]],
        hide = TRUE,
    },
    -- uninspired = {
    --     name = "Uninspired",
    --     desc = [[Consecutively restart 100 times]],
    --     quote = [[Without the will to even begin, how will you ever improve?]],
    --     credit = "@shig @Winterfrost",
    -- },
    and_then_nothing = {
        name = "And Then... Nothing",
        desc = [[Break b2b x 50 while one player is KO'd in rDP, and survived]],
        quote = [[Moral of the story: NEVER exploit your partner.]],
        hide = function() return GAME.completion.DP > 0 end,
        credit = "@GameTilDead",
    },
    zenith_relocation = {
        name = "Zenith Relocation",
        desc = [[Export your save to a different platform (Web / Windows / Linux)]],
        quote = [[Uncover the mysteries of a new, familiar Tower.]],
        credit = "@GameTilDead",
    },

    -- Issued, hard
    mastery = {
        name = "Mastery",
        desc = [[Mastery on all single mods]],
        quote = [[Game cleared, congratulations!]],
    },
    terminal_velocity = {
        name = "Terminal Velocity",
        desc = [[Speedrun all single mods]],
        quote = [[Reaching for the stars again and again.]],
        credit = "@The_111thBlitzer",
    },
    false_god = {
        name = "False God",
        desc = [[Mastery on all mods]],
        quote = [[Do it again but without clever tricks this time.]],
        hide = TRUE,
    },
    supremacy = {
        name = "Supremacy",
        desc = [[Mastery on all single rev mods]],
        quote = [[Your reign has begun, and it knows no end.]],
        hide = TRUE,
    },
    the_completionist = {
        name = "The Completionist",
        desc = [[Speedrun all single rev mods]],
        quote = [[The full spectrum of the mods now lies within your grasp.]],
        hide = TRUE,
    },
    skys_the_limit = {
        name = "Sky's The Limit",
        desc = [[Reach 6200m]],
        quote = [[Edge of the universe.]],
        hide = TRUE,
    },
    superluminal = {
        name = "Superluminal",
        desc = [[Reach F10 in 76.2s]],
        quote = [[Faster than light!]],
        hide = TRUE,
    },
}

local compFunc = {
    ['>'] = function(a, b) return a > b end,
    ['<'] = function(a, b) return a < b end,
}

for id, achv in next, Achievements do
    assert(achv.name, "Missing field 'name'", id)

    assert(achv.desc, "Missing field 'desc'", id)
    achv.desc = achv.desc:gsub("[A-Z][A-Z][A-Z][A-Z]?", {
        HFD = "Highest floor discovered",
        AFAP = "as fast as possible",
    })

    assert(achv.quote, "Missing field 'quote'", id)

    achv.credit = achv.credit or ""

    if achv.comp == nil then
        achv.comp = compFunc['>']
    elseif compFunc[achv.comp] then
        achv.comp = compFunc[achv.comp]
    elseif type(achv.comp) ~= 'function' then
        error("Invalid field 'comp'", id)
    end

    if achv.rank == nil then achv.rank = floorRank(1, 3, 5, 7, 9, 10) end
    assert(type(achv.rank) == 'function', "Invalid field 'rank'", id)

    achv.scoreSimp = achv.scoreSimp or heightFloor
    achv.scoreFull = achv.scoreFull or heightNumber

    achv.hide = achv.hide or FALSE
end
