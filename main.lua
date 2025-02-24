require 'Zenitha'

ZENITHA.setMainLoopSpeed(240)
ZENITHA.setRenderRate(50)
ZENITHA.setShowFPS(false)
ZENITHA.setVersionText(require 'version'.appVer)
ZENITHA.setClickDist(62)

STRING.install()

SCR.setSize(1600, 1000)

MSG.addCategory('dark', COLOR.lD, COLOR.L)

IMG.init {
    star0 = 'assets/crystal-dark.png',
    star1 = 'assets/crystal.png',
    glass_a = 'assets/glass-a.png',
    glass_b = 'assets/glass-b.png',
    throb_a = 'assets/throb-a.png',
    throb_b = 'assets/throb-b.png',
    floorBG = {
        'assets/1fa.jpg',
        'assets/2fa.jpg',
        'assets/3fa.jpg',
        'assets/4fa.jpg',
        'assets/5fa.jpg',
        'assets/6fa.jpg',
        'assets/7fa.jpg',
        'assets/8fa.jpg',
        'assets/9fa.jpg',
        'assets/10fa.jpg',
    },
}

local _DATA = {
    highScore = setmetatable({}, { __index = function() return 0 end }),
    maxFloor = 1,
}

DATA = setmetatable({
    load = function() TABLE.update(_DATA, FILE.load('data.luaon', '-luaon -canskip') or NONE) end,
    save = function() love.filesystem.write('data.luaon', TABLE.dumpDeflate(_DATA)) end,
}, {
    __index = _DATA,
    __newindex = function(_, k, v)
        _DATA[k] = v
        DATA.save()
    end,
})

GAME = require 'module/game'

MX, MY = 0, 0

---@type Map<Card>
Cards = {}

---@type nil|number
FloatOnCard = nil

Background = {
    floor = 2,
    alpha = 0,
}
ImpactGlow = {}
DeckPress = 0
ThrobAlpha = {
    card = 0,
    bg1 = 0,
    bg2 = 0,
}

BgmSets = {
    all = {
        'piano',
        'arp', 'bass', 'guitar', 'pad', 'staccato', 'violin',
        'expert', 'rev',
        'piano2', 'violin2',
    },
    assist = { 'arp', 'bass', 'guitar', 'pad', 'staccato', 'violin' },
}

DeckData = {
    { initOrder = 1, nameOrder = 8, id = 'EX', lockover = 'lockover-9',         name = 'expert',     fullName = "< EXPERT MODE >",         desc = "A LESS LENIENT CHALLENGE, FOR THOSE WHO DARE",            revName = "> THE TYRANT <",      revDesc = "FEAR, OPPRESSION, AND LIMITLESS AMBITION." },
    { initOrder = 2, nameOrder = 4, id = 'NH', lockfull = 'lockfull-2',         name = 'nohold',     fullName = "< NO HOLD >",             desc = "CANCELING IS DISABLED",                                   revName = "> ASCETICISM <",      revDesc = "A DETACHMENT FROM EVEN THAT WHICH IS MODERATE." },
    { initOrder = 3, nameOrder = 2, id = 'MS', lockfull = 'lockfull-3',         name = 'messy',      fullName = "< MESSIER GARBAGE  >",    desc = "TAROTS WILL BE SHUFFLED BY FLOOR",                        revName = "> LOADED DICE <",     revDesc = "IN A RIGGED GAME, YOUR MIND IS THE ONLY FAIR ADVANTAGE." },
    { initOrder = 4, nameOrder = 7, id = 'GV', lockfull = 'lockfull-4',         name = 'gravity',    fullName = "< GRAVITY >",             desc = "AUTO COMMITTING, TIMED BY FLOOR",                         revName = "> FREEFALL <",        revDesc = "THE GROUND YOU STOOD ON NEVER EXISTED IN THE FIRST PLACE." },
    { initOrder = 5, nameOrder = 3, id = 'VL', lockfull = 'lockfull-5',         name = 'volatile',   fullName = "< VOLATILE GARBAGE >",    desc = "LARGER GAPS BETWEEN TAROTS, BUT MUST CLICK TWICE",        revName = "> LAST STAND <",      revDesc = "STRENGTH ISN'T NECESSARY FOR THOSE WITH NOTHING TO LOSE." },
    { initOrder = 6, nameOrder = 5, id = 'DH', lockfull = 'lockfull-6',         name = 'doublehole', fullName = "< DOUBLE HOLE GARBAGE >", desc = "COMBOS WILL SPAWN HARDER",                                revName = "> DAMNATION <",       revDesc = "NO MORE SECOND CHANCES." },
    { initOrder = 7, nameOrder = 1, id = 'IN', lockfull = 'lockfull-7',         name = 'invisible',  fullName = "< INVISIBLE >",           desc = "TAROTS FACE DOWN AND HINTS FLASH ONCE EVERY TWO SECONDS", revName = "> THE EXILE <",       revDesc = "NEVER UNDERESTIMATE BLIND FAITH." },
    { initOrder = 8, nameOrder = 6, id = 'AS', lockfull = 'lockfull-8',         name = 'allspin',    fullName = "< ALL-SPIN >",            desc = "KEYBOARD AVAILABLE, BUT DOUBLE CLICKING IS PENALIZED",    revName = "> THE WARLOCK <",     revDesc = "INTO REALMS BEYOND HEAVEN AND EARTH." },
    { initOrder = 9, nameOrder = 9, id = 'DP', lockover = 'lockover-supporter', name = 'duo',        fullName = "< DUO >",                 desc = "FLOOD THE TOWER WITH SOMEONE DOESN'T EXIST",              revName = "> BLEEDING HEARTS <", revDesc = "EVEN AS WE BLEED, WE KEEP HOLDING ON..." },
    lock = { fullName = "< LOCKED >", desc = "REACH HIGHER FLOOR TO UNLOCK" },
    lockDP = { fullName = "< LOCKED >", desc = "MASTER THIS MOD TO UNLOCK?" },
}
Mod = {
    weight = {
        EX = 13, --  8 + 5
        NH = 12, --  8 + 4
        MS = 14, -- 10 + 4
        GV = 12, -- 10 + 2
        VL = 17, -- 15 + 2
        DH = 12, --  8 + 4
        IN = 7,  --  6 + 1
        AS = 13, -- 10 + 3
        DP = 4,  --  3 + 1
    },
    color = {
        EX = { COLOR.HEX "89590B" },
        NH = { COLOR.HEX "FF00D4" },
        MS = { COLOR.HEX "FFB400" },
        GV = { COLOR.HEX "FFFF00" },
        VL = { COLOR.HEX "FF1500" },
        DH = { COLOR.HEX "47ACFF" },
        IN = { COLOR.HEX "BD24FF" },
        AS = { COLOR.HEX "00FED4" },
        DP = { COLOR.HEX "FF8C9D" },
    },
    textColor = {
        EX = { COLOR.HEX "C29F68" },
        NH = { COLOR.HEX "FF8BEC" },
        MS = { COLOR.HEX "FFD572" },
        GV = { COLOR.HEX "F7FF8A" },
        VL = { COLOR.HEX "FF978D" },
        DH = { COLOR.HEX "A6D5FF" },
        IN = { COLOR.HEX "E8B3FF" },
        AS = { COLOR.HEX "93FFE0" },
        DP = { COLOR.HEX "FFC0C9" },
    },
    prio = { IN = 0, MS = 1, VL = 2, NH = 3, DH = 4, AS = 5, GV = 6, EX = 7, DP = 8, rIN = 0, rMS = 1, rVL = 2, rNH = 3, rDH = 4, rAS = 5, rGV = 6, rEX = 7, rDP = 8 },
    adj = {
        IN = "INVISIBLE",
        MS = "MESSY",
        VL = "VOLATILE",
        NH = "HOLDLESS",
        DH = "DOUBLE HOLE",
        AS = "ALL-SPIN",
        GV = "GRAVITY",
        EX = "EXPERT",
        DP = "DUO",
        rIN = "BELIEVED",
        rMS = "DECEPTIVE",
        rVL = "DESPERATE",
        rNH = "ASCENDANT",
        rDH = "DAMNED",
        rAS = "OMNI-SPIN",
        rGV = "COLLAPSED",
        rEX = "TYRANNICAL",
        rDP = "PIERCING",
    },
    noun = {
        IN = "INVISIBLITY",
        MS = "MESSINESS",
        VL = "VOLATILITY",
        NH = "NO HOLD",
        DH = "DOUBLE HOLE",
        AS = "ALL-SPIN",
        GV = "GRAVITY",
        EX = "EXPERT",
        DP = "DUO",
        rIN = "BELIEF",
        rMS = "DECEPTION",
        rVL = "DESPERATION",
        rNH = "ASCENSION",
        rDH = "DAMNATION",
        rAS = "OMNI-SPIN",
        rGV = "COLLAPSE",
        rEX = "TYRANNY",
        rDP = "HEARTACHE",
    },
}

BasicComboCount = 9
Combos = require "module/combo_data"
for i = 1, #Combos do
    local cmb = Combos[i]
    cmb.name = '"' .. cmb.name:upper() .. '"'
    local cmbStr = table.concat(TABLE.sort(cmb.set:trim():split('%s+', true)), ' ')
    Combos[cmbStr] = Combos[cmbStr] or cmb
end

Floors = {
    { top = 50,   event = {},                                                 name = "Hall of Beginnings" },
    { top = 150,  event = { 'dmgDelay', -2, 'dmgWrong', 1 },                  name = "The Hotel" },
    { top = 300,  event = { 'dmgDelay', -2, 'dmgCycle', -.5 },                name = "The Casino" },
    { top = 450,  event = { 'dmgDelay', -1, 'dmgCycle', -.5 },                name = "The Arena" },
    { top = 650,  event = { 'dmgDelay', -1, 'dmgCycle', -.5, 'dmgWrong', 1 }, name = "The Museum" },
    { top = 850,  event = { 'dmgDelay', -1, 'dmgTime', 1 },                   name = "Abandoned Offices" },
    { top = 1100, event = { 'dmgDelay', -1, 'dmgCycle', -.5 },                name = "The Laboratory" },
    { top = 1350, event = { 'dmgDelay', -1, 'dmgCycle', -.5 },                name = "The Core" },
    { top = 1650, event = { 'dmgDelay', -.5, 'dmgWrong', 1 },                 name = "Corruption" },
    { top = 1e99, event = { 'dmgDelay', -.5, 'dmgCycle', -.5, 'dmgTime', 1 }, name = "Platform of The Gods" },
    -- Initial: Delay=15. Cycle=5, Wrong=1
    -- Total: Delay-10, Cycle-3, Wrong+4
}

Fatigue = {
    normal = {
        { time = 300, event = { 'dmgTimeMul', -.1 }, text = "FATIGUE SETS IN…", desc = "DmgDelay--" },
        { time = 330, event = { 'dmgCycle', -.5, 'dmgWrong', 1 }, text = "YOUR BODY GROWS WEAK…", desc = "DmgCycle--   Damage++" },
        { time = 360, event = { 'dmgTimeMul', -.1, 'dmgHeal', -1 }, text = "ALL SENSES BLUR TOGETHER…", desc = "DmgDelay--   Heal--" },
        { time = 390, event = { 'dmgTimeMul', -.1, 'dmgWrong', 1 }, text = "YOUR CONSCIOUSNESS FADES…", desc = "DmgDelay--   DmgCycle--" },
        { time = 420, event = { 'dmgTimeMul', -.2, 'dmgCycle', -.5 }, text = "THIS IS THE END", desc = "DmgDelay--   Damage++" },
        { time = 1e99 }, -- Total: dmgTimeMul-50%, Cycle-1, Wrong+2
    },
    rEX = {
        { time = 240, event = { 'dmgTimeMul', -.2 }, text = "YOUR POWER SLIPS…", desc = "DmgDelay--" },
        { time = 270, event = { 'dmgWrong', 2 }, text = "WHISPERS OF DISCONTENT SPREAD…", desc = "Damage++" },
        { time = 300, event = { 'dmgCycle', -1 }, text = "PROTESTERS LINE THE STREETS…", desc = "DmgCycle--" },
        { time = 330, event = { 'dmgTimeMul', -.2, 'dmgWrong', 2, }, text = "YOUR CLOSEST ALLIES DEFECT…", desc = "DmgDelay--   Damage++" },
        { time = 360, event = { 'dmgTimeMul', -.2, 'dmgHeal', -1 }, text = "PARANOIA CLOUDS YOUR JUDGEMENT…", desc = "DmgCycle--   Heal--" },
        { time = 390, event = { 'dmgCycle', -.5, 'dmgWrong', 1 }, text = "THE REVOLUTION HAS BEGUN…", desc = "DmgDelay--   Damage++" },
        { time = 420, event = { 'dmgTimeMul', -.3 }, text = "THE END OF AN ERA", desc = "DmgDelay--" },
        { time = 1e99 }, -- Total: dmgTimeMul-90%, Cycle-1, Wrong+5
    },
    rDP = {
        { time = 030, event = {}, text = [[THE RELATIONSHIP STAGNATES…]] }, -- garbage becomes a bit messier
        { time = 060, event = {}, text = [[INSECURITIES GROW STRONGER…]] }, -- garbage becomes messier
        { time = 090, event = {}, text = [[%p2 FEELS NEGLECTED…]] }, -- garbage becomes much messier
        { time = 120, event = {}, text = [[%p1 SUCCESSFULLY APOLOGIZES…?]] }, -- garbage becomes a bit cleaner
        { time = 150, event = {}, text = [[THINGS ARE BACK TO HOW THEY SHOULD BE…!]] }, -- garbage becomes much cleaner
        { time = 180, event = {}, text = [[THE WEIGHT OF WORDS UNSPOKEN…]] }, -- garbage becomes messier
        { time = 210, event = {}, text = [["WHY CAN'T YOU JUST LISTEN TO ME?"]] }, -- garbage becomes much messier
        { time = 240, event = {}, text = [["THIS IS ALL YOUR FAULT".]] }, -- revive difficulty increased
        { time = 270, event = {}, text = [[%p2 MAKES THE SAME PROMISE AGAIN…]] }, -- garbage becomes cleaner
        { time = 300, event = {}, text = [["THIS TIME WILL BE DIFFERENT."]] }, -- +4 PERMANENT GARBAGE
        { time = 330, event = {}, text = [[SOME HABITS CAN'T BE BROKEN…]] }, -- garbage becomes much messier
        { time = 360, event = {}, text = [[ALL TRUST HAS WITHERED AWAY…]] }, -- garbage becomes messier
        { time = 390, event = {}, text = [[%p1 SETS AN ULTIMATUM…]] }, -- garbage becomes messier
        { time = 420, event = {}, text = [[%p2 CONTEMPLATES THEIR WASTED EFFORT…]] }, -- garbage becomes messier
        { time = 450, event = {}, text = [[ONE LAST PAINFUL ARGUMENT…]] }, -- receive 25% more garbage
        { time = 480, event = {}, text = [[GOODBYE.]] }, -- you can no longer revive
        { time = 510, event = {}, text = [["I MISS YOU"]] }, -- garbage becomes much cleaner
        { time = 540, event = {}, text = [[WHAT IF…?]] }, -- garbage becomes a bit cleaner
        { time = 570, event = {}, text = [[…]] }, -- +12 PERMANENT GARBAGE
        { time = 1e99 },
    },
}

GravityTimer = {
    { 9.0, 8.0, 7.5, 7.0, 6.5, 6.0, 5.5, 5.0, 4.5, 4.0 },
    { 3.2, 3.0, 2.8, 2.6, 2.5, 2.4, 2.3, 2.2, 2.1, 2.0 },
}

for i = 1, #DeckData do table.insert(Cards, require 'module/card'.new(DeckData[i])) end
GAME.refreshLayout()
for i, C in ipairs(Cards) do
    Cards[C.id], C.x, C.y = C, C.tx, C.ty + 260 + 26 * 1.6 ^ i
end

SCN.add('tower', require 'module/tower')
SCN.add('joining', require 'module/joining')
ZENITHA.setFirstScene('joining')

ZENITHA.globalEvent.drawCursor = NULL
ZENITHA.globalEvent.clickFX = NULL

local _keyDown_orig = ZENITHA.globalEvent.keyDown
function ZENITHA.globalEvent.keyDown(key)
    if _keyDown_orig(key) then return true end
    if key == 'f11' then
        love.window.setFullscreen(not love.window.getFullscreen())
        return true
    elseif key == 'f12' then
        MSG('check', "Zenith Clicker is powered by Love2d & Zenitha, not Web!")
        return true
    end
end

local gc = love.graphics
function WIDGET._prototype.button:draw()
    gc.push('transform')
    gc.translate(self._x, self._y + DeckPress)

    if self._pressTime > 0 then
        gc.scale(1 - self._pressTime / self._pressTimeMax * .0626)
    end
    local w, h = self.w, self.h

    local fillC = self.fillColor
    local frameC = self.frameColor

    -- Background
    gc.setColor(fillC[1], fillC[2], fillC[3], fillC[4])
    GC.mRect('fill', 0, 0, w, h)

    -- Frame
    gc.setLineWidth(self.lineWidth)
    gc.setColor(frameC[1] * .2, frameC[2] * .2, frameC[3] * .2)
    gc.line(-w / 2, h / 2, w / 2, h / 2, w / 2, -h / 2)
    gc.setColor(.2 + frameC[1] * .8, .2 + frameC[2] * .8, .2 + frameC[3] * .8)
    gc.line(-w / 2, h / 2, -w / 2, -h / 2, w / 2, -h / 2)

    -- Highlight
    if self._hoverTime > 0 then
        gc.setColor(1, 1, 1, self._hoverTime / self._hoverTimeMax * .16)
        GC.mRect('fill', 0, 0, w, h)
    end

    -- Drawable
    gc.setColor(self.textColor)
    WIDGET._alignDraw(self, self._text, 0, 0, nil, 1, 1.15 * (1 - 2 * GAME.revTimer))

    gc.pop()
end

-- Muisc syncing daemon
function Daemon_Sync()
    local lib = BGM._srcLib
    local set = BgmSets.all
    coroutine.yield()
    local length = BGM.getDuration()
    while true do
        local t0 = lib[set[1]].source:tell()
        for i = #set, 2, -1 do
            local obj = lib[set[i]]
            local T = t0
            if set[i] == 'piano2' then T = T * 2 % length end
            if set[i] == 'violin2' then T = (T - 4 * 60 / 184) % length end
            if math.abs(obj.source:tell() - T) > 0.026 then
                -- print('Desync', set[i])
                obj.source:seek(T)
            end
        end
        TASK.yieldT(1)
    end
end

-- Throb tranpaency daemon
-- Messy position daemon
-- Expert guitar randomization daemon
function Daemon_Beat()
    local bar = 2 * 60 / 184 * 4
    local t1, step1 = -.1, 2 * 60 / 184
    local t2, step2 = 0, 2 * 60 / 184 / 4
    while true do
        local T = BGM.tell()
        ThrobAlpha.card = math.max(.626 - 2 * T / bar % 1, .626 - 2 * (T / bar - .375) % 1)
        ThrobAlpha.bg1 = .626 - 2 * T / bar % 1
        ThrobAlpha.bg2 = .626 - 2 * (T / bar - 1 / 32) % 1
        if T < t1 then t1 = -.1 end
        if T > t1 + step1 then
            t1 = t1 + step1
            for i = 1, 9 do
                Cards[i].visY = GAME.mod.MS * math.random(-6, 2)
            end
            GAME.refreshLayout()
        end
        if T < t2 then t2 = 0 end
        if T > t2 + step2 then
            t2 = t2 + step2
            if not GAME.playing and GAME.mod.EX > 0 and not GAME.anyRev then
                local v = MATH.roll(GAME.mod.EX == 1 and .26 or .626)
                BGM.set('expert', 'volume', v and MATH.rand(.42, .626) or 0, v and 0 or .1)
            end
        end
        coroutine.yield()
    end
end

-- Background transition deamon
function Daemon_Floor()
    local bg = Background
    while true do
        repeat TASK.yieldT(.1) until bg.floor ~= GAME.floor
        repeat
            bg.alpha = bg.alpha - coroutine.yield()
        until bg.alpha <= 0
        bg.floor = GAME.floor
        bg.alpha = 0
        repeat
            bg.alpha = bg.alpha + coroutine.yield()
        until bg.alpha >= 1
        bg.alpha = 1
    end
end

-- Load data
DATA.load()
local oldVer = DATA.version
if DATA.version == nil then
    for k in next, DATA.highScore do
        if k:find('rNH') or k:find('rMS') or k:find('rVL') or k:find('rAS') then
            DATA.highScore[k] = nil
        end
    end
    DATA.version = 162
end
if DATA.version ~= oldVer then DATA.save() end

-- Some Initialization
for i = 1, #Cards do
    local f10 = Floors[9].top
    local id = Cards[i].id
    local rid = 'r' .. id
    if DATA.highScore[rid] >= f10 then
        GAME.completion[id] = 2
    else
        for cmb, h in next, DATA.highScore do
            if h >= f10 and cmb:find(rid) then
                GAME.completion[id] = 2
                break
            end
        end
    end
    if GAME.completion[id] ~= 2 then
        if DATA.highScore[id] >= f10 then
            GAME.completion[id] = 1
        else
            for cmb, h in next, DATA.highScore do
                if h >= f10 and (cmb:gsub('r', ''):find(id) or 0) % 2 == 1 then
                    GAME.completion[id] = 1
                    break
                end
            end
        end
    end
end
GAME.refreshLockState()
GAME.refreshPBText()

-- Test
TASK.new(function()
    for _, s in next, ([[ ]]):trim():split('%s+', true) do
        TASK.yieldT(1)
        SFX.play(s)
        love.window.setIcon(love.image.newImageData('assets/icon.png'))
    end
end)

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
