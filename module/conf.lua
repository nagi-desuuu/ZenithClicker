---@type Zenitha.Scene
local scene = {}

local color = {
    D = { COLOR.HEX '191E31' },
    L = { COLOR.HEX '4D67A6' },
}

function scene.load()
    TASK.lock('no_back', 0.26)
end

function scene.keyDown(key, isRep)
    if isRep then return true end
    if key == 'escape' and not TASK.getLock('no_back') then
        SFX.play('menuclick')
        SCN.back('none')
    end
    ZENITHA.setCursorVis(true)
    return true
end

function scene.draw()
    DrawBG(26)

    GC.replaceTransform(SCR.xOy_u)

    if love.keyboard.isDown('space') then
        GC.setColor(1, 1, 0)
        FONT.set(30)
        for x = -600, 600 - 100, 100 do
            for y = 0, 600 - 100, 100 do
                GC.rectangle('line', x, y, 100, 100)
                GC.print(x .. ',' .. y, x + 2.6, y, 0, .355)
            end
        end
    end

    -- Top bar & title
    GC.replaceTransform(SCR.xOy_u)
    GC.setColor(color.D)
    GC.rectangle('fill', -1300, 0, 2600, 70)
    GC.setColor(color.L)
    GC.setAlpha(.626)
    GC.rectangle('fill', -1300, 70, 2600, 3)
    GC.replaceTransform(SCR.xOy_ul)
    GC.setColor(color.L)
    FONT.set(50)
    GC.print("CONFIG", 15, 0)

    -- Bottom bar & thanks
    GC.replaceTransform(SCR.xOy_d)
    GC.setColor(color.D)
    GC.rectangle('fill', -1300, 0, 2600, -50)
    GC.setColor(color.L)
    GC.setAlpha(.626)
    GC.rectangle('fill', -1300, -50, 2600, -3)
    GC.replaceTransform(SCR.xOy_dl)
    GC.setColor(color.L)
    FONT.set(30)
    GC.print("TWEAK YOUR SETTINGS FOR A BETTER CLICKING EXPERIENCE", 15, -45, 0, .85, 1)
end

scene.widgetList = {
    WIDGET.new {
        name = 'back', type = 'button',
        pos = { 0, 0 }, x = 60, y = 140, w = 160, h = 60,
        color = { .15, .15, .15 },
        sound_hover = 'menutap',
        fontSize = 30, text = "    BACK", textColor = 'DL',
        onClick = function() love.keypressed('escape') end,
    },
}

return scene
