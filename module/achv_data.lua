local floor = math.floor
local ilLerp = MATH.ilLerp
local function floorRank(l0, l1, l2, l3, l4, l5, l6)
    local l = {
        Floors[l0 - 1].top,
        Floors[l1 - 1].top,
        Floors[l2 - 1].top,
        Floors[l3 - 1].top,
        Floors[l4 - 1].top,
        Floors[l5 - 1].top,
        l6 <= 10 and Floors[l6 - 1].top or l6,
    }
    assert(#l == 7)
    return function(h) return 5.9999 * ilLerp(l, h) end
end
local function numberRank(...)
    local l = { ... }
    assert(#l == 7)
    return function(s) return 5.9999 * ilLerp(l, s) end
end
local function numberRankRev(...)
    local l = TABLE.reverse { ... }
    assert(#l == 7)
    return function(s) return 5.9999 * (1 - ilLerp(l, s)) end
end
local function heightFloor(h)
    for i = 9, 0, -1 do
        if h >= Floors[i].top then
            return "FLOOR " .. (i + 1)
        end
    end
end
local function heightNumber(score)
    return string.format("%.1fm", score)
end

---@class Achievement
---@field id string
---@field name string
---@field desc string
---@field quote string
---@field credit? string
---@field comp? '<' | '>' | fun(newScore, oldScore):boolean
---@field noScore? number
---@field scoreSimp? fun(score):string
---@field scoreFull? fun(score):string
---@field rank? 'floor' | fun(score):number
---@field type? 'competitive' | 'issued' | 'event'
---@field hide? fun():boolean

---@type Map<Achievement>
Achievements = {
    ---------------------------
    -- Original from TETR.IO --
    ---------------------------

    -- Single Mod
    {
        id = 'EX',
        name = "The Emperor",
        desc = [[HFD with the "Expert Mode" mod]],
        quote = [[A display of power for those willing to bear its burden.]],
        rank = floorRank(1, 3, 5, 7, 9, 10, 4200),
    },
    {
        id = 'NH',
        name = "Temperance",
        desc = [[HFD with the "No Hold" mod]],
        quote = [[Use each piece as they come and embrace the natural flow of stacking.]],
    },
    {
        id = 'MS',
        name = "Wheel of Fortune",
        desc = [[HFD with the "Messier Garbage" mod]],
        quote = [[The only constant in life is change.]],
        rank = floorRank(1, 3, 5, 7, 9, 10, 4200),
    },
    {
        id = 'GV',
        name = "The Tower",
        desc = [[HFD with the "Gravity" mod]],
        quote = [[What will you do when it all comes crumbling down?]],
    },
    {
        id = 'VL',
        name = "Strength",
        desc = [[HFD with the "Volatile Garbage" mod]],
        quote = [[Match great obstacles with greater determination.]],
    },
    {
        id = 'DH',
        name = "The Devil",
        desc = [[HFD with the "Double Hole" mod]],
        quote = [[Redifine your limits or succumb to his chains.]],
    },
    {
        id = 'IN',
        name = "The Hermit",
        desc = [[HFD with the "Invisible" mod]],
        quote = [[When the outside world fails you, trust the voice within to light a path.]],
    },
    {
        id = 'AS',
        name = "The Magician",
        desc = [[HFD with the "All-Spin" mod]],
        quote = [[Inspiration is nothing short of magic.]],
        rank = floorRank(1, 3, 5, 7, 9, 10, 7200),
    },
    {
        id = 'DP',
        name = "The Lovers",
        desc = [[HFD with the "Duo" mod]],
        quote = [[Love, and resign yourself to the fate of another.]],
    },
    {
        id = 'rEX',
        name = "The Tyrant",
        desc = [[HFD with the reversed "Expert Mode" mod]],
        quote = [[Fear, oppression, and limitless ambition.]],
        hide = function() return GAME.completion.EX == 0 end,
        rank = floorRank(1, 3, 5, 7, 9, 10, 2000),
    },
    {
        id = 'rNH',
        name = "Asceticism",
        desc = [[HFD with the reversed "No Hold" mod]],
        quote = [[A detachment from even that which is moderate.]],
        hide = function() return GAME.completion.NH == 0 end,
        rank = floorRank(1, 3, 5, 7, 9, 10, 2600),
    },
    {
        id = 'rMS',
        name = "Loaded Dice",
        desc = [[HFD with the reversed "Messier Garbage" mod]],
        quote = [[In a rigged game, your mind is the only fair advantage.]],
        hide = function() return GAME.completion.MS == 0 end,
        rank = floorRank(1, 3, 5, 7, 9, 10, 2600),
    },
    {
        id = 'rGV',
        name = "Freefall",
        desc = [[HFD with the reversed "Gravity" mod]],
        quote = [[In retrospect, the ground you stood on never existed in the first place.]],
        hide = function() return GAME.completion.GV == 0 end,
        rank = floorRank(1, 3, 5, 7, 9, 10, 4200),
    },
    {
        id = 'rVL',
        name = "Last Stand",
        desc = [[HFD with the reversed "Volatile Garbage" mod]],
        quote = [[Strength isn't necessary for those with nothing to lose.]],
        hide = function() return GAME.completion.VL == 0 end,
        rank = floorRank(1, 3, 5, 7, 9, 10, 4200),
    },
    {
        id = 'rDH',
        name = "Damnation",
        desc = [[HFD with the reversed "Double Hole" mod]],
        quote = [[No more second chances.]],
        hide = function() return GAME.completion.DH == 0 end,
        rank = floorRank(1, 3, 5, 7, 9, 10, 2600),
    },
    {
        id = 'rIN',
        name = "The Exile",
        desc = [[HFD with the reversed "Invisible" mod]],
        quote = [[Never underestimate blind faith.]],
        hide = function() return GAME.completion.IN == 0 end,
        rank = floorRank(1, 3, 5, 7, 9, 10, 2000),
    },
    {
        id = 'rAS',
        name = "The Warlock",
        desc = [[HFD with the reversed "All-Spin" mod]],
        quote = [[Into realms beyond heaven and earth.]],
        hide = function() return GAME.completion.AS == 0 end,
    },
    {
        id = 'rDP',
        name = "Bleeding Hearts",
        desc = [[HFD with the reversed "Duo" mod]],
        quote = [[Even as we bleed, we keep holding on...]],
        hide = function() return GAME.completion.DP == 0 end,
        rank = floorRank(1, 3, 5, 7, 9, 10, 2000),
    },

    -- Mod Combo
    {
        id = 'GVNH',
        name = "A Modern Classic",
        desc = [[HFDWUT "No Hold" and "Gravity" mods]],
        quote = [[Times were different back then...]],
        rank = floorRank(1, 3, 5, 7, 9, 10, 4200),
    },
    {
        id = 'DHMSNH',
        name = "Deadlock",
        desc = [[HFDWUT "No Hold", "Messier Garbage" and "Double Hole" mods]],
        quote = [["Escape has become a distant dream, yet still we struggle..."]],
        rank = floorRank(1, 3, 5, 7, 9, 10, 4200),
    },
    {
        id = 'ASDHMS',
        name = "The Escape Artist",
        desc = [[HFDWUT "Messier Garbage", "Double Hole" and "All-Spin" mods]],
        quote = [["An impossible situation! A daring illusionist! Will he make it out alive?"]],
        rank = floorRank(1, 3, 5, 7, 9, 10, 4200),
    },
    {
        id = 'GVIN',
        name = "The Grandmaster",
        desc = [[HFDWUT "Gravity" and "Invisible" mods]],
        quote = [[When the world descends into chaos, the grandmaster remains at peace.]],
        rank = floorRank(1, 3, 5, 7, 9, 10, 4200),
    },
    {
        id = 'DHEXNH',
        name = "Emperor's Decadence",
        desc = [[HFDWUT "Expert Mode", "No Hold" and "Double Hole" mods]],
        quote = [[The Devil's lesson in humility.]],
        rank = floorRank(1, 3, 5, 7, 9, 10, 2600),
    },
    {
        id = 'DHEXMSVL',
        name = "Divine Mastery",
        desc = [[HFDWUT "Expert Mode", "Messier Garbage", "Volatile Garbage" and "Double Hole" mods]],
        quote = [[The universe is yours.]],
        rank = floorRank(1, 3, 5, 7, 9, 10, 2600),
    },
    {
        id = 'ASNH',
        name = "The Starving Artist",
        desc = [[HFDWUT "No Hold" and "All-Spin" mods]],
        quote = [[Creativity cultivated trough limitation.]],
    },
    {
        id = 'ASEXVL',
        name = "The Con Artist",
        desc = [[HFDWUT "Expert Mode", "Volatile Garbage" and "All-Spin" mods]],
        quote = [[Would the perfect lie not be an art worthy of admiration ?]],
    },
    {
        id = 'DPEX',
        name = "Trained Professionals",
        desc = [[HFDWUT "Expert Mode" and "Duo" mods]],
        quote = [[Partners in expertise.]],
        rank = floorRank(1, 3, 5, 7, 9, 10, 4200),
    },
    {
        id = 'EXMS',
        name = "Block Rationing",
        desc = [[HFDWUT "Expert Mode" and "Messier Garbage" mods]],
        quote = [[Adversity favors the resourceful.]],
        rank = floorRank(1, 3, 5, 7, 9, 10, 2600),
    },
    {
        id = 'swamp_water_lite',
        name = "Swamp Water Lite",
        desc = [[HFDWUT all 7/8 of the difficulty mods ("Duo" not allowed)]],
        quote = [[Comes in 8 different flavors!]],
        rank = floorRank(1, 3, 5, 7, 9, 10, 2600),
    },
    {
        id = 'swamp_water',
        name = "Swamp Water",
        desc = [[HFDWUT all mods other than "Duo" at the same time]],
        quote = [[The worst of all worlds.]],
        rank = floorRank(1, 3, 5, 7, 9, 10, 2200),
    },

    -- General
    {
        id = 'zenith_explorer',
        name = "Zenith Explorer",
        desc = [[HFD without any mods]],
        quote = [[Uncover the mysteries of the Zenith Tower.]],
    },
    {
        id = 'zenith_speedrun',
        name = "Zenith Speedrun",
        desc = [[Reach F10 as fast as possible while retaining GIGASPEED without any mods]],
        quote = [[F10 Hyper%]],
        comp = '<',
        noScore = 2600,
        scoreSimp = function(time) return string.format("%.2fs", time) end,
        rank = numberRankRev(180, 120, 100, 90, 82.6, 76.2, 62.6),
    },
    {
        id = 'supercharged',
        name = "Supercharged",
        desc = [[Highest Back-to-Back chain reached without any mods]],
        quote = [["With this divine power, we'll be unstoppable!" -Mathis, Core Engineer]],
        scoreSimp = function(b2b) return "B2B x" .. b2b end,
        rank = numberRank(0, 20, 40, 65, 85, 100, 160),
    },
    {
        id = 'the_responsible_one',
        name = "The Responsible One",
        desc = [[Highest amount of revivals performed in a single duo run]],
        quote = [["Could you please stop dying?"]],
        scoreSimp = function(b2b) return b2b .. " Revives" end,
        rank = numberRank(0, 3, 6, 9, 12, 15, 18),
    },
    {
        id = 'guardian_angel',
        name = "Guardian Angel",
        desc = [[Highest altitude to perform a successful revive at]],
        quote = [[An angel's intervention.]],
        scoreSimp = heightNumber,
        rank = numberRank(0, 626, 942, 1620, 2600, 4200, 6200),
    },
    {
        id = 'talentless',
        name = "Talentless",
        desc = [[HFDWUT "All-Spin" mod without using keyboard]],
        quote = [[Reaching deep down but coming back empty every time.]],
        rank = floorRank(1, 3, 5, 7, 9, 10, 4200),
    },

    -- Others
    {
        id = 'lovers_promise',
        name = "Lover's Promise",
        desc = [[Highest altitude reached with DP on 14th day of a month]],
        quote = [[The impossible promise of an eternity just like this moment.]],
        scoreSimp = heightNumber,
        type = 'event',
    },
    {
        id = 'the_harbinger',
        name = "The Harbinger",
        desc = [[Reach floor 5 in all nine reversed mods]],
        quote = [[Weathering the storm of an unfavorable future.]],
        hide = TRUE,
        type = 'issued',
    },



    -----------------------------------------------
    -- Extended Achievements from Zenith Clicker --
    -----------------------------------------------

    -- Rev Swamp Water Series
    {
        id = 'blight',
        name = "Blight",
        desc = [[HFD with 8+ mod points]],
        quote = [[The world starts withering...]],
        rank = floorRank(1, 3, 5, 7, 9, 10, 4200),
        hide = function() return TABLE.countAll(GAME.completion, 0) > 7 end,
    },
    {
        id = 'desolation',
        name = "Desolation",
        desc = [[HFD with 9+ mod points]],
        quote = [[Vitality has faded from the world's palette...]],
        rank = floorRank(1, 3, 5, 7, 9, 10, 2600),
        hide = function() return TABLE.countAll(GAME.completion, 0) > 7 end,
    },
    {
        id = 'havoc',
        name = "Havoc",
        desc = [[HFD with 10+ mod points]],
        quote = [[The world is in chaos...]],
        rank = floorRank(1, 3, 5, 7, 8, 9, 10),
        hide = function() return TABLE.countAll(GAME.completion, 0) > 7 end,
    },
    {
        id = 'pandemonium',
        name = "Pandemonium",
        desc = [[HFD with 11+ mod points]],
        quote = [[Several realms began to collide...]],
        rank = floorRank(1, 2, 4, 6, 8, 9, 10),
        hide = function() return TABLE.countAll(GAME.completion, 0) > 7 end,
    },
    {
        id = 'inferno',
        name = "Inferno",
        desc = [[HFD with 12+ mod points]],
        quote = [[Everything is burning and melting...]],
        rank = floorRank(1, 2, 4, 6, 7, 8, 9),
        hide = function() return TABLE.countAll(GAME.completion, 0) > 6 end,
    },
    {
        id = 'purgatory',
        name = "Purgatory",
        desc = [[HFD with 13+ mod points]],
        quote = [[Nobody knows their destination...]],
        rank = floorRank(1, 1, 3, 5, 6, 7, 8),
        hide = function() return TABLE.countAll(GAME.completion, 0) > 5 end,
    },
    {
        id = 'perdition',
        name = "Perdition",
        desc = [[HFD with 14+ mod points]],
        quote = [[There's no way back...]],
        rank = floorRank(1, 1, 3, 4, 5, 6, 7),
        hide = function() return TABLE.countAll(GAME.completion, 0) > 4 end,
    },
    {
        id = 'cataclysm',
        name = "Cataclysm",
        desc = [[HFD with 15+ mod points]],
        quote = [[The real disaster is yet to come...]],
        rank = floorRank(1, 1, 2, 3, 4, 5, 6),
        hide = function() return TABLE.countAll(GAME.completion, 0) > 3 end,
    },
    {
        id = 'annihilation',
        name = "Annihilation",
        desc = [[HFD with 16+ mod points]],
        quote = [[The whole universe is trembling...]],
        rank = floorRank(1, 1, 1, 2, 3, 4, 5),
        hide = function() return TABLE.countAll(GAME.completion, 0) > 2 end,
    },
    {
        id = 'armageddon',
        name = "Armageddon",
        desc = [[HFD with 17+ mod points]],
        quote = [[Big crunch is about to happen...]],
        rank = floorRank(1, 1, 1, 1, 2, 3, 4),
        hide = function() return TABLE.countAll(GAME.completion, 0) > 1 end,
    },
    {
        id = 'abyss',
        name = "Abyss",
        desc = [[HFD with 18 mod points]],
        quote = [[.]],
        rank = floorRank(1, 1, 1, 1, 1, 2, 3),
        hide = function() return TABLE.countAll(GAME.completion, 0) > 0 end,
    },

    -- Swamp Water Extended
    {
        id = 'swamp_water_pro',
        name = "Swamp Water Pro",
        desc = [[HFDWUT all mods at the same time]],
        quote = [[How did you find someone as insane as you to do it together?]],
        rank = floorRank(1, 3, 5, 7, 9, 10, 2200),
        hide = function() return STAT.maxFloor >= 9 end,
    },
    {
        id = 'swamp_water_lite_plus',
        name = "Swamp Water Lite+",
        desc = [[HFDWUT 1rev+6 mods ("Duo" not allowed)]],
        quote = [[Comes in...... 252 different flavors?]],
        rank = floorRank(1, 3, 5, 7, 9, 10, 2200),
        hide = function() return TABLE.countAll(GAME.completion, 0) == 9 end,
    },
    {
        id = 'swamp_water_plus',
        name = "Swamp Water+",
        desc = [[HFDWUT 1rev+7 mods ("Duo" not allowed)]],
        quote = [[Less choices but still a lot to try.]],
        rank = floorRank(1, 3, 5, 7, 9, 10, 2000),
        hide = function() return TABLE.countAll(GAME.completion, 0) == 9 end,
    },
    {
        id = 'swamp_water_pro_plus',
        name = "Swamp Water Pro+",
        desc = [[HFDWUT 1rev+8 mods]],
        quote = [[The cup is about to overflow!]],
        rank = floorRank(1, 3, 5, 7, 9, 10, 2000),
        hide = function() return TABLE.countAll(GAME.completion, 0) == 9 end,
    },

    -- Mod Combo Extended
    {
        id = 'ASDPNHVL',
        name = "Midnight Meal",
        desc = [[HFDWUT NH VL AS DP mods]],
        quote = [[You came to eat up these mods, so you'd best be hungry.]],
        credit = "@GameTilDead",
    },
    {
        id = 'rGVrNHrVL',
        name = "Sweatshop",
        desc = [[HFDWUT rNH rGV rVL mods]],
        quote = [[Carefree life is not for the asking, someone else is carrying the burden for you.]],
        credit = "@obsidian",
        rank = floorRank(1, 3, 5, 7, 9, 10, 2200),
        hide = function() return GAME.completion.NH == 0 or GAME.completion.GV == 0 or GAME.completion.VL == 0 end,
    },
    {
        id = 'NHrAS',
        name = "Pristine",
        desc = [[HFDWUT NH rAS mods]],
        quote = [[The pearl of your gameplay requires perfection for a clean finish.]],
        credit = "@GameTilDead",
        rank = floorRank(1, 3, 5, 7, 9, 10, 2600),
        hide = function() return GAME.completion.AS == 0 end,
    },
    {
        id = 'rDPrEX',
        name = "Tyrannical Dyarchy",
        desc = [[HFDWUT rEX rDP mods]],
        quote = [[Live in fear and despair.]],
        rank = floorRank(1, 2, 3, 4, 6, 7, 8),
        hide = function() return GAME.completion.EX == 0 or GAME.completion.DP == 0 end,
    },
    {
        id = 'VLrDPrIN',
        name = "Painful Relapse",
        desc = [[HFDWUT VL rIN rDP mods]],
        quote = [["I miss my ex..."]],
        credit = "@obsidian",
        rank = floorRank(1, 2, 3, 4, 5, 6, 7),
        hide = function() return GAME.completion.IN == 0 or GAME.completion.DP == 0 end,
    },
    {
        id = 'rDHrIN',
        name = "Brain Capacity",
        desc = [[HFDWUT rDH rIN mods]],
        quote = [[How long can you keep up in this forsaken memory game?]],
        credit = "@GameTilDead",
        rank = floorRank(1, 1, 2, 3, 4, 5, 6),
        hide = function() return GAME.completion.DH == 0 or GAME.completion.IN == 0 end,
    },
    {
        id = 'DHEXrGV',
        name = "Demonic Speed",
        desc = [[HFDWUT EX rGV DH mods]],
        quote = [[Prove your hellish capabilities to the world.]],
        credit = "@GameTilDead",
        rank = floorRank(1, 3, 5, 7, 9, 10, 4200),
        hide = function() return GAME.completion.GV == 0 end,
    },
    {
        id = 'DPGVMSrNH',
        name = "Grand-Master! Rounds",
        desc = [[HFDWUT rNH MS GV DP mods]],
        quote = [[YOUR AER: GRAND-MASTER! Rounds]],
        -- credit = "TGM4",
        rank = floorRank(1, 3, 5, 7, 9, 10, 2000),
        hide = function() return GAME.completion.NH == 0 end,
    },
    {
        id = 'rINrNH',
        name = "Instant Memory",
        desc = [[HFDWUT rNH rIN mods]],
        quote = [[In the twinkling of a eye.]],
        rank = floorRank(1, 3, 5, 7, 9, 10, 2000),
        hide = function() return GAME.completion.NH == 0 or GAME.completion.IN == 0 end,
    },
    {
        id = 'EXGVNHrMS',
        name = "Bnuuy",
        desc = [[HFDWUT EX NH rMS GV mods]],
        quote = [[Look at them hopping around! Too bad they don't want to be picked up...]],
        credit = "@GameTilDead",
        rank = floorRank(1, 3, 5, 7, 9, 10, 2000),
        hide = function() return GAME.completion.MS == 0 end,
    },
    {
        id = 'rASrDH',
        name = "Do I Have to Memorize All of Them?",
        desc = [[HFDWUT GV rDH rAS mods]],
        quote = [[Believe it or not, no.]],
        rank = floorRank(1, 3, 5, 7, 9, 10, 2600),
        hide = function() return GAME.completion.DH == 0 or GAME.completion.AS == 0 end,
    },
    {
        id = 'DHNHrASrIN',
        name = "Steganography",
        desc = [[HFDWUT NH DH rIN rAS mods]],
        quote = [[Sometimes, the best hiding place is in plain sight.]],
        credit = "@obsidian",
        rank = floorRank(1, 3, 5, 7, 9, 10, 2600),
        hide = function() return GAME.completion.IN == 0 or GAME.completion.AS == 0 end,
    },
    {
        id = 'rGVrAS',
        name = "Whizzing Wizard",
        desc = [[HFDWUT rGV rAS mods]],
        quote = [["I felt enchanted!"  But soon after, disaster struck...]],
        credit = "@GameTilDead",
        rank = floorRank(1, 3, 5, 7, 9, 10, 2600),
        hide = function() return GAME.completion.GV == 0 or GAME.completion.AS == 0 end,
    },

    -- Supercharged
    {
        id = 'supercharged_plus',
        name = "Supercharged+",
        desc = [[Highest Back-to-Back chain reached]],
        quote = [[Supercharged Any%]],
        scoreSimp = function(b2b) return "B2B x" .. b2b end,
        rank = numberRank(0, 20, 40, 65, 85, 100, 180),
    },
    {
        id = 'clicker_speedrun',
        name = "Clicker Speedrun",
        desc = [[Minimal time on 40 quests without any mods]],
        quote = [[Supercharged Q40%]],
        comp = '<',
        noScore = 2600,
        scoreSimp = function(time) return string.format("%.2fs", time) end,
        rank = numberRankRev(94.2, 72, 55, 42, 33, 26, 20),
    },
    {
        id = 'typer_speedrun',
        name = "Typer Speedrun",
        desc = [[Minimal time on 40 quests]],
        quote = [[Supercharged AnyQ40%]],
        comp = '<',
        noScore = 2600,
        scoreSimp = function(time) return string.format("%.2fs", time) end,
        rank = numberRankRev(72, 55, 42, 33, 26, 22, 19),
    },
    {
        id = 'perfect_speedrun',
        name = "Perfect Speedrun",
        desc = [[Reach 75 Back-to-Back as fast as possible]],
        quote = [[Supercharged B75%]],
        comp = '<',
        noScore = 2600,
        scoreSimp = function(time) return string.format("%.2fs", time) end,
        rank = numberRankRev(150, 115, 90, 70, 55, 45, 40),
    },
    {
        id = 'the_perfectionist',
        name = "The Perfectionist",
        desc = [[HFD with no imperfect pass or getting hurt]],
        quote = [[Supercharged Perf%]],
        rank = floorRank(1, 3, 5, 7, 9, 10, 2600),
    },
    {
        id = 'museum_heist',
        name = "Museum Heist",
        desc = [[Shortest time spent in F5 with DH DP]],
        quote = [[Less time, less evidence.]],
        comp = '<',
        noScore = 2600,
        scoreSimp = function(time) return string.format("%.2fs", time) end,
        rank = numberRankRev(35, 26, 20, 12, 6.2, 4.2, 2.6),
    },
    {
        id = 'ultra_dash',
        name = "Ultra Dash",
        desc = [[Shortest time spent in F9]],
        quote = [[Probably a good strategy for speedrunning 1.2x faster.]],
        comp = '<',
        noScore = 2600,
        scoreSimp = function(time) return string.format("%.2fs", time) end,
        rank = numberRankRev(62, 26, 16, 12, 6.2, 4.2, 2.6),
    },

    -- Others
    {
        id = 'zenith_explorer_plus',
        name = "Zenith Explorer+",
        desc = [[HFD]],
        quote = [[Uncover the mysteries of the Zenith Tower.]],
        rank = floorRank(1, 3, 5, 7, 9, 10, 8000),
    },
    {
        id = 'zenith_speedrun_plus',
        name = "Zenith Speedrun+",
        desc = [[Reach F10 as fast as possible while retaining GIGASPEED]],
        quote = [[F10 Any%]],
        comp = '<',
        noScore = 2600,
        scoreSimp = function(time) return string.format("%.2fs", time) end,
        rank = numberRankRev(180, 120, 100, 90, 82.6, 76.2, 56.7),
    },
    {
        id = 'zenith_challenger',
        name = "Zenith Challenger",
        desc = [[Total best altitude with 1 mod enabled]],
        quote = [[Challenge the reality of the Zenith Tower.]],
        credit = "@5han",
        rank = numberRank(0, 14000, 26000, 36000, 42000, 46000, 60000),
        scoreSimp = function(h) return string.format("%.0fm", h) end,
    },
    {
        id = 'divine_challenger',
        name = "Divine Challenger",
        desc = [[Total best altitude with 1 rev mod enabled]],
        quote = [[Expose the darkness of the Zenith Tower.]],
        rank = numberRank(0, 10000, 16000, 20000, 24000, 26000, 30000),
        scoreSimp = function(h) return string.format("%.0fm", h) end,
        hide = function() return TABLE.countAll(GAME.completion, 0) > 0 end,
    },
    {
        id = 'fel_magic',
        name = "Fel Magic",
        desc = [[Quest passed with wound triggered during GIGASPEED, with rAS]],
        quote = [["And what, Gul'dan, must we give it return?"]],
        -- credit = "WoW",
        rank = numberRank(0, 6, 15, 26, 42, 62, 100),
        scoreSimp = function(rank) return floor(rank) .. " Quests" end,
        hide = function() return GAME.completion.AS == 0 end,
    },
    -- {
    --     id = 'the_pacifist',
    --     name = "The Pacifist",
    --     desc = [[Minimum attack before reaching F10]],
    --     quote = [[Give evil nothing to oppose and it will disappear by itself.]],
    --     rank = numberRankRev(2600,600,550,500,470,440,420,400),
    --     scoreSimp = function(atk) return atk .. " Attack" end,
    --     comp = '<',
    --     noScore = 2600,
    --     credit = "@wah",
    -- },
    {
        id = 'multitasker',
        name = "Multitasker",
        desc = [[Highest altitude*modPoints]],
        quote = [[Master doing everything, then master doing everything.]],
        credit = "@Flowerling",
        rank = numberRank(0, 2600, 4200, 6200, 10000, 16200, 26000),
        scoreSimp = function(rank) return floor(rank) .. "m·MP" end,
    },
    {
        id = 'effective',
        name = "Effective",
        desc = [[Highest altitude*ZPmul]],
        quote = [[Master doing everything efficiently.]],
        rank = numberRank(0, 2600, 4200, 6200, 10000, 12600, 16200),
        scoreSimp = function(rank) return floor(rank) .. " ZP" end,
    },
    {
        id = 'teraspeed',
        name = "TeraSpeed",
        desc = [[Highest rank reached]],
        quote = [[Speed is the key.]],
        rank = numberRank(13, 14, 15, 16, 17, 18, 20),
        scoreSimp = function(rank) return "Rank " .. rank end,
    },
    {
        id = 'sunk_cost',
        name = "Sunk Cost",
        desc = [[HFD without losing rank]],
        quote = [["Cross the line, and the descent begins."]],
        rank = floorRank(1, 3, 5, 7, 9, 10, 2600),
    },
    {
        id = 'knife_edge',
        name = "Knife-edge",
        desc = [[HFD without losing rank, with at least EX]],
        quote = [[A delicate dance on the cutting edge.]],
        rank = floorRank(1, 3, 5, 7, 9, 10, 2000),
    },
    {
        id = 'carried',
        name = "Carried",
        desc = [[HFD with only one player passing quests, with at least DP]],
        quote = [["I have no idea how to play the game, can you unlock the mods for me?"]],
        credit = "@obsidian",
        rank = floorRank(1, 3, 5, 7, 9, 10, 2000),
    },
    -- {
    --     id = 'honeymoon',
    --     name = "Honeymoon",
    --     desc = [[HFD with every commit shares at least one mod with previous]],
    --     quote = [["Can we be together forever?"]],
    --     -- TODO
    -- },
    -- {
    --     id = 'break_up',
    --     name = "Break Up",
    --     desc = [[HFD without commiting any mod twice in a row]],
    --     quote = [["Never let me see you again."]],
    --     -- TODO
    -- },
    {
        id = 'arrogance',
        name = "Arrogance",
        desc = [[HFD with rAS and no perfect pass]],
        quote = [[Maintaining arrogance constantly is also not easy.]],
        rank = floorRank(1, 1, 1, 1, 2, 3, 4),
        hide = function() return GAME.completion.AS == 0 end,
    },
    -- {
    --     id = 'powerless',
    --     name = "Powerless",
    --     desc = [[HFD without building up surge]],
    --     quote = [["We have a similar goal to climb the Zenith Tower in many ways."]],
    --     rank = floorRank(1, 3, 5, 7, 9, 10, 2200),
    --     credit = "@cmdingo",
    -- },
    {
        id = 'psychokinesis',
        name = "Psychokinesis",
        desc = [[HFD with 0 flip count increasing in statistics]],
        quote = [[Real magic exists!]],
        rank = floorRank(1, 1, 1, 1, 2, 3, 5),
    },
    {
        id = 'divine_rejection',
        name = "Divine Rejection",
        desc = [[Finish the run exactly before F10]],
        quote = [["And in the end, it doesn't even matter..."]],
        rank = numberRank(1626, 1626, 1635, 1640, 1645, 1647.8, 1649),
    },
    -- {
    --     id = 'moon_struck',
    --     name = "Moon Struck",
    --     desc = [[Finish the run at exactly 2202.8m (±3/±1/±0)]],
    --     quote = [[TODO]],
    --     scoreSimp = heightNumber,
    --     rank = ...,
    --     credit = "@osk",
    -- },
    {
        id = 'patience_is_a_virtue',
        name = "Patience is a Virtue",
        desc = [[HFD without manually commit]],
        quote = [[Good things come to those who wait.]],
        credit = "@The_111thBlitzer",
        rank = floorRank(1, 3, 5, 7, 9, 10, 2200),
        hide = function() return GAME.completion.GV == 0 end,
    },

    -- Issued, easy
    -- {
    --     id = 'uninspired',
    --     name = "Uninspired",
    --     desc = [[Consecutively restart 100 times]],
    --     quote = [[Without the will to even begin, how will you ever improve?]],
    --     credit = "@shig @Winterfrost",
    --     type = 'issued',
    -- },
    {
        id = 'identity',
        name = "Identity",
        desc = [[Change ID or about-me]],
        quote = [[Is this free?]],
        type = 'issued',
    },
    {
        id = 'zenith_relocation',
        name = "Zenith Relocation",
        desc = [[Export your save to a different platform (Web / Windows / Linux)]],
        quote = [[Uncover the mysteries of a new, familiar Tower.]],
        credit = "@GameTilDead",
        type = 'issued',
    },
    {
        id = 'respectful',
        name = "Respectful",
        desc = [[Stay in ABOUT page for 26s]],
        quote = [[Press F2 to pay respect]],
        -- credit = "COD11",
        type = 'issued',
    },
    {
        id = 'intended_glitch',
        name = "Intended Glitch",
        desc = [[Play Duo]],
        quote = [[This is not a bug, it's a feature.]],
        type = 'issued',
    },
    {
        id = 'zenith_traveler',
        name = "Zenith Traveler",
        desc = [[Enter traveler mode]],
        quote = [[Also known as background debugging mode]],
        type = 'issued',
    },
    {
        id = 'worn_out',
        name = "Worn Out",
        desc = [[Reach F10 in over 5 minutes while retaining GIGASPEED]],
        quote = [[You alright over there? You seem a bit tired from all that "speed"-running...]],
        credit = "@GameTilDead",
        type = 'issued',
    },
    {
        id = 'somersault',
        name = "Somersault",
        desc = [[Rev animation ended at non-rev activated state]],
        quote = [[Elegant backflip]],
        hide = TRUE,
        type = 'issued',
    },
    {
        id = 'dark_force',
        name = "Dark Force",
        desc = [[Interrupt font loading with rev mod]],
        quote = [[The darkness overflows.]],
        hide = TRUE,
        type = 'issued',
    },
    {
        id = 'speedrun_speedruning',
        name = "Speedrun Speedruning",
        desc = [[Enter GIGASPEED on F1]],
        quote = [[Not much of a speedrun]],
        hide = function() return GAME.completion.EX == 0 end,
        type = 'issued',
    },
    {
        id = 'fruitless_effort',
        name = "Fruitless Effort",
        desc = [[Finish a game with bonus over 260%]],
        quote = [[Effort is pointless if you are not strong enough.]],
        hide = function() return GAME.completion.EX == 0 end,
        type = 'issued',
    },
    {
        id = 'and_then_nothing',
        name = "And Then... Nothing",
        desc = [[Break B2B x 50 while one player is KO'd in rDP, and survived]],
        quote = [[Moral of the story: NEVER exploit your partner.]],
        credit = "@GameTilDead",
        hide = function() return GAME.completion.DP == 0 end,
        type = 'issued',
    },

    -- Issued, hard
    {
        id = 'skys_the_limit',
        name = "Sky's The Limit",
        desc = [[Reach 6200m]],
        quote = [[Edge of the universe.]],
        type = 'issued',
    },
    {
        id = 'superluminal',
        name = "Superluminal",
        desc = [[Reach F10 in 76.2s]],
        quote = [[Faster than light!]],
        type = 'issued',
    },
    {
        id = 'mastery',
        name = "Mastery",
        desc = [[Mastery on all single mods]],
        quote = [[Game cleared, congratulations!]],
        type = 'issued',
    },
    {
        id = 'terminal_velocity',
        name = "Terminal Velocity",
        desc = [[Speedrun all single mods]],
        quote = [[Reaching for the stars again and again.]],
        credit = "@The_111thBlitzer",
        type = 'issued',
    },
    {
        id = 'final_defiance',
        name = "Final Defiance",
        desc = [[Meet the final fatigue effect]],
        quote = [["This is not the end!"]],
        type = 'issued',
    },
    {
        id = 'royal_resistance',
        name = "Royal Resistance",
        desc = [[Meet the final fatigue effect with rEX]],
        quote = [["History will prove me right!!"]],
        hide = function() return GAME.completion.EX == 0 end,
        type = 'issued',
    },
    {
        id = 'lovers_stand',
        name = "Lover's Stand",
        desc = [[Meet the final fatigue effect with rDP]],
        quote = [[The power of affection sees you through the bitter end.]],
        hide = function() return GAME.completion.DP == 0 end,
        type = 'issued',
    },
    {
        id = 'false_god',
        name = "False God",
        desc = [[Mastery on all mods]],
        quote = [[Do it again but without clever tricks this time.]],
        type = 'issued',
        hide = TRUE,
    },
    {
        id = 'supremacy',
        name = "Supremacy",
        desc = [[Mastery on all single rev mods]],
        quote = [[Your reign has begun, and it knows no end.]],
        type = 'issued',
        hide = TRUE,
    },
    {
        id = 'the_completionist',
        name = "The Completionist",
        desc = [[Speedrun all single rev mods]],
        quote = [[The full spectrum of the mods now lies within your grasp.]],
        type = 'issued',
        hide = TRUE,
    },
}

local compFunc = {
    ['>'] = function(a, b) return a - b > 1e-10 end,
    ['<'] = function(a, b) return b - a > 1e-10 end,
}
local defaultFloorRank = floorRank(1, 3, 5, 7, 9, 10, 6200)

for i = 1, #Achievements do
    local achv = Achievements[i]
    local id = achv.id
    Achievements[id] = achv

    assert(type(id) == 'string', "Missing field 'name' - " .. id)
    assert(type(achv.name) == 'string', "Missing field 'name' - " .. id)

    assert(achv.desc, "Missing field 'desc' - " .. id)
    achv.desc = achv.desc
        :gsub("HFDWUT", "Highest floor discovered while using the")
        :gsub("HFD", "Highest floor discovered")

    assert(achv.quote, "Missing field 'quote' - " .. id)

    achv.credit = achv.credit or ""

    if achv.comp == nil then
        achv.comp = compFunc['>']
    elseif compFunc[achv.comp] then
        achv.comp = compFunc[achv.comp]
    elseif type(achv.comp) ~= 'function' then
        error("Invalid field 'comp' - " .. id)
    end

    if achv.rank == nil then achv.rank = defaultFloorRank end
    assert(type(achv.rank) == 'function', "Invalid field 'rank' - " .. id)

    if achv.scoreSimp == nil then
        achv.scoreSimp = heightFloor
        achv.scoreFull = heightNumber
    end
    assert(type(achv.scoreSimp) == 'function', "Invalid field 'scoreSimp' - " .. id)
    assert(achv.scoreFull == nil or type(achv.scoreFull) == 'function', "Invalid field 'scoreFull' - " .. id)

    if achv.type == nil then achv.type = 'competitive' end
    assert(type(achv.type) == 'string', "Invalid field 'type' - " .. id)

    achv.hide = achv.hide or FALSE
end
