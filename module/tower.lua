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
    local GAME = GAME
    if GAME.playing then
        local distRemain = Floors[GAME.floor].top - GAME.altitude
        GAME.altitude = GAME.altitude + dt * GAME.rank / 4 * MATH.icLerp(1, 6, distRemain)

        -- if love.keyboard.isDown('z') then
        --     GAME.altitude = GAME.altitude + dt * 260
        -- end

        if GAME.altitude >= Floors[GAME.floor].top then
            GAME.floor = GAME.floor + 1
            if GAME.mod_MS == 1 and (GAME.floor % 2 == 1 or GAME.floor == 10) then GAME:shuffleCards() end
            TEXT:add {
                text = "Floor",
                x = 160, y = 290, k = 1.6, fontSize = 30,
                color = 'LY', duration = 2.6,
            }
            TEXT:add {
                text = tostring(GAME.floor),
                x = 240, y = 280, k = 2.6, fontSize = 30,
                color = 'LY', duration = 2.6, align = 'left',
            }
            TEXT:add {
                text = Floors[GAME.floor].name,
                x = 200, y = 350, k = 1.2, fontSize = 30,
                color = 'LY', duration = 2.6,
            }
            SFX.play('zenith_levelup_' .. Floors[GAME.floor].sfx)
        end

        GAME.xp = GAME.xp - dt * (GAME.mod_EX and 5 or 3) * GAME.rank * (GAME.rank + 1) / 60
        if GAME.xp <= 0 then
            GAME.xp = 0
            if GAME.rank > 1 then
                GAME.rank = GAME.rank - 1
                SFX.play('speed_down')
                -- SFX.play('speed_up_'..MATH.clamp(GAME.rank-1,1,4))
            end
        end
    end
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

local gc = love.graphics

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
    if not FloatOnCard then
        for i = #Cards, 1, -1 do Cards[i]:draw() end
    else
        for i = #Cards, 1, -1 do
            if i ~= FloatOnCard then Cards[i]:draw() end
        end
        Cards[FloatOnCard]:draw()
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
                GAME:finish()
            else
                GAME:start()
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
        onClick = function()
            GAME:cancelAll()
        end,
    },
    WIDGET.new {
        name = 'hint', type = 'hint',
        pos = { .5, .5 }, x = 500, y = -230, w = 80, cornerR = 40,
        color = 'lF',
        fontSize = 80, text = "?", textColor = 'dF',
        labelPos = 'leftBottom',
        floatText = STRING.trimIndent [[
            Welcome to Zenith Clicker! Select required tarots to send players to scale the tower.
            The higher the tower, the more tricky players will come!
            There's no leaderboard, but how high can you reach?
        ]],
    }
}

return scene
