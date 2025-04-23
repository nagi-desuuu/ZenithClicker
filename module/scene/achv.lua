---@type Zenitha.Scene
local scene = {}

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
---@field rank number
---@field progress number
---@field score table

---@type AchvItem[]
local achvList = {}
local scroll, scroll1 = 0, -620
local maxScroll = 0

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
            score = ACHV[achv.id] and { COLOR.lM, "NICE!" } or ""
        else
            rank = achv.rank(ACHV[achv.id] or achv.noScore or 0)
            progress = rank % 1
            score = not ACHV[achv.id] and { COLOR.L, "---" } or
                { COLOR.L, achv.scoreSimp(ACHV[achv.id]), COLOR.DL, achv.scoreFull and
                "   " .. achv.scoreFull(ACHV[achv.id]) or "" }
        end
        repeat
            local hide = achv.hide()
            if hide and not rank then break end
            table.insert(achvList, {
                id = achv.id,
                name = achv.name:upper(),
                rank = math.floor(rank),
                progress = progress,
                score = score,
            })
        until true
    end

    maxScroll = math.floor((#achvList - 12) / 2) * 140
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
    scroll1 = MATH.expApproach(scroll1, scroll, dt * 26)
end

function scene.draw()
    DrawBG(26)

    -- Board
    GC.replaceTransform(SCR.xOy_m)
    GC.setColor(clr.D)
    GC.mRect('fill', 0, 0, 1260, 1200)

    -- Achievements
    GC.translate(0, -400 - scroll1)
    for i = 1, #achvList do
        local a = achvList[i]
        local A = Achievements[a.id]
        GC.ucs_move('m', i % 2 == 1 and -605 or 5, math.floor((i - 1) / 2) * 140)
        GC.setColor(0, 0, 0, .5)
        GC.setAlpha(.626)
        GC.rectangle('fill', 0, 0, 600, 130)
        GC.setColor(1, 1, 1)
        GC.mDraw(TEXTURE.stat.achievement.frame[a.rank], 65, 65, 0, .42)
        FONT.set(30)
        GC.setColor(COLOR.L)
        GC.print(a.name, 135, 10, 0, .6)
        GC.print(A.desc, 135, 77, 0, .5)
        GC.setColor(1, 1, 1)
        GC.print(a.score, 135, 35, 0)
        GC.setColor(COLOR.LD)
        GC.print(A.quote, 135, 98, 0, .42)
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
