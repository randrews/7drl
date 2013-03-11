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

    self.armor = loveframes.Create('text', self.panel)
    self.armor:SetPos(10, 50)

    self.score = loveframes.Create('text', self.panel)
    self.score:SetPos(10, 70)

    self.inventory = loveframes.Create('list', self.panel)
    self.inventory:SetPos(10, 90)
    self.inventory:SetSize(180, 470)
    self.inventory:SetDisplayType('vertical')
    self.inventory:SetPadding(0)
    self.inventory:SetSpacing(0)

    self.inventory_panels = {} -- Map from Item to panel

    self.map = loveframes.Create('button', self.panel)
    self.map:SetSize(53, 20)
    self.map:SetPos(10, 570)
    self.map:SetText('Map')

    self.help = loveframes.Create('button', self.panel)
    self.help:SetSize(54, 20)
    self.help:SetPos(73, 570)
    self.help:SetText('Help')

    self.exit = loveframes.Create('button', self.panel)
    self.exit:SetSize(53, 20)
    self.exit:SetPos(137, 570)
    self.exit:SetText('Exit')

    self.minimap = nil

    self.map.OnClick = function() self:toggle_map() end
    self.exit.OnClick = function() self:exit_dialog() end
end

function Sidebar:add_item(item)
    local panel = loveframes.Create('panel')
    panel:SetHeight(32)
    self.inventory:AddItem(panel)
    item:create_panel(panel, self)
    self.inventory_panels[item] = panel
end

function Sidebar:remove_item(item)
    local panel = self.inventory_panels[item]
    if not panel then return end
    self.inventory_panels[item] = nil
    self.inventory:RemoveItem(panel)
    panel:Remove()
end

function Sidebar:update()
    local white = {255, 255, 255}
    local health_color = {0, 255, 0}
    if self.game.health <= 5 then
        health_color = {255, 0, 0}
    end

    local health_str = self.game.health .. " / " .. self.game.max_health

    self.level:SetText{white, "Level " .. self.game.level}
    self.health:SetText{white, "Health: ", health_color, health_str}
    self.armor:SetText{white, "Armor: " .. self.game.armor}
    self.score:SetText{white, "Score: " .. self.game.score}
end

function Sidebar:toggle_map()
    if self.minimap then
        self.minimap.frame:Remove()
        self.minimap = nil
    else
        local minimap = {}
        minimap.frame = loveframes.Create('frame')
        minimap.frame:SetName('Map')
        minimap.frame:SetSize(196, 196+25)
        minimap.frame:SetPos(10, 10)
        minimap.frame.OnClose = function() self:toggle_map() end

        minimap.image = loveframes.Create('image', minimap.frame)
        minimap.image:SetSize(196, 196)
        minimap.image:SetPos(0, 25)
        minimap.image:SetImage(function() self:draw_minimap() end)

        self.minimap = minimap
    end
end

function Sidebar:draw_minimap()
    love.graphics.setColor(255, 255, 255)
    love.graphics.line(0, 0, 196, 196)
    love.graphics.line(0, 196, 196, 0)
end

function Sidebar:exit_dialog()
    self.game:set_freeze(true)

    local prom = utils.dialog('Exit', 'Really quit?', 'Yes', 'No')

    prom:add(function(btn)
                 if btn == 'Yes' then
                     love.event.push('quit')
                     REALLY_QUIT = true
                 elseif btn == 'No' then
                     self.game:set_freeze(false)
                 end
             end)
end

return Sidebar