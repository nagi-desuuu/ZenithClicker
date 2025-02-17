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
    { initOrder = 0, nameOrder = 7, name = 'expert',     id = 'EX', lockover = 'lockover-9' },
    { initOrder = 1, nameOrder = 3, name = 'nohold',     id = 'NH', lockfull = 'lockfull-2' },
    { initOrder = 2, nameOrder = 1, name = 'messy',      id = 'MS', lockfull = 'lockfull-3' },
    { initOrder = 3, nameOrder = 6, name = 'gravity',    id = 'GV', lockfull = 'lockfull-4' },
    { initOrder = 4, nameOrder = 2, name = 'volatile',   id = 'VL', lockfull = 'lockfull-5' },
    { initOrder = 5, nameOrder = 4, name = 'doublehole', id = 'DH', lockfull = 'lockfull-6' },
    { initOrder = 6, nameOrder = 0, name = 'invisible',  id = 'IN', lockfull = 'lockfull-7' },
    { initOrder = 7, nameOrder = 5, name = 'allspin',    id = 'AS', lockfull = 'lockfull-8' },
    { initOrder = 8, nameOrder = 8, name = 'duo',        id = '2P', lockover = 'lockover-incompatible' },
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
    { name = [["A MODERN CLASSIC"]],    check = 'NH GV' },
    { name = [["DEADLOCK"]],            check = 'MS NH DH' },
    { name = [["THE ESCAPE ARTIST"]],   check = 'MS DH AS' },
    { name = [["THE GRANDMASTER"]],     check = 'IN GV' },
    { name = [["EMPEROR'S DECADENCE"]], check = 'NH DH EX' },
    { name = [["DIVINE MASTERY"]],      check = 'MS VL DH EX' },
    { name = [["THE STARVING ARTIST"]], check = 'NH AS' },
    { name = [["THE CON ARTIST"]],      check = 'VL AS EX' },
    { name = [["SWAMP WATER LITE"]],    check = function(i) return #i == 7 * 3 - 1 and not i:find('2P') end },
    { name = [["SWAMP WATER"]],         check = function(i) return #i == 8 * 3 - 1 and not i:find('2P') end },
    -- THE TYRANT
    -- ASCETICISM
    -- LOADED DICE
    -- FREEFALL
    -- LAST STAND
    -- DAMNATION
    -- THE EXILE
    -- THE WARLOCK
    -- BLEEDING HEARTS
}
for _, cmb in next, Combos do
    if type(cmb.check) == 'string' then
        local list = cmb.check:split(' ')
        table.sort(list)
        local cmbStr = table.concat(list, ' ')
        cmb.check = function(i)
            return i == cmbStr
        end
    end
end

Fatigue = {
    { time = 360, event = function() --[[TODO]] end, text = "FATIGUE SETS IN…" },
    { time = 420, event = function() --[[TODO]] end, text = "YOUR BODY GROWS WEAK…" },
    { time = 480, event = function() --[[TODO]] end, text = "ALL SENSES BLUR TOGETHER…" },
    { time = 540, event = function() --[[TODO]] end, text = "YOUR CONSCIOUSNESS FADES…" },
    { time = 600, event = function() --[[TODO]] end, text = "THIS IS THE END." },
    { time = 1e99 },
}
FatigueRevEx = {
    { time = 300, event = function() --[[TODO]] end, text = "YOUR POWER SLIPS…" },
    { time = 360, event = function() --[[TODO]] end, text = "WHISPERS OF DISCONTENT SPREAD…" },
    { time = 420, event = function() --[[TODO]] end, text = "PROTESTERS LINE THE STREETS…" },
    { time = 480, event = function() --[[TODO]] end, text = "YOUR CLOSEST ALLIES DEFECT…" },
    { time = 540, event = function() --[[TODO]] end, text = "PARANOIA CLOUDS YOUR JUDGEMENT…" },
    { time = 600, event = function() --[[TODO]] end, text = "THE REVOLUTION HAS BEGUN…" },
    { time = 660, event = function() --[[TODO]] end, text = "THE END OF AN ERA." },
    { time = 1e99 },
}

MessyBias = TABLE.new(0, 9)
function RefreshLayout()
    local baseDist = 110 + GAME.mod_VL * 20
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

    table.sort(list)
    local str = table.concat(list, ' ')
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

for _, d in next, DeckData do table.insert(Cards, require 'module/card'.new(d)) end
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

function ZENITHA.globalEvent.requestQuit()
    BGM.set('all', 'volume', 0)
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
    local step = 60 / 184
    while true do
        local T = BGM.tell()
        if T < t then t = -.1 end
        if T > t + step then
            t = t + step
            if GAME.mod_MS > 0 then
                for i = 1, 9 do
                    MessyBias[i] = math.random(-5, 5)
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
    for _, s in next, {
        '',
    } do
        SFX.play(s)
        TASK.yieldT(1)
    end
end)
