love.window.setIcon(love.image.newImageData('assets/icon.png'))

require 'Zenitha'

ZENITHA.setMainLoopSpeed(240)
ZENITHA.setRenderRate(50)
ZENITHA.setShowFPS(false)
ZENITHA.setVersionText(require 'version'.appVer)
ZENITHA.setClickDist(62)

STRING.install()

SCR.setSize(1600, 1000)

MSG.setSafeY(75)
MSG.addCategory('dark', COLOR.lD, COLOR.L)

---@return love.Texture
local function p(path) return 'assets/' .. path end
local function q(x, y, size) return GC.newQuad(x * size, y * size, size, size, size * 5, size * 2) end
TEXTURE = {
    star0 = p 'crystal-dark.png',
    star1 = p 'crystal.png',
    panel = {
        glass_a = p 'panel/glass-a.png',
        glass_b = p 'panel/glass-b.png',
        throb_a = p 'panel/throb-a.png',
        throb_b = p 'panel/throb-b.png',
    },
    icon = {
        ingame = p 'icon/ingame.png',
        ingame_rev = p 'icon/ingame_rev.png',
        result = p 'icon/result.png',
        result_rev = p 'icon/result_rev.png',
        quad = {
            ingame = {
                VL = q(0, 0, 128),
                NH = q(1, 0, 128),
                MS = q(2, 0, 128),
                IN = q(3, 0, 128),
                GV = q(4, 0, 128),
                EX = q(0, 1, 128),
                DP = q(1, 1, 128),
                DH = q(2, 1, 128),
                AS = q(3, 1, 128),
            },
            ingame_rev = {
                VL = q(0, 0, 219),
                NH = q(1, 0, 219),
                MS = q(2, 0, 219),
                IN = q(3, 0, 219),
                GV = q(4, 0, 219),
                EX = q(0, 1, 219),
                DP = q(1, 1, 219),
                DH = q(2, 1, 219),
                AS = q(3, 1, 219),
            },
            result = {
                VL = q(0, 0, 183),
                NH = q(1, 0, 183),
                MS = q(2, 0, 183),
                IN = q(3, 0, 183),
                GV = q(4, 0, 183),
                EX = q(0, 1, 183),
                DP = q(1, 1, 183),
                DH = q(2, 1, 183),
                AS = q(3, 1, 183),
            },
            result_rev = {
                VL = q(0, 0, 183),
                NH = q(1, 0, 183),
                MS = q(2, 0, 183),
                IN = q(3, 0, 183),
                GV = q(4, 0, 183),
                EX = q(0, 1, 183),
                DP = q(1, 1, 183),
                DH = q(2, 1, 183),
                AS = q(3, 1, 183),
            },
        },
    },
    EX = { lock = p 'card/lockover-9.png', front = p 'card/expert.png', back = p 'card/expert-back.png', throb = p 'card/expert-throb.png', },
    NH = { lock = p 'card/lockfull-2.png', front = p 'card/nohold.png', back = p 'card/nohold-back.png', throb = p 'card/nohold-throb.png', },
    MS = { lock = p 'card/lockfull-3.png', front = p 'card/messy.png', back = p 'card/messy-back.png', throb = p 'card/messy-throb.png', },
    GV = { lock = p 'card/lockfull-4.png', front = p 'card/gravity.png', back = p 'card/gravity-back.png', throb = p 'card/gravity-throb.png', },
    VL = { lock = p 'card/lockfull-5.png', front = p 'card/volatile.png', back = p 'card/volatile-back.png', throb = p 'card/volatile-throb.png', },
    DH = { lock = p 'card/lockfull-6.png', front = p 'card/doublehole.png', back = p 'card/doublehole-back.png', throb = p 'card/doublehole-throb.png', },
    IN = { lock = p 'card/lockfull-7.png', front = p 'card/invisible.png', back = p 'card/invisible-back.png', throb = p 'card/invisible-throb.png', },
    AS = { lock = p 'card/lockfull-8.png', front = p 'card/allspin.png', back = p 'card/allspin-back.png', throb = p 'card/allspin-throb.png', },
    DP = { lock = p 'card/lockover-supporter.png', front = p 'card/duo.png', back = p 'card/duo-back.png', throb = p 'card/duo-throb.png', },
    floorBG = { p 'bg/1fa.jpg', p 'bg/2fa.jpg', p 'bg/3fa.jpg', p 'bg/4fa.jpg', p 'bg/5fa.jpg', p 'bg/6fa.jpg', p 'bg/7fa.jpg', p 'bg/8fa.jpg', p 'bg/9fa.jpg', p 'bg/10fa.jpg' },
}
local transition = { w = 128, h = 1 }
for x = 0, 127 do
    table.insert(transition, { 'setCL', 1, 1, 1, 1 - x / 128 })
    table.insert(transition, { 'fRect', x, 0, 1, 1 })
end
TEXTURE.transition = GC.load(transition)
TEXTURE = IMG.init(TEXTURE, true)

local fontNotLoaded = MATH.roll(.62)
if fontNotLoaded then
    FONT.load { tnr = "assets/Times New Roman.ttf" }
    FONT.setDefaultFont('tnr')
end
FONT.get(25):setLineHeight(0.9)
TEXTS = {
    mod        = GC.newText(FONT.get(30)),
    title      = GC.newText(FONT.get(50), "EXPERT QUICK PICK"),
    load       = GC.newText(FONT.get(60), "JOINING ROOM..."),
    pb         = GC.newText(FONT.get(50)),
    sr         = GC.newText(FONT.get(50)),
    endHeight  = GC.newText(FONT.get(50)),
    endTime    = GC.newText(FONT.get(30)),
    prevPB     = GC.newText(FONT.get(50), "PB"),
    height     = GC.newText(FONT.get(30, '_mono')),
    time       = GC.newText(FONT.get(30, '_mono')),
    chain      = GC.newText(FONT.get(50)),
    b2b        = GC.newText(FONT.get(30), "B2B x"),
    gigaspeed  = GC.newText(FONT.get(50), {
        COLOR.R, "G", COLOR.O, "I", COLOR.Y, "G",
        COLOR.K, "A", COLOR.G, "S", COLOR.J, "P",
        COLOR.C, "E", COLOR.S, "E", COLOR.B, "D" }),
    gigatime   = GC.newText(FONT.get(50, '_mono')),
    slogan     = GC.newText(FONT.get(30), "CROWD THE TOWER!"),
    slogan_EX  = GC.newText(FONT.get(30), "THRONG THE TOWER!"),
    slogan_rEX = GC.newText(FONT.get(30), "OVERFLOW THE TOWER!"),
    forfeit    = GC.newText(FONT.get(50), "KEEP HOLDING TO FORFEIT"),
    credit     = GC.newText(FONT.get(30), "All assets from TETR.IO, see the help page"),
}
if fontNotLoaded then
    TASK.new(function()
        local t = love.timer.getTime()
        local delay = MATH.roll(.9626) and MATH.rand(2.6, 6.26) or 26
        while love.timer.getTime() - t < delay do
            coroutine.yield()
            if GAME.anyRev then
                TASK.yieldT(0.26)
                SFX.play('staffsilence')
                MSG('dark', "A DARK FORCE INTERRUPTED THE FONT LOADING")
                return
            end
        end
        FONT.setDefaultFont('_norm')
        local scale = 60 / TEXTS.load:getFont():getHeight()
        for _, text in next, TEXTS do text:setFont(FONT.get(MATH.roundUnit(text:getFont():getHeight() * scale, 10))) end
        for _, quest in next, GAME.quests do quest.name:setFont(FONT.get(60)) end
        TEXTS.height:setFont(FONT.get(30, '_mono'))
        TEXTS.time:setFont(FONT.get(30, '_mono'))
        TEXTS.gigatime:setFont(FONT.get(50, '_mono'))
        FONT.get(25):setLineHeight(0.9)
        WIDGET._reset()
    end)
end

local _DATA = {
    highScore = setmetatable({}, { __index = function() return 0 end }),
    speedrun = setmetatable({}, { __index = function() return 1e99 end }),
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

local _CONF = {
    fullscreen = true,
    syscursor = false,
}
local function saver()
    TASK.yieldT(2.6)
    CONF.save()
end
CONF = setmetatable({
    load = function() TABLE.update(_CONF, FILE.load('conf.luaon', '-luaon -canskip') or NONE) end,
    save = function() love.filesystem.write('conf.luaon', TABLE.dumpDeflate(_CONF)) end,
}, {
    __index = _CONF,
    __newindex = function(_, k, v)
        _CONF[k] = v
        TASK.removeTask_code(saver)
        TASK.new(saver)
    end,
})

MX, MY = 0, 0

---@type Map<Card>
Cards = {}

---@type nil|number
FloatOnCard = nil

Background = {
    floor = 2,
    alpha = 0,
    quad = GC.newQuad(0, 0, 1920, 1080, 1920, 1080)
}
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

for i = 1, #ComboData do
    local cmb = ComboData[i]
    cmb.name = '"' .. cmb.name:upper() .. '"'
    local cmbStr = table.concat(TABLE.sort(cmb.set:trim():split('%s+', true)), ' ')
    ComboData[cmbStr] = ComboData[cmbStr] or cmb
end

Shader_Coloring = GC.newShader [[vec4 effect(vec4 color, sampler2D tex, vec2 texCoord, vec2 scrCoord) {return vec4(color.rgb, color.a * texture2D(tex, texCoord).a);}]]

GAME = require 'module/game'

for i = 1, #ModData.deck do table.insert(Cards, require 'module/card'.new(ModData.deck[i])) end
GAME.refreshLayout()
for i, C in ipairs(Cards) do
    Cards[C.id], C.x, C.y = C, C.tx, C.ty + 260 + 26 * 1.6 ^ i
end

SCN.add('tower', require 'module/tower')
SCN.add('joining', require 'module/joining')
ZENITHA.setFirstScene('joining')

local gc = love.graphics

local pressValue = 0

CursorProgress = 0
local function StarHandCursor(x, y)
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

function RefreshSysCursor()
    love.mouse.setVisible(CONF.syscursor)
    ZENITHA.globalEvent.drawCursor = CONF.syscursor and NULL or StarHandCursor
end

love.mouse.setVisible(false)
ZENITHA.globalEvent.drawCursor = NULL
ZENITHA.globalEvent.clickFX = NULL

function WIDGET._prototype.button:draw()
    gc.push('transform')
    gc.translate(self._x, self.name == 'back' and self._y or self._y + DeckPress)

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
    gc.setLineWidth(3)
    gc.setColor(frameC[1] * .2, frameC[2] * .2, frameC[3] * .2)
    gc.line(-w / 2, h / 2, w / 2, h / 2, w / 2, -h / 2 - 1.5)
    gc.setColor(.2 + frameC[1] * .8, .2 + frameC[2] * .8, .2 + frameC[3] * .8)
    gc.line(-w / 2, h / 2 + 1.5, -w / 2, -h / 2, w / 2 - 1.5, -h / 2)

    -- Highlight
    if self._hoverTime > 0 then
        gc.setColor(1, 1, 1, self._hoverTime / self._hoverTimeMax * .16)
        GC.mRect('fill', 0, 0, w - 3, h - 3)
    end

    -- Drawable
    gc.setColor(self.textColor)
    WIDGET._alignDraw(self, self._text, 0, 0, nil, 1, 1.15 * (1 - 2 * GAME.revTimer))

    gc.pop()
end

-- Mouse Holding daemon
function Daemon_Cursor()
    while true do
        local dt = coroutine.yield()
        if love.mouse.isDown(1, 2, 3) then
            pressValue = 1
        else
            pressValue = MATH.expApproach(pressValue, 0, dt * 12)
        end
    end
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
            if set[i] == 'violin2' then T = (T - 8 * 60 / 184) % length end
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

        GigaSpeed.r, GigaSpeed.g, GigaSpeed.b = COLOR.HSV(T / bar % 1, .626, 1)
        GigaSpeed.bgAlpha = 1 - 4 * T / bar % 1

        if T < t1 then t1 = -.1 end
        if T > t1 + step1 then
            t1 = t1 + step1
            for i = 1, 9 do
                Cards[i].visY = GAME.mod.MS * math.random(-4, 4)
            end
            GAME.refreshLayout()
        end

        if T < t2 then t2 = 0 end
        if T > t2 + step2 then
            t2 = t2 + step2
            if GAME.mod.EX > 0 and not SCN.swapping then
                if GAME.anyRev then
                    BGM.set('expert', 'volume', MATH.rand(.7, 1) or 0, 0)
                else
                    local pick = MATH.roll(MATH.interpolate(1, .26, 10, .9, GAME.floor))
                    BGM.set('expert', 'volume', pick and MATH.rand(.4, .7) or 0, pick and 0 or .1)
                end
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

DiscordState = {}
function Daemon_DiscordRPC()
    while true do
        TASK.yieldT(1)
        if DiscordState.needUpdate and not TASK.getLock('RPC_update') then
            DiscordState.needUpdate = nil
            DiscordRPC.update(DiscordState)
        end
    end
end

-- Load data
DATA.load()
CONF.load()
local oldVer = DATA.version
if DATA.version == nil then
    for k in next, DATA.highScore do
        if k:find('rNH') or k:find('rMS') or k:find('rVL') or k:find('rAS') then
            DATA.highScore[k] = nil
        end
    end
    DATA.version = 162
end
if DATA.version == 162 then
    TABLE.clear(DATA.speedrun)
    DATA.version = 163
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
love.window.setFullscreen(CONF.fullscreen)

-- Test
TASK.new(function()
    for _, s in next, ([[ ]]):trim():split('%s+', true) do
        TASK.yieldT(1)
        SFX.play(s)
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
