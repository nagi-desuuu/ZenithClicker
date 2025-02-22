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
---@field firstClickDelay false | number
---@field firstClickTimer false | number
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
    revTimer = 0,
    revDeckSkin = false,
    uiHide = 0,

    mod = {
        EX = 0,
        NH = 0,
        MS = 0,
        GV = 0,
        VL = 0,
        DH = 0,
        IN = 0,
        AS = 0,
        DP = 0,
    },
    hardMode = false,
    anyRev = false,

    revUnlocked = {
        EX = false,
        NH = false,
        MS = false,
        GV = false,
        VL = false,
        DH = false,
        IN = false,
        AS = false,
        DP = false,
    },

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
function GAME.getHand(showRev)
    local list = {}
    if showRev then
        for i = 1, 9 do
            local D = DeckData[i]
            local level = GAME.mod[D.id]
            if level > 0 then
                table.insert(list, level == 2 and 'r' .. D.id or D.id)
            end
        end
    else
        for _, C in ipairs(Cards) do
            if C.active then
                table.insert(list, C.id)
            end
        end
    end
    return list
end

local modName = {
    prio = { IN = 0, MS = 1, VL = 2, NH = 3, DH = 4, AS = 5, GV = 6, EX = 7, DP = 8, rIN = 0, rMS = 1, rVL = 2, rNH = 3, rDH = 4, rAS = 5, rGV = 6, rEX = 7, rDP = 8 },
    adj = {
        IN = "INVISIBLE",
        MS = "MESSY",
        VL = "VOLATILE",
        NH = "HOLDLESS",
        DH = "DOUBLE HOLE",
        AS = "ALL-SPIN",
        GV = "GRAVITY",
        EX = "EXPERT",
        DP = "DUO",
        rIN = "BELIEVED",
        rMS = "DECEPTIVE",
        rVL = "DESPERATE",
        rNH = "ASCENDANT",
        rDH = "DAMNED",
        rAS = "OMNI-SPIN",
        rGV = "COLLAPSED",
        rEX = "TYRANNICAL",
        rDP = "PIERCING",
    },
    noun = {
        IN = "INVISIBLITY",
        MS = "MESSINESS",
        VL = "VOLATILITY",
        NH = "NO HOLD",
        DH = "DOUBLE HOLE",
        AS = "ALL-SPIN",
        GV = "GRAVITY",
        EX = "EXPERT",
        DP = "DUO",
        rIN = "BELIEF",
        rMS = "DECEPTION",
        rVL = "DESPERATION",
        rNH = "ASCENSION",
        rDH = "DAMNATION",
        rAS = "OMNI-SPIN",
        rGV = "COLLAPSE",
        rEX = "TYRANNY",
        rDP = "HEARTACHE",
    },
}
---@param list string[] OVERWRITE!!!
---@param extend? boolean use extended combo lib from community
function GAME.getComboName(list, extend)
    if #list == 0 then return "" end
    if #list == 1 then return modName.noun[list[1]] end

    if not GAME.anyRev and not TABLE.find(list, 'DP') then
        if #list == 8 then return [["SWAMP WATER"]] end
        if #list == 7 then return [["SWAMP WATER LITE"]] end
    end

    local str = table.concat(TABLE.sort(list), ' ')
    if Combos[str] and (Combos[str].basic or extend) then return Combos[str].name end

    str = ""
    table.sort(list, function(a, b) return modName.prio[a] < modName.prio[b] end)
    for i = 1, #list - 1 do str = str .. modName.adj[list[i]] .. " " end
    return str .. modName.noun[list[#list]]
end

function GAME.refreshCurrentCombo()
    GAME.modText:set(GAME.getComboName(GAME.getHand(not GAME.playing), GAME.mod.DH == 2))
    GAME.hardMode = GAME.mod.EX > 0 or not not TABLE.findAll(GAME.mod, 2)
end

function GAME.refreshLayout()
    local baseDist = (GAME.mod.EX > 0 and 100 or 110) + GAME.mod.VL * 20
    local baseL, baseR = 800 - 4 * baseDist - 70, 800 + 4 * baseDist + 70
    local dodge = GAME.mod.VL == 0 and 260 or 220
    local baseY = 726 + 15 * GAME.mod.GV
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
end

function GAME.refreshLockState()
    Cards.EX.lock = DATA.maxFloor < 9
    Cards.NH.lock = DATA.maxFloor < 2
    Cards.MS.lock = DATA.maxFloor < 3
    Cards.GV.lock = DATA.maxFloor < 4
    Cards.VL.lock = DATA.maxFloor < 5
    Cards.DH.lock = DATA.maxFloor < 6
    Cards.IN.lock = DATA.maxFloor < 7
    Cards.AS.lock = DATA.maxFloor < 8
    Cards.DP.lock = true -- Not really locked forever! Try to find the way to play it
end

function GAME.refreshPBText()
    local h = DATA.highScore[table.concat(TABLE.sort(GAME.getHand(true)))] or 0
    if h == 0 then return PBText:set("No Score Yet") end
    for f = 1, #Floors do
        if h < Floors[f].top then
            PBText:set(("Best: %.1fm   <F%d>"):format(h, f))
            break
        end
    end
end

function GAME.refreshRev()
    local anyRev = false
    for _, C in ipairs(Cards) do
        if GAME.mod[C.id] == 2 then
            anyRev = true
            break
        end
    end
    if anyRev ~= GAME.anyRev then
        GAME.anyRev = anyRev
        if not GAME.anyRev then
            GAME.revDeckSkin = false
        end
        TWEEN.new(function(t)
            if not anyRev then t = 1 - t end
            GAME.revTimer = t
            TextColor[1] = MATH.lerp(.7, .62, t)
            TextColor[2] = MATH.lerp(.5, .1, t)
            TextColor[3] = MATH.lerp(.3, .1, t)
            ShadeColor[1] = MATH.lerp(.3, .1, t)
            ShadeColor[2] = MATH.lerp(.15, 0, t)
            ShadeColor[3] = MATH.lerp(.0, 0, t)
        end):setDuration(.26):run()
        GAME.updateBgm('revSwitched')
    end
end

function GAME.updateBgm(event)
    if event == 'start' then
        BGM.set(BgmSets.assist, 'volume', 1)
        if GAME.anyRev then
            BGM.set('rev', 'volume', .62)
            BGM.set('expert', 'volume', 0)
        else
            BGM.set('expert', 'volume', GAME.mod.EX / 2)
        end
    elseif event == 'finish' then
        BGM.set(BgmSets.assist, 'volume', 0)
        local l = TABLE.copy(BgmSets.assist)
        for _ = 1, MATH.clamp(GAME.floor - 6, 2, 4) do
            BGM.set(TABLE.popRandom(l), 'volume', 1)
        end
        if GAME.anyRev then
            BGM.set('rev', 'volume', .82)
        end
    elseif event == 'expertSwitched' then
        BGM.set('expert', 'volume', GAME.anyRev and GAME.mod.EX / 2 or 0)
    elseif event == 'revSwitched' then
        BGM.set('expert', 'volume', GAME.mod.EX / 2)
        if GAME.anyRev then
            BGM.set('rev', 'volume', .82, 4.2)
            BGM.set(BgmSets.assist, 'volume', 0, 4.2)
        else
            BGM.set('rev', 'volume', 0, 2.6)
            local l = TABLE.copy(BgmSets.assist)
            for _ = 1, 2 do
                BGM.set(TABLE.popRandom(l), 'volume', 1, 4.2)
            end
        end
    elseif event == 'f10' then
        BGM.set('bass', 'volume', 0)
    elseif event == 'init' then
        BGM.play(BgmSets.all)
        BGM.set('all', 'volume', 0, 0)
        BGM.set('piano', 'volume', 1)
        BGM.set('piano2', 'pitch', 2, 0)
        BGM.set(TABLE.getRandom(BgmSets.assist), 'volume', 1, 10)
    end
end

-- for floor = 1, 10 do
--     local stat = { 0, 0, 0, 0, 0 }
--     local sum = 0
--     for _ = 1, 1000 do
--         local base = .7023 + floor ^ .5 / 6 + .626
--         local var = floor / 3.55 - .626

--         local r = base + var * math.abs(MATH.randNorm())
--         r = MATH.roll(r % 1) and math.ceil(r) or math.floor(r)
--         r = MATH.clamp(r, 1, 5)
--         stat[r] = stat[r] + 1
--         sum = sum + r
--     end
--     print(("Floor %2d : %3d %3d %3d %3d %3d  E(x)=%.2f"):format(
--         floor, stat[1], stat[2], stat[3], stat[4], stat[5],
--         sum / MATH.sum(stat)))
-- end

function GAME.genQuest()
    local combo = {}
    local base = .626 + GAME.floor ^ .5 / 6
    local var = GAME.floor / 3.55
    if GAME.mod.DH then base, var = base + .626, var - .626 end

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
        name = GAME.getComboName(TABLE.copy(combo), GAME.mod.DH == 2),
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
    GAME.firstClickTimer = false
end

function GAME.anim_setMenuHide(t)
    GAME.uiHide = t
    MSG.setSafeY(75 * (1 - GAME.uiHide))
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
    if GAME.mod.MS > 0 then
        GAME.shuffleCards()
    end
    GAME.questReady()
end
function GAME.start()
    if TASK.getLock('cannotStart') then
        SFX.play('clutch')
        return
    end
    if GAME.mod.DP > 0 then
        MSG.clear()
        MSG('dark', "Working in Progress")
        Cards.DP:shake()
        SFX.play('no')
        return
    end
    if GAME.mod.EX == 2 then
        MSG.clear()
        MSG('dark', "Working in Progress")
        Cards.EX:shake()
        SFX.play('no')
        return
    end
    SCN.scenes.main.widgetList.hint:setVisible(false)

    SFX.play('menuconfirm', .8)
    SFX.play(Cards.DP.active and 'zenith_start_duo' or 'zenith_start', 1, 0, GAME.mod.GV)

    GAME.playing = true
    GAME.dmgHeal = 2
    GAME.dmgWrong = 1
    GAME.dmgTime = 2
    GAME.dmgDelay = 15
    GAME.dmgCycle = 5
    GAME.queueLen = GAME.mod.NH == 2 and 1 or 3

    GAME.time = 0
    GAME.questTime = 0
    GAME.questCount = 0
    GAME.rank = 1
    GAME.xp = 0
    GAME.rankupLast = false
    GAME.xpLockLevel = 5
    GAME.xpLockTimer = 0
    GAME.floor = 0
    GAME.fatigue = 1
    GAME.altitude = 0
    GAME.heightBuffer = 0
    GAME.life = 20
    GAME.dmgTimer = GAME.dmgDelay
    GAME.chain = 0

    GAME.upFloor()

    TABLE.clear(GAME.quests)
    while #GAME.quests < GAME.queueLen do GAME.genQuest() end

    TASK.removeTask_code(task_startSpin)
    TASK.new(task_startSpin)

    TWEEN.new(GAME.anim_setMenuHide):setDuration(.26):setUnique('textHide'):run()
    GAME.updateBgm('start')
end

---@param reason 'forfeit' | 'wrongAns' | 'killed'
function GAME.finish(reason)
    SCN.scenes.main.widgetList.hint:setVisible(true)
    MSG.clear()

    SFX.play(
        reason == 'forfeit' and 'detonated' or
        reason == 'wrongAns' and 'topout' or
        reason == 'killed' and 'losestock' or
        'shatter', .8)

    table.sort(Cards, function(a, b) return a.initOrder < b.initOrder end)
    for _, C in ipairs(Cards) do
        if (GAME.mod[C.id] > 0) ~= C.active then
            C:setActive(true)
        end
        C.touchCount = 0
        C.hintMark = false
        C:clearBuff()
    end

    GAME.playing = false

    if GAME.questCount > 2.6 then
        if GAME.floor >= 10 then
            local anyNewRev
            for k, v in next, GAME.mod do
                if v > 0 and not GAME.revUnlocked[k] then
                    GAME.revUnlocked[k] = true
                    anyNewRev = true
                end
            end
            if anyNewRev then
                MSG.clear()
                MSG('dark', "New reversed mod unlocked!!!\nActivate with right click")
                SFX.play('notify')
            end
        end
        local newPB
        if GAME.floor > DATA.maxFloor then
            DATA.maxFloor = GAME.floor
            newPB = true
        end
        local setStr = table.concat(TABLE.sort(GAME.getHand(true)))
        local oldPB = DATA.highScore[setStr] or 0
        if GAME.altitude > oldPB then
            DATA.highScore[setStr] = MATH.roundUnit(GAME.altitude, .1)
            DATA.maxFloor = DATA.maxFloor
            newPB = true
        end
        if newPB then
            local modCount = #GAME.getHand(true)
            if modCount > 0 and oldPB < Floors[9].top and GAME.floor >= 10 then
                local t = modCount == 1 and "MOD MASTERED" or "COMBO MASTERED"
                if GAME.anyRev then t = t:gsub(" ", "+ ") end
                TEXT:add {
                    text = t,
                    x = 800, y = 200, k = 2.6, fontSize = 60,
                    style = 'beat', inPoint = .26, outPoint = .62,
                    color = 'lC', duration = 6.2,
                }
                SFX.play('worldrecord', 1, 0, (modCount == 1 and -1 or 0) + GAME.mod.GV)
            elseif GAME.floor >= 2 then
                TEXT:add {
                    text = "PERSONAL BEST",
                    x = 800, y = 200, k = 3, fontSize = 60,
                    style = 'beat', inPoint = .26, outPoint = .62,
                    color = 'lY', duration = 6.2,
                }
                SFX.play('personalbest', 1, 0, -.1 + GAME.mod.GV)
            end
            SFX.play('applause', GAME.floor / 10)
            DATA.save()
        end
    end

    TASK.removeTask_code(task_startSpin)
    GAME.refreshLockState()
    GAME.refreshPBText()
    GAME.refreshCurrentCombo()

    TWEEN.new(GAME.anim_setMenuHide_rev):setDuration(.26):setUnique('textHide'):run()
    DiscordRPC.update {
        details = "QUICK PICK",
        state = "Enjoying Music",
    }
    GAME.updateBgm('finish')
    TASK.lock('cannotStart', 1)
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
    else
        local dangerDmg = math.max(GAME.dmgWrong, GAME.dmgTime)
        if GAME.life <= dangerDmg and GAME.life + dmg > dangerDmg then
            SFX.play('hyperalert')
        end
    end
end

function GAME.commit()
    if #GAME.quests == 0 then return end

    local Q = GAME.quests[1]

    local hand = GAME.getHand(false)
    local target = Q.combo
    local result = TABLE.equal(TABLE.sort(hand), TABLE.sort(target))

    if result then
        GAME.life = math.min(GAME.life + math.max(GAME.dmgHeal, 0), 20)

        local dp = TABLE.find(hand, 'DP')
        local attack = 3
        local xp = 0
        if dp then attack = attack + 2 end
        if GAME.fault then
            attack = attack + 1
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
            attack = attack + 2
            xp = xp + 3
            GAME.chain = GAME.chain + 1
            if GAME.chain < 4 then
            elseif GAME.chain < 8 then
                if GAME.chain == 4 then SFX.play('b2bcharge_start', .8) end
                SFX.play('b2bcharge_1', .8)
            elseif GAME.chain < 12 then
                SFX.play('b2bcharge_2', .8)
            elseif GAME.chain < 24 then
                SFX.play('b2bcharge_3', .8)
            else
                SFX.play('b2bcharge_4', .8)
            end
        end

        SFX.play(dp and 'zenith_start_duo' or 'zenith_start', .626, 0, 12 + GAME.mod.GV)

        GAME.addHeight(attack)
        GAME.addXP(attack + xp)

        if GAME.mod.MS == 2 then
            local r1 = math.random(2, #Cards - 1)
            local r2 = MATH.clamp(r1 + MATH.coin(-1, 1) * math.random(2), 1, #Cards)
            Cards[r1], Cards[r2] = Cards[r2], Cards[r1]
            GAME.refreshLayout()
        end

        GAME.genQuest()
        table.remove(GAME.quests, 1)
        GAME.questCount = GAME.questCount + 1

        GAME.cancelAll(true)

        GAME.dmgTimer = math.min(GAME.dmgTimer + math.max(2.6, GAME.dmgDelay / 2), GAME.dmgDelay)

        GAME.questReady()
        return true
    else
        GAME.fault = true
        if GAME.takeDamage(math.min(GAME.dmgWrong, 1), 'wrongAns') then return end
        if GAME.mod.EX > 0 then
            GAME.cancelAll(true)
        else
            for _, C in ipairs(Cards) do C:clearBuff() end
        end
    end
end

function GAME.task_cancelAll(instant)
    local spinMode = not instant and GAME.mod.AS > 0
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
end

function GAME.cancelAll(instant)
    if GAME.mod.NH == 2 then
        for _, C in ipairs(Cards) do C:clearBuff() end
        return
    end
    TASK.removeTask_code(GAME.task_cancelAll)
    TASK.new(GAME.task_cancelAll, instant)
    if GAME.firstClickTimer then GAME.firstClickTimer = GAME.firstClickDelay end
end

function GAME.shuffleCards()
    TABLE.shuffle(Cards)
    GAME.refreshLayout()
end

function GAME.upFloor()
    GAME.floor = GAME.floor + 1
    if GAME.mod.MS == 1 and GAME.floor % 3 == 2 then GAME.shuffleCards() end
    if GAME.mod.GV > 0 then GAME.firstClickDelay = GravityTimer[GAME.mod.GV][GAME.floor] end
    local F = Floors[GAME.floor]
    local e = F.event
    for i = 1, #e, 2 do
        GAME[e[i]] = GAME[e[i]] + e[i + 1]
    end
    if GAME.dmgTimer > GAME.dmgDelay then GAME.dmgTimer = GAME.dmgDelay end

    TEXT:add {
        text = "Floor",
        x = 160, y = 290, k = 1.6, fontSize = 30,
        color = 'LY', duration = 4.2,
    }
    TEXT:add {
        text = tostring(GAME.floor),
        x = 240, y = 280, k = 2.6, fontSize = 30,
        color = 'LY', duration = 4.2, align = 'left',
    }
    TEXT:add {
        text = Floors[GAME.floor].name,
        x = 200, y = 350, k = 1.2, fontSize = 30,
        color = 'LY', duration = 4.2,
    }
    if GAME.floor > 1 then SFX.play('zenith_levelup_g', 1, 0, GAME.mod.GV) end
    if GAME.floor == 10 then GAME.updateBgm('f10') end

    DiscordRPC.update {
        details = GAME.mod.EX > 0 and "EXPERT QUICK PICK" or "QUICK PICK",
        state = "In Game: F" .. GAME.floor .. " - " .. GAME.getComboName(GAME.getHand(true), GAME.mod.DH == 2),
    }
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
        if GAME.mod.GV > 0 and not GAME.firstClickTimer and GAME.questTime >= 2.6 and GAME.questTime - dt < 2.6 then
            GAME.firstClickTimer = GAME.firstClickDelay
        end
        local curFtgStag = (GAME.mod.EX == 2 and FatigueRevEx or Fatigue)[GAME.fatigue]
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
            GAME.xp = GAME.xp - dt * (GAME.mod.EX > 0 and 5 or 3) * GAME.rank * (GAME.rank + 1) / 60
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

        if GAME.firstClickTimer then
            GAME.firstClickTimer = GAME.firstClickTimer - dt
            if GAME.firstClickTimer <= 0 then
                GAME.firstClickTimer = GAME.firstClickDelay
                GAME.commit()
            end
        end
    end
end

return GAME
