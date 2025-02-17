---@class Game
local GAME = {
    forfeitTimer = 0,
    bg = { .1, 0, 0 },

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
    modText = GC.newText(FONT.get(30)),
    time = 0,
    xp = 0,
    rank = 0,
    floor = 1,
    altitude = 0,
}

function GAME:freshComboText()
    self.modText:set(GetComboName())
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
end
function GAME:start()
    BGM.set(BgmSets.extra, 'volume', 1)
    SFX.play('zenith_start')

    self.playing = true
    self.xp = 0
    self.rank = 0
    self.floor = 1
    self.altitude = 0

    TASK.removeTask_code(task_startSpin)
    TASK.new(task_startSpin)
end

function GAME:finish()
    BGM.set(BgmSets.extra, 'volume', 0)
    local l = TABLE.copy(BgmSets.extra)
    BGM.set(TABLE.popRandom(l), 'volume', 1)
    BGM.set(TABLE.popRandom(l), 'volume', 1)

    table.sort(Cards, function(a, b) return a.initOrder < b.initOrder end)
    for _, C in next, Cards do
        if (GAME['mod_' .. C.id] > 0) ~= C.active then
            C:setActive(true)
        end
        C.lock = GAME['mod_' .. C.id] < 0
    end

    self.playing = false

    if self.altitude > DATA.maxAltitude then
        DATA.maxAltitude = self.altitude
    end
    if self.floor > DATA.maxFloor then
        DATA.maxFloor = self.floor
    end
    -- TASK.removeTask_code(task_startSpin) -- Double hit quickly then you can...
    GAME:freshLockState()
end

function GAME.task_cancelAll(auto)
    for i = 1, #Cards do
        local C = Cards[i]
        if C.active then
            C:setActive(auto)
            TASK.yieldT(.026)
        end
    end
end
function GAME:cancelAll(auto)
    if GAME.mod_NH == 2 then return end
    TASK.removeTask_code(GAME.task_cancelAll)
    TASK.new(GAME.task_cancelAll, auto)
end

return GAME
