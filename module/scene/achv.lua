---@type Zenitha.Scene
local scene = {}

local max, min = math.max, math.min
local floor, abs = math.floor, math.abs
local sin, cos = math.sin, math.cos


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

function scene.load()
    SetMouseVisible(true)
    if GAME.anyRev ~= colorRev then
        colorRev = GAME.anyRev
        for _, C in next, clr do
            C[1], C[2] = C[2], C[1]
        end
    end

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

    if GAME.mod.MS == 2 then TABLE.shuffle(achvList) end

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
    elseif key == 'return' then
        local function submit(id, score)
            if SubmitAchv(id, score) then TASK.yieldT(0.1) end
        end
        TASK.new(function()
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
        end)
    end
    ZENITHA.setCursorVis(true)
    return true
end

function scene.wheelMove(_, dy)
    scroll = MATH.clamp(scroll - dy * 260, 0, maxScroll)
end

function scene.update(dt)
    if timer < 6.26 then
        timer = timer + dt
        if timer > 6.26 then
            AchvNotice.__canClear = true
            timer = 0
        end
    end
    scroll1 = MATH.expApproach(scroll1, scroll, dt * 26)
end

function scene.draw()
    DrawBG(26)

    -- Board
    GC.replaceTransform(SCR.xOy_m)
    GC.setColor(clr.D)
    GC.mRect('fill', 0, 0, 1260, 1200)

    local t = love.timer.getTime()
    local ea = (colorRev and .5 or -.5) * GAME.mod.AS ^ 2 * t
    local ka = colorRev and -3.1416 or 3.1416

    -- Achievements
    GC.translate(0, -400 - scroll1)
    for i = 1, #achvList do
        local a = achvList[i]
        local A = Achievements[a.id]
        GC.ucs_move('m', i % 2 == 1 and -605 or 5, floor((i - 1) / 2) * 140)
        GC.setColor(AchvNotice[a.id] and .26 + .2 * sin(t * 6.26) or 0, 0, 0, .5)
        GC.setAlpha(.626)
        GC.rectangle('fill', 0, 0, 600, 130)
        GC.setColor(1, 1, 1)
        GC.mDraw(TEXTURE.stat.achievement.frame[a.rank], 65, 65, 0, .42)
        if a.progress > 0 then
            if colorRev then GC.setColor(COLOR.lR) end
            if a.progress < 1 then
                GC.stc_setComp()
                GC.stc_arc('pie', 65, 65,
                    ea + -2.0944,
                    ea + -2.0944 + ka * a.progress,
                    63, 26)
                GC.stc_arc('pie', 65, 65,
                    ea + 1.0472,
                    ea + 1.0472 + ka * a.progress,
                    63, 26)
                GC.mDraw(TEXTURE.stat.achievement.frame.ring, 65, 65, 0, .42)
                GC.mDraw(TEXTURE.stat.achievement.frame.ring, 65, 65, 3.1416, .42)
                GC.stc_stop()
            else
                GC.mDraw(TEXTURE.stat.achievement.frame.ring, 65, 65, 0, .42)
                GC.mDraw(TEXTURE.stat.achievement.frame.ring, 65, 65, 3.1416, .42)
            end
        end
        FONT.set(30)
        GC.setColor(AchvData[a.rank].fg2)
        GC.print(a.score, 135, 35, 0)
        GC.setColor(colorRev and COLOR.LR or COLOR.L)
        GC.print(a.name, 135, 7, 0, .7)
        if 420 / a.descWidth > .4 then
            GC.print(a.desc, 135, 77, 0, min(400 / a.descWidth, .4), .4)
        else
            GC.printf(a.desc, 135, 73, 1100, 'left', 0, .4)
        end
        GC.setColor(colorRev and COLOR.dR or COLOR.LD)
        GC.print(A.quote, 135, a.descWidth <= 1150 and 98 or 103, 0, .42)
        local x = 600 - 15
        if a.hidden then
            GC.mDraw(TEXTURE.stat.achievement.hidden, x, 15, 0, .2)
            x = x - 30
        end
        if A.type == 'competitive' then
            GC.mDraw(TEXTURE.stat.achievement.competitive, x, 15, 0, .2)
        elseif A.type == 'event' then
            GC.mDraw(TEXTURE.stat.achievement.event, x, 15, 0, .2)
        end

        GC.ucs_back()
    end

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
    GC.print("ACHIEVEMENTS", 15, 0)

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
    GC.print("VIEW YOUR ACHIEVEMENT PROGRESS!", 15, -45, 0, .85, 1)

    -- GC.replaceTransform(SCR.xOy)
    -- GC.translate(60, 0)
    -- GC.setColor(clr.D)
    -- GC.setAlpha(.626)
    -- GC.rectangle('fill', 400, 360, 680, 220)
    -- GC.setColor(COLOR.DL)
    -- FONT.set(30)
    -- GC.print("Zenith Clicker Achievement System When?", 420, 380)
    -- GC.setColor(COLOR.D)
    -- GC.rectangle('fill', 420, 435, 626, 50)
    -- GC.setColor(COLOR.lS)
    -- GC.rectangle('fill', 430, 435, 75, 50)
    -- GC.setColor(COLOR.D)
    -- GC.print("MrZ", 440, 440)
    -- GC.setColor(COLOR.lD)
    -- GC.print("at 2025/3/18 (Tue)", 520, 440)
    -- GC.setColor(COLOR.lS)
    -- GC.print("When it's ready.", 462, 520)
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
