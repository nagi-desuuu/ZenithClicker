local scene = {}

function scene.load()
    love.keyboard.setKeyRepeat(false)
end

local function MouseOnCard(x, y)
    if FloatOnCard and Cards[FloatOnCard]:mouseOn(x, y) then
        return FloatOnCard
    end
    local cid, dist = 0, 1e99
    for j = 1, #Cards do
        if Cards[j]:mouseOn(x, y) then
            local dist2 = MATH.distance(x, y, Cards[j].x, Cards[j].y)
            if dist2 < dist then
                dist = dist2
                cid = j
            end
        end
    end
    if cid > 0 then
        return cid
    end
end

local function mouseMove(x, y)
    MX, MY = x, y
    local new = MouseOnCard(x, y)
    if FloatOnCard ~= new then
        FloatOnCard = new
        if new then
            SFX.play('card_slide_' .. math.random(4), .5)
        end
        GAME.refreshLayout()
    end
end

local function mousePress(x, y, k)
    mouseMove(x, y)
    local C = Cards[FloatOnCard]
    if C then
        if GAME.playing or not C.lock then
            C:setActive()
        else
            C:flick()
            SFX.play('no')
        end
    end
end

local function keyPress(key)
    if key == 'escape' then
        if not GAME.playing then
            if TASK.lock('sure_quit', 2.6) then
                SFX.play('menuclick')
                MSG('dark', "PRESS AGAIN TO QUIT", 2.6)
            else
                BGM.set('all', 'volume', 0, 1.6)
                SFX.play('menuback')
                SCN.back()
            end
        end
    elseif key == 'z' then
        SFX.play('menuclick')
        GAME.cancelAll()
    elseif key == 'space' then
        if GAME.playing then
            GAME.commit()
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
                    Cards[i]:flick()
                end
            end
            if unlocked then
                SFX.play('supporter')
            end
        end
    elseif GAME.mod_AS > 0 or (not GAME.playing and (key == 'k' or key == 'i')) then
        local C = Cards[#key == 1 and ("asdfghjkl"):find(key, nil, true) or ("qwertyuio"):find(key, nil, true)]
        if C then
            if GAME.playing or not C.lock then
                C:setActive()
            else
                C:flick()
                SFX.play('boardlock_clink')
            end
        end
    end
end

function scene.mouseMove(x, y, dx, dy)
    mouseMove(x, y)
end

local cancelNextClick
function scene.mouseDown(x, y, k)
    if GAME.mod_EX == 0 then
        mousePress(x, y, k)
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
        mousePress(x, y, k)
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
        GAME.forfeitTimer = GAME.forfeitTimer + dt * MATH.clampInterpolate(4, 6, 10, 2, GAME.questCount)
        if TASK.lock('forfeit_sfx', .0872) then
            SFX.play('detonate1', MATH.clampInterpolate(0, .4, 2, .6, GAME.forfeitTimer))
        end
        if GAME.forfeitTimer > 2.6 then
            SFX.play('detonate2')
            GAME.finish('forfeit')
        end
    else
        if GAME.forfeitTimer > 0 then
            GAME.forfeitTimer = GAME.forfeitTimer - (GAME.playing and 2.6 or 6.2) * dt
        end
    end
end

local gc = love.graphics
local Cards = Cards

local shortcut = ('QWERTYUIO'):atomize()
local shadeColor = { .3, .15, 0 }
local textColor = { .7, .5, .3 }
local rankColor = {
    [0] = { 0, 0, 0, 0 },
    { 1,  .1, 0 },
    { 1,  .7, 0 },
    { .5, 1,  0 },
    { 0,  .7, 1 },
    { 1,  .1, 1 },
    { 1,  .8, .5 },
    { .6, 1,  .8 },
    { .4, .9, 1 },
    { 1,  .8, 1 },
}
local origAuth = gc.newText(FONT.get(30), "All Arts & Sounds from TETR.IO by osk")
local slogan = gc.newText(FONT.get(30), "CROWD THE TOWER!")
local sloganExp = gc.newText(FONT.get(30), "THRONG THE TOWER!")
-- local sloganRev=GC.newText(FONT.get(30),"OVERFLOW THE TOWER!")
function scene.draw()
    gc.replaceTransform(SCR.origin)
    GC.setColor(1, 1, 1, GAME.bgAlpha * .42)
    GC.mDraw(IMG.floorBG[GAME.bgFloor], SCR.w / 2, SCR.h / 2, nil, math.max(SCR.w / 1920, SCR.h / 1080))

    gc.replaceTransform(SCR.xOy)

    -- Cards
    gc.setColor(1, 1, 1)
    if FloatOnCard then
        for i = #Cards, 1, -1 do
            if i ~= FloatOnCard then Cards[i]:draw() end
        end
        Cards[FloatOnCard]:draw()
    else
        for i = #Cards, 1, -1 do Cards[i]:draw() end
    end

    -- Allspin keyboard hint
    if GAME.mod_AS > 0 then
        FONT.set(60)
        for i = 1, #Cards do
            GC.strokePrint('full', 4, shadeColor, COLOR.lR, shortcut[i], Cards[i].x + 80, Cards[i].y + 120)
        end
    end

    -- Thruster
    gc.setColor(rankColor[GAME.rank - 1] or COLOR.L)
    GC.mRect('fill', 800, 975, 420, 26)
    gc.setColor(rankColor[GAME.rank] or COLOR.L)
    GC.mRect('fill', 800, 975, 420 * GAME.xp / (4 * GAME.rank), 26)
    GC.setLineWidth(2)
    gc.setColor(1, 1, 1, .42)
    GC.mRect('line', 800, 975, 420, 26)

    -- Altitude
    FONT.set(40)
    GC.strokePrint('full', 3, COLOR.D, COLOR.L, ("%.1fm"):format(GAME.altitude), 800, 942, nil, 'center')

    if GAME.playing then
        -- Target combo
        gc.setColor(COLOR.L)
        FONT.set(80)
        GC.mStr(GAME.quests[1].name, 800, 110)
        if GAME.quests[2] then
            gc.setColor(COLOR.DL)
            FONT.set(60)
            GC.mStr(GAME.quests[2].name, 800, 50)
            if GAME.quests[3] then
                gc.setColor(COLOR.LD)
                FONT.set(50)
                GC.mStr(GAME.quests[3].name, 800, 0)
            end
        end
    else
        -- Card info
        if FloatOnCard then
            local C = Cards[FloatOnCard]
            if C.lock then C = DeckData[0] end
            gc.setColor(.3, .1, 0, .62)
            GC.mRect('fill', 800, 910, 1260, 126, 10)
            FONT.set(60)
            GC.strokePrint('full', 3, shadeColor, textColor, C.fullName, 800, 842, nil, 'center')
            FONT.set(30)
            GC.strokePrint('full', 2, shadeColor, textColor, C.desc, 800, 926, nil, 'center')
        end
    end
    -- Texts
    if GAME.textHide < 1 then
        local d = GAME.textHide * 70
        gc.replaceTransform(SCR.xOy_ul)
        gc.translate(0, -d)
        gc.setColor(shadeColor)
        GC.rectangle('fill', 0, 0, 1600, 70)
        gc.setColor(textColor)
        FONT.set(50)
        gc.print("EXPERT QUICK PICK", GAME.exTimer * 205 - 195, 0, nil, 1, 1.1)
        gc.printf("Personal Best: " .. (GAME.mod_EX and DATA.maxAltitude_ex or DATA.maxAltitude) .. "m", 0, 0, 1590,'right',nil,1,1.1)

        gc.replaceTransform(SCR.xOy_dl)
        gc.translate(0, d)
        gc.draw(slogan, 6, 2 + GAME.exTimer * 42, nil, 1, 1.26, 0, origAuth:getHeight())
        gc.draw(sloganExp, 6, 2 + (1 - GAME.exTimer) * 42, nil, 1, 1.26, 0, origAuth:getHeight())
        gc.replaceTransform(SCR.xOy_dr)
        gc.setColor(.26, .26, .26)
        gc.draw(origAuth, -5, 0, nil, 1, 1, origAuth:getDimensions())
    end
end

function scene.overDraw()
    -- Current combo
    gc.setColor(.7, .5, .3)
    local k = math.min(.9, 760 / GAME.modText:getWidth())
    GC.mDraw(GAME.modText, 800, 396, nil, k, k * 1.1)

    if GAME.forfeitTimer > 0 then
        gc.replaceTransform(SCR.origin)
        gc.setColor(.872, .26, .26, GAME.forfeitTimer * .6)
        gc.rectangle('fill', 0, SCR.h, SCR.w, -SCR.h * GAME.forfeitTimer / 2.6 * .5)
        gc.setColor(.626, 0, 0, GAME.forfeitTimer * .6)
        gc.rectangle('fill', 0, SCR.h * (1 - GAME.forfeitTimer / 2.6 * .5), SCR.w, -5)
    end
end

function WIDGET._prototype.button:draw()
    gc.push('transform')
    gc.translate(self._x, self._y)

    if self._pressTime > 0 then
        gc.scale(1 - self._pressTime / self._pressTimeMax * .0626)
    end
    local w, h = self.w, self.h

    local fillC = self.fillColor
    local frameC = self.frameColor

    -- Background
    gc.setColor(fillC[1], fillC[2], fillC[3], fillC[4])
    GC.mRect('fill', 0, 0, w, h)

    -- Frame
    gc.setLineWidth(self.lineWidth)
    gc.setColor(frameC[1] * .2, frameC[2] * .2, frameC[3] * .2)
    gc.line(-w / 2, h / 2, w / 2, h / 2, w / 2, -h / 2)
    gc.setColor(.2 + frameC[1] * .8, .2 + frameC[2] * .8, .2 + frameC[3] * .8)
    gc.line(-w / 2, h / 2, -w / 2, -h / 2, w / 2, -h / 2)

    -- Highlight
    if self._hoverTime > 0 then
        gc.setColor(1, 1, 1, self._hoverTime / self._hoverTimeMax * .16)
        GC.mRect('fill', 0, 0, w, h)
    end

    -- Drawable
    local startX =
        self.alignX == 'center' and 0 or
        self.alignX == 'left' and -w * .5 + self.marginX or
        w * .5 - self.marginX
    local startY =
        self.alignY == 'center' and 0 or
        self.alignY == 'top' and -h * .5 + self.marginY or
        h * .5 - self.marginY
    if self._text then
        gc.setColor(self.textColor)
        WIDGET._alignDraw(self, self._text, startX, startY, nil, self.textScale)
    end
    gc.pop()
end

scene.widgetList = {
    WIDGET.new {
        name = 'start', type = 'button',
        pos = { .5, .5 }, y = -170, w = 800, h = 200,
        color = { .35, .12, .05 },
        textColor = textColor,
        sound_hover = 'menuhover',
        fontSize = 100, text = "START",
        onClick = function()
            if GAME.playing then
                GAME.commit()
            else
                GAME.start()
            end
        end,
    },
    WIDGET.new {
        name = 'reset', type = 'button',
        pos = { .5, .5 }, x = 500, y = -120, w = 160, h = 100,
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
            Space: Start/Commit   Z: Reset selection   ESC: Forfeit/Quit
        ]],
    }
}

return scene
