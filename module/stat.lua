---@type Zenitha.Scene
local scene = {}

local maskAlpha, cardShow
local card = GC.newCanvas(1200, 720)

local gc = love.graphics
local gc_origin, gc_replaceTransform = gc.origin, gc.replaceTransform
local gc_setColor, gc_setLineWidth = gc.setColor, gc.setLineWidth
local gc_draw, gc_line = gc.draw, gc.line
local gc_rectangle = gc.rectangle
local gc_print, gc_printf = gc.print, gc.printf
local gc_mDraw = GC.mDraw
local gc_setAlpha, gc_move, gc_back = GC.setAlpha, GC.ucs_move, GC.ucs_back

local baseColor = { .08, .26, .14 }
local areaColor = { .08, .23, .12 }
local titleColor = { COLOR.HEX("16582D") }
local textColor = { COLOR.HEX("54B06D") }
local scoreColor = { COLOR.HEX("B0FFC0") }
local setup = { stencil = true, card }

local sawMap = {
    { 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0 },
    { 1, 0, 0, 0, 1, 1, 1, 0, 1, 1, 1, 1, 0, 0, 1, 0, 1, 0, 1, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0 },
    { 1, 1, 0, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 0 },
}
local saw = { w = 30, h = 3 }
for y = 1, 3 do
    for x = 1, 30 do
        if sawMap[y][x] == 1 then
            table.insert(saw, { 'fRect', x - 1, y - 1, 1, 1 })
        end
    end
end
saw = GC.load(saw)
saw:setFilter('nearest', 'nearest')
saw:setWrap('repeat', 'repeat')
local sawQuad = GC.newQuad(0, 0, 180, 3, saw)
local bannerQuad = GC.newQuad(0, 220, 512, 256, TEXTURE.banner)

local function dblMidStr(str, x, y)
    GC.mStr(str, x, y)
    gc_setAlpha(.6)
    GC.mStr(str, x, y + 3)
end

function scene.load()
    maskAlpha, cardShow = 0, 0
    TWEEN.new(function(t)
        maskAlpha = t
    end):setTag('stat_in'):setDuration(.26):run():setOnFinish(function()
        TWEEN.new(function(t)
            cardShow = t
        end):setTag('stat_in'):setDuration(.1):run()
    end)

    GC.setCanvas(setup)
    gc_origin()
    GC.clear(baseColor[1], baseColor[2], baseColor[3], 0)

    -- Banner
    gc_setColor(.42, .42, .42)
    gc_draw(TEXTURE.banner, bannerQuad, 0, 10, 0, 1200 / 512, 150 / 256)

    -- Main panel & frame
    gc_setColor(baseColor)
    -- base
    gc_rectangle('fill', 0, 720, 1200, -560)
    -- deco
    gc_draw(saw, sawQuad, 0, 720 - 560, 0, 7.2, 7.2, 0, 3)
    -- top ribbon
    gc_setColor(areaColor)
    gc_rectangle('fill', 0, 210, 1200, 60)
    -- bottom ribbon
    gc_rectangle('fill', 0, 720, 1200, -90)
    -- github link
    FONT.set(50)
    gc_setColor(scoreColor)
    gc_printf("↗  VIEW SOURCE FILE", 0, 640, 1200, 'center')
    -- bottom dark
    gc_setColor(.04, .16, .08)
    gc_rectangle('fill', 0, 720, 1200, -3)
    -- right dark
    gc_setColor(.08, .2, .1)
    gc_rectangle('fill', 1200, 720, -3, -560)
    gc_draw(TEXTURE.transition, 1200, 720 - 560, -1.5708, .626, -3)
    -- left light
    gc_setColor(.26, .42, .32)
    gc_rectangle('fill', 0, 720, 3, -560)
    gc_draw(TEXTURE.transition, 0, 720 - 560, -1.5708, .626, 3)

    -- X
    FONT.set(30)
    gc_setColor(COLOR.DL)
    gc_print("CLOSE", 1068 - 10, 45 - 3, 0, 1.2)

    -- PFP
    gc_setColor(1, 1, 1)
    GC.stc_setComp()
    GC.stc_rect(30, 0, 120, 120, 6)
    gc_draw(TEXTURE.avatar, 20, 0, 0, 130 / TEXTURE.avatar:getWidth())
    GC.stc_stop()

    -- ID
    FONT.set(30)
    gc_print("MIGHT JOIN 26 DAYS AGO", 165, 96, 0, .7)
    FONT.set(50)
    gc_setColor(COLOR.L)
    gc_print("ANON-20250226", 165, 18, 0, 1.2)

    -- Time
    gc_move('m', 1075, 165)
    gc_setColor(areaColor)
    gc_rectangle('fill', 0, 0, 100, 40, 5)
    gc_setColor(scoreColor)
    local t
    if STAT.totalTime <= 3600 then
        t = math.floor(STAT.totalTime / 60) .. "Min"
    else
        t = math.floor(STAT.totalTime / 3600) .. "H"
    end
    FONT.set(30)
    GC.mStr(t, 50, 0)
    gc_back()

    -- Clicker
    gc_setColor(1, 1, 1)
    gc_mDraw(TEXTURE.clicker, 980, 182, 0, .626)

    -- Introduction
    gc_move('m', 25, 280)
    gc_setColor(areaColor)
    gc_rectangle('fill', 0, 0, 1150, 80)
    FONT.set(30)
    gc_setColor(titleColor)
    gc_print("ABOUT  US", 7, 2, 0, .8)
    gc_setColor(textColor)
    gc_print("Click the Zenith!", 15, 35, 0, .8)
    gc_back()

    gc_setLineWidth(2)

    -- Rating
    gc_move('m', 25, 370)
    gc_setColor(areaColor)
    gc_rectangle('fill', 0, 0, 375, 120)
    FONT.set(30)
    gc_setColor(titleColor)
    gc_print("CLICKER  LEAGUE", 7, 2, 0, .8)
    gc_line(7, 90, 370 - 7, 90)
    FONT.set(50)
    gc_setColor(scoreColor)
    -- dblMidStr("00000FR", 370 / 2, 24)
    gc_back()

    -- Height
    gc_move('m', 412.5, 370)
    gc_setColor(areaColor)
    gc_rectangle('fill', 0, 0, 375, 120)
    FONT.set(30)
    gc_setColor(titleColor)
    gc_print("MAX  ALTITUDE", 7, 2, 0, .8)
    gc_line(7, 90, 370 - 7, 90)
    FONT.set(50)
    gc_setColor(scoreColor)
    dblMidStr(TABLE.maxAll(BEST.highScore) .. "m", 370 / 2, 24)
    gc_back()

    -- Speedrun
    gc_move('m', 800, 370)
    gc_setColor(areaColor)
    gc_rectangle('fill', 0, 0, 375, 120)
    FONT.set(30)
    gc_setColor(titleColor)
    gc_print("FASTEST  SPEEDRUN", 7, 2, 0, .8)
    gc_line(7, 90, 370 - 7, 90)
    FONT.set(50)
    gc_setColor(scoreColor)
    dblMidStr(STRING.time(TABLE.minAll(BEST.speedrun)), 370 / 2, 24)
    gc_back()

    -- Career
    gc_move('m', 25, 500)
    gc_setColor(areaColor)
    gc_rectangle('fill', 0, 0, 570, 120)
    FONT.set(30)
    gc_setColor(titleColor)
    gc_print("CAREER", 7, 2, 0, .8)
    FONT.set(50)
    gc_setColor(scoreColor)
    -- TODO
    gc_back()

    -- Full stats
    gc_move('m', 605, 500)
    gc_setColor(areaColor)
    gc_rectangle('fill', 0, 0, 570, 120)
    FONT.set(30)
    gc_setColor(titleColor)
    gc_print("FULL  STATS", 7, 2, 0, .8)
    gc_setColor(scoreColor)
    -- TODO
    gc_back()

    GC.setCanvas()
end

function scene.keyDown(key, isRep)
    if isRep then return true end
    if key == 'escape' then
        SFX.play('menuclick')
        TWEEN.tag_kill('stat_in')
        if TASK.lock('stat_quit') then
            TWEEN.new(function(t)
                cardShow = 1 - t
            end):setDuration(.26):run():setOnFinish(function()
                TWEEN.new(function(t)
                    maskAlpha = 1 - t
                end):setDuration(.26):run():setOnFinish(function()
                    SCN.back('none')
                    TASK.unlock('stat_quit')
                end)
            end)
        end
    end
    return true
end

function scene.update(dt)
    SCN.scenes.tower.update(dt)
end

function scene.draw()
    SCN.scenes.tower.draw()
    gc_replaceTransform(SCR.xOy)
    WIDGET.draw(SCN.scenes.tower.widgetList)
    SCN.scenes.tower.overDraw()
    gc_origin()
    gc_setColor(0, 0, 0, maskAlpha * .7023)
    gc_rectangle('fill', 0, 0, SCR.w, SCR.h)

    if cardShow > 0 then
        gc_replaceTransform(SCR.xOy_m)
        gc_setColor(1, 1, 1, cardShow)
        local k = .9 + cardShow * .1
        gc_mDraw(card, 0, 0, 0, k * .67, k ^ 26 * .67)
    end
end

scene.widgetList = {
    WIDGET.new {
        name = 'back', type = 'button',
        pos = { 0, 0 }, x = 60, y = 140, w = 160, h = 60,
        color = { .15, .15, .15 },
        sound_hover = 'menutap',
        fontSize = 35, text = "    BACK", textColor = 'DL',
        onClick = function() love.keypressed('escape') end,
    },
    WIDGET.new {
        type = 'button_invis',
        pos = { .5, .5 }, y = 210, w = 800, h = 60,
        onClick = function()
            SFX.play('menuconfirm')
            love.system.openURL("https://github.com/MrZ626/ZenithClicker")
        end,
    },
    WIDGET.new {
        type = 'button_invis',
        pos = { .5, .5 }, x = 344, y = -196, w = 100, h = 50,
        onClick = function() love.keypressed('escape') end,
    },
    WIDGET.new {
        name = 'protect', type = 'button_invis',
        pos = { .5, .5 }, w = 820, h = 500,
    },
    WIDGET.new {
        type = 'button_invis',
        pos = { .5, .5 }, w = 3500, h = 2600,
        onClick = function() love.keypressed('escape') end,
    }
}
return scene
