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
}

function GAME:freshComboText()
    self.modText:set(GetComboName(nil,GAME.mod_DH==2))
end

function GAME:freshLockState()
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
        GAME:shuffleCards()
    end
end
function GAME:start()
    SCN.scenes.main.widgetList.hint:setVisible(false)
    MSG.setSafeY(0)
    MSG('io', "The game is still working in progress.\nYou can only press START to forfeit game", 4.2)

    BGM.set(BgmSets.extra, 'volume', 1)

    SFX.play('menuconfirm')
    SFX.play(Cards[9].active and 'zenith_start_duo' or 'zenith_start', nil, nil, self.mod_GV)

    self.playing = true
    self.dmgHeal = 2
    self.dmgWrong = 1
    self.dmgDelay = 15
    self.dmgCycle = 3

    self.time = 0
    self.xp = 0
    self.rank = 1
    self.floor = 1
    self.fatigue = 1
    self.altitude = 0
    self.live = 20
    self.dmgTimer = 0
    self.b2b = 0

    TASK.removeTask_code(task_startSpin)
    TASK.new(task_startSpin)
end

function GAME:finish()
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

    self.playing = false

    -- if self.floor > DATA.maxFloor then DATA.maxFloor = self.floor end
    -- if self.altitude > DATA.maxAltitude then DATA.maxAltitude = self.altitude end

    TASK.removeTask_code(task_startSpin) -- Double hit quickly then you can...
    self:remDebuff()
    self:freshLockState()
end

function GAME:commit()
    local result
    -- TODO
    self:remDebuff()
    if result then
        self.live = math.min(self.live + math.max(self.dmgHeal, 0), 20)
        -- TODO
        if self.mod_MS == 2 then
            local r1 = math.random(#Cards)
            local r2 = math.random(#Cards - 1)
            if r2 >= r1 then r2 = r2 + 1 end
            Cards[r1], Cards[r2] = Cards[r2], Cards[r1]
            RefreshLayout()
        end
    else
        self.live = math.max(self.live - math.min(self.dmgWrong, 1), 0)
        -- TODO
        if self.live <= 0 then
            self:finish()
            return
        end
    end
    if result or self.mod_EX > 0 then
        self:cancelAll(true)
    end
end

function GAME:task_cancelAll(noSpin)
    local spinMode = not noSpin and self.mod_AS > 0
    for i = 1, #Cards do
        local C = Cards[i]
        if spinMode or C.active then
            C:setActive(true)
            TASK.yieldT(.026)
        end
    end
end

function GAME:cancelAll(noSpin)
    if self.mod_NH == 2 then return end
    TASK.removeTask_code(self.task_cancelAll)
    TASK.new(self.task_cancelAll, self, noSpin)
end

function GAME:remDebuff()
    if self.mod_AS then for _, C in next, Cards do C.burn = false end end
end

function GAME:shuffleCards()
    TABLE.shuffle(Cards)
    RefreshLayout()
end

function GAME:upFloor()
    self.floor = self.floor + 1
    if self.mod_MS == 1 and (self.floor % 2 == 1 or self.floor == 10) then self:shuffleCards() end
    TEXT:add {
        text = "Floor",
        x = 160, y = 290, k = 1.6, fontSize = 30,
        color = 'LY', duration = 2.6,
    }
    TEXT:add {
        text = tostring(self.floor),
        x = 240, y = 280, k = 2.6, fontSize = 30,
        color = 'LY', duration = 2.6, align = 'left',
    }
    TEXT:add {
        text = Floors[self.floor].name,
        x = 200, y = 350, k = 1.2, fontSize = 30,
        color = 'LY', duration = 2.6,
    }
    SFX.play('zenith_levelup_' .. Floors[self.floor].sfx)
end

function GAME:update(dt)
    if self.playing then
        self.time = self.time + dt
        local curFtgStag = (self.mod_EX == 2 and FatigueRevEx or Fatigue)[self.fatigue]
        if self.time >= curFtgStag.time then
            local e = curFtgStag.event
            for i = 1, #e, 2 do
                GAME[e[i]] = GAME[e[i]] + e[i + 1]
            end
            self.fatigue = self.fatigue + 1
        end

        local distRemain = Floors[self.floor].top - self.altitude
        self.altitude = self.altitude + dt * self.rank / 4 * MATH.icLerp(1, 6, distRemain)

        -- if love.keyboard.isDown('z') then
        --     GAME.altitude = GAME.altitude + dt * 260
        -- end

        if self.altitude >= Floors[self.floor].top then
            GAME:upFloor()
        end

        self.xp = self.xp - dt * (self.mod_EX and 5 or 3) * self.rank * (self.rank + 1) / 60
        if self.xp <= 0 then
            self.xp = 0
            if self.rank > 1 then
                self.rank = self.rank - 1
                SFX.play('speed_down')
                -- SFX.play('speed_up_'..MATH.clamp(GAME.rank-1,1,4))
            end
        end
    end
end

return GAME
