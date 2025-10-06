---@type Zenitha.Scene
local scene = {}

local max, min = math.max, math.min

local clr = {
    D = { COLOR.HEX '1B3B22FF' },
    L = { COLOR.HEX '4DA667FF' },
    T = { COLOR.HEX '9ED499FF' },
    T2 = { COLOR.HEX '31583AFF' },
    cbFill = { COLOR.HEX '0B170EFF' },
    cbFrame = { COLOR.HEX '6AA782FF' },
}
local colorRev = false

local M = GAME.mod
local MD = ModData

local baseX, baseY = 200, 110
local pw, ph = 1200, 300

local scroll, scroll1, maxScroll
local cd, timer = 0, 0
local set = {
    sel = TABLE.new(0, #MD.deck),
    match = 'include', ---@type 'include' | 'exact'
    floor = 1, ---@type number|false
    floorComp = '>', ---@type '=' | '<' | '>'
    mode = 'altitude', ---@type 'altitude' | 'speedrun'
    order = 'first', ---@type 'first' | 'last'
}

---@class Record
---@field _height number
---@field _speedrun number
---@field _floor number
---
---@field comboTextObj love.Text
---@field modNames string
---@field desc string
---@field mp number

---@return Record?
local function newRecord(list)
    local modNames = #list == 0 and "No Mod" or table.concat(list, " ")
    table.sort(list)
    local cmbID = table.concat(list)
    local height = BEST.highScore[cmbID]
    if height == 0 then return end
    local time = BEST.speedrun[cmbID]
    local floor = GAME.calculateFloor(height)
    local desc
    if set.mode == 'altitude' then
        desc = ("%.2fm"):format(height)
    else
        desc = "F10 in " .. STRING.time(time)
    end
    return {
        _height = height,
        _speedrun = time,
        _floor = floor,

        comboTextObj = GC.newText(FONT.get(50), cmbID == "" and [["QUICK PICK"]] or GAME.getComboName(list, 'button')),
        modNames = modNames,
        desc = desc,
        mp = GAME.getComboMP(list),
    }
end

---@type Record[]
local recList = {}
local recSorter = {
    high = function(a, b) return a._height > b._height end,
    low = function(a, b) return a._height < b._height end,
    fast = function(a, b) return a._speedrun < b._speedrun end,
    slow = function(a, b) return a._speedrun > b._speedrun end,
}
local function query()
    TABLE.clear(recList)
    for i = 1, #recList do recList[i].comboTextObj:release() end

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
                if set.mode == 'altitude' then
                    -- floor check
                    local floor = GAME.calculateFloor(height)
                    if
                        set.floorComp == '>' and floor < set.floor or
                        set.floorComp == '<' and floor > set.floor or
                        set.floorComp == '=' and floor ~= set.floor
                    then
                        break
                    end
                else
                    -- speedrun check
                    if BEST.speedrun[id] == 1e99 then break end
                end

                -- combo check
                if #id < #table.concat(list) then break end
                local l2 = {}
                for m in id:gmatch('r?..') do table.insert(l2, m) end
                if #l2 - #list ~= #TABLE.subtract(TABLE.copy(l2), list) then break end

                table.insert(recList, newRecord(l2))
            until true
        end
        table.sort(recList,
            set.mode == 'altitude' and (set.order == 'first' and recSorter.high or recSorter.low) or
            (set.order == 'first' and recSorter.fast or recSorter.slow)
        )
    end
    maxScroll = max((#recList - 3.5) * 120, 0)
    scroll = MATH.clamp(scroll, 0, maxScroll)
end

local function refresh()
    TABLE.clear(recList)
    maxScroll, scroll = 0, 0
    cd = 1
    timer = math.random()
    local simp = set.match == 'exact' or set.mode == 'speedrun'
    for i = 1, 13 do
        scene.widgetList[#scene.widgetList - i]:setVisible(not simp)
    end
    ph = simp and 180 or 300
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

    local pos = { 1, 2, 3, 4, 5, 6, 7, 8, 9 }
    if M.MS == 1 then
        for _ = 1, math.random(2, 3) do
            local r1 = math.random(2, 8)
            local r2 = MATH.clamp(math.random(r1 - 2, r1 + 2), 1, 9)
            pos[r1], pos[r2] = pos[r2], pos[r1]
        end
    elseif M.MS == 2 then
        TABLE.shuffle(pos)
    end
    for i = 1, 9 do
        local w = scene.widgetList[4 + i]
        w.x = baseX - 60 + 100 * pos[i]
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

    query()
end

function scene.mouseMove(_, _, _, dy)
    if love.mouse.isDown(1, 2) then
        scroll = MATH.clamp(scroll - dy * (1 + M.VL), 0, maxScroll)
    end
end

function scene.keyDown(key, isRep)
    if isRep then return true end
    local bindID = TABLE.find(STAT.keybind, key)
    if bindID and bindID <= 18 and M.AS > 0 then
        set.sel[bindID] = (set.sel[bindID] + 1) % 3
    elseif key == 'escape' then
        SFX.play('menuclick')
        SCN.back('none')
    end
    ZENITHA.setCursorVis(true)
    return true
end

function scene.wheelMove(_, dy)
    scroll = MATH.clamp(scroll - dy * 100 * (1 + M.VL), 0, maxScroll)
end

function scene.resize()
    scroll, scroll1 = 0, 0
end

function scene.update(dt)
    local y0 = scroll1
    if math.abs(y0 - scroll) > .1 then
        scroll1 = MATH.expApproach(scroll1, scroll, dt * 26)
        for i = 1, #scene.widgetList - 1 do
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
local gc_draw, gc_rectangle, gc_print, gc_printf = gc.draw, gc.rectangle, gc.print, gc.printf
local gc_setColor, gc_setLineWidth = gc.setColor, gc.setLineWidth
local gc_setAlpha = GC.setAlpha
local setFont = FONT.set

local function drawBtn(x, y, w, h)
    gc_rectangle('fill', x, y, w, h)
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
    for i = 1, 9 do
        if set.sel[i] == 2 then
            GC.draw(TEXTURE.statRevLight, -120 + 100 * i, 100 - 60)
        end
    end

    -- Records
    if recList[1] then
        local s = -4 + 1 + math.floor(scroll1 / 120)
        local e = MATH.clamp(s + 9, 1, #recList)
        s = math.max(s, 1)
        gc_translate(0, ph + (s - 1) * 120)
        for i = s, e do
            gc_setColor(clr.D)
            drawBtn(0, 10, pw, 110)

            local R = recList[i]
            setFont(50)
            gc_setColor(clr.T)
            gc_draw(R.comboTextObj, 15, 15, 0, math.min(760 / R.comboTextObj:getWidth(), 1), 1)
            gc_printf(R.desc, 0, 15, pw - 15, 'right')

            setFont(30)
            gc_setColor(clr.T2)
            gc_print(R.modNames, 15, 72)

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
    x = baseX - 60 + 100 * 2.6, y = baseY + 40,
    disp = function() return set.mode == 'altitude' end,
    code = function()
        set.mode = 'altitude'
        refresh()
    end,
})
table.insert(scene.widgetList, WIDGET.new {
    type = 'checkBox', fillColor = clr.cbFill, frameColor = clr.cbFrame,
    textColor = clr.T, text = "SPEEDRUN",
    x = baseX - 60 + 100 * 4.8, y = baseY + 40,
    disp = function() return set.mode == 'speedrun' end,
    code = function()
        set.mode = 'speedrun'
        refresh()
    end,
})

-- Sort
table.insert(scene.widgetList, WIDGET.new {
    type = 'checkBox', fillColor = clr.cbFill, frameColor = clr.cbFrame,
    textColor = clr.T, text = "BEST FIRST",
    x = baseX - 60 + 100 * 8.2, y = baseY + 40,
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
for i = 1, 9 do
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
                if k == 2 then
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
    textColor = clr.T, text = "EXACT",
    x = baseX - 60 + 100 * 3, y = baseY + 100 + 45,
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

return scene
