local map_01 = require "maps.map_01"
Player = {}

function Player:load()
    self.x = 50
    self.y = 50
    self.width = 12
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
    self.scaleX = 1 -- direction (right)
    self.state = "idle"

    self:loadAssets()

    self.physics = {}
    self.physics.body = love.physics.newBody(World, self.x, self.y, "dynamic")
    self.physics.body:setFixedRotation(true)
    self.physics.shape = love.physics.newRectangleShape(self.width, self.height)
    self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)
end

function Player:loadAssets()
    self.animation = {timer = 0, rate = 0.1}
    self.animation.idle = {total = 2, current = 1, img = {}}
    self.animation.run  = {total = 2, current = 1, img = {}}
    self.animation.jump  = {total = 1, current = 1, img = {}}

    for i = 1, self.animation.idle.total do
        self.animation.idle.img[i] = love.graphics.newImage("assets/player_idle_"..i..".png")
    end

    for i = 1, self.animation.run.total do
        self.animation.run.img[i] = love.graphics.newImage("assets/player_run_"..i..".png")
    end

    for i = 1, self.animation.jump.total do
        self.animation.jump.img[i] = love.graphics.newImage("assets/player_jump_"..i..".png")
    end

    self.animation.draw = self.animation.idle.img[1]
    self.animation.width = self.animation.draw:getWidth()
    self.animation.height = self.animation.draw:getHeight()
end

function Player:update(dt)
    self:setState()
    self:animate(dt)
    self:decreaseGraceTime(dt)
    self:syncPhysics()
    -- self:checkBoundaries()
    self:applyGravity(dt)
    if self.grounded then
        self:applyFriction(dt)
    end
    self:move(dt)
end

function Player:animate(dt)
    self.animation.timer = self.animation.timer + dt
    if self.animation.timer > self.animation.rate then
        self.animation.timer = 0
        self:setNewFrame()
    end
end

function Player:setState()
    if not self.grounded then
        self.state = "jump"
    elseif self.xVel == 0 then
        self.state = "idle"
    else
        self.state = "run"
    end
end

function Player:setNewFrame()
    local anim = self.animation[self.state]
    if anim.current < anim.total then
        anim.current = anim.current + 1
    else
        anim.current = 1
    end
    self.animation.draw = anim.img[anim.current]
end

function Player:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
    self.physics.body:setLinearVelocity(self.xVel, self.yVel)
end

function Player:move(dt)
    if love.keyboard.isDown("a", "left") then
        self.scaleX = -1
        if self.xVel > -self.maxSpeed then
            if self.xVel - self.acceleration * dt > -self.maxSpeed then
                if self.grounded then
                    self.xVel = self.xVel - self.acceleration * dt
                else
                    self.xVel = self.xVel - self.acceleration/8 * dt
                end
            else
                self.xVel = -self.maxSpeed
            end
        end
    elseif love.keyboard.isDown("d", "right") then
        self.scaleX = 1
        if self.xVel < self.maxSpeed then
            if self.xVel + self.acceleration * dt < self.maxSpeed then
                if self.grounded then
                    self.xVel = self.xVel + self.acceleration * dt
                else
                    self.xVel = self.xVel + self.acceleration/8 * dt
                end
            else
                self.xVel = self.maxSpeed
            end
        end
    end
end

function Player:jump(key)
    if (key == "w" or key == "up") then
        if self.grounded or self.graceTime > 0 then
            self.yVel = self.jumpAmount
            self.graceTime = 0
        elseif self.secondJump then
            self.secondJump = false
            self.yVel = self.jumpAmount * 0.75
        end
    end
end

function Player:decreaseGraceTime(dt)
    if not self.grounded then
        self.graceTime = self.graceTime - dt
    end
end

function Player:applyGravity(dt)
    if not self.grounded then
        self.yVel = self.yVel + self.gravity * dt
    end
end

function Player:applyFriction(dt)
    if self.xVel < 0 then
        if self.xVel + self.friction * dt < 0 then
            self.xVel = self.xVel + self.friction * dt
        else
            self.xVel = 0
        end
    elseif self.xVel > 0 then
        if self.xVel - self.friction * dt > 0 then
            self.xVel = self.xVel - self.friction * dt
        else
            self.xVel = 0
        end
    end

end

function Player:checkBoundaries()
    if self.x < 0 then
        self.x = 0
    elseif self.x + self.width > ScreenWidth/Scale then
        self.x = ScreenWidth/Scale - self.width
    end
end

function Player:beginContact(a, b, collision)
    if self.grounded then return end
    local nx, ny = collision:getNormal()
    if a == self.physics.fixture then
        if ny > 0 then
            self:land(collision)
        end
    elseif b == self.physics.fixture then
        if ny < 0 then
            self:land(collision)
        end
    end
end

function Player:endContact(a, b, collision)
    if a == self.physics.fixture or b == self.physics.fixture then
        if self.currentGroundCollision == collision then
            self.grounded = false
        end
    end
end

function Player:land(collision)
    self.currentGroundCollision = collision
    self.yVel = 0
    self.grounded = true
    self.secondJump = true
    self.graceTime = self.graceDuration
end

function Player:draw()
    love.graphics.draw(self.animation.draw, self.x, self.y, 0, self.scaleX, 1, self.animation.width/2, self.animation.height/2)
end
