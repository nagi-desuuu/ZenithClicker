---@type Zenitha.Scene
local scene = {}

local scroll = 0
local scroll1 = 0

local clr = {
    D = { COLOR.HEX '1F1F1F' },
    L = { COLOR.HEX '656565' },

    z = { COLOR.HEX "80CCFF" },
    asrial = { COLOR.HEX "DDFF80" },
    ccyt = { COLOR.HEX "66DD55" },
    osk = { COLOR.HEX "DD99FF" },
    ocelot = { COLOR.HEX "FF99CC" },
    garbo = { COLOR.HEX "3A66DD" },
}

AboutText = GC.newText(FONT.get(70))
local lines = {}

local function addText(text, x, y, scale, wraplimit)
    if type(text) == 'string' then text = { COLOR.L, text } end
    scale = scale or 1
    local w = (wraplimit or 900) / scale
    AboutText:addf(text, w, 'center', x - w / 2 * scale, y, 0, scale)
end

addText("ZENITH", 40, 20)
addText("CLICKER", 80, 95)
addText("BY MrZ", 0, 200, .5)

table.insert(lines, 260)

addText(STRING.trimIndent [[
    FLIP THE TAROT CARDS IN THIS MODERN YET UNFAMILIAR OFFLINE CLICKER.
    PLAY TO IMPROVE YOUR SKILLS, AND GAIN CR FROM VARIOUS MODS
    - THE CLICKER FUTURE IS YOURS!
]], 0, 283, .3, 800)

table.insert(lines, 387)

-- THE TEAM

addText({ COLOR.O, "THE TEAM" }, 0, 410, .3)

addText({ clr.z, "MRZ" }, 0, 450, .5)
addText({ COLOR.LD, "FOUNDER & LEAD PRODUCER" }, 0, 490, .26)
addText({ COLOR.LD, "Programming, Game Design, General Development" }, 0, 510, .2)

addText({ clr.asrial, "DJ  ASRIEL" }, -160, 550, .5)
addText({ COLOR.LD, "ASSISTING GRAPHICS DESIGN" }, -160, 590, .26)
addText({ COLOR.LD, "Background Reconstruction" }, -160, 610, .2)

addText({ clr.ccyt, "CREEPERCRAFTYT" }, 160, 550, .5)
addText({ COLOR.LD, "ASSISTING GRAPHICS DESIGN" }, 160, 590, .26)
addText({ COLOR.LD, "Detailed Mod Icons" }, 160, 610, .2)

addText({ clr.osk, "OSK" }, -320, 650, .5)
addText({ COLOR.LD, "FOUNDER & LEAD PRODUCER…" }, -320, 690, .26)
addText({ COLOR.LD, "of the Original Game: TETR.IO" }, -320, 710, .2)

addText({ clr.ocelot, "DOKTOROCELOT" }, 0, 650, .5)
addText({ COLOR.LD, "AUDIO & MUSIC" }, 0, 690, .26)

addText({ clr.garbo, "GARBO" }, 320, 650, .5)
addText({ COLOR.LD, "GAME & WORLD DESIGN…" }, 320, 690, .26)
addText({ COLOR.LD, "of the Original Game: TETR.IO" }, 320, 710, .2)

table.insert(lines, 740)

addText({ COLOR.O, "ART BY" }, 0, 760 + 10, .3)

addText("LARGEONIONS", -300 * 1.26, 812, .46)
addText({ COLOR.LD, "FLOORS 1-5" }, -300 * 1.26, 840 + 10, .26)
addText("S. ZHANG", -100 * 1.26, 812, .46)
addText({ COLOR.LD, "FLOORS 6-8" }, -100 * 1.26, 840 + 10, .26)
addText("LAUREN SHENG", 100 * 1.26, 812, .46)
addText({ COLOR.LD, "FLOORS 9-10" }, 100 * 1.26, 840 + 10, .26)
addText("RICMAN", 300 * 1.26, 812, .46)
addText({ COLOR.LD, "CARD ART" }, 300 * 1.26, 840 + 10, .26)

table.insert(lines, 900)

addText({
    COLOR.O, "GAME ICON BY ",
    clr.asrial, "DJ Asriel ",
    COLOR.O, "& ",
    clr.z, "MrZ"
}, 0, 926, .32)

addText({
    COLOR.O, "FONTS BY ",
    COLOR.L, "Adrian Frutiger (D-Din-Pro) ",
    COLOR.O, "& ",
    COLOR.L, "Mooniak (AbhayaLibre)"
}, 0, 970, .32)

local timer
function scene.load()
    timer = 0
    SetMouseVisible(true)
    scroll, scroll1 = 0, -620
end

function scene.mouseMove(_, _, _, dy)
    if love.mouse.isDown(1, 2) then
        scroll = MATH.clamp(scroll - dy, 0, 200)
    end
end

function scene.touchMove(_, _, _, dy)
    scroll = MATH.clamp(scroll - dy, 0, 200)
end

function scene.keyDown(key, isRep)
    if isRep then return true end
    if key == 'escape' or key == 'f2' then
        SFX.play('menuclick')
        SCN.back('none')
    end
    ZENITHA.setCursorVis(true)
    return true
end

function scene.wheelMove(_, dy)
    scroll = MATH.clamp(scroll - dy * 42, 0, 200)
end

function scene.update(dt)
    if timer < 26 then
        timer = timer + dt
        if timer > 26 then
            IssueAchv('respectful')
        end
    end
    scroll1 = MATH.expApproach(scroll1, scroll, dt * 26)
end

local gc = love.graphics
local gc_replaceTransform, gc_translate = gc.replaceTransform, gc.translate
local gc_setColor, gc_rectangle, gc_print = gc.setColor, gc.rectangle, gc.print
local gc_setAlpha, gc_setLineWidth = GC.setAlpha, GC.setLineWidth
local gc_draw, gc_mDraw = GC.draw, GC.mDraw
local gc_line = GC.line
function scene.draw()
    DrawBG(26)

    gc_replaceTransform(SCR.xOy_u)
    gc_translate(0, 100 - scroll1)

    gc_setColor(1, 1, 1)
    local icon, kx, ky
    if GAME.mod.EX > 0 then
        icon = TEXTURE.logo_old
        kx, ky = .5, .5
    else
        icon = TEXTURE.logo
        kx, ky = .3, .3
    end
    if GAME.anyRev then ky = -ky end
    gc_mDraw(icon, -170, 100, 0, kx, ky)
    gc_draw(AboutText)

    gc_setColor(1, 1, 1, .2)
    gc_setLineWidth(0.5)
    for i = 1, #lines do
        gc_line(-600, lines[i], 600, lines[i])
    end

    if love.keyboard.isDown('space') then
        gc_setColor(1, 1, 0)
        FONT.set(30)
        for x = -600, 600 - 100, 100 do
            for y = 0, 900 - 100, 100 do
                gc_rectangle('line', x, y, 100, 100)
                gc_print(x .. ',' .. y, x + 2.6, y, 0, .355)
            end
        end
    end

    -- Top bar & title
    gc_replaceTransform(SCR.xOy_u)
    gc_setColor(clr.D)
    gc_rectangle('fill', -1300, 0, 2600, 70)
    gc_setColor(clr.L)
    gc_setAlpha(.626)
    gc_rectangle('fill', -1300, 70, 2600, 3)
    gc_replaceTransform(SCR.xOy_ul)
    gc_setColor(clr.L)
    FONT.set(50)
    if GAME.anyRev then
        gc_print("ABOUT", 15, 68, 0, 1, -1)
    else
        gc_print("ABOUT", 15, 0)
    end

    -- Bottom bar & thanks
    gc_replaceTransform(SCR.xOy_d)
    gc_setColor(clr.D)
    gc_rectangle('fill', -1300, 0, 2600, -50)
    gc_setColor(clr.L)
    gc_setAlpha(.626)
    gc_rectangle('fill', -1300, -50, 2600, -3)
    gc_replaceTransform(SCR.xOy_dl)
    gc_setColor(clr.L)
    FONT.set(30)
    gc_print("THANK YOU FOR PLAYING ZENITH CLICKER!", 15, -45, 0, .85, 1)
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
