---@type Zenitha.Scene
local scene = {}

local scroll = 0
local scroll1 = 0

function scene.load()
    scroll, scroll1 = 0, -620
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

function scene.wheelMove(_, dy)
    scroll = MATH.clamp(scroll - dy * 42, 0, 120)
end

AboutText = GC.newText(FONT.get(70))
local lines = {}
local nameColor = {
    z = { .4, .8, 1 },
    ocelot = { 1, .3, .5 },
    asrial = { .5, 1, .3 },
}

local function addText(text, x, y, scale, wraplimit)
    if type(text) == 'string' then
        text = { COLOR.L, text }
    end
    scale = scale or 1
    local w = (wraplimit or 900) / scale
    AboutText:addf(text, w, 'center', x - w / 2 * scale, y, 0, scale)
end

addText("Zenith", 30, 20 - 5)
addText("Clicker", 100, 85 + 5)
addText("BY MrZ", 0, 200, .5)

table.insert(lines, 260)

addText(STRING.trimIndent [[
    FLIPPING TAROTS IN THIS MODERN YET UNFAMILIAR OFFLINE CLICKER.
    IMPROVE YOURSELF AGAIN AND AGAIN, AND GRINDING THE MAXIUM CR
    - THE CLICKER FUTURE IS YOURS!
]], 0, 283, .3, 800)

table.insert(lines, 387)

-- THE TEAM

addText({ COLOR.O, "THE TEAM" }, 0, 410, .3)

addText({ nameColor.z, "MRZ" }, 0, 450, .5)
addText({ COLOR.LD, "FOUNDER & LEAD PRODUCER" }, 0, 490, .26)
addText({ COLOR.LD, "Programming, Game Design, General Development, Test" }, 0, 510, .2)

addText({ nameColor.ocelot, "DOKTOROCELOT" }, 160, 550, .5)
addText({ COLOR.LD, "Audio, Music" }, 160, 590, .26)

addText({ nameColor.asrial, "DJ  ASRIEL" }, -160, 550, .5)
addText({ COLOR.LD, "Test & Background Reconstruct" }, -160, 590, .26)

table.insert(lines, 640)

addText({ COLOR.O, "ART BY" }, 0, 660 + 10, .3)

addText("LARGEONIONS", -300 * 1.26, 700 + 10, .5)
addText({ COLOR.LD, "FLOORS 1-5" }, -300 * 1.26, 740 + 10, .26)
addText("S.  ZHANG", -100 * 1.26, 700 + 10, .5)
addText({ COLOR.LD, "FLOORS 6-8" }, -100 * 1.26, 740 + 10, .26)
addText("LAUREN  SHENG", 100 * 1.26, 700 + 10, .5)
addText({ COLOR.LD, "FLOORS 9-10" }, 100 * 1.26, 740 + 10, .26)
addText("RICMAN", 300 * 1.26, 700 + 10, .5)
addText({ COLOR.LD, "CARD ART" }, 300 * 1.26, 740 + 10, .26)

table.insert(lines, 800)

addText({
    COLOR.O, "GAME ICON BY ",
    nameColor.asrial, "DJ Asriel ",
    COLOR.O, "& ",
    nameColor.z, "MrZ"
}, 0, 826, .32)

addText({
    COLOR.O, "FONTS BY ",
    COLOR.L, "Adrian Frutiger (D-Din-Pro) ",
    COLOR.O, "& ",
    COLOR.L, "Mooniak (AbhayaLibre)"
}, 0, 870, .32)

function scene.update(dt)
    scroll1 = MATH.expApproach(scroll1, scroll, dt * 26)
end

function scene.draw()
    DrawBG()

    GC.replaceTransform(SCR.xOy_u)
    GC.translate(0, 100 - scroll1)
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

    GC.setColor(.8, .8, .8)
    GC.mDraw(TEXTURE.banner, -180, 100, 0, 0.3)
    GC.setColor(1, 1, 1)
    GC.draw(AboutText)

    GC.setColor(1, 1, 1, .2)
    GC.setLineWidth(0.5)
    for i = 1, #lines do
        GC.line(-600, lines[i], 600, lines[i])
    end

    -- Top bar & title
    GC.replaceTransform(SCR.xOy_u)
    GC.setColor(COLOR.D)
    GC.rectangle('fill', -1300, 0, 2600, 70)
    GC.setColor(COLOR.lD)
    GC.rectangle('fill', -1300, 70, 2600, 4)
    GC.replaceTransform(SCR.xOy_ul)
    GC.setColor(COLOR.LD)
    GC.draw(TEXTS.aboutTitle, 15, 0)

    -- Bottom bar & thanks
    GC.replaceTransform(SCR.xOy_d)
    GC.setColor(COLOR.D)
    GC.rectangle('fill', -1300, 0, 2600, -50)
    GC.setColor(COLOR.lD)
    GC.rectangle('fill', -1300, -50, 2600, -4)
    GC.replaceTransform(SCR.xOy_dl)
    GC.setColor(COLOR.LD)
    GC.draw(TEXTS.aboutThanks, 15, -45)
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
