local M = GAME.mod

local scene = {}

local function MouseOnCard(x, y)
    if FloatOnCard and Cards[FloatOnCard]:mouseOn(x, y) then
        return FloatOnCard
    end
    local cid, dist = 0, 1e99
    for j = 1, #Cards do
        if Cards[j]:mouseOn(x, y) then
            local dist2 = MATH.distance(x, y, Cards[j].x, Cards[j].y)
            if dist2 < dist then
                dist = dist2
                cid = j
            end
        end
    end
    if cid > 0 then
        return cid
    end
end

local function mouseMove(x, y)
    MX, MY = x, y
    local new = MouseOnCard(x, y)
    if FloatOnCard ~= new then
        FloatOnCard = new
        if new then
            SFX.play('card_slide_' .. math.random(4), .5)
        end
        GAME.refreshLayout()
    end
end

local function mousePress(x, y, k)
    mouseMove(x, y)
    local C = Cards[FloatOnCard]
    if C then
        if GAME.playing or not C.lock then
            C:setActive(false, k)
        else
            C:flick()
            SFX.play('no')
        end
    end
end

local function keyPress(key)
    if key == 'escape' then
        if not GAME.playing then
            if TASK.lock('sure_quit', 2.6) then
                SFX.play('menuclick')
                MSG.clear()
                MSG('dark', "PRESS AGAIN TO QUIT", 2.6)
            else
                BGM.set('all', 'volume', 0, 1.6)
                SFX.play('menuback')
                SCN.back()
            end
        end
    elseif key == 'z' then
        if M.NH == 2 and M.AS < 2 then
            SFX.play('no')
            return true
        end
        local W = scene.widgetList.reset
        W._pressTime = W._pressTimeMax * 2
        W._hoverTime = W._hoverTimeMax
        SFX.play('menuclick')
        GAME.cancelAll()
    elseif key == 'space' then
        if M.NH == 2 and M.AS < 2 then
            SFX.play('no')
            return true
        end
        local W = scene.widgetList.start
        W._pressTime = W._pressTimeMax * 2
        W._hoverTime = W._hoverTimeMax
        GAME[GAME.playing and 'commit' or 'start']();
    elseif key == '\\' then
        if not GAME.playing then
            local unlocked
            for i = 1, #Cards - 1 do
                if Cards[i].lock then
                    Cards[i].lock = false
                    unlocked = true
                    Cards[i]:flick()
                end
            end
            if unlocked then
                SFX.play('supporter')
            end
        end
    elseif M.AS > 0 or (not GAME.playing and (key == 'k' or key == 'i')) then
        local C = Cards[#key == 1 and ("asdfghjkl"):find(key, nil, true) or ("qwertyuio"):find(key, nil, true)]
        if C then
            if GAME.playing or not C.lock then
                C:setActive()
            else
                C:flick()
                SFX.play('boardlock_clink')
            end
        end
    end
end

function scene.mouseMove(x, y, dx, dy)
    mouseMove(x, y)
end

local cancelNextClick
function scene.mouseDown(x, y, k)
    if M.EX == 0 then
        mousePress(x, y, k)
        if M.EX > 0 then
            cancelNextClick = true
        end
    end
end

function scene.mouseClick(x, y, k)
    if cancelNextClick then
        cancelNextClick = false
        return
    end
    if M.EX > 0 then
        mousePress(x, y, k)
    end
end

scene.touchDown = mouseMove
scene.touchMove = mouseMove
scene.touchClick = scene.mouseClick

local cancelNextPress
function scene.keyDown(key)
    if M.EX == 0 then
        keyPress(key)
        if M.EX > 0 then
            cancelNextPress = true
        end
    end
    return true
end

function scene.keyUp(key)
    if cancelNextPress then
        cancelNextPress = false
        return
    end
    if M.EX > 0 then
        keyPress(key)
    end
end

function scene.update(dt)
    GAME.update(dt)
    GAME.lifeShow = MATH.expApproach(GAME.lifeShow, GAME.life, dt * 10)
    if DeckPress > 0 then
        DeckPress = DeckPress - dt
    end
    for i = #ImpactGlow, 1, -1 do
        local L = ImpactGlow[i]
        L.t = L.t - dt
        if L.t <= 0 then
            table.remove(ImpactGlow, i)
        end
    end

    for i = 1, #Cards do
        Cards[i]:update(dt)
    end
    if love.keyboard.isDown('escape') and GAME.playing then
        GAME.forfeitTimer = GAME.forfeitTimer + dt * MATH.clampInterpolate(4, 6, 10, 2, GAME.questCount)
        if TASK.lock('forfeit_sfx', .0872) then
            SFX.play('detonate1', MATH.clampInterpolate(0, .4, 2, .6, GAME.forfeitTimer))
        end
        if GAME.forfeitTimer > 2.6 then
            SFX.play('detonate2')
            GAME.finish('forfeit')
        end
    else
        if GAME.forfeitTimer > 0 then
            GAME.forfeitTimer = GAME.forfeitTimer - (GAME.playing and 2.6 or 6.2) * dt
        end
    end
end

TextColor = { .7, .5, .3 }
ShadeColor = { .3, .15, 0 }
local shortcut = ('QWERTYUIO'):atomize()
local rankColor = {
    [0] = { 0, 0, 0, 0 },
    { 1,  .1, 0 },
    { 1,  .7, 0 },
    { .5, 1,  0 },
    { 0,  .7, 1 },
    { 1,  .1, 1 },
    { 1,  .8, .5 },
    { .6, 1,  .8 },
    { .4, .9, 1 },
    { 1,  .8, 1 },
}
local gc = love.graphics
local gc_push, gc_pop = gc.push, gc.pop
local gc_replaceTransform = gc.replaceTransform
local gc_translate, gc_rotate, gc_scale = gc.translate, gc.rotate, gc.scale
local gc_setColor, gc_setLineWidth = gc.setColor, gc.setLineWidth
local gc_draw, gc_line = gc.draw, gc.line
local gc_rectangle, gc_circle, gc_arc = gc.rectangle, gc.circle, gc.arc
local gc_mDraw = GC.mDraw

local titleText = gc.newText(FONT.get(50), "EXPERT QUICK PICK")
PBText = gc.newText(FONT.get(50))
HeightText = gc.newText(FONT.get(50))
TimeText = gc.newText(FONT.get(30))
ChainText = gc.newText(FONT.get(50))
ChainPrefix = gc.newText(FONT.get(30), "B2B x")
local sloganText = gc.newText(FONT.get(30), "CROWD THE TOWER!")
local sloganText_EX = gc.newText(FONT.get(30), "THRONG THE TOWER!")
local sloganText_rev = GC.newText(FONT.get(30), "OVERFLOW THE TOWER!")
local creditText = gc.newText(FONT.get(30), "All assets from TETR.IO, see the help page")
local chargeIcon = GC.load {
    w = 256, h = 256,
    { 'move',   128,  128 },
    { 'fCirc',  0,    0,  90, 4 },
    { 'rotate', .5236 },
    { 'fCirc',  0,    0,  90, 4 },
    { 'rotate', .5236 },
    { 'fCirc',  0,    0,  90, 4 },
}

local Cards = Cards
local TextColor = TextColor
local ShadeColor = ShadeColor
function scene.draw()
    gc_replaceTransform(SCR.origin)
    gc_setColor(1, 1, 1, Background.alpha * .42)
    gc_mDraw(IMG.floorBG[Background.floor], SCR.w / 2, SCR.h / 2, nil, math.max(SCR.w / 1920, SCR.h / 1080))

    -- Card Panel
    gc_replaceTransform(SCR.xOy)
    gc_translate(0, DeckPress)
    local h = 697 + GAME.uiHide * 420
    gc_setColor(ShadeColor)
    GC.setAlpha(.872)
    gc_rectangle('fill', 800 - 1586 / 2, h - 303, 1586, 2600)
    if GAME.revDeckSkin then
        gc_setColor(1, 1, 1, GAME.revTimer)
        gc_mDraw(IMG.glass_a, 800, h)
        gc_mDraw(IMG.glass_b, 800, h)
        gc_setColor(1, 1, 1, ThrobAlpha.bg1)
        gc_mDraw(IMG.throb_a, 800, h)
        gc_setColor(1, 1, 1, ThrobAlpha.bg2)
        gc_mDraw(IMG.throb_b, 800, h)
    end
    gc_setColor(ShadeColor)
    gc_setLineWidth(4)
    gc_line(800 - 1586 / 2, h + 303, 800 - 1586 / 2, h - 303, 800 + 1586 / 2, h - 303, 800 + 1586 / 2, h + 303)
    gc_setColor(TextColor)
    gc_line(800 - 1586 / 2, h - 303, 800 + 1586 / 2, h - 303)

    -- Chain Counter
    if GAME.playing and GAME.chain >= 4 then
        local bounce = .26 / (26 * GAME.questTime + 1)
        local k = MATH.clampInterpolate(6, .7023, 26, 2, GAME.chain)
        local x = 255 - 100 * (.5 * k + bounce)
        gc_setColor(COLOR.D)
        gc_draw(ChainPrefix, x, 212, 0, 1, 1.1)
        gc_setColor(COLOR.HSL(
            26 / (GAME.chain + 22) + 1.3, 1,
            MATH.icLerp(-260, 420, GAME.chain),
            GAME.chain < 8 and .26 or 1
        ))
        GC.blurCircle(-.26, 326, 270, 100 * k)
        gc_mDraw(chargeIcon, 326, 270, GAME.time * 2.6 * k, .5 * k + bounce)
        GC.setAlpha(1)
        gc_draw(ChainPrefix, x, 210, 0, 1, 1.1)
        gc_setColor(COLOR.L)
        GC.strokeDraw('full', k * 2, ChainText, 326, 270, 0, k, 1.1 * k,
            ChainText:getWidth() / 2, ChainText:getHeight() / 2)
        gc_setColor(COLOR.D)
        gc_mDraw(ChainText, 326, 270, 0, k, 1.1 * k)
    end
end

local questStyle = {
    { k = 1.6, y = 175 },
    { k = 1.0, y = 100 },
    { k = 0.9, y = 40 },
}
function scene.overDraw()
    -- Current combo
    if M.IN < 2 or not GAME.playing then
        gc_setColor(TextColor)
        if M.IN == 2 then GC.setAlpha(.42) end
        local k = math.min(.9, 760 / GAME.modText:getWidth())
        gc_mDraw(GAME.modText, 800, 396 + DeckPress, nil, k, k * 1.1)
    end

    gc_translate(0, DeckPress)

    -- Glow
    for i = 1, #ImpactGlow do
        local L = ImpactGlow[i]
        gc_setColor(L.r, L.g, L.b, L.t - 1.5)
        GC.blurCircle(0, L.x, L.y, 120 * L.t ^ 2)
    end

    if GAME.playing then
        -- Quests
        for i = 1, #GAME.quests do
            local t = GAME.quests[i].name
            local kx = math.min(questStyle[i].k, 1550 / t:getWidth())
            local ky = math.max(kx, questStyle[i].k * .8)
            local a = 1
            if M.IN == 2 and i == 1 then
                a = 1 - GAME.questTime * GAME.floor * .26
                if GAME.fault then
                    a = math.max(a, .26)
                end
            end
            gc_setColor(.2, .2, .2, a)
            gc_mDraw(t, 800, questStyle[i].y + 5, 0, kx, ky)
            gc_setColor(1, 1, 1, a)
            gc_mDraw(t, 800, questStyle[i].y, 0, kx, ky)
        end

        -- Damage Timer
        local delay = GAME.dmgDelay
        gc_setColor(GAME.dmgTimer > GAME.dmgCycle and COLOR.DL or COLOR.lR)
        gc_rectangle('fill', 390, 430, -360 * (GAME.dmgTimer / delay), -20 - 2 * delay)
        gc_setLineWidth(3)
        gc_setColor(COLOR.LD)
        gc_rectangle('line', 390, 430, -360 * (GAME.dmgCycle / delay), -20 - 2 * delay)
        gc_rectangle('line', 390, 430, -360, -20 - 2 * delay)

        -- Health Bar
        gc_setColor(GAME.life > math.max(GAME.dmgWrong, GAME.dmgTime) and COLOR.L or COLOR.R)
        GC.mRect('fill', 800, 440, 1540 * GAME.lifeShow / 20, 10)

        -- Gravity Timer
        if M.GV > 0 then
            gc_push('transform')
            gc_translate(1300, 270)
            gc_scale(GAME.uiHide)
            gc_setColor(COLOR.DL)
            if GAME.gravTimer then
                gc_arc('fill', 'pie', 0, 0, 40, -1.5708,
                    -1.5708 + 6.2832 * GAME.gravTimer / GAME.gravDelay)
            else
                gc_circle('fill', 0, 0, 40)
            end
            gc_setColor(COLOR.LD)
            gc_circle('line', 0, 0, 40)
            gc_pop()
        end
    end

    -- Debug
    -- FONT.set(40) gc_setColor(1, 1, 1)
    -- for i = 1, #Cards do
    --     gc.print(Cards[i].ty, Cards[i].x, Cards[i].y-260)
    -- end

    -- Bottom In-game UI
    if GAME.uiHide > 0 then
        local h = 100 - GAME.uiHide * 100
        gc_translate(0, h)
        -- Thruster
        gc_setColor(rankColor[GAME.rank - 1] or COLOR.L)
        GC.mRect('fill', 800, 975, 420, 26)
        gc_setColor(rankColor[GAME.rank] or COLOR.L)
        GC.mRect('fill', 800, 975, 420 * GAME.xp / (4 * GAME.rank), 26)
        gc.setLineWidth(2)
        gc_setColor(1, 1, 1, .42)
        GC.mRect('line', 800, 975, 420, 26)

        -- Height & Timer
        FONT.set(40)
        GC.strokePrint('full', 3, COLOR.D, COLOR.L, ("%.1fm"):format(GAME.height), 800, 942, nil, 'center')
        GC.strokePrint('full', 3, COLOR.D, COLOR.L, STRING.time_simp(GAME.time), 375, 950)
        gc_translate(0, -h)
    end

    -- Cards
    gc_setColor(1, 1, 1)
    if FloatOnCard then
        for i = #Cards, 1, -1 do
            if i ~= FloatOnCard then Cards[i]:draw() end
        end
        Cards[FloatOnCard]:draw()
    else
        for i = #Cards, 1, -1 do Cards[i]:draw() end
    end

    -- Allspin keyboard hint
    if M.AS > 0 then
        FONT.set(60)
        for i = 1, #Cards do
            GC.strokePrint('full', 4, ShadeColor, COLOR.lR, shortcut[i], Cards[i].x + 80, Cards[i].y + 120)
        end
    end

    -- UI
    if GAME.uiHide < 1 then
        local exT = GAME.exTimer
        local revT = GAME.revTimer
        local d = GAME.uiHide * 70

        -- Last height
        gc_replaceTransform(SCR.xOy_u)
        gc_setColor(COLOR.D)
        gc_mDraw(HeightText, 0, 140 - 3.2 * d, 0, 2, 2)
        gc_mDraw(TimeText, 0, 204 - 3.2 * d)
        gc_setColor(COLOR.L)
        gc_mDraw(HeightText, 0, 135 - 3.2 * d, 0, 2, 2)
        gc_mDraw(TimeText, 0, 201 - 3.2 * d)

        -- Top bar & texts
        gc_setColor(ShadeColor)
        gc_rectangle('fill', -1300, -d, 2600, 70)
        gc_setColor(TextColor)
        gc_rectangle('fill', -1300, 70 - d, 2600, 4)
        gc_replaceTransform(SCR.xOy_ul)
        gc_draw(titleText,
            exT * 205 - 195, titleText:getHeight() / 2 - d, nil,
            1, 1.1 * (1 - 2 * revT), 0, titleText:getHeight() / 2)
        gc_replaceTransform(SCR.xOy_ur)
        gc_draw(PBText, -10, -d, nil, 1, 1.1, PBText:getWidth(), 0)
        gc_replaceTransform(SCR.xOy_dl)
        gc_translate(0, DeckPress)
        gc_translate(0, d)
        if revT > 0 then
            gc_draw(sloganText, 6, 2 + (exT + revT) * 42, nil, 1, 1.26, 0, sloganText:getHeight())
            gc_draw(sloganText_EX, 6, 2 + (1 - exT + revT) * 42, nil, 1, 1.26, 0, sloganText_EX:getHeight())
            gc_draw(sloganText_rev, 6, 2 + (1 - revT) * 42, nil, 1, 1.26, 0, sloganText_rev:getHeight())
        else
            gc_draw(sloganText, 6, 2 + exT * 42, nil, 1, 1.26, 0, sloganText:getHeight())
            gc_draw(sloganText_EX, 6, 2 + (1 - exT) * 42, nil, 1, 1.26, 0, sloganText_EX:getHeight())
        end
        gc_replaceTransform(SCR.xOy_dr)
        gc_translate(0, DeckPress)
        gc_draw(creditText, -5, d, 0, .872, .872, creditText:getDimensions())
    end

    -- Card info
    if not GAME.playing and FloatOnCard then
        local C = Cards[FloatOnCard]
        if C.lock then C = DeckData[C.id == 'DP' and -1 or 0] end
        gc_replaceTransform(SCR.xOy_d)
        gc_setColor(ShadeColor)
        GC.setAlpha(.7023)
        gc_rectangle('fill', -840 / 2, -140, 840, 110, 10)
        if GAME.anyRev and C.id and M[C.id] == 2 then
            FONT.set(60)
            GC.strokePrint('full', 6, COLOR.DW, nil, C.revName, 195, -145 + 4, 2600, 'center', nil, 0.85, 1)
            GC.strokePrint('full', 4, COLOR.dW, nil, C.revName, 195, -145 + 2, 2600, 'center', nil, 0.85, 1)
            GC.strokePrint('full', 2, COLOR.W, COLOR.L, C.revName, 195, -145, 2600, 'center', nil, 0.85, 1)
            FONT.set(30)
            GC.strokePrint('full', 2, COLOR.dW, COLOR.W, C.revDesc, 2600 * 0.15, -75, 2600, 'center', nil, 0.7, 1)
        else
            FONT.set(60)
            GC.strokePrint('full', 3, ShadeColor, TextColor, C.fullName, 195, -145, 2600, 'center', nil, 0.85, 1)
            FONT.set(30)
            GC.strokePrint('full', 2, ShadeColor, TextColor, C.desc, 2600 * 0.15, -75, 2600, 'center', nil, 0.7, 1)
        end
    end

    -- Forfeit Roll
    if GAME.forfeitTimer > 0 then
        gc_replaceTransform(SCR.origin)
        gc_setColor(.872, .26, .26, GAME.forfeitTimer * .6)
        gc_rectangle('fill', 0, SCR.h, SCR.w, -SCR.h * GAME.forfeitTimer / 2.6 * .5)
        gc_setColor(.626, 0, 0, GAME.forfeitTimer * .6)
        gc_rectangle('fill', 0, SCR.h * (1 - GAME.forfeitTimer / 2.6 * .5), SCR.w, -5)
    end
end

scene.widgetList = {
    WIDGET.new {
        name = 'start', type = 'button',
        pos = { .5, .5 }, y = -170, w = 800, h = 200,
        color = { .35, .12, .05 },
        textColor = TextColor,
        sound_hover = 'menuhover',
        fontSize = 80, text = "START",
        onClick = function()
            if GAME.playing then
                GAME.commit()
            else
                GAME.start()
            end
        end,
    },
    WIDGET.new {
        name = 'reset', type = 'button',
        pos = { .5, .5 }, x = 500, y = -120, w = 160, h = 100,
        color = 'DR',
        sound_hover = 'menutap',
        sound_release = 'menuclick',
        fontSize = 40, text = "RESET", textColor = 'dR',
        onClick = function() GAME.cancelAll() end,
    },
    WIDGET.new {
        name = 'hint', type = 'hint',
        pos = { 1, 0 }, x = -50, y = 120, w = 80, cornerR = 40,
        color = TextColor,
        fontSize = 80, text = "?",
        sound_hover = 'menutap',
        labelPos = 'leftBottom',
        floatText = STRING.trimIndent [[
            Welcome to Zenith Clicker! Select required tarots to send players to scale the tower.
            The higher the tower, the more tricky players will come!
            There's no leaderboard, but how high can you reach?
            Space: Start/Commit   Z: Reset selection   ESC: Forfeit/Quit

            All assets from TETR.IO, by osk team:
            Musics & Sounds by Dr.Ocelot
            Arts by Largeonions & S. Zhang & Lauren Sheng & Ricman
        ]],
    }
}

return scene
