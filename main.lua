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
local function q(oy, n, size)
    return GC.newQuad(
        n * size, oy,
        size, size,
        1971, 804
    )
end
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
        achievement = {
            frame = {
                [-1] = assets 'achievements/frames/issued.png',
                [0] = assets 'achievements/frames/none.png',
                assets 'achievements/frames/bronze.png',
                assets 'achievements/frames/silver.png',
                assets 'achievements/frames/gold.png',
                assets 'achievements/frames/platinum.png',
                assets 'achievements/frames/diamond.png',
            },
            glint_1 = assets 'achievements/glint-a.png',
            glint_2 = assets 'achievements/glint-b.png',
            glint_3 = assets 'achievements/glint-c.png',
            competitive = assets 'achievements/competitive.png',
            hidden = assets 'achievements/hidden.png',
        },
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
TEXTURE = IMG.init(TEXTURE, true)

FONT.load {
    serif = "assets/AbhayaLibre-Regular.ttf",
    sans = "assets/DINPro-Medium.otf",
    led = "assets/UniDreamLED.ttf",
}
local fontNotLoaded = MATH.roll(.62)
FONT.setDefaultFont(fontNotLoaded and 'serif' or 'sans')

BG.add('black', { draw = function() GC.clear(0, 0, 0) end })
BG.set('black')

TEXTS = { -- Font size can only be 30 and 50 here !!!
    mod        = GC.newText(FONT.get(30)),
    mpPreview  = GC.newText(FONT.get(30)),
    zpPreview  = GC.newText(FONT.get(30)),
    title      = GC.newText(FONT.get(50), "EXPERT QUICK PICK"),
    load       = GC.newText(FONT.get(50), "JOINING ROOM..."),
    pb         = GC.newText(FONT.get(50)),
    endResult  = GC.newText(FONT.get(30)),
    endHeight  = GC.newText(FONT.get(50)),
    endFloor   = GC.newText(FONT.get(30)),
    prevPB     = GC.newText(FONT.get(50), "PB"),
    height     = GC.newText(FONT.get(30)),
    time       = GC.newText(FONT.get(30)),
    rank       = GC.newText(FONT.get(30)),
    chain      = GC.newText(FONT.get(50)),
    chain2     = GC.newText(FONT.get(50, 'led')),
    b2b        = GC.newText(FONT.get(30), "B2B x"),
    gigaspeed  = GC.newText(FONT.get(50), {
        COLOR.R, "G", COLOR.O, "I", COLOR.Y, "G",
        COLOR.K, "A", COLOR.G, "S", COLOR.J, "P",
        COLOR.C, "E", COLOR.S, "E", COLOR.B, "D" }),
    gigatime   = GC.newText(FONT.get(50)),
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

function SaveBest() love.filesystem.write('best.luaon', 'return' .. TABLE.dumpDeflate(BEST)) end

function SaveStat() love.filesystem.write('stat.luaon', 'return' .. TABLE.dumpDeflate(STAT)) end

function SaveAchv() love.filesystem.write('achv.luaon', 'return' .. TABLE.dumpDeflate(ACHV)) end

function IssueAchv(tag)
    if not ACHV[tag] then
        ACHV[tag] = 0
        -- TODO
        SFX.play('achievement_1', .7, 0, GAME.mod.VL)
        -- SaveAchv()
    end
end

function SubmitAchv()
    -- TODO
    SFX.play('achievement_1', .7, 0, GAME.mod.VL)
    -- SFX.play('achievement_2', .7, 0, GAME.mod.VL)
    -- SFX.play('achievement_3', .7, 0, GAME.mod.VL)
    -- SaveAchv()
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

function ApplySettings()
    love.mouse.setVisible(STAT.syscursor)
    ZENITHA.globalEvent.drawCursor = STAT.syscursor and NULL or starCursor
    SFX.setVol(STAT.sfx / 100 * .6)
    BGM.setVol(STAT.bgm / 100)
end

function ReloadTexts()
    local sep = (TEXTS.mod:getFont():getHeight() + TEXTS.title:getFont():getHeight()) / 2
    for _, text in next, TEXTS do text:setFont(FONT.get(text:getFont():getHeight() < sep and 30 or 50)) end
    for _, quest in next, GAME.quests do quest.name:setFont(FONT.get(70)) end
    TEXTS.height:setFont(FONT.get(30))
    TEXTS.time:setFont(FONT.get(30))
    TEXTS.gigatime:setFont(FONT.get(50))
    TEXTS.chain2:setFont(FONT.get(50, 'led'))
    for _, W in next, SCN.scenes.tower.widgetList do W:reset() end
    for _, W in next, SCN.scenes.stat.widgetList do W:reset() end
    for _, W in next, SCN.scenes.conf.widgetList do W:reset() end
    for _, W in next, SCN.scenes.about.widgetList do W:reset() end
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
        ApplySettings()
    elseif key == 'f9' then
        if not GAME.zenithTraveler then
            STAT.bg = not STAT.bg
        end
    elseif key == 'f8' then
        if STAT.bgBrightness < 80 then
            STAT.bgBrightness = MATH.clamp(STAT.bgBrightness + 10, 30, 80)
            MSG.clear()
            MSG('dark', "BG " .. STAT.bgBrightness .. "%", 1)
        end
    elseif key == 'f7' then
        if STAT.bgBrightness > 30 then
            STAT.bgBrightness = MATH.clamp(STAT.bgBrightness - 10, 30, 80)
            MSG.clear()
            MSG('dark', "BG " .. STAT.bgBrightness .. "%", 1)
        end
    elseif key == 'f5' then
        if STAT.cardBrightness > 80 then
            STAT.cardBrightness = MATH.clamp(STAT.cardBrightness - 5, 80, 100)
            MSG.clear()
            MSG('dark', "Card " .. STAT.cardBrightness .. "%", 1)
        end
    elseif key == 'f6' then
        if STAT.cardBrightness < 100 then
            STAT.cardBrightness = MATH.clamp(STAT.cardBrightness + 5, 80, 100)
            MSG.clear()
            MSG('dark', "Card " .. STAT.cardBrightness .. "%", 1)
        end
    elseif key == 'f4' then
        if STAT.sfx > 0 then
            TempSFX = STAT.sfx
            STAT.sfx = 0
        else
            STAT.sfx = TempSFX or 60
            TempSFX = false
        end
        MSG.clear()
        MSG('dark', STAT.sfx > 0 and "SFX ON" or "SFX OFF", 1)
        ApplySettings()
        SFX.play('menuclick')
    elseif key == 'f3' then
        if STAT.bgm > 0 then
            TempBGM = STAT.bgm
            STAT.bgm = 0
        else
            STAT.bgm = TempBGM or 100
            TempBGM = false
        end
        MSG.clear()
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
    local M = GAME.mod

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
if STAT.totalF10 == 0 and STAT.totalGiga > 0 then STAT.totalF10 = math.floor(STAT.totalGiga * 0.872) end
if STAT.totalBonus == 0 and STAT.totalGame > 2.6 then STAT.totalBonus = STAT.totalHeight * 0.5 end
if STAT.totalPerfect == 0 and STAT.totalQuest > 0 then STAT.totalPerfect = math.floor(STAT.totalQuest * 0.872) end
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
if BEST.version == 166 then
    STAT.sfx = STAT.sfx and 60 or 0
    STAT.bgm = STAT.bgm and 100 or 0
    BEST.version = 167
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
GAME.refreshCurrentCombo()

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
