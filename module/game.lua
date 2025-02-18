---@class Game
local GAME = {
    forfeitTimer = 0,
    exTimer = 0,
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
    rank = 1,
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
    SFX.play(Cards[9].active and 'zenith_start_duo' or 'zenith_start', nil, nil, GAME.mod_GV)

    self.playing = true
    self.xp = 0
    self.rank = 1
    self.floor = 1
    self.altitude = 0

    TASK.removeTask_code(task_startSpin)
    TASK.new(task_startSpin)
end

function GAME:finish()
    SCN.scenes.main.widgetList.hint:setVisible(true)
    MSG.setSafeY(62)

    BGM.set(BgmSets.extra, 'volume', 0)
    local l = TABLE.copy(BgmSets.extra)
    BGM.set(TABLE.popRandom(l), 'volume', 1)
    BGM.set(TABLE.popRandom(l), 'volume', 1)

    SFX.play('losestock')

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

    -- TASK.removeTask_code(task_startSpin) -- Double hit quickly then you can...
    if self.mod_AS then for _, C in next, Cards do C.burn = false end end
    GAME:freshLockState()
end

function GAME:commit()
    -- TODO
    if self.mod_MS == 2 then
        table.insert(Cards, math.random(#Cards), table.remove(Cards, math.random(#Cards)))
        RefreshLayout()
    end
    if self.mod_AS then for _, C in next, Cards do C.burn = false end end
end

function GAME:task_cancelAll()
    local spinMode = self.mod_AS > 0
    for i = 1, #Cards do
        local C = Cards[i]
        if spinMode or C.active then
            C:setActive(true)
            TASK.yieldT(.026)
        end
    end
end

function GAME:cancelAll()
    if GAME.mod_NH == 2 then return end
    TASK.removeTask_code(GAME.task_cancelAll)
    TASK.new(GAME.task_cancelAll, GAME)
end

function GAME:shuffleCards()
    TABLE.shuffle(Cards)
    RefreshLayout()
end

return GAME
