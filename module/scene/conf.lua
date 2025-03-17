---@type Zenitha.Scene
local scene = {}

local clr = {
    D = { COLOR.HEX '191E31' },
    L = { COLOR.HEX '4D67A6' },
    T = { COLOR.HEX '6F82AC' },
}

function scene.load()
    TASK.lock('no_back', 0.26)
end

-- function scene.unload()
--     SaveStat()
-- end

function scene.keyDown(key, isRep)
    if isRep then return true end
    if key == 'escape' and not TASK.getLock('no_back') then
        SFX.play('menuclick')
        SCN.back('none')
    end
    ZENITHA.setCursorVis(true)
    return true
end

function scene.draw()
    DrawBG(26)

    GC.replaceTransform(SCR.xOy_u)

    if love.keyboard.isDown('space') then
        GC.setColor(1, 1, 0)
        FONT.set(30)
        for x = -600, 600 - 100, 100 do
            for y = 0, 600 - 100, 100 do
                GC.rectangle('line', x, y, 100, 100)
                GC.print(x .. ',' .. y, x + 2.6, y, 0, .355)
            end
        end
    end

    local w, h = 1200, 700
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

    -- Brightness Slider Components
    GC.setColor(0, 0, 0, .26)
    GC.mRect('fill', 600, 450, 1160, 65, 5)
    GC.mRect('fill', 1110, 450, 123, 48, 3)
    FONT.set(30)
    GC.setColor(clr.T)
    GC.print("BG  BRIGHTNESS", 40, 430)
    GC.setAlpha(.42)
    GC.print("BRIGHT", 970, 455, 0, .5)
    GC.print("DARK", 326, 455, 0, .5)
    GC.setColor(clr.T)
    GC.mStr(STAT.bgBrightness, 1100, 430)
    GC.setColor(clr.L)
    GC.print("%", 1140, 430, 0, .85, 1)

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

    -- Bottom bar & thanks
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
        x = 200 + 30, y = 150 + 50,
    },
    WIDGET.new {
        name = 'changeName', type = 'button',
        x = 200 + 220, y = 150 + 112, w = 360, h = 50,
        color = clr.L,
        fontSize = 30, textColor = 'LS', text = "CHANGE USERNAME",
        sound_hover = 'menutap',
        sound_release = 'menuclick',
        onClick = function()
            MSG.clear()
            local newName = love.system.getClipboardText()
            if type(newName) ~= 'string' or #newName == 0 then
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
        x = 200 + 620, y = 150 + 112, w = 360, h = 50,
        color = clr.L,
        fontSize = 30, textColor = 'LS', text = "CHANGE ABOUT-ME",
        sound_hover = 'menutap',
        sound_release = 'menuclick',
        onClick = function()
            MSG.clear()
            local newText = love.system.getClipboardText()
            if type(newText) ~= 'string' or #newText == 0 then
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
        type = 'text', alignX = 'left',
        text = "AUDIO",
        color = clr.T,
        fontSize = 50,
        x = 200 + 30, y = 150 + 190,
    },
    WIDGET.new {
        type = 'checkBox',
        fillColor = { COLOR.HEX '0B0E17' },
        frameColor = { COLOR.HEX '6A82A7' },
        textColor = clr.T, text = "BGM (F5)",
        x = 200 + 55, y = 150 + 250,
        disp = function() return STAT.bgm end,
        code = function()
            STAT.bgm = not STAT.bgm
            ApplySettings()
        end,
    },
    WIDGET.new {
        type = 'checkBox',
        fillColor = { COLOR.HEX '0B0E17' },
        frameColor = { COLOR.HEX '6A82A7' },
        textColor = clr.T, text = "SFX (F6)",
        x = 200 + 55, y = 150 + 310,
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
        x = 200 + 30, y = 150 + 380,
    },
    WIDGET.new {
        type = 'slider',
        x = 200 + 240 + 85, y = 150 + 450, w = 700,
        axis = { 30, 100, 10 },
        frameColor = 'dD', fillColor = clr.D,
        disp = function() return STAT.bgBrightness end,
        code = function(value) STAT.bgBrightness = value end,
    },
    WIDGET.new {
        type = 'checkBox',
        fillColor = { COLOR.HEX '0B0E17' },
        frameColor = { COLOR.HEX '6A82A7' },
        textColor = clr.T, text = "FANCY BACKGROUND (F9)",
        x = 200 + 55, y = 150 + 520,
        disp = function() return STAT.bg end,
        code = function() STAT.bg = not STAT.bg end,
    },
    WIDGET.new {
        type = 'checkBox',
        fillColor = { COLOR.HEX '0B0E17' },
        frameColor = { COLOR.HEX '6A82A7' },
        textColor = clr.T, text = "STAR FORCE (F10)",
        x = 200 + 55, y = 150 + 580,
        disp = function() return not STAT.syscursor end,
        code = function()
            STAT.syscursor = not STAT.syscursor
            ApplySettings()
        end,
    },
    WIDGET.new {
        type = 'checkBox',
        fillColor = { COLOR.HEX '0B0E17' },
        frameColor = { COLOR.HEX '6A82A7' },
        textColor = clr.T, text = "FULLSCREEN (F11)",
        x = 200 + 55, y = 150 + 640,
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
