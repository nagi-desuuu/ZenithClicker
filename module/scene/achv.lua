---@type Zenitha.Scene
local scene = {}

local max, min = math.max, math.min
local floor, sin = math.floor, math.sin

local clr = {
    D = { COLOR.HEX '19311E' },
    L = { COLOR.HEX '4DA667' },
    T = { COLOR.HEX '6FAC82' },
    LT = { COLOR.HEX 'CCEBB0' },
}
local colorRev = false

local Achievements = Achievements

---@class AchvItem
---@field id string
---@field name string
---@field desc string
---@field descWidth number
---@field rank number
---@field progress number
---@field score table
---@field hidden boolean

---@type AchvItem[]
local achvList = {}
local scroll, scroll1 = 0, -620
local maxScroll = 0
local tempText = GC.newText(FONT.get(30))
local timer = 0
local whenItsReady = false

local function refreshAchvList(canShuffle)
    TABLE.clear(achvList)
    for i = 1, #Achievements do
        local achv = Achievements[i]
        local rank, score, progress
        if achv.type == 'issued' then
            rank = ACHV[achv.id] and 6 or 0
            progress = 0
            score = ACHV[achv.id] and "DONE!" or "---"
        else
            rank = achv.rank(ACHV[achv.id] or achv.noScore or 0)
            progress = rank == 5 and 1 or rank % 1
            score = not ACHV[achv.id] and "---" or
                { COLOR.LL, achv.scoreSimp(ACHV[achv.id]), COLOR.DL, achv.scoreFull and
                "   " .. achv.scoreFull(ACHV[achv.id]) or "" }
        end
        tempText:set(achv.desc)
        repeat
            if achv.hide() and not ACHV[achv.id] then break end
            table.insert(achvList, {
                id = achv.id,
                name = achv.name:upper(),
                desc = achv.desc,
                descWidth = tempText:getWidth(),
                rank = floor(rank),
                progress = progress,
                score = score,
                hidden = achv.hide ~= FALSE,
            })
        until true
    end

    if GAME.mod.MS == 2 and canShuffle then TABLE.shuffle(achvList) end
end

local function submit(id, score)
    if SubmitAchv(id, score) then TASK.yieldT(0.1) end
end
local function refreshAchivement()
    local MD = ModData
    for k, v in next, BEST.highScore do
        submit(k, v)
        local mp = #k / 2 + STRING.count(k, 'r') / 2
        if mp >= 8 then submit(RevSwampName[mp]:sub(2, -2):lower(), v) end
    end
    submit('zenith_explorer', BEST.highScore[''] or 0)
    submit('zenith_speedrun', BEST.speedrun[''] or 2600)
    submit('zenith_explorer_plus', TABLE.maxAll(BEST.highScore) or 0)
    submit('zenith_speedrun_plus', TABLE.minAll(BEST.speedrun) or 2600)
    if STAT.maxHeight >= 6200 then IssueAchv('skys_the_limit') end
    if STAT.minTime <= 76.2 then IssueAchv('superluminal') end
    submit('effective', STAT.dzp)
    local _t
    if not ACHV.terminal_velocity then
        _t = 0
        for id in next, MD.name do if BEST.speedrun[id] then _t = _t + 1 end end
        if _t >= 9 then IssueAchv('terminal_velocity') end
    end
    if not ACHV.the_completionist then
        _t = 0
        for id in next, MD.name do if BEST.speedrun['r' .. id] then _t = _t + 1 end end
        if _t >= 9 then IssueAchv('the_completionist') end
    end
    if not ACHV.mastery then
        _t = 0
        for id in next, MD.name do if BEST.highScore[id] >= 1650 then _t = _t + 1 end end
        if _t >= 9 then IssueAchv('mastery') end
    end
    if not ACHV.supremacy then
        _t = 0
        for id in next, MD.name do if BEST.highScore['r' .. id] >= 1650 then _t = _t + 1 end end
        if _t >= 9 then IssueAchv('supremacy') end
    end
    if not ACHV.false_god and MATH.sumAll(GAME.completion) >= 18 then IssueAchv('false_god', ACHV.supremacy) end

    if not ACHV.the_harbinger then
        local allRevF5 = true
        for id in next, MD.name do
            if BEST.highScore['r' .. id] < Floors[4].top then
                allRevF5 = false
                break
            end
        end
        if allRevF5 then
            IssueAchv('the_harbinger')
        end
    end

    refreshAchvList()
end

function scene.load()
    SetMouseVisible(true)
    if GAME.anyRev ~= colorRev then
        colorRev = GAME.anyRev
        for _, C in next, clr do
            C[1], C[2] = C[2], C[1]
        end
    end

    if TASK.lock('achv_init') then
        TASK.new(refreshAchivement)
    else
        whenItsReady = MATH.roll(.01)
    end

    refreshAchvList(true)

    maxScroll = max(floor((#achvList - 12) / 2) * 140, 0)
end

function scene.mouseMove(_, _, _, dy)
    if love.mouse.isDown(1, 2) then
        scroll = MATH.clamp(scroll - dy * 1.626, 0, maxScroll)
    end
end

function scene.touchMove(_, _, _, dy)
    scroll = MATH.clamp(scroll - dy * 1.626, 0, maxScroll)
end

function scene.keyDown(key, isRep)
    if isRep then return true end
    if key == 'escape' or key == 'tab' then
        SFX.play('menuclick')
        SCN.back('none')
    end
    ZENITHA.setCursorVis(true)
    return true
end

function scene.wheelMove(_, dy)
    scroll = MATH.clamp(scroll - dy * 260, 0, maxScroll)
end

function scene.update(dt)
    if timer < 2.6 then
        timer = timer + dt
        if timer > 2.6 then
            AchvNotice.__canClear = true
            timer = 0
        end
    end
    scroll1 = MATH.expApproach(scroll1, scroll, dt * 26)
end

local gc = love.graphics
local gc_replaceTransform, gc_translate = gc.replaceTransform, gc.translate
local gc_setColor, gc_rectangle, gc_print, gc_printf = gc.setColor, gc.rectangle, gc.print, gc.printf
local gc_ucs_move, gc_ucs_back = GC.ucs_move, GC.ucs_back
local gc_setAlpha, gc_mRect, gc_mDraw = GC.setAlpha, GC.mRect, GC.mDraw
local gc_stc_setComp, gc_stc_arc, gc_stc_stop = GC.stc_setComp, GC.stc_arc, GC.stc_stop

function scene.draw()
    DrawBG(26)

    FONT.set(30)
    if whenItsReady then
        gc_replaceTransform(SCR.xOy)
        gc_translate(60, 0)
        gc_setColor(clr.D)
        gc_setAlpha(.626)
        gc_rectangle('fill', 400, 360, 680, 220)
        gc_setColor(COLOR.DL)
        gc_print("Zenith Clicker Achievement System When?", 420, 380)
        gc_setColor(COLOR.D)
        gc_rectangle('fill', 420, 435, 626, 50)
        gc_setColor(COLOR.lS)
        gc_rectangle('fill', 430, 435, 75, 50)
        gc_setColor(COLOR.D)
        gc_print("MrZ", 440, 440)
        gc_setColor(COLOR.lD)
        gc_print("at 2025/3/18 (Tue)", 520, 440)
        gc_setColor(COLOR.lS)
        gc_print("When it's ready.", 462, 520)
    else
        -- Board
        gc_replaceTransform(SCR.xOy_m)
        gc_setColor(clr.D)
        gc_mRect('fill', 0, 0, 1260, 1200)

        -- Achievements
        local t = love.timer.getTime()
        local ea = (colorRev and -.5 or .5) * GAME.mod.AS ^ 2 * t
        local ka = colorRev and -3.1416 or 3.1416
        gc_translate(0, -400 - scroll1)
        for i = 1, #achvList do
            local a = achvList[i]
            local A = Achievements[a.id]
            gc_ucs_move('m', i % 2 == 1 and -605 or 5, floor((i - 1) / 2) * 140)
            gc_setColor(AchvNotice[a.id] and .26 + .2 * sin(t * 6.26) or 0, 0, 0, .5)
            gc_setAlpha(.626)
            gc_rectangle('fill', 0, 0, 600, 130)
            gc_setColor(1, 1, 1)
            gc_mDraw(TEXTURE.stat.achievement.frame[a.rank], 65, 65, 0, .42)
            if a.progress > 0 then
                if colorRev then gc_setColor(COLOR.lR) end
                if a.progress < 1 then
                    gc_stc_setComp()
                    gc_stc_arc('pie', 65, 65,
                        ea + -2.0944,
                        ea + -2.0944 + ka * a.progress,
                        63, 26)
                    gc_stc_arc('pie', 65, 65,
                        ea + 1.0472,
                        ea + 1.0472 + ka * a.progress,
                        63, 26)
                    gc_mDraw(TEXTURE.stat.achievement.frame.ring, 65, 65, 0, .42)
                    gc_mDraw(TEXTURE.stat.achievement.frame.ring, 65, 65, 3.1416, .42)
                    gc_stc_stop()
                else
                    gc_mDraw(TEXTURE.stat.achievement.frame.ring, 65, 65, 0, .42)
                    gc_mDraw(TEXTURE.stat.achievement.frame.ring, 65, 65, 3.1416, .42)
                end
            end
            gc_setColor(AchvData[a.rank].fg2)
            gc_print(a.score, 135, 35, 0)
            gc_setColor(colorRev and COLOR.LR or COLOR.L)
            gc_print(a.name, 135, 7, 0, .7)
            if 420 / a.descWidth > .4 then
                gc_print(a.desc, 135, 77, 0, min(400 / a.descWidth, .4), .4)
            else
                gc_printf(a.desc, 135, 73, 1100, 'left', 0, .4)
            end
            gc_setColor(colorRev and COLOR.dR or COLOR.LD)
            gc_print(A.quote, 135, a.descWidth <= 1150 and 98 or 103, 0, .42)
            gc_printf(A.credit, 65, 113, 130 / .37, 'center', 0, .37, .37, 65 / .37)
            local x = 600 - 15
            if a.hidden then
                gc_mDraw(TEXTURE.stat.achievement.hidden, x, 15, 0, .2)
                x = x - 30
            end
            if A.type == 'competitive' then
                gc_mDraw(TEXTURE.stat.achievement.competitive, x, 15, 0, .2)
            elseif A.type == 'event' then
                gc_mDraw(TEXTURE.stat.achievement.event, x, 15, 0, .2)
            end

            gc_ucs_back()
        end
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
    gc_print("ACHIEVEMENTS", 15, 0)

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
    gc_print("VIEW YOUR ACHIEVEMENT PROGRESS!", 15, -45, 0, .85, 1)
end

scene.widgetList = {
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
