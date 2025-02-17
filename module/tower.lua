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

function scene.mouseClick(x, y, k)
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

MSG.addCategory('io', COLOR.lD, COLOR.L)
MSG.setSafeY(62)
function scene.keyDown(key)
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
        GAME:cancelAll()
    elseif key == 'space' then
        if GAME.playing then
            GAME:finish()
        else
            GAME:start()
        end
    elseif GAME.mod_AS > 0 or (not GAME.playing and (key == 'k' or key == 'i')) then
        local C = Cards[#key == 1 and ("asdfghjkl"):find(key, nil, true) or ("qwertyuio"):find(key, nil, true)]
        if C then C:setActive() end
    end
    return true
end

function scene.update(dt)
    for i = 1, #Cards do
        Cards[i]:update(dt)
    end
    if love.keyboard.isDown('escape') and GAME.playing then
        GAME.forfeitTimer = GAME.forfeitTimer + dt
        if GAME.forfeitTimer > 2.6 then
            GAME:finish()
        end
    else
        if GAME.forfeitTimer > 0 then
            GAME.forfeitTimer = GAME.forfeitTimer - (GAME.playing and 2.6 or 6.2) * dt
        end
    end
end

local origAuth = GC.newText(FONT.get(30), "All Arts & Sounds from TETR.IO, by osk team")
local title = GC.newText(FONT.get(50), "EXPERT QUICK PICK")
local slogan = GC.newText(FONT.get(30), "CROWD THE TOWER!")
local sloganExp = GC.newText(FONT.get(30), "THRONG THE TOWER!")
-- local sloganRev=GC.newText(FONT.get(30),"OVERFLOW THE TOWER!")
function scene.draw()
    GC.clear(GAME.bg, 0, 0)
    GC.setColor(1, 1, 1)
    if not FloatOnCard then
        for i = #Cards, 1, -1 do Cards[i]:draw() end
    else
        for i = #Cards, 1, -1 do
            if i ~= FloatOnCard then Cards[i]:draw() end
        end
        Cards[FloatOnCard]:draw()
    end

    if not GAME.playing then
        GC.setColor(.7, .5, .3)
        local k = math.min(.9, 760 / GAME.modText:getWidth())
        GC.mDraw(GAME.modText, 800, 362, nil, k, k * 1.1)

        GC.replaceTransform(SCR.xOy_ul)
        GC.draw(title, GAME.exTimer * 205 - 195, 0, nil, 1, 1.1)
        GC.replaceTransform(SCR.xOy_dl)
        GC.draw(slogan, 6, 2 + GAME.exTimer * 42, nil, 1, 1.26, 0, origAuth:getHeight())
        GC.draw(sloganExp, 6, 2 + (1 - GAME.exTimer) * 42, nil, 1, 1.26, 0, origAuth:getHeight())

        GC.replaceTransform(SCR.xOy_dr)
        GC.setColor(.26, .26, .26)
        GC.draw(origAuth, -5, 0, nil, 1, 1, origAuth:getDimensions())
    end
end

function scene.overDraw()
    if GAME.forfeitTimer > 0 then
        GC.replaceTransform(SCR.origin)
        GC.setColor(.872, .26, .26, GAME.forfeitTimer * .6)
        GC.rectangle('fill', 0, SCR.h, SCR.w, -SCR.h * GAME.forfeitTimer / 2.6 * .5)
        GC.setColor(.626, 0, 0, GAME.forfeitTimer * .6)
        GC.rectangle('fill', 0, SCR.h * (1 - GAME.forfeitTimer / 2.6 * .5), SCR.w, -5)
    end
end

scene.widgetList = {
    WIDGET.new {
        name = 'start', type = 'button',
        pos = { .5, .5 }, y = -220, w = 800, h = 260, cornerR = 2,
        color = 'lF',
        sound_hover = 'menuhover',
        fontSize = 100, text = "START",
        onClick = function()
            if GAME.playing then
                GAME:finish()
            else
                GAME:start()
            end
        end,
    },
    WIDGET.new {
        name = 'reset', type = 'button',
        pos = { .5, .5 }, x = 500, y = -140, w = 160, h = 100, cornerR = 2,
        color = 'DR',
        sound_hover = 'menutap',
        sound_release = 'menuclick',
        fontSize = 40, text = "RESET", textColor = 'dR',
        onClick = function()
            GAME:cancelAll()
        end,
    },
    WIDGET.new {
        name = 'hint', type = 'hint',
        pos = { .5, .5 }, x = 500, y = -280, w = 160, h = 140, cornerR = 2,
        color = 'lF',
        fontSize = 80, text = "?", textColor = 'DR',
        labelPos = 'leftBottom',
        floatText = STRING.trimIndent [[
            Welcome to Zenith Clicker! Feed required cards to send players to scales the tower.
            The higher the tower, more tricky players will come!
            There's no leaderboard, but how high can you reach?
        ]],
    }
}

return scene
