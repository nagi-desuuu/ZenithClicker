local min, floor = math.min, math.floor
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
    return function(h) return min(6 * ilLerp(l, h), 5.9999) end
end
local function numberRank(...)
    local l = { ... }
    assert(#l == 7)
    return function(s) return min(6 * ilLerp(l, s), 5.9999) end
end
local function numberRankRev(...)
    local l = TABLE.reverse { ... }
    assert(#l == 7)
    return function(s) return min(6 * (1 - ilLerp(l, s)), 5.9999) end
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
---@field title? string
---@field ex? true Extended by Zenith Clicker
---@field id? string
---@field name? string
---@field desc? string
---@field quote? string
---@field credit? string
---@field comp? '<' | '>' | fun(newScore, oldScore):boolean
---@field noScore? number
---@field scoreSimp? fun(score):string
---@field scoreFull? fun(score):string
---@field rank? 'floor' | fun(score):number
---@field type? 'competitive' | 'issued' | 'event'
---@field hide? fun():boolean
---@field notUsed? true

---@type Map<Achievement>
Achievements = {
    { title = "General", quote = [[禁忌「クランベリートラップ」]] }, -- placeholder
    { quote = [[禁忌「レーヴァテイン」]] }, -- placeholder
    { -- zenith_explorer
        id = 'zenith_explorer',
        name = "Zenith Explorer",
        desc = [[HFD without any mods]],
        quote = [[Uncover the mysteries of the Zenith Tower.]],
    },
    { -- zenith_speedrun
        id = 'zenith_speedrun',
        name = "Zenith Speedrun",
        desc = [[Reach F10 as fast as possible while retaining GIGASPEED without any mods]],
        quote = [[F10 Hyper%]],
        comp = '<',
        noScore = 2600,
        scoreSimp = function(time) return string.format("%.2fs", time) end,
        rank = numberRankRev(180, 120, 100, 90, 82.6, 76.2, 62.6),
        hide = function() return STAT.totalGiga == 0 end,
    },
    { -- zenith_explorer_plus
        ex = true,
        id = 'zenith_explorer_plus',
        name = "Zenith Explorer+",
        desc = [[HFD]],
        quote = [[Uncover the mysteries of the Zenith Tower.]],
        rank = floorRank(1, 3, 5, 7, 9, 10, 8000),
    },
    { -- zenith_speedrun_plus
        ex = true,
        id = 'zenith_speedrun_plus',
        name = "Zenith Speedrun+",
        desc = [[Reach F10 as fast as possible while retaining GIGASPEED]],
        quote = [[F10 Any%]],
        comp = '<',
        noScore = 2600,
        scoreSimp = function(time) return string.format("%.2fs", time) end,
        rank = numberRankRev(180, 120, 100, 90, 82.6, 76.2, 56.7),
        hide = function() return STAT.totalGiga == 0 end,
    },
    { -- zenith_challenger
        ex = true,
        id = 'zenith_challenger',
        name = "Zenith Challenger",
        desc = [[Total best altitude with 1 mod enabled]],
        quote = [[Challenge the reality of the Zenith Tower.]],
        credit = "@5han",
        rank = numberRank(0, 14000, 26000, 36000, 42000, 46000, 60000),
        scoreSimp = function(h) return string.format("%.0fm", h) end,
        hide = TRUE,
    },
    { -- zenith_speedrunner
        ex = true,
        id = 'zenith_speedrunner',
        name = "Zenith Speedrunner",
        desc = [[Sum of best F10 time with GIGASPEED using each mod]],
        quote = [[F10 All%]],
        comp = '<',
        noScore = 2600,
        scoreSimp = function(time) return string.format("%.2fs", time) end,
        rank = numberRankRev(2600, 2000, 1500, 1260, 1100, 1000, 900),
        hide = function() return STAT.totalGiga == 0 end,
    },
    { -- supercharged
        id = 'supercharged',
        name = "Supercharged",
        desc = [[Highest Back-to-Back chain reached without any mods]],
        quote = [["With this divine power, we'll be unstoppable!" -Mathis, Core Engineer]],
        scoreSimp = function(b2b) return "B2B x" .. b2b end,
        rank = numberRank(0, 20, 40, 65, 90, 120, 180),
    },
    { -- clicker_speedrun
        ex = true,
        id = 'clicker_speedrun',
        name = "Clicker Speedrun",
        desc = [[Minimal time on 40 quests without any mods]],
        quote = [[Supercharged Q40%]],
        comp = '<',
        noScore = 2600,
        scoreSimp = function(time) return string.format("%.2fs", time) end,
        rank = numberRankRev(94.2, 72, 55, 42, 33, 26, 20),
    },
    { -- supercharged_plus
        ex = true,
        id = 'supercharged_plus',
        name = "Supercharged+",
        desc = [[Highest Back-to-Back chain reached]],
        quote = [[Supercharged Any%]],
        scoreSimp = function(b2b) return "B2B x" .. b2b end,
        rank = numberRank(0, 20, 40, 65, 90, 120, 180),
    },
    { -- typer_speedrun
        ex = true,
        id = 'typer_speedrun',
        name = "Typer Speedrun",
        desc = [[Minimal time on 40 quests]],
        quote = [[Supercharged AnyQ40%]],
        comp = '<',
        noScore = 2600,
        scoreSimp = function(time) return string.format("%.2fs", time) end,
        rank = numberRankRev(72, 55, 42, 33, 26, 22, 19),
    },
    { -- multitasker
        ex = true,
        id = 'multitasker',
        name = "Multitasker",
        desc = [[Highest altitude*modPoints]],
        quote = [[Master doing everything, then master doing everything.]],
        credit = "@Flowerling",
        rank = numberRank(0, 4200, 6200, 9420, 12600, 16200, 26000),
        scoreSimp = function(rank) return floor(rank) .. "m·MP" end,
        hide = TRUE,
    },
    { -- effective
        ex = true,
        id = 'effective',
        name = "Effective",
        desc = [[Highest altitude*ZPmul]],
        quote = [[Master doing everything efficiently.]],
        rank = numberRank(0, 2600, 4200, 6200, 10000, 12600, 16200),
        scoreSimp = function(rank) return floor(rank) .. " ZP" end,
        hide = TRUE,
    },

    { title = "Mods", quote = [[禁忌「フォーオブアカインド」]] }, -- placeholder
    { quote = [[禁忌「カゴメカゴメ」]] }, -- placeholder
    { -- EX
        id = 'EX',
        name = "The Emperor",
        desc = [[HFD with the "Expert Mode" mod]],
        quote = [[A display of power for those willing to bear its burden.]],
        rank = floorRank(1, 3, 5, 7, 9, 10, 4200),
        hide = function() return STAT.maxFloor < 9 end,
    },
    { -- NH
        id = 'NH',
        name = "Temperance",
        desc = [[HFD with the "No Hold" mod]],
        quote = [[Use each piece as they come and embrace the natural flow of stacking.]],
        hide = function() return STAT.maxFloor < 2 end,
    },
    { -- MS
        id = 'MS',
        name = "Wheel of Fortune",
        desc = [[HFD with the "Messier Garbage" mod]],
        quote = [[The only constant in life is change.]],
        rank = floorRank(1, 3, 5, 7, 9, 10, 4200),
        hide = function() return STAT.maxFloor < 3 end,
    },
    { -- GV
        id = 'GV',
        name = "The Tower",
        desc = [[HFD with the "Gravity" mod]],
        quote = [[What will you do when it all comes crumbling down?]],
        hide = function() return STAT.maxFloor < 4 end,
    },
    { -- VL
        id = 'VL',
        name = "Strength",
        desc = [[HFD with the "Volatile Garbage" mod]],
        quote = [[Match great obstacles with greater determination.]],
        hide = function() return STAT.maxFloor < 5 end,
    },
    { -- DH
        id = 'DH',
        name = "The Devil",
        desc = [[HFD with the "Double Hole" mod]],
        quote = [[Redifine your limits or succumb to his chains.]],
        hide = function() return STAT.maxFloor < 6 end,
    },
    { -- IN
        id = 'IN',
        name = "The Hermit",
        desc = [[HFD with the "Invisible" mod]],
        quote = [[When the outside world fails you, trust the voice within to light a path.]],
        hide = function() return STAT.maxFloor < 7 end,
    },
    { -- AS
        id = 'AS',
        name = "The Magician",
        desc = [[HFD with the "All-Spin" mod]],
        quote = [[Inspiration is nothing short of magic.]],
        rank = floorRank(1, 3, 5, 7, 9, 10, 7200),
        hide = function() return STAT.maxFloor < 8 end,
    },
    { -- DP
        id = 'DP',
        name = "The Lovers",
        desc = [[HFD with the "Duo" mod]],
        quote = [[Love, and resign yourself to the fate of another.]],
        hide = function() return STAT.maxFloor < 8 end,
    },
    { -- GVIN
        id = 'GVIN',
        name = "The Grandmaster",
        desc = [[HFD WUT "Gravity" and "Invisible" mods]],
        quote = [[When the world descends into chaos, the grandmaster remains at peace.]],
        hide = function() return STAT.maxFloor < 7 end,
    },
    { -- ASNH
        id = 'ASNH',
        name = "The Starving Artist",
        desc = [[HFD WUT "No Hold" and "All-Spin" mods]],
        quote = [[Creativity cultivated trough limitation.]],
        hide = function() return STAT.maxFloor < 8 end,
    },
    { -- DPEX
        id = 'DPEX',
        name = "Trained Professionals",
        desc = [[HFD WUT "Expert Mode" and "Duo" mods]],
        quote = [[Partners in expertise.]],
        rank = floorRank(1, 3, 5, 7, 9, 10, 4200),
        hide = function() return STAT.maxFloor < 9 end,
    },
    { -- GVNH
        id = 'GVNH',
        name = "A Modern Classic",
        desc = [[HFD WUT "No Hold" and "Gravity" mods]],
        quote = [[Times were different back then...]],
        rank = floorRank(1, 3, 5, 7, 9, 10, 4200),
        hide = function() return STAT.maxFloor < 4 end,
    },
    { -- DHMSNH
        id = 'DHMSNH',
        name = "Deadlock",
        desc = [[HFD WUT "No Hold", "Messier Garbage" and "Double Hole" mods]],
        quote = [["Escape has become a distant dream, yet still we struggle..."]],
        rank = floorRank(1, 3, 5, 7, 9, 10, 2600),
        hide = function() return STAT.maxFloor < 6 end,
    },
    { -- DHEXNH
        id = 'DHEXNH',
        name = "Emperor's Decadence",
        desc = [[HFD WUT "Expert Mode", "No Hold" and "Double Hole" mods]],
        quote = [[The Devil's lesson in humility.]],
        rank = floorRank(1, 3, 5, 7, 9, 10, 2600),
        hide = function() return STAT.maxFloor < 9 end,
    },
    { -- DHEXMSVL
        id = 'DHEXMSVL',
        name = "Divine Mastery",
        desc = [[HFD WUT "Expert Mode", "Messier Garbage", "Volatile Garbage" and "Double Hole" mods]],
        quote = [[The universe is yours.]],
        rank = floorRank(1, 3, 5, 7, 9, 10, 2600),
        hide = function() return STAT.maxFloor < 9 end,
    },
    { -- ASEXVL
        id = 'ASEXVL',
        name = "The Con Artist",
        desc = [[HFD WUT "Expert Mode", "Volatile Garbage" and "All-Spin" mods]],
        quote = [[Would the perfect lie not be an art worthy of admiration ?]],
        rank = floorRank(1, 3, 5, 7, 9, 10, 2600),
        hide = function() return STAT.maxFloor < 9 end,
    },
    { -- swamp_water_lite
        id = 'swamp_water_lite',
        name = "Swamp Water Lite",
        desc = [[HFD WUT all 7/8 of the difficulty mods ("Duo" not allowed)]],
        quote = [[Comes in 8 different flavors!]],
        rank = floorRank(1, 3, 5, 7, 9, 10, 2600),
        hide = function() return STAT.maxFloor < 8 end,
    },
    { -- swamp_water
        id = 'swamp_water',
        name = "Swamp Water",
        desc = [[HFD WUT all mods other than "Duo" at the same time]],
        quote = [[The worst of all worlds.]],
        rank = floorRank(1, 3, 5, 7, 9, 10, 2200),
        hide = function() return STAT.maxFloor < 9 end,
    },
    { -- swamp_water_pro
        ex = true,
        id = 'swamp_water_pro',
        name = "Swamp Water Pro",
        desc = [[HFD WUT all mods at the same time]],
        quote = [[How did you find someone as insane as you to do it together?]],
        rank = floorRank(1, 3, 5, 7, 9, 10, 2200),
        hide = function() return STAT.maxFloor < 9 end,
    },

    { title = "Reversed Mods", quote = [[禁忌「恋の迷路」]] }, -- placeholder
    { quote = [[禁弾「スターボウブレイク」]] }, -- placeholder
    { -- rEX
        id = 'rEX',
        name = "The Tyrant",
        desc = [[HFD with the reversed "Expert Mode" mod]],
        quote = [[Fear, oppression, and limitless ambition.]],
        hide = function() return GAME.completion.EX == 0 end,
        rank = floorRank(1, 3, 5, 7, 9, 10, 1800),
    },
    { -- rNH
        id = 'rNH',
        name = "Asceticism",
        desc = [[HFD with the reversed "No Hold" mod]],
        quote = [[A detachment from even that which is moderate.]],
        hide = function() return GAME.completion.NH == 0 end,
        rank = floorRank(1, 3, 5, 7, 9, 10, 2600),
    },
    { -- rMS
        id = 'rMS',
        name = "Loaded Dice",
        desc = [[HFD with the reversed "Messier Garbage" mod]],
        quote = [[In a rigged game, your mind is the only fair advantage.]],
        hide = function() return GAME.completion.MS == 0 end,
        rank = floorRank(1, 3, 5, 7, 9, 10, 2600),
    },
    { -- rGV
        id = 'rGV',
        name = "Freefall",
        desc = [[HFD with the reversed "Gravity" mod]],
        quote = [[In retrospect, the ground you stood on never existed in the first place.]],
        hide = function() return GAME.completion.GV == 0 end,
        rank = floorRank(1, 3, 5, 7, 9, 10, 4200),
    },
    { -- rVL
        id = 'rVL',
        name = "Last Stand",
        desc = [[HFD with the reversed "Volatile Garbage" mod]],
        quote = [[Strength isn't necessary for those with nothing to lose.]],
        hide = function() return GAME.completion.VL == 0 end,
        rank = floorRank(1, 3, 5, 7, 9, 10, 4200),
    },
    { -- rDH
        id = 'rDH',
        name = "Damnation",
        desc = [[HFD with the reversed "Double Hole" mod]],
        quote = [[No more second chances.]],
        hide = function() return GAME.completion.DH == 0 end,
        rank = floorRank(1, 3, 5, 7, 9, 10, 2200),
    },
    { -- rIN
        id = 'rIN',
        name = "The Exile",
        desc = [[HFD with the reversed "Invisible" mod]],
        quote = [[Never underestimate blind faith.]],
        hide = function() return GAME.completion.IN == 0 end,
        rank = floorRank(1, 3, 5, 7, 9, 10, 2600),
    },
    { -- rAS
        id = 'rAS',
        name = "The Warlock",
        desc = [[HFD with the reversed "All-Spin" mod]],
        quote = [[Into realms beyond heaven and earth.]],
        hide = function() return GAME.completion.AS == 0 end,
    },
    { -- rDP
        id = 'rDP',
        name = "Bleeding Hearts",
        desc = [[HFD with the reversed "Duo" mod]],
        quote = [[Even as we bleed, we keep holding on...]],
        hide = function() return GAME.completion.DP == 0 end,
        rank = floorRank(1, 3, 5, 7, 9, 10, 2200),
    },
    { -- the_harbinger
        id = 'the_harbinger',
        name = "The Harbinger",
        desc = [[Reach floor 5 in all nine reversed mods]],
        quote = [[Weathering the storm of an unfavorable future.]],
        hide = TRUE,
        type = 'issued',
    },
    { -- divine_challenger
        ex = true,
        id = 'divine_challenger',
        name = "Divine Challenger",
        desc = [[Total best altitude with 1 rev mod enabled]],
        quote = [[Expose the darkness of the Zenith Tower.]],
        rank = numberRank(0, 10000, 16000, 20000, 24000, 26000, 30000),
        scoreSimp = function(h) return string.format("%.0fm", h) end,
        hide = TRUE,
    },
    { -- DHEXrGV
        ex = true,
        id = 'DHEXrGV',
        name = "Demonic Speed",
        desc = [[HFD WUT EX rGV DH mods]],
        quote = [[Prove your hellish capabilities to the world.]],
        credit = "@GameTilDead",
        rank = floorRank(1, 3, 5, 7, 9, 10, 4200),
        hide = function() return GAME.completion.GV == 0 end,
    },
    { -- rASrGV
        ex = true,
        id = 'rASrGV',
        name = "Whizzing Wizard",
        desc = [[HFD WUT rGV rAS mods]],
        quote = [["I felt enchanted!"  But soon after, disaster struck...]],
        credit = "@GameTilDead",
        rank = floorRank(1, 3, 5, 7, 9, 10, 4200),
        hide = function() return GAME.completion.GV == 0 or GAME.completion.AS == 0 end,
    },
    { -- NHrAS
        ex = true,
        id = 'NHrAS',
        name = "Pristine",
        desc = [[HFD WUT NH rAS mods]],
        quote = [[The pearl of your gameplay requires perfection for a clean finish.]],
        credit = "@GameTilDead",
        rank = floorRank(1, 3, 5, 7, 9, 10, 2600),
        hide = function() return GAME.completion.AS == 0 end,
    },
    { -- rASrDH
        ex = true,
        id = 'GVrASrDH',
        name = "Storage Overload",
        desc = [[HFD WUT GV rDH rAS mods]],
        quote = [[Believe it or not, you don't have to memorize every one.]],
        rank = floorRank(1, 3, 5, 7, 9, 10, 2600),
        hide = function() return GAME.completion.DH == 0 or GAME.completion.AS == 0 end,
    },
    { -- DHNHrASrIN
        ex = true,
        id = 'DHNHrASrIN',
        name = "Steganography",
        desc = [[HFD WUT NH DH rIN rAS mods]],
        quote = [[Sometimes, the best hiding place is in plain sight.]],
        credit = "@obsidian",
        rank = floorRank(1, 3, 5, 7, 9, 10, 2600),
        hide = function() return GAME.completion.IN == 0 or GAME.completion.AS == 0 end,
    },
    { -- rGVrNHrVL
        ex = true,
        id = 'rGVrNHrVL',
        name = "Sweatshop",
        desc = [[HFD WUT rNH rGV rVL mods]],
        quote = [[Carefree life is not for the asking, someone else is carrying the burden for you.]],
        credit = "@obsidian",
        rank = floorRank(1, 3, 5, 7, 9, 10, 2200),
        hide = function() return GAME.completion.NH == 0 or GAME.completion.GV == 0 or GAME.completion.VL == 0 end,
    },
    { -- DPGVMSrNH
        ex = true,
        id = 'DPGVMSrNH',
        name = "Grand-Master! Rounds",
        desc = [[HFD WUT rNH MS GV DP mods]],
        quote = [[YOUR AER: GRAND-MASTER! Rounds]],
        -- credit = "TGM4",
        rank = floorRank(1, 3, 5, 7, 9, 10, 2000),
        hide = function() return GAME.completion.NH == 0 end,
    },
    { -- rINrNH
        ex = true,
        id = 'rINrNH',
        name = "Instant Memory",
        desc = [[HFD WUT rNH rIN mods]],
        quote = [[In the twinkling of a eye.]],
        rank = floorRank(1, 3, 5, 7, 9, 10, 2000),
        hide = function() return GAME.completion.NH == 0 or GAME.completion.IN == 0 end,
    },
    { -- EXGVNHrMS
        ex = true,
        id = 'EXGVNHrMS',
        name = "Bnuuy",
        desc = [[HFD WUT EX NH rMS GV mods]],
        quote = [[Look at them hopping around! Too bad they don't want to be picked up...]],
        credit = "@GameTilDead",
        rank = floorRank(1, 3, 5, 7, 9, 10, 2000),
        hide = function() return GAME.completion.MS == 0 end,
    },
    { -- rDPrEX
        ex = true,
        id = 'rDPrEX',
        name = "Tyrannical Dyarchy",
        desc = [[HFD WUT rEX rDP mods]],
        quote = [[Live in fear and despair.]],
        rank = floorRank(1, 2, 3, 4, 6, 7, 8),
        hide = function() return GAME.completion.EX == 0 or GAME.completion.DP == 0 end,
    },
    { -- VLrDPrIN
        ex = true,
        id = 'VLrDPrIN',
        name = "Painful Relapse",
        desc = [[HFD WUT VL rIN rDP mods]],
        quote = [["I miss my ex..."]],
        credit = "@obsidian",
        rank = floorRank(1, 2, 3, 4, 5, 6, 7),
        hide = function() return GAME.completion.IN == 0 or GAME.completion.DP == 0 end,
    },
    { -- rDHrIN
        ex = true,
        id = 'rDHrIN',
        name = "Brain Capacity",
        desc = [[HFD WUT rDH rIN mods]],
        quote = [[How long can you keep up in this forsaken memory game?]],
        credit = "@GameTilDead",
        rank = floorRank(1, 1, 2, 3, 4, 5, 6),
        hide = function() return GAME.completion.DH == 0 or GAME.completion.IN == 0 end,
    },
    { -- swamp_water_lite_plus
        ex = true,
        id = 'swamp_water_lite_plus',
        name = "Swamp Water Lite+",
        desc = [[HFD WUT 1rev+6 mods ("Duo" not allowed)]],
        quote = [[Comes in...... 252 different flavors?]],
        rank = floorRank(1, 3, 5, 7, 9, 10, 2200),
        hide = function() return TABLE.countAll(GAME.completion, 0) == 9 end,
    },
    { -- swamp_water_plus
        ex = true,
        id = 'swamp_water_plus',
        name = "Swamp Water+",
        desc = [[HFD WUT 1rev+7 mods ("Duo" not allowed)]],
        quote = [[Less choices but still a lot to try.]],
        rank = floorRank(1, 3, 5, 7, 9, 10, 2000),
        hide = function() return TABLE.countAll(GAME.completion, 0) == 9 end,
    },
    { -- swamp_water_pro_plus
        ex = true,
        id = 'swamp_water_pro_plus',
        name = "Swamp Water Pro+",
        desc = [[HFD WUT 1rev+8 mods]],
        quote = [[The cup is about to overflow!]],
        rank = floorRank(1, 3, 5, 7, 9, 10, 2000),
        hide = function() return TABLE.countAll(GAME.completion, 0) == 9 end,
    },

    { title = "Why", quote = [[禁弾「カタディオプトリック」]] }, -- placeholder
    { quote = [[禁弾「過去を刻む時計」]] }, -- placeholder
    { -- blight
        ex = true,
        id = 'blight',
        name = "Blight",
        desc = [[HFD with 8+ mod points]],
        quote = [[The world starts withering...]],
        rank = floorRank(1, 3, 5, 7, 9, 10, 4200),
        hide = function() return TABLE.countAll(GAME.completion, 0) > 7 end,
    },
    { -- desolation
        ex = true,
        id = 'desolation',
        name = "Desolation",
        desc = [[HFD with 9+ mod points]],
        quote = [[Vitality has faded from the world's palette...]],
        rank = floorRank(1, 3, 5, 7, 9, 10, 2600),
        hide = function() return TABLE.countAll(GAME.completion, 0) > 7 end,
    },
    { -- havoc
        ex = true,
        id = 'havoc',
        name = "Havoc",
        desc = [[HFD with 10+ mod points]],
        quote = [[The world is in chaos...]],
        rank = floorRank(1, 3, 5, 7, 8, 9, 10),
        hide = function() return TABLE.countAll(GAME.completion, 0) > 7 end,
    },
    { -- pandemonium
        ex = true,
        id = 'pandemonium',
        name = "Pandemonium",
        desc = [[HFD with 11+ mod points]],
        quote = [[Several realms began to collide...]],
        rank = floorRank(1, 2, 4, 6, 8, 9, 10),
        hide = function() return TABLE.countAll(GAME.completion, 0) > 7 end,
    },
    { -- inferno
        ex = true,
        id = 'inferno',
        name = "Inferno",
        desc = [[HFD with 12+ mod points]],
        quote = [[Everything is burning and melting...]],
        rank = floorRank(1, 2, 4, 6, 7, 8, 9),
        hide = function() return TABLE.countAll(GAME.completion, 0) > 6 end,
    },
    { -- purgatory
        ex = true,
        id = 'purgatory',
        name = "Purgatory",
        desc = [[HFD with 13+ mod points]],
        quote = [[Nobody knows their destination...]],
        rank = floorRank(1, 1, 3, 5, 6, 7, 8),
        hide = function() return TABLE.countAll(GAME.completion, 0) > 5 end,
    },
    { -- perdition
        ex = true,
        id = 'perdition',
        name = "Perdition",
        desc = [[HFD with 14+ mod points]],
        quote = [[There's no way back...]],
        rank = floorRank(1, 1, 3, 4, 5, 6, 7),
        hide = function() return TABLE.countAll(GAME.completion, 0) > 4 end,
    },
    { -- cataclysm
        ex = true,
        id = 'cataclysm',
        name = "Cataclysm",
        desc = [[HFD with 15+ mod points]],
        quote = [[The real disaster is yet to come...]],
        rank = floorRank(1, 1, 2, 3, 4, 5, 6),
        hide = function() return TABLE.countAll(GAME.completion, 0) > 3 end,
    },
    { -- annihilation
        ex = true,
        id = 'annihilation',
        name = "Annihilation",
        desc = [[HFD with 16+ mod points]],
        quote = [[The whole universe is trembling...]],
        rank = floorRank(1, 1, 1, 2, 3, 4, 5),
        hide = function() return TABLE.countAll(GAME.completion, 0) > 2 end,
    },
    { -- armageddon
        ex = true,
        id = 'armageddon',
        name = "Armageddon",
        desc = [[HFD with 17+ mod points]],
        quote = [[Big crunch is about to happen...]],
        rank = floorRank(1, 1, 1, 1, 2, 3, 4),
        hide = function() return TABLE.countAll(GAME.completion, 0) > 1 end,
    },
    { -- abyss
        ex = true,
        id = 'abyss',
        name = "Abyss",
        desc = [[HFD with 18 mod points]],
        quote = [[.]],
        rank = floorRank(1, 1, 1, 1, 1, 2, 3),
        hide = function() return TABLE.countAll(GAME.completion, 0) > 0 end,
    },
    { quote = [[秘弾「そして誰もいなくなるか？」]] }, -- placeholder

    { title = "Special", quote = [[QED「495年の波紋」]] }, -- placeholder
    { quote = [[禁忌「フォービドゥンフルーツ」]] }, -- placeholder
    { -- the_escape_artist
        id = 'the_escape_artist',
        name = "The Escape Artist",
        desc = [[Quests passed with wound triggered WUT "Double Hole Garbage", "Messier Garbage" and "All-Spin" mods]],
        quote = [["An impossible situation! A daring illusionist! Will he make it out alive?"]],
        rank = numberRank(0, 10, 26, 50, 70, 90, 126),
        scoreSimp = function(rank) return floor(rank) .. " Quests" end,
        hide = function() return STAT.maxFloor < 8 end,
    },
    { -- talentless
        id = 'talentless',
        name = "Talentless",
        desc = [[HFD WUT "All-Spin" mod without using keyboard]],
        quote = [[Reaching deep down but coming back empty every time.]],
        rank = floorRank(1, 3, 5, 7, 9, 10, 4200),
        hide = function() return STAT.maxFloor < 8 end,
    },
    { -- block_rationing
        id = 'block_rationing',
        name = "Block Rationing",
        desc = [[Highest altitude on 40 quests WUT "Expert Mode" and "Messier Garbage" mods]],
        quote = [[Adversity favors the resourceful.]],
        scoreSimp = heightNumber,
        rank = numberRank(0, 260, 360, 450, 495, 550, 600),
        hide = function() return STAT.maxFloor < 9 end,
    },
    { -- the_responsible_one
        id = 'the_responsible_one',
        name = "The Responsible One",
        desc = [[Highest amount of revivals performed in a single duo run]],
        quote = [["Could you please stop dying?"]],
        scoreSimp = function(b2b) return b2b .. " Revives" end,
        rank = numberRank(0, 3, 6, 9, 12, 14, 16),
        hide = function() return STAT.maxFloor < 8 end,
    },
    { -- guardian_angel
        id = 'guardian_angel',
        name = "Guardian Angel",
        desc = [[Highest altitude to perform a successful revive at]],
        quote = [[An angel's intervention.]],
        scoreSimp = heightNumber,
        rank = numberRank(0, 626, 942, 1620, 2000, 2600, 4200),
        hide = function() return STAT.maxFloor < 8 end,
    },
    { -- lovers_promise
        id = 'lovers_promise',
        name = "Lover's Promise",
        desc = [[Highest altitude reached with DP on 14th day of a month]],
        quote = [[The impossible promise of an eternity just like this moment.]],
        scoreSimp = heightNumber,
        hide = function() return STAT.maxFloor < 8 end,
        type = 'event',
    },
    { -- moon_struck
        ex = true,
        id = 'moon_struck',
        name = "Moon Struck",
        desc = [[Finish the run at exactly 2202.8m (±3/±1/±0)]],
        quote = [[TODO]],
        scoreSimp = heightNumber,
        credit = "@osk",
        notUsed = true,
    },
    { -- clutch_main
        ex = true,
        id = 'clutch_main',
        name = "Clutch Main",
        desc = [[Quests passed while HP in danger, WUT NH rGV mods]],
        quote = [[Your horses had better be held onto!]],
        credit = "@GameTilDead",
        rank = numberRank(0, 26, 42, 62, 94, 126, 180),
        scoreSimp = function(rank) return floor(rank) .. " Quests" end,
        hide = function() return GAME.completion.GV == 0 end,
    },
    { -- powerless
        ex = true,
        id = 'powerless',
        name = "Powerless",
        desc = [[HFD without building up surge]],
        quote = [["We have a similar goal to climb the Zenith Tower in many ways."]],
        rank = floorRank(1, 3, 5, 7, 9, 10, 4200),
    },
    { -- the_pacifist
        ex = true,
        id = 'the_pacifist',
        name = "The Pacifist",
        desc = [[Minimum attack before reaching F10]],
        quote = [[Give evil nothing to oppose and it will disappear by itself.]],
        credit = "@wah",
        rank = numberRankRev(500, 426, 412, 400, 395, 390, 380),
        scoreSimp = function(atk) return atk .. " Attack" end,
        comp = '<',
        noScore = 2600,
    },
    { -- divine_rejection
        ex = true,
        id = 'divine_rejection',
        name = "Divine Rejection",
        desc = [[Finish the run exactly before F10]],
        quote = [["And in the end, it doesn't even matter..."]],
        rank = numberRank(1626, 1626, 1635, 1640, 1645, 1647.8, 1649),
        scoreSimp = function(h) return string.format("%.2fm", h) end,
    },
    { -- sunk_cost
        ex = true,
        id = 'sunk_cost',
        name = "Sunk Cost",
        desc = [[HFD without losing rank]],
        quote = [["Cross the line, and the descent begins."]],
        rank = floorRank(1, 3, 5, 7, 9, 10, 2600),
    },
    { -- knife_edge
        ex = true,
        id = 'knife_edge',
        name = "Knife-edge",
        desc = [[HFD without losing rank, with at least EX]],
        quote = [[A delicate dance on the cutting edge.]],
        rank = floorRank(1, 3, 5, 7, 9, 10, 2000),
        hide = function() return STAT.maxFloor < 9 end,
    },
    { -- carried
        ex = true,
        id = 'carried',
        name = "Carried",
        desc = [[HFD with only one player alive, with at least DP]],
        quote = [["I have no idea how to play the game, can you unlock the mods for me?"]],
        credit = "@obsidian",
        rank = floorRank(1, 3, 5, 7, 9, 10, 2000),
        hide = function() return STAT.maxFloor < 8 end,
    },
    { -- honeymoon
        ex = true,
        id = 'honeymoon',
        name = "Honeymoon",
        desc = [[HFD with every commit shares at least one mod with previous]],
        quote = [["Can we be together forever?"]],
        notUsed = true,
    },
    { -- break_up
        ex = true,
        id = 'break_up',
        name = "Break Up",
        desc = [[HFD without commiting any mod twice in a row]],
        quote = [["Never let me see you again."]],
        notUsed = true,
    },
    { -- patience_is_a_virtue
        ex = true,
        id = 'patience_is_a_virtue',
        name = "Patience is a Virtue",
        desc = [[HFD without manually commit]],
        quote = [[Opportunities always favor those who are prepared and wait.]],
        credit = "@The_111thBlitzer",
        rank = floorRank(1, 3, 5, 7, 9, 10, 2200),
        hide = function() return STAT.maxFloor < 4 end,
    },
    { -- fel_magic
        ex = true,
        id = 'fel_magic',
        name = "Fel Magic",
        desc = [[Quests passed with wound triggered during GIGASPEED, with rAS]],
        quote = [["And what, Gul'dan, must we give it return?"]],
        -- credit = "WoW",
        rank = numberRank(0, 6, 15, 26, 42, 62, 100),
        scoreSimp = function(rank) return floor(rank) .. " Quests" end,
        hide = function() return GAME.completion.AS == 0 or STAT.totalGiga == 0 end,
    },
    { -- arrogance
        ex = true,
        id = 'arrogance',
        name = "Arrogance",
        desc = [[HFD with rAS and no perfect pass]],
        quote = [[Maintaining arrogance constantly is also not easy.]],
        rank = floorRank(1, 1, 1, 1, 2, 3, 4),
        hide = function() return GAME.completion.AS == 0 end,
    },
    { -- psychokinesis
        ex = true,
        id = 'psychokinesis',
        name = "Psychokinesis",
        desc = [[HFD with 0 flip count increasing in statistics]],
        quote = [[Real magic exists!]],
        rank = floorRank(1, 1, 1, 1, 2, 3, 5),
        hide = function() return STAT.maxFloor < 9 end,
    },
    { quote = [[禁忌「禁じられた遊び」]] }, -- placeholder

    { title = "Supercharged Clone", quote = [[紅魔符「ブラッディカタストロフ」]] }, -- placeholder -- @Garbo
    { quote = [[紅神符「十七条のカタストロフ」]] }, -- placeholder
    { -- museum_heist
        ex = true,
        id = 'museum_heist',
        name = "Museum Heist",
        desc = [[Shortest time spent in F5 with DH DP]],
        quote = [[Less time, less evidence.]],
        credit = "@Baron",
        comp = '<',
        noScore = 2600,
        scoreSimp = function(time) return string.format("%.2fs", time) end,
        rank = numberRankRev(35, 26, 20, 12, 6.2, 4.2, 2.6),
        hide = function() return STAT.maxFloor < 8 end,
    },
    { -- ultra_dash
        ex = true,
        id = 'ultra_dash',
        name = "Ultra Dash",
        desc = [[Shortest time spent in F9]],
        quote = [[Probably a good strategy for speedrunning 1.2x faster.]],
        comp = '<',
        noScore = 2600,
        scoreSimp = function(time) return string.format("%.2fs", time) end,
        rank = numberRankRev(62, 26, 16, 12, 6.2, 2.6, 1.0),
    },
    { -- perfect_speedrun
        ex = true,
        id = 'perfect_speedrun',
        name = "Perfect Speedrun",
        desc = [[Reach 75 Back-to-Back as fast as possible]],
        quote = [[Supercharged B75%]],
        comp = '<',
        noScore = 2600,
        scoreSimp = function(time) return string.format("%.2fs", time) end,
        rank = numberRankRev(150, 115, 90, 70, 55, 45, 40),
    },
    { -- the_perfectionist
        ex = true,
        id = 'the_perfectionist',
        name = "The Perfectionist",
        desc = [[HFD with no imperfect pass or getting hurt]],
        quote = [[Supercharged Perf%]],
        rank = floorRank(1, 3, 5, 7, 9, 10, 2600),
    },
    { -- teraspeed
        ex = true,
        id = 'teraspeed',
        name = "TeraSpeed",
        desc = [[Highest rank reached]],
        quote = [[Supercharged Inf%]],
        rank = numberRank(12, 14, 15, 16, 17, 18, 20),
        scoreSimp = function(rank) return "Rank " .. rank end,
    },
    { quote = [[紅星符「超人カタストロフ行脚」]] }, -- placeholder

    { title = "Issued (No CR)", quote = [[禁忌「レックレスバレット」]] }, -- placeholder
    { quote = [[禁忌「ケルベロスクリッパー」]] }, -- placeholder
    { -- identity
        ex = true,
        id = 'identity',
        name = "Identity",
        desc = [[Change ID or about-me]],
        quote = [[Is this free?]],
        type = 'issued',
    },
    { -- zenith_relocation
        ex = true,
        id = 'zenith_relocation',
        name = "Zenith Relocation",
        desc = [[Export your save to a different platform (Web / Windows / Linux)]],
        quote = [[Uncover the mysteries of a new, familiar Tower.]],
        credit = "@GameTilDead",
        type = 'issued',
    },
    { -- respectful
        ex = true,
        id = 'respectful',
        name = "Respectful",
        desc = [[Stay in ABOUT page for 26s]],
        quote = [[Press F2 to pay respect]],
        -- credit = "COD11",
        type = 'issued',
    },
    { -- zenith_traveler
        ex = true,
        id = 'zenith_traveler',
        name = "Zenith Traveler",
        desc = [[Enter traveler mode]],
        quote = [[Also known as background debugging mode]],
        type = 'issued',
    },
    { -- intended_glitch
        ex = true,
        id = 'intended_glitch',
        name = "Intended Glitch",
        desc = [[Play Duo]],
        quote = [[This is not a bug, it's a feature.]],
        hide = function() return STAT.maxFloor < 8 end,
        type = 'issued',
    },
    { -- somersault
        ex = true,
        id = 'somersault',
        name = "Somersault",
        desc = [[Reversing card animation ended at non-rev activated state]],
        quote = [[Elegant backflip]],
        hide = TRUE,
        type = 'issued',
    },
    { -- dark_force
        ex = true,
        id = 'dark_force',
        name = "Dark Force",
        desc = [[Interrupt font loading with rev mod]],
        quote = [[The darkness overflows.]],
        hide = TRUE,
        type = 'issued',
    },
    { -- skys_the_limit
        ex = true,
        id = 'skys_the_limit',
        name = "Sky's The Limit",
        desc = [[Reach 6200m]],
        quote = [[Edge of the universe.]],
        type = 'issued',
    },
    { -- superluminal
        ex = true,
        id = 'superluminal',
        name = "Superluminal",
        desc = [[Reach F10 in 76.2s]],
        quote = [[Faster than light!]],
        type = 'issued',
    },
    { -- mastery
        ex = true,
        id = 'mastery',
        name = "Mastery",
        desc = [[Mastery on all single mods]],
        quote = [[Game cleared, congratulations!]],
        type = 'issued',
    },
    { -- terminal_velocity
        ex = true,
        id = 'terminal_velocity',
        name = "Terminal Velocity",
        desc = [[Speedrun all single mods]],
        quote = [[Reaching for the stars again and again.]],
        credit = "@The_111thBlitzer",
        hide = function() return STAT.totalGiga == 0 end,
        type = 'issued',
    },
    { -- and_then_nothing
        ex = true,
        id = 'and_then_nothing',
        name = "And Then... Nothing",
        desc = [[Survive after breaking B2B x 50 while using rDP and one player is KO'd]],
        quote = [[Moral of the story: NEVER exploit your partner.]],
        credit = "@GameTilDead",
        hide = function() return GAME.completion.DP == 0 end,
        type = 'issued',
    },
    { -- fruitless_effort
        ex = true,
        id = 'fruitless_effort',
        name = "Fruitless Effort",
        desc = [[Finish a game with bonus over 260%]],
        quote = [[Effort is pointless if you are not strong enough.]],
        hide = function() return GAME.completion.EX == 0 end,
        type = 'issued',
    },
    { -- speedrun_speedrunning
        ex = true,
        id = 'speedrun_speedrunning',
        name = "Speedrun Speedrunning",
        desc = [[Enter GIGASPEED on F1]],
        quote = [[Not much of a speedrun]],
        type = 'issued',
        hide = function() return GAME.completion.EX == 0 or STAT.totalGiga == 0 end,
    },
    { -- worn_out
        ex = true,
        id = 'worn_out',
        name = "Worn Out",
        desc = [[Reach f10 with GIGASPEED after retaining it for 5 minutes]],
        quote = [[You alright over there? You seem a bit tired from all that "speed"-running...]],
        credit = "@GameTilDead",
        type = 'issued',
        hide = function() return STAT.totalGiga == 0 end,
    },
    { -- final_defiance
        ex = true,
        id = 'final_defiance',
        name = "Final Defiance",
        desc = [[Meet the final fatigue effect]],
        quote = [["This is not the end!"]],
        credit = "@Flowerling",
        type = 'issued',
    },
    { -- royal_resistance
        ex = true,
        id = 'royal_resistance',
        name = "Royal Resistance",
        desc = [[Meet the final fatigue effect with rEX]],
        quote = [["History will prove me right!!"]],
        credit = "@Flowerling",
        hide = function() return GAME.completion.EX == 0 end,
        type = 'issued',
    },
    { -- lovers_stand
        ex = true,
        id = 'lovers_stand',
        name = "Lover's Stand",
        desc = [[Meet the final fatigue effect with rDP]],
        quote = [[The power of affection sees you through the bitter end.]],
        hide = function() return GAME.completion.DP == 0 end,
        type = 'issued',
    },
    { -- false_god
        ex = true,
        id = 'false_god',
        name = "False God",
        desc = [[Mastery on all mods]],
        quote = [[Do it again but without clever tricks this time.]],
        type = 'issued',
        hide = TRUE,
    },
    { -- supremacy
        ex = true,
        id = 'supremacy',
        name = "Supremacy",
        desc = [[Mastery on all single rev mods]],
        quote = [[Your reign has begun, and it knows no end.]],
        type = 'issued',
        hide = TRUE,
    },
    { -- the_completionist
        ex = true,
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

TABLE.foreach(Achievements, function(v) return v.notUsed end, true)

for i = 1, #Achievements do
    local achv = Achievements[i]
    local id = achv.id
    if id then
        Achievements[id] = achv

        assert(type(id) == 'string', "Missing field 'name' - " .. id)
        assert(type(achv.name) == 'string', "Missing field 'name' - " .. id)

        assert(achv.desc, "Missing field 'desc' - " .. id)
        achv.desc = achv.desc
            :gsub("WUT", "while using the")
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
end
