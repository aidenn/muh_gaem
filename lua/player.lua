local bullet = require("lua/bullet")
local player = {}

function player:load()
    self.x = 50
    self.y = 50
    self.startX = self.x
    self.startY = self.y
    self.width = 8
    self.height = 16
    self.xVel = 0
    self.yVel = 0
    self.maxSpeed = 200
    self.acceleration = 4000
    self.friction = 3500
    self.gravity = 1500
    self.grounded = false
    self.graceTime = 0
    self.graceDuration = 0.05
    self.jumpAmount = -350
    self.secondJump = false
    self.scaleX = 1 -- direction (1: right, -1: left)
    self.state = "idle"
    self.airMod = 8 -- dampen direction change in air
    self.points = 0
    self.health = {current = 3, total = 3}
    self.alive = true

    self:loadAssets()

    self.physics = {}
    self.physics.body = love.physics.newBody(World, self.x, self.y, "dynamic")
    self.physics.body:setFixedRotation(true)
    self.physics.body:setGravityScale(0)
    self.physics.shape = love.physics.newRectangleShape(self.width, self.height)
    self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)
end

function player:loadAssets()
    self.animation = {timer = 0, rate = 0.1}
    self.animation.idle = {total = 2, current = 1, img = {}}
    self.animation.run  = {total = 2, current = 1, img = {}}
    self.animation.jump  = {total = 1, current = 1, img = {}}

    for i = 1, self.animation.idle.total do
        self.animation.idle.img[i] = love.graphics.newImage("assets/images/player_idle_"..i..".png")
    end

    for i = 1, self.animation.run.total do
        self.animation.run.img[i] = love.graphics.newImage("assets/images/player_run_"..i..".png")
    end

    for i = 1, self.animation.jump.total do
        self.animation.jump.img[i] = love.graphics.newImage("assets/images/player_jump_"..i..".png")
    end

    self.animation.draw = self.animation.idle.img[1]
    self.animation.width = self.animation.draw:getWidth()
    self.animation.height = self.animation.draw:getHeight()
end

function player:update(dt)
    if self.health.current <= 0 then
        self:die()
    end
    self:setState()
    self:animate(dt)
    self:decreaseGraceTime(dt)
    self:syncPhysics()
    self:applyGravity(dt)
    if self.grounded then
        self:applyFriction(dt)
    end
    self:move(dt)
    self:pewPew(dt)
end

function player:setState()
    if not self.grounded then
        self.state = "jump"
    elseif self.xVel == 0 then
        self.state = "idle"
    else
        self.state = "run"
    end
end

function player:animate(dt)
    self.animation.timer = self.animation.timer + dt
    if self.animation.timer > self.animation.rate then
        self.animation.timer = 0
        self:setNewFrame()
    end
end

function player:setNewFrame()
    local anim = self.animation[self.state]
    if anim.current < anim.total then
        anim.current = anim.current + 1
    else
        anim.current = 1
    end
    self.animation.draw = anim.img[anim.current]
end

function player:decreaseGraceTime(dt)
    if not self.grounded then
        self.graceTime = self.graceTime - dt
    end
end

function player:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
    self.physics.body:setLinearVelocity(self.xVel, self.yVel)
end

function player:applyGravity(dt)
    if not self.grounded then
        self.yVel = self.yVel + self.gravity * dt
    end
end

function player:applyFriction(dt)
    if self.xVel < 0 then
        self.xVel = math.min(self.xVel + self.friction * dt, 0)
    elseif self.xVel > 0 then
        self.xVel = math.max(self.xVel - self.friction * dt, 0)
    end
end

function player:move(dt)
    local am = 1
    if not self.grounded then
        am = self.airMod
    end
    if love.keyboard.isDown("a", "left") then
        self.scaleX = -1
        self.xVel = math.max(self.xVel - self.acceleration/am * dt, -self.maxSpeed)
    elseif love.keyboard.isDown("d", "right") then
        self.scaleX = 1
        self.xVel = math.min(self.xVel + self.acceleration/am * dt, self.maxSpeed)
    end
end

function player:pewPew(dt)
    if love.keyboard.isDown("j", "space") then
        if bullet:canShoot(dt) then
            bullet:new(self.x + 10 * self.scaleX, self.y + 4, self.scaleX, math.abs(self.xVel))
        end
    end
end

function player:jump(key)
    if (key == "w" or key == "up") then
        if self.grounded or self.graceTime > 0 then
            self.yVel = self.jumpAmount
            self.graceTime = 0
        elseif self.secondJump then
            self.secondJump = false
            self.yVel = self.jumpAmount * 0.85
        end
    end
end

function player:beginContact(a, b, collision)
    if self.grounded then return end
    local nx, ny = collision:getNormal()
    if a == self.physics.fixture then
        if ny > 0 then
            self:land(collision)
        elseif ny < 0 then
            self.yVel = 0
        end
    elseif b == self.physics.fixture then
        if ny < 0 then
            self:land(collision)
        elseif ny > 0 then
            self.yVel = 0
        end
    end
end

function player:endContact(a, b, collision)
    if a == self.physics.fixture or b == self.physics.fixture then
        if self.currentGroundCollision == collision then
            self.grounded = false
        end
    end
end

function player:land(collision)
    self.currentGroundCollision = collision
    self.yVel = 0
    self.grounded = true
    self.secondJump = true
    self.graceTime = self.graceDuration
end

function player:addPoints(number)
    self.points = self.points + number
end

function player:takeDamage(amount)
    self.health.current = math.max(0, self.health.current - amount)
end

function player:die()
    self.alive = false
    self:respawn()
end

function player:respawn()
    self.alive = true
    self:resetPosition()
    self.health.current = self.health.total
end

function player:resetPosition()
    self.physics.body:setPosition(self.startX, self.startY)
    self.xVel = 0
    self.yVel = 0
end

function player:draw()
    love.graphics.draw(self.animation.draw, self.x, self.y, 0, self.scaleX, 1, self.animation.width/2, self.animation.height/2)
end

return player