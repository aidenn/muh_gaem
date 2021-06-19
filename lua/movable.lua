local movable = {}
movable.__index = movable
local activeMovables = {}

function movable:new(x, y)
    local instance = setmetatable({}, movable)
    instance.x = x
    instance.y = y
    instance.r = 0
    instance.width = 16
    instance.height = 16
    instance.scaleX = 1 -- direction (1: right, -1: left)
    instance.state = "idle"
    instance.toRemove = false

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "dynamic")
    instance.physics.body:setMass(25)
    instance.physics.shape = love.physics.newRectangleShape(instance.width, instance.height)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    table.insert(activeMovables, instance)
end

function movable:loadAssets()
    self.animation = {timer = 0, rate = 0.1}
    self.animation.idle = {total = 1, current = 1, img = {}}

    for i = 1, self.animation.idle.total do
        self.animation.idle.img[i] = love.graphics.newImage("assets/images/box_idle_"..i..".png")
    end

    self.animation.draw = self.animation.idle.img[1]
    self.animation.width = self.animation.draw:getWidth()
    self.animation.height = self.animation.draw:getHeight()
end

function movable:remove()
    for i, instance in ipairs(activeMovables) do
        if instance == self then
            instance.physics.body:destroy()
            table.remove(activeMovables, i)
        end
    end
end

function movable:removeAll()
    for i, instance in ipairs(activeMovables) do
        instance.physics.body:destroy()
    end
    activeMovables = {}
end

function movable:update(dt)
    self:setState()
    self:animate(dt)
    self:syncPhysics()
end

function movable.updateAll(dt)
    for i, instance in ipairs(activeMovables) do
        instance:update(dt)
    end
end

function movable:setState()
    self.state = "idle"
    self.r = self.physics.body:getAngle()
end

function movable:animate(dt)
    self.animation.timer = self.animation.timer + dt
    if self.animation.timer > self.animation.rate then
        self.animation.timer = 0
        self:setNewFrame()
    end
end

function movable:setNewFrame()
    local anim = self.animation[self.state]
    if anim.current < anim.total then
        anim.current = anim.current + 1
    else
        anim.current = 1
    end
    self.animation.draw = anim.img[anim.current]
end

function movable:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
end

function movable.beginContact(a, b, collision)
    for i, instance in ipairs(activeMovables) do
        if a == instance.physics.fixture or b == instance.physics.fixture then

        end
    end
end

function movable:draw()
    love.graphics.draw(self.animation.draw, self.x, self.y, self.r, self.scaleX, 1, self.width/2, self.height/2)
end

function movable.drawAll()
    for i, instance in ipairs(activeMovables) do
        instance:draw()
    end
end

return movable