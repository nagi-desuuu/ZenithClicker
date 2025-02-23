---@type Zenitha.Scene
local scene = {}

local t1, t2 = .626, .42
local text = GC.newText(FONT.get(60), "JOINING ROOM...")

function scene.load()
    love.keyboard.setKeyRepeat(false)
end

function scene.update(dt)
    dt = math.min(dt, 1 / 30)
    if t1 > 0 then
        t1 = t1 - dt
        if t1 <= 0 then
            text:set("GETTING READY TO SPECTATE...")
            GAME.updateBgm('init')
            TASK.new(Daemon_Sync)
            TASK.new(Daemon_Beat)
            TASK.new(Daemon_Floor)
        end
    elseif t2 > 0 then
        t2 = t2 - dt
        if t2 <= 0 then
            SCN.go('tower')
        end
    end
end

function scene.draw()
    GC.setColor(.2, .2, .2)
    GC.strokeDraw('full', 7, text, 800, 500, 0, 1.26, 2, text:getWidth() / 2, text:getHeight() / 2)
    GC.setColor(.4, .4, .4)
    GC.strokeDraw('full', 4, text, 800, 500, 0, 1.26, 2, text:getWidth() / 2, text:getHeight() / 2)
    GC.setColor(.6, .6, .6)
    GC.strokeDraw('full', 2, text, 800, 500, 0, 1.26, 2, text:getWidth() / 2, text:getHeight() / 2)
    GC.setColor(.9, .9, .9)
    GC.mDraw(text, 800, 500, 0, 1.26, 2)
end

return scene
