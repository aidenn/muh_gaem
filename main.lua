local bullet = require "lua.bullet"
if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    require("lldebugger").start()
end

ScreenWidth = love.graphics.getWidth()
ScreenHeight = love.graphics.getHeight()
Scale = 3
love.graphics.setDefaultFilter("nearest", "nearest")
love.physics.getMeter(10)

local player = require("lua/player")
local entity = {}
entity.item = require("lua/item")
entity.hazard = require("lua/hazard")
entity.bullet = require("lua/bullet")
entity.movable = require("lua/movable")
entity.enemy = require("lua/enemy")
local map = require("lua/map")
local hud = require("lua/hud")
local camera = require("lua/camera")

function love.load()
    map:load()
    player:load()
    entity.hazard:loadAssets()
    entity.item:loadAssets()
    entity.movable:loadAssets()
    entity.enemy:loadAssets()
    entity.bullet:loadAssets()
    hud:load()
end

function love.update(dt)
    camera:setPosition(player.x, 0)
    map:update(dt)
    entity.movable.updateAll(dt)
    entity.hazard.updateAll(dt)
    entity.item.updateAll(dt)
    entity.enemy.updateAll(dt)
    entity.bullet.updateAll(dt)
    player:update(dt)
    hud:update(dt)
end

function love.draw()
    map:draw(camera.x, camera.y)

    camera:apply()

    entity.movable.drawAll()
    entity.hazard.drawAll()
    entity.item.drawAll()
    entity.enemy.drawAll()
    entity.bullet.drawAll()
    player:draw()

    camera:clear()

    hud:draw()
end

function beginContact(a, b, collision)
    if entity.item.beginContact(a, b, collision) then return end
    entity.hazard.beginContact(a, b, collision)
    entity.enemy.beginContact(a, b, collision)
    entity.bullet.beginContact(a, b, collision)
    player:beginContact(a, b, collision)
end

function endContact(a, b, collision)
    player:endContact(a, b, collision)
end

function love.keypressed(key, scancode, isrepeat)
    if key == "escape" then
        love.event.quit()
    end

    player:jump(key)
end