---@type Zenitha.Scene
local scene = {}

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

local scroll = { 0, 0 }
function scene.wheelMove(dx, dy)
    dx = -dx
    if love.keyboard.isDown('lshift', 'rshift') then dx, dy = dy, dx end
    scroll[1] = MATH.clamp(scroll[1] - dx * 42, -62, 62)
    scroll[2] = MATH.clamp(scroll[2] - dy * 42, 0, 620)
end

AboutText = GC.newText(FONT.get(70))

local function addText(text, x, y, scale, wraplimit)
    if type(text) == 'string' then
        text = { COLOR.L, text }
    end
    scale = scale or 1
    local w = (wraplimit or 900) / scale
    AboutText:addf(text, w, 'center', x - w / 2 * scale, y, 0, scale)
end

addText({ COLOR.L, "Zenith Clicker" }, 0, 10)
addText({ COLOR.L, "BY MrZ" }, 0, 100, .5)
addText({ COLOR.L, string.rep("EXAMPLE TEXT ", 12) }, 0, 180, .3)
-- TODO

--[[
Redesigned by MrZ
Backgrounds reconstructed by DJ Asriel

Origin design and assets are from TETR.IO, by osk team:
Musics & Sounds by Dr.Ocelot
Arts by Largeonions & S. Zhang & Lauren Sheng & Ricman
]]

function scene.draw()
    DrawBG()

    GC.replaceTransform(SCR.xOy_u)
    GC.translate(-scroll[1], 100 - scroll[2])
    if love.keyboard.isDown('space') then
        GC.setColor(1, 1, 1)
        FONT.set(30)
        GC.circle('fill', 0, 0, 3)
        GC.print("0,0", 5, -30)
        GC.circle('fill', 100, 0, 3)
        GC.print("100,0", 105, -30)
        GC.setColor(1, 1, 0)
        GC.setLineWidth(0.5)
        for x = -600, 600, 100 do GC.line(x, 0, x, 1500) end
        for y = -1500, 1500, 100 do GC.line(-600, y, 600, y) end
    end

    GC.setColor(1, 1, 1)
    GC.draw(AboutText)

    GC.setColor(1, 1, 1, .1)
    GC.setLineWidth(0.5)
    GC.line(-600, 160, 600, 160)
    GC.line(-600, 290, 600, 290)

    -- Top bar & title
    GC.replaceTransform(SCR.xOy_u)
    GC.setColor(COLOR.D)
    GC.rectangle('fill', -1300, 0, 2600, 70)
    GC.setColor(COLOR.lD)
    GC.rectangle('fill', -1300, 70, 2600, 4)
    GC.replaceTransform(SCR.xOy_ul)
    GC.setColor(COLOR.LD)
    GC.draw(TEXTS.aboutTitle, 15, 0)
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
