local flushCHN, dataCHN = love.thread.getChannel('save_flush'), love.thread.getChannel('save_data')

---@class Techmino.Data: Techmino._Data
local _DATA = {
    maxAltitude = 0,
    maxFloor = 1,
}

setmetatable(_DATA, {
    __index = { ---@class Techmino._Data
        load = function() TABLE.update(_DATA, FILE.load('data.luaon', '-luaon -canskip') or NONE) end,
        flush = function() flushCHN:push(true) end,
    }
})

local saveThread = love.thread.newThread [[
    local write=require'love.filesystem'.write
    local sleep=require'love.timer'.sleep
    local data,timer
    local dataCHN=love.thread.getChannel('save_data')
    local flushCHN=love.thread.getChannel('save_flush')
    local signalCHN=love.thread.getChannel('save_signal')

    while true do
        if not data then
            -- print("Saver-Demanding")
            data=dataCHN:demand()
            timer=26
        else
            local cnt=dataCHN:getCount()
            if cnt>0 then
                -- print("Saver-Overwrite")
                for i=1,cnt-1 do dataCHN:pop() end
                data=dataCHN:pop()
                timer=46
            end
        end

        -- print("Saver-Wait",timer)
        sleep(.1)
        timer=timer-1
        if flushCHN:pop() then timer=0 end
        if timer<=0 then
            -- print("Saver-Save",timer)
            write('data.luaon',data)
            signalCHN:push(true)
            data,timer=nil
        end
    end
]]
saveThread:start()

local dieCount = 0
TASK.new(function()
    local yield = coroutine.yield
    local signalCHN = love.thread.getChannel('save_signal')
    while true do
        yield(.1)
        if not saveThread:isRunning() then
            dieCount = dieCount + 1
            if dieCount <= 3 then
                MSG('warn', ('SaveThread crashed(x$1):$2'):repD(dieCount, saveThread:getError()), 12)
                saveThread:start()
            else
                MSG('error', ('SaveThread died completely:$1'):repD(saveThread:getError()), 26)
                return
            end
        end
        if signalCHN:pop() then print("SAVE") end
    end
end)

---@type Techmino.Data
return setmetatable({}, {
    __newindex = function(_, k, v)
        _DATA[k] = v
        dataCHN:push(TABLE.dumpDeflate(_DATA))
    end,
    __index = _DATA,
})
