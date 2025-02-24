local ins, rem = table.insert, table.remove

---@class Question
---@field combo string[]
---@field name love.Text

---@class Game
---@field dmgHeal number
---@field dmgWrong number
---@field dmgTime number
---@field dmgDelay number
---@field dmgCycle number
---@field queueLen number
---
---@field questTime number
---@field gravDelay false | number
---@field gravTimer false | number
---@field questCount number
---@field rankupLast boolean
---@field xpLockLevel number
---@field xpLockTimer number
---@field fatigueSet {time:number, event:table, text:string, desc:string}[]
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

    completion = { -- 0=locked, 1=unlocked, 2=mastered
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

    playing = false,
    quests = {}, --- @type Question[]

    life = 0,
    lifeShow = 0,
    time = 0,
    floor = 1,
    rank = 1,
    xp = 0,
    height = 0,
}
local M = GAME.mod

--- Unsorted
function GAME.getHand(showRev)
    local list = {}
    if showRev then
        for i = 1, 9 do
            local D = DeckData[i]
            local level = M[D.id]
            if level > 0 then
                ins(list, level == 2 and 'r' .. D.id or D.id)
            end
        end
    else
        for _, C in ipairs(Cards) do
            if C.active then
                ins(list, C.id)
            end
        end
    end
    return list
end

---@param list string[] OVERWRITE!!!
---@param extend? boolean use extended combo lib from community
---@param colored? boolean return a color-string table instead
function GAME.getComboName(list, extend, colored)
    local len = #list
    if colored then
        if len == 0 then return {} end

        local fstr = {}

        local comboText
        if not GAME.anyRev and not TABLE.find(list, 'DP') then
            comboText = len == 8 and [["SWAMP WATER"]] or len == 7 and [["SWAMP WATER LITE"]]
            if comboText then
                fstr = comboText:atomize()
                for i = #fstr, 1, -1 do
                    ins(fstr, i, i % #fstr <= 1 and COLOR.dL or COLOR.random(5))
                end
                return fstr
            end
        end

        local str = table.concat(TABLE.sort(list), ' ')
        if Combos[str] and (Combos[str].basic or extend) then return { COLOR.dL, Combos[str].name } end

        table.sort(list, function(a, b) return Mod.prio[a] < Mod.prio[b] end)

        for i = 1, len - 1 do
            ins(fstr, Mod.textColor[list[i]])
            ins(fstr, Mod.adj[list[i]] .. " ")
        end
        ins(fstr, Mod.textColor[list[len]])
        ins(fstr, Mod.noun[list[len]])
        if M.IN > 0 then
            local r = 0
            for i = 1, #fstr, 2 do
                r = (r + math.random(0, 3)) % 4
                fstr[i] = { 1, 1, 1, .55 + .15 * r }
            end
        end

        return fstr
    else
        if len == 0 then return "" end
        if len == 1 then return Mod.noun[list[1]] end

        if not GAME.anyRev and not TABLE.find(list, 'DP') then
            if len == 8 then return [["SWAMP WATER"]] end
            if len == 7 then return [["SWAMP WATER LITE"]] end
        end

        local str = table.concat(TABLE.sort(list), ' ')
        if Combos[str] and (Combos[str].basic or extend) then return Combos[str].name end

        table.sort(list, function(a, b) return Mod.prio[a] < Mod.prio[b] end)

        str = ""
        for i = 1, len - 1 do str = str .. Mod.adj[list[i]] .. " " end
        return str .. Mod.noun[list[len]]
    end
end

function GAME.updateBgm(event)
    if event == 'start' then
        BGM.set(BgmSets.assist, 'volume', 1)
        if GAME.anyRev then
            BGM.set('rev', 'volume', .62)
            BGM.set('expert', 'volume', 0)
        else
            BGM.set('expert', 'volume', M.EX / 2)
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
        BGM.set('expert', 'volume', GAME.anyRev and M.EX / 2 or 0)
    elseif event == 'revSwitched' then
        BGM.set('expert', 'volume', M.EX / 2)
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

function GAME.anim_setMenuHide(t)
    GAME.uiHide = t
    MSG.setSafeY(75 * (1 - GAME.uiHide))
end

function GAME.anim_setMenuHide_rev(t)
    GAME.anim_setMenuHide(1 - t)
end

function GAME.task_fatigueWarn()
    for _ = 1, 3 do
        for _ = 1, 3 do SFX.play('warning', 1, 0, M.GV) end
        TASK.yieldT(1)
    end
end

function GAME.cancelBurn()
    for i = 1, #Cards do Cards[i].burn = false end
end

function GAME.shuffleCards()
    TABLE.shuffle(Cards)
    GAME.refreshLayout()
end

-- for floor = 1, 10 do
--     local stat = { 0, 0, 0, 0, 0 }
--     local sum = 0
--     for _ = 1, 1000 do
--         local base = .872 + floor ^ .5 / 6
--         local var = floor * .26
--         if false then base, var = base + .626, var * .626 end

--         local r = base + var * math.abs(MATH.randNorm())
--         r = MATH.clamp(MATH.roll(r % 1) and math.ceil(r) or math.floor(r), 1, 5)
--         stat[r] = stat[r] + 1
--         sum = sum + r
--     end
--     print(("Floor %2d : %3d %3d %3d %3d %3d  E(x)=%.2f"):format(
--         floor, stat[1], stat[2], stat[3], stat[4], stat[5],
--         sum / MATH.sum(stat)))
-- end

function GAME.genQuest()
    local combo = {}
    local base = .872 + GAME.floor ^ .5 / 6
    local var = GAME.floor * .26
    if M.DH > 0 then base, var = base + .626, var * .626 end

    local r = MATH.clamp(base + var * math.abs(MATH.randNorm()), 1, 5)
    GAME.atkBuffer = GAME.atkBuffer + r
    if GAME.atkBuffer > 8 then
        r = r - (GAME.atkBuffer - 8)
        GAME.atkBuffer = 8
    end
    GAME.atkBuffer = math.max(GAME.atkBuffer - math.max(GAME.floor / 3, 2), 0)

    local pool = TABLE.copyAll(Mod.weight)
    local lastQ = GAME.quests[#GAME.quests]
    if lastQ then pool[lastQ.combo[1]] = nil end
    for _ = 1, MATH.clamp(MATH.roundRnd(r), 1, 5) do
        local mod = MATH.randFreqAll(pool)
        pool[mod] = nil
        ins(combo, mod)
    end

    ins(GAME.quests, {
        combo = combo,
        name = GC.newText(FONT.get(60), GAME.getComboName(TABLE.copy(combo), M.DH == 2, M.NH < 2)),
    })
end

function GAME.questReady()
    GAME.questTime = 0
    GAME.fault = false
    GAME.faultWrong = false
    for _, C in ipairs(Cards) do
        C.touchCount = 0
        C.hintMark = false
    end
    local Q = GAME.quests[1].combo
    for i = 1, #Q do Cards[Q[i]].hintMark = true end
    GAME.gravTimer = false
end

function GAME.takeDamage(dmg, killReason)
    GAME.life = math.max(GAME.life - dmg, 0)
    SFX.play(
        dmg <= 1 and 'damage_small' or
        dmg <= 4 and 'damage_medium' or
        'damage_large', .872)
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

function GAME.addHeight(h)
    GAME.heightBuffer = GAME.heightBuffer + h * GAME.rank / 4
end

function GAME.addXP(xp)
    GAME.xp = GAME.xp + xp
    if GAME.xpLockLevel < 5 and GAME.rankupLast and GAME.xp >= 2 * GAME.rank then
        GAME.xpLockLevel = 5
    end
    local rankup
    while GAME.xp >= 4 * GAME.rank do
        GAME.xp = GAME.xp - 4 * GAME.rank
        GAME.rank = GAME.rank + 1
        rankup = true
        GAME.rankupLast = true
        GAME.xpLockTimer = GAME.xpLockLevel
        GAME.xpLockLevel = math.max(GAME.xpLockLevel - 1, 1)

        -- Rank skip
        if GAME.xp >= 4 * GAME.rank then
            GAME.rank = GAME.rank + math.floor(GAME.xp / (4 * GAME.rank))
            -- One more
            if GAME.xp >= 4 * GAME.rank then
                GAME.rank = GAME.rank + 1
                GAME.xp = GAME.xp - 4 * GAME.rank
            end
            GAME.xpLockLevel = 5
        end
    end
    if rankup then
        SFX.play('speed_up_' .. MATH.clamp(2 + math.floor(GAME.rank / 2), 1, 4), .4 + GAME.xpLockLevel / 10)
    end
end

function GAME.upFloor()
    GAME.floor = GAME.floor + 1
    if M.MS == 2 or M.MS == 1 and GAME.floor % 3 == 2 then GAME.shuffleCards() end
    if M.GV > 0 then GAME.gravDelay = GravityTimer[M.GV][GAME.floor] end
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
    if GAME.floor > 1 then SFX.play('zenith_levelup_g', 1, 0, M.GV) end
    if GAME.floor == 10 then GAME.updateBgm('f10') end

    DiscordRPC.update {
        details = M.EX > 0 and "EXPERT QUICK PICK" or "QUICK PICK",
        state = "In Game: F" .. GAME.floor .. " - " .. GAME.getComboName(GAME.getHand(true), M.DH == 2),
    }
end

--------------------------------------------------------------

function GAME.refreshCurrentCombo()
    GAME.modText:set(GAME.getComboName(GAME.getHand(not GAME.playing), M.DH == 2))
    GAME.hardMode = M.EX > 0 or not not TABLE.findAll(M, 2)
end

function GAME.refreshLayout()
    local baseDist = (M.EX > 0 and 100 or 110) + M.VL * 20
    local baseL, baseR = 800 - 4 * baseDist - 70, 800 + 4 * baseDist + 70
    local dodge = M.VL == 0 and 260 or 220
    local baseY = 726 + 15 * M.GV
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
        if M[C.id] == 2 then
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

function GAME.cancelAll(instant)
    if M.NH == 2 then
        if M.AS == 1 then GAME.cancelBurn() end
        return
    end
    TASK.removeTask_code(GAME.task_cancelAll)
    TASK.new(GAME.task_cancelAll, instant)
    if GAME.gravTimer then GAME.gravTimer = GAME.gravDelay end
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
            if M.AS == 1 then
                list[i].burn = false
            end
            if not instant then
                TASK.yieldT(.026)
            end
        end
    end
end

function GAME.commit()
    if #GAME.quests == 0 then return end

    local Q = GAME.quests[1]

    local hand = GAME.getHand(false)

    if TABLE.equal(TABLE.sort(hand), TABLE.sort(Q.combo)) then
        GAME.life = math.min(GAME.life + math.max(GAME.dmgHeal, 0), 20)

        local dp = TABLE.find(hand, 'DP')
        local attack = 3
        local xp = 0
        if dp and M.EX <= 2 then attack = attack + 2 end
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
            attack = attack + 1
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
        if GAME.chain >= 4 then
            ChainText:set(tostring(GAME.chain))
        end

        SFX.play(dp and 'zenith_start_duo' or 'zenith_start', .626, 0, 12 + M.GV)

        GAME.addHeight(attack)
        GAME.addXP(attack + xp)

        if M.MS == 2 then
            local r1 = math.random(2, #Cards - 1)
            local r2, r3
            repeat r2 = math.random(r1 - 2, r1 + 2) until r2 ~= r1 and MATH.between(r2, 1, #Cards)
            repeat r3 = math.random(r1 - 2, r1 + 2) until r3 ~= r1 and r3 ~= r2 and MATH.between(r3, 1, #Cards)
            if GAME.floor <= 8 then
                Cards[r1], Cards[r2] = Cards[r2], Cards[r1]
            else
                Cards[r1], Cards[r2], Cards[r3] = Cards[r2], Cards[r3], Cards[r1]
            end
            GAME.refreshLayout()
        end

        GAME.genQuest()
        rem(GAME.quests, 1)
        GAME.questCount = GAME.questCount + 1

        local combo = GAME.quests[1] and GAME.quests[1].combo or NONE
        local hasDH = TABLE.find(combo, 'DH') and 1 or 0
        if #combo >= 4 then
            SFX.play('garbagewindup_' .. MATH.clamp(#combo * 2 - 7 + hasDH, 1, 4))
        end

        GAME.cancelAll(true)
        GAME.cancelBurn()

        GAME.dmgTimer = math.min(GAME.dmgTimer + math.max(2.6, GAME.dmgDelay / 2), GAME.dmgDelay)

        GAME.questReady()
        return true
    else
        GAME.fault = true
        GAME.faultWrong = true
        if GAME.takeDamage(math.min(GAME.dmgWrong, 1), 'wrongAns') then return end
        if M.EX > 0 then
            GAME.cancelAll(true)
        elseif M.AS == 1 then
            GAME.cancelBurn()
        end
    end
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
    if M.MS > 0 then
        GAME.shuffleCards()
    end
    GAME.questReady()
end
function GAME.start()
    if TASK.getLock('cannotStart') then
        SFX.play('clutch')
        return
    end
    if M.DP > 0 then
        MSG.clear()
        MSG('dark', "Working in Progress")
        Cards.DP:shake()
        SFX.play('no')
        return
    end
    SCN.scenes.tower.widgetList.hint:setVisible(false)

    SFX.play('menuconfirm', .8)
    SFX.play(Cards.DP.active and 'zenith_start_duo' or 'zenith_start', 1, 0, M.GV)

    GAME.playing = true
    GAME.dmgHeal = 2
    GAME.dmgWrong = 1
    GAME.dmgTime = 2
    GAME.dmgTimeMul = 1
    GAME.dmgDelay = 15
    GAME.dmgCycle = 5
    GAME.queueLen = M.NH == 2 and 1 or 3

    GAME.time = 0
    GAME.questTime = 0
    GAME.questCount = 0
    GAME.rank = 1
    GAME.xp = 0
    GAME.rankupLast = false
    GAME.xpLockLevel = 5
    GAME.xpLockTimer = 0
    GAME.floor = 0
    GAME.fatigueSet = Fatigue[M.EX == 2 and 'rEX' or M.EX == 2 and 'rDP' or 'normal']
    GAME.fatigue = 1
    GAME.height = 0
    GAME.heightBuffer = 0
    GAME.life = 20
    GAME.dmgTimer = GAME.dmgDelay
    GAME.chain = 0
    GAME.atkBuffer = 0

    GAME.upFloor()

    TABLE.clear(GAME.quests)
    for _ = 1, GAME.queueLen do GAME.genQuest() end

    TASK.removeTask_code(task_startSpin)
    TASK.new(task_startSpin)

    TWEEN.new(GAME.anim_setMenuHide):setDuration(.26):setUnique('textHide'):run()
    GAME.updateBgm('start')
end

---@param reason 'forfeit' | 'wrongAns' | 'killed'
function GAME.finish(reason)
    SCN.scenes.tower.widgetList.hint:setVisible(true)
    MSG.clear()

    SFX.play(
        reason == 'forfeit' and 'detonated' or
        reason == 'wrongAns' and 'topout' or
        reason == 'killed' and 'losestock' or
        'shatter', .8)

    table.sort(Cards, function(a, b) return a.initOrder < b.initOrder end)
    for _, C in ipairs(Cards) do
        if (M[C.id] > 0) ~= C.active then
            C:setActive(true)
        end
        C.touchCount = 0
        C.hintMark = false
        C.burn = false
        C.charge = 0
    end

    GAME.playing = false

    if GAME.questCount > 2.6 then
        if GAME.floor >= 10 then
            if TABLE.count(GAME.completion, 0) == 9 then
                MSG.clear()
                MSG('dark', "REVERSED MOD unlocked!!!\nActivate with right click")
                SFX.play('notify')
            end
            for k, v in next, M do
                GAME.completion[k] = math.max(GAME.completion[k], v)
            end
        end
        local newPB
        if GAME.floor > DATA.maxFloor then
            DATA.maxFloor = GAME.floor
            newPB = true
        end
        local setStr = table.concat(TABLE.sort(GAME.getHand(true)))
        local oldPB = DATA.highScore[setStr]
        if GAME.height > oldPB then
            DATA.highScore[setStr] = MATH.roundUnit(GAME.height, .1)
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
                    x = 800, y = 226, k = 2.6, fontSize = 60,
                    style = 'beat', inPoint = .26, outPoint = .62,
                    color = 'lC', duration = 6.2,
                }
                SFX.play('worldrecord', 1, 0, (modCount == 1 and -1 or 0) + M.GV)
            elseif GAME.floor >= 2 then
                TEXT:add {
                    text = "PERSONAL BEST",
                    x = 800, y = 226, k = 3, fontSize = 60,
                    style = 'beat', inPoint = .26, outPoint = .62,
                    color = 'lY', duration = 6.2,
                }
                SFX.play('personalbest', 1, 0, -.1 + M.GV)
            end
            SFX.play('applause', GAME.floor / 10)
            DATA.save()
        end
        HeightText:set(("%.1fm"):format(GAME.height))
        TimeText:set(STRING.time_simp(GAME.time))
    else
        HeightText:set("")
        TimeText:set("")
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
    if reason ~= 'forfeit' then
        TASK.lock('cannotStart', 1)
        TASK.lock('cannotFlip', .626)
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
        if M.GV > 0 and not GAME.gravTimer and GAME.questTime >= 2.6 and GAME.questTime - dt < 2.6 then
            GAME.gravTimer = GAME.gravDelay
        end
        local stage = GAME.fatigueSet[GAME.fatigue]
        if GAME.time >= stage.time then
            local e = stage.event
            for i = 1, #e, 2 do
                GAME[e[i]] = GAME[e[i]] + e[i + 1]
            end
            GAME.fatigue = GAME.fatigue + 1
            local duration = GAME.fatigue == #GAME.fatigueSet and 10 or 5
            TEXT:add {
                text = stage.text,
                x = 800, y = 265, fontSize = 30, k = 1.5,
                style = 'score', duration = duration,
                inPoint = .1, outPoint = .26,
                color = 'lM',
            }
            TEXT:add {
                text = stage.desc,
                x = 800, y = 300, fontSize = 30,
                style = 'score', duration = duration,
                inPoint = .26, outPoint = .1,
                color = 'lM',
            }
            TASK.new(GAME.task_fatigueWarn)
        end

        local releaseHeight = GAME.heightBuffer
        GAME.heightBuffer = math.max(MATH.expApproach(GAME.heightBuffer, 0, dt * 6.3216), GAME.heightBuffer - 600 * dt)
        releaseHeight = releaseHeight - GAME.heightBuffer

        GAME.height = GAME.height + releaseHeight
        if M.EX < 2 then
            GAME.height = GAME.height + GAME.rank / 4 * dt * MATH.icLerp(1, 6, Floors[GAME.floor].top - GAME.height)
        else
            GAME.height = math.max(
                GAME.height - dt * (GAME.floor * (GAME.floor + 1) + 10) / 20,
                GAME.floor == 1 and 0 or Floors[GAME.floor - 1].top
            )
        end

        if GAME.height >= Floors[GAME.floor].top then
            GAME.upFloor()
        end

        if GAME.xpLockTimer > 0 then
            GAME.xpLockTimer = GAME.xpLockTimer - dt
        else
            GAME.xp = GAME.xp - dt * (M.EX > 0 and 5 or 3) * GAME.rank * (GAME.rank + 1) / 60
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

        GAME.dmgTimer = GAME.dmgTimer - dt / GAME.dmgTimeMul
        if GAME.dmgTimer <= 0 then
            GAME.dmgTimer = GAME.dmgCycle
            GAME.takeDamage(GAME.dmgTime, 'killed')
        end

        if GAME.gravTimer then
            GAME.gravTimer = GAME.gravTimer - dt
            if GAME.gravTimer <= 0 then
                GAME.gravTimer = GAME.gravDelay
                GAME.commit()
            end
        end
    end
end

return GAME
