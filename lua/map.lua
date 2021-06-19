local sti = require("sti")
local player = require("lua/player")
local entity = {}
entity.item = require("lua/item")
entity.hazard = require("lua/hazard")
entity.movable = require("lua/movable")
entity.enemy = require("lua/enemy")
local map = {}

function map:load()
    self.currentLevel = 1
    World = love.physics.newWorld(0, 2000)
    World:setCallbacks(beginContact, endContact)

    self:init()
end

function map:init()
    self.level = sti("maps/map_"..self.currentLevel..".lua", { "box2d" })
    self.level:box2d_init(World)
    self.solidLayer = self.level.layers.solid
    self.groundLayer = self.level.layers.ground
    self.entityLayer = self.level.layers.entity
    self.solidLayer.visible = false
    self.entityLayer.visible = false
    self.level.width = self.groundLayer.width * 16

    self:spawnEntities()
end

function map:spawnEntities()
    for i, v in ipairs(self.entityLayer.objects) do
        entity[v.type]:new(v.x + v.width/2, v.y + v.height/2)
    end
end

function map:next()
    self:clear()
    self.currentLevel = self.currentLevel + 1
    self:init()
    player:resetPosition()
end

function map:clear()
    self.level:box2d_removeLayer("solid")
    for i, v in ipairs(self.entityLayer.objects) do
        entity[v.type]:removeAll()
    end
end

function map:update(dt)
    World:update(dt)
    if player.x > self.level.width - 32 then
        self:next()
    end
end

function map:draw(cameraX, cameraY)
    self.level:draw(-cameraX, -cameraY, Scale, Scale)
end

return map