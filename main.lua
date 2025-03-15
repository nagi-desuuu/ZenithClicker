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
local function assets(path) return 'assets/' .. path end
local function q(x, y, size) return GC.newQuad(x * size, y * size, size, size, size * 5, size * 2) end
TEXTURE = {
    star0 = assets 'crystal-dark.png',
    star1 = assets 'crystal.png',
    panel = {
        glass_a = assets 'panel/glass-a.png',
        glass_b = assets 'panel/glass-b.png',
        throb_a = assets 'panel/throb-a.png',
        throb_b = assets 'panel/throb-b.png',
    },
    icon = {
        ingame = assets 'icon/ingame.png',
        ingame_rev = assets 'icon/ingame_rev.png',
        result = assets 'icon/result.png',
        result_rev = assets 'icon/result_rev.png',
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
    revive = assets 'revive.png',
    revive_rev_left = assets 'revive_rev_left.png',
    revive_rev_right = assets 'revive_rev_right.png',

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
    logo = assets 'icon.png',
    avatar = assets 'avatar.png',
    clicker = assets 'clicker.png',
}
local transition = { w = 128, h = 1 }
for x = 0, 127 do
    table.insert(transition, { 'setCL', 1, 1, 1, 1 - x / 128 })
    table.insert(transition, { 'fRect', x, 0, 1, 1 })
end
TEXTURE.transition = GC.load(transition)
TEXTURE = IMG.init(TEXTURE, true)

local fontNotLoaded = MATH.roll(.62)
FONT.load {
    serif = "assets/AbhayaLibre-Regular.ttf",
    sans = "assets/DINPro-Medium.otf",
}
FONT.setDefaultFont(fontNotLoaded and 'serif' or 'sans')
TEXTS = { -- Font size can only be 30 and 50 here !!!
    mod         = GC.newText(FONT.get(30)),
    title       = GC.newText(FONT.get(50), "EXPERT QUICK PICK"),
    load        = GC.newText(FONT.get(50), "JOINING ROOM..."),
    pb          = GC.newText(FONT.get(50)),
    sr          = GC.newText(FONT.get(50)),
    endHeight   = GC.newText(FONT.get(50)),
    endTime     = GC.newText(FONT.get(30)),
    prevPB      = GC.newText(FONT.get(50), "PB"),
    height      = GC.newText(FONT.get(30)),
    time        = GC.newText(FONT.get(30)),
    chain       = GC.newText(FONT.get(50)),
    b2b         = GC.newText(FONT.get(30), "B2B x"),
    gigaspeed   = GC.newText(FONT.get(50), {
        COLOR.R, "G", COLOR.O, "I", COLOR.Y, "G",
        COLOR.K, "A", COLOR.G, "S", COLOR.J, "P",
        COLOR.C, "E", COLOR.S, "E", COLOR.B, "D" }),
    gigatime    = GC.newText(FONT.get(50)),
    slogan      = GC.newText(FONT.get(30), "CROWD THE TOWER!"),
    slogan_EX   = GC.newText(FONT.get(30), "THRONG THE TOWER!"),
    slogan_rEX  = GC.newText(FONT.get(30), "OVERFLOW THE TOWER!"),
    forfeit     = GC.newText(FONT.get(50), "KEEP HOLDING TO FORFEIT"),
    credit      = GC.newText(FONT.get(30), "All assets from TETR.IO"),

    aboutTitle  = GC.newText(FONT.get(50), "ABOUT"),
    aboutThanks = GC.newText(FONT.get(30), "THANK YOU FOR PLAYING ZENITH CLICKER!"),
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

BEST = {
    highScore = setmetatable({}, { __index = function() return 0 end }),
    speedrun = setmetatable({}, { __index = function() return 1e99 end }),
}

STAT = {
    joinDate = os.date("%b %Y"),
    uid = "ANON-" .. os.date("%d_") .. math.random(2600, 6200),
    aboutme = "Click the Zenith!",
    maxFloor = 1,
    maxHeight = 0,
    heightDate = "NO DATE",
    minTime = 26 * 60,
    timeDate = "NO DATE",

    totalGame = 0,
    totalTime = 0,
    totalQuest = 0,
    totalHeight = 0,
    totalFloor = 0,
    totalFlip = 0,
    totalAttack = 0,
    totalGiga = 0,
    totalF10 = 0,

    fullscreen = true,
    syscursor = false,
    bg = true,
    bgBrightness = 60,
    bgm = true,
    sfx = true,
}

function SaveBest() love.filesystem.write('best.luaon', TABLE.dumpDeflate(BEST)) end

function SaveStat() love.filesystem.write('stat.luaon', TABLE.dumpDeflate(STAT)) end

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

SCN.add('joining', require 'module/joining')
SCN.add('tower', require 'module/tower')
SCN.add('stat', require 'module/stat')
SCN.add('about', require 'module/about')
ZENITHA.setFirstScene('joining')

local gc = love.graphics

local pressValue = 0

CursorProgress = 0
local function starCursor(x, y)
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

function ApplySettings()
    love.mouse.setVisible(STAT.syscursor)
    ZENITHA.globalEvent.drawCursor = STAT.syscursor and NULL or starCursor
    BGM.setVol(STAT.bgm and 1 or 0)
    SFX.setVol(STAT.sfx and 1 or 0)
end

function ReloadTexts()
    local sep = (TEXTS.mod:getFont():getHeight() + TEXTS.title:getFont():getHeight()) / 2
    for _, text in next, TEXTS do text:setFont(FONT.get(text:getFont():getHeight() < sep and 30 or 50)) end
    for _, quest in next, GAME.quests do quest.name:setFont(FONT.get(70)) end
    TEXTS.height:setFont(FONT.get(30))
    TEXTS.time:setFont(FONT.get(30))
    TEXTS.gigatime:setFont(FONT.get(50))
    for _, W in next, SCN.scenes.tower.widgetList do W:reset() end
    for _, W in next, SCN.scenes.stat.widgetList do W:reset() end
    if SCN.cur == 'stat' then RefreshProfile() end
    AboutText:setFont(FONT.get(70))
    MSG.clear()
end

love.mouse.setVisible(false)
ZENITHA.globalEvent.drawCursor = NULL
ZENITHA.globalEvent.clickFX = NULL

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
        MSG.clear()
        MSG('check', "Zenith Clicker is powered by Love2d & Zenitha, not Web!")
    elseif key == 'f11' then
        STAT.fullscreen = not STAT.fullscreen
        MSG.clear()
        MSG('dark', STAT.fullscreen and "Fullscreen" or "Window Mode", 1)
        love.window.setFullscreen(STAT.fullscreen)
    elseif key == 'f10' then
        STAT.syscursor = not STAT.syscursor
        MSG.clear()
        MSG('dark', STAT.syscursor and "Star Force OFF" or "Star Force ON", 1)
        ApplySettings()
    elseif key == 'f9' then
        STAT.bg = not STAT.bg
        MSG.clear()
        MSG('dark', STAT.bg and "Background ON" or "Background OFF", 1)
    elseif key == 'f8' then
        if STAT.bgBrightness < 100 then
            STAT.bgBrightness = MATH.clamp(STAT.bgBrightness + 10, 30, 100)
            MSG.clear()
            MSG('dark', "Background Brightness " .. STAT.bgBrightness .. "%", 1)
        end
    elseif key == 'f7' then
        if STAT.bgBrightness > 26 then
            STAT.bgBrightness = MATH.clamp(STAT.bgBrightness - 10, 30, 100)
            MSG.clear()
            MSG('dark', "Background Brightness " .. STAT.bgBrightness .. "%", 1)
        end
    elseif key == 'f6' then
        STAT.bgm = not STAT.bgm
        MSG.clear()
        MSG('dark', STAT.bgm and "BGM ON" or "BGM OFF", 1)
        ApplySettings()
    elseif key == 'f5' then
        STAT.sfx = not STAT.sfx
        MSG.clear()
        MSG('dark', STAT.sfx and "SFX ON" or "SFX OFF", 1)
        ApplySettings()
    elseif key == 'f3' then
        MSG.clear()
        if TASK.forceLock('sure_rename', 2.6) then
            SFX.play('notify')
            MSG('dark', "Press F3 again to rename your account with text in clipboard")
        else
            local newName = love.system.getClipboardText()
            repeat
                if type(newName) ~= 'string' then
                    MSG('dark', "No data in clipboard")
                    break
                end
                newName = newName:upper()
                if #newName < 3 or #newName > 16 or newName:find('[^A-Z0-9_%-]') then
                    MSG('dark', "New name can only be 3~16 characters with A-Z, 0-9, _")
                    break
                end
                if newName == STAT.uid then
                    MSG('dark', "New name is the same as old one")
                    break
                end
                if newName:sub(1, 4) == 'ANON' then
                    MSG('dark', "New name can't be ANON")
                    break
                end
                STAT.uid = newName
                SaveStat()
                SFX.play('supporter')
                MSG('dark', "Name changed to " .. STAT.uid)
                if SCN.cur == 'stat' then RefreshProfile() end
                return
            until true
            SFX.play('staffwarning')
        end
    elseif key == 'f4' then
        MSG.clear()
        if TASK.forceLock('sure_reabout', 2.6) then
            SFX.play('notify')
            MSG('dark', "Press F4 again to change your 'about me' text with text in clipboard")
        else
            local newText = love.system.getClipboardText()
            repeat
                if type(newText) ~= 'string' then
                    MSG('dark', "No data in clipboard")
                    break
                end
                if #newText < 1 or #newText > 260 or newText:find('[^\32-\126]') then
                    MSG('dark', "New text can only be 1~260 characters with visiable ASCII characters")
                    break
                end
                if newText == STAT.aboutme then
                    MSG('dark', "New text is the same as old one")
                    break
                end
                STAT.aboutme = newText
                SaveStat()
                SFX.play('supporter')
                MSG('dark', "About text updated")
                if SCN.cur == 'stat' then RefreshProfile() end
                return
            until true
            SFX.play('staffwarning')
        end
    end
end

function WIDGET._prototype.button:draw()
    gc.push('transform')
    gc.translate(self._x, #self.name == 4 and self._y or self._y + DeckPress)

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
    gc.setColor(frameC[1] * .42, frameC[2] * .42, frameC[3] * .42)
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
    WIDGET._alignDraw(self, self._text, 0, 0, 0, 1.2, 1.2 - 2.4 * GAME.revTimer)

    gc.pop()
end

-- Mouse Holding daemon
function Daemon_Cursor()
    while true do
        local dt = coroutine.yield()
        if love.mouse.isDown(1, 2) then
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
                obj.source:seek(math.max(T, 0))
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
                    BGM.set('expert', 'volume', MATH.rand(.7, 1), 0)
                else
                    local pick = MATH.roll(MATH.interpolate(1, .26, 10, .9, GAME.floor))
                    BGM.set('expert', 'volume', pick and MATH.rand(.4, .7) or 0, pick and 0 or .1)
                end
            end
        end
        coroutine.yield()
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
if FILE.exist('data.luaon') then
    if not FILE.exist('best.luaon') then
        love.filesystem.write('best.luaon', love.filesystem.read('data.luaon'))
    end
    love.filesystem.remove('data.luaon')
end
if FILE.exist('conf.luaon') then love.filesystem.remove('conf.luaon') end
TABLE.update(BEST, FILE.load('best.luaon', '-luaon -canskip') or NONE)
TABLE.update(STAT, FILE.load('stat.luaon', '-luaon -canskip') or NONE)
if STAT.totalF10 == 0 and STAT.totalGiga > 0 then STAT.totalF10 = math.floor(STAT.totalGiga * 0.872) end

local oldVer = BEST.version
if BEST.version == nil then
    for k in next, BEST.highScore do
        if k:find('rNH') or k:find('rMS') or k:find('rVL') or k:find('rAS') then
            BEST.highScore[k] = nil
        end
    end
    BEST.version = 162
end
if BEST.version == 162 then
    TABLE.clear(BEST.speedrun)
    BEST.version = 163
end
if BEST.version == 163 then
    STAT.maxFloor = BEST.maxFloor or 1
    BEST.maxFloor = nil
    BEST.version = 166
end
if BEST.version ~= oldVer then
    SaveStat()
    SaveBest()
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
if STAT.maxHeight == 0 then STAT.maxHeight = math.max(STAT.maxHeight, (TABLE.maxAll(BEST.highScore))) end
if STAT.minTime == 26 * 60 then STAT.minTime = math.min(STAT.minTime, (TABLE.minAll(BEST.speedrun))) end
do
    -- Auto fixing
    local realBestHeight = math.max(TABLE.maxAll(BEST.highScore), 0)
    if STAT.maxHeight > realBestHeight then
        STAT.maxHeight = realBestHeight
        STAT.heightDate = "NO DATE"
    end
    local realBestTime = math.min(TABLE.minAll(BEST.speedrun), 26 * 60)
    if STAT.minTime < realBestTime then
        STAT.minTime = realBestTime
        STAT.timeDate = "NO DATE"
    end
end
GAME.refreshLockState()
GAME.refreshPBText()
love.window.setFullscreen(STAT.fullscreen)
ApplySettings()
GAME.refreshCursor()

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
