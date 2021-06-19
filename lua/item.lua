local player = require("lua/player")
local item = {}
item.__index = item
local activeItems = {}

function item:new(x, y)
    local instance = setmetatable({}, item)
    instance.x = x
    instance.y = y
    instance.width = 8
    instance.height = 8
    instance.xVel = 0
    instance.yVel = 0
    instance.maxSpeed = 100
    instance.scaleX = 1 -- direction (1: right, -1: left)
    instance.state = "idle"
    instance.toRemove = false
    instance.worth = 100

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "static")
    instance.physics.shape = love.physics.newRectangleShape(instance.width, instance.height)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.fixture:setSensor(true)
    table.insert(activeItems, instance)
end

function item:loadAssets()
    self.animation = {timer = 0, rate = 0.1}
    self.animation.idle = {total = 1, current = 1, img = {}}

    for i = 1, self.animation.idle.total do
        self.animation.idle.img[i] = love.graphics.newImage("assets/images/item_idle_"..i..".png")
    end

    self.animation.draw = self.animation.idle.img[1]
    self.animation.width = self.animation.draw:getWidth()
    self.animation.height = self.animation.draw:getHeight()
end

function item:remove()
    for i, instance in ipairs(activeItems) do
        if instance == self then
            instance.physics.body:destroy()
            table.remove(activeItems, i)
        end
    end
end

function item:removeAll()
    for i, instance in ipairs(activeItems) do
        instance.physics.body:destroy()
    end
    activeItems = {}
end

function item:update(dt)
    self:checkAndRemove()
    self:setState()
    self:animate(dt)
end

function item.updateAll(dt)
    for i, instance in ipairs(activeItems) do
        instance:update(dt)
    end
end

function item:checkAndRemove()
    if self.toRemove then
        self:remove()
    end
end

function item:setState()
    self.state = "idle"
end

function item:animate(dt)
    self.animation.timer = self.animation.timer + dt
    if self.animation.timer > self.animation.rate then
        self.animation.timer = 0
        self:setNewFrame()
    end
end

function item:setNewFrame()
    local anim = self.animation[self.state]
    if anim.current < anim.total then
        anim.current = anim.current + 1
    else
        anim.current = 1
    end
    self.animation.draw = anim.img[anim.current]
end

function item.beginContact(a, b, collision)
    for i, instance in ipairs(activeItems) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == player.physics.fixture or b == player.physics.fixture then
                player:addPoints(instance.worth)
                instance.toRemove = true
                return true
            end
        end
    end
end

function item:draw()
    love.graphics.draw(self.animation.draw, self.x, self.y, 0, self.scaleX, 1, self.width/2, self.height/2)
end

function item.drawAll()
    for i, instance in ipairs(activeItems) do
        instance:draw()
    end
end

return item