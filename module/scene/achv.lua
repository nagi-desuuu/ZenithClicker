---@type Zenitha.Scene
local scene = {}

local clr = {
    D = { COLOR.HEX '19311E' },
    L = { COLOR.HEX '4DA667' },
    T = { COLOR.HEX '6FAC82' },
    LT = { COLOR.HEX 'CCEBB0' },
}
local colorRev = false

function scene.load()
    SetMouseVisible(true)
    if GAME.anyRev ~= colorRev then
        colorRev = GAME.anyRev
        for _, C in next, clr do
            C[1], C[2] = C[2], C[1]
        end
    end
end

function scene.keyDown(key, isRep)
    if isRep then return true end
    if key == 'escape' or key == 'tab' then
        SFX.play('menuclick')
        SCN.back('none')
    end
    ZENITHA.setCursorVis(true)
    return true
end

function scene.draw()
    DrawBG(26)

    -- Top bar & title
    GC.replaceTransform(SCR.xOy_u)
    GC.setColor(clr.D)
    GC.rectangle('fill', -1300, 0, 2600, 70)
    GC.setColor(clr.L)
    GC.setAlpha(.626)
    GC.rectangle('fill', -1300, 70, 2600, 3)
    GC.replaceTransform(SCR.xOy_ul)
    GC.setColor(clr.L)
    FONT.set(50)
    GC.print("ACHIEVEMENTS", 15, 0)

    -- Bottom bar & text
    GC.replaceTransform(SCR.xOy_d)
    GC.setColor(clr.D)
    GC.rectangle('fill', -1300, 0, 2600, -50)
    GC.setColor(clr.L)
    GC.setAlpha(.626)
    GC.rectangle('fill', -1300, -50, 2600, -3)
    GC.replaceTransform(SCR.xOy_dl)
    GC.setColor(clr.L)
    FONT.set(30)
    GC.print("VIEW YOUR ACHIEVEMENT PROGRESS!", 15, -45, 0, .85, 1)

    GC.replaceTransform(SCR.xOy)
    GC.translate(60, 0)
    GC.setColor(clr.D)
    GC.setAlpha(.626)
    GC.rectangle('fill', 400, 360, 680, 220)
    GC.setColor(COLOR.DL)
    FONT.set(30)
    GC.print("Zenith Clicker Achievement System When?", 420, 380)
    GC.setColor(COLOR.D)
    GC.rectangle('fill', 420, 435, 626, 50)
    GC.setColor(COLOR.lS)
    GC.rectangle('fill', 430, 435, 75, 50)
    GC.setColor(COLOR.D)
    GC.print("MrZ", 440, 440)
    GC.setColor(COLOR.lD)
    GC.print("at 2025/3/18 (Tue)", 520, 440)
    GC.setColor(COLOR.lS)
    GC.print("When it's ready.", 462, 520)
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
