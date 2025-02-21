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
        throbImg = GC.newImage('assets/' .. d.name .. '-throb.png'),
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
        visY = 0,

        touchCount = 0,
        burn = false,
        hintMark = false,
        charge = 0,
    }, Card)
    return obj
end

function Card:mouseOn(x, y)
    return
        abs(x - self.tx) <= self.size * 260 and
        abs(y - self.ty) <= self.size * 350
end

function Card:clearBuff()
    if GAME.mod.AS then self.burn = false end
    self.charge = 0
end

local KBIsDown = love.keyboard.isDown
local function tween_deckPress(t) DeckPress = 26 * (1 - t) end
function Card:setActive(auto, key)
    if GAME.mod.VL == 1 then
        if not self.active and not auto then
            self.charge = self.charge + 1
            SFX.play('clearline', .42)
            if self.charge < 1.2 then
                self:shake()
                SFX.play('combo_' .. math.random(2, 3), .626, 0, -2 + GAME.mod.GV)
                return
            end
            SFX.play('combo_4', .626, 0, GAME.mod.GV)
            self.charge = 0
        end
    elseif GAME.mod.VL == 2 then
        self.charge = self.charge + (auto and 2.6 or 1)
        if self.charge < 2.1 then
            SFX.play('clearline', .3)
            self:shake()
            if self.charge < 1.2 then
                SFX.play('combo_1', .626, 0, GAME.mod.GV)
            elseif MATH.roll() then
                SFX.play('combo_2', .626, 0, 1 + GAME.mod.GV)
            else
                SFX.play('combo_3', .626, 0, -2 + GAME.mod.GV)
            end
            return
        end
        if not auto then
            SFX.play('clearquad', .3)
            SFX.play('combo_4', .626, 0, GAME.mod.GV)
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
            if GAME.mod.NH > 0 and not self.active then
                GAME.cancelAll()
            end
            if GAME.mod.GV > 0 and GAME.firstClickDelay and not GAME.firstClickTimer then
                GAME.firstClickTimer = GAME.firstClickDelay
            end
            if GAME.mod.AS > 0 then
                if self.burn then
                    self.burn = false
                    TASK.removeTask_code(GAME.task_cancelAll)
                    local cards = TABLE.copy(Cards, 0)
                    TABLE.delete(cards, self)
                    for _ = 1, GAME.mod.AS == 1 and 2 or 4 do
                        TABLE.popRandom(cards):setActive(true)
                    end
                    SFX.play('wound')
                else
                    self.burn = GAME.mod.AS == 1 and 3 + GAME.floor / 2 or 1e99
                end
            end
        end
    else
        TASK.unlock('cannotStart')
        revOn = self.active and (KBIsDown('lctrl', 'rctrl') or key == 2) and TABLE.findAll(GAME.revUnlocked, true)
        if revOn then
            if not GAME.revUnlocked[self.id] then
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
        local wasRev = GAME.mod[self.id] == 2
        if wasRev and not revOn then
            self:spin()
        end
        GAME.mod[self.id] = self.active and (revOn and 2 or 1) or 0
        -- if revOn then
        --     for _, C in ipairs(Cards) do
        --         if C.active and C ~= self then
        --             C:setActive(true)
        --         end
        --     end
        -- end
        self.upright = not (self.active and revOn)
        if self.id == 'EX' then
            GAME.updateBgm('expertSwitched')
            TWEEN.new(function(t)
                GAME.exTimer = self.active and t or (1 - t)
            end):setDuration(self.active and .26 or .1):run()
        elseif self.id == 'NH' then
            BGM.set('piano', 'volume', self.active and (GAME.mod.NH == 2 and 0 or .26) or 1)
        elseif self.id == 'GV' then
            BGM.set('all', 'pitch', self.active and 2 ^ (GAME.mod.GV / 12) or 1, .26)
        elseif self.id == 'DH' then
            local W = SCN.scenes.main.widgetList.start
            W.text = self.active and 'COMMENCE' or 'START'
            W:reset()
        elseif self.id == 'IN' then
            BGM.set('all', 'highgain', self.active and (GAME.mod.IN == 2 and .65 or .8) or 1)
            for _, C in ipairs(Cards) do C:flip() end
            noSpin = GAME.mod.IN == 1
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
    GAME.refreshCurrentCombo()
    if not auto then -- Sound and animation
        if self.active then
            if revOn then
                SFX.play('card_select_reverse', 1, 0, GAME.mod.GV)
                SFX.play('card_tone_' .. self.name .. '_reverse', 1, 0, GAME.mod.GV)
                TASK.new(function()
                    TASK.yieldT(0.62)
                    local currentState = GAME.mod[self.id]
                    if currentState == 2 then
                        SFX.play('card_reverse_impact', 1, 0, GAME.mod.GV)
                        TWEEN.new(tween_deckPress):setUnique('DeckPress')
                            :setEase('OutQuad'):setDuration(.42):run()
                        for _, C in ipairs(Cards) do
                            if C ~= self then
                                local r = math.random()
                                if self.id == 'EX' then r = r * 2.6 end
                                C:bounce(MATH.lerp(62, 420, r), MATH.lerp(.42, .62, r))
                            end
                        end
                        table.insert(ImpactGlow, {
                            x = self.x,
                            y = self.y,
                            t = 2.6,
                        })
                    else
                        SFX.play('spin')
                        if currentState == 0 then
                            self:bounce(100, .26)
                        else
                            for _, C in ipairs(Cards) do
                                if C ~= self then
                                    local r = 1 - math.abs(C.initOrder - self.initOrder) / 8
                                    C:bounce(MATH.lerp(120, 420, r), MATH.lerp(.42, .62, r))
                                end
                            end
                        end
                    end
                end)
            else
                SFX.play('card_select')
                SFX.play('card_tone_' .. self.name, 1, 0, GAME.mod.GV)
            end
            if not noSpin then self:spin() end
            if revOn then self:bounce(1200, .62) end
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
        if GAME.mod.IN ~= 1 then
            self.ky = .9 + .1 * math.cos(t * 6.2832)
            self.r = t * 6.2832
            self.kx = math.cos((GAME.mod.AS + 1) * t * 6.2832)
        else
            self.kx = math.cos(t * 6.2832)
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
        :setEase(GAME.mod.IN == 1 and 'OutInQuart' or 'OutQuart')
        :setDuration(0.42):run()
end

local bounceEase = { 'linear', 'inQuad' }
function Card:bounce(height, duration)
    TWEEN.new(function(t)
        self.y = self.ty + t * (t - 1) * height
    end):setUnique('bounce_' .. self.id):setEase(bounceEase):setDuration(duration):run()
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
    self.y = MATH.expApproach(self.y, self.ty + (self.active and 1 or -1) * self.visY, dt * 16)
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

local GAME = GAME
local gc = love.graphics
local outlineShader = gc.newShader [[
vec4 effect(vec4 color, sampler2D tex, vec2 texCoord, vec2 scrCoord) {
    vec4 fragColor = texture2D(tex, texCoord);
    return vec4(color.rgb, color.a * fragColor.a);
}
]]
function Card:draw()
    local playing = GAME.playing
    local img, img2
    if self.lock and self.lockfull then
        img = self.lockfull
    else
        if GAME.mod.IN == 2 then
            img = self.backImg
        else
            img = self.kx * self.ky > 0 and self.frontImg or self.backImg
        end
        img2 = self.lock and self.lockover
    end

    gc.push('transform')
    gc.translate(self.x, self.y)
    gc.rotate(self.r)
    if not playing and not self.upright then gc.rotate(3.1416) end
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
    gc.setColor(
        self.burn and (
            GAME.time % .16 < .08 and COLOR.LF
            or COLOR.lY
        ) or COLOR.LL
    )
    gc.draw(img, -img:getWidth() / 2, -img:getHeight() / 2)
    if img2 then
        gc.draw(img2, -img2:getWidth() / 2, -img2:getHeight() / 2)
    end

    local r, g, b = 1, .26, 0
    if not playing and not self.upright then
        r, g, b = (1 - r) * .626, (1 - g) * .626, (1 - b) * .626
    end
    local a = 0

    if self.active then
        -- Active
        a = 1
        if playing and not self.hintMark and GAME.mod.IN < 2 then
            -- But wrong
            r, g, b = .4 + .1 * math.sin(GAME.time * 42 - self.x * .0026), 0, 0
        end
    elseif self.hintMark then
        -- Inactive but need
        r, g, b = 1, 1, 1
        local qt = GAME.questTime
        if GAME.mod.IN == 0 then
            if GAME.hardMode then qt = qt - 1.5 end
            a = MATH.clampInterpolate(1, 0, 2, .4, qt) +
                MATH.clampInterpolate(1.2, 0, 2.6, 1, qt) * .2 * math.sin(qt * 26 - self.x * .0026)
        elseif GAME.mod.IN == 1 then
            if GAME.hardMode then qt = qt * .626 end
            a = -.1 + .4 * math.sin(3.1416 + qt * 3)
        else
            a = 0
        end
    end
    if a > 0 then
        gc.setShader(outlineShader)
        gc.setColor(r, g, b, a)
        gc.draw(activeFrame, -activeFrame:getWidth() / 2, -activeFrame:getHeight() / 2)
        gc.setShader()
    end

    if not playing then
        if not self.upright and img == self.frontImg then
            gc.setColor(1, 1, 1, ThrobAlpha.card)
            gc.draw(self.throbImg, -self.throbImg:getWidth() / 2, -self.throbImg:getHeight() / 2)
        end
        if self.upright and GAME.revUnlocked[self.id] then
            gc.setColor(1, 1, 1)
            if FloatOnCard == self.initOrder then
                GC.blurCircle(-.26, 0, -330, 100)
                GC.mDraw(IMG.star1, 0, -330, nil, .3)
            else
                GC.mDraw(self.active and IMG.star1 or IMG.star0, 155, -370, nil, .15)
            end
        end
    end

    -- GC.mRect('line', 0, 0, 260 * 2, 350 * 2)
    gc.pop()
end

return Card
