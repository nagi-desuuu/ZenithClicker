local abs = math.abs


---@class Card
---@field burn false | number
local Card = {}
Card.__index = Card
function Card.new(d)
    ---@class Card
    local obj = setmetatable({
        initOrder = d.initOrder,
        id = d.id,
        name = d.name,
        fullName = d.fullName,
        desc = d.desc,
        revName = d.revName,
        revDesc = d.revDesc,

        frontImg = GC.newImage('assets/' .. d.name .. '.png'),
        backImg = GC.newImage('assets/' .. d.name .. '-back.png'),
        lockfull = d.lockfull and GC.newImage('assets/' .. d.lockfull .. '.png'),
        lockover = d.lockover and GC.newImage('assets/' .. d.lockover .. '.png'),

        lock = false,
        active = false,
        front = true,
        upright = true,

        x = 0,
        y = 0,
        kx = 1,
        ky = 1,
        size = .62,
        r = 0,
        tx = 0,
        ty = 0,

        touchCount = 0,
        burn = false,
        hintMark = false,
        charge = 0,
    }, Card)
    return obj
end

function Card:mouseOn(x, y)
    return
        abs(x - self.x) <= self.size * 260 and
        abs(y - self.y) <= self.size * 350
end

function Card:clearBuff()
    if GAME.mod_AS then self.burn = false end
    self.charge = 0
end

function Card:setActive(auto)
    if GAME.mod_VL == 1 then
        if not self.active and not auto then
            self.charge = self.charge + 1
            SFX.play('clearline', .42)
            if self.charge < 1.2 then
                self:shake()
                SFX.play('combo_' .. math.random(2, 3), .626, 0, -2 + GAME.mod_GV)
                return
            end
            SFX.play('combo_4', .626, 0, GAME.mod_GV)
            self.charge = 0
        end
    elseif GAME.mod_VL == 2 then
        self.charge = self.charge + (auto and 2.6 or 1)
        if self.charge < 2.1 then
            SFX.play('clearline', .3)
            self:shake()
            if self.charge < 1.2 then
                SFX.play('combo_1', .626, 0, GAME.mod_GV)
            elseif MATH.roll() then
                SFX.play('combo_2', .626, 0, 1 + GAME.mod_GV)
            else
                SFX.play('combo_3', .626, 0, -2 + GAME.mod_GV)
            end
            return
        end
        if not auto then
            SFX.play('clearquad', .3)
            SFX.play('combo_4', .626, 0, GAME.mod_GV)
        end
        self.charge = 0
    end
    local noSpin
    self.active = not self.active
    local revOn
    if GAME.playing then
        self.touchCount = self.touchCount + 1
        if self.touchCount == 1 then
            if self.hintMark then
                GAME.addXP(1)
            end
        elseif self.touchCount == 2 then
            GAME.fault = true
        end
        if not auto then
            if GAME.mod_NH > 0 and not self.active then
                GAME.cancelAll()
            end
            if GAME.mod_GV > 0 and GAME.firstClickDelay and not GAME.firstClickTimer then
                GAME.firstClickTimer = GAME.firstClickDelay
            end
            if GAME.mod_AS > 0 then
                if self.burn then
                    self.burn = false
                    TASK.removeTask_code(GAME.task_cancelAll)
                    local cards = TABLE.copy(Cards, 0)
                    TABLE.delete(cards, self)
                    for _ = 1, GAME.mod_AS == 1 and 2 or 4 do
                        TABLE.popRandom(cards):setActive(true)
                    end
                    SFX.play('wound')
                else
                    self.burn = GAME.mod_AS == 1 and 3 + GAME.floor / 2 or 1e99
                end
            end
        end
    else
        TASK.unlock('cannotStart')
        revOn = self.active and love.keyboard.isDown('lctrl', 'rctrl')
        if revOn then
            local completed = (DATA.highScore[self.id] or 0) >= 1650
            if not completed then
                for k, v in next, DATA.highScore do
                    if v >= 1650 and (k:gsub('r', ''):find(self.id) or 0) % 2 == 1 then
                        completed = true
                        break
                    end
                end
            end
            if not completed then
                revOn = false
                noSpin = true
                self.active = false
                self:shake()
                SFX.play('no')
                MSG.clear()
                MSG('dark', "Reach F10 with this mod to Unlock Reversed Mod")
                return
            end
        end
        local wasRev = GAME['mod_' .. self.id] == 2
        GAME['mod_' .. self.id] = self.active and (revOn and 2 or 1) or 0
        -- if revOn then
        --     for _, C in ipairs(Cards) do
        --         if C.active and C ~= self then
        --             C:setActive(true)
        --         end
        --     end
        -- end
        self.upright = not (self.active and revOn)
        if self.id == 'EX' then
            TWEEN.new(function(t)
                GAME.exTimer = self.active and t or (1 - t)
            end):setDuration(self.active and .26 or .1):run()
        elseif self.id == 'NH' then
            BGM.set('piano', 'volume', self.active and (GAME.mod_NH == 2 and 0 or .26) or 1)
        elseif self.id == 'GV' then
            BGM.set('all', 'pitch', self.active and 2 ^ (GAME.mod_GV / 12) or 1, .26)
        elseif self.id == 'DH' then
            local W = SCN.scenes.main.widgetList.start
            W.text = self.active and 'COMMENCE' or 'START'
            W:reset()
        elseif self.id == 'IN' then
            BGM.set('all', 'highgain', self.active and (GAME.mod_IN == 2 and .65 or .8) or 1)
            for _, C in ipairs(Cards) do C:flip() end
            noSpin = true
        elseif self.id == 'AS' then
            local W = SCN.scenes.main.widgetList.reset
            W.text = self.active and 'SPIN' or 'RESET'
            W:reset()
        end
        GAME.refreshPBText()
        if revOn or wasRev then
            GAME.refreshRev()
        end
    end
    GAME.refreshComboText()
    if not auto then -- Sound and animation
        if self.active then
            if revOn then
                SFX.play('card_select_reverse', 1, 0, GAME.mod_GV)
                SFX.play('card_tone_' .. self.name .. '_reverse', 1, 0, GAME.mod_GV)
                TASK.new(function()
                    TASK.yieldT(0.3)
                    SFX.play('card_reverse_impact', 1, 0, GAME.mod_GV)
                end)
                if not noSpin then self:spin() end
            else
                SFX.play('card_select')
                SFX.play('card_tone_' .. self.name, 1, 0, GAME.mod_GV)
                if not noSpin then self:spin() end
            end
        else
            SFX.play('card_slide_' .. math.random(4))
        end
    end
    GAME.refreshLayout()
end

function Card:flip()
    self.front = not self.front
    local s, e = self.kx, self.front and 1 or -1
    TWEEN.new(function(t)
        self.kx = MATH.lerp(s, e, t)
    end):setUnique('spin_' .. self.id):setEase('OutQuad'):setDuration(0.26):run()
end

function Card:spin()
    TWEEN.new(function(t)
        if GAME.mod_IN == 0 then
            self.ky = .9 + .1 * math.cos(t * 6.2831853)
            self.r = t * 6.2831853
            self.kx = math.cos((GAME.mod_AS + 1) * t * 6.2831853)
        else
            self.kx = math.cos(t * 6.2831853)
        end
        if not self.front then
            self.kx = -self.kx
        end
    end):setUnique('spin_' .. self.id)
        :setOnKill(function()
            self.ky = 1
            self.r = 0
            -- self.kx = self.front and 1 or -1
        end)
        :setEase(GAME.mod_IN > 0 and 'OutInQuart' or 'OutQuart')
        :setDuration(0.42):run()
end

function Card:shake()
    self.r = MATH.coin(-.26, .26)
    local s, e = self.r, 0
    TWEEN.new(function(t)
        self.r = MATH.lerp(s, e, t)
    end):setUnique('shake_' .. self.id):setEase('OutBack'):setDuration(0.26):run()
end

function Card:flick()
    TWEEN.new(function(t)
        self.size = MATH.lerp(.56, .62, t)
    end):setUnique('flick_' .. self.id):setEase('OutBack'):setDuration(0.26):run()
end

local activeFrame = GC.newImage('assets/outline.png')

function Card:update(dt)
    self.x = MATH.expApproach(self.x, self.tx, dt * 16)
    self.y = MATH.expApproach(self.y, self.ty, dt * 16)
    if self.burn then
        self.burn = self.burn - dt
        if self.burn <= 0 then
            self.burn = false
            SFX.play('wound_repel')
        end
    end
    if self.charge > 0 then
        self.charge = math.max(self.charge - dt, 0)
    end
end

local gc = love.graphics
local outlineShader = gc.newShader [[
vec4 effect(vec4 color, sampler2D tex, vec2 texCoord, vec2 scrCoord) {
    vec4 fragColor = texture2D(tex, texCoord);
    return vec4(color.rgb, color.a * fragColor.a);
}
]]
function Card:draw()
    local img, img2
    if self.lock and self.lockfull then
        img = self.lockfull
    else
        if GAME.mod_IN == 2 then
            img = self.backImg
        else
            img = self.kx * self.ky > 0 and self.frontImg or self.backImg
        end
        img2 = self.lock and self.lockover
    end

    gc.push('transform')
    gc.translate(self.x, self.y)
    gc.rotate(self.r)
    if not GAME.playing and not self.upright then gc.rotate(3.1416) end
    gc.scale(abs(self.size * self.kx), self.size * self.ky)

    -- Fake 3D
    if self == Cards[FloatOnCard] then
        local dx, dy = (MX - self.x) / (260 * self.size), (MY - self.y) / (350 * self.size)
        local d = (abs(dx) - abs(dy)) * .026
        gc.scale(math.min(1, 1 - d), math.min(1, 1 + d))
        local D = -MATH.sign(dx * dy) * abs(dx * dy) ^ .626 * .026
        gc.shear(D, D)
        gc.scale(1 - abs(D))
    end

    -- Draw card
    GC.setColor(
        self.burn and (
            GAME.time % .16 < .08 and COLOR.LF
            or COLOR.lY
        ) or COLOR.LL
    )
    GC.draw(img, -img:getWidth() / 2, -img:getHeight() / 2)
    if img2 then
        GC.draw(img2, -img2:getWidth() / 2, -img2:getHeight() / 2)
    end

    local r, g, b = 1, .26, 0
    local a = 0

    if self.active then
        -- Active
        a = 1
        if GAME.playing and not self.hintMark and GAME.mod_IN < 2 then
            -- But wrong
            r, g, b = .4 + .1 * math.sin(GAME.time * 42 - self.x * .0026), 0, 0
        end
    elseif self.hintMark then
        -- Inactive but need
        r, g, b = 1, 1, 1
        local qt = GAME.questTime
        if GAME.mod_IN == 0 then
            if GAME.mod_EX > 0 then qt = qt - 1.5 end
            a = MATH.clampInterpolate(1, 0, 2, .4, qt) +
                MATH.clampInterpolate(1.2, 0, 2.6, 1, qt) * .2 * math.sin(qt * 26 - self.x * .0026)
        elseif GAME.mod_IN == 1 then
            if GAME.mod_EX > 0 then qt = qt * .626 end
            a = -.1 + .4 * math.sin(3.1416 + qt * 3)
        else
            a = 0
        end
    end
    if a > 0 then
        GC.setShader(outlineShader)
        GC.setColor(r, g, b, a)
        GC.draw(activeFrame, -activeFrame:getWidth() / 2, -activeFrame:getHeight() / 2)
        GC.setShader()
    end

    -- GC.mRect('line',0,0,260*2,350*2)
    gc.pop()
end

return Card
