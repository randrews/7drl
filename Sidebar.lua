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

    self.help = loveframes.Create('button', self.panel)
    self.help:SetSize(85, 20)
    self.help:SetPos(10, 570)
    self.help:SetText('Help')

    self.exit = loveframes.Create('button', self.panel)
    self.exit:SetSize(85, 20)
    self.exit:SetPos(105, 570)
    self.exit:SetText('Exit')

    self.exit.OnClick = function() self:exit_dialog() end
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

function Sidebar:exit_dialog()
    self.game:set_freeze(true)

    local dialog = loveframes.Create('frame')
    dialog:SetSize(200, 120)
    dialog:Center()
    dialog:SetName('Exit')
    dialog:SetModal(true)
    dialog:ShowCloseButton(false)

    local white = {255, 255, 255}
    local text = loveframes.Create('text', dialog)
    text:SetText{white, "Really quit?"}
    text:Center()
    text:SetY(50)

    local yes = loveframes.Create('button', dialog)
    yes:SetText('Yes')
    yes:SetSize(85, 20)
    yes:SetPos(10, 90)

    local no = loveframes.Create('button', dialog)
    no:SetText('No')
    no:SetSize(85, 20)
    no:SetPos(105, 90)

    yes.OnClick = function() love.event.push('quit') end
    no.OnClick = function()
                     self.game:set_freeze(false)
                     dialog:Remove()
                 end
end

return Sidebar