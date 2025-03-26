---@type Zenitha.Scene
local scene = {}

local clr = {
    D = { COLOR.HEX '191E31' },
    L = { COLOR.HEX '4D67A6' },
    T = { COLOR.HEX '6F82AC' },
    LT = { COLOR.HEX 'B0CCEB' },
    cbFill = { COLOR.HEX '0B0E17' },
    cbFrame = { COLOR.HEX '6A82A7' },
}
local colorRev = false

function scene.load()
    if GAME.anyRev ~= colorRev then
        colorRev = GAME.anyRev
        for _, C in next, clr do
            C[1], C[3] = C[3], C[1]
        end
    end
end

-- function scene.unload()
--     SaveStat()
-- end

function scene.keyDown(key, isRep)
    if isRep then return true end
    if key == 'escape' or key == 'f1' then
        SFX.play('menuclick')
        SCN.back('none')
    end
    ZENITHA.setCursorVis(true)
    return true
end

-- Panel size
local w, h = 900, 800
local baseX, baseY = (1600 - w) / 2, (1000 - h) / 2

local function drawSliderComponents(y, title, t1, t2, value)
    GC.ucs_move('m', 0, y)
    GC.setColor(0, 0, 0, .26)
    GC.mRect('fill', w / 2, 0, w - 40, 65, 5)
    GC.mRect('fill', w - 90, 0, 123, 48, 3)
    FONT.set(30)
    GC.setColor(clr.T)
    GC.print(title, 40, -20, 0, .85, 1)
    GC.setAlpha(.42)
    GC.print(t1, 326, 5, 0, .5)
    GC.print(t2, w - 230, 5, 0, .5)
    GC.setColor(clr.T)
    GC.mStr(value, w - 100, -20)
    GC.setColor(clr.L)
    GC.print("%", w - 60, -20, 0, .85, 1)
    GC.ucs_back()
end

function scene.draw()
    DrawBG(STAT.bgBrightness)

    -- Panel
    GC.replaceTransform(SCR.xOy)
    GC.ucs_move('m', 800 - w / 2, 500 - h / 2)
    GC.setColor(clr.D)
    GC.rectangle('fill', 0, 0, w, h)
    GC.setColor(0, 0, 0, .26)
    GC.rectangle('fill', 3, 3, w - 6, h - 6)
    GC.setColor(1, 1, 1, .1)
    GC.rectangle('fill', 0, 0, w, 3)
    GC.setColor(1, 1, 1, .04)
    GC.rectangle('fill', 0, 3, 3, h + 3)

    -- Sliders
    drawSliderComponents(500, "CARD  BRIGHTNESS", "DARK", "BRIGHT", STAT.cardBrightness)
    drawSliderComponents(570, "BG  BRIGHTNESS", "DARK", "BRIGHT", STAT.bgBrightness)

    -- Top bar & title
    GC.replaceTransform(SCR.xOy_u)
    GC.setColor(clr.D)
    GC.rectangle('fill', -1300, 0, 2600, 70)
    GC.setColor(clr.L)
    GC.setAlpha(.626)
    GC.rectangle('fill', -1300, 70, 2600, 3)
    GC.replaceTransform(SCR.xOy_ul)
    GC.setColor(clr.L)
    FONT.set(50)
    GC.print("CONFIG", 15, 0)

    -- Bottom bar & text
    GC.replaceTransform(SCR.xOy_d)
    GC.setColor(clr.D)
    GC.rectangle('fill', -1300, 0, 2600, -50)
    GC.setColor(clr.L)
    GC.setAlpha(.626)
    GC.rectangle('fill', -1300, -50, 2600, -3)
    GC.replaceTransform(SCR.xOy_dl)
    GC.setColor(clr.L)
    FONT.set(30)
    GC.print("TWEAK YOUR SETTINGS FOR A BETTER CLICKING EXPERIENCE", 15, -45, 0, .85, 1)
end

scene.widgetList = {
    WIDGET.new {
        type = 'text', alignX = 'left',
        text = "ACCOUNT",
        color = clr.T,
        fontSize = 50,
        x = baseX + 30, y = baseY + 50,
    },
    WIDGET.new {
        name = 'changeName', type = 'button',
        x = baseX + 220, y = baseY + 112, w = 360, h = 50,
        color = clr.L,
        fontSize = 30, textColor = clr.LT, text = "CHANGE USERNAME",
        sound_hover = 'menutap',
        sound_release = 'menuclick',
        onClick = function()
            MSG.clear()
            local newName = CLIPBOARD.get()
            if #newName == 0 then
                MSG('dark', "No data in clipboard")
                return
            end
            newName = newName:trim()
            if TASK.lock('changeName', 2.6) then
                SFX.play('notify')
                MSG('dark', "Change name to clipboard text? ('" .. newName .. "')\nClick again to confirm", 2.6)
                return
            end
            TASK.unlock('changeName')
            repeat
                newName = newName:upper()
                if #newName < 3 or #newName > 16 or newName:find('[^A-Z0-9_%-]') then
                    MSG('dark', "New name can only be 3~16 characters with A-Z, 0-9, -, _")
                    break
                end
                if newName == STAT.uid then
                    MSG('dark', "New name is the same as old one")
                    break
                end
                if newName:sub(1, 4) == 'ANON-' or newName:sub(1, 4) == 'ANON_' then
                    MSG('dark', "New name can't be ANON")
                    break
                end
                STAT.uid = newName
                SaveStat()
                SFX.play('supporter')
                MSG('dark', "Name changed to " .. STAT.uid)
                if SCN.cur == 'stat' then RefreshProfile() end
                return
            until true
            SFX.play('staffwarning')
        end,
    },
    WIDGET.new {
        name = 'changeAboutme', type = 'button',
        x = baseX + 610, y = baseY + 112, w = 360, h = 50,
        color = clr.L,
        fontSize = 30, textColor = clr.LT, text = "CHANGE ABOUT-ME",
        sound_hover = 'menutap',
        sound_release = 'menuclick',
        onClick = function()
            MSG.clear()
            local newText = CLIPBOARD.get()
            if #newText == 0 then
                MSG('dark', "No data in clipboard")
                return
            end
            newText = newText:trim()
            if TASK.lock('changeAboutme', 2.6) then
                SFX.play('notify')
                MSG('dark', "Change about-me text to clipboard text?\nClick again to confirm", 2.6)
                return
            end
            TASK.unlock('changeAboutme')
            repeat
                if type(newText) ~= 'string' then
                    MSG('dark', "No data in clipboard")
                    break
                end
                if #newText < 1 or #newText > 260 or newText:find('[^\32-\126]') then
                    MSG('dark', "New text can only be 1~260 characters with visiable ASCII characters")
                    break
                end
                if newText == STAT.aboutme then
                    MSG('dark', "New text is the same as old one")
                    break
                end
                STAT.aboutme = newText
                SaveStat()
                SFX.play('supporter')
                MSG('dark', "About text updated")
                if SCN.cur == 'stat' then RefreshProfile() end
                return
            until true
            SFX.play('staffwarning')
        end,
    },
    WIDGET.new {
        name = 'export', type = 'button',
        x = baseX + 220, y = baseY + 182, w = 360, h = 50,
        color = clr.L,
        fontSize = 30, textColor = clr.LT, text = "EXPORT PROGRESS",
        sound_hover = 'menutap',
        sound_release = 'menuclick',
        onClick = function()
            MSG.clear()
            if TASK.lock('export', 2.6) then
                SFX.play('notify')
                MSG('dark', "Export progress to clipboard?\nClick again to confirm", 2.6)
                return
            end
            TASK.unlock('export')
            CLIPBOARD.set(STRING.packTable(STAT) .. ',' .. STRING.packTable(BEST))
            MSG('dark', "Progress exported!")
            SFX.play('social_notify_minor')
        end,
    },
    WIDGET.new {
        name = 'import', type = 'button',
        x = baseX + 610, y = baseY + 182, w = 360, h = 50,
        color = clr.L,
        fontSize = 30, textColor = clr.LT, text = "IMPORT PROGRESS",
        sound_hover = 'menutap',
        sound_release = 'menuclick',
        onClick = function()
            MSG.clear()
            local data = CLIPBOARD.get()
            if #data == 0 then
                MSG('dark', "No data in clipboard")
                return
            end
            data = data:trim()
            if TASK.lock('import', 2.6) then
                SFX.play('notify')
                MSG('dark', "Import data from clipboard text?\nClick again to confirm", 2.6)
                return
            end
            TASK.unlock('import')
            local d2 = STRING.split(data, ',')
            local suc1, res1 = pcall(STRING.unpackTable, d2[1])
            local suc2, res2 = pcall(STRING.unpackTable, d2[2])
            if not suc1 or not suc2 then
                MSG('dark', "Invalid data format")
                SFX.play('staffwarning')
                return
            end
            STAT, BEST = res1, res2
            GAME.refreshLockState()
            SaveStat()
            SaveBest()
            MSG('dark', "Progress imported!")
            SFX.play('social_notify_major')
        end,
    },
    WIDGET.new {
        type = 'text', alignX = 'left',
        text = "AUDIO",
        color = clr.T,
        fontSize = 50,
        x = baseX + 30, y = baseY + 245,
    },
    WIDGET.new {
        type = 'checkBox',
        fillColor = clr.cbFill,
        frameColor = clr.cbFrame,
        textColor = clr.T, text = "BGM  (F3)",
        x = baseX + 55, y = baseY + 305,
        disp = function() return STAT.bgm end,
        code = function()
            STAT.bgm = not STAT.bgm
            ApplySettings()
        end,
    },
    WIDGET.new {
        type = 'checkBox',
        fillColor = clr.cbFill,
        frameColor = clr.cbFrame,
        textColor = clr.T, text = "SFX  (F4)",
        x = baseX + 55, y = baseY + 365,
        disp = function() return STAT.sfx end,
        code = function()
            STAT.sfx = not STAT.sfx
            ApplySettings()
        end,
    },
    WIDGET.new {
        type = 'text', alignX = 'left',
        text = "VIDEO",
        color = clr.T,
        fontSize = 50,
        x = baseX + 30, y = baseY + 430,
    },
    WIDGET.new {
        type = 'slider',
        x = baseX + 240 + 85, y = baseY + 500, w = 400,
        axis = { 80, 100, 5 },
        frameColor = 'dD', fillColor = clr.D,
        disp = function() return STAT.cardBrightness end,
        code = function(value) STAT.cardBrightness = value end,
        sound_drag = 'rotate',
    },
    WIDGET.new {
        type = 'slider',
        x = baseX + 240 + 85, y = baseY + 570, w = 400,
        axis = { 30, 100, 10 },
        frameColor = 'dD', fillColor = clr.D,
        disp = function() return STAT.bgBrightness end,
        code = function(value) STAT.bgBrightness = value end,
        sound_drag = 'rotate',
    },
    WIDGET.new {
        type = 'checkBox',
        fillColor = clr.cbFill,
        frameColor = clr.cbFrame,
        textColor = clr.T, text = "FANCY BACKGROUND  (F9)",
        x = baseX + 55, y = baseY + 630,
        disp = function() return STAT.bg end,
        code = function() STAT.bg = not STAT.bg end,
    },
    WIDGET.new {
        type = 'checkBox',
        fillColor = clr.cbFill,
        frameColor = clr.cbFrame,
        textColor = clr.T, text = "STAR FORCE  (F10)",
        x = baseX + 55, y = baseY + 690,
        disp = function() return not STAT.syscursor end,
        code = function()
            STAT.syscursor = not STAT.syscursor
            ApplySettings()
        end,
    },
    WIDGET.new {
        type = 'checkBox',
        fillColor = clr.cbFill,
        frameColor = clr.cbFrame,
        textColor = clr.T, text = "FULLSCREEN  (F11)",
        x = baseX + 55, y = baseY + 750,
        disp = function() return STAT.fullscreen end,
        code = function()
            STAT.fullscreen = not STAT.fullscreen
            love.window.setFullscreen(STAT.fullscreen)
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
}

return scene
