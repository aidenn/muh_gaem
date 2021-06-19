local map = require("lua/map")
local camera = {x = 0, y = 0}

function camera:apply()
    love.graphics.push()
    love.graphics.scale(Scale, Scale)
    love.graphics.translate(-self.x, -self.y)
end

function camera:clear()
    love.graphics.pop()
end

function camera:setPosition(x, y)
    if map.level.width == ScreenWidth/Scale then
        self.x = 0
        self.y = 0
        return
    end

    self.x = math.max(0, x - ScreenWidth/2/Scale)
    self.y = y

    local rs = self.x + ScreenWidth/Scale
        if rs > map.level.width then
        self.x = map.level.width - ScreenWidth/Scale
    end
end

return camera