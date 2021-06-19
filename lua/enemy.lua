local player = require("lua/player")
local enemy = {}
enemy.__index = enemy
local activeEnemies = {}

function enemy:new(x, y)
    local instance = setmetatable({}, enemy)
    instance.x = x
    instance.y = y
    instance.r = 0
    instance.width = 16
    instance.height = 32
    instance.scaleX = 1 -- direction (1: right, -1: left)
    instance.state = "idle"
    instance.toRemove = false
    instance.damage = 1
    instance.speed = 50
    instance.xVel = 0
    instance.yVel = instance.speed

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "kinematic")
    instance.physics.shape = love.physics.newRectangleShape(instance.width, instance.height)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    table.insert(activeEnemies, instance)
end

function enemy:loadAssets()
    self.animation = {timer = 0, rate = 0.1}
    self.animation.idle = {total = 1, current = 1, img = {}}

    for i = 1, self.animation.idle.total do
        self.animation.idle.img[i] = love.graphics.newImage("assets/images/enemy_idle_"..i..".png")
    end

    self.animation.draw = self.animation.idle.img[1]
    self.animation.width = self.animation.draw:getWidth()
    self.animation.height = self.animation.draw:getHeight()
end

function enemy:remove()
    for i, instance in ipairs(activeEnemies) do
        if instance == self then
            instance.physics.body:destroy()
            table.remove(activeEnemies, i)
        end
    end
end

function enemy:removeAll()
    for i, instance in ipairs(activeEnemies) do
        instance.physics.body:destroy()
    end
    activeEnemies = {}
end

function enemy:update(dt)
    self:setState()
    self:animate(dt)

    if self.y < 100 then
        self.yVel = -self.yVel
        self.physics.body:setPosition(self.x, 100)
    elseif self.y > 200 then
        self.yVel = -self.yVel
        self.physics.body:setPosition(self.x, 200)
    end

    self:syncPhysics()
end

function enemy.updateAll(dt)
    for i, instance in ipairs(activeEnemies) do
        instance:update(dt)
    end
end

function enemy:setState()
    self.state = "idle"
    self.r = self.physics.body:getAngle()
end

function enemy:animate(dt)
    self.animation.timer = self.animation.timer + dt
    if self.animation.timer > self.animation.rate then
        self.animation.timer = 0
        self:setNewFrame()
    end
end

function enemy:setNewFrame()
    local anim = self.animation[self.state]
    if anim.current < anim.total then
        anim.current = anim.current + 1
    else
        anim.current = 1
    end
    self.animation.draw = anim.img[anim.current]
end

function enemy:flipYDir()
    self.xVel = -self.Xvel
end

function enemy:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
    self.physics.body:setLinearVelocity(self.xVel, self.yVel)
end

function enemy.beginContact(a, b, collision)
    for i, instance in ipairs(activeEnemies) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == player.physics.fixture or b == player.physics.fixture then
               player:takeDamage(instance.damage)
            end
        end
    end
end

function enemy:draw()
    love.graphics.draw(self.animation.draw, self.x, self.y, self.r, self.scaleX, 1, self.width/2, self.height/2)
end

function enemy.drawAll()
    for i, instance in ipairs(activeEnemies) do
        instance:draw()
    end
end

return enemy