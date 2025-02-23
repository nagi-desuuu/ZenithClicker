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

        float = 0,

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

local KBIsDown = love.keyboard.isDown
local function tween_deckPress(t) DeckPress = 26 * (1 - t) end
function Card:setActive(auto, key)
    if TASK.getLock('cannotFlip') then
        SFX.play('no')
        return
    end
    local M = GAME.mod
    if M.VL == 1 then
        if not self.active and not auto then
            self.charge = self.charge + 1
            SFX.play('clearline', .42)
            if self.charge < 1.2 then
                self:shake()
                SFX.play('combo_' .. math.random(2, 3), .626, 0, -2 + M.GV)
                return
            end
            SFX.play('combo_4', .626, 0, M.GV)
            self.charge = 0
        end
    elseif M.VL == 2 then
        self.charge = self.charge + (auto and 3.55 or 1)
        if self.charge < 3.1 then
            SFX.play('clearline', .3)
            self:shake()
            if self.charge < 1.3 then
                SFX.play('combo_1', .626, 0, M.GV)
            elseif self.charge < 2.2 then
                SFX.play('combo_3', .626, 0, -2 + M.GV)
            else
                SFX.play('combo_2', .626, 0, 1 + M.GV)
            end
            return
        end
        if not auto then
            SFX.play('clearquad', .3)
            SFX.play('combo_4', .626, 0, M.GV)
        end
        self.charge = 0
    end
    local noSpin
    self.active = not self.active
    local revOn
    if GAME.playing then
        self.touchCount = self.touchCount + 1
        if self.touchCount == 1 then
            if self.hintMark and not GAME.hardMode then
                GAME.addXP(1)
            end
        elseif self.touchCount == 2 then
            GAME.fault = true
        end
        if not auto then
            if M.GV > 0 and not GAME.gravTimer then
                GAME.gravTimer = GAME.gravDelay
            end
            local ignite
            if M.AS > 0 then
                if self.burn then
                    ignite = true
                    self.burn = false
                    TASK.removeTask_code(GAME.task_cancelAll)
                    local cards = TABLE.copy(Cards, 0)
                    TABLE.delete(cards, self)
                    for _ = 1, M.AS == 1 and 2 or 4 do
                        TABLE.popRandom(cards):setActive(true)
                    end
                    SFX.play('wound')
                else
                    self.burn = M.AS == 1 and 3 + GAME.floor / 2 or 1e99
                end
            end
            if not ignite and M.NH == 1 and not self.active then
                if M.AS > 0 then
                    auto = true
                    self.active = not self.active
                end
                GAME.cancelAll()
            end
        end
    else
        TASK.unlock('cannotStart')
        revOn = self.active and (KBIsDown('lctrl', 'rctrl') or key == 2) and TABLE.findAll(GAME.completion, 1)
        if revOn then
            if GAME.completion[self.id] == 0 then
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
        local wasRev = M[self.id] == 2
        if wasRev and not revOn then
            self:spin()
        end
        M[self.id] = self.active and (revOn and 2 or 1) or 0
        -- if revOn then -- Limit only one Rev mod can be selected
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
                GAME.exTimer = M.EX > 0 and t or (1 - t)
            end):setDuration(M.EX > 0 and .26 or .1):run()
        elseif self.id == 'NH' then
            BGM.set('piano', 'volume', M.NH == 0 and 1 or M.NH == 1 and .26 or 0)
        elseif self.id == 'GV' then
            local v = M.GV > 0 and 2 ^ (M.GV / 12) or 1
            BGM.set('all', 'pitch', v, .26)
            BGM.set('piano2', 'pitch', 2 * v, .26)
        elseif self.id == 'DH' then
            local W = SCN.scenes.tower.widgetList.start
            W.text = M.DH > 0 and 'COMMENCE' or 'START'
            W:reset()
        elseif self.id == 'IN' then
            BGM.set('all', 'highgain', M.IN == 0 and 1 or M.IN == 1 and .8 or .65)
            for _, C in ipairs(Cards) do C:flip() end
            noSpin = M.IN == 1
        elseif self.id == 'AS' then
            local W = SCN.scenes.tower.widgetList.reset
            W.text = M.AS > 0 and 'SPIN' or 'RESET'
            W:reset()
        elseif self.id == 'DP' then
            BGM.set('violin2', 'volume', M.DP == 2 and 1 or 0, .26)
            BGM.set('piano2', 'volume', M.DP > 0 and 1 or 0, .26)
        end
        GAME.refreshPBText()
        if revOn or wasRev then
            GAME.refreshRev()
        end
        HeightText:set("")
        TimeText:set("")
    end
    GAME.refreshCurrentCombo()
    GAME.refreshLayout()
    if auto then return end

    -- Sound and animation
    if not self.active then
        SFX.play('card_slide_' .. math.random(4))
        return
    end
    if revOn then
        SFX.play('card_select_reverse', 1, 0, M.GV)
        SFX.play('card_tone_' .. self.name .. '_reverse', 1, 0, M.GV)
        TASK.new(function()
            TASK.yieldT(0.62)
            local currentState = M[self.id]
            if currentState == 2 then
                SFX.play('card_reverse_impact', 1, 0, M.GV)
                TWEEN.new(tween_deckPress):setUnique('DeckPress')
                    :setEase('OutQuad'):setDuration(.42):run()
                for _, C in ipairs(Cards) do
                    if C ~= self then
                        local r = math.random()
                        if self.id == 'EX' then r = r * 2.6 end
                        C:bounce(MATH.lerp(62, 420, r), MATH.lerp(.42, .62, r))
                    end
                end
                local color = Mod.color[self.id]
                table.insert(ImpactGlow, {
                    r = (color[1] - .26) * .8,
                    g = (color[2] - .26) * .8,
                    b = (color[3] - .26) * .8,
                    x = self.x,
                    y = self.y,
                    t = 2.6,
                })
                GAME.revDeckSkin = true
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
        SFX.play('card_tone_' .. self.name, 1, 0, M.GV)
    end
    if not noSpin then self:spin() end
    if revOn then self:bounce(1200, .62) end
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
    self.float = MATH.expApproach(self.float, Cards[FloatOnCard] == self and 1 or 0, dt * 12)
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
local gc_push, gc_pop = gc.push, gc.pop
local gc_translate, gc_scale = gc.translate, gc.scale
local gc_rotate, gc_shear = gc.rotate, gc.shear
local gc_draw = gc.draw
local gc_setColor, gc_setShader = gc.setColor, gc.setShader

local outlineShader = gc.newShader [[vec4 effect(vec4 color, sampler2D tex, vec2 texCoord, vec2 scrCoord) {return vec4(color.rgb, color.a * texture2D(tex, texCoord).a);}]]
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

    gc_push('transform')
    gc_translate(self.x, self.y)
    gc_rotate(self.r)
    if not playing and not self.upright then gc_rotate(3.1416) end
    gc_scale(abs(self.size * self.kx), self.size * self.ky)

    -- Fake 3D
    if self == Cards[FloatOnCard] then
        local dx, dy = (MX - self.x) / (260 * self.size), (MY - self.y) / (350 * self.size)
        local d = (abs(dx) - abs(dy)) * .026
        gc_scale(math.min(1, 1 - d), math.min(1, 1 + d))
        local D = -MATH.sign(dx * dy) * abs(dx * dy) ^ .626 * .026
        gc_shear(D, D)
        gc_scale(1 - abs(D))
    end

    -- Draw card
    gc_setColor(
        self.burn and (
            GAME.time % .16 < .08 and COLOR.LF
            or COLOR.lY
        ) or COLOR.LL
    )
    gc_draw(img, -img:getWidth() / 2, -img:getHeight() / 2)
    if img2 then
        gc_draw(img2, -img2:getWidth() / 2, -img2:getHeight() / 2)
    end

    local r, g, b = 1, .26, 0
    if not playing and not self.upright then
        r, g, b = (1 - r) * .626, (1 - g) * .626, (1 - b) * .626
    end
    local a = 0

    if self.active then
        -- Active
        if playing and not self.hintMark and GAME.mod.IN < 2 then
            -- But wrong
            a = 1
            r, g, b = .4 + .1 * math.sin(GAME.time * 42 - self.x * .0026), 0, 0
        else
            a = .6 + .4 * self.float
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
        gc_setShader(outlineShader)
        gc_setColor(r, g, b, a)
        gc_draw(activeFrame, -activeFrame:getWidth() / 2, -activeFrame:getHeight() / 2)
        gc_setShader()
    end

    if not playing then
        if not self.upright and GAME.revDeckSkin and img == self.frontImg then
            gc_setColor(1, 1, 1, ThrobAlpha.card)
            gc_draw(self.throbImg, -self.throbImg:getWidth() / 2, -self.throbImg:getHeight() / 2)
        end
        if GAME.completion[self.id] > 0 then
            img = self.active and IMG.star1 or IMG.star0
            local t = self.upright and self.float or 1
            local blur = (FloatOnCard == self.initOrder or not self.upright) and 0 or -.2
            local x = MATH.lerp(155, 0, t)
            local y = MATH.lerp(-370, -330, t)
            local cr = MATH.lerp(.16, .42, t)
            gc_scale(math.abs(1 / self.kx), 1)
            if self.upright then
                gc_setColor(.5, .5, .5)
                GC.blurCircle(blur, x, y, cr * 260)
                gc_setColor(1, 1, 1)
                GC.mDraw(img, x, y, -t * 6.2832, MATH.lerp(.16, .42, t))
            else
                gc_rotate(3.1416)
                gc_setColor(.2, .2, .2)
                GC.blurCircle(blur, x, y, cr * 260)
                gc_setColor(1, .7 + .15 * math.sin(love.timer.getTime() * 62 + self.x), .2)
                GC.mDraw(img, x, y, -t * 6.2832, MATH.lerp(.16, .42, t))
            end
            if not self.active then
                gc_setColor(1, 1, 1, t)
                GC.mDraw(IMG.star1, x, y, -t * 6.2832, MATH.lerp(.16, .42, t))
            end
        end
    end

    -- gc_setColor(ModColor[self.id])
    -- gc.rectangle('fill', 260, -350, -60, 60)
    -- gc_setColor(1, 1, 1)
    -- gc_setLineWidth(2)
    -- GC.mRect('line', 0, 0, 260 * 2, 350 * 2)
    gc_pop()
end

return Card
