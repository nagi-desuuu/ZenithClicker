require 'Zenitha'

ZENITHA.setMainLoopSpeed(120)
ZENITHA.setShowFPS(false)
ZENITHA.setVersionText("")

STRING.install()

SCR.setSize(1600, 1000)

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
    { initOrder = 6, nameOrder = 5, id = 'DH', lockfull = 'lockfull-6',            name = 'doublehole', fullName = "< DOUBLE HOLE GARBAGE >", desc = "COMBOS MAY SPAWN HARDER",                                           revName = "> DAMNATION <",       revDesc = "NO MORE SECOND CHANCES." },
    { initOrder = 7, nameOrder = 1, id = 'IN', lockfull = 'lockfull-7',            name = 'invisible',  fullName = "< INVISIBLE >",           desc = "TAROTS FACE DOWN, AND HINTS FLASH ONCE EVERY TWO SECONDS",          revName = "> THE EXILE <",       revDesc = "NEVER UNDERESTIMATE BLIND FAITH." },
    { initOrder = 8, nameOrder = 6, id = 'AS', lockfull = 'lockfull-8',            name = 'allspin',    fullName = "< ALL-SPIN >",            desc = "KEYBOARD IS AVAILABLE, BUT TOUCHING SAME TAROT TWICE IS PENALIZED", revName = "> THE WARLOCK <",     revDesc = "INTO REALMS BEYOND HEAVEN AND EARTH." },
    { initOrder = 9, nameOrder = 9, id = '2P', lockover = 'lockover-incompatible', name = 'duo',        fullName = "< DUO >",                 desc = "FLOOD THE TOWER WITH SOMEONE DOESN'T EXIST",                        revName = "> BLEEDING HEARTS <", revDesc = "EVEN AS WE BLEED, WE KEEP HOLDING ON..." },
    [0] = { fullName = "< LOCKED >", desc = "REACH HIGHER FLOOR TO UNLOCK" },
}
local modName = {
    prio = {
        ['IN'] = 0,
        ['MS'] = 1,
        ['VL'] = 2,
        ['NH'] = 3,
        ['DH'] = 4,
        ['AS'] = 5,
        ['GV'] = 6,
        ['EX'] = 7,
        ['2P'] = 8,
    },
    adj = {
        ['IN'] = "INVISIBLE",
        ['MS'] = "MESSY",
        ['VL'] = "VOLATILILE",
        ['NH'] = "HOLDLESS",
        ['DH'] = "DOUBLE HOLE",
        ['AS'] = "ALL-SPIN",
        ['GV'] = "GRAVITY",
        ['EX'] = "EXPERT",
        ['2P'] = "DUO",
    },
    noun = {
        ['IN'] = "INVISIBLITY",
        ['MS'] = "MESSINESS",
        ['VL'] = "VOLATILILITY",
        ['NH'] = "NO HOLD",
        ['DH'] = "DOUBLE HOLE",
        ['AS'] = "ALL-SPIN",
        ['GV'] = "GRAVITY",
        ['EX'] = "EXPERT",
        ['2P'] = "DUO",
    },
}

Combos = {
    { name = [["A MODERN CLASSIC"]],     check = 'NH GV' },
    { name = [["DEADLOCK"]],             check = 'MS NH DH' },
    { name = [["THE ESCAPE ARTIST"]],    check = 'MS DH AS' },
    { name = [["THE GRANDMASTER"]],      check = 'IN GV' },
    { name = [["EMPEROR'S DECADENCE"]],  check = 'NH DH EX' },
    { name = [["DIVINE MASTERY"]],       check = 'MS VL DH EX' },
    { name = [["THE STARVING ARTIST"]],  check = 'NH AS' },
    { name = [["THE CON ARTIST"]],       check = 'VL AS EX' },
    { name = [["TRAINED PROFESIONALS"]], check = 'EX 2P' },
    { name = [["SWAMP WATER LITE"]],     check = function(i) return #i == 7 * 3 - 1 and not i:find('2P') end },
    { name = [["SWAMP WATER"]],          check = function(i) return #i == 8 * 3 - 1 and not i:find('2P') end },
}
for _, cmb in next, Combos do
    if type(cmb.check) == 'string' then
        local cmbStr = table.concat(TABLE.sort(cmb.check:split(' ')), ' ')
        cmb.check = function(i)
            return i == cmbStr
        end
    end
end

Floors = {
    { top = 50,   event = {},                                name = "Hall of Beginnings",   sfx = false },
    { top = 150,  event = { 'dmgWrong', 1 },                 name = "The Hotel",            sfx = "c" },
    { top = 300,  event = { 'dmgDelay', -1 },                name = "The Casino",           sfx = "b" },
    { top = 450,  event = { 'dmgCycle', -1 },                name = "The Arena",            sfx = "a" },
    { top = 650,  event = { 'dmgDelay', -1 },                name = "The Museum",           sfx = "fsharp" },
    { top = 850,  event = { 'dmgWrong', 1 },                 name = "Abandoned Offices",    sfx = "e" },
    { top = 1100, event = { 'dmgDelay', -1 },                name = "The Laboratory",       sfx = "a" },
    { top = 1350, event = { 'dmgDelay', -1 },                name = "The Core",             sfx = "ahalfsharp" },
    { top = 1650, event = { 'dmgDelay', -1, 'dmgWrong', 1 }, name = "Corruption",           sfx = "e" },
    { top = 1e99, event = { 'dmgDelay', -1, 'dmgWrong', 1 }, name = "Platform of The Gods", sfx = "e" },
    -- Initial: Delay=15. Cycle=3, Wrong=1
    -- Total: Delay-7, Cycle-1, Wrong+4
}

Fatigue = {
    { time = 360, event = { 'dmgDelay', -1 }, text = "FATIGUE SETS IN…" },
    { time = 420, event = { 'dmgCycle', -1 }, text = "YOUR BODY GROWS WEAK…" },
    { time = 480, event = { 'dmgDelay', -1, 'dmgHeal', -1 }, text = "ALL SENSES BLUR TOGETHER…" },
    { time = 540, event = { 'dmgDelay', -1, 'dmgWrong', 1 }, text = "YOUR CONSCIOUSNESS FADES…" },
    { time = 600, event = { 'dmgDelay', -2, 'dmgWrong', 1 }, text = "THIS IS THE END" },
    { time = 1e99 }, -- Total: Delay-5, Cycle-1, Wrong+2
}
FatigueRevEx = {
    { time = 300, event = { 'dmgDelay', -2 }, text = "YOUR POWER SLIPS…" },
    { time = 360, event = { 'dmgCycle', -.5, 'dmgWrong', 1 }, text = "WHISPERS OF DISCONTENT SPREAD…" },
    { time = 420, event = { 'dmgCycle', -.5, 'dmgWrong', 1 }, text = "PROTESTERS LINE THE STREETS…" },
    { time = 480, event = { 'dmgCycle', -.5, 'dmgWrong', 2, }, text = "YOUR CLOSEST ALLIES DEFECT…" },
    { time = 540, event = { 'dmgDelay', -2, 'dmgHeal', -1 }, text = "PARANOIA CLOUDS YOUR JUDGEMENT…" },
    { time = 600, event = { 'dmgDelay', -1.5, 'dmgWrong', 1 }, text = "THE REVOLUTION HAS BEGUN…" },
    { time = 660, event = { 'dmgDelay', -2 }, text = "THE END OF AN ERA" },
    { time = 1e99 }, -- Total: Delay-7.5, Cycle-1.5, Wrong+5
}

MessyBias = TABLE.new(0, 9)
function RefreshLayout()
    local baseDist = (GAME.mod_EX > 0 and 100 or 110) + GAME.mod_VL * 20
    local baseL, baseR = 800 - 4 * baseDist - 70, 800 + 4 * baseDist + 70
    local dodge = GAME.mod_VL < 1 and 260 or 220
    local baseY = 726 + 15 * GAME.mod_GV
    if FloatOnCard then
        local selX = 800 + (FloatOnCard - 5) * baseDist
        for i, c in next, Cards do
            if i < FloatOnCard then
                c.tx = MATH.interpolate(1, baseL, FloatOnCard - 1, selX - dodge, i)
                if c.tx ~= c.tx then c.tx = baseL end
            elseif i > FloatOnCard then
                c.tx = MATH.interpolate(#Cards, baseR, FloatOnCard + 1, selX + dodge, i)
                if c.tx ~= c.tx then c.tx = baseR end
            else
                c.tx = selX
            end
            c.ty = baseY - (c.active and 35 or 0) - (i == FloatOnCard and 55 or 0)
        end
    else
        for i, c in next, Cards do
            c.tx = 800 + (i - 5) * baseDist
            c.ty = baseY - (c.active and 35 or 0) - (i == FloatOnCard and 55 or 0)
        end
    end
    if GAME.mod_MS > 0 then
        for i = 1, 9 do
            Cards[i].ty = Cards[i].ty + MessyBias[i]
        end
    end
end

function MouseOnCard(x, y)
    if FloatOnCard and Cards[FloatOnCard]:mouseOn(x, y) then
        return FloatOnCard
    end
    for i = #Cards, 1, -1 do
        if Cards[i]:mouseOn(x, y) then
            return i
        end
    end
end

function GetComboName(list)
    if not list then
        list = {}
        for _, C in next, Cards do
            if C.active then
                table.insert(list, C.id)
            end
        end
    end

    if #list == 0 then return "" end
    if #list == 1 then return modName.noun[list[1]] end

    local str = table.concat(TABLE.sort(list), ' ')
    for _, cmb in next, Combos do
        if cmb.check(str) then
            return cmb.name
        end
    end

    str = ""
    table.sort(list, function(a, b) return modName.prio[a] < modName.prio[b] end)
    for i = 1, #list - 1 do str = str .. modName.adj[list[i]] .. " " end
    return str .. modName.noun[list[#list]]
end

for i = 1, #DeckData do table.insert(Cards, require 'module/card'.new(DeckData[i])) end
RefreshLayout()
for i, C in next, Cards do C.x, C.y = C.tx, C.ty + 260 + 26 * 1.6 ^ i end

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
TASK.new(function()
    local t = -.1
    local step = 2 * 60 / 184
    while true do
        local T = BGM.tell()
        if T < t then t = -.1 end
        if T > t + step then
            t = t + step
            if GAME.mod_MS > 0 then
                for i = 1, 9 do
                    MessyBias[i] = Cards[i].active and math.random(-6, 2) or math.random(-2, 6)
                end
                RefreshLayout()
            end
        end
        coroutine.yield()
    end
end)

-- Load data
DATA.load()
GAME:freshLockState()

-- Test
TASK.new(function()
    for _, s in next, ([[]]):split('%s+', true) do
        SFX.play(s)
        TASK.yieldT(1)
    end
end)
