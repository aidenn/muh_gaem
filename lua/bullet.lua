local bullet = {}
bullet.__index = bullet
bullet.timer = 0
bullet.maxTime = 0.1
local activeBullets = {}

function bullet:new(x, y, dir, vel)
    local instance = setmetatable({}, bullet)
    instance.x = x
    instance.y = y
    instance.r = 0
    instance.width = 3
    instance.height = 3
    instance.scaleX = dir -- direction (1: right, -1: left)
    instance.state = "idle"
    instance.toRemove = false
    instance.damage = 1
    instance.speed = 300
    instance.xVel = instance.speed + vel
    instance.yVel = 0

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "kinematic")
    instance.physics.shape = love.physics.newRectangleShape(instance.width, instance.height)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    --instance.physics.fixture:setSensor(true)
    table.insert(activeBullets, instance)
end

function bullet:loadAssets()
    self.animation = {timer = 0, rate = 0.1}
    self.animation.idle = {total = 1, current = 1, img = {}}

    for i = 1, self.animation.idle.total do
        self.animation.idle.img[i] = love.graphics.newImage("assets/images/bullet_idle_"..i..".png")
    end

    self.animation.draw = self.animation.idle.img[1]
    self.animation.width = self.animation.draw:getWidth()
    self.animation.height = self.animation.draw:getHeight()
end

function bullet:remove()
    for i, instance in ipairs(activeBullets) do
        if instance == self then
            instance.physics.body:destroy()
            table.remove(activeBullets, i)
        end
    end
end

function bullet:removeAll()
    for i, instance in ipairs(activeBullets) do
        instance.physics.body:destroy()
    end
    activeBullets = {}
end

function bullet:update(dt)
    self:setState()
    self:animate(dt)
    self:syncPhysics()
end

function bullet.updateAll(dt)
    for i, instance in ipairs(activeBullets) do
        instance:update(dt)
    end
end

function bullet:setState()
    self.state = "idle"
    self.r = self.physics.body:getAngle()
end

function bullet:animate(dt)
    self.animation.timer = self.animation.timer + dt
    if self.animation.timer > self.animation.rate then
        self.animation.timer = 0
        self:setNewFrame()
    end
end

function bullet:setNewFrame()
    local anim = self.animation[self.state]
    if anim.current < anim.total then
        anim.current = anim.current + 1
    else
        anim.current = 1
    end
    self.animation.draw = anim.img[anim.current]
end

function bullet:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
    self.physics.body:setLinearVelocity(self.xVel * self.scaleX, self.yVel)
end

function bullet:canShoot(dt)
    if self.timer + dt < self.maxTime then
        self.timer = self.timer + dt
    else
        self.timer = 0
        return true
    end
end

function bullet.beginContact(a, b, collision)
    for i, instance in ipairs(activeBullets) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            instance:remove()
        end
    end
end

function bullet:draw()
    love.graphics.draw(self.animation.draw, self.x, self.y, self.r, self.scaleX, 1, self.width/2, self.height/2)
end

function bullet.drawAll()
    for i, instance in ipairs(activeBullets) do
        instance:draw()
    end
end

return bullet