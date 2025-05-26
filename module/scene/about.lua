---@type Zenitha.Scene
local scene = {}

local scroll, scroll1 = 0, 0
local maxScroll = 400

local clr = {
    D = { COLOR.HEX '1F1F1F' },
    L = { COLOR.HEX '656565' },

    z = { COLOR.HEX "80CCFF" },

    asrial = { COLOR.HEX "DDFF80" },
    ccyt = { COLOR.HEX "77DD66" },
    rzkj = { COLOR.HEX "9DBCFF" },

    flower = { COLOR.HEX "F880F0" },
    _ = { COLOR.HEX "000000" },
    matt = { COLOR.HEX "FFE590" },

    osk = { COLOR.HEX "DD99FF" },
    ocelot = { COLOR.HEX "FF99CC" },
    garbo = { COLOR.HEX "3A66DD" },

    flmk = { COLOR.HEX "B7A0FF" },
    sheep = { COLOR.HEX "FF82F0" },
    fcs = { COLOR.HEX "E9C6FF" },
    obs = { COLOR.HEX "BAFEFF" },
}

AboutText = GC.newText(FONT.get(70))
local lines = {}

local tempY = 0

local function addText(text, x, y, scale, wraplimit)
    if type(text) == 'string' then text = { COLOR.L, text } end
    scale = scale or 1
    local w = (wraplimit or 900) / scale
    AboutText:addf(text, w, 'center', x - w / 2 * scale, tempY + y, 0, scale)
end

local function addSection(y)
    tempY = y
    table.insert(lines, y)
end

addText("ZENITH", 40, 20)
addText("CLICKER", 80, 95)

addSection(220)

addText(STRING.trimIndent [[
    FLIP THE TAROT CARDS IN THIS MODERN YET UNFAMILIAR OFFLINE CLICKER.
    PLAY TO IMPROVE YOUR SKILLS, AND GAIN CR FROM VARIOUS MODS
    - THE CLICKER FUTURE IS YOURS!
]], 0, 23, .3, 800)

addSection(350)

-- THE TEAM

addText({ COLOR.O, "THE TEAM" }, 0, 20, .3)

addText({ clr.z, "MRZ" }, 0, 60, .5)
addText({ COLOR.LD, "FOUNDER & LEAD PRODUCER" }, 0, 100, .26)
addText({ COLOR.LD, "Programming, Game Design, General Development" }, 0, 120, .2)

addText({ clr.asrial, "DJ  ASRIEL" }, -160, 160, .5)
addText({ COLOR.LD, "ASSISTING GRAPHICS DESIGN" }, -160, 200, .26)
addText({ COLOR.LD, "Background Reconstruction & Game Icon" }, -160, 220, .2)

addText({ clr.ccyt, "CREEPERCRAFTYT" }, 160, 160, .5)
addText({ COLOR.LD, "ASSISTING GRAPHICS DESIGN" }, 160, 200, .26)
addText({ COLOR.LD, "Mod Icons Remake" }, 160, 220, .2)

addText({ clr.flower, "FLOWERLING" }, -480, 160, .5)
addText({ COLOR.LD, "TEXT REVISION" }, -480, 200, .26)

addText({ clr.matt, "MATTMAYUGA" }, 480, 160, .5)
addText({ COLOR.LD, "TEXT REVISION" }, 480, 200, .26)

addText({ clr.osk, "OSK" }, -320, 260, .5)
addText({ COLOR.LD, "FOUNDER & LEAD PRODUCER…" }, -320, 300, .26)
addText({ COLOR.LD, "of the Original Game: TETR.IO" }, -320, 320, .2)

addText({ clr.ocelot, "DOKTOROCELOT" }, 0, 260, .5)
addText({ COLOR.LD, "AUDIO & MUSIC" }, 0, 300, .26)
addText({ COLOR.LD, "of both TETR.IO and Zenith Clicker" }, 0, 320, .2)

addText({ clr.garbo, "GARBO" }, 320, 260, .5)
addText({ COLOR.LD, "GAME & WORLD DESIGN…" }, 320, 300, .26)
addText({ COLOR.LD, "of the Original Game: TETR.IO" }, 320, 320, .2)

addSection(710)

addText({ COLOR.O, "ART BY" }, 0, 20, .3)

addText("LARGEONIONS", -300 * 1.26, 62, .46)
addText({ COLOR.LD, "FLOORS 1-5" }, -300 * 1.26, 100, .26)
addText("S. ZHANG", -100 * 1.26, 62, .46)
addText({ COLOR.LD, "FLOORS 6-8" }, -100 * 1.26, 100, .26)
addText("LAUREN SHENG", 100 * 1.26, 62, .46)
addText({ COLOR.LD, "FLOORS 9-10" }, 100 * 1.26, 100, .26)
addText("RICMAN", 300 * 1.26, 62, .46)
addText({ COLOR.LD, "CARD ART" }, 300 * 1.26, 100, .26)

addSection(860)

addText({
    COLOR.O, "MUSICS BY ",
    clr.ocelot, "DOKTOROCELOT      ",
    COLOR.O, "EXTRA MUSIC BY ",
    clr.rzkj, "RONEZKJ15",
}, 0, 20, .32)

addText({
    COLOR.O, "MANY TEXTS BY ",
    clr.flmk, "FLOMIKEL ",
    COLOR.O, "& ",
    clr.sheep, "SPRITZY SHEEP ",
    COLOR.O, "& ",
    clr.fcs, "FCSPLAYZ ",
    COLOR.O, "& ",
    clr.obs, "OBSIDIAN "
}, 0, 60, .32)

addText({
    COLOR.O, "FONTS BY ",
    COLOR.L, "ADRIAN FRUTIGER (D-DIN-PRO) ",
    COLOR.O, "& ",
    COLOR.L, "MOONIAK (ABHAYALIBRE)"
}, 0, 100, .32)

addText({
    COLOR.O, "SOME ACHV ICONS BY ",
    COLOR.L, "LORC ",
    COLOR.O, "& ",
    COLOR.L, "DELAPOUITE ",
    COLOR.O, "& ",
    COLOR.L, "QUOTING ",
    COLOR.O, "FROM ",
    COLOR.L, "GAME-ICONS.NET"
}, 0, 140, .32)

addSection(1050)

addText({ COLOR.O, "ALL PARTICIPANTS" }, 0, 20, .3)

addText({
    table.concat({
        "5HAN",
        "ADRIAN FRUTIGER",
        "BARON",
        "CREEPERCRAFTYT",
        "DELAPOUITE",
        "DJ ASRIEL",
        "DOKTOROCELOT",
        "FCSPLAYZ",
        "FLOMIKEL",
        "FLOWERLING",
        "GAMETILDEAD",
        "GARBO",
        "LARGEONIONS",
        "LAUREN SHENG",
        "LORC",
        "MATTMAYUGA",
        "MOONIAK",
        "MRZ",
        "OBSIDIAN",
        "OSK",
        "QUOTING",
        "RICMAN",
        "RONEZKJ15",
        -- "RTXTILE",
        "S. ZHANG",
        "SPRITZY SHEEP",
        "THE_111THBLITZER",
        "TIZAGO",
        "WAH",
    }, ",  ")
}, 0, 60, .26)

local timer
function scene.load()
    MSG.clear()
    timer = 0
    SetMouseVisible(true)
    scroll, scroll1 = 0, -620
end

function scene.mouseMove(_, _, _, dy)
    if love.mouse.isDown(1, 2) then
        scroll = MATH.clamp(scroll - dy, 0, maxScroll)
    end
end

function scene.touchMove(_, _, _, dy)
    scroll = MATH.clamp(scroll - dy, 0, maxScroll)
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
    scroll = MATH.clamp(scroll - dy * 42, 0, maxScroll)
end

function scene.update(dt)
    if timer < 26 then
        timer = timer + dt
        if timer > 26 then
            IssueAchv('respectful')
        end
    end
    if GAME.mod.EX == 2 then scroll = math.min(scroll + .26, maxScroll) end
    local y0 = scroll1
    scroll1 = MATH.expApproach(scroll1, scroll, dt * 26)
    GAME.bgH = math.max(GAME.bgH + (y0 - scroll1) / 355, 0)
    GAME.height = GAME.bgH
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

    -- Grid
    if love.keyboard.isDown('space') then
        gc_setColor(1, 1, 0)
        FONT.set(30)
        for x = -600, 600 - 100, 100 do
            for y = 0, 1300 - 100, 100 do
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
