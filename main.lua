if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    require("lldebugger").start()
end

require("player")
local sti = require("sti")

ScreenWidth = love.graphics.getWidth()
ScreenHeight = love.graphics.getHeight()
Scale = 3

function love.load()

    love.graphics.setDefaultFilter("nearest", "nearest")
    love.physics.getMeter(10)

    Map = sti("maps/map_01.lua", { "box2d" })
    World = love.physics.newWorld(0, 0)

    World:setCallbacks(beginContact, endContact)
    Map:box2d_init(World)
    -- Map:addCustomLayer("Sprite Layer", 3)

    Player:load()

end

function love.update(dt)

    World:update(dt)
    Player:update(dt)

end

function love.draw()

    Map:draw(0, 0, Scale, Scale)

    love.graphics.push()
    love.graphics.scale(Scale, Scale)

    Player:draw()

    love.graphics.pop()

end

function beginContact(a, b, collision)
    Player:beginContact(a, b, collision)
end

function endContact(a, b, collision)
    Player:endContact(a, b, collision)
end

function love.keypressed(key, scancode, isrepeat)

    if key == "escape" then
        love.event.quit()
    end

    Player:jump(key)

end