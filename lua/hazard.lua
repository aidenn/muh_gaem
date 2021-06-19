local player = require("lua/player")
local hazard = {}
hazard.__index = hazard
local activeHazards = {}

function hazard:new(x, y)
    local instance = setmetatable({}, hazard)
    instance.x = x
    instance.y = y
    instance.width = 8
    instance.height = 8
    instance.scaleX = 1 -- direction (1: right, -1: left)
    instance.state = "idle"
    instance.toRemove = false
    instance.damage = 1

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "static")
    instance.physics.shape = love.physics.newRectangleShape(instance.width, instance.height)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    table.insert(activeHazards, instance)
end

function hazard:loadAssets()
    self.animation = {timer = 0, rate = 0.1}
    self.animation.idle = {total = 1, current = 1, img = {}}

    for i = 1, self.animation.idle.total do
        self.animation.idle.img[i] = love.graphics.newImage("assets/images/spike_idle_"..i..".png")
    end

    self.animation.draw = self.animation.idle.img[1]
    self.animation.width = self.animation.draw:getWidth()
    self.animation.height = self.animation.draw:getHeight()
end

function hazard:remove()
    for i, instance in ipairs(activeHazards) do
        if instance == self then
            instance.physics.body:destroy()
            table.remove(activeHazards, i)
        end
    end
end

function hazard:removeAll()
    for i, instance in ipairs(activeHazards) do
        instance.physics.body:destroy()
    end
    activeHazards = {}
end

function hazard:update(dt)
    self:setState()
    self:animate(dt)
end

function hazard.updateAll(dt)
    for i, instance in ipairs(activeHazards) do
        instance:update(dt)
    end
end

function hazard:setState()
    self.state = "idle"
end

function hazard:animate(dt)
    self.animation.timer = self.animation.timer + dt
    if self.animation.timer > self.animation.rate then
        self.animation.timer = 0
        self:setNewFrame()
    end
end

function hazard:setNewFrame()
    local anim = self.animation[self.state]
    if anim.current < anim.total then
        anim.current = anim.current + 1
    else
        anim.current = 1
    end
    self.animation.draw = anim.img[anim.current]
end

function hazard.beginContact(a, b, collision)
    for i, instance in ipairs(activeHazards) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == player.physics.fixture or b == player.physics.fixture then
                player:takeDamage(instance.damage)
                return true
            end
        end
    end
end

function hazard:draw()
    love.graphics.draw(self.animation.draw, self.x, self.y, 0, self.scaleX, 1, self.width/2, self.height/2)
end

function hazard.drawAll()
    for i, instance in ipairs(activeHazards) do
        instance:draw()
    end
end

return hazard