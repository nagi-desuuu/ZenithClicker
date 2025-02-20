require 'Zenitha'

ZENITHA.setMainLoopSpeed(240)
ZENITHA.setRenderRate(50)
ZENITHA.setShowFPS(false)
ZENITHA.setVersionText("")
ZENITHA.setClickDist(62)

STRING.install()

SCR.setSize(1600, 1000)

MSG.addCategory('dark', COLOR.lD, COLOR.L)

BGM.setMaxSources(8)
BGM.load {
    piano = 'assets/piano.ogg',
    expert = 'assets/expert.ogg',
    arp = 'assets/arp.ogg',
    bass = 'assets/bass.ogg',
    guitar = 'assets/guitar.ogg',
    pad = 'assets/pad.ogg',
    staccato = 'assets/staccato.ogg',
    violin = 'assets/violin.ogg',
}

SFX.load('assets/sfx.ogg', FILE.load('module/sfx_data.lua', '-luaon'))
SFX.setVol(.6)

IMG.init {
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

DATA = require 'module/data'

GAME = require 'module/game'

MX, MY = 0, 0

---@type Card[]
Cards = {}

---@type nil|number
FloatOnCard = nil

BgmSets = {
    all = { 'piano', 'expert', 'arp', 'bass', 'guitar', 'pad', 'staccato', 'violin' },
    extra = { 'arp', 'bass', 'guitar', 'pad', 'staccato', 'violin' },
}

DeckData = {
    { initOrder = 1, nameOrder = 8, id = 'EX', lockover = 'lockover-9',            name = 'expert',     fullName = "< EXPERT MODE >",         desc = "A LESS LENIENT CHALLENGE, FOR THOSE WHO DARE",                      revName = "> THE TYRANT <",      revDesc = "FEAR, OPPRESSION, AND LIMITLESS AMBITION." },
    { initOrder = 2, nameOrder = 4, id = 'NH', lockfull = 'lockfull-2',            name = 'nohold',     fullName = "< NO HOLD >",             desc = "CANCELING IS DISABLED",                                             revName = "> ASCETICISM <",      revDesc = "A DETACHMENT FROM EVEN THAT WHICH IS MODERATE." },
    { initOrder = 3, nameOrder = 2, id = 'MS', lockfull = 'lockfull-3',            name = 'messy',      fullName = "< MESSIER GARBAGE  >",    desc = "TAROTS WILL BE SHUFFLED BY FLOOR",                                  revName = "> LOADED DICE <",     revDesc = "IN A RIGGED GAME, YOUR MIND IS THE ONLY FAIR ADVANTAGE." },
    { initOrder = 4, nameOrder = 7, id = 'GV', lockfull = 'lockfull-4',            name = 'gravity',    fullName = "< GRAVITY >",             desc = "AUTO CLICK AND COMMIT, TIMED BY FLOOR",                             revName = "> FREEFALL <",        revDesc = "THE GROUND YOU STOOD ON NEVER EXISTED IN THE FIRST PLACE." },
    { initOrder = 5, nameOrder = 3, id = 'VL', lockfull = 'lockfull-5',            name = 'volatile',   fullName = "< VOLATILE GARBAGE >",    desc = "LARGER GAPS BETWEEN TAROTS, BUT MUST CLICK TWICE",                  revName = "> LAST STAND <",      revDesc = "STRENGTH ISN'T NECESSARY FOR THOSE WITH NOTHING TO LOSE." },
    { initOrder = 6, nameOrder = 5, id = 'DH', lockfull = 'lockfull-6',            name = 'doublehole', fullName = "< DOUBLE HOLE GARBAGE >", desc = "COMBOS WILL SPAWN HARDER",                                          revName = "> DAMNATION <",       revDesc = "NO MORE SECOND CHANCES." },
    { initOrder = 7, nameOrder = 1, id = 'IN', lockfull = 'lockfull-7',            name = 'invisible',  fullName = "< INVISIBLE >",           desc = "TAROTS FACE DOWN, AND HINTS FLASH ONCE EVERY TWO SECONDS",          revName = "> THE EXILE <",       revDesc = "NEVER UNDERESTIMATE BLIND FAITH." },
    { initOrder = 8, nameOrder = 6, id = 'AS', lockfull = 'lockfull-8',            name = 'allspin',    fullName = "< ALL-SPIN >",            desc = "KEYBOARD IS AVAILABLE, BUT TOUCHING SAME TAROT TWICE IS PENALIZED", revName = "> THE WARLOCK <",     revDesc = "INTO REALMS BEYOND HEAVEN AND EARTH." },
    { initOrder = 9, nameOrder = 9, id = '2P', lockover = 'lockover-incompatible', name = 'duo',        fullName = "< DUO >",                 desc = "FLOOD THE TOWER WITH SOMEONE DOESN'T EXIST",                        revName = "> BLEEDING HEARTS <", revDesc = "EVEN AS WE BLEED, WE KEEP HOLDING ON..." },
    [0] = { fullName = "< LOCKED >", desc = "REACH HIGHER FLOOR TO UNLOCK" },
}

ModWeight = {
    ['EX'] = 13, --  8 + 5
    ['NH'] = 12, --  8 + 4
    ['MS'] = 14, -- 10 + 4
    ['GV'] = 12, -- 10 + 2
    ['VL'] = 17, -- 15 + 2
    ['DH'] = 14, -- 10 + 4
    ['IN'] = 6,  --  5 + 1
    ['AS'] = 13, -- 10 + 3
    ['2P'] = 4,  --  3 + 1
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
    { top = 50,   event = {},                                                  name = "Hall of Beginnings" },
    { top = 150,  event = { 'dmgDelay', -2, 'dmgCycle', -.5, 'dmgWrong', 1 },  name = "The Hotel" },
    { top = 300,  event = { 'dmgDelay', -2, 'dmgCycle', -.5 },                 name = "The Casino" },
    { top = 450,  event = { 'dmgDelay', -1, 'dmgCycle', -.5 },                 name = "The Arena" },
    { top = 650,  event = { 'dmgDelay', -1, 'dmgCycle', -.5, 'dmgWrong', 1 },  name = "The Museum" },
    { top = 850,  event = { 'dmgDelay', -1 },                                  name = "Abandoned Offices" },
    { top = 1100, event = { 'dmgDelay', -1, 'dmgCycle', -.5 },                 name = "The Laboratory" },
    { top = 1350, event = { 'dmgDelay', -1 },                                  name = "The Core" },
    { top = 1650, event = { 'dmgDelay', -.5, 'dmgCycle', -.5, 'dmgWrong', 1 }, name = "Corruption" },
    { top = 1e99, event = { 'dmgDelay', -.5, 'dmgCycle', -.5, 'dmgTime', 2 },  name = "Platform of The Gods" },
    -- Initial: Delay=15. Cycle=5, Wrong=1
    -- Total: Delay-10, Cycle-3.5, Wrong+4
}

Fatigue = {
    { time = 300, event = { 'dmgDelay', -1 }, text = "FATIGUE SETS IN…" },
    { time = 330, event = { 'dmgCycle', -.5 }, text = "YOUR BODY GROWS WEAK…" },
    { time = 360, event = { 'dmgDelay', -1, 'dmgHeal', -1 }, text = "ALL SENSES BLUR TOGETHER…" },
    { time = 390, event = { 'dmgCycle', -.5, 'dmgWrong', 1 }, text = "YOUR CONSCIOUSNESS FADES…" },
    { time = 420, event = { 'dmgDelay', -1, 'dmgWrong', 1 }, text = "THIS IS THE END" },
    { time = 1e99 }, -- Total: Delay-3, Cycle-1, Wrong+2
}
FatigueRevEx = {
    { time = 240, event = { 'dmgDelay', -1 }, text = "YOUR POWER SLIPS…" },
    { time = 270, event = { 'dmgWrong', 1 }, text = "WHISPERS OF DISCONTENT SPREAD…" },
    { time = 300, event = { 'dmgCycle', -.5, 'dmgWrong', 1 }, text = "PROTESTERS LINE THE STREETS…" },
    { time = 330, event = { 'dmgDelay', -1, 'dmgWrong', 2, }, text = "YOUR CLOSEST ALLIES DEFECT…" },
    { time = 360, event = { 'dmgCycle', -1, 'dmgHeal', -1 }, text = "PARANOIA CLOUDS YOUR JUDGEMENT…" },
    { time = 390, event = { 'dmgDelay', -.5, 'dmgWrong', 1 }, text = "THE REVOLUTION HAS BEGUN…" },
    { time = 420, event = { 'dmgDelay', -.5 }, text = "THE END OF AN ERA" },
    { time = 1e99 }, -- Total: Delay-3, Cycle-1, Wrong+5
}

MessyBias = TABLE.new(0, 9)

for i = 1, #DeckData do table.insert(Cards, require 'module/card'.new(DeckData[i])) end
GAME.refreshLayout()
for i, C in ipairs(Cards) do
    Cards[C.id], C.x, C.y = C, C.tx, C.ty + 260 + 26 * 1.6 ^ i
end

SCN.add('main', require 'module/tower')
ZENITHA.setFirstScene('main')

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

function ZENITHA.globalEvent.quit()
    DATA.flush()
    love.timer.sleep(.1)
end

BGM.play(BgmSets.all)
BGM.set('all', 'volume', 0, 0)
BGM.set('piano', 'volume', 1)
-- BGM.set(BgmSets.extra, 'volume', 1, 10)
BGM.set(TABLE.getRandom(BgmSets.extra), 'volume', 1, 10)

-- Desync fixing daemon
TASK.new(function()
    local lib = BGM._srcLib
    while true do
        TASK.yieldT(1)
        local t0 = lib[BgmSets.all[1]].source:tell()
        for i = 2, #BgmSets.all do
            local obj = lib[BgmSets.all[i]]
            if math.abs(obj.source:tell() - t0) > 0.026 then
                obj.source:seek(t0)
            end
        end
    end
end)

-- Messy position daemon
-- Expert guitar randomization daemon
TASK.new(function()
    local t1, step1 = -.1, 2 * 60 / 184
    local t2, step2 = 0, 2 * 60 / 184 / 4
    while true do
        local T = BGM.tell()
        if T < t1 then t1 = -.1 end
        if T > t1 + step1 then
            t1 = t1 + step1
            if GAME.mod_MS > 0 then
                for i = 1, 9 do
                    MessyBias[i] = Cards[i].active and math.random(-6, 2) or math.random(-2, 6)
                end
                GAME.refreshLayout()
            end
        end
        if T < t2 then t2 = 0 end
        if T > t2 + step2 then
            t2 = t2 + step2
            if not GAME.playing and GAME.mod_EX > 0 then
                local v = MATH.roll(.626)
                BGM.set('expert', 'volume', v and MATH.rand(.42, .626) or 0, v and 0 or .1)
            end
        end
        coroutine.yield()
    end
end)

-- Background transition deamon
TASK.new(function()
    while true do
        repeat TASK.yieldT(.1) until GAME.bgFloor ~= GAME.floor
        repeat
            GAME.bgAlpha = GAME.bgAlpha - coroutine.yield()
        until GAME.bgAlpha <= 0
        GAME.bgFloor = GAME.floor
        GAME.bgAlpha = 0
        repeat
            GAME.bgAlpha = GAME.bgAlpha + coroutine.yield()
        until GAME.bgAlpha >= 1
        GAME.bgAlpha = 1
    end
end)

-- Load data
DATA.load()
GAME.refreshLockState()

-- Test
TASK.new(function()
    for _, s in next, ([[ ]]):split('%s+', true) do
        SFX.play(s)
        TASK.yieldT(1)
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
