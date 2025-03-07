local max, min = math.max, math.min
local sin, cos = math.sin, math.cos
local abs = math.abs

local M = GAME.mod
local MD = ModData

---@type Zenitha.Scene
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
                SFX.play('menuback')
                BGM.set('all', 'volume', 0, 1.6)
                SCN.back()
            end
        end
    elseif key == 'z' then
        if M.NH == 2 and M.AS ~= 1 then
            SFX.play('no')
            return true
        end
        local W = scene.widgetList.reset
        W._pressTime = W._pressTimeMax * 2
        W._hoverTime = W._hoverTimeMax
        SFX.play('menuclick')
        GAME.cancelAll()
    elseif key == 'space' then
        if M.NH == 2 and M.AS ~= 1 then
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
                SFX.play('purchase_start')
            end
        end
    elseif M.AS > 0 or (not GAME.playing and (key == 'k' or key == 'i')) then
        local C = Cards[#key == 1 and ("asdfghjkl"):find(key, nil, true) or ("qwertyuio"):find(key, nil, true)]
        if C then
            if GAME.playing or not C.lock then
                C:setActive()
            else
                C:flick()
                SFX.play('no')
            end
        end
    end
end

function scene.enter()
    RefreshSysCursor()
    GAME.refreshCursor()
end

function scene.mouseMove(x, y)
    mouseMove(x, y)
end

local cancelNextClick
function scene.mouseDown(x, y, k)
    if k == 3 then return true end
    if M.EX == 0 then
        SFX.play('move')
        mousePress(x, y, k)
        if M.EX > 0 then
            cancelNextClick = true
        end
    else
        SFX.play('rotate')
    end
end

function scene.mouseClick(x, y, k)
    if k == 3 then return true end
    if cancelNextClick then
        cancelNextClick = false
        return
    end
    if M.EX > 0 then
        mousePress(x, y, k)
    end
end

function scene.touchMove(x, y) scene.mouseMove(x, y) end

function scene.touchDown(x, y) scene.mouseDown(x, y, 1) end

function scene.touchClick(x, y) scene.mouseClick(x, y, 1) end

local cancelNextPress
function scene.keyDown(key)
    if key == 'f10' then
        STAT.syscursor = not STAT.syscursor
        RefreshSysCursor()
    elseif key == 'f11' then
        STAT.fullscreen = not STAT.fullscreen
        love.window.setFullscreen(STAT.fullscreen)
        return true
    elseif key == 'f12' then
        MSG('check', "Zenith Clicker is powered by Love2d & Zenitha, not Web!")
        return true
    end
    if M.EX == 0 then
        keyPress(key)
        if M.EX > 0 then
            cancelNextPress = true
        end
    end
    ZENITHA.setCursorVis(true)
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

local KBIsDown = love.keyboard.isDown
local MSIsDown = love.mouse.isDown
function scene.update(dt)
    GAME.update(dt)
    GAME.lifeShow = MATH.expApproach(GAME.lifeShow, GAME.life, dt * 10)
    GAME.lifeShow2 = MATH.expApproach(GAME.lifeShow2, GAME.life2, dt * 10)
    GAME.bgH = MATH.expApproach(GAME.bgH, GAME.height, dt * 2.6)
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

    StarPS:moveTo(0, -GAME.bgH * 2 * BackgroundScale)
    StarPS:update(dt)

    for i = 1, #Cards do
        Cards[i]:update(dt)
    end
    if GAME.playing and (KBIsDown('escape') or MSIsDown(3)) then
        GAME.forfeitTimer = GAME.forfeitTimer +
            dt * MATH.clampInterpolate(6, 2.6, 12, 1, min(GAME.questCount, GAME.time))
        if TASK.lock('forfeit_sfx', .0872) then
            SFX.play('detonate1', MATH.clampInterpolate(0, .4, 1, .6, GAME.forfeitTimer))
        end
        if GAME.forfeitTimer > 1 then
            SFX.play('detonate2')
            GAME.finish('forfeit')
        end
    else
        if GAME.forfeitTimer > 0 then
            GAME.forfeitTimer = GAME.forfeitTimer - (GAME.playing and 1 or 2.6) * dt
        end
    end
end

TextColor = { .7, .5, .3 }
ShadeColor = { .3, .15, 0 }
local shortcut = ('QWERTYUIO'):atomize()
local rankColor = {
    [0] = { 1, 1, 1, .26 },
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
local f10colors = {
    { .9, .6, .4, .2, .4, 1,  1,  .8, .0 },
    { .3, .3, .2, .5, .6, 0,  0,  0,  .0 },
    { .9, .8, .7, .7, .4, .5, .6, 1,  1 },
}
local gc = love.graphics
local gc_push, gc_pop = gc.push, gc.pop
local gc_replaceTransform = gc.replaceTransform
local gc_translate, gc_scale, gc_shear = gc.translate, gc.scale, gc.shear
local gc_setColor, gc_setLineWidth, gc_setBlendMode = gc.setColor, gc.setLineWidth, gc.setBlendMode
local gc_draw = gc.draw
local gc_rectangle, gc_circle, gc_arc = gc.rectangle, gc.circle, gc.arc
local gc_mRect, gc_mDraw, gc_mDrawQ, gc_strokeDraw = GC.mRect, GC.mDraw, GC.mDrawQ, GC.strokeDraw
local gc_setAlpha, gc_move, gc_back = GC.setAlpha, GC.ucs_move, GC.ucs_back
local gc_blurCircle, gc_strokePrint = GC.blurCircle, GC.strokePrint
local setFont = FONT.set

local chargeIcon = GC.load {
    w = 256, h = 256,
    { 'move',   128,  128 },
    { 'fCirc',  0,    0,  90, 4 },
    { 'rotate', .5236 },
    { 'fCirc',  0,    0,  90, 4 },
    { 'rotate', .5236 },
    { 'fCirc',  0,    0,  90, 4 },
}

local TEXTURE = TEXTURE
local Cards = Cards
local TextColor = TextColor
local ShadeColor = ShadeColor
local bgQuad = GC.newQuad(0, 0, 0, 0, 0, 0)
function scene.draw()
    gc_replaceTransform(SCR.origin)
    local bgFloor = GAME.getBgFloor()
    local bgAlpha = GAME.gigaspeed and .26 * (1 + GigaSpeed.bgAlpha) or .7
    if bgFloor < 10 then
        gc_setColor(1, 1, 1, bgAlpha)
        local bottom = Floors[bgFloor - 1].top
        local top = Floors[bgFloor].top
        local bg = TEXTURE.towerBG[bgFloor]
        local w, h = bg:getDimensions()
        local quadStartH = MATH.interpolate(bottom, h, top, 0, GAME.bgH) - 640
        bgQuad:setViewport(0, quadStartH, 1024, 640, w, h)
        gc_mDrawQ(bg, bgQuad, SCR.w / 2, SCR.h / 2, 0, BackgroundScale)
        if bgFloor == 9 then
            if GAME.bgH > 1562 then
                gc_setColor(.626, .626, .626, MATH.interpolate(1562, 0, 1650, 1, GAME.bgH))
                gc_rectangle('fill', 0, 0, SCR.w, SCR.h)
            end
        elseif quadStartH < 0 then
            bg = TEXTURE.towerBG[bgFloor + 1]
            w, h = bg:getDimensions()
            bgQuad:setViewport(0, h - 640, 1024, 640, w, h)
            gc_mDrawQ(bg, bgQuad,
                SCR.w / 2, SCR.h * MATH.interpolate(0, -.5, -640, .5, quadStartH),
                0, BackgroundScale)
        end
    else
        -- Fading Base
        gc_setColor(0, 0, GAME.bgH > 1900 and 0 or MATH.interpolate(1650, .2, 1900, 0, GAME.bgH))
        gc_rectangle('fill', 0, 0, SCR.w, SCR.h)

        -- Transition at Bottom
        if GAME.bgH < 2500 then
            local t = MATH.iLerp(1650, 2500, GAME.bgH)
            gc_setColor(
                MATH.lLerp(f10colors[1], t),
                MATH.lLerp(f10colors[2], t),
                MATH.lLerp(f10colors[3], t),
                .626 * (1 - t)
            )
        end
        gc_draw(TEXTURE.transition, 0, SCR.h, -1.5708, SCR.h / 128, SCR.w)

        -- Space
        gc_setBlendMode('add', 'alphamultiply')
        gc_setColor(1, 1, 1, .8)
        gc_draw(StarPS, SCR.w / 2, SCR.h / 2 + GAME.bgH * 2 * BackgroundScale)
        gc_mDraw(TEXTURE.moon, SCR.w / 2, SCR.h / 2 + (GAME.bgH - 2202.84) * 2 * BackgroundScale, 0, .2 * BackgroundScale)
        gc_setBlendMode('alpha')

        -- Tower
        if GAME.bgH < 1700 then
            gc_setColor(1, 1, 1)
            local bg = TEXTURE.towerBG[10]
            local w, h = bg:getDimensions()
            local quadStartH = MATH.interpolate(1650, h, 1700, 0, GAME.bgH) - 640
            bgQuad:setViewport(0, quadStartH, 1024, 640, w, h)
            gc_mDrawQ(bg, bgQuad, SCR.w / 2, SCR.h / 2, 0, BackgroundScale)
        end

        -- Cover
        if GAME.floorTime < 4.2 then
            gc_setColor(.626, .626, .626, MATH.interpolate(0, 1, 4.2, 0, GAME.floorTime))
            gc_rectangle('fill', 0, 0, SCR.w, SCR.h)
        end
    end

    -- Wind Particles
    if GAME.height <= 1650 then
        local dh = GAME.bgH - GAME.bgLastH
        GAME.bgLastH = GAME.bgH
        for i = 1, 62 do
            local w = Wind[i]
            w[2] = w[2] + dh / w[3] / 42
            if w[2] < 0 or w[2] > 1 then
                w[1], w[2] = math.random(), w[2] % 1
            end
            WindBatch:set(i, w[1] * SCR.w, (w[2] * 1.2 - .1) * SCR.h, 0, 5, (-6 - dh * 260) / w[3] * SCR.k, .5, 0)
        end
        gc_setColor(1, 1, 1, GAME.uiHide *
            MATH.clamp((GAME.rank - 2) / 6, .26, 1) * .26 *
            MATH.cLerp(.62, 1, abs(dh * 26))
        )
        gc_draw(WindBatch)
    end

    -- Previous PB Line
    gc_replaceTransform(SCR.xOy_r)
    local over = MATH.clampInterpolate(-15, 0, 5, 1, GAME.height - GAME.prevPB)
    local y = -26 * (GAME.prevPB - GAME.bgH)
    gc_setColor(1, .8 + over * .2, over * 1, 1 - over * .626)
    gc_rectangle('fill', -TEXTS.prevPB:getWidth() - 20, y - 2, -2600, 4)
    gc_draw(TEXTS.prevPB, 0, y, 0, 1, 1, TEXTS.prevPB:getWidth() + 10, TEXTS.prevPB:getHeight() / 2)

    local panelH = 697 + GAME.uiHide * (420 + GAME.height / 6.2)

    -- GigaSpeed BG
    if GigaSpeed.alpha > 0 then
        gc_replaceTransform(SCR.origin)
        gc_setColor(GigaSpeed.r, GigaSpeed.g, GigaSpeed.b, .42 * GigaSpeed.alpha)
        local h1 = SCR.y + 470 * SCR.k
        gc_draw(TEXTURE.transition, 0, 0, 0, .42 / 128 * SCR.w, h1)
        gc_draw(TEXTURE.transition, SCR.w, 0, 0, -.42 / 128 * SCR.w, h1)

        gc_replaceTransform(SCR.xOy)
        gc_setAlpha(GigaSpeed.alpha)
        gc_draw(TEXTURE.transition, 800 - 1586 / 2, panelH - 303, 1.5708, 26, 1586, 0, 1)
    else
        gc_replaceTransform(SCR.xOy)
    end

    -- Mod icons
    if GAME.uiHide > 0 then
        gc_setColor(1, 1, 1, GAME.uiHide)
        gc_draw(GAME.iconRevSB, 1490, 350)
        gc_draw(GAME.iconSB, 1490, 350)
    end

    -- Card Panel
    gc_translate(0, DeckPress)
    gc_setColor(ShadeColor)
    gc_draw(TEXTURE.transition, 800 - 1586 / 2, panelH - 303, 1.5708, 6.26, 1586, 0, 1)
    if GAME.revDeckSkin then
        gc_setColor(1, 1, 1, GAME.revTimer)
        gc_mDraw(TEXTURE.panel.glass_a, 800, panelH)
        gc_mDraw(TEXTURE.panel.glass_b, 800, panelH)
        gc_setColor(1, 1, 1, ThrobAlpha.bg1)
        gc_mDraw(TEXTURE.panel.throb_a, 800, panelH)
        gc_setColor(1, 1, 1, ThrobAlpha.bg2)
        gc_mDraw(TEXTURE.panel.throb_b, 800, panelH)
    end
    gc_setColor(ShadeColor)
    gc_draw(TEXTURE.transition, 800 - 1586 / 2, panelH - 303, 1.5708, 12.6, -3, 0, 1)
    gc_draw(TEXTURE.transition, 800 + 1586 / 2, panelH - 303, 1.5708, 12.6, 3, 0, 1)
    gc_setColor(TextColor)
    gc_mRect('fill', 800, panelH - 303 - 2, 1586 + 6, 4)

    -- Chain Counter
    if GAME.playing and GAME.chain >= 4 then
        local bounce = .26 / (26 * GAME.questTime + 1)
        local k = MATH.clampInterpolate(6, .7, 26, 2, GAME.chain)
        local x = 255 - 100 * (.5 * k + bounce)
        gc_setColor(COLOR.D)
        gc_draw(TEXTS.b2b, x, 216)
        if GAME.fault then
            gc_setColor(.62, .62, .62, GAME.chain < 8 and .26 or 1)
        else
            gc_setColor(COLOR.HSL(
                26 / (GAME.chain + 22) + 1.3, 1,
                MATH.icLerp(-260, 420, GAME.chain),
                GAME.chain < 8 and .26 or 1
            ))
        end
        gc_blurCircle(-.26, 326, 270, 100 * k)
        gc_mDraw(chargeIcon, 326, 270, GAME.time * 2.6 * k, .5 * k + bounce)
        gc_setAlpha(1)
        gc_draw(TEXTS.b2b, x, 214)
        gc_setColor(COLOR.L)
        gc_strokeDraw('full', k * 2, TEXTS.chain, 326, 270, 0, k, 1.1 * k,
            TEXTS.chain:getWidth() / 2, TEXTS.chain:getHeight() / 2)
        gc_setColor(COLOR.D)
        gc_mDraw(TEXTS.chain, 326, 270, 0, k, 1.1 * k)
    end

    --- Result
    if GAME.uiHide < 1 then
        gc_replaceTransform(SCR.xOy_u)
        gc_translate(0, -3.2 * GAME.uiHide * 70)
        gc_setColor(1, 1, 1)
        gc_draw(GAME.resultRevSB, 380, 168, 0, .9)
        gc_draw(GAME.resultSB, 380, 168, 0, .9)
        gc_setColor(COLOR.D)
        gc_mDraw(TEXTS.endHeight, 0, 135, 0, 1.8, 1.8)
        gc_mDraw(TEXTS.endTime, 0, 204)
        gc_setColor(COLOR.L)
        gc_mDraw(TEXTS.endHeight, 0, 130, 0, 1.8, 1.8)
        gc_mDraw(TEXTS.endTime, 0, 201)
    end
end

local questStyle = {
    { k = 1.4, y = 175 },
    { k = 1.1, y = 95 },
    { k = 0.9, y = 30 },
}
local questStyleDP = {
    { k = 1.4, y = 175 },
    { k = 1.4, y = 90 },
    { k = 0.7, y = 25 },
}
function scene.overDraw()
    -- Current combo
    if M.IN < 2 or not GAME.playing then
        gc_setColor(TextColor)
        if M.IN == 2 then gc_setAlpha(.42 + .26 * sin(love.timer.getTime() * 2.6)) end
        local k = min(1, 760 / TEXTS.mod:getWidth())
        gc_mDraw(TEXTS.mod, 800, 396 + DeckPress, 0, k)
    end

    gc_translate(0, DeckPress)

    -- Glow
    for i = 1, #ImpactGlow do
        local L = ImpactGlow[i]
        gc_setColor(L.r, L.g, L.b, L.t - 1.5)
        gc_blurCircle(0, L.x, L.y, 120 * L.t ^ 2)
    end

    -- GigaSpeed Timer
    if GigaSpeed.alpha > 0 then
        local w, h = TEXTS.gigatime:getDimensions()
        gc_setColor(GigaSpeed.r, GigaSpeed.g, GigaSpeed.b, .26 * GigaSpeed.alpha)
        gc_strokeDraw('full', 3, TEXTS.gigatime, 800, 264, 0, 1.5, 1.2, w * .5, h * .5)
        gc_setAlpha(GigaSpeed.alpha)
        gc_draw(TEXTS.gigatime, 800, 264, 0, 1.5, 1.2, w * .5, h * .5)
    end

    -- GigaSpeed Anim
    if GigaSpeed.textTimer then
        gc_setBlendMode('add', 'alphamultiply')
        gc_setColor(.26, .26, .26)
        for t = -10, 10, 3 do
            gc_mDraw(TEXTS.gigaspeed, 800 + (GigaSpeed.textTimer + t * .01) ^ 7 * 1800, 395, 0, 1.6)
        end
        gc_setBlendMode('alpha')
    end

    -- Health Bar
    local safeHP = GAME.playing and max(GAME.dmgWrong + GAME.dmgWrongExtra, GAME.dmgTime) or 0
    if M.DP == 0 then
        gc_setColor(GAME.playing and GAME.life > safeHP and COLOR.L or COLOR.R)
        gc_mRect('fill', 800, 440, 1540 * GAME.lifeShow / 20, 10)
    else
        gc_setColor(GAME.playing and GAME.life > safeHP and COLOR.L or COLOR.R)
        if GAME.onAlly then gc_setAlpha(.42) end
        gc_rectangle('fill', 800, 440 - 5, -1540 / 2 * GAME.lifeShow / 20, GAME.onAlly and 8 or 12)
        gc_setColor(GAME.playing and GAME.life2 > safeHP and COLOR.L or COLOR.R)
        if not GAME.onAlly then gc_setAlpha(.42) end
        gc_rectangle('fill', 800, 440 - 5, 1540 / 2 * GAME.lifeShow2 / 20, GAME.onAlly and 12 or 8)
    end

    if GAME.playing then
        -- Quests
        local style = M.DP == 0 and questStyle or questStyleDP
        for i = 1, #GAME.quests do
            local t = GAME.quests[i].name
            local kx = min(style[i].k, 1550 / t:getWidth())
            local ky = max(kx, style[i].k)
            local a = 1
            if M.IN == 2 and i <= (M.DP > 0 and 2 or 1) then
                a = a * (1 - GAME.questTime * GAME.floor * .26)
                if GAME.faultWrong then a = max(a, .355) end
            end
            gc_setColor(.2 * a, .2 * a, .2 * a, a)
            gc_mDraw(t, 800, style[i].y + 5, 0, kx, ky)
            gc_setColor(1, 1, 1, a)
            gc_mDraw(t, 800, style[i].y, 0, kx, ky)
        end

        -- Damage Timer
        local delay = GAME.dmgDelay
        gc_setColor(GAME.dmgTimer > GAME.dmgCycle and COLOR.DL or COLOR.lR)
        gc_rectangle('fill', 390, 430, -360 * (GAME.dmgTimer / delay), -20 - 2 * delay)
        gc_setLineWidth(3)
        gc_setColor(COLOR.LD)
        gc_rectangle('line', 390, 430, -360 * (GAME.dmgCycle / delay), -20 - 2 * delay)
        gc_rectangle('line', 390, 430, -360, -20 - 2 * delay)

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
    -- setFont(60) gc_setColor(1, 1, 1)
    -- for i = 1, #Cards do
    --     gc.print(Cards[i].ty, Cards[i].x, Cards[i].y-260)
    -- end

    -- Bottom In-game UI
    if GAME.uiHide > 0 then
        local h = 100 - GAME.uiHide * 100
        gc_move('m', 0, h)

        -- Thruster
        gc_setColor(rankColor[GAME.rank - 1] or COLOR.L)
        gc_setLineWidth(6)
        gc_mRect('line', 800, 965, 420, 26)
        if GAME.rankupLast then
            if GAME.xpLockLevel < 5 then
                gc_setLineWidth(2)
                gc_setAlpha(.8 - GAME.xpLockLevel * .15)
                gc_mRect('line', 800, 965, 210, 26)
            end
        else
            gc_mRect('fill', 800, 965, 420, 2)
        end
        gc_setColor(rankColor[GAME.rank] or COLOR.L)
        if GAME.xpLockTimer > 0 then
            gc_setAlpha(sin(6200 / (GAME.xpLockTimer + 4.2) ^ 3) * .26 + .74)
        end
        gc_mRect('fill', 800, 965, 420 * GAME.xp / (4 * GAME.rank), 3 + GAME.xpLockLevel)

        -- Height & Time
        TEXTS.height:set(("%.1fm"):format(GAME.height))
        TEXTS.time:set(STRING.time_simp(GAME.time))
        gc_setColor(COLOR.D)
        local wid, hgt = TEXTS.height:getDimensions()
        gc_strokeDraw('full', 1, TEXTS.height, 800, 978, 0, 1, 1, wid / 2, hgt / 2)
        wid, hgt = TEXTS.time:getDimensions()
        gc_strokeDraw('full', 2, TEXTS.time, 375, 978, 0, 1, 1, wid / 2, hgt / 2)

        gc_setColor(COLOR.L)
        gc_mDraw(TEXTS.height, 800, 978)
        gc_mDraw(TEXTS.time, 375, 978)

        gc_back()
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
        setFont(50)
        for i = 1, #Cards do
            gc_strokePrint('full', 4, ShadeColor, COLOR.lR, shortcut[i], Cards[i].x + 80, Cards[i].y + 120)
        end
    end

    -- UI
    if GAME.uiHide < 1 then
        local exT = GAME.exTimer
        local revT = GAME.revTimer
        local d = GAME.uiHide * 70

        gc_replaceTransform(SCR.xOy_u)

        -- Top bar & texts
        gc_setColor(ShadeColor)
        gc_rectangle('fill', -1300, -d, 2600, 70)
        gc_setColor(TextColor)
        gc_rectangle('fill', -1300, 70 - d, 2600, 4)
        gc_replaceTransform(SCR.xOy_ul)
        local h = TEXTS.title:getHeight()
        gc_draw(TEXTS.title, MATH.lerp(-181, 10, exT), h / 2 - d, 0, 1, 1 - 2 * revT, 0, h / 2)
        gc_replaceTransform(SCR.xOy_ur)
        gc_draw(TEXTS.pb, -10, -d, 0, 1, 1, TEXTS.pb:getWidth(), 0)
        gc_replaceTransform(SCR.xOy_u)
        gc_draw(TEXTS.sr, 0, -d, 0, 1, 1, TEXTS.sr:getWidth() / 2, 0)
        gc_replaceTransform(SCR.xOy_dl)
        gc_translate(0, DeckPress + d)
        if revT > 0 then
            gc_draw(TEXTS.slogan, 6, 2 + (exT + revT) * 42, 0, 1, 1, 0, TEXTS.slogan:getHeight())
            gc_draw(TEXTS.slogan_EX, 6, 2 + (1 - exT + revT) * 42, 0, 1, 1, 0, TEXTS.slogan_EX:getHeight())
            gc_draw(TEXTS.slogan_rEX, 6, 2 + (1 - revT) * 42, 0, 1, 1, 0, TEXTS.slogan_rEX:getHeight())
        else
            gc_draw(TEXTS.slogan, 6, 2 + exT * 42, 0, 1, 1, 0, TEXTS.slogan:getHeight())
            gc_draw(TEXTS.slogan_EX, 6, 2 + (1 - exT) * 42, 0, 1, 1, 0, TEXTS.slogan_EX:getHeight())
        end
        gc_replaceTransform(SCR.xOy_dr)
        gc_translate(0, DeckPress)
        gc_draw(TEXTS.credit, -5, d, 0, .872, .872, TEXTS.credit:getDimensions())
    end

    -- Card info
    if not GAME.playing and FloatOnCard then
        local C = Cards[FloatOnCard]
        local infoID = C.lock and (C.id == 'DP' and 'lockDP' or 'lock') or C.id
        gc_replaceTransform(SCR.xOy_d)
        gc_move('m', 0, 126 * (1 - C.float))
        gc_setColor(ShadeColor)
        gc_setAlpha(.7)
        gc_rectangle('fill', -840 / 2, -140, 840, 110, 10)
        if GAME.anyRev and M[infoID] == 2 then
            setFont(60)
            gc_push('transform')
            gc_translate(0, -112)
            local t = love.timer.getTime()
            gc_scale(1 + sin(t / 2.6) * .026)
            gc_shear(sin(t) * .26, cos(t * 1.2) * .026)
            gc_strokePrint('full', 6, COLOR.DW, nil, MD.revName[infoID], 130, -35 + 4, 2600, 'center', 0, .9, 1)
            gc_strokePrint('full', 4, COLOR.dW, nil, MD.revName[infoID], 130, -35 + 2, 2600, 'center', 0, .9, 1)
            gc_strokePrint('full', 2, COLOR.W, COLOR.L, MD.revName[infoID], 130, -35, 2600, 'center', 0, .9, 1)
            gc_pop()
            setFont(25)
            gc_strokePrint('full', 2, COLOR.dW, COLOR.W, MD.revDesc[infoID], 260, -70, 2600, 'center', 0, .8, 1)
        else
            setFont(60)
            gc_strokePrint('full', 3, ShadeColor, TextColor, MD.fullName[infoID], 130, -145, 2600, 'center', 0, .9, 1)
            setFont(25)
            gc_strokePrint('full', 2, ShadeColor, TextColor, MD.desc[infoID], 260, -70, 2600, 'center', 0, .8, 1)
        end
        gc_back()
    end

    -- Forfeit Panel
    if GAME.forfeitTimer > 0 then
        gc_replaceTransform(SCR.origin)
        local alpha = min(GAME.forfeitTimer * 2.6, 1)
        local h = SCR.h * GAME.forfeitTimer * .5

        -- Body
        gc_setColor(.8, .2, .0626, alpha)
        gc_rectangle('fill', 0, SCR.h, SCR.w, -h)

        -- Blur
        gc_setColor(1, 1, 1, alpha * .355)
        gc_draw(TEXTURE.transition, 0, SCR.h - h, 1.5708, h / 128, SCR.w, 0, 1)
        gc_setColor(1, 0, 0, alpha * .42)
        gc_draw(TEXTURE.transition, 0, SCR.h - h, -1.5708, SCR.k * 42 / 128, SCR.w)

        -- Line
        gc_setColor(1, 0, 0, alpha)
        gc_rectangle('fill', 0, SCR.h - h, SCR.w, -5 * SCR.k)

        -- Text
        gc_setColor(1, .872, .872, alpha)
        gc_mDraw(TEXTS.forfeit, SCR.w / 2, SCR.h - h * .5, 0, SCR.k, SCR.k)
    end
end

scene.widgetList = {
    WIDGET.new {
        name = 'back', type = 'button',
        pos = { 0, 0 }, x = 60, y = 140, w = 160, h = 60,
        color = { .15, .15, .15 },
        sound_hover = 'menutap',
        fontSize = 35, text = "    BACK", textColor = 'DL',
        onClick = function()
            if GAME.playing then
                if TASK.lock('sure_forfeit', 2.6) then
                    SFX.play('menuclick')
                    MSG.clear()
                    MSG('dark', "PRESS AGAIN TO FORFEIT", 2.6)
                else
                    SFX.play('menuback')
                    GAME.finish('forfeit')
                end
            else
                love.keypressed('escape')
            end
        end,
    },
    WIDGET.new {
        name = 'start', type = 'button',
        pos = { .5, .5 }, y = -170, w = 800, h = 200,
        color = { .35, .12, .05 },
        textColor = TextColor,
        sound_hover = 'menuhover',
        fontSize = 90, text = "START",
        onClick = function(k)
            if k ~= 3 then
                GAME[GAME.playing and 'commit' or 'start']()
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
        onClick = function(k) if k ~= 3 then GAME.cancelAll() end end,
    },
    WIDGET.new {
        name = 'hint', type = 'hint',
        pos = { 1, 0 }, x = -50, y = 120, w = 80, cornerR = 40,
        color = TextColor,
        fontSize = 60, text = "?",
        sound_hover = 'menutap',
        labelPos = 'leftBottom',
        floatFontSize = 20,
        floatText = STRING.trimIndent [[
            Welcome to Zenith Clicker! Select required tarots to send players to scale the tower.
            The higher the tower, the more tricky players will come!
            There's no leaderboard, but how high can you reach?
            Space: commit    Z: reset    Esc: forfeit/quit
            F10: large cursor    F11: fullscreen

            Redesign by MrZ, backgrounds recontructed by DJ Asrial
            Origin design and assets are from TETR.IO, by osk team:
            Musics & Sounds by Dr.Ocelot
            Arts by Largeonions & S. Zhang & Lauren Sheng & Ricman
        ]],
    }
}

return scene
