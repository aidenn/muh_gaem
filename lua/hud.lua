local player = require("lua/player")
local hud = {}

function hud:load()
    self.x = 0
    self.y = 0
    self.pointsText = "punkty: "
    self.healthText = "zdrowie: "
    self.font = love.graphics.newImageFont("assets/fonts/font_2.png", " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,!?-+/():;%&`_*#=[]'{}", 1)
    self.font:setLineHeight(.6)
    love.graphics.setFont(self.font)
end

function hud:update(dt)

end

function hud:draw()
    love.graphics.print(self.pointsText..player.points, self.x, self.y, 0, Scale, Scale)
    love.graphics.print(self.healthText..player.health.current, self.x, self.y + 26, 0, Scale, Scale)
    love.graphics.print("fps: "..love.timer.getFPS(), self.x, self.y + 26 * 2, 0, Scale, Scale)
end

return hud