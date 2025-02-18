---@class Question
---@field text string
---@field comboStr string

---@class Game
---@field dmgHeal number
---@field dmgWrong number
---@field dmgDelay number
---@field dmgCycle number
---
---@field time number
---@field xp number
---@field rank number
---@field floor number
---@field fatigue number
---@field altitude number
---@field live number
---@field dmgTimer number
---@field b2b number
local GAME = {
    modText = GC.newText(FONT.get(30)),
    bg = { .1, 0, 0 },
    forfeitTimer = 0,
    exTimer = 0,

    mod_EX = 0,
    mod_NH = 0,
    mod_MS = 0,
    mod_GV = 0,
    mod_VL = 0,
    mod_DH = 0,
    mod_IN = 0,
    mod_AS = 0,
    mod_2P = 0,

    playing = false,
    questions = {}, --- @type Question[]
}

function GAME.freshComboText()
    GAME.modText:set(GetComboName(nil, GAME.mod_DH == 2))
end

function GAME.freshLockState()
    Cards[1].lock = DATA.maxFloor < 9
    Cards[2].lock = DATA.maxFloor < 2
    Cards[3].lock = DATA.maxFloor < 3
    Cards[4].lock = DATA.maxFloor < 4
    Cards[5].lock = DATA.maxFloor < 5
    Cards[6].lock = DATA.maxFloor < 6
    Cards[7].lock = DATA.maxFloor < 7
    Cards[8].lock = DATA.maxFloor < 8
    Cards[9].lock = true
end

local function task_startSpin()
    for i = 1, #Cards do
        local C = Cards[i]
        if C.lock then
            C.lock = false
            C:shake()
        else
            C:spin()
        end
        if C.active then
            C:setActive(true)
        end
        TASK.yieldT(.01)
    end
    if GAME.mod_MS > 0 then
        GAME.shuffleCards()
    end
end
function GAME.start()
    SCN.scenes.main.widgetList.hint:setVisible(false)
    MSG.setSafeY(0)
    MSG('io', "The game is still working in progress.\nYou can only press START to forfeit game", 4.2)

    BGM.set(BgmSets.extra, 'volume', 1)

    SFX.play('menuconfirm')
    SFX.play(Cards[9].active and 'zenith_start_duo' or 'zenith_start', nil, nil, GAME.mod_GV)

    GAME.playing = true
    GAME.dmgHeal = 2
    GAME.dmgWrong = 1
    GAME.dmgDelay = 15
    GAME.dmgCycle = 3

    GAME.time = 0
    GAME.xp = 0
    GAME.rank = 1
    GAME.floor = 1
    GAME.fatigue = 1
    GAME.altitude = 0
    GAME.heightBuffer = 0
    GAME.live = 20
    GAME.dmgTimer = 0
    GAME.b2b = 0

    TASK.removeTask_code(task_startSpin)
    TASK.new(task_startSpin)
end

function GAME.finish()
    SCN.scenes.main.widgetList.hint:setVisible(true)
    MSG.setSafeY(62)
    MSG.clear()

    BGM.set(BgmSets.extra, 'volume', 0)
    local l = TABLE.copy(BgmSets.extra)
    BGM.set(TABLE.popRandom(l), 'volume', 1)
    BGM.set(TABLE.popRandom(l), 'volume', 1)

    SFX.play('shatter')

    table.sort(Cards, function(a, b) return a.initOrder < b.initOrder end)
    for _, C in next, Cards do
        if (GAME['mod_' .. C.id] > 0) ~= C.active then
            C:setActive(true)
        end
        C.lock = GAME['mod_' .. C.id] < 0
    end

    GAME.playing = false

    -- if GAME.floor > DATA.maxFloor then DATA.maxFloor = GAME.floor end
    -- if GAME.altitude > DATA.maxAltitude then DATA.maxAltitude = GAME.altitude end

    TASK.removeTask_code(task_startSpin) -- Double hit quickly then you can...
    GAME.remDebuff()
    GAME.freshLockState()
end

function GAME.commit()
    local result
    -- TODO
    GAME.remDebuff()
    if result then
        GAME.live = math.min(GAME.live + math.max(GAME.dmgHeal, 0), 20)
        -- TODO
        if GAME.mod_MS == 2 then
            local r1 = math.random(#Cards)
            local r2 = math.random(#Cards - 1)
            if r2 >= r1 then r2 = r2 + 1 end
            Cards[r1], Cards[r2] = Cards[r2], Cards[r1]
            RefreshLayout()
        end
    else
        GAME.live = math.max(GAME.live - math.min(GAME.dmgWrong, 1), 0)
        -- TODO
        if GAME.live <= 0 then
            GAME.finish()
            return
        end
    end
    if result or GAME.mod_EX > 0 then
        GAME.cancelAll(true)
    end
end

function GAME.task_cancelAll(noSpin)
    local spinMode = not noSpin and GAME.mod_AS > 0
    for i = 1, #Cards do
        local C = Cards[i]
        if spinMode or C.active then
            C:setActive(true)
            TASK.yieldT(.026)
        end
    end
end

function GAME.cancelAll(noSpin)
    if GAME.mod_NH == 2 then return end
    TASK.removeTask_code(GAME.task_cancelAll)
    TASK.new(GAME.task_cancelAll, GAME, noSpin)
end

function GAME.remDebuff()
    if GAME.mod_AS then for _, C in next, Cards do C.burn = false end end
end

function GAME.shuffleCards()
    TABLE.shuffle(Cards)
    RefreshLayout()
end

function GAME.upFloor()
    GAME.floor = GAME.floor + 1
    if GAME.mod_MS == 1 and (GAME.floor % 2 == 1 or GAME.floor == 10) then GAME.shuffleCards() end
    TEXT:add {
        text = "Floor",
        x = 160, y = 290, k = 1.6, fontSize = 30,
        color = 'LY', duration = 2.6,
    }
    TEXT:add {
        text = tostring(GAME.floor),
        x = 240, y = 280, k = 2.6, fontSize = 30,
        color = 'LY', duration = 2.6, align = 'left',
    }
    TEXT:add {
        text = Floors[GAME.floor].name,
        x = 200, y = 350, k = 1.2, fontSize = 30,
        color = 'LY', duration = 2.6,
    }
    SFX.play('zenith_levelup_' .. Floors[GAME.floor].sfx)
end

function GAME.addHeight(h)
    GAME.heightBuffer = GAME.heightBuffer + h * GAME.rank / 4
end

function GAME.addXP(xp)
    GAME.xp = GAME.xp + xp
    if GAME.xp >= 4 * GAME.rank then
        GAME.xp = GAME.xp - 4 * GAME.rank
        GAME.rank = GAME.rank + 1

        -- Rank skip
        if GAME.xp >= 4 * GAME.rank then
            GAME.rank = GAME.rank + math.floor(GAME.xp / (4 * GAME.rank))
        end

        SFX.play('speed_up_' .. MATH.clamp(GAME.rank - 1, 1, 4))
    end
end

function GAME.update(dt)
    if GAME.playing then
        GAME.time = GAME.time + dt
        local curFtgStag = (GAME.mod_EX == 2 and FatigueRevEx or Fatigue)[GAME.fatigue]
        if GAME.time >= curFtgStag.time then
            local e = curFtgStag.event
            for i = 1, #e, 2 do
                GAME[e[i]] = GAME[e[i]] + e[i + 1]
            end
            GAME.fatigue = GAME.fatigue + 1
        end

        local releaseHeight = GAME.heightBuffer
        GAME.heightBuffer = math.max(MATH.expApproach(GAME.heightBuffer, 0, dt * 6.3216), GAME.heightBuffer - 600 * dt)
        releaseHeight = releaseHeight - GAME.heightBuffer

        GAME.altitude =
            GAME.altitude + releaseHeight +
            GAME.rank / 4 * dt * MATH.icLerp(1, 6, Floors[GAME.floor].top - GAME.altitude)

        -- if love.keyboard.isDown('z') then
        --     GAME.altitude = GAME.altitude + dt * 260
        -- end

        if GAME.altitude >= Floors[GAME.floor].top then
            GAME.upFloor()
        end

        GAME.xp = GAME.xp - dt * (GAME.mod_EX and 5 or 3) * GAME.rank * (GAME.rank + 1) / 60
        if GAME.xp <= 0 then
            GAME.xp = 0
            if GAME.rank > 1 then
                GAME.rank = GAME.rank - 1
                SFX.play('speed_down')
            end
        end
    end
end

return GAME
