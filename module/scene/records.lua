---@type Zenitha.Scene
local scene = {}

local max, min = math.max, math.min

local clr = {
    D = { COLOR.HEX '19311EFF' },
    L = { COLOR.HEX '4DA667FF' },
    T = { COLOR.HEX '6FAC82FF' },
    T2 = { COLOR.HEX '31583AFF' },
    cbFill = { COLOR.HEX '0B170EFF' },
    cbFrame = { COLOR.HEX '6AA782FF' },
}
local colorRev = false

local M = GAME.mod
local MD = ModData

local baseX, baseY = 200, 110
local pw, ph = 1200, 360

local scroll, scroll1, maxScroll
local cd = false
local set = {
    sel = TABLE.new(0, #MD.deck),
    match = 'include', ---@type 'include' | 'exact'
    floor = 1, ---@type number|false
    floorComp = '>', ---@type '=' | '<' | '>'
    srOnly = false,
    order = 'first', ---@type 'first' | 'last'
}

---@class Record
---@field _height number
---@field _speedrun number
---@field _floor number
---
---@field comboTextObj love.Text
---@field mods string
---@field height string
---@field note string
---@field mp number

---@return Record?
local function newRecord(list)
    local cmbID = table.concat(list)
    local height = BEST.highScore[cmbID]
    if height == 0 then return end
    local time = BEST.speedrun[cmbID]
    local floor = GAME.calculateFloor(height)
    return {
        _height = height,
        _speedrun = time,
        _floor = floor,

        comboTextObj = GC.newText(FONT.get(50), cmbID == "" and [["QUICK PICK"]] or GAME.getComboName(list, 'record')),
        mods = cmbID == "" and "NO MOD" or table.concat(list, " "),
        height = height .. "m",
        note = time <= 2600 and ("F10 in " .. STRING.time(time)) or ("F" .. floor .. ": " .. Floors[floor].name),

        mp = GAME.getComboMP(list),
    }
end

---@type Record[]
local recList = {}
local function query()
    TABLE.clear(recList)
    for i = 1, #recList do recList[i].comboTextObj:release() end

    local list = {}
    for i = 1, #MD.deck do
        if set.sel[i] > 0 then
            table.insert(list, (set.sel[i] == 2 and 'r' or '') .. MD.deck[i].id)
        end
    end
    table.sort(list)
    if set.match == 'exact' then
        recList[1] = newRecord(list)
    else
        for k, v in next, BEST.speedrun do
            -- TODO
        end
    end
    maxScroll = max((#recList - 3.5) * 120, 0)
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
        local w = scene.widgetList[i]
        w.x = baseX - 60 + 100 * pos[i]
        w:resetPos()
    end
    for i = 1, 10 do
        local w = scene.widgetList[i + 11]
        w.x = baseX - 60 + 100 * (M.EX < 2 and i or 11 - i)
        w:resetPos()
    end
    if M.EX > 0 then set.match = 'exact' end
    if M.GV > 0 then set.order = M.GV == 1 and 'first' or 'last' end
    if BgmPlaying == 'tera' or BgmPlaying == 'terar' then set.srOnly = true end

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

function scene.update(dt)
    local y0 = scroll1
    if math.abs(y0 - scroll) > .1 then
        scroll1 = MATH.expApproach(scroll1, scroll, dt * 26)
        for i = 1, #scene.widgetList - 1 do
            local w = scene.widgetList[i]
            w._y = w._y + (y0 - scroll1)
        end
    end
    GAME.bgH = max(GAME.bgH + (y0 - scroll1) / 355, 0)
    GAME.height = GAME.bgH

    if cd then
        cd = cd - dt
        if cd <= 0 then
            cd = false
            query()
        end
    end
end

local gc = love.graphics
local gc_replaceTransform, gc_translate = gc.replaceTransform, gc.translate
local gc_draw, gc_rectangle, gc_print, gc_printf = gc.draw, gc.rectangle, gc.print, gc.printf
local gc_setColor, gc_setAlpha = gc.setColor, GC.setAlpha

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
    FONT.set(50)
    gc_setColor(clr.T)
    gc_print("ME", 15, 3, 0, .85, 1)

    -- Rev Glow
    gc_setColor(1, 1, 1)
    for i = 1, 9 do
        if set.sel[i] == 2 then
            GC.draw(TEXTURE.statRevLight, -120 + 100 * i, 100 - 60)
        end
    end

    -- Records
    gc_translate(0, ph)
    for i = 1, #recList do
        gc_setColor(clr.D)
        drawBtn(0, 10, pw, 110)
        local R = recList[i]
        FONT.set(50)
        gc_setColor(clr.L)
        gc_draw(R.comboTextObj, 15, 15, 0, math.min(760 / R.comboTextObj:getWidth(), 1), 1)
        gc_printf(R.height, 0, 15, pw - 15, 'right')
        FONT.set(30)
        gc_setColor(clr.T2)
        gc_print(R.mods, 15, 72)
        gc_printf(R.note, 0, 70, pw - 20, 'right')

        gc_translate(0, 120)
    end
end

function scene.overDraw()
    -- EXACT mode cover
    if set.match == 'exact' then
        gc_replaceTransform(SCR.xOy)
        gc_translate(baseX, baseY - scroll1)
        gc_setColor(clr.D)
        gc_rectangle('fill', 3, ph - 3, pw - 6, -169)
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
    FONT.set(30)
    gc_print("VIEW ALL OF YOUR PERSONAL RECORDS!", 15, -45, 0, .85, 1)
end

scene.widgetList = {}

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
            set.sel[i] = k % 2 == 1 and (set.sel[i] + 1) % 3 or set.sel[i] ~= 2 and 2 or 0
            cd = .626
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
        cd = .626
    end
})
table.insert(scene.widgetList, WIDGET.new {
    type = 'checkBox', fillColor = clr.cbFill, frameColor = clr.cbFrame,
    textColor = clr.T, text = "EXACT",
    x = baseX - 60 + 100 * 3, y = baseY + 100 + 45,
    disp = function() return set.match == 'exact' end,
    code = function()
        set.match = 'exact'
        cd = .626
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
            cd = .626
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
        cd = .626
    end,
})
table.insert(scene.widgetList, WIDGET.new {
    type = 'checkBox', fillColor = clr.cbFill, frameColor = clr.cbFrame,
    textColor = clr.T, text = "BELOW",
    x = baseX - 60 + 100 * 3, y = baseY + 210 + 45,
    disp = function() return set.floorComp == '<' end,
    code = function()
        set.floorComp = '<'
        cd = .626
    end,
})
table.insert(scene.widgetList, WIDGET.new {
    type = 'checkBox', fillColor = clr.cbFill, frameColor = clr.cbFrame,
    textColor = clr.T, text = "JUST",
    x = baseX - 60 + 100 * 5, y = baseY + 210 + 45,
    disp = function() return set.floorComp == '=' end,
    code = function()
        set.floorComp = '='
        cd = .626
    end,
})

-- Sort
table.insert(scene.widgetList, WIDGET.new {
    type = 'checkBox', fillColor = clr.cbFill, frameColor = clr.cbFrame,
    textColor = clr.T, text = "BEST FIRST",
    x = baseX - 60 + 100 * 1, y = baseY + 320,
    disp = function() return set.order == 'first' end,
    code = function()
        set.order = 'first'
        cd = .626
    end,
})
table.insert(scene.widgetList, WIDGET.new {
    type = 'checkBox', fillColor = clr.cbFill, frameColor = clr.cbFrame,
    textColor = clr.T, text = "BEST LAST",
    x = baseX - 60 + 100 * 3.5, y = baseY + 320,
    disp = function() return set.order == 'last' end,
    code = function()
        set.order = 'last'
        cd = .626
    end,
})

-- Speedrun
table.insert(scene.widgetList, WIDGET.new {
    type = 'checkBox', fillColor = clr.cbFill, frameColor = clr.cbFrame,
    textColor = clr.T, text = "SPEEDRUN",
    x = baseX - 60 + 100 * 7, y = baseY + 320,
    disp = function() return set.srOnly end,
    code = function()
        set.srOnly = not set.srOnly
        cd = .626
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
