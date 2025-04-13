---@type Zenitha.Scene
local scene = {}

local maskAlpha, cardShow
local card = GC.newCanvas(1200, 720)

local floor = math.floor

local baseColor = { .12, .26, .14 }
local areaColor = { .12, .23, .12 }
local titleColor = { COLOR.HEX("16582D") }
local textColor = { COLOR.HEX("54B06D") }
local scoreColor = { COLOR.HEX("B0FFC0") }
local setup = { stencil = true, card }

local function getF10Completion()
    local s = 0
    for i = 1, 9 do
        local id = ModData.deck[i].id
        if BEST.highScore[id] >= Floors[9].top then s = s + 1 end
        if BEST.highScore['r' .. id] >= Floors[9].top then s = s + 1 end
    end
    return s
end
local function getSpeedrunCompletion()
    local s = 0
    for i = 1, 9 do
        local id = ModData.deck[i].id
        if BEST.speedrun[id] < 1e26 then s = s + 1 end
        if BEST.speedrun['r' .. id] < 1e26 then s = s + 1 end
    end
    return s
end
local function norm(x, k) return 1 + (x - 1) / (k * x + 1) end
local function calculateRating()
    local cr = 0

    -- Best Height (5K)
    cr = cr + 5000 * norm(MATH.icLerp(50, 6666, STAT.maxHeight), 6.2)

    -- Best Time (5K)
    cr = cr + 5000 * norm(MATH.icLerp(420, 76.2, STAT.minTime), -.5)

    -- Mod Completion (3K)
    cr = cr + 3000 * norm(MATH.icLerp(0, 18, getF10Completion()), .62)

    -- Mod Speedrun (2K)
    cr = cr + 2000 * norm(MATH.icLerp(0, 18, getSpeedrunCompletion()), .62)

    -- Zenith Points (3K)
    cr = cr + 3000 * norm(MATH.icLerp(0, 1e6, STAT.zp), 2.6)

    -- TODO: Achievement (5K)
    -- TODO: Daily Challenge (2K)
    cr = MATH.clamp(cr * 25000 / 18000, 0, 25000)

    return MATH.round(cr)
end

local sawMap = {
    { 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0 },
    { 1, 0, 0, 0, 1, 1, 1, 0, 1, 1, 1, 1, 0, 0, 1, 0, 1, 0, 1, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0 },
    { 1, 1, 0, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 0 },
}
local saw = { w = 30, h = 3 }
for y = 1, 3 do
    for x = 1, 30 do
        if sawMap[y][x] == 1 then
            table.insert(saw, { 'fRect', x - 1, y - 1, 1, 1 })
        end
    end
end
saw = GC.load(saw)
saw:setFilter('nearest', 'nearest')
saw:setWrap('repeat', 'repeat')
local sawQuad = GC.newQuad(0, 0, 180, 3, saw)
local bannerQuad = GC.newQuad(0, 220, 512, 256, TEXTURE.logo)
local function dblMidDraw(obj, x, y)
    GC.mDraw(obj, x, y)
    GC.setAlpha(.626)
    GC.mDraw(obj, x, y + 2.6)
end
function RefreshProfile()
    ---@diagnostic disable
    local pnlColor = TABLE.copy(baseColor)
    local boxColor = TABLE.copy(areaColor)
    local lblColor = TABLE.copy(titleColor)
    local textColor = TABLE.copy(textColor)
    local scoreColor = TABLE.copy(scoreColor)
    ---@diagnostic enable

    if GAME.anyRev then
        pnlColor[1], pnlColor[2] = pnlColor[2], pnlColor[1]
        boxColor[1], boxColor[2] = boxColor[2], boxColor[1]
        lblColor[1], lblColor[2] = lblColor[2], lblColor[1]
        textColor[1], textColor[2] = textColor[2], textColor[1]
        scoreColor[1], scoreColor[2] = scoreColor[2], scoreColor[1]
    end

    GC.setCanvas(setup)
    GC.origin()
    GC.clear(pnlColor[1], pnlColor[2], pnlColor[3], 0)

    local t30 = GC.newText(FONT.get(30))
    local t50 = GC.newText(FONT.get(50))

    -- Banner
    GC.setColor(.42, .42, .42)
    GC.draw(TEXTURE.logo, bannerQuad, 0, 10, 0, 1200 / 512, 150 / 256)

    -- Main panel & frame
    GC.setColor(pnlColor)
    -- base
    GC.rectangle('fill', 0, 720, 1200, -560)
    -- deco
    GC.draw(saw, sawQuad, 0, 720 - 560, 0, 7.2, 7.2, 0, 3)
    -- top ribbon
    GC.setColor(boxColor)
    GC.rectangle('fill', 0, 210, 1200, 60)
    -- bottom ribbon
    GC.rectangle('fill', 0, 720, 1200, -90)
    -- github link
    FONT.set(50)
    GC.setColor(scoreColor)
    GC.printf("↗  VIEW SOURCE FILE", 0, 640, 1200, 'center')
    -- bottom dark
    GC.setColor(0, 0, 0, .3)
    GC.rectangle('fill', 0, 720, 1200, -3)
    -- right dark
    GC.setColor(0, 0, 0, .15)
    GC.rectangle('fill', 1200, 720, -3, -560)
    GC.draw(TEXTURE.transition, 1200, 720 - 560, -1.5708, .626, -3)
    -- left light
    GC.setColor(1, 1, 1, .15)
    GC.rectangle('fill', 0, 720, 3, -560)
    GC.draw(TEXTURE.transition, 0, 720 - 560, -1.5708, .626, 3)

    -- X
    FONT.set(30)
    GC.setColor(COLOR.DL)
    GC.print("CLOSE", 1068 - 10, 45 - 3, 0, 1.2)

    -- PFP
    GC.setColor(1, 1, 1)
    GC.stc_setComp()
    GC.stc_rect(30, 0, 120, 120, 6)
    GC.draw(TEXTURE.stat.avatar, 20, 0, 0, 130 / TEXTURE.stat.avatar:getWidth())
    GC.stc_stop()

    -- ID
    FONT.set(30)
    GC.print(("Joined " .. STAT.joinDate):upper(), 165, 96, 0, .7)
    FONT.set(50)
    GC.setColor(COLOR.L)
    GC.print(STAT.uid, 165, 18, 0, 1.2)

    -- Time
    GC.ucs_move('m', 1065, 165)
    GC.setColor(boxColor)
    GC.rectangle('fill', 0, 0, 110, 40, 5)
    GC.setColor(1, 1, 1)
    FONT.set(30)
    GC.mStr(STAT.totalTime <= 60000 and
        { scoreColor, floor(STAT.totalTime / 60), textColor, "min" }
        or { scoreColor, floor(STAT.totalTime / 3600), textColor, "H" },
        55, 0)
    GC.ucs_back()

    -- Clicker
    GC.setColor(1, 1, 1)
    GC.mDraw(TEXTURE.stat.clicker, 970, 182, 0, .626)

    -- Introduction
    GC.ucs_move('m', 25, 280)
    GC.setColor(boxColor)
    GC.rectangle('fill', 0, 0, 1150, 80)
    FONT.set(30)
    GC.setColor(lblColor)
    GC.print("ABOUT  ME", 7, 2, 0, .8)
    GC.setColor(textColor)
    GC.print(STAT.aboutme, 15, 35, 0, .8)
    GC.ucs_back()

    GC.setLineWidth(2)

    local bw, bh = 370, 120

    -- Rating
    GC.ucs_move('m', 25, 370)
    GC.setColor(boxColor)
    GC.rectangle('fill', 0, 0, bw, bh)
    FONT.set(30)
    GC.setColor(lblColor)
    GC.print("CLICKER  LEAGUE", 7, 2, 0, .8)
    GC.line(7, bh - 30, bw - 7, bh - 30)
    -- Number
    local rating = calculateRating()
    t30:set(rating == 25000 and "YOU ARE THE VERY BEST!" or "CALCULATED FROM CAREER")
    GC.mDraw(t30, bw / 2, 105, 0, .7)
    t50:set(tostring(rating))
    GC.setColor(scoreColor)
    dblMidDraw(t50, bw / 2, bh / 2 - 4)
    -- CR
    t30:set("CR")
    GC.setColor(scoreColor)
    dblMidDraw(t30, bw / 2 + t50:getWidth() / 2 + t30:getWidth() / 2, bh / 2 + 4)
    -- Rank
    local rank =
        STAT.totalTime / 60 + STAT.totalFloor / 9 + STAT.totalGiga / 2 <= 62 and 0 or
        MATH.clamp(math.ceil(rating / 1400), 1, 18)
    local rankIcon = TEXTURE.stat.rank[rank]
    GC.setColor(1, 1, 1)
    GC.mDraw(rankIcon, bw / 2 - t50:getWidth() / 2 - 21, bh / 2, 0, 42 / rankIcon:getWidth())
    if rank > 0 then
        -- Progress Bar
        GC.setColor(textColor)
        GC.line(7, bh - 30, MATH.lerp(7, bw - 7, rating % 1400 / (rank < 18 and 1400 or 1200)), bh - 30)
        GC.ucs_back()
    end

    -- Height
    GC.ucs_move('m', 412.5, 370)
    GC.setColor(boxColor)
    GC.rectangle('fill', 0, 0, bw, bh)
    FONT.set(30)
    GC.setColor(lblColor)
    GC.print("MAX  ALTITUDE", 7, 2, 0, .8)
    GC.line(7, bh - 30, bw - 7, bh - 30)
    GC.setColor(textColor)
    t30:set(STAT.heightDate)
    GC.mDraw(t30, bw / 2, 105, 0, .75)
    GC.setColor(scoreColor)
    t50:set(STAT.maxHeight <= 0 and "---" or tostring(STAT.maxHeight))
    dblMidDraw(t50, bw / 2, bh / 2 - 4)
    GC.setColor(textColor)
    t30:set("M")
    dblMidDraw(t30, bw / 2 + t50:getWidth() / 2 + t30:getWidth() / 2, bh / 2 + 4)
    GC.ucs_back()

    -- Speedrun
    GC.ucs_move('m', 800, 370)
    GC.setColor(boxColor)
    GC.rectangle('fill', 0, 0, bw, bh)
    FONT.set(30)
    GC.setColor(lblColor)
    GC.print("FASTEST  SPEEDRUN", 7, 2, 0, .8)
    GC.line(7, bh - 30, bw - 7, bh - 30)
    GC.setColor(textColor)
    t30:set(STAT.timeDate)
    GC.mDraw(t30, bw / 2, 105, 0, .75)
    GC.setColor(scoreColor)
    t50:set(STAT.minTime >= 1560 and "---" or tostring(STAT.minTime))
    dblMidDraw(t50, bw / 2, bh / 2 - 4)
    GC.setColor(textColor)
    t30:set("S")
    dblMidDraw(t30, bw / 2 + t50:getWidth() / 2 + t30:getWidth() / 2, bh / 2 + 4)
    GC.ucs_back()

    -- Career
    GC.ucs_move('m', 25, 500)
    GC.setColor(boxColor)
    GC.rectangle('fill', 0, 0, 570, bh)
    FONT.set(30)
    GC.setColor(lblColor)
    GC.print("CAREER", 7, 2, 0, .8)
    GC.setColor(1, 1, 1)
    local maxComp = TABLE.countAll(GAME.completion, 0) == 9 and 9 or 18
    for _, l in next, {
        { t = { textColor, "Zenith Points" },                                                     x = 26,  y = 33 },
        { t = { textColor, "Achievements" },                                                      x = 26,  y = 58 },
        { t = { textColor, "Daily Challenge" },                                                   x = 26,  y = 83 },
        { t = { scoreColor, MATH.round(STAT.zp) },                                                x = 200, y = 33 },
        { t = { scoreColor, "N/A" },                                                              x = 200, y = 58 },
        { t = { scoreColor, "N/A" --[[MATH.round(STAT.dailyHighscore)]] },                        x = 200, y = 83 },
        { t = { textColor, "Best Altitude" },                                                     x = 300, y = 8 },
        { t = { textColor, "Best Speedrun" },                                                     x = 300, y = 33 },
        { t = { textColor, "1-Mod Ascent" },                                                      x = 300, y = 58 },
        { t = { textColor, "1-Mod Speedrun" },                                                    x = 300, y = 83 },
        { t = { scoreColor, STAT.maxHeight <= 0 and "---" or MATH.round(STAT.maxHeight) .. "m" }, x = 480, y = 8 },
        { t = { scoreColor, STAT.minTime >= 1560 and "---" or MATH.round(STAT.minTime) .. "s" },  x = 480, y = 33 },
        { t = { scoreColor, getF10Completion() .. " / " .. maxComp },                             x = 480, y = 58 },
        { t = { scoreColor, getSpeedrunCompletion() .. " / " .. maxComp },                        x = 480, y = 83 },
    } do GC.print(l.t, l.x, l.y, 0, .75) end
    GC.ucs_back()

    -- Full stats
    GC.ucs_move('m', 605, 500)
    GC.setColor(boxColor)
    GC.rectangle('fill', 0, 0, 570, bh)
    FONT.set(30)
    GC.setColor(lblColor)
    GC.print("FULL  STATS", 7, 2, 0, .8)
    for _, l in next, {
        { k = "Game",    v = { scoreColor, STAT.totalGame },                                                       x = 26,  y = 33, d = 80 },
        { k = "Ascent",  v = { scoreColor, STAT.totalF10 },                                                        x = 26,  y = 58, d = 80 },
        { k = "Giga",    v = { scoreColor, STAT.totalGiga },                                                       x = 26,  y = 83, d = 80 },
        { k = "Flip",    v = { scoreColor, STAT.totalFlip },                                                       x = 194, y = 08, d = 82 },
        { k = "Quest",   v = { scoreColor, STAT.totalQuest },                                                      x = 194, y = 33, d = 82 },
        { k = "Perfect", v = { scoreColor, STAT.totalPerfect },                                                    x = 194, y = 58, d = 82 },
        { k = "Attack",  v = { scoreColor, STAT.totalAttack },                                                     x = 194, y = 83, d = 82 },
        { k = "Time",    v = { scoreColor, ("%dh%dm"):format(STAT.totalTime / 3600, STAT.totalTime % 3600 / 60) }, x = 380, y = 08, d = 80 },
        { k = "Floor",   v = { scoreColor, STAT.totalFloor },                                                      x = 380, y = 33, d = 80 },
        { k = "Height",  v = { scoreColor, floor(STAT.totalHeight * .001), textColor, " km" },                     x = 380, y = 58, d = 80 },
        { k = "Bonus",   v = { scoreColor, floor(STAT.totalBonus * .001), textColor, " km" },                      x = 380, y = 83, d = 80 },
    } do
        GC.setColor(textColor)
        GC.print(l.k, l.x, l.y, 0, .75)
        GC.setColor(1, 1, 1)
        GC.print(l.v, l.x + l.d, l.y, 0, .75)
    end
    GC.ucs_back()

    GC.setCanvas()
end

function scene.load()
    SetMouseVisible(true)
    TASK.lock('no_back')
    maskAlpha, cardShow = 0, 0
    TWEEN.new(function(t)
        maskAlpha = t
    end):setTag('stat_in'):setDuration(.26):run():setOnFinish(function()
        TWEEN.new(function(t)
            cardShow = t
        end):setTag('stat_in'):setDuration(.1):run():setOnFinish(function()
            TASK.unlock('no_back')
        end)
    end)

    RefreshProfile()
end

function scene.keyDown(key, isRep)
    if isRep then return true end
    if (key == 'escape' or key == '`') and TASK.lock('no_back') then
        SFX.play('menuclick')
        TWEEN.tag_kill('stat_in')
        TWEEN.new(function(t)
            cardShow = 1 - t
        end):setDuration(.26):run():setOnFinish(function()
            TWEEN.new(function(t)
                maskAlpha = 1 - t
            end):setDuration(.26):run():setOnFinish(function()
                SCN.back('none')
                TASK.unlock('no_back')
            end)
        end)
    end
    ZENITHA.setCursorVis(true)
    return true
end

function scene.update(dt)
    SCN.scenes.tower.update(dt)
    for _, W in next, SCN.scenes.tower.widgetList do
        W:update(dt)
    end
end

function scene.draw()
    SCN.scenes.tower.draw()
    GC.replaceTransform(SCR.xOy)
    WIDGET.draw(SCN.scenes.tower.widgetList)
    SCN.scenes.tower.overDraw()
    GC.origin()
    GC.setColor(0, 0, 0, maskAlpha * .7023)
    GC.rectangle('fill', 0, 0, SCR.w, SCR.h)

    if cardShow > 0 then
        GC.replaceTransform(SCR.xOy_m)
        GC.setColor(1, 1, 1, cardShow)
        local k = .9 + cardShow * .1
        GC.mDraw(card, 0, 0, 0, k * .67, k ^ 26 * .67)
    end
end

scene.widgetList = {
    WIDGET.new {
        name = 'link', type = 'hint',
        pos = { .5, .5 }, x = 0, y = 210, w = 800, h = 60,
        color = COLOR.X,
        labelPos = 'top',
        floatFontSize = 20,
        floatText = "Open github repo with browser",
        onPress = function()
            SFX.play('menuconfirm')
            love.system.openURL("https://github.com/MrZ626/ZenithClicker")
        end,
    },
    WIDGET.new {
        name = 'back', type = 'button',
        pos = { 0, 0 }, x = 60, y = 140, w = 160, h = 60,
        color = { .15, .15, .15 },
        sound_hover = 'menutap',
        fontSize = 30, text = "    BACK", textColor = 'DL',
        onClick = function() love.keypressed('escape') end,
    },
    WIDGET.new {
        name = 'close', type = 'button_invis',
        pos = { .5, .5 }, x = 344, y = -196, w = 100, h = 50,
        onClick = function() love.keypressed('escape') end,
    },
    WIDGET.new {
        name = 'protect', type = 'button_invis',
        pos = { .5, .5 }, w = 820, h = 500,
    },
    WIDGET.new {
        type = 'button_invis',
        pos = { .5, .5 }, w = 3500, h = 2600,
        onClick = function() love.keypressed('escape') end,
    }
}

return scene
