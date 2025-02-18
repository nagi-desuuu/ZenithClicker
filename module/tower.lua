local scene = {}

function scene.load()
    love.keyboard.setKeyRepeat(false)
end

function scene.mouseMove(x, y, dx, dy)
    MX, MY = x, y
    local new = MouseOnCard(x, y)
    if FloatOnCard ~= new then
        FloatOnCard = new
        RefreshLayout()
        if FloatOnCard then
            SFX.play('card_slide_' .. math.random(4), .5)
        end
    end
end

local function click(x, y, k)
    local C = Cards[MouseOnCard(x, y)]
    if C then
        if GAME.playing then
            C:setActive()
        else
            if not C.lock then
                C:setActive()
            else
                C:shake()
                SFX.play('no')
            end
        end
    end
end

local function keyPress(key)
    if key == 'escape' then
        if not GAME.playing then
            if TASK.lock('sure_quit', 2.6) then
                MSG('io', "PRESS AGAIN TO QUIT", 2.6)
            else
                BGM.set('all', 'volume', 0, 1.6)
                SFX.play('menuback')
                SCN.back()
            end
        end
    elseif key == 'z' then
        GAME.cancelAll()
    elseif key == 'space' then
        if GAME.playing then
            GAME.finish()
        else
            GAME.start()
        end
    elseif key == '\\' then
        if not GAME.playing then
            local unlocked
            for i = 1, #Cards - 1 do
                if Cards[i].lock then
                    Cards[i].lock = false
                    unlocked = true
                    Cards[i]:shake()
                end
            end
            if unlocked then
                SFX.play('notify')
            end
        end
    elseif GAME.mod_AS > 0 or (not GAME.playing and (key == 'k' or key == 'i')) then
        local C = Cards[#key == 1 and ("asdfghjkl"):find(key, nil, true) or ("qwertyuio"):find(key, nil, true)]
        if C then C:setActive() end
    end
end

local cancelNextClick
function scene.mouseDown(x, y, k)
    if GAME.mod_EX == 0 then
        click(x, y, k)
        if GAME.mod_EX > 0 then
            cancelNextClick = true
        end
    end
end

function scene.mouseClick(x, y, k)
    if cancelNextClick then
        cancelNextClick = false
        return
    end
    if GAME.mod_EX > 0 then
        click(x, y, k)
    end
end

local cancelNextPress
function scene.keyDown(key)
    if GAME.mod_EX == 0 then
        keyPress(key)
        if GAME.mod_EX > 0 then
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
    if GAME.mod_EX > 0 then
        keyPress(key)
    end
end

function scene.update(dt)
    GAME.update(dt)
    for i = 1, #Cards do
        Cards[i]:update(dt)
    end
    if love.keyboard.isDown('escape') and GAME.playing then
        GAME.forfeitTimer = GAME.forfeitTimer + dt
        if GAME.forfeitTimer > 2.6 then
            GAME.finish()
        end
    else
        if GAME.forfeitTimer > 0 then
            GAME.forfeitTimer = GAME.forfeitTimer - (GAME.playing and 2.6 or 6.2) * dt
        end
    end
end

local gc = love.graphics

local shortcut = ('QWERTYUIO'):atomize()
local shadeColor = { .3, .15, 0 }
local textColor = { .7, .5, .3 }
local origAuth = gc.newText(FONT.get(30), "All Arts & Sounds from TETR.IO by osk")
local title = gc.newText(FONT.get(50), "EXPERT QUICK PICK")
local slogan = gc.newText(FONT.get(30), "CROWD THE TOWER!")
local sloganExp = gc.newText(FONT.get(30), "THRONG THE TOWER!")
-- local sloganRev=GC.newText(FONT.get(30),"OVERFLOW THE TOWER!")
function scene.draw()
    gc.clear(GAME.bg, 0, 0)
    gc.setColor(1, 1, 1)
    if FloatOnCard then
        for i = #Cards, 1, -1 do
            if i ~= FloatOnCard then Cards[i]:draw() end
        end
        Cards[FloatOnCard]:draw()
    else
        for i = #Cards, 1, -1 do Cards[i]:draw() end
    end
    if GAME.mod_AS > 0 then
        FONT.set(60)
        for i = 1, #Cards do
            local C = Cards[i]
            GC.strokePrint('full', 4, shadeColor, COLOR.lR, shortcut[i], C.x + 80, C.y + 120)
        end
    end

    if GAME.playing then
        gc.setColor(COLOR.L)
        FONT.set(40)
        GC.mStr(("%.1fm"):format(GAME.altitude), 800, 942)
    else
        gc.setColor(.7, .5, .3)
        local k = math.min(.9, 760 / GAME.modText:getWidth())
        GC.mDraw(GAME.modText, 800, 396, nil, k, k * 1.1)

        if FloatOnCard then
            local C = Cards[FloatOnCard]
            if C.lock then C = DeckData[0] end
            gc.setColor(.3, .1, 0, .62)
            GC.mRect('fill', 800, 910, 1260, 126, 10)
            gc.setColor(.7, .5, .3)
            FONT.set(60)
            GC.strokePrint('full', 3, shadeColor, textColor, C.fullName, 800, 842, nil, 'center')
            FONT.set(30)
            GC.strokePrint('full', 2, shadeColor, textColor, C.desc, 800, 926, nil, 'center')
        end

        gc.replaceTransform(SCR.xOy_ul)
        gc.draw(title, GAME.exTimer * 205 - 195, 0, nil, 1, 1.1)
        gc.replaceTransform(SCR.xOy_dl)
        gc.draw(slogan, 6, 2 + GAME.exTimer * 42, nil, 1, 1.26, 0, origAuth:getHeight())
        gc.draw(sloganExp, 6, 2 + (1 - GAME.exTimer) * 42, nil, 1, 1.26, 0, origAuth:getHeight())

        gc.replaceTransform(SCR.xOy_dr)
        gc.setColor(.26, .26, .26)
        gc.draw(origAuth, -5, 0, nil, 1, 1, origAuth:getDimensions())
    end
end

function scene.overDraw()
    if GAME.forfeitTimer > 0 then
        gc.replaceTransform(SCR.origin)
        gc.setColor(.872, .26, .26, GAME.forfeitTimer * .6)
        gc.rectangle('fill', 0, SCR.h, SCR.w, -SCR.h * GAME.forfeitTimer / 2.6 * .5)
        gc.setColor(.626, 0, 0, GAME.forfeitTimer * .6)
        gc.rectangle('fill', 0, SCR.h * (1 - GAME.forfeitTimer / 2.6 * .5), SCR.w, -5)
    end
end

scene.widgetList = {
    WIDGET.new {
        name = 'start', type = 'button',
        pos = { .5, .5 }, y = -170, w = 800, h = 200, cornerR = 2,
        color = 'lF',
        sound_hover = 'menuhover',
        fontSize = 100, text = "START",
        onClick = function()
            if GAME.playing then
                GAME.finish()
            else
                GAME.start()
            end
        end,
    },
    WIDGET.new {
        name = 'reset', type = 'button',
        pos = { .5, .5 }, x = 500, y = -120, w = 160, h = 100, cornerR = 2,
        color = 'DR',
        sound_hover = 'menutap',
        sound_release = 'menuclick',
        fontSize = 40, text = "RESET", textColor = 'dR',
        onClick = function() GAME.cancelAll() end,
    },
    WIDGET.new {
        name = 'hint', type = 'hint',
        pos = { .5, .5 }, x = 500, y = -230, w = 80, cornerR = 40,
        color = 'lF',
        fontSize = 80, text = "?", textColor = 'dF',
        sound_hover = 'menutap',
        labelPos = 'leftBottom',
        floatText = STRING.trimIndent [[
            Welcome to Zenith Clicker! Select required tarots to send players to scale the tower.
            The higher the tower, the more tricky players will come!
            There's no leaderboard, but how high can you reach?
        ]],
    }
}

return scene
