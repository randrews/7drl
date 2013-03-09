Sidebar = class('Sidebar')

function Sidebar:initialize(game)
    self.game = game

    self.panel = loveframes.Create('panel')
    self.panel:SetSize(200, 600)
    self.panel:SetPos(800, 0)

    self.level = loveframes.Create('text', self.panel)
    self.level:SetPos(10, 10)

    self.health = loveframes.Create('text', self.panel)
    self.health:SetPos(10, 30)

    self.score = loveframes.Create('text', self.panel)
    self.score:SetPos(10, 50)
end

function Sidebar:update()
    local white = {255, 255, 255}
    local health_color = {0, 255, 0}
    if self.game.health <= 5 then
        health_color = {255, 0, 0}
    end

    self.level:SetText{white, "Level " .. self.game.level}
    self.health:SetText{white, "Health: ", health_color, self.game.health}
    self.score:SetText{white, "Score: " .. self.game.score}
end

return Sidebar