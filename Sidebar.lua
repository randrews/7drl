Sidebar = class('Sidebar')

function Sidebar:initialize(game)
    self.game = game

    self.panel = loveframes.Create('panel')
    self.panel:SetSize(200, 600)
    self.panel:SetPos(800, 0)

    -- Status box
    self.level = loveframes.Create('text', self.panel)
    self.level:SetPos(10, 10)

    self.health = loveframes.Create('text', self.panel)
    self.health:SetPos(10, 30)

    self.armor = loveframes.Create('text', self.panel)
    self.armor:SetPos(10, 50)

    self.score = loveframes.Create('text', self.panel)
    self.score:SetPos(10, 70)

    -- Inventory
    self.inventory = loveframes.Create('list', self.panel)
    self.inventory:SetPos(10, 90)
    self.inventory:SetSize(180, 440)
    self.inventory:SetDisplayType('vertical')
    self.inventory:SetPadding(0)
    self.inventory:SetSpacing(0)

    self.inventory_panels = {} -- Map from Item to panel

    -- Buttons (row 1)
    self.log = loveframes.Create('button', self.panel)
    self.log:SetSize(85, 20)
    self.log:SetPos(105, 540)
    self.log:SetText('Log')

    self.map = loveframes.Create('button', self.panel)
    self.map:SetSize(85, 20)
    self.map:SetPos(10, 540)
    self.map:SetText('Map')

    -- Buttons (row 2)
    self.exit = loveframes.Create('button', self.panel)
    self.exit:SetSize(85, 20)
    self.exit:SetPos(10, 570)
    self.exit:SetText('Exit')

    -- self.help = loveframes.Create('button', self.panel)
    -- self.help:SetSize(85, 20)
    -- self.help:SetPos(105, 570)
    -- self.help:SetText('Help')

    self.minimap = nil

    -- Button events
    self.map.OnClick = function() self:toggle_map() end
    self.exit.OnClick = function() self:exit_dialog() end
    self.log.OnClick = function() self:toggle_log() end

    self:create_log_window()
    self:create_map_window()
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

    self.level:SetText{white, "Level " .. self.game.level_num}
    self.health:SetText{white, "Health: ", health_color, health_str}
    self.armor:SetText{white, "Armor: " .. self.game.armor}
    self.score:SetText{white, "Score: " .. self.game.score}
end

function Sidebar:create_log_window()
    if self.log_window then
        self.log_window.frame:Remove()
        self.log_window = nil
    else
        local log = {}
        log.frame = loveframes.Create('frame')
        log.frame:SetName('Message Log')
        log.frame:SetSize(300, 150+25)
        log.frame:SetPos(490, 415)
        log.frame.OnClose = function() self:toggle_log() ; return true end

        local list = loveframes.Create('list', log.frame)
        list:SetSize(300, 150)
        list:SetPos(0, 25)
        list:SetPadding(5)

        log.text = loveframes.Create('text')
        list:AddItem(log.text)

        log.lines = List()
        self.log_window = log
    end
end

function Sidebar:add_log_message(str, color)
    color = color or {255, 255, 255}
    self.log_window.lines:unshift(str .. " \n ")
    self.log_window.lines:unshift(color)

    while self.log_window.lines:length() > 200 do
        self.log_window.lines:pop()
    end

    self.log_window.text:SetText(self.log_window.lines.items)
end

function Sidebar:toggle_log()
    if self.log_window.frame:GetVisible() then
        self.log_window.frame:SetVisible(false)
    else
        self.log_window.frame:SetVisible(true)
    end
end

function Sidebar:create_map_window()
    local minimap = {}
    minimap.frame = loveframes.Create('frame')
    minimap.frame:SetVisible(false)
    minimap.frame:SetName('Map')
    minimap.frame:SetSize(196, 196+25)
    minimap.frame:SetPos(10, 10)
    minimap.frame.OnClose = function() self:toggle_map() ; return true end

    minimap.image = loveframes.Create('image', minimap.frame)
    minimap.image:SetSize(196, 196)
    minimap.image:SetPos(0, 25)
    minimap.image:SetImage(function() self:draw_minimap() end)

    self.minimap = minimap
end

function Sidebar:toggle_map()
    if self.minimap.frame:GetVisible() then
        self.minimap.frame:SetVisible(false)
    else
        self.minimap.frame:SetVisible(true)
    end
end

function Sidebar:create_minimap_canvas()
    local g = love.graphics
    local canvas = self.minimap.canvas or g.newCanvas()

    g.setCanvas(canvas)
    g.push()

    -- Ugly hack:
    -- -----------------------------------------------------
    -- Drawing to a canvas doesn't reset the transformation
    -- matrix, and there's no way to do so by hand. So we'll
    -- end up drawing the minimap on the canvas wherever the
    -- window happens to be on the screen, which is no good.
    -- But, we know where the window *is*, so we can just
    -- translate backwards from that to draw in the upper-
    -- left of the canvas anyway, as long as there are no
    -- transformations other than "translate to the upper-
    -- left of minimap.image" in effect. Which there should
    -- never be.

    local ix, iy = self.minimap.image:GetPos()
    g.translate(-ix, -iy)
    g.setScissor() -- Also, we have to clear the scissor ourselves

    -- -----------------------------------------------------

    g.setColor(0, 0, 0)
    g.rectangle('fill', 0, 0, 196, 196)

    for pt in self.game.map:each() do
        if true or self.game.visibility:at(pt) then
            local c = self.game.map:at(pt)

            if c == '.' or c == ',' or c == '_' then
                g.setColor(140, 140, 140)
                g.rectangle('fill', pt.x*4, pt.y*4, 4, 4)
            elseif c == '+' then
                g.setColor(255, 140, 0)
                g.rectangle('fill', pt.x*4, pt.y*4, 4, 4)
            end
        end
    end

    g.pop()
    g.setCanvas() 

    return canvas
end

function Sidebar:redraw_minimap()
    if self.minimap then self.minimap.redraw = true end
end

function Sidebar:draw_minimap()
    if not self.minimap.canvas or self.minimap.redraw then
        self.minimap.canvas = self:create_minimap_canvas()
        self.minimap.redraw = false
    end

    love.graphics.draw(self.minimap.canvas, 0, 0)
    love.graphics.setColor(0, 255, 0)
    love.graphics.rectangle('fill',
                            self.game.player_loc.x*4,
                            self.game.player_loc.y*4,
                            4, 4)

    if true or self.game.visibility:at(self.game.stairs_loc) then
        love.graphics.setColor(0, 0, 255)
        love.graphics.rectangle('fill',
                                self.game.stairs_loc.x*4,
                                self.game.stairs_loc.y*4,
                                4, 4)
    end
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