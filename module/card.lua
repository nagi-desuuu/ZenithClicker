local max, min = math.max, math.min
local abs, rnd = math.abs, math.random
local sin, cos = math.sin, math.cos
local sign, lerp = MATH.sign, MATH.lerp
local expApproach, clampInterpolate = MATH.expApproach, MATH.clampInterpolate

local M = GAME.mod
local CD = Cards

---@class Card
---@field burn false | number
---@field isCorrect false | number
local Card = {}
Card.__index = Card
function Card.new(d)
    ---@class Card
    local obj = setmetatable({
        initOrder = d.initOrder,
        tempOrder = d.initOrder,
        id = d.id,
        lockfull = d.lockfull,

        lock = true,
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
        visY1 = 0,

        float = 0,

        touchCount = 0,
        burn = false,
        isCorrect = false,
        charge = 0,
    }, Card)
    return obj
end

function Card:mouseOn(x, y)
    return
        abs(x - self.tx) <= self.size * 260 and
        abs(y - self.ty) <= self.size * 350
end

local completion = GAME.completion
local KBIsDown = love.keyboard.isDown
local function tween_deckPress(t) DeckPress = 26 * (1 - t) end
function Card:setActive(auto, key)
    if TASK.getLock('cannotFlip') or GAME.playing and M.NH == 1 and not auto and self.active then
        self:flick()
        SFX.play('no')
        return
    end
    if M.VL == 1 then
        if not self.active and not auto then
            self.charge = self.charge + 1
            SFX.play('clearline', .42)
            if self.charge < 1.2 then
                self:shake()
                SFX.play('combo_' .. rnd(2, 3), .626, 0, -2 + M.GV)
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

    if GAME.currentTask then
        if self.active then
            GAME.incrementPrompt('cancel')
            if not auto then GAME.nixPrompt('keep_no_cancel') end
        else
            GAME.incrementPrompt('activate')
        end
        if not auto then
            if self.id ~= GAME.lastFlip then
                GAME.nixPrompt('flip_single')
                GAME.lastFlip = self.id
            end
            GAME.incrementPrompt('flip_single')
        end
        GAME.incrementPrompt('flip')
    end

    local noSpin
    self.active = not self.active
    local revOn
    if GAME.playing then
        if not auto then
            self.touchCount = self.touchCount + 1
            GAME.totalFlip = GAME.totalFlip + 1
            if self.touchCount == 1 then
                if self.isCorrect == 1 and not GAME.hardMode then
                    GAME.addXP(1)
                end
            elseif not GAME.fault and not self.burn then
                GAME.fault = true
            end
        end
        if M.DP > 0 and not auto and self.id == 'DP' and self.active then
            if GAME.swapControl() then
                SFX.play('party_ready', .8, 0, M.GV)
            end
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
                    local p = TABLE.find(CD, self) or 0
                    local l = { -3, -2, -1, 1, 2, 3 }
                    CD[(p + table.remove(l, rnd(4, 6)) - 1) % #CD + 1]:setActive(true)
                    CD[(p + table.remove(l, rnd(1, 3)) - 1) % #CD + 1]:setActive(true)
                    if M.AS == 2 then
                        CD[(p + table.remove(l, rnd(3, 4)) - 1) % #CD + 1]:setActive(true)
                        CD[(p + table.remove(l, rnd(1, 2)) - 1) % #CD + 1]:setActive(true)
                        if GAME.floor < 10 and GAME.gigaspeed then GAME.achv_felMagicBurnt = true end
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
        revOn = self.active and (key == 2 or KBIsDown('lctrl', 'rctrl'))
        if revOn and completion[self.id] == 0 then
            revOn = false
            noSpin = true
            self.active = false
            self:shake()
            SFX.play('no')
            MSG.clear()
            MSG('dark', "Reach F10 with this mod first!")
            return
        end
        local wasRev = M[self.id] == 2
        M[self.id] = self.active and (revOn and 2 or 1) or 0
        -- if revOn then -- Limit only one Rev mod can be selected
        --     for _, C in ipairs(Cards) do
        --         if C.active and C ~= self then
        --             C:setActive(true)
        --         end
        --     end
        -- end
        self.upright = not (self.active and revOn)
        if wasRev and not revOn then self:spin() end
        if self.id == 'EX' then
            if M.EX == 0 then BGM.set('expert', 'volume', 0, .1) end
            TWEEN.new(function(t) GAME.exTimer = M.EX > 0 and t or (1 - t) end):setDuration(M.EX > 0 and .26 or .1):run()
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
            for _, C in ipairs(CD) do C:flip() end
            noSpin = M.IN == 1
        elseif self.id == 'AS' then
            local W = SCN.scenes.tower.widgetList.reset
            W.text = M.AS > 0 and 'SPIN' or 'RESET'
            W:reset()
        elseif self.id == 'DP' then
            BGM.set('violin2', 'volume', M.DP == 2 and 1 or 0, .26)
            BGM.set('piano2', 'volume', M.DP > 0 and .626 or 0, .26)
        end
        SCN.scenes.tower.widgetList.reset:setVisible(not GAME.zenithTraveler and M.NH < 2)
        if revOn or wasRev then GAME.refreshRev() end
        GAME.hardMode = M.EX > 0 or GAME.anyRev
        GAME.refreshPBText()
        GAME.refreshRPC()
    end
    GAME.refreshCurrentCombo()
    GAME.refreshLayout()
    if auto then
        if self.active and revOn then self:revJump() end
        return
    end

    -- Sound and animation
    if self.active then
        local postfix = revOn and '_reverse' or ''
        SFX.play('card_select' .. postfix, 1, 0,
            key and clampInterpolate(-200, -4.2, 200, 4.2, self.y - MY) or MATH.rand(-2.6, 2.6))
        SFX.play(
            'card_tone_' .. ModData.name[self.id] .. postfix,
            GAME.playing and .8 + GAME.floor * .02 - (GAME.gigaTime and .26 or 0) or 1,
            0, M.GV
        )
        if revOn then
            self:revJump()
        elseif not noSpin then
            self:spin()
        end
    else
        SFX.play('card_slide_' .. rnd(4))
    end
end

function Card:flip()
    TWEEN.tag_kill('shake' .. self.id)
    self.front = not self.front
    local s, e = self.kx, self.front and 1 or -1
    local rs = self.r % 6.2832
    TWEEN.new(function(t)
        self.kx = lerp(s, e, t)
        self.r = lerp(rs, 0, t)
    end):setUnique('spin_' .. self.id):setEase('OutQuad'):setDuration(0.26):run()
end

function Card:spin()
    TWEEN.tag_kill('shake' .. self.id)
    local animFunc, ease
    local re = (GAME.playing or self.upright) and 0 or 3.1416
    if M.IN ~= 1 then
        -- Normal
        ease = 'OutQuart'
        function animFunc(t)
            self.ky = .9 + .1 * cos(t * 6.2832)
            self.r = t * 6.2832
            self.kx = cos((M.AS + 1) * t * 6.2832)
            if not self.front then
                self.kx = -self.kx
            end
        end
    else
        -- Flip only
        ease = 'OutInQuart'
        local s = self.r % 6.2832
        function animFunc(t)
            self.kx = cos(t * 6.2832)
            self.r = lerp(s, re, t)
            if not self.front then
                self.kx = -self.kx
            end
        end
    end
    TWEEN.new(animFunc):setUnique('spin_' .. self.id):setEase(ease):setDuration(.42):run()
        :setOnKill(function()
            self.ky = 1
            self.r = re
            -- self.kx = self.front and 1 or -1
        end)
end

local bounceEase = { 'linear', 'inQuad' }
function Card:bounce(height, duration)
    TWEEN.tag_kill('shake' .. self.id)
    TWEEN.new(function(t)
        self.y = self.ty + t * (t - 1) * height
    end):setUnique('bounce_' .. self.id):setEase(bounceEase):setDuration(duration):run()
end

function Card:revJump()
    TWEEN.tag_kill('shake' .. self.id)
    TWEEN.new(function(t)
        t = t * (t - 1) * 4
        self.y = self.ty + t * 355
        self.size = .62 - .355 * t
    end):setUnique('revJump_' .. self.id):setEase(bounceEase):setDuration(.62):run()
        :setOnFinish(function()
            local currentState = M[self.id]
            if currentState == 2 then
                SFX.play('card_reverse_impact', 1, 0, M.GV)
                TWEEN.new(tween_deckPress):setUnique('DeckPress'):setEase('OutQuad'):setDuration(.42):run()
                if self.id ~= 'NH' then
                    for _, C in ipairs(CD) do
                        if C ~= self then
                            local r = rnd()
                            if self.id == 'EX' then r = r * 2.6 end
                            if self.id == 'MS' then r = max((r - .5) ^ .3333 / 1.5874 + .5, 0) end
                            if self.id == 'GV' then r = r * .26 end
                            C:bounce(lerp(62, 420, r), lerp(.42, .62, r))
                        end
                    end
                end
                local color = ModData.color[self.id]
                table.insert(ImpactGlow, {
                    r = (color[1] - .26) * .8,
                    g = (color[2] - .26) * .8,
                    b = (color[3] - .26) * .8,
                    x = self.x,
                    y = self.y,
                    t = 2.6,
                })
                GAME.revDeckSkin = true
                GAME.bgXdir = MATH.coin(-1, 1)
            else
                SFX.play('spin')
                if currentState == 0 then
                    self:bounce(100, .26)
                else
                    for _, C in ipairs(CD) do
                        if C ~= self then
                            local r = 1 - abs(C.initOrder - self.initOrder) / 8
                            if self.id == 'EX' then r = r * 2.6 end
                            if self.id == 'MS' then r = r * MATH.rand(.26, 1.26) end
                            if self.id == 'GV' then r = r * .26 end
                            C:bounce(lerp(120, 420, r), lerp(.42, .62, r))
                        end
                    end
                    IssueAchv('somersault')
                end
            end
        end)
    local s, e = self.kx, self.front and 1 or -1
    TWEEN.new(function(t)
        self.kx = lerp(s, e, t)
        self.r = (t - 1) * 3.1416
    end):setUnique('spin_' .. self.id):setEase('OutQuart'):setDuration(.52):run()
end

function Card:shake()
    local tag = 'shake' .. self.id
    TWEEN.tag_kill(tag)
    self.r = MATH.coin(-.26, .26)
    local s, e = self.r, 0
    TWEEN.new(function(t)
        self.r = lerp(s, e, t)
    end):setTag(tag):setEase('OutBack'):setDuration(0.26):run()
end

function Card:flick()
    TWEEN.new(function(t)
        self.size = lerp(.56, .62, t)
    end):setUnique('flick_' .. self.id):setEase('OutBack'):setDuration(0.26):run()
end

local activeFrame = GC.newImage('assets/card/outline.png')

function Card:update(dt)
    self.x = expApproach(self.x, self.tx, dt * 16)
    self.y = expApproach(self.y, self.ty, dt * 16)
    self.visY1 = expApproach(self.visY1, self.visY, dt * 26)
    self.float = expApproach(self.float, CD[FloatOnCard] == self and 1 or 0, dt * 12)
    if self.burn then
        self.burn = self.burn - dt
        if self.burn <= 0 then
            self.burn = false
            SFX.play('wound_repel')
        end
    end
    if self.charge > 0 then
        self.charge = max(self.charge - dt, 0)
    end
end

local GAME = GAME
local gc = love.graphics
local gc_push, gc_pop = gc.push, gc.pop
local gc_translate, gc_scale = gc.translate, gc.scale
local gc_rotate, gc_shear = gc.rotate, gc.shear
local gc_draw = gc.draw
local gc_setColor, gc_setShader = gc.setColor, gc.setShader
local gc_mDraw = GC.mDraw
local gc_blurCircle = GC.blurCircle

local Shader_Coloring = Shader_Coloring
function Card:draw()
    local texture = TEXTURE[self.id]
    local playing = GAME.playing
    local img, img2
    if self.lock and self.lockfull then
        img = texture.lock
    else
        if M.IN == 2 then
            img = texture.back
        else
            img = self.kx * self.ky > 0 and texture.front or texture.back
        end
        if self.lock then
            img2 = texture.lock
        end
    end

    gc_push('transform')
    gc_translate(self.x, self.y + self.visY1)
    gc_rotate(self.r)
    if not playing and not self.upright then gc_rotate(3.1416) end
    gc_scale(abs(self.size * self.kx), self.size * self.ky)

    if self == CD[FloatOnCard] then
        -- EX scale
        if M.EX > 0 and love.mouse.isDown(1, 2) then gc_scale(.9) end
        -- Fake 3D
        local dx, dy = (MX - self.x) / (260 * self.size), (MY - self.y) / (350 * self.size)
        local d = (abs(dx) - abs(dy)) * .026
        gc_scale(min(1, 1 - d), min(1, 1 + d))
        local D = -sign(dx * dy) * abs(dx * dy) ^ .626 * .026
        gc_shear(D, D)
        gc_scale(1 - abs(D))
    end

    -- Draw card
    if self.burn then
        gc_setColor(
            self.burn and (
                GAME.time % .16 < .08 and COLOR.LF
                or COLOR.lY
            ) or COLOR.LL
        )
    else
        local b = STAT.cardBrightness / 100
        gc_setColor(b, b, b)
    end
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
        if playing and not self.isCorrect and M.IN < 2 then
            -- But wrong
            a = 1
            r, g, b = .4 + .1 * sin(GAME.time * 42 - self.x * .0026), 0, 0
        else
            a = .6 + .4 * self.float
            if self.isCorrect == 2 and M.IN < 2 then
                -- Second quest!
                r, g, b = .942, .626, .872
            end
        end
    elseif self.isCorrect == 1 then
        -- Inactive but need
        r, g, b = 1, 1, 1
        local qt = GAME.questTime
        if M.IN == 0 then
            if GAME.hardMode then qt = qt - 1.5 end
            a = clampInterpolate(1, 0, 2, .4, qt) +
                clampInterpolate(1.2, 0, 2.6, 1, qt) * .2 * sin(qt * 26 - self.x * .0026)
        elseif M.IN == 1 then
            if GAME.hardMode then qt = qt * .626 end
            a = -.1 + .4 * sin(3.1416 + qt * 3)
        else
            a = 0
        end
    end
    if a > 0 then
        gc_setShader(Shader_Coloring)
        gc_setColor(r, g, b, a)
        gc_draw(activeFrame, -activeFrame:getWidth() / 2, -activeFrame:getHeight() / 2)
        gc_setShader()
    end

    if not playing then
        if not self.upright and GAME.revDeckSkin and img == texture.front then
            gc_setColor(1, 1, 1, ThrobAlpha.card)
            gc_draw(texture.throb, -texture.throb:getWidth() / 2, -texture.throb:getHeight() / 2)
        end
        if completion[self.id] > 0 then
            img = self.active and TEXTURE.star1 or TEXTURE.star0
            local t = self.upright and self.float or 1
            local blur = (FloatOnCard == self.initOrder or not self.upright) and 0 or -.2
            local x = lerp(155, 0, t)
            local y = lerp(-370, -330, t)
            local cr = lerp(.16, .42, t)
            local revMastery = completion[self.id] == 2
            local ang = -t * 6.2832
            gc_scale(abs(1 / self.kx * self.ky), 1)
            -- Base star
            if self.upright then
                if revMastery then
                    gc_setColor(.5, .5, .5)
                    gc_blurCircle(blur, -x, -y, cr * 260)
                    gc_setColor(1, 1, 1)
                    gc_mDraw(img, -x, -y, ang, lerp(.16, .42, t))
                end
                gc_setColor(.5, .5, .5)
                gc_blurCircle(blur, x, y, cr * 260)
                gc_setColor(1, 1, 1)
                gc_mDraw(img, x, y, ang, lerp(.16, .42, t))
            else
                if revMastery then
                    gc_setColor(.2, .2, .2)
                    gc_blurCircle(blur, -x, -y, cr * 260)
                    gc_setColor(1, .7 + .15 * sin(love.timer.getTime() * 62 + self.x), .2)
                    gc_mDraw(img, -x, -y, ang, lerp(.16, .42, t))
                end
                gc_setColor(.2, .2, .2)
                gc_blurCircle(blur, x, y, cr * 260)
                gc_setColor(1, .7 + .15 * sin(love.timer.getTime() * 62 + self.x), .2)
                gc_mDraw(img, x, y, ang, lerp(.16, .42, t))
            end
            -- Float star
            if not self.active then
                if revMastery then
                    gc_setColor(.5, .5, .5, t)
                    gc_blurCircle(blur, -x, -y, cr * 260)
                    gc_setColor(1, 1, 1, t)
                    gc_mDraw(TEXTURE.star1, -x, -y, ang, lerp(.16, .42, t))
                    gc_mDraw(TEXTURE.star1, x, y, ang, lerp(.16, .42, t))
                else
                    gc_setColor(1, 1, 1, t)
                    gc_mDraw(TEXTURE.star1, x, y, ang, lerp(.16, .42, t))
                end
            end
        end
    end

    -- Debug
    -- if not self.upright then gc_rotate(3.1416) end
    -- gc_setColor(ModData.color[self.id])
    -- gc.rectangle('fill', 260, -350, -60, 60)
    -- gc_setColor(1, 1, 1)
    -- gc.setLineWidth(2)
    -- GC.mRect('line', 0, 0, 260 * 2, 350 * 2)
    -- FONT.set(30)
    -- gc.print(self.upright and self.id or "r" .. self.id, -260, -450)
    -- gc.print("r = " .. MATH.round(self.r / 3.1416 * 180), -260, -420)

    gc_pop()
end

return Card
