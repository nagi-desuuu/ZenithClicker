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
local bindBuffer
MusicPlayer = false
local playingBgmTitle = 'kagari cute'
local playingBgmLength = 2202.8
local playingBgmLengthStr = '22:02.8'
local songList = {
    f0 = "Dr Ocelot - Watchful Eye",
    f1 = "Dr Ocelot - Divine Registration",
    f2 = "Dr Ocelot - Zenith Hotel",
    f3 = "Dr Ocelot - Empty Prayers",
    f4 = "Dr Ocelot - Crowd Control",
    f5 = "Dr Ocelot - Phantom Memories",
    f6 = "Dr Ocelot - Echo",
    f7 = "Dr Ocelot - Cryptic Chemistry",
    f8 = "Dr Ocelot - Chrono Flux",
    f9 = "Dr Ocelot - Broken Record",
    f10 = "Dr Ocelot - Divine Confirmation",
    giga = "Dr Ocelot - Schnellfeuer BULLET",
    f1ex = "Dr Ocelot - Infernal Registration",

    f0r = "Dr Ocelot - Awaiting Judgement",
    f1r = "Dr Ocelot - Desecrated Ruins",
    f2r = "Dr Ocelot - The Age of Vanity",
    f3r = "Dr Ocelot - A Rigged Game",
    f4r = "Dr Ocelot - Spectacles of Violence",
    f5r = "Dr Ocelot - The Past Repeats",
    f6r = "Dr Ocelot - Damning Evidence",
    f7r = "Dr Ocelot - Cryptic Heresy",
    f8r = "Dr Ocelot - Futile Ambition",
    f9r = "Dr Ocelot - Mere Sacrifices",
    f10r = "Dr Ocelot - False God",
    gigar = "Dr Ocelot - Kugelhagel OVERDRIVE",

    fomg = "Ronezkj15 - Floor Omega",
}

local function refreshWidgets()
    scene.widgetList.mp_prev5s:setVisible(true)
    scene.widgetList.mp_next5s:setVisible(true)
    scene.widgetList.mp_noLoop:setVisible(true)
    scene.widgetList.changeAboutme:setVisible(false)
    scene.widgetList.changeName:setVisible(false)
    scene.widgetList.export:setVisible(false)
end

function scene.load()
    MSG.clear()
    bindBuffer = nil
    SetMouseVisible(true)
    if GAME.anyRev ~= colorRev then
        colorRev = GAME.anyRev
        for _, C in next, clr do
            C[1], C[3] = C[3], C[1]
        end
    end
    TASK.unlock('changeName')
    TASK.unlock('changeAboutme')
    TASK.unlock('export')
    TASK.unlock('import')
    TASK.unlock('rebind_control')
    refreshWidgets()
end

-- function scene.unload()
--     SaveStat()
-- end

local bindHint = {
    "CARD-1",
    "CARD-2",
    "CARD-3",
    "CARD-4",
    "CARD-5",
    "CARD-6",
    "CARD-7",
    "CARD-8",
    "CARD-9",
    "CARD-1 (2nd)",
    "CARD-2 (2nd)",
    "CARD-3 (2nd)",
    "CARD-4 (2nd)",
    "CARD-5 (2nd)",
    "CARD-6 (2nd)",
    "CARD-7 (2nd)",
    "CARD-8 (2nd)",
    "CARD-9 (2nd)",
    "COMMIT",
    "RESET",
    "LEFTCLK",
    "RIGHTCLK",
}

local function isLegalKey(key)
    if key:find('ctrl') or key:find('alt') or key == 'f1' or key == 'f2' or key == 'tab' or key == '`' then
        SFX.play('finessefault', .626)
        return false
    elseif key:match('^f%d%d?$') then
        return false
    else
        return true
    end
end
function scene.keyDown(key, isRep)
    if isRep then return true end
    if key == 'escape' or (key == 'f1' and not bindBuffer) then
        if bindBuffer then
            bindBuffer = nil
            MSG('dark', "Keybinding cancelled")
            SFX.play('staffwarning')
        else
            SFX.play('menuclick')
            SCN.back('none')
        end
    elseif bindBuffer and isLegalKey(key) then
        if TABLE.find(bindBuffer, key) then
            MSG('dark', "Keybinding should not repeat!", 1)
            SFX.play('finessefault')
        else
            table.insert(bindBuffer, key)
            if #bindBuffer >= 22 then
                STAT.keybind = bindBuffer
                bindBuffer = nil
                SaveStat()
                MSG('dark', "Keybinding updated.")
                SFX.play('social_notify_major')
            else
                SFX.play('irs')
            end
        end
    elseif MusicPlayer then
        if key == 'left' then
            BGM.set('all', 'seek', math.max(BGM.tell() - 5, 0))
        elseif key == 'right' then
            BGM.set('all', 'seek', math.min(BGM.tell() + 5, BGM.getDuration()))
        elseif key == 'space' then
            BgmLooping, BgmNeedSkip = false, false
        end
        return true
    end
    ZENITHA.setCursorVis(true)
    return true
end

-- Panel size
local w, h = 900, 830
local baseX, baseY = (1600 - w) / 2, (1000 - h) / 2

local gc = love.graphics
local gc_replaceTransform = gc.replaceTransform
local gc_setColor, gc_rectangle, gc_print, gc_printf = gc.setColor, gc.rectangle, gc.print, gc.printf
local gc_ucs_move, gc_ucs_back = GC.ucs_move, GC.ucs_back
local gc_setAlpha, gc_mRect, gc_mStr = GC.setAlpha, GC.mRect, GC.mStr

local function drawSliderComponents(y, title, t1, t2, value)
    gc_ucs_move('m', 0, y)
    gc_setColor(0, 0, 0, .26)
    gc_mRect('fill', w / 2, 0, w - 40, 65, 5)
    gc_mRect('fill', w - 90, 0, 123, 48, 3)
    FONT.set(30)
    gc_setColor(clr.T)
    gc_print(title, 40, -20, 0, .85, 1)
    gc_setAlpha(.42)
    gc_print(t1, 326, 5, 0, .5)
    gc_printf(t2, w - 355, 5, 355, 'right', 0, .5)
    gc_setColor(clr.T)
    gc_mStr(value, w - 100, -20)
    gc_setColor(clr.L)
    gc_print("%", w - 60, -20, 0, .85, 1)
    gc_ucs_back()
end

function scene.draw()
    DrawBG(STAT.bgBrightness)

    local t = love.timer.getTime()

    -- Panel
    gc_replaceTransform(SCR.xOy)
    gc.translate(800 - w / 2, 510 - h / 2)
    if MusicPlayer then
        local beat = 60 / BgmData[BgmPlaying].bpm
        local dy = MATH.clamp(6 * math.sin(t / beat * 3.1416), -2.6, 2.6)
        gc.translate(0, dy)
        SCN.curScroll = -dy
    end
    gc_setColor(clr.D)
    gc_rectangle('fill', 0, 0, w, h)
    gc_setColor(0, 0, 0, .26)
    gc_rectangle('fill', 3, 3, w - 6, h - 6)
    gc_setColor(1, 1, 1, .1)
    gc_rectangle('fill', 0, 0, w, 3)
    gc_setColor(1, 1, 1, .04)
    gc_rectangle('fill', 0, 3, 3, h + 3)

    -- Sliders
    drawSliderComponents(310, "EFFECT VOLUME", "QUIET (F3)", "LOUD (F3)", STAT.sfx)
    drawSliderComponents(380, "MUSIC VOLUME", "QUIET (F4)", "LOUD (F4)", STAT.bgm)
    drawSliderComponents(520, "CARD  BRIGHTNESS", "DARK (F5)", "BRIGHT (F6)", STAT.cardBrightness)
    drawSliderComponents(590, "BG  BRIGHTNESS", "DARK (F7)", "BRIGHT (F8)", STAT.bgBrightness)

    -- Keybind
    if bindBuffer then
        FONT.set(30)
        gc_print("Press key for...", 610, 680, 0, .872)
        gc_print(bindHint[#bindBuffer + 1], 610, 710, 0, .872)
    end

    -- Music player info
    if MusicPlayer then
        local sx, len = 260, 570

        FONT.set(30)
        gc_setColor(clr.T)
        gc_print(STRING.time_simp(BGM.tell()), sx, 249, 0, .626)
        gc_print(playingBgmLengthStr, sx + len - 45, 249, 0, .626)

        local data = BgmData[BgmPlaying]
        if BgmLooping then
            if data.loop[1] == 0 then
                gc_print('D.C.', sx + len * data.loop[2] / playingBgmLength, 235, 0, .3)
            else
                gc_print('S', sx + len * data.loop[1] / playingBgmLength, 235, 0, .3)
                gc_print('D.S.', sx + len * data.loop[2] / playingBgmLength, 235, 0, .3)
            end
        end

        gc_setColor(clr.L)
        gc_rectangle('fill', sx, 246, len, 4)
        gc_setColor(clr.LT)
        gc_rectangle('fill', sx, 246, len * BGM.tell() / playingBgmLength, 4)

        if BgmNeedSkip then
            local alpha = .26 + .62 * (-2.6 * t % 1)
            gc_setColor(COLOR.C)
            gc_setAlpha(alpha)
            gc_mRect('fill', sx + len * BgmNeedSkip[1] / playingBgmLength, 248, 2, 9)
            gc_setColor(COLOR.O)
            gc_setAlpha(alpha)
            gc_mRect('fill', sx + len * BgmNeedSkip[2] / playingBgmLength, 248, 2, 9)
        end

        gc_setColor(clr.LT)
        gc_setAlpha(.626 + .26 * math.sin(t))
        gc_mStr(playingBgmTitle, sx + len / 2, 200)
        gc_setAlpha(.26)
        gc_printf(data.meta, sx + len / 2, 256, len, 'center', 0, .42, .42, len / 2)
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
    if GAME.anyRev then
        gc_print("CONFIG", 15, 68, 0, 1, -1)
    else
        gc_print("CONFIG", 15, 0)
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
    gc_print("TWEAK YOUR SETTINGS FOR A BETTER CLICKING EXPERIENCE", 15, -45, 0, .85, 1)
end

scene.widgetList = {
    -- ACCOUNT
    WIDGET.new {
        type = 'text', alignX = 'left',
        text = "ACCOUNT",
        color = clr.T,
        fontSize = 50,
        x = baseX + 30, y = baseY + 50,
    },
    WIDGET.new {
        name = 'mp_prev5s', type = 'button',
        x = baseX + 230, y = baseY + 115, w = 380, h = 50,
        color = clr.L,
        fontSize = 30, textColor = clr.LT, text = "BACK  5S",
        sound_hover = 'menutap',
        onClick = function()
            BGM.set('all', 'seek', math.max(BGM.tell() - 5, 0))
        end,
        visibleFunc = FALSE,
    },
    WIDGET.new {
        name = 'mp_next5s', type = 'button',
        x = baseX + 640, y = baseY + 115, w = 380, h = 50,
        color = clr.L,
        fontSize = 30, textColor = clr.LT, text = "FORWARD  5S",
        sound_hover = 'menutap',
        onClick = function()
            BGM.set('all', 'seek', math.min(BGM.tell() + 5, BGM.getDuration()))
        end,
        visibleFunc = FALSE,
    },
    WIDGET.new {
        name = 'mp_noLoop', type = 'button',
        x = baseX + 230, y = baseY + 185, w = 380, h = 50,
        color = clr.L,
        fontSize = 30, textColor = clr.LT, text = "NO REPEAT MARKS",
        sound_hover = 'menutap',
        onClick = function()
            BgmLooping, BgmNeedSkip = false, false
        end,
        visibleFunc = FALSE,
    },
    WIDGET.new {
        name = 'changeName', type = 'button',
        x = baseX + 230, y = baseY + 115, w = 380, h = 50,
        color = clr.L,
        fontSize = 30, textColor = clr.LT, text = "CHANGE  USERNAME",
        sound_hover = 'menutap',
        sound_release = 'menuclick',
        onClick = function()
            -- MSG.clear()
            local newName = CLIPBOARD.get()
            if #newName == 0 then
                MSG('dark', "No data in clipboard")
                return
            end
            newName = newName:trim()
            if TASK.lock('changeName', 2.6) then
                SFX.play('notify')
                MSG('dark', "Change your name to clipboard text? ('" .. newName .. "')\nPress again to confirm", 2.6)
                return
            end
            TASK.unlock('changeName')
            repeat
                newName = newName:upper()
                if #newName < 3 or #newName > 16 or newName:find('[^A-Z0-9_%-]') then
                    MSG('dark', "New name must be 3-16 characters long and contain the following: A-Z, 0-9, -, _")
                    break
                end
                if newName == STAT.uid then
                    MSG('dark', "New name is the same as the old one.")
                    break
                end
                if newName:match('^ANON[-_]') then
                    MSG('dark', "You can’t enter ANON as your new name.")
                    break
                end
                STAT.uid = newName
                SaveStat()
                SFX.play('supporter')
                MSG('dark', "Your name was changed to " .. STAT.uid)
                if SCN.cur == 'stat' then RefreshProfile() end
                IssueAchv('identity')
                return
            until true
            SFX.play('staffwarning')
        end,
        visibleFunc = TRUE,
    },
    WIDGET.new {
        name = 'changeAboutme', type = 'button',
        x = baseX + 640, y = baseY + 115, w = 380, h = 50,
        color = clr.L,
        fontSize = 30, textColor = clr.LT, text = "CHANGE  ABOUT ME",
        sound_hover = 'menutap',
        sound_release = 'menuclick',
        onClick = function()
            -- MSG.clear()
            local newText = CLIPBOARD.get()
            if #newText == 0 then
                MSG('dark', "No data in clipboard")
                return
            end
            newText = newText:trim()
            if TASK.lock('changeAboutme', 2.6) then
                SFX.play('notify')
                MSG('dark', "Change your about me text to clipboard text?\nPress again to confirm", 2.6)
                return
            end
            TASK.unlock('changeAboutme')
            repeat
                if type(newText) ~= 'string' then
                    MSG('dark', "No data in clipboard")
                    break
                end
                if #newText < 1 or #newText > 260 or newText:find('[^\32-\126]') then
                    MSG('dark', "Text must be 1-260 characters long and contain visible ASCII characters")
                    break
                end
                if newText == STAT.aboutme then
                    MSG('dark', "New text is the same as the old one")
                    break
                end
                STAT.aboutme = newText
                SaveStat()
                SFX.play('supporter')
                MSG('dark', "Your About Me text has been updated.")
                if SCN.cur == 'stat' then RefreshProfile() end
                IssueAchv('identity')
                return
            until true
            SFX.play('staffwarning')
        end,
        visibleFunc = TRUE,
    },
    WIDGET.new {
        name = 'export', type = 'button',
        x = baseX + 230, y = baseY + 185, w = 380, h = 50,
        color = clr.L,
        fontSize = 30, textColor = clr.LT, text = "EXPORT  PROGRESS",
        sound_hover = 'menutap',
        sound_release = 'menuclick',
        onClick = function()
            -- MSG.clear()
            if TASK.lock('export', 2.6) then
                SFX.play('notify')
                MSG('dark', "Export your progress to clipboard?\nPress again to confirm", 2.6)
                return
            end
            TASK.unlock('export')
            CLIPBOARD.set(STRING.packTable(STAT) .. ',' .. STRING.packTable(BEST) .. ',' .. STRING.packTable(ACHV))
            MSG('dark', "Progress exported!")
            SFX.play('social_notify_minor')
        end,
        visibleFunc = TRUE,
    },
    WIDGET.new {
        name = 'import', type = 'button',
        x = baseX + 640, y = baseY + 185, w = 380, h = 50,
        color = clr.L,
        fontSize = 30, textColor = clr.LT, text = "IMPORT  PROGRESS",
        sound_hover = 'menutap',
        sound_release = 'menuclick',
        onClick = function()
            -- MSG.clear()
            local data = CLIPBOARD.get()
            data = data:trim()
            if #data == 0 then
                MSG('dark', "No data in clipboard")
                return
            end
            if data == 'cmd' then
                SFX.play('cutin_superlobby', 1, 0, Tone(-2))
                SCN.go('_console')
                return
            elseif data == 'fps' then
                SFX.play('map_change', .626, 0, Tone(-3.5))
                ZENITHA.setShowFPS(true)
                return
            elseif data == 'tapper' then
                SFX.play('social_invite')
                TEXTS.version:set(SYSTEM .. " T" .. (require 'version'.verStr))
                ForceOldHitbox = true
                return
            elseif data == 'true_ending' then
                SFX.play('warp')
                SCN.go('ending', 'warp')
                return
            elseif songList[data] then
                TASK.removeTask_code(Task_MusicEnd)
                PlayBGM(data, true)
                playingBgmTitle = songList[data]
                playingBgmLength = BGM.getDuration()
                playingBgmLengthStr = STRING.time_simp(playingBgmLength)
                if not MusicPlayer then
                    MusicPlayer = true
                    refreshWidgets()
                end
                return
            end
            if TASK.lock('import', 4.2) then
                SFX.play('notify')
                MSG('dark',
                    "Import data from clipboard text?\nThe version must match; all progress you made so far will be permanently lost!\nPress again to confirm",
                    4.2)
                return
            end
            TASK.unlock('import')
            local d3 = STRING.split(data, ',')
            local suc1, res1 = pcall(STRING.unpackTable, d3[1])
            local suc2, res2 = pcall(STRING.unpackTable, d3[2])
            local suc3, res3
            if d3[3] then
                suc3, res3 = pcall(STRING.unpackTable, d3[3])
            else
                suc3, res3 = true, {}
            end
            if not suc1 or not suc2 or not suc3 then
                MSG('dark', "Invalid data format")
                SFX.play('staffwarning')
                return
            end
            TABLE.update(STAT, res1)
            BEST, ACHV = res2, res3
            setmetatable(BEST.highScore, Metatable.best_highscore)
            setmetatable(BEST.speedrun, Metatable.best_speedrun)
            GAME.refreshLockState()
            if STAT.system ~= SYSTEM then
                STAT.system = SYSTEM
                IssueAchv('zenith_relocation')
            end
            Initialize(true)
            MSG('dark', "Progress imported!")
            SFX.play('social_notify_major')
        end,
    },

    -- AUDIO
    WIDGET.new {
        type = 'text', alignX = 'left',
        text = "AUDIO",
        color = clr.T,
        fontSize = 50,
        x = baseX + 30, y = baseY + 250,
    },
    WIDGET.new {
        type = 'slider',
        x = baseX + 240 + 85, y = baseY + 310, w = 400,
        axis = { 0, 100, 10 },
        frameColor = 'dD', fillColor = clr.D,
        disp = function() return STAT.sfx end,
        code = function(value)
            STAT.sfx = value
            ApplySettings()
        end,
        sound_drag = 'rotate',
    },
    WIDGET.new {
        type = 'slider',
        x = baseX + 240 + 85, y = baseY + 380, w = 400,
        axis = { 0, 100, 10 },
        frameColor = 'dD', fillColor = clr.D,
        disp = function() return STAT.bgm end,
        code = function(value)
            STAT.bgm = value
            ApplySettings()
        end,
        sound_drag = 'rotate',
    },

    -- VIDEO
    WIDGET.new {
        type = 'text', alignX = 'left',
        text = "VIDEO",
        color = clr.T,
        fontSize = 50,
        x = baseX + 30, y = baseY + 460,
    },
    WIDGET.new {
        type = 'slider',
        x = baseX + 240 + 85, y = baseY + 520, w = 400,
        axis = { 80, 100, 5 },
        frameColor = 'dD', fillColor = clr.D,
        disp = function() return STAT.cardBrightness end,
        code = function(value) STAT.cardBrightness = value end,
        sound_drag = 'rotate',
    },
    WIDGET.new {
        type = 'slider',
        x = baseX + 240 + 85, y = baseY + 590, w = 400,
        axis = { 30, 80, 10 },
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
        x = baseX + 55, y = baseY + 670,
        disp = function() return STAT.bg end,
        code = WIDGET.c_pressKey 'f9',
    },
    WIDGET.new {
        type = 'checkBox',
        fillColor = clr.cbFill,
        frameColor = clr.cbFrame,
        textColor = clr.T, text = "STAR FORCE  (F10)",
        x = baseX + 55, y = baseY + 730,
        disp = function() return not STAT.syscursor end,
        code = WIDGET.c_pressKey 'f10',
    },
    WIDGET.new {
        type = 'checkBox',
        fillColor = clr.cbFill,
        frameColor = clr.cbFrame,
        textColor = clr.T, text = "FULLSCREEN  (F11)",
        x = baseX + 55, y = baseY + 790,
        disp = function() return STAT.fullscreen end,
        code = WIDGET.c_pressKey 'f11',
    },

    -- KEYBIND
    WIDGET.new {
        name = 'export', type = 'button',
        x = baseX + 740, y = baseY + 790, w = 260, h = 50,
        color = clr.L,
        fontSize = 30, textColor = clr.LT, text = "REBIND  KEY",
        sound_hover = 'menutap',
        sound_release = 'menuclick',
        onClick = function()
            if bindBuffer then
                bindBuffer = {}
                SFX.play('b2bcharge_danger', .8)
            else
                -- MSG.clear()
                if TASK.lock('rebind_control', 12) then
                    SFX.play('notify')
                    MSG('dark', {
                            "Current Keybinding:\n" ..
                            table.concat(TABLE.sub(STAT.keybind, 1, 9), ', ') .. "\n" ..
                            table.concat(TABLE.sub(STAT.keybind, 10, 18), ', ') .. "\n" ..
                            "Commit: " .. STAT.keybind[19] .. "\n" ..
                            "Reset: " .. STAT.keybind[20] .. "\n" ..
                            "Click L/R: " .. STAT.keybind[21] .. ", " .. STAT.keybind[22] .. "\n",
                            COLOR.F, "PRESS AGAIN TO REBIND\n",
                            COLOR.LD, "(F1-F12 ` Tab Ctrl Alt are not allowed)"
                        },
                        12
                    )
                else
                    TASK.unlock('rebind_control')
                    bindBuffer = {}
                    SFX.play('b2bcharge_danger', .8)
                end
            end
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
