---@type Zenitha.Scene
local scene = {}

local max, min = math.max, math.min
local floor, ceil, sin = math.floor, math.ceil, math.sin

local clr = {
    D = { COLOR.HEX '19311E' },
    L = { COLOR.HEX '4DA667' },
    T = { COLOR.HEX '6FAC82' },
}
local colorRev = false

local Achievements = Achievements
local M = GAME.mod

---@class EmptyAchv
---@field title string

---@class AchvItem
---@field id string
---@field name string
---@field desc string
---@field descWidth number
---@field rank number
---@field wreath? number
---@field progress number
---@field score table
---@field type string
---@field hidden boolean

---@type (AchvItem | EmptyAchv)[]
local achvList = {}
local scroll, scroll1 = 0, -620
local maxScroll = 0
local tempText = GC.newText(FONT.get(30))
local timer = 0
local whenItsReady = false
local clearNotice
local overallProgress = {
    rank = { [0] = 0, 0, 0, 0, 0, 0 },
    wreath = { [0] = 0, 0, 0, 0, 0, 0, 0 },
    countStart = 0,
    ptGet = 0,
    ptAll = 0,
    ptText = "0/0 Pts",
}

local function refreshAchvList(canShuffle)
    overallProgress.rank = TABLE.new(0, 5)
    overallProgress.rank[0] = 0
    overallProgress.wreath = TABLE.new(0, 6)
    overallProgress.wreath[0] = 0
    overallProgress.ptGet = 0
    overallProgress.ptAll = 0
    TABLE.clear(achvList)
    for i = 1, #Achievements do
        local A = Achievements[i]
        if not A.id then
            table.insert(achvList, { title = A.title and A.title:upper() })
        else
            local rank, score, progress, wreath
            if A.type == 'issued' then
                rank = ACHV[A.id] and 6 or 0
                progress = 0
                score = ACHV[A.id] and "DONE!" or "---"
            else
                local r = A.rank(ACHV[A.id] or A.noScore or 0)
                rank = floor(r)
                progress = r < 5 and r % 1 or r % 1 / .9999
                score = not ACHV[A.id] and "---" or
                    { COLOR.LL, A.scoreSimp(ACHV[A.id]), COLOR.DL, A.scoreFull and
                    "   " .. A.scoreFull(ACHV[A.id]) or "" }
                if r >= 5 then
                    wreath = floor(MATH.clampInterpolate(0, 0, .9999, 6, r % 1))
                end
                if A.type == 'competitive' then
                    overallProgress.rank[rank] = overallProgress.rank[rank] + 1
                    if wreath then overallProgress.wreath[wreath] = overallProgress.wreath[wreath] + 1 end
                    overallProgress.ptGet = overallProgress.ptGet + floor(rank)
                    overallProgress.ptAll = overallProgress.ptAll + 5
                end
            end
            tempText:set(A.desc)
            local hidden = A.hide() and not ACHV[A.id]
            table.insert(achvList, {
                id = A.id,
                name = hidden and "???" or A.name:upper(),
                desc = hidden and "???" or A.desc,
                descWidth = hidden and 26 or tempText:getWidth(),
                rank = floor(rank),
                wreath = wreath,
                progress = progress,
                score = score,
                type = A.type,
                hidden = A.hide ~= FALSE,
            })
        end
    end
    if canShuffle then
        if M.NH == 2 then
            TABLE.foreach(achvList, function(v) return not v.id end, true)
        end

        if M.DH == 2 then
            for i = 1, #achvList do
                if achvList[i].name then
                    local a = achvList[i]
                    a.name =
                        a.name:sub(1, 1) ..
                        table.concat(TABLE.shuffle(a.name:sub(2, -2):atomize())) ..
                        a.name:sub(-1)
                end
            end
        end

        local s, e
        for i = 1, #achvList do
            if not s then
                if achvList[i].id then
                    s = i
                end
            elseif not e then
                if not achvList[i].id then
                    e = i - 1
                elseif i == #achvList then
                    e = i
                end
            end
            if e then
                local buffer = TABLE.sub(achvList, s, e)
                if M.MS > 0 then TABLE.shuffle(buffer) end
                if M.GV > 0 then table.sort(buffer, function(i1, i2) return (i1.name < i2.name) == (M.GV == 1) end) end
                for j, a2 in next, buffer do achvList[s + j - 1] = a2 end
                s, e = nil, nil
            end
        end
    end

    overallProgress.ptText = overallProgress.ptGet .. "/" .. overallProgress.ptAll .. " Pts"
    if overallProgress.ptGet < overallProgress.ptAll then
        for i = 0, 5 do
            if overallProgress.rank[i] > 0 then
                overallProgress.countStart = i
                break
            end
        end
    else
        for i = 0, 6 do
            if overallProgress.wreath[i] > 0 then
                overallProgress.countStart = i
                break
            end
        end
        if overallProgress.countStart == 6 then
            overallProgress.countStart = false
        end
    end
end

local function submit(id, score, silent)
    if SubmitAchv(id, score, silent) then TASK.yieldT(0.1) end
end
local function issue(id, silent)
    if IssueAchv(id, silent) then TASK.yieldT(0.1) end
end
local function refreshAchivement()
    if not STAT.uid:match('^ANON[-_]') or STAT.aboutme ~= "Click the Zenith!" then issue('identity') end
    if BEST.highScore.DP > 0 then issue('intended_glitch') end
    local MD = ModData
    local sw = {
        'swamp_water_lite',
        'swamp_water',
        'swamp_water_pro',
        'swamp_water_x',
    }
    local maxMMP, maxZP = 0, 0
    for k, v in next, BEST.highScore do
        submit(k, v)
        local revCount = STRING.count(k, 'r')
        local count = (#k - revCount) / 2
        if count == 9 or count >= 7 and not k:find('DP') then
            for i = count, 7, -1 do
                SubmitAchv(sw[i - 6], v)
                if revCount > 0 then SubmitAchv(sw[i - 6] .. '_plus', v) end
            end
        end
        local mp = count + revCount
        if mp >= 8 then for m = mp, 8, -1 do submit(RevSwampName[m]:sub(2, -2):lower(), v) end end
        maxMMP = max(maxMMP, v * mp)
        local l = {}
        for m in k:gmatch('r?%w%w') do l[m] = true end
        maxZP = max(maxZP, v * GAME.getComboZP(l))
    end
    submit('multitasker', maxMMP)
    submit('effective', maxZP)
    submit('zenith_explorer', BEST.highScore[''] or 0)
    submit('zenith_speedrun', BEST.speedrun[''] or 2600)
    submit('zenith_explorer_plus', TABLE.maxAll(BEST.highScore) or 0)
    submit('zenith_speedrun_plus', TABLE.minAll(BEST.speedrun) or 2600)
    if STAT.maxHeight >= 6200 then issue('skys_the_limit') end
    if STAT.minTime <= 76.2 then issue('superluminal') end
    local _t
    if not ACHV.terminal_velocity then
        _t = 0
        for id in next, MD.name do if rawget(BEST.speedrun, id) then _t = _t + 1 end end
        if _t >= 9 then issue('terminal_velocity') end
    end
    if not ACHV.the_completionist then
        _t = 0
        for id in next, MD.name do if rawget(BEST.speedrun, 'r' .. id) then _t = _t + 1 end end
        if _t >= 9 then issue('the_completionist') end
    end
    if not ACHV.mastery then
        _t = 0
        for id in next, MD.name do if BEST.highScore[id] >= 1650 then _t = _t + 1 end end
        if _t >= 9 then issue('mastery') end
    end
    if not ACHV.supremacy then
        _t = 0
        for id in next, MD.name do if BEST.highScore['r' .. id] >= 1650 then _t = _t + 1 end end
        if _t >= 9 then issue('supremacy') end
    end
    _t = 0
    for id in next, MD.name do _t = _t + BEST.speedrun[id] end
    submit('zenith_speedrunner', _t, true)
    _t = 0
    for id in next, MD.name do _t = _t + BEST.highScore[id] end
    submit('zenith_challenger', _t, true)
    _t = 0
    for id in next, MD.name do _t = _t + BEST.highScore['r' .. id] end
    submit('divine_challenger', _t, true)

    if not ACHV.false_god and MATH.sumAll(GAME.completion) >= 18 then issue('false_god', ACHV.supremacy) end

    if not ACHV.the_harbinger then
        local allRevF5 = true
        for id in next, MD.name do
            if BEST.highScore['r' .. id] < Floors[4].top then
                allRevF5 = false
                break
            end
        end
        if allRevF5 then
            issue('the_harbinger')
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

    maxScroll = max(ceil((#achvList - 12) / 2) * 140, 0)
    clearNotice = false
end

function scene.unload()
    if clearNotice then
        TABLE.clear(AchvNotice)
    end
end

function scene.mouseMove(_, _, _, dy)
    if love.mouse.isDown(1, 2) then
        scroll = MATH.clamp(scroll - dy * (1 + M.VL), 0, maxScroll)
    end
end

function scene.touchMove(_, _, _, dy)
    scroll = MATH.clamp(scroll - dy * (1 + M.VL), 0, maxScroll)
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
    scroll = MATH.clamp(scroll - dy * 100 * (1 + M.VL), 0, maxScroll)
end

function scene.update(dt)
    if timer < 2.6 then
        timer = timer + dt
        if timer > 2.6 then
            clearNotice = true
            timer = 0
        end
    end
    for mp = 8, 18 do
        if TASK.lock('revswamp_icon_' .. mp, 1.26 / (mp - 4)) then
            local name = RevSwampName[mp]:sub(2, -2):lower()
            local r = math.random(94, 126)
            TEXTURE.achievement.iconQuad[name][2]:setViewport(
                math.random(.5 * 256, 7.5 * 256) - r, math.random(.5 * 256, 7.5 * 256) - r,
                2 * r, 2 * r, 2048, 2304
            )
        end
    end
    if M.EX == 2 then scroll = min(scroll + .26, maxScroll) end
    scroll1 = MATH.expApproach(scroll1, scroll, dt * 26)
end

local gc = love.graphics
local gc_replaceTransform, gc_translate = gc.replaceTransform, gc.translate
local gc_setColor, gc_rectangle, gc_print, gc_printf = gc.setColor, gc.rectangle, gc.print, gc.printf
local gc_ucs_move, gc_ucs_back = GC.ucs_move, GC.ucs_back
local gc_setAlpha, gc_mRect, gc_mDraw, gc_mDrawQ = GC.setAlpha, GC.mRect, GC.mDraw, GC.mDrawQ
local gc_stc_setComp, gc_stc_arc, gc_stc_stop = GC.stc_setComp, GC.stc_arc, GC.stc_stop
local gc_setBlendMode = GC.setBlendMode
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
        local ea = (colorRev and -.5 or .5) * M.AS ^ 2 * t
        local ka = colorRev and -3.1416 or 3.1416
        local texture = TEXTURE.achievement
        local notAllRank5 = overallProgress.ptGet < overallProgress.ptAll
        gc_translate(0, -420 - scroll1)
        for i = 1 + 2 * max(floor(scroll1 / 140) - 1, 0), min(2 * (floor(scroll1 / 140) + 8), #achvList) do
            local a = achvList[i]
            if not a.id then
                if a.title then
                    gc_ucs_move('m', i % 2 == 1 and -605 or 5, floor((i - 1) / 2) * 140)
                    gc_setColor(0, 0, 0, .42)
                    gc_rectangle('fill', -25, 42, 1260, -10)
                    gc_setColor(clr.L)
                    gc_rectangle('fill', -25, 42, 1260, 3)
                    if colorRev then
                        gc_print(a.title, 10, 134, 0, 1.8, -1.8)
                    else
                        gc_print(a.title, 10, 62, 0, 1.8)
                    end
                    gc_ucs_back()
                end
            else
                local A = Achievements[a.id]
                if M.DP == 0 then
                    gc_ucs_move('m', i % 2 == 1 and -605 or 5, floor((i - 1) / 2) * 140)
                elseif M.DP == 1 then
                    gc_ucs_move('m', i % 2 == 1 and -600 or 0, floor((i - 1) / 2) * 140)
                else
                    gc_ucs_move('m', i % 2 == 1 and -626 or 26, floor((i - 1) / 2) * 140)
                end
                -- Bottom rectangle
                if M.EX > 0 and a.type == 'competitive' and (notAllRank5 and a.rank < 5 or not notAllRank5 and (a.wreath or 0) < 6) then
                    gc_setColor(.26 + .1 * sin(t * 2.6 + ceil(i / 2) * 1.2), 0, 0, .626)
                else
                    gc_setColor(0, 0, 0, .626)
                end
                gc_rectangle('fill', 0, 0, 600, 130)
                -- Flashing notice
                if AchvNotice[a.id] then
                    gc_setColor(1, 1, 1, .1 + .1 * sin(t * (6.2 + M.VL * 4.2)))
                    gc_rectangle('fill', 0, 0, 600, 130)
                end
                -- Badge base
                gc_setColor(1, 1, 1)
                gc_mDraw(texture.frame[a.rank], 65, 65, 0, .42)
                -- Progress ring
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
                    end
                    gc_mDraw(texture.ring, 65, 65, 0, .42)
                    gc_mDraw(texture.ring, 65, 65, 3.1416, .42)
                    gc_stc_stop()
                end
                -- Glint
                if a.rank >= 1 then
                    gc_setBlendMode('add', 'alphamultiply')
                    gc_setColor(1, 1, 1, .1 + .2 * sin(i * 2.6 + t * 2.1))
                    gc_mDraw(texture.glint_1, 65, 65, 0, .42)
                    gc_setColor(1, 1, 1, .1 + .2 * sin(i * 2.6 + t * 2.3))
                    gc_mDraw(texture.glint_2, 65, 65, 0, .42)
                    gc_setColor(1, 1, 1, .1 + .2 * sin(i * 2.6 + t * 2.6))
                    gc_mDraw(texture.glint_3, 65, 65, 0, .42)
                    gc_setBlendMode('alpha')
                end

                -- Icon
                if a.rank > 0 then
                    local slice = texture.iconQuad[a.id]
                    if slice then
                        gc_setColor(0, 0, 0, .872)
                        gc_mDrawQ(texture.icons[slice[1]], slice[2] or texture.iconQuad._undef, 65, 65, 0, .24)
                    end
                end

                -- Wreath
                if a.wreath and a.wreath > 0 then
                    gc_setColor(1, 1, 1)
                    gc_mDraw(texture.wreath[a.wreath], 65, 65, 0, .42)
                end

                -- Texts
                gc_setColor(AchvData[a.rank].fg2)
                gc_print(a.score, 135, 35, 0)
                gc_setColor(colorRev and COLOR.LR or COLOR.L)
                gc_print(a.name, 135, 7, 0, .7)
                if a.descWidth < 1050 then
                    gc_print(a.desc, 135, 77, 0, min(400 / a.descWidth, .4), .4)
                else
                    gc_printf(a.desc, 135, 73, 1100, 'left', 0, .4)
                end
                gc_setColor(colorRev and COLOR.dR or COLOR.LD)
                gc_print(A.quote, 135, a.descWidth <= 1050 and 98 or 103, 0, .42)
                gc_printf(A.credit, 65, 113, 130 / .37, 'center', 0, .37, .37, 65 / .37)
                local x = 600 - 15
                if A.ex then
                    gc_mDraw(texture.extra, x, 15, 0, .42)
                    x = x - 30
                end
                if a.hidden then
                    gc_mDraw(texture.hidden, x, 15, 0, .2)
                    x = x - 30
                end
                if A.type == 'competitive' then
                    gc_mDraw(texture.competitive, x, 15, 0, .2)
                elseif A.type == 'event' then
                    gc_mDraw(texture.event, x, 15, 0, .2)
                end

                if M.IN > 0 and a.hidden then
                    gc_setColor(clr.D)
                    gc_setAlpha(M.IN * (.3 + .1 * sin(ceil(i / 2) * 1.2 - t * 2.6)))
                    gc_rectangle('fill', 0, 0, 600, 130)
                end

                gc_ucs_back()
            end
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
    if colorRev then
        gc_print("ACHIEVEMENTS", 15, 68, 0, 1, -1)
    else
        gc_print("ACHIEVEMENTS", 15, 0)
    end

    -- Badge (wreath) count
    if STAT.maxFloor >= 10 then
        gc_replaceTransform(SCR.xOy_ur)
        if overallProgress.ptGet < overallProgress.ptAll then
            for i = overallProgress.countStart, 5 do gc_print(overallProgress.rank[i], -1150 + 40 + 140 * i) end
            gc_printf(overallProgress.ptText, -360, 0, 350, 'right')
            gc_setColor(1, 1, 1)
            for i = overallProgress.countStart, 5 do
                gc_mDraw(TEXTURE.achievement.frame[i], -1150 + 140 * i, 35, 0, .26)
            end
        elseif overallProgress.countStart then
            for i = overallProgress.countStart, 6 do gc_print(overallProgress.wreath[i], -1100 + 40 + 160 * i) end
            gc_setColor(1, 1, 1)
            for i = overallProgress.countStart, 6 do
                gc_mDraw(
                    i > 0 and TEXTURE.achievement.wreath[i] or TEXTURE.achievement.frame[5],
                    -1100 + 160 * i, 35, 0, .26
                )
            end
        else
            gc_printf("CONGRATULATIONS!   THANKS FOR PLAYING.", -1610, 0, 1600, 'right')
        end
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
