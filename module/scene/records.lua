---@type Zenitha.Scene
local scene = {}

local max, min = math.max, math.min
local clamp = MATH.clamp

local clr = {
    D = { COLOR.HEX '1B3B22FF' },
    L = { COLOR.HEX '4DA667FF' },
    T = { COLOR.HEX '9ED499FF' },
    T2 = { COLOR.HEX '31583AFF' },
    cbFill = { COLOR.HEX '0B170EFF' },
    cbFrame = { COLOR.HEX '6AA782FF' },
    btn1 = { COLOR.HEX '1F4E2CFF' },
    btn2 = { COLOR.HEX '73E284FF' },
}
local colorRev = false

local M = GAME.mod
local MD = ModData
local CD = Cards

local baseX, baseY = 200, 110
local pw, ph = 1200, 300

local cardPos = { 1, 2, 3, 4, 5, 6, 7, 8, 9 }
local revBGquads = {}
for i = 1, 26 do
    revBGquads[i] = GC.newQuad(MATH.rand(0, 1586 - pw), MATH.rand(0, 606 - 110), pw, 110, 1586, 606)
end

local scroll, scroll1, maxScroll
local cd, timer = 0, 0
local set = {
    sel = TABLE.new(0, #MD.deck),
    match = 'include', ---@type 'include' | 'exclude' | 'exact'
    floor = 1,
    floorComp = '>', ---@type '=' | '<' | '>'
    mode = 'altitude', ---@type 'altitude' | 'speedrun' | 'zp'
    order = 'first', ---@type 'first' | 'last'
}

---@class Record
---@field _list string[]
---@field _height number
---@field _speedrun number
---@field _floor number
---@field _zp number
---
---@field revQuad love.Quad | false
---@field comboText love.Text
---@field modsText love.Text
---@field floorText love.Text
---@field scoreText love.Text
---@field extraText love.Text

---@return Record?
local function newRecord(list)
    local mods = #list == 0 and "No Mod" or table.concat(list, " ")
    table.sort(list)
    local cmbID = table.concat(list)
    local height = BEST.highScore[cmbID]
    if height == 0 then return end
    local time = BEST.speedrun[cmbID]
    local floor = height >= 6200 and 11 or GAME.calculateFloor(height)
    local scoreText, floorText, extraText
    local mp, zp = GAME.getComboMP(list), GAME.getComboZP(list)
    if set.mode == 'altitude' then
        floorText = "F" .. (floor <= 10 and floor or "Ω")
        scoreText = ("%.2f M"):format(height)
        extraText = ("%d ZP"):format(height * zp)
    elseif set.mode == 'speedrun' then
        floorText = "GIGA"
        scoreText = STRING.time(time)
        extraText = ("%.1f m/s"):format(1650 / time)
    elseif set.mode == 'zp' then
        floorText = "F" .. (floor <= 10 and floor or "Ω")
        scoreText = ("%d ZP"):format(height * zp)
        extraText = ("%.2f M"):format(height)
    end
    return {
        _list = list,
        _height = height,
        _speedrun = time,
        _floor = floor,
        _zp = height * zp,

        comboText = GC.newText(FONT.get(50), cmbID == "" and [["QUICK PICK"]] or GAME.getComboName(list, 'button')),
        modsText = GC.newText(FONT.get(30), mods .. (mp > 2 and "  [" .. mp .. "]" or "")),
        floorText = GC.newText(FONT.get(50), floorText),
        scoreText = GC.newText(FONT.get(50), scoreText),
        extraText = GC.newText(FONT.get(30), extraText),
        revQuad = mp > #list and TABLE.getRandom(revBGquads),
    }
end

---@type Record[]
local recList = {}
local recSorter = {
    high = function(a, b) return a._height > b._height end,
    low = function(a, b) return a._height < b._height end,
    fast = function(a, b) return a._speedrun < b._speedrun end,
    slow = function(a, b) return a._speedrun > b._speedrun end,
    high_zp = function(a, b) return a._zp > b._zp end,
    low_zp = function(a, b) return a._zp < b._zp end,
}
local function clear()
    for i = 1, #recList do
        local R = recList[i]
        R.comboText:release()
        R.modsText:release()
        R.floorText:release()
        R.scoreText:release()
        R.extraText:release()
    end
    TABLE.clear(recList)
    collectgarbage()
end
local function refresh()
    clear()
    maxScroll, scroll = 0, 0
    cd = 1
    timer = math.random()
    local simp = set.match == 'exact' or set.mode == 'speedrun'
    for i = 1, 13 do
        scene.widgetList[#scene.widgetList - 1 - i]:setVisible(not simp)
    end
    ph = simp and 180 or 300
end
local function query()
    clear()
    for i = 1, #recList do recList[i].comboText:release() end

    local list = {}
    for i = 1, #MD.deck do
        if set.sel[i] > 0 then
            table.insert(list, (set.sel[i] == 2 and 'r' or '') .. MD.deck[i].id)
        end
    end
    if set.match == 'exact' then
        recList[1] = newRecord(list)
    else
        for id, height in next, BEST.highScore do
            repeat
                if set.mode ~= 'speedrun' then
                    -- floor check
                    if not (set.floorComp == '>' and set.floor == 1 or set.floorComp == '<' and set.floor == 10) then
                        local floor = GAME.calculateFloor(height)
                        if
                            set.floorComp == '>' and floor < set.floor or
                            set.floorComp == '<' and floor > set.floor or
                            set.floorComp == '=' and floor ~= set.floor
                        then
                            break
                        end
                    end
                else
                    -- speedrun check
                    if BEST.speedrun[id] == 1e99 then break end
                end
                -- combo check
                if set.match ~= 'exclude' and #id < #table.concat(list) then break end
                local l2 = {}
                for m in id:gmatch('r?..') do table.insert(l2, m) end
                if set.match == 'include' then
                    if #l2 - #list ~= #TABLE.subtract(TABLE.copy(l2), list) then break end
                elseif set.match == 'exclude' then
                    if #l2 ~= #TABLE.subtract(TABLE.copy(l2), list) then break end
                end

                table.insert(recList, newRecord(l2))
            until true
        end
        table.sort(recList,
            set.mode == 'altitude' and (set.order == 'first' and recSorter.high or recSorter.low) or
            set.mode == 'zp' and (set.order == 'first' and recSorter.high_zp or recSorter.low_zp) or
            (set.order == 'first' and recSorter.fast or recSorter.slow)
        )
    end
    SFX.play(
        #recList == 0 and 'combobreak' or
        #recList == 1 and 'timer2' or
        'timer1',
        1, 0, Tone(0)
    )
    maxScroll = max((#recList - 3.5) * 120, 0)
    scroll = clamp(scroll, 0, maxScroll)
end

function scene.load()
    SetMouseVisible(true)
    if GAME.anyRev ~= colorRev then
        colorRev = GAME.anyRev
        for _, C in next, clr do
            C[1], C[2] = C[2], C[1]
        end
    end
    scroll, scroll1 = 0, 0

    for i = 1, #CD do cardPos[i] = i end
    if M.MS == 1 then
        for _ = 1, math.random(2, 3) do
            local r1 = math.random(2, 8)
            local r2 = clamp(math.random(r1 - 2, r1 + 2), 1, 9)
            cardPos[r1], cardPos[r2] = cardPos[r2], cardPos[r1]
        end
    elseif M.MS == 2 then
        TABLE.shuffle(cardPos)
    end
    for i = 1, #CD do
        local w = scene.widgetList[5 + i]
        w.x = baseX - 60 + 100 * cardPos[i]
        w:resetPos()
    end
    -- for i = 1, 10 do
    --     local w = scene.widgetList[i + 12]
    --     w.x = baseX - 60 + 100 * (M.EX < 2 and i or 11 - i)
    --     w:resetPos()
    -- end
    -- if M.EX > 0 then set.match = 'exact' end
    -- if M.GV > 0 then set.order = M.GV == 1 and 'first' or 'last' end
    -- if BgmPlaying == 'tera' or BgmPlaying == 'terar' then set.mode == 'speedrun' end

    clear()
    cd = 1.626
    maxScroll = 0
end

function scene.unload()
    clear()
end

function scene.mouseMove(_, _, _, dy)
    if love.mouse.isDown(1, 2) then
        scroll = clamp(scroll - dy * (1 + M.VL), 0, maxScroll)
    end
end

function scene.touchMove(_, _, _, dy)
    scroll = clamp(scroll - dy * (1 + M.VL), 0, maxScroll)
end

function scene.mouseClick(x, y, k)
    if k ~= 1 or not MATH.between(x - baseX, 0, pw) then return end
    y = (y - (baseY - scroll1) - ph) / 120
    if y % 1 < 10 / 120 then return end
    y = math.ceil(y)
    if recList[y] then
        MSG('dark', "Mod set applied!", 1)
        SFX.play('ihs')
        PendingComboFromRecord = recList[y]._list
    end
end

function scene.touchClick(x, y) scene.mouseClick(x, y, 1) end

function scene.keyDown(key, isRep)
    if isRep then return true end
    local bindID = TABLE.find(STAT.keybind, key)
    if bindID and bindID <= 18 and M.AS > 0 then
        set.sel[bindID] = (set.sel[bindID] + 1) % 3
    elseif key == STAT.keybind[20] then
        for i = 1, #set.sel do set.sel[i] = 0 end
        set.match = 'include'
        set.floor = 1
        set.floorComp = '>'
        set.mode = 'altitude'
        set.order = 'first'
        SFX.play('allclear')
        refresh()
    elseif key == STAT.keybind[19] then
        cd = min(cd, .01)
    elseif key == 'escape' then
        SFX.play('menuclick')
        SCN.back('none')
    end
    ZENITHA.setCursorVis(true)
    return true
end

function scene.wheelMove(_, dy)
    scroll = clamp(scroll - dy * 100 * (1 + M.VL), 0, maxScroll)
end

function scene.resize()
    scroll, scroll1 = 0, 0
end

function scene.update(dt)
    local y0 = scroll1
    if math.abs(y0 - scroll) > .1 then
        scroll1 = MATH.expApproach(scroll1, scroll, dt * 26)
        for i = 1, #scene.widgetList - 2 do
            local w = scene.widgetList[i]
            w._y = w._y + (y0 - scroll1)
        end
        GAME.bgH = max(GAME.bgH + (y0 - scroll1) / 355, 0)
    end
    GAME.height = GAME.bgH

    if cd > 0 then
        timer = timer + dt
        cd = cd - dt * (set.match == 'exact' and 2.6 or 1.26)
        if cd <= 0 then
            query()
        end
    end
end

local gc = love.graphics
local gc_replaceTransform, gc_translate = gc.replaceTransform, gc.translate
local gc_draw, gc_rectangle, gc_print = gc.draw, gc.rectangle, gc.print
local gc_setColor, gc_setLineWidth = gc.setColor, gc.setLineWidth
local gc_setAlpha = GC.setAlpha
local setFont = FONT.set

local function drawBtn(x, y, w, h, revQuad)
    gc_rectangle('fill', x, y, w, h)
    if revQuad then
        gc_setColor(1, 1, 1)
        gc_draw(TEXTURE.recRevBG, revQuad, 0, 10)
    end
    gc_setColor(1, 1, 1, .2)
    gc_rectangle('fill', x, y, w, 3)
    gc_rectangle('fill', x, y + 3, 3, h - 3)
    gc_setColor(0, 0, 0, .2)
    gc_rectangle('fill', x + w, y + 3, -3, h - 6)
    gc_setColor(0, 0, 0, .4)
    gc_rectangle('fill', x + 3, y + h, w - 3, -3)
end

function scene.draw()
    DrawBG(26)

    -- Panel
    gc_replaceTransform(SCR.xOy)
    gc_translate(baseX, baseY - scroll1)
    gc_setColor(clr.D)
    drawBtn(0, 0, pw, ph)
    setFont(50)
    gc_setColor(clr.T)
    gc_print("ME", 15, 3, 0, .85, 1)

    -- Searching timer
    if cd > 0 then
        gc_setColor(clr.D)
        gc_setLineWidth(62)
        GC.circle('line', pw / 2, ph + 260, 200)
        gc_setColor(clr.L)
        gc_setLineWidth(26)
        local t = -timer * MATH.tau
        GC.arc('line', 'open', pw / 2, ph + 260, 200, t + 3.1416 * 1.5, t + 3.1416 * MATH.interpolate(1, 1.5, 0, -.6, cd ^ 2))
    end

    -- Rev Glow
    gc_setColor(1, 1, 1)
    for i = 1, #CD do
        if set.sel[i] == 2 then
            gc_draw(TEXTURE.recRevLight, -120 + 100 * cardPos[i], 100 - 60)
        end
    end

    -- Records
    if recList[1] then
        local s = -3 + 1 + math.floor(scroll1 / 120)
        local e = clamp(s + 9, 1, #recList)
        s = max(s, 1)
        gc_translate(0, ph + (s - 1) * 120)
        for i = s, e do
            local R = recList[i]
            gc_setColor(clr.D)
            drawBtn(0, 10, pw, 110, R.revQuad)

            gc_setColor(clr.T2)
            gc_draw(R.floorText, pw * .626, -5, 0, 2, 2, R.floorText:getWidth() / 2)
            gc_draw(R.modsText, 15, 72)
            gc_draw(R.extraText, pw - 15, 72, 0, 1, 1, R.extraText:getWidth())

            gc_setColor(clr.T)
            gc_draw(R.comboText, 15, 15, 0, min(888 / R.comboText:getWidth(), 1), 1)
            gc_draw(R.scoreText, pw - 15, 15, 0, 1, 1, R.scoreText:getWidth())

            gc_translate(0, 120)
        end
    end
end

function scene.overDraw()
    gc_replaceTransform(SCR.xOy)
    gc_translate(baseX, baseY - scroll1)

    -- Top bar & title
    gc_replaceTransform(SCR.xOy_u)
    gc_setColor(clr.D)
    gc_rectangle('fill', -1300, 0, 2600, 70)
    gc_setColor(clr.L)
    gc_setAlpha(.626)
    gc_rectangle('fill', -1300, 70, 2600, 3)
    gc_replaceTransform(SCR.xOy_ul)
    gc_setColor(clr.L)
    setFont(50)
    if colorRev then
        gc_print("PERSONAL RECORDS", 15, 68, 0, 1, -1)
    else
        gc_print("PERSONAL RECORDS", 15, 0)
    end

    -- Bottom bar & text
    gc_replaceTransform(SCR.xOy_d)
    gc_setColor(clr.D)
    gc_rectangle('fill', -1300, 0, 2600, -50)
    gc_setColor(clr.L)
    gc_setAlpha(.626)
    gc_rectangle('fill', -1300, -50, 2600, -3)
    gc_replaceTransform(SCR.xOy_dl)
    gc_setColor(clr.L)
    setFont(30)
    gc_print("VIEW ALL OF YOUR PERSONAL BESTS!", 15, -45, 0, .85, 1)
end

scene.widgetList = {}

-- Mode
table.insert(scene.widgetList, WIDGET.new {
    type = 'checkBox', fillColor = clr.cbFill, frameColor = clr.cbFrame,
    textColor = clr.T, text = "ALTITUDE",
    x = baseX - 60 + 100 * 2.2, y = baseY + 40,
    disp = function() return set.mode == 'altitude' end,
    code = function()
        set.mode = 'altitude'
        refresh()
    end,
})
table.insert(scene.widgetList, WIDGET.new {
    type = 'checkBox', fillColor = clr.cbFill, frameColor = clr.cbFrame,
    textColor = clr.T, text = "SPEEDRUN",
    x = baseX - 60 + 100 * 4.3, y = baseY + 40,
    disp = function() return set.mode == 'speedrun' end,
    code = function()
        set.mode = 'speedrun'
        refresh()
    end,
})
table.insert(scene.widgetList, WIDGET.new {
    type = 'checkBox', fillColor = clr.cbFill, frameColor = clr.cbFrame,
    textColor = clr.T, text = "ZP",
    x = baseX - 60 + 100 * 6.6, y = baseY + 40,
    disp = function() return set.mode == 'zp' end,
    code = function()
        set.mode = 'zp'
        refresh()
    end,
})

-- Sort
table.insert(scene.widgetList, WIDGET.new {
    type = 'checkBox', fillColor = clr.cbFill, frameColor = clr.cbFrame,
    textColor = clr.T, text = "BEST FIRST",
    x = baseX - 60 + 100 * 8.3, y = baseY + 40,
    disp = function() return set.order == 'first' end,
    code = function()
        set.order = 'first'
        refresh()
    end,
})
table.insert(scene.widgetList, WIDGET.new {
    type = 'checkBox', fillColor = clr.cbFill, frameColor = clr.cbFrame,
    textColor = clr.T, text = "BEST LAST",
    x = baseX - 60 + 100 * 10.6, y = baseY + 40,
    disp = function() return set.order == 'last' end,
    code = function()
        set.order = 'last'
        refresh()
    end,
})

-- Mods
for i = 1, #CD do
    table.insert(scene.widgetList, WIDGET.new {
        type = 'checkBox',
        fillColor = { COLOR.lerp(MD.color[MD.deck[i].id], COLOR.DD, .8) },
        frameColor = { COLOR.lerp(MD.color[MD.deck[i].id], COLOR.DD, .26) },
        textColor = { COLOR.lerp(MD.textColor[MD.deck[i].id], COLOR.LL, .26) },
        text = MD.deck[i].id,
        x = baseX - 60 + 100 * i, y = baseY + 100,
        disp = function() return set.sel[i] > 0 end,
        code = function(k)
            if GAME.completion[MD.deck[i].id] > 0 then
                if k == 2 or love.keyboard.isDown('lctrl', 'rctrl') then
                    set.sel[i] = set.sel[i] == 0 and 2 or 0
                else
                    set.sel[i] = (set.sel[i] + 1) % 3
                end
            else
                set.sel[i] = set.sel[i] == 0 and 1 or 0
            end
            refresh()
        end,
    })
end
table.insert(scene.widgetList, WIDGET.new {
    type = 'checkBox', fillColor = clr.cbFill, frameColor = clr.cbFrame,
    textColor = clr.T, text = "INCLUDE",
    x = baseX - 60 + 100 * 1, y = baseY + 100 + 45,
    disp = function() return set.match == 'include' end,
    code = function()
        set.match = 'include'
        refresh()
    end
})
table.insert(scene.widgetList, WIDGET.new {
    type = 'checkBox', fillColor = clr.cbFill, frameColor = clr.cbFrame,
    textColor = clr.T, text = "EXCLUDE",
    x = baseX - 60 + 100 * 3, y = baseY + 100 + 45,
    disp = function() return set.match == 'exclude' end,
    code = function()
        set.match = 'exclude'
        refresh()
    end
})
table.insert(scene.widgetList, WIDGET.new {
    type = 'checkBox', fillColor = clr.cbFill, frameColor = clr.cbFrame,
    textColor = clr.T, text = "EXACT",
    x = baseX - 60 + 100 * 5, y = baseY + 100 + 45,
    disp = function() return set.match == 'exact' end,
    code = function()
        set.match = 'exact'
        refresh()
    end
})

-- Floors
for i = 1, 10 do
    table.insert(scene.widgetList, WIDGET.new {
        type = 'checkBox', fillColor = clr.cbFill, frameColor = clr.cbFrame,
        textColor = clr.T, text = "F" .. i,
        x = baseX - 60 + 100 * i, y = baseY + 210,
        disp = function() return set.floor == i end,
        code = function()
            set.floor = i
            refresh()
        end,
    })
end
table.insert(scene.widgetList, WIDGET.new {
    type = 'checkBox', fillColor = clr.cbFill, frameColor = clr.cbFrame,
    textColor = clr.T, text = "ABOVE",
    x = baseX - 60 + 100 * 1, y = baseY + 210 + 45,
    disp = function() return set.floorComp == '>' end,
    code = function()
        set.floorComp = '>'
        refresh()
    end,
})
table.insert(scene.widgetList, WIDGET.new {
    type = 'checkBox', fillColor = clr.cbFill, frameColor = clr.cbFrame,
    textColor = clr.T, text = "BELOW",
    x = baseX - 60 + 100 * 3, y = baseY + 210 + 45,
    disp = function() return set.floorComp == '<' end,
    code = function()
        set.floorComp = '<'
        refresh()
    end,
})
table.insert(scene.widgetList, WIDGET.new {
    type = 'checkBox', fillColor = clr.cbFill, frameColor = clr.cbFrame,
    textColor = clr.T, text = "JUST",
    x = baseX - 60 + 100 * 5, y = baseY + 210 + 45,
    disp = function() return set.floorComp == '=' end,
    code = function()
        set.floorComp = '='
        refresh()
    end,
})

-- Back
table.insert(scene.widgetList, WIDGET.new {
    name = 'back', type = 'button',
    pos = { 0, 0 }, x = 60, y = 140, w = 160, h = 60,
    color = { .15, .15, .15 },
    sound_hover = 'menutap',
    fontSize = 30, text = "    BACK", textColor = 'DL',
    onClick = function() love.keypressed('escape') end,
})
table.insert(scene.widgetList, WIDGET.new {
    name = 'stat', type = 'button',
    pos = { 0, 0 }, x = 60, y = 230, w = 160, h = 60,
    color = clr.btn1,
    sound_hover = 'menutap',
    fontSize = 30, text = "    RESET", textColor = clr.btn2,
    onClick = function() love.keypressed(STAT.keybind[20]) end,
})

return scene
