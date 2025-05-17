love.window.setIcon(love.image.newImageData('assets/icon.png'))

require 'Zenitha'

ZENITHA.setMainLoopSpeed(240)
ZENITHA.setRenderRate(50)
ZENITHA.setShowFPS(false)
ZENITHA.setVersionText("")
ZENITHA.setClickDist(62)

STRING.install()

SCR.setSize(1600, 1000)

---@return love.Texture
local function assets(path) return 'assets/' .. path end
local function q(oy, n, size)
    return GC.newQuad(
        n * size, oy,
        size, size,
        1971, 2255
    )
end
local function q2(ox, oy, w, h)
    return GC.newQuad(
        ox, oy,
        w, h,
        1971, 2255
    )
end
local function aq(x, y) return { 1, GC.newQuad((x - 1) % 16 * 256, (y - 1) % 16 * 256, 256, 256, 2048, 2304) } end
local function aq2(x, y) return { 2, GC.newQuad((x - 1) % 16 * 256, (y - 1) % 16 * 256, 256, 256, 2048, 2304) } end
TEXTURE = {
    star0 = assets 'crystal-dark.png',
    star1 = assets 'crystal.png',
    panel = {
        glass_a = assets 'panel/glass-a.png',
        glass_b = assets 'panel/glass-b.png',
        throb_a = assets 'panel/throb-a.png',
        throb_b = assets 'panel/throb-b.png',
    },
    modIcon = assets 'mod_icon.png',
    modQuad_ig = {
        VL = q(0, 0, 219),
        NH = q(0, 1, 219),
        MS = q(0, 2, 219),
        IN = q(0, 3, 219),
        GV = q(0, 4, 219),
        EX = q(0, 5, 219),
        DP = q(0, 6, 219),
        DH = q(0, 7, 219),
        AS = q(0, 8, 219),
        rVL = q(219, 0, 219),
        rNH = q(219, 1, 219),
        rMS = q(219, 2, 219),
        rIN = q(219, 3, 219),
        rGV = q(219, 4, 219),
        rEX = q(219, 5, 219),
        rDP = q(219, 6, 219),
        rDH = q(219, 7, 219),
        rAS = q(219, 8, 219),
    },
    modQuad_res = {
        VL = q(438, 0, 183),
        NH = q(438, 1, 183),
        MS = q(438, 2, 183),
        IN = q(438, 3, 183),
        GV = q(438, 4, 183),
        EX = q(438, 5, 183),
        DP = q(438, 6, 183),
        DH = q(438, 7, 183),
        AS = q(438, 8, 183),
        rVL = q(621, 0, 183),
        rNH = q(621, 1, 183),
        rMS = q(621, 2, 183),
        rIN = q(621, 3, 183),
        rGV = q(621, 4, 183),
        rEX = q(621, 5, 183),
        rDP = q(621, 6, 183),
        rDH = q(621, 7, 183),
        rAS = q(621, 8, 183),
    },
    modQuad_ig_ex = {
        VL = q(804, 0, 219),
        NH = q(804, 1, 219),
        MS = q(804, 2, 219),
        IN = q(804, 3, 219),
        GV = q(804, 4, 219),
        EX = q(804, 5, 219),
        DP = q(804, 6, 219),
        DH = q(804, 7, 219),
        AS = q(804, 8, 219),
        rVL = q(1023, 0, 219),
        rNH = q(1023, 1, 219),
        rMS = q(1023, 2, 219),
        rIN = q(1023, 3, 219),
        rGV = q(1023, 4, 219),
        rEX = q(1023, 5, 219),
        rDP = q(1023, 6, 219),
        rDH = q(1023, 7, 219),
        rAS = q(1023, 8, 219),
    },
    modQuad_res_ex = {
        VL = q(1242, 0, 183),
        NH = q(1242, 1, 183),
        MS = q(1242, 2, 183),
        IN = q(1242, 3, 183),
        GV = q(1242, 4, 183),
        EX = q(1242, 5, 183),
        DP = q(1242, 6, 183),
        DH = q(1242, 7, 183),
        AS = q(1242, 8, 183),
        rVL = q(1425, 0, 183),
        rNH = q(1425, 1, 183),
        rMS = q(1425, 2, 183),
        rIN = q(1425, 3, 183),
        rGV = q(1425, 4, 183),
        rEX = q(1425, 5, 183),
        rDP = q(1425, 6, 183),
        rDH = q(1425, 7, 183),
        rAS = q(1425, 8, 183),
    },
    modQuad_ultra = {
        rNH = q2(000, 1608, 315, 315),
        rMS = q2(315, 1608, 315, 315),
        rGV = q2(630, 1608, 315, 315),
        rVL = q2(945, 1608, 315, 315),
        rDH = q2(000, 1923, 315, 315),
        rIN = q2(315, 1923, 315, 315),
        rAS = q2(630, 1923, 315, 315),
        rEX = q2(945, 1923, 315, 332),
        rDP = q2(1260, 1608, 419, 378),
    },
    EX = { lock = assets 'card/lockover-9.png', front = assets 'card/expert.png', back = assets 'card/expert-back.png', throb = assets 'card/expert-throb.png', },
    NH = { lock = assets 'card/lockfull-2.png', front = assets 'card/nohold.png', back = assets 'card/nohold-back.png', throb = assets 'card/nohold-throb.png', },
    MS = { lock = assets 'card/lockfull-3.png', front = assets 'card/messy.png', back = assets 'card/messy-back.png', throb = assets 'card/messy-throb.png', },
    GV = { lock = assets 'card/lockfull-4.png', front = assets 'card/gravity.png', back = assets 'card/gravity-back.png', throb = assets 'card/gravity-throb.png', },
    VL = { lock = assets 'card/lockfull-5.png', front = assets 'card/volatile.png', back = assets 'card/volatile-back.png', throb = assets 'card/volatile-throb.png', },
    DH = { lock = assets 'card/lockfull-6.png', front = assets 'card/doublehole.png', back = assets 'card/doublehole-back.png', throb = assets 'card/doublehole-throb.png', },
    IN = { lock = assets 'card/lockfull-7.png', front = assets 'card/invisible.png', back = assets 'card/invisible-back.png', throb = assets 'card/invisible-throb.png', },
    AS = { lock = assets 'card/lockfull-8.png', front = assets 'card/allspin.png', back = assets 'card/allspin-back.png', throb = assets 'card/allspin-throb.png', },
    DP = { lock = assets 'card/lockover-supporter.png', front = assets 'card/duo.png', back = assets 'card/duo-back.png', throb = assets 'card/duo-throb.png', },
    towerBG = { assets 'tower/f1.jpg', assets 'tower/f2.jpg', assets 'tower/f3.jpg', assets 'tower/f4.jpg', assets 'tower/f5.jpg', assets 'tower/f6.jpg', assets 'tower/f7.jpg', assets 'tower/f8.jpg', assets 'tower/f9.jpg', assets 'tower/f10.png' },
    moon = assets 'tower/moon.png',
    stars = assets 'tower/stars.png',
    ruler = assets 'ruler.png',

    revive = {
        norm = assets 'revive/norm.png',
        rev_left = assets 'revive/rev_left.png',
        rev_right = assets 'revive/rev_right.png',
    },
    spark = {
        assets 'particle/spark1.png',
        assets 'particle/spark2.png',
        assets 'particle/spark3.png',
    },

    stat = {
        avatar = assets 'stat/avatar.png',
        clicker = assets 'stat/clicker.png',
        rank = {
            [0] = assets 'rank/z.png',
            assets 'rank/d.png',
            assets 'rank/d+.png',
            assets 'rank/c-.png',
            assets 'rank/c.png',
            assets 'rank/c+.png',
            assets 'rank/b-.png',
            assets 'rank/b.png',
            assets 'rank/b+.png',
            assets 'rank/a-.png',
            assets 'rank/a.png',
            assets 'rank/a+.png',
            assets 'rank/s-.png',
            assets 'rank/s.png',
            assets 'rank/s+.png',
            assets 'rank/ss.png',
            assets 'rank/u.png',
            assets 'rank/x.png',
            assets 'rank/x+.png',
        },
    },
    achievement = {
        icons = {
            assets 'achievements/icons1.png',
            assets 'achievements/icons2.png',
        },
        iconQuad = {
            _undef = aq(8, 8),
            zenith_explorer = aq(2, 3),
            zenith_explorer_plus = aq(2, 3),
            clicker_speedrun = aq(5, 1),
            typer_speedrun = aq(5, 1),
            supercharged = aq(5, 6),
            supercharged_plus = aq(5, 6),
            multitasker = aq(7, 2),
            effective = aq(7, 2),
            zenith_speedrun = aq(2, 6),
            zenith_speedrun_plus = aq(2, 6),
            zenith_challenger = aq(8, 2),
            divine_challenger = aq2(4, 1),
            zenith_speedrunner = aq(2, 6),
            divine_speedrunner = aq2(5, 1),
            the_spike_of_all_time = aq(4, 2),
            the_spike_of_all_time_minus = aq(4, 2),
            vip_list = aq(6, 6),

            EX = aq(3, 3),
            NH = aq(7, 3),
            MS = aq(8, 3),
            GV = aq(6, 3),
            VL = aq(5, 3),
            DH = aq(4, 3),
            IN = aq(1, 4),
            AS = aq(2, 4),
            DP = aq(3, 4),
            GVIN = aq(6, 4),
            ASNH = aq(4, 6),
            DPEX = aq(8, 5),
            GVNH = aq(4, 4),
            DHMSNH = aq(5, 4),
            DHEXNH = aq(7, 4),
            DHEXMSVL = aq(8, 4),
            ASEXVL = aq(1, 7),
            swamp_water_lite = aq(5, 7),
            swamp_water = aq(2, 5),
            swamp_water_pro = aq2(8, 1),

            rEX = aq(7, 9),
            rNH = aq(3, 9),
            rMS = aq(4, 9),
            rGV = aq(2, 9),
            rVL = aq(1, 9),
            rDH = aq(8, 9),
            rIN = aq(5, 9),
            rAS = aq(6, 9),
            rDP = aq(7, 7),
            DHEXrGV = aq2(5, 2),      -- Demonic Speed
            rASrGV = aq2(3, 2),       -- Whizzing Wizard
            rGVrIN = aq2(1, 2),       -- The Grandmaster+
            NHrAS = aq(1, 2),         -- Pristine
            GVrASrDH = aq2(1, 3),     -- Storage Overload
            DHNHrASrIN = aq2(7, 7),   -- Steganography
            DHrMSrNH = aq2(6, 7),     -- Deadbeat
            DHGVNHrMS = aq2(3, 7),    -- Trench Warfare
            rGVrNHrVL = aq2(8, 5),    -- Sweatshop
            rINrNH = aq2(6, 5),       -- Fleeting Memory
            EXGVNHrMS = aq2(4, 5),    -- Bnuuy
            DPGVMSrNH = aq2(2, 2),    -- Grand-Master!
            ASDPGVrMSrNH = aq2(2, 2), -- Grand-Master! Rounds
            ASEXrDHrMS = aq2(5, 7),   -- Endless Gluttony
            DHrEXrVL = aq2(4, 7),     -- Sweat and Ruin
            ASGVrDPrMS = aq2(4, 3),   -- Cupid's Gamble
            NHVLrDPrGV = aq2(3, 5),   -- Despairful Longing
            INMSrDHrDP = aq2(1, 5),   -- Uneasy Alliance
            VLrEXrIN = aq2(8, 8),     -- Authoritarian Delusion
            rDPrEX = aq2(4, 2),       -- Tyrannical Dyarchy
            INMSrDHrEX = aq2(7, 5),   -- Sisyphean Monarchy
            rDHrIN = aq2(5, 5),       -- Brain Capacity
            swamp_water_lite_plus = aq2(6, 2),
            swamp_water_plus = aq2(7, 2),
            swamp_water_pro_plus = aq2(8, 2),

            -- Special, no texture needed
            blight = aq(0, 0),
            desolation = aq(0, 0),
            havoc = aq(0, 0),
            pandemonium = aq(0, 0),
            inferno = aq(0, 0),
            purgatory = aq(0, 0),
            perdition = aq(0, 0),
            cataclysm = aq(0, 0),
            annihilation = aq(0, 0),
            armageddon = aq(0, 0),
            abyss = aq(0, 0),

            the_escape_artist = aq(1, 5),
            talentless = aq(3, 7),
            block_rationing = aq(2, 7),
            the_responsible_one = aq(1, 6),
            guardian_angel = aq(3, 6),
            lovers_promise = aq(8, 7),
            -- moon_struck = aq(),
            clutch_main = aq2(8, 3),
            the_oblivious_artist = aq2(6, 9),
            powerless = aq(7, 5),
            the_pacifist = aq(4, 1),
            divine_rejection = aq(7, 6),
            sunk_cost = aq2(6, 8),
            wax_wings = aq2(7, 8),
            carried = aq(3, 8),
            patience_is_a_virtue = aq2(2, 5),
            spotless = aq2(5, 3),
            fel_magic = aq2(1, 7),
            arrogance = aq(3, 5),
            honeymoon = aq2(3, 4),
            break_up = aq2(1, 4),
            overprotection = aq2(1, 9),
            the_unreliable_one = aq2(7, 1),
            detail_oriented = aq(8, 6),
            psychokinesis = aq(8, 6),

            love_hotel = aq(5, 6),
            financially_responsible = aq(5, 6),
            unfair_battle = aq(5, 6),
            museum_heist = aq(5, 6),
            workaholic = aq(5, 6),
            human_experiment = aq(5, 6),
            core_meltdown = aq(5, 6),
            ultra_dash = aq(5, 6),
            perfect_speedrun = aq(5, 6),
            the_perfectionist = aq(5, 6),
            teraspeed = aq(5, 6),
            cruise_control = aq(5, 6),
            the_spike_of_all_time_plus = aq(5, 6),

            skys_the_limit = aq2(2, 3),
            superluminal = aq2(6, 1),
            cut_off = aq(6, 2),
            worn_out = aq(6, 2),
            mastery = aq2(2, 6),
            terminal_velocity = aq2(2, 6),
            final_defiance = aq(3, 2),
            the_harbinger = aq(5, 8),
            speedrun_speedrunning = aq(5, 2),
            abyss_weaver = aq(5, 2),
            royal_resistance = aq2(2, 1),
            lovers_stand = aq2(2, 1),
            romantic_homicide = aq(4, 8),
            its_kinda_rare = aq2(6, 3),
            benevolent_ambition = aq2(7, 3),
            fruitless_effort = aq(6, 7),
            false_god = aq(2, 8),
            subjugation = aq2(2, 7),
            omnipotence = aq2(2, 7),
            clicking_champion = aq2(8, 6),

            identity = aq(6, 6),
            respectful = aq(2, 1),
            zenith_relocation = aq(4, 7),
            intended_glitch = aq2(3, 3),
            dark_force = aq(3, 1),
            zenith_traveler = aq(1, 8),
            smooth_dismount = aq(4, 1),
        },
        frame = {
            [0] = assets 'achievements/frames/none.png',
            assets 'achievements/frames/bronze.png',
            assets 'achievements/frames/silver.png',
            assets 'achievements/frames/gold.png',
            assets 'achievements/frames/platinum.png',
            assets 'achievements/frames/diamond.png',
            assets 'achievements/frames/issued.png',
        },
        ring = assets 'achievements/frames/ring-piece.png',
        wreath = {
            assets 'achievements/wreaths/t100.png',
            assets 'achievements/wreaths/t50.png',
            assets 'achievements/wreaths/t25.png',
            assets 'achievements/wreaths/t10.png',
            assets 'achievements/wreaths/t5.png',
            assets 'achievements/wreaths/t3.png',
        },
        glint_1 = assets 'achievements/glint-a.png',
        glint_2 = assets 'achievements/glint-b.png',
        glint_3 = assets 'achievements/glint-c.png',
        competitive = assets 'achievements/competitive.png',
        hidden = assets 'achievements/hidden.png',
        event = assets 'achievements/event.png',
        extra = assets 'achievements/extra.png',
    },

    logo = assets 'icon.png',
    logo_old = assets 'icon_old.png',
}
local transition = { w = 128, h = 1 }
for x = 0, 127 do
    table.insert(transition, { 'setCL', 1, 1, 1, 1 - x / 128 })
    table.insert(transition, { 'fRect', x, 0, 1, 1 })
end
TEXTURE.transition = GC.load(transition)
TEXTURE.pixel = GC.load { w = 1, h = 1, { 'clear', 1, 1, 1 } }
TEXTURE.darkCorner = GC.newCanvas(128, 128)
GC.setCanvas(TEXTURE.darkCorner)
GC.setColor(0, 0, 0)
GC.blurCircle(.626, 64, 64, 64)
GC.setCanvas()
TEXTURE = IMG.init(TEXTURE, true)

FONT.load {
    serif = "assets/AbhayaLibre-Regular.ttf",
    sans = "assets/DINPro-Medium.otf",
    led = "assets/UniDreamLED.ttf",
}
local fontNotLoaded = SYSTEM ~= 'Web' and MATH.roll(.62)
FONT.setDefaultFont(fontNotLoaded and 'serif' or 'sans')

BG.add('black', { draw = function() GC.clear(0, 0, 0) end })
BG.set('black')

TEXTS = { -- Font size can only be 30 and 50 here !!!
    version    = GC.newText(FONT.get(30), SYSTEM .. " " .. (require 'version'.appVer)),
    mod        = GC.newText(FONT.get(30)),
    mpPreview  = GC.newText(FONT.get(30)),
    zpPreview  = GC.newText(FONT.get(30)),
    zpChange   = GC.newText(FONT.get(30)),
    dcBest     = GC.newText(FONT.get(30)),
    dcTimer    = GC.newText(FONT.get(30)),
    title      = GC.newText(FONT.get(50), "EXPERT QUICK PICK"),
    load       = GC.newText(FONT.get(50), "JOINING ROOM..."),
    pb         = GC.newText(FONT.get(50)),
    endResult  = GC.newText(FONT.get(30)),
    endHeight  = GC.newText(FONT.get(50)),
    endFloor   = GC.newText(FONT.get(30)),
    linePB     = GC.newText(FONT.get(50), "PB"),
    lineKM     = GC.newText(FONT.get(50), "1000"),
    height     = GC.newText(FONT.get(30)),
    time       = GC.newText(FONT.get(30)),
    rank       = GC.newText(FONT.get(30)),
    chain      = GC.newText(FONT.get(50)),
    chain2     = GC.newText(FONT.get(50, 'led')),
    b2b        = GC.newText(FONT.get(30), "B2B x"),
    spike      = GC.newText(FONT.get(50)),
    gigaspeed  = GC.newText(FONT.get(50), {
        COLOR.R, "G", COLOR.O, "I", COLOR.Y, "G",
        COLOR.K, "A", COLOR.G, "S", COLOR.J, "P",
        COLOR.C, "E", COLOR.S, "E", COLOR.B, "D"
    }),
    gigatime   = GC.newText(FONT.get(50)),
    floorTime  = GC.newText(FONT.get(30)),
    rankTime   = GC.newText(FONT.get(30)),
    slogan     = GC.newText(FONT.get(30), "CROWD THE TOWER!"),
    slogan_EX  = GC.newText(FONT.get(30), "THRONG THE TOWER!"),
    slogan_rEX = GC.newText(FONT.get(30), "OVERFLOW THE TOWER!"),
    forfeit    = GC.newText(FONT.get(50), "KEEP HOLDING TO FORFEIT"),
    credit     = GC.newText(FONT.get(30), "All assets from TETR.IO"),
}
if fontNotLoaded then
    TASK.new(function()
        local loadTime = love.timer.getTime() + (MATH.roll(.9626) and MATH.rand(2.6, 6.26) or 26)
        while love.timer.getTime() < loadTime do
            TASK.yieldT(0.1)
            if GAME.anyRev then
                TASK.yieldT(0.26)
                SFX.play('staffsilence')
                MSG('dark', "A DARK FORCE INTERRUPTED THE FONT LOADING")
                IssueAchv('dark_force')
                return
            end
            if SCN.cur == 'about' then
                TASK.yieldT(0.26)
                SFX.play('staffspam')
                break
            end
        end
        FONT.setDefaultFont('sans')
        ReloadTexts()
    end)
end

local button_invis = WIDGET.newClass('button_invis', 'button')
button_invis.draw = NULL

Metatable = {
    best_highscore = { __index = function() return 0 end },
    best_speedrun = { __index = function() return 1e99 end },
}
BEST = {
    highScore = setmetatable({}, Metatable.best_highscore),
    speedrun = setmetatable({}, Metatable.best_speedrun),
}

STAT = {
    system = SYSTEM,
    joinDate = os.date("%b %Y"),
    hid = os.date("%d%S%m%M%y%H") .. math.random(2600000000, 6200000000),
    uid = "ANON-" .. os.date("%d_") .. math.random(2600, 6200),
    keybind = {
        "q", "w", "e", "r", "t", "y", "u", "i", "o",
        "a", "s", "d", "f", "g", "h", "j", "k", "l",
        "space", "z", "x", "c"
    },
    aboutme = "Click the Zenith!",
    maxFloor = 1,
    maxHeight = 0,
    heightDate = "NO DATE",
    minTime = 2600,
    timeDate = "NO DATE",

    zp = 0,
    dzp = 0,
    dailyBest = 0,
    dailyMastered = false,
    lastDay = 0,
    vipListCount = 0,

    totalGame = 0,
    totalTime = 0,
    totalQuest = 0,
    totalPerfect = 0,
    totalHeight = 0,
    totalBonus = 0,
    totalFloor = 0,
    totalFlip = 0,
    totalAttack = 0,
    totalGiga = 0,
    totalF10 = 0,

    fullscreen = true,
    syscursor = false,
    cardBrightness = 90,
    bgBrightness = 40,
    bg = true,
    sfx = 60,
    bgm = 100,
}

ACHV = {}

AchvNotice = {}

function SaveBest() love.filesystem.write('best.luaon', 'return' .. TABLE.dumpDeflate(BEST)) end

function SaveStat() love.filesystem.write('stat.luaon', 'return' .. TABLE.dumpDeflate(STAT)) end

function SaveAchv() love.filesystem.write('achv.luaon', 'return' .. TABLE.dumpDeflate(ACHV)) end

MSG.setSafeY(75)
MSG.addCategory('dark', COLOR.D, COLOR.L)

AchvData = {
    [0] = { id = 'achv_none', bg = COLOR.D, fg = COLOR.LD, fg2 = COLOR.LD },
    { id = 'achv_bronze',   bg = COLOR.DO,          fg = COLOR.lO, fg2 = COLOR.O },
    { id = 'achv_silver',   bg = { .26, .26, .26 }, fg = COLOR.L,  fg2 = COLOR.dL },
    { id = 'achv_gold',     bg = COLOR.DY,          fg = COLOR.lY, fg2 = COLOR.Y },
    { id = 'achv_platinum', bg = COLOR.DJ,          fg = COLOR.lJ, fg2 = COLOR.J },
    { id = 'achv_diamond',  bg = COLOR.DP,          fg = COLOR.lP, fg2 = COLOR.lB },
    { id = 'achv_issued',   bg = COLOR.DM,          fg = COLOR.lM, fg2 = COLOR.lM },
}
for i = 0, 6 do MSG.addCategory(AchvData[i].id, AchvData[i].bg, COLOR.L, TEXTURE.achievement.frame[i]) end

local msgTime = 0
local bufferedMsg = {}

function IssueAchv(id, silent)
    local A = Achievements[id]
    if not A or ACHV[id] then return end

    if not silent then
        table.insert(bufferedMsg, { 'achv_issued', {
            AchvData[6].fg, A.name .. "\n",
            COLOR.dL, A.desc .. "\n",
            COLOR.LD, A.quote,
        }, 1 })
        if not GAME.playing then
            ReleaseAchvBuffer()
        end
    end

    ACHV[id] = 0
    AchvNotice[id] = true
    TWEEN.new():setOnFinish(SaveAchv):setDuration(.26):setUnique('achv_saver'):run()

    return true
end

function SubmitAchv(id, score, silent)
    local A = Achievements[id]
    if not A then return end
    local oldScore = ACHV[id] or A.noScore or 0
    local R0, R1 = A.rank(oldScore), A.rank(score)
    -- printf("%s: %.1f(%.2f) -> %.1f(%.2f)", id, oldScore, R0, score, R1)
    if R1 == 0 or not A.comp(score, oldScore) then return end

    if not silent and R1 >= 1 then
        local rank = math.floor(R1)
        local scoreText = A.scoreSimp(score) .. (A.scoreFull and "  " .. A.scoreFull(score) or "")
        local oldScoreText = A.scoreSimp(oldScore) .. (A.scoreFull and "  " .. A.scoreFull(oldScore) or "")
        table.insert(bufferedMsg, { AchvData[rank].id, {
            AchvData[rank].fg, A.name .. "   >>   " .. scoreText,
            COLOR.LD, (ACHV[id] and "    Previous: " .. oldScoreText or "") .. "\n",
            COLOR.dL, A.desc .. "\n", COLOR.LD, A.quote,
        }, rank <= 2 and 1 or rank <= 4 and 2 or 3 })
        if not GAME.playing then
            ReleaseAchvBuffer()
        end
    end

    ACHV[id] = score
    AchvNotice[id] = true
    TWEEN.new():setOnFinish(SaveAchv):setDuration(.26):setUnique('achv_saver'):run()

    return true
end

function ReleaseAchvBuffer()
    for i = 1, #bufferedMsg do
        local msg = bufferedMsg[i]
        msgTime = TASK.lock('achv_bulk', 1) and 6.2 or msgTime + 2.6
        MSG { msg[1], msg[2], time = msgTime, last = true, alpha = .75 }
        if TASK.lock('achv_sfx_' .. msg[3], .08) then
            SFX.play('achievement_' .. msg[3], .7, 0, Tone(0))
        end
    end
    TABLE.clear(bufferedMsg)
end

MX, MY = 0, 0

---@type Map<Card>
Cards = {}

---@type nil|number
FloatOnCard = nil

GigaSpeed = {
    r = 0,
    g = 0,
    b = 0,
    alpha = 0,
    bgAlpha = 0,
    textTimer = false,
}
ImpactGlow = {}
DeckPress = 0
ThrobAlpha = {
    card = 0,
    bg1 = 0,
    bg2 = 0,
}
Wind = {}
WindBatch = GC.newSpriteBatch(GC.load { w = 1, h = 1, { 'clear', 1, 1, 1, 1 } }, 260, 'static')
for i = 1, 62 do
    Wind[i] = { math.random(), math.random(), MATH.clampInterpolate(1, 0.5, 260, 2.6, i) }
    WindBatch:add(0, 0)
end
StarPS = GC.newParticleSystem(TEXTURE.stars, 32)
StarPS:setParticleLifetime(2.6)
StarPS:setRotation(0, 6.26)
StarPS:setEmissionRate(12)
---@diagnostic disable-next-line
StarPS:setColors(COLOR.LX, COLOR.L, COLOR.L, COLOR.L, COLOR.L, COLOR.L, COLOR.L, COLOR.LX)

WoundPS = GC.newParticleSystem(GC.load { w = 16, h = 16,
    { 'clear', 1, 1, 1 },
    { 'setCL', 0, 0, 0 },
    { 'fRect', 1, 1, 14, 14 },
}, 32)
WoundPS:setEmissionArea('uniform', 42, 42, 0)
WoundPS:setParticleLifetime(2.6, 6.2)
WoundPS:setSpread(6.28)
WoundPS:setSpeed(26, 42)
---@diagnostic disable-next-line
WoundPS:setColors(COLOR.LX, COLOR.L, COLOR.L, COLOR.L, COLOR.L, COLOR.L, COLOR.L, COLOR.LX)


SparkPS = {}
for i = 1, 3 do
    local ps = GC.newParticleSystem(TEXTURE.spark[i])
    ps:setParticleLifetime(.26, .62)
    ps:setEmissionArea('ellipse', 62, 62, 0)
    ---@diagnostic disable-next-line
    ps:setColors(COLOR.L, COLOR.LX)
    SparkPS[i] = ps
end

BgScale = 1
BgmSets = {
    all = {
        'piano',
        'arp', 'bass', 'guitar', 'pad', 'staccato', 'violin',
        'expert', 'rev',
        'piano2', 'violin2',
    },
    assist = { 'arp', 'bass', 'guitar', 'pad', 'staccato', 'violin' },
}

require 'module.game_data'
require 'module.achv_data'

Shader_Coloring = GC.newShader [[vec4 effect(vec4 color, sampler2D tex, vec2 texCoord, vec2 scrCoord) {return vec4(color.rgb, color.a * texture2D(tex, texCoord).a);}]]

GAME = require 'module/game'
local M = GAME.mod

for i = 1, #ModData.deck do table.insert(Cards, require 'module/card'.new(ModData.deck[i])) end
GAME.refreshLayout()
for i, C in ipairs(Cards) do
    Cards[C.id], C.x, C.y = C, C.tx, C.ty + 260 + 26 * 1.6 ^ i
end

SCN.add('joining', require 'module/scene/joining')
SCN.add('tower', require 'module/scene/tower')
SCN.add('stat', require 'module/scene/stat')
SCN.add('achv', require 'module/scene/achv')
SCN.add('conf', require 'module/scene/conf')
SCN.add('about', require 'module/scene/about')
ZENITHA.setFirstScene('joining')

local gc = love.graphics

local pressValue = 0

CursorProgress = 0
CursorHide = true
local function starCursor(x, y)
    if CursorHide or GAME.zenithTraveler then return end
    GC.translate(x, y)
    GC.scale(1.42)
    GC.rotate(MATH.lerp(-.626, -1.2, pressValue))
    GC.scale(.8 + .2 * pressValue, 1)
    local l = .626 + .374 * pressValue
    GC.setColor(l, l, l)
    GC.draw(TEXTURE.star0, 0, -6, 0, .14, .3, TEXTURE.star1:getWidth() * .5, 0)
    GC.scale(.12, .26)
    GC.setShader(Shader_Coloring)
    GC.setColor(1, .626, .5)
    GC.draw(TEXTURE.star0, -150, 0)
    if CursorProgress <= .384626 then
        local t = MATH.interpolate(0, 1, .384626, 0, CursorProgress)
        GC.setColor(.9, .9, .9, t)
        GC.draw(TEXTURE.star0, -150, 0)
        GC.setShader()
    else
        GC.setShader()
        GC.setColor(1, 1, 1, MATH.iLerp(.384626, 1, CursorProgress))
        GC.draw(TEXTURE.star1, -150, 0)
    end
end

function Tone(pitch)
    return pitch + M.GV
end

function ApplySettings()
    love.mouse.setVisible(STAT.syscursor)
    ZENITHA.globalEvent.drawCursor = STAT.syscursor and NULL or starCursor
    SFX.setVol(STAT.sfx / 100 * .6)
    BGM.setVol(STAT.bgm / 100)
end

function ReloadTexts()
    local sep = (TEXTS.mod:getFont():getHeight() + TEXTS.title:getFont():getHeight()) / 2
    for _, text in next, TEXTS do text:setFont(FONT.get(text:getFont():getHeight() < sep and 30 or 50)) end
    for _, text in next, ShortCut do text:setFont(FONT.get(text:getFont():getHeight() < sep and 30 or 50)) end
    for _, quest in next, GAME.quests do quest.name:setFont(FONT.get(70)) end
    TEXTS.height:setFont(FONT.get(30))
    TEXTS.time:setFont(FONT.get(30))
    TEXTS.gigatime:setFont(FONT.get(50))
    TEXTS.chain2:setFont(FONT.get(50, 'led'))
    for _, W in next, SCN.scenes.tower.widgetList do W:reset() end
    for _, W in next, SCN.scenes.stat.widgetList do W:reset() end
    for _, W in next, SCN.scenes.achv.widgetList do W:reset() end
    for _, W in next, SCN.scenes.conf.widgetList do W:reset() end
    for _, W in next, SCN.scenes.about.widgetList do W:reset() end
    if SCN.cur == 'stat' then RefreshProfile() end
    AboutText:setFont(FONT.get(70))
end

VALENTINE = false
VALENTINE_TEXT = "FLOOD THE TOWER SIDE BY SIDE WITH WHAT COULD BE"
function RefreshDaily()
    local dateToday = os.date("!*t", os.time())
    local dateLastDay = os.date("!*t", math.max(STAT.lastDay, 946656000)) -- at least 2000/1/1
    local time0Today = os.time({ year = dateToday.year, month = dateToday.month, day = dateToday.day })
    local time0LastDay = os.time({ year = dateLastDay.year, month = dateLastDay.month, day = dateLastDay.day })
    local dayPast = MATH.round((time0Today - time0LastDay) / 86400)

    if dayPast < 0 then
        MSG('warn', "Back to the future?", 26)
    elseif MATH.between(dayPast, 1, 2600) then
        -- print("Old ZP & Daily HS", STAT.zp, STAT.dailyHS)
        STAT.zp = MATH.expApproach(STAT.zp, 0, dayPast * .026)
        STAT.dzp = MATH.expApproach(STAT.dzp, 0, dayPast * .0626)
        STAT.dailyBest = 0
        STAT.dailyMastered = false
        -- print("New ZP & Daily HS", STAT.zp, STAT.dailyHS)
        STAT.lastDay = os.time()
        print("Daily Reset finished")
    end

    for x = 0, 0 do
        math.randomseed(os.date("!%Y%m%d") + x)
        for _ = 1, 26 do math.random() end

        local modCount = math.ceil(9 - math.log(math.random(11, 42), 1.62)) -- 5 444 3333 2222
        DAILY = {}

        DailyActived = false
        DailyAvailable = false

        while #DAILY < modCount do
            local m = ModData.deck[MATH.randFreq { 3, 3, 2, 5, 3, 5, 4, 4, 2 }].id
            if not TABLE.find(DAILY, m) then table.insert(DAILY, m) end
        end
        if MATH.roll(.26 + #DAILY * .1) then
            if #DAILY >= 3 and MATH.roll(.62) then TABLE.popRandom(DAILY) end
            local r = math.random(#DAILY)
            DAILY[r] = 'r' .. DAILY[r]
            if MATH.roll(.26) then
                local r2 = math.random(#DAILY - 1)
                if r2 >= r then r2 = r2 + 1 end
                DAILY[r2] = 'r' .. DAILY[r2]
            end
        end
        -- print(table.concat(DAILY, ' '))
    end

    local v = os.date('!%d') == '14'
    if VALENTINE ~= v then
        VALENTINE = v
        ModData.desc.DP, VALENTINE_TEXT = VALENTINE_TEXT, ModData.desc.DP
        ValentineTextColor, BaseTextColor = BaseTextColor, ValentineTextColor
        ValentineShadeColor, BaseShadeColor = BaseShadeColor, ValentineShadeColor
    end
end

love.mouse.setVisible(false)
ZENITHA.globalEvent.drawCursor = NULL
ZENITHA.globalEvent.clickFX = NULL
function ZENITHA.globalEvent.fileDrop(file)
    local data = file:read('data')
    local suc, res = pcall(GC.newImage, data)
    if suc then
        if AVATAR then AVATAR:release() end
        AVATAR = res
        love.filesystem.write('avatar', data)
        IssueAchv('identity')
        SFX.play('supporter')
        MSG('dark', "Your avatar was updated!")
    else
        MSG('dark', "Invalid image file.")
    end
    file:close()
    file:release()
    if SCN.cur == 'stat' then RefreshProfile() end
end

function ZENITHA.globalEvent.resize()
    BgScale = math.max(SCR.w / 1024, SCR.h / 640)
    StarPS:reset()
    StarPS:moveTo(0, -GAME.bgH * 2 * BgScale)
    StarPS:setEmissionArea('uniform', SCR.w * .626, SCR.h * .626)
    StarPS:setSizes(SCR.k * 1.626)
    local dt = 1 / StarPS:getEmissionRate()
    for _ = 1, StarPS:getBufferSize() do
        StarPS:emit(1)
        StarPS:update(dt)
    end
end

function ZENITHA.globalEvent.keyDown(key, isRep)
    if isRep then return end
    if key == 'f12' then
        if TASK.lock('dev') then
            MSG('check', "Zenith Clicker is powered by Love2d & Zenitha, not Web!", 6.26)
        else
            ZENITHA.setDevMode(not ZENITHA.getDevMode() and 1 or false)
        end
    elseif key == 'f11' then
        STAT.fullscreen = not STAT.fullscreen
        love.window.setFullscreen(STAT.fullscreen)
    elseif key == 'f10' then
        STAT.syscursor = not STAT.syscursor
        SetMouseVisible(true)
        ApplySettings()
    elseif key == 'f9' then
        if not GAME.zenithTraveler then
            STAT.bg = not STAT.bg
        end
    elseif key == 'f8' then
        if STAT.bgBrightness < 80 then
            STAT.bgBrightness = MATH.clamp(STAT.bgBrightness + 10, 30, 80)
            MSG('dark', "BG " .. STAT.bgBrightness .. "%", 1)
        end
    elseif key == 'f7' then
        if STAT.bgBrightness > 30 then
            STAT.bgBrightness = MATH.clamp(STAT.bgBrightness - 10, 30, 80)
            MSG('dark', "BG " .. STAT.bgBrightness .. "%", 1)
        end
    elseif key == 'f5' then
        if STAT.cardBrightness > 80 then
            STAT.cardBrightness = MATH.clamp(STAT.cardBrightness - 5, 80, 100)
            MSG('dark', "Card " .. STAT.cardBrightness .. "%", 1)
        end
    elseif key == 'f6' then
        if STAT.cardBrightness < 100 then
            STAT.cardBrightness = MATH.clamp(STAT.cardBrightness + 5, 80, 100)
            MSG('dark', "Card " .. STAT.cardBrightness .. "%", 1)
        end
    elseif key == 'f3' then
        if STAT.sfx > 0 then
            TempSFX = STAT.sfx
            STAT.sfx = 0
        else
            STAT.sfx = TempSFX or 60
            TempSFX = false
        end
        MSG('dark', STAT.sfx > 0 and "SFX ON" or "SFX OFF", 1)
        ApplySettings()
        SFX.play('menuclick')
    elseif key == 'f4' then
        if STAT.bgm > 0 then
            TempBGM = STAT.bgm
            STAT.bgm = 0
        else
            STAT.bgm = TempBGM or 100
            TempBGM = false
        end
        MSG('dark', STAT.bgm > 0 and "BGM ON" or "BGM OFF", 1)
        ApplySettings()
    end
end

WIDGET.setDefaultOption {
    checkBox = {
        w = 40,
        labelPos = 'right',
        labelDist = 8,
        lineWidth = 2,
        sound_on = 'menuclick',
        sound_off = 'menuclick',
    },
    slider = {
        lineWidth = 2,
        _approachSpeed = 1e99,
    },
}

function WIDGET._prototype.button:draw()
    gc.push('transform')
    gc.translate(self._x, (not self.pos or self.pos[1] ~= .5) and self._y or self._y + DeckPress)

    if self._pressTime > 0 then
        gc.scale(1 - self._pressTime / self._pressTimeMax * .0626)
    end
    local w, h = self.w, self.h

    local fillC = self.fillColor
    local frameC = self.frameColor

    -- Background
    gc.setColor(fillC)
    GC.mRect('fill', 0, 0, w, h)

    -- Frame
    gc.setLineWidth(3)
    gc.setColor(frameC[1] * .42, frameC[2] * .42, frameC[3] * .42)
    gc.line(-w / 2, h / 2, w / 2, h / 2, w / 2, -h / 2 - 1.5)
    gc.setColor(.2 + frameC[1] * .8, .2 + frameC[2] * .8, .2 + frameC[3] * .8)
    gc.line(-w / 2, h / 2 + 1.5, -w / 2, -h / 2, w / 2 - 1.5, -h / 2)

    -- Drawable
    gc.setColor(self.textColor)
    WIDGET._alignDraw(self, self._text, 0, 0, 0, 1.2, 1.2 - 2.4 * GAME.revTimer)

    -- Highlight
    if self._hoverTime > 0 then
        gc.setColor(1, 1, 1, self._hoverTime / self._hoverTimeMax * .0626)
        GC.mRect('fill', 0, 0, w - 3, h - 3)
    end

    gc.pop()
end

function WIDGET._prototype.checkBox:draw()
    gc.push('transform')
    gc.translate(self._x, self._y)
    local w = self.w

    gc.setLineWidth(self.lineWidth)
    if self.disp() then
        -- Active
        gc.setColor(self.frameColor)
        GC.mRect('fill', 0, 0, w, w, 2)
        gc.setColor(0, 0, 0, .42)
        gc.line(-w / 2, w / 2, w / 2, w / 2, w / 2, -w / 2)
        gc.setColor(1, 1, 1, .62)
        gc.line(-w / 2, w / 2, -w / 2, -w / 2, w / 2, -w / 2)
        gc.setLineWidth(self.lineWidth * 2)
        gc.setLineJoin('bevel')
        gc.setColor(1, 1, 1)
        gc.line(-w * .355, 0, 0, w * .355, w * .355, -w * .355)
    else
        -- Background
        gc.setColor(self.fillColor)
        GC.mRect('fill', 0, 0, w, w, 2)
        gc.setColor(0, 0, 0, .626)
        gc.line(-w / 2, w / 2, -w / 2, -w / 2, w / 2, -w / 2)
        gc.setColor(1, 1, 1, .0626)
        gc.line(-w / 2, w / 2, w / 2, w / 2, w / 2, -w / 2)
    end

    -- Drawable
    local x2, y2 = w * .5 + self.labelDist, 0
    gc.setColor(self.textColor)
    WIDGET._alignDraw(self, self._text, x2, y2, nil, self.textScale)

    -- Highlight
    gc.setColor(1, 1, 1, self._hoverTime / self._hoverTimeMax * .0626)
    GC.mRect('fill', 0, 0, w, w, 2)

    gc.pop()
end

function WIDGET._prototype.slider:draw()
    local x, y = self._x, self._y
    local x2 = x + self.w
    local rangeL, rangeR = self._rangeL, self._rangeR

    local frameC = self.frameColor

    -- Axis
    gc.setColor(frameC)
    gc.setLineWidth(self.lineWidth * 2)
    gc.line(x, y, x2, y)

    local fillC = self.fillColor

    -- Block
    local pos = MATH.clamp(self._pos, rangeL, rangeR)
    local cx = x + self.w * (pos - rangeL) / self._rangeWidth
    local bw, bh = 26, 30
    GC.ucs_move('m', cx, y)
    gc.setColor(fillC)
    GC.mRect('fill', 0, 0, bw, bh, self.cornerR)
    gc.setLineWidth(self.lineWidth)
    gc.setColor(0, 0, 0, .26)
    gc.line(-bw / 2, bh / 2, bw / 2, bh / 2, bw / 2, -bh / 2)
    gc.setColor(1, 1, 1, .1)
    gc.line(-bw / 2, bh / 2, -bw / 2, -bh / 2, bw / 2, -bh / 2)
    GC.ucs_back()
end

local uVLpool = {}
function UltraVlCheck(id, auto)
    uVLpool[id] = (uVLpool[id] or 0) + (auto and 3.55 or 1)
    if uVLpool[id] < 3.1 then
        SFX.play('clearline', .3)
        if uVLpool[id] < 1.3 then
            SFX.play('combo_1', .626, 0, Tone(0))
        elseif uVLpool[id] < 2.2 then
            SFX.play('combo_3', .626, 0, Tone(-2))
        else
            SFX.play('combo_2', .626, 0, Tone(1))
        end
        return false
    end
    if not auto then
        SFX.play('clearquad', .3)
        SFX.play('combo_4', .626, 0, Tone(0))
    end
    uVLpool[id] = 0
    return true
end

-- Muisc syncing daemon
-- DiscordRPC syncing daemon
DiscordState = {}
function Daemon_Slow()
    TASK.yieldT(1)
    local lib = BGM._srcLib
    local set = BgmSets.all
    local length = BGM.getDuration()
    while true do
        local t0 = lib[set[1]].source:tell()
        for i = #set, 2, -1 do
            local obj = lib[set[i]]
            local T = t0
            if set[i] == 'piano2' then T = T * 2 % length end
            if set[i] == 'violin2' then T = (T - 8 * 60 / 184) % length end
            if math.abs(obj.source:tell() - T) > 0.026 then
                -- print('Desync', set[i])
                obj.source:seek(math.max(T, 0))
            end
        end
        if DiscordState.needUpdate and not TASK.getLock('RPC_update') then
            DiscordState.needUpdate = nil
            DiscordRPC.update(DiscordState)
        end
        TASK.yieldT(1)
    end
end

-- Throb tranpaency daemon
-- Messy position daemon
-- Expert guitar randomization daemon
-- Mouse holding animation daemon
function Daemon_Fast()
    local max = math.max
    local hsv = COLOR.HSV
    local yield = coroutine.yield
    local msIsDown = love.mouse.isDown
    local expApproach = MATH.expApproach

    local bar = 2 * 60 / 184 * 4
    local t1, step1 = -.1, 2 * 60 / 184
    local t2, step2 = 0, 2 * 60 / 184 / 4
    local exLastVol = 0
    local t = 0
    while true do
        local T = BGM.tell()
        ThrobAlpha.card = max(.626 - 2 * T / bar % 1, .626 - 2 * (T / bar - .375) % 1)
        ThrobAlpha.bg1 = .626 - 2 * T / bar % 1
        ThrobAlpha.bg2 = .626 - 2 * (T / bar - 1 / 32) % 1

        if GigaSpeed.alpha > 0 then
            GigaSpeed.r, GigaSpeed.g, GigaSpeed.b = hsv(T / bar % 1, .626, 1)
            GigaSpeed.bgAlpha = 1 - 4 * T / bar % 1
        end

        if T < t1 then t1 = -.1 end
        if T > t1 + step1 then
            t1 = t1 + step1
            if M.MS == 0 then
                for i = 1, 9 do Cards[i].visY = 0 end
            elseif URM and M.MS == 2 then
                for i = 1, 9 do Cards[i].visY = math.random(-42, 42) end
            else
                for i = 1, 9 do Cards[i].visY = M.MS * math.random(-4, 4) end
            end
            GAME.refreshLayout()
        end

        if T < t2 then t2 = 0 end
        if T > t2 + step2 then
            t2 = t2 + step2
            if M.EX > 0 and not SCN.swapping then
                local r = math.random()
                local f = GAME.floor
                r = 1 + (r - 1) / (f * r + 1)
                r = MATH.clamp(r, exLastVol - (26 - f) * .02, exLastVol + (26 - f) * .02)
                BGM.set('expert', 'volume', r, r > exLastVol and .0626 or .26)
                exLastVol = r
            end
        end

        local dt = yield()

        if not STAT.syscursor then
            pressValue = msIsDown(1, 2) and 1 or expApproach(pressValue, 0, dt * 12)
        end

        for k, v in next, uVLpool do
            uVLpool[k] = max(v - dt, 0)
        end

        if GAME.revDeckSkin and SYSTEM ~= 'Web' then
            if M.NH > 0 then dt = dt * (1 - M.NH * .42) end
            if M.AS > 0 then dt = dt * (1 + M.AS) end
            t = t + dt
            local v = dt * GAME.bgXdir * (26 + 2.6 * GAME.rank)
            if M.GV > 0 then v = v * (.62 + M.GV * 2.6 * math.sin(t * 2.6 * (M.GV - .5))) end
            GAME.bgX = GAME.bgX + v
        end
    end
end

-- Load data
if FILE.exist('data.luaon') then
    if not FILE.exist('best.luaon') then
        love.filesystem.write('best.luaon', love.filesystem.read('data.luaon'))
    end
    love.filesystem.remove('data.luaon')
end
if FILE.exist('conf.luaon') then love.filesystem.remove('conf.luaon') end
TABLE.update(BEST, FILE.load('best.luaon', '-luaon') or NONE)
TABLE.update(STAT, FILE.load('stat.luaon', '-luaon') or NONE)
TABLE.update(ACHV, FILE.load('achv.luaon', '-luaon') or NONE)
if FILE.exist('avatar') then
    local suc, res = pcall(GC.newImage, 'avatar')
    if suc then AVATAR = res end
end
function Initialize(save)
    if STAT.totalF10 == 0 and STAT.totalGiga > 0 then STAT.totalF10 = math.floor(STAT.totalGiga * 0.872) end
    if STAT.totalBonus == 0 and STAT.totalGame > 2.6 then STAT.totalBonus = STAT.totalHeight * 0.5 end
    if STAT.totalPerfect == 0 and STAT.totalQuest > 0 then STAT.totalPerfect = math.floor(STAT.totalQuest * 0.872) end
    if BEST.version then STAT.version, BEST.version = BEST.version, nil end
    local oldVer = STAT.version
    if STAT.version == nil then
        for k in next, BEST.highScore do
            if k:find('rNH') or k:find('rMS') or k:find('rVL') or k:find('rAS') then
                BEST.highScore[k] = nil
            end
        end
        STAT.version = 162
    end
    if STAT.version == 162 then
        TABLE.clear(BEST.speedrun)
        STAT.version = 163
    end
    if STAT.version == 163 then
        STAT.maxFloor = BEST.maxFloor or 1
        BEST.maxFloor = nil
        STAT.version = 166
    end
    if STAT.version == 166 then
        STAT.sfx = STAT.sfx and 60 or 0
        STAT.bgm = STAT.bgm and 100 or 0
        STAT.version = 167
    end
    if STAT.version == 167 then
        STAT.dzp = STAT.dailyHS or 0
        STAT.dailyHS = nil
        STAT.version = 168
    end
    if STAT.version == 168 or STAT.version == 169 then
        if ACHV.patience_is_a_virtue and ACHV.patience_is_a_virtue > 0 and ACHV.talentless == ACHV.patience_is_a_virtue then ACHV.patience_is_a_virtue = nil end
        ACHV.mastery = nil
        ACHV.terminal_velocity = nil
        ACHV.false_god = nil
        ACHV.supremacy = nil
        ACHV.the_completionist = nil
        ACHV.sunk_cost, ACHV.sink_cost = ACHV.sink_cost, nil
        STAT.version = 170
    end
    if STAT.version == 170 then
        ACHV.block_rationing = nil
        STAT.version = 171
    end
    if STAT.version == 171 then
        ACHV.worn_out = nil
        STAT.version = 172
    end
    if STAT.version == 172 then
        ACHV.speedrun_speedrunning = ACHV.speedrun_speedruning
        STAT.version = 173
    end
    if STAT.version == 173 then
        ACHV.cruise_control, ACHV.stable_rise = ACHV.stable_rise, nil
        ACHV.subjugation, ACHV.supremacy = ACHV.supremacy, nil
        ACHV.smooth_dismount, ACHV.somersault = ACHV.somersault, nil
        ACHV.omnipotence, ACHV.the_completionist = ACHV.omnipotence, nil
        STAT.version = 174
    end
    if STAT.version == 174 then
        ACHV.overprotection, ACHV.overprotectiveness = ACHV.overprotection, nil
        STAT.version = 175
    end

    -- Some Initialization
    for i = 1, #Cards do
        local f10 = Floors[9].top
        local id = Cards[i].id
        local rid = 'r' .. id
        if BEST.highScore[rid] >= f10 then
            GAME.completion[id] = 2
        else
            for cmb, h in next, BEST.highScore do
                if h >= f10 and cmb:find(rid) then
                    GAME.completion[id] = 2
                    break
                end
            end
        end
        if GAME.completion[id] ~= 2 then
            if BEST.highScore[id] >= f10 then
                GAME.completion[id] = 1
            else
                for cmb, h in next, BEST.highScore do
                    if h >= f10 and (cmb:gsub('r', ''):find(id) or 0) % 2 == 1 then
                        GAME.completion[id] = 1
                        break
                    end
                end
            end
        end
    end

    -- Auto fixing
    local realBestHeight = math.max(STAT.maxHeight, TABLE.maxAll(BEST.highScore), 0)
    if STAT.maxHeight > realBestHeight + .1 then
        STAT.maxHeight = realBestHeight
        STAT.heightDate = "NO DATE"
    end
    local realBestTime = math.min(STAT.minTime, TABLE.minAll(BEST.speedrun), 2600)
    if STAT.minTime < realBestTime - .1 then
        STAT.minTime = realBestTime
        STAT.timeDate = "NO DATE"
    end
    for cmb in next, BEST.highScore do
        cmb = cmb:gsub('r', '')
        local illegal
        for i = 1, #cmb, 2 do
            if not GAME.completion[cmb:sub(i, i + 1)] then
                illegal = true
                break
            end
        end
        if illegal then
            BEST.highScore[cmb] = nil
            BEST.speedrun[cmb] = nil
        end
    end
    local achvLost = ""
    for k in next, ACHV do
        if not Achievements[k] then
            ACHV[k] = nil
            achvLost = achvLost .. "[" .. (k) .. "]\n"
        end
    end
    if #achvLost > 0 then
        MSG('dark', "Achievements lost due to update:\n" .. achvLost:sub(1, #achvLost - 1), 6.26)
    end

    GAME.refreshLockState()
    GAME.refreshPBText()
    love.window.setFullscreen(STAT.fullscreen)
    ApplySettings()
    GAME.refreshCursor()

    if save or STAT.version ~= oldVer then
        SaveStat()
        SaveBest()
        SaveAchv()
    end
end

Initialize()
RefreshDaily()
TABLE.update(TextColor, BaseTextColor)
TABLE.update(ShadeColor, BaseShadeColor)
GAME.refreshCurrentCombo()

if SYSTEM == 'Web' then
    _G[('DiscordRPC')] = { update = NULL, setEnable = NULL }
else
    DiscordRPC = require 'module/discordRPC'
    DiscordRPC.setEnable(true)
    DiscordRPC.update {
        details = "QUICK PICK",
        state = "Enjoying Music",
    }
end

-- Debug
for i = 1, 4 do SCN.scenes._console.widgetList[i].textColor = COLOR.D end
TASK.new(function()
    for _, s in next, ([[ ]]):trim():split('%s+', true) do
        TASK.yieldT(1)
        SFX.play(s)
    end
end)
