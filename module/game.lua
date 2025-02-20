---@class Question
---@field combo string[]
---@field name string

---@class Game
---@field dmgHeal number
---@field dmgWrong number
---@field dmgTime number
---@field dmgDelay number
---@field dmgCycle number
---@field queueLen number
---
---@field questTime number
---@field questCount number
---@field rankupLast boolean
---@field xpLockLevel number
---@field xpLockTimer number
---@field fatigue number
---@field dmgTimer number
---@field chain number
local GAME = {
    modText = GC.newText(FONT.get(30)),
    forfeitTimer = 0,
    exTimer = 0,
    textHide = 0,
    bgFloor = 1,
    bgAlpha = 1,

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
    quests = {}, --- @type Question[]

    life = 0,
    lifeShow = 0,
    time = 0,
    floor = 1,
    rank = 1,
    xp = 0,
    altitude = 0,
}

--- Unsorted
function GAME.getHand()
    local list = {}
    for _, C in ipairs(Cards) do
        if C.active then
            table.insert(list, C.id)
        end
    end
    return list
end

local modName = {
    prio = { ['IN'] = 0, ['MS'] = 1, ['VL'] = 2, ['NH'] = 3, ['DH'] = 4, ['AS'] = 5, ['GV'] = 6, ['EX'] = 7, ['2P'] = 8 },
    adj = {
        ['IN'] = "INVISIBLE",
        ['MS'] = "MESSY",
        ['VL'] = "VOLATILE",
        ['NH'] = "HOLDLESS",
        ['DH'] = "DOUBLE HOLE",
        ['AS'] = "ALL-SPIN",
        ['GV'] = "GRAVITY",
        ['EX'] = "EXPERT",
        ['2P'] = "DUO",
    },
    noun = {
        ['IN'] = "INVISIBLITY",
        ['MS'] = "MESSINESS",
        ['VL'] = "VOLATILITY",
        ['NH'] = "NO HOLD",
        ['DH'] = "DOUBLE HOLE",
        ['AS'] = "ALL-SPIN",
        ['GV'] = "GRAVITY",
        ['EX'] = "EXPERT",
        ['2P'] = "DUO",
    },
}
---@param list? string[]
---@param extend? boolean use extended combo lib from community
function GAME.getComboName(list, extend)
    list = list and TABLE.copy(list) or GAME.getHand()

    if #list == 0 then return "" end
    if #list == 1 then return modName.noun[list[1]] end

    local str = table.concat(TABLE.sort(list), ' ')
    if Combos[str] and (Combos[str].basic or extend) then return Combos[str].name end

    str = ""
    table.sort(list, function(a, b) return modName.prio[a] < modName.prio[b] end)
    for i = 1, #list - 1 do str = str .. modName.adj[list[i]] .. " " end
    return str .. modName.noun[list[#list]]
end

function GAME.refreshComboText()
    GAME.modText:set(GAME.getComboName(nil, GAME.mod_DH == 2))
end

function GAME.refreshLayout()
    local baseDist = (GAME.mod_EX > 0 and 100 or 110) + GAME.mod_VL * 20
    local baseL, baseR = 800 - 4 * baseDist - 70, 800 + 4 * baseDist + 70
    local dodge = GAME.mod_VL == 0 and 260 or 220
    local baseY = 726 + 15 * GAME.mod_GV
    if FloatOnCard then
        local selX = 800 + (FloatOnCard - 5) * baseDist
        for i = 1, #Cards do
            local C = Cards[i]
            if i < FloatOnCard then
                C.tx = MATH.interpolate(1, baseL, FloatOnCard - 1, selX - dodge, i)
                if C.tx ~= C.tx then C.tx = baseL end
            elseif i > FloatOnCard then
                C.tx = MATH.interpolate(#Cards, baseR, FloatOnCard + 1, selX + dodge, i)
                if C.tx ~= C.tx then C.tx = baseR end
            else
                C.tx = selX
            end
            C.ty = baseY - (C.active and 35 or 0) - (i == FloatOnCard and 55 or 0)
        end
    else
        for i, C in ipairs(Cards) do
            C.tx = 800 + (i - 5) * baseDist
            C.ty = baseY - (C.active and 35 or 0) - (i == FloatOnCard and 55 or 0)
        end
    end
    if GAME.mod_MS > 0 then
        for i = 1, 9 do
            Cards[i].ty = Cards[i].ty + MessyBias[i]
        end
    end
end

function GAME.refreshLockState()
    Cards['EX'].lock = DATA.maxFloor < 9
    Cards['NH'].lock = DATA.maxFloor < 2
    Cards['MS'].lock = DATA.maxFloor < 3
    Cards['GV'].lock = true -- DATA.maxFloor < 4
    Cards['VL'].lock = DATA.maxFloor < 5
    Cards['DH'].lock = DATA.maxFloor < 6
    Cards['IN'].lock = DATA.maxFloor < 7
    Cards['AS'].lock = DATA.maxFloor < 8
    Cards['2P'].lock = true -- Not really locked forever! Try to find the way to play it
end

-- for floor = 1, 10 do
--     local stat = { 0, 0, 0, 0, 0 }
--     local sum = 0
--     for _ = 1, 620 do
--         local base = .626 + floor ^ .5 / 5
--         local var = floor / 4.2

--         local r = base + var * math.abs(MATH.randNorm())
--         r = MATH.roll(r % 1) and math.ceil(r) or math.floor(r)
--         r = MATH.clamp(r, 1, 5)
--         stat[r] = stat[r] + 1
--         sum = sum + r
--     end
--     print(("Floor %2d : %s"):format(floor, table.concat(stat, ', ')), "E(x)=" .. sum / MATH.sum(stat))
-- end

function GAME.genQuest()
    local combo = {}
    local base = .626 + GAME.floor ^ .5 / 5
    local var = GAME.floor / 4.2
    if GAME.mod_DH then base = base + .626 end

    local r = base + var * math.abs(MATH.randNorm())
    r = MATH.roll(r % 1) and math.ceil(r) or math.floor(r)

    local pool = TABLE.copyAll(ModWeight)
    local lastQ = GAME.quests[#GAME.quests]
    if lastQ then pool[lastQ.combo[1]] = nil end
    for _ = 1, math.min(r, 5) do
        local mod = MATH.randFreqAll(pool)
        pool[mod] = nil
        table.insert(combo, mod)
    end

    table.insert(GAME.quests, {
        combo = combo,
        name = GAME.getComboName(combo, GAME.mod_DH == 2),
    })
end

function GAME.questReady()
    GAME.questTime = 0
    GAME.fault = false
    for _, C in ipairs(Cards) do
        C.touchCount = 0
        C.hintMark = false
    end
    local Q = GAME.quests[1].combo
    for i = 1, #Q do Cards[Q[i]].hintMark = true end
end

function GAME.anim_setMenuHide(t)
    GAME.textHide = t
    MSG.setSafeY(75 * (1 - GAME.textHide))
end

function GAME.anim_setMenuHide_rev(t)
    GAME.anim_setMenuHide(1 - t)
end

local function task_startSpin()
    for i = 1, #Cards do
        local C = Cards[i]
        if C.lock then
            C.lock = false
            C:flick()
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
    GAME.questReady()
end
function GAME.start()
    SCN.scenes.main.widgetList.hint:setVisible(false)
    MSG.clear()
    MSG('dark', "The game is still working in progress.\nScore will NOT be saved!!!", 4.2)

    BGM.set(BgmSets.extra, 'volume', 1)
    BGM.set('expert', 'volume', MATH.sign(GAME.mod_EX))

    SFX.play('menuconfirm', .8)
    SFX.play(Cards['2P'].active and 'zenith_start_duo' or 'zenith_start', 1, 0, GAME.mod_GV)

    GAME.playing = true
    GAME.dmgHeal = 2
    GAME.dmgWrong = 1
    GAME.dmgTime = 1
    GAME.dmgDelay = 15
    GAME.dmgCycle = 5
    GAME.queueLen = GAME.mod_NH == 2 and 1 or 3

    GAME.time = 0
    GAME.questTime = 0
    GAME.questCount = 0
    GAME.rank = 1
    GAME.xp = 0
    GAME.rankupLast = false
    GAME.xpLockLevel = 5
    GAME.xpLockTimer = 0
    GAME.floor = 1
    GAME.fatigue = 1
    GAME.altitude = 0
    GAME.heightBuffer = 0
    GAME.life = 20
    GAME.dmgTimer = GAME.dmgDelay
    GAME.chain = 0

    TABLE.clear(GAME.quests)
    while #GAME.quests < GAME.queueLen do GAME.genQuest() end

    TASK.removeTask_code(task_startSpin)
    TASK.new(task_startSpin)
    GAME.showHint = GAME.mod_IN < 2

    TWEEN.new(GAME.anim_setMenuHide):setDuration(.26):setUnique('textHide'):run()
    DiscordRPC.update {
        details = GAME.mod_EX > 0 and "EXPERT QUICK PICK" or "QUICK PICK",
        state = "In Game",
    }
end

---@param reason 'forfeit' | 'wrongAns' | 'killed'
function GAME.finish(reason)
    SCN.scenes.main.widgetList.hint:setVisible(true)
    MSG.clear()

    BGM.set(BgmSets.extra, 'volume', 0)
    local r1 = math.random(#BgmSets.extra)
    local r2 = math.random(#BgmSets.extra - 1)
    if r2 >= r1 then r2 = r2 + 1 end
    BGM.set(BgmSets.extra[r1], 'volume', 1)
    BGM.set(BgmSets.extra[r2], 'volume', 1)

    SFX.play(
        reason == 'forfeit' and 'detonated' or
        reason == 'wrongAns' and 'topout' or
        reason == 'killed' and 'losestock' or
        'shatter', .8)

    table.sort(Cards, function(a, b) return a.initOrder < b.initOrder end)
    for _, C in ipairs(Cards) do
        if (GAME['mod_' .. C.id] > 0) ~= C.active then
            C:setActive(true)
        end
        C.touchCount = 0
        C.hintMark = false
    end

    GAME.playing = false

    local newPB
    if GAME.floor > DATA.maxFloor then
        DATA.maxFloor = GAME.floor
        newPB = true
    end
    if GAME.altitude > DATA.maxAltitude then
        DATA.maxAltitude = GAME.altitude
        newPB = true
    end
    if GAME.mod_EX > 0 and GAME.altitude > DATA.maxAltitude_ex then
        DATA.maxAltitude_ex = GAME.altitude
        newPB = true
    end
    if newPB then
        TEXT:add {
            text = "PERSOANL BEST",
            x = 800, y = 450, k = 3, fontSize = 60,
            style = 'beat', inPoint = .26, outPoint = .62,
            color = 'lY', duration = 6.2,
        }
        SFX.play('personalbest', 1, 0, -.1 + GAME.mod_GV)
    end

    TASK.removeTask_code(task_startSpin)
    for _, C in ipairs(Cards) do C:clearBuff() end
    GAME.refreshLockState()

    TWEEN.new(GAME.anim_setMenuHide_rev):setDuration(.26):setUnique('textHide'):run()
    DiscordRPC.update {
        details = "QUICK PICK",
        state = "Enjoying Music",
    }
end

function GAME.takeDamage(dmg, killReason)
    GAME.life = math.max(GAME.life - dmg, 0)
    SFX.play(
        dmg <= 1 and 'damage_small' or
        dmg <= 4 and 'damage_medium' or
        'damage_large')
    if GAME.life <= 0 then
        GAME.finish(killReason)
        return true
    elseif GAME.life <= GAME.dmgWrong and GAME.life + dmg > GAME.dmgWrong then
        SFX.play('hyperalert')
    end
end

function GAME.commit()
    if #GAME.quests == 0 then return end

    local Q = GAME.quests[1]

    local hand = GAME.getHand()
    local target = Q.combo
    local result = TABLE.equal(TABLE.sort(hand), TABLE.sort(target))

    if result then
        GAME.life = math.min(GAME.life + math.max(GAME.dmgHeal, 0), 20)

        local attack = TABLE.find(hand, '2P') and 6 or 4
        local xp = 0
        if GAME.fault then
            xp = xp + 2
            if GAME.chain < 4 then
                SFX.play('clearline', .62)
            else
                SFX.play('clearline')
                SFX.play(
                    GAME.chain < 8 and 'b2bcharge_blast_1' or
                    GAME.chain < 12 and 'b2bcharge_blast_2' or
                    GAME.chain < 24 and 'b2bcharge_blast_3' or
                    'b2bcharge_blast_4'
                )
                if GAME.chain >= 8 then
                    SFX.play('thunder' .. math.random(6), MATH.clampInterpolate(8, .7, 16, 1, GAME.chain))
                end
                while GAME.chain > 0 and GAME.life < 20 do
                    GAME.chain = math.max(GAME.chain - 2, 0)
                    GAME.life = math.min(GAME.life + 1, 20)
                end
                if GAME.chain > 0 then
                    attack = attack + GAME.chain
                end
            end
            GAME.chain = 0
        else
            SFX.play(MATH.roll(.626) and 'clearspin' or 'clearquad', .5)
            xp = xp + 3
            GAME.chain = GAME.chain + 1
            if GAME.chain < 4 then
            elseif GAME.chain < 8 then
                if GAME.chain == 4 then SFX.play('b2bcharge_start') end
                SFX.play('b2bcharge_1', .8)
            elseif GAME.chain < 12 then
                SFX.play('b2bcharge_2', .8)
            elseif GAME.chain < 24 then
                SFX.play('b2bcharge_3', .8)
            else
                SFX.play('b2bcharge_4', .8)
            end
        end

        SFX.play(TABLE.find(hand, '2P') and 'zenith_start_duo' or 'zenith_start', .626, 0, 12 + GAME.mod_GV)

        GAME.addHeight(attack)
        GAME.addXP(attack + xp)

        if GAME.mod_MS == 2 then
            local r1 = math.random(#Cards)
            local r2 = math.random(#Cards - 1)
            if r2 >= r1 then r2 = r2 + 1 end
            Cards[r1], Cards[r2] = Cards[r2], Cards[r1]
            GAME.refreshLayout()
        end

        table.remove(GAME.quests, 1)
        GAME.questCount = GAME.questCount + 1
        GAME.genQuest()

        GAME.showHint = false
        GAME.cancelAll(true, true)

        GAME.dmgTimer = math.min(GAME.dmgTimer + math.max(2.6, GAME.dmgDelay / 2), GAME.dmgDelay)

        GAME.questReady()
    else
        GAME.fault = true
        if GAME.takeDamage(math.min(GAME.dmgWrong, 1), 'wrongAns') then return end
        if GAME.mod_EX > 0 then
            GAME.showHint = false
            GAME.cancelAll(true, true)
        else
            for _, C in ipairs(Cards) do C:clearBuff() end
        end
    end
end

function GAME.task_cancelAll(noSpin, instant)
    local spinMode = not noSpin and GAME.mod_AS > 0
    local list = TABLE.copy(Cards, 0)
    local needFlip = {}
    for i = 1, #Cards do
        needFlip[i] = spinMode or Cards[i].active
    end
    for i = 1, #list do
        if needFlip[i] then
            list[i]:setActive(true)
            if not instant then
                TASK.yieldT(.026)
            end
        end
        list[i]:clearBuff()
    end
    GAME.showHint = GAME.mod_IN < 2
end

function GAME.cancelAll(noSpin, instant)
    if GAME.mod_NH == 2 then return end
    TASK.removeTask_code(GAME.task_cancelAll)
    TASK.new(GAME.task_cancelAll, noSpin, instant)
end

function GAME.shuffleCards()
    TABLE.shuffle(Cards)
    GAME.refreshLayout()
end

function GAME.upFloor()
    GAME.floor = GAME.floor + 1
    if GAME.mod_MS == 1 and GAME.floor % 3 == 2 then GAME.shuffleCards() end
    local F = Floors[GAME.floor]
    local e = F.event
    for i = 1, #e, 2 do
        GAME[e[i]] = GAME[e[i]] + e[i + 1]
    end

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
    SFX.play('zenith_levelup_g', 1, 0, GAME.mod_GV)
end

function GAME.addHeight(h)
    GAME.heightBuffer = GAME.heightBuffer + h * GAME.rank / 4
end

function GAME.addXP(xp)
    GAME.xp = GAME.xp + xp
    if GAME.xpLockLevel < 5 and GAME.rankupLast and GAME.xp >= 2 * GAME.rank then
        GAME.xpLockLevel = 5
    end
    if GAME.xp >= 4 * GAME.rank then
        GAME.xp = GAME.xp - 4 * GAME.rank
        GAME.rank = GAME.rank + 1
        GAME.rankupLast = true
        GAME.xpLockTimer = GAME.xpLockLevel
        GAME.xpLockLevel = math.max(GAME.xpLockLevel - 1, 1)

        -- Rank skip
        if GAME.xp >= 4 * GAME.rank then
            GAME.rank = GAME.rank + math.floor(GAME.xp / (4 * GAME.rank))
        end

        SFX.play('speed_up_' .. MATH.clamp(GAME.rank - 1, 1, 4), .4 + GAME.xpLockLevel / 10)
    end
end

function GAME.update(dt)
    if GAME.playing then
        -- if love.keyboard.isDown('x') then
        --     GAME.addHeight(dt * 260)
        -- elseif love.keyboard.isDown('c') then
        --     GAME.addXP(dt * 26)
        -- end

        GAME.time = GAME.time + dt
        GAME.questTime = GAME.questTime + dt
        local curFtgStag = (GAME.mod_EX == 2 and FatigueRevEx or Fatigue)[GAME.fatigue]
        if GAME.time >= curFtgStag.time then
            local e = curFtgStag.event
            for i = 1, #e, 2 do
                GAME[e[i]] = GAME[e[i]] + e[i + 1]
            end
            GAME.fatigue = GAME.fatigue + 1
            SFX.play('warning')
        end

        local releaseHeight = GAME.heightBuffer
        GAME.heightBuffer = math.max(MATH.expApproach(GAME.heightBuffer, 0, dt * 6.3216), GAME.heightBuffer - 600 * dt)
        releaseHeight = releaseHeight - GAME.heightBuffer

        GAME.altitude =
            GAME.altitude + releaseHeight +
            GAME.rank / 4 * dt * MATH.icLerp(1, 6, Floors[GAME.floor].top - GAME.altitude)

        if GAME.altitude >= Floors[GAME.floor].top then
            GAME.upFloor()
        end

        if GAME.xpLockTimer > 0 then
            GAME.xpLockTimer = GAME.xpLockTimer - dt
        else
            GAME.xp = GAME.xp - dt * (GAME.mod_EX > 0 and 5 or 3) * GAME.rank * (GAME.rank + 1) / 60
            if GAME.xp <= 0 then
                GAME.xp = 0
                if GAME.rank > 1 then
                    GAME.rank = GAME.rank - 1
                    GAME.xp = 4 * GAME.rank
                    GAME.rankupLast = false
                    SFX.play('speed_down', .4 + GAME.xpLockLevel / 10)
                end
            end
        end

        GAME.dmgTimer = GAME.dmgTimer - dt
        if GAME.dmgTimer <= 0 then
            GAME.dmgTimer = GAME.dmgCycle
            GAME.takeDamage(GAME.dmgTime, 'killed')
        end
    end
end

return GAME
