MapItem = class('MapItem')

function MapItem:init(opts)
    self.name = opts.name ; assert(self.name)
    self.icon = opts.icon ; assert(self.icon)
    self.size = opts.size or Point(32, 32)
    self.image = opts.image or Game.images.extras

    local w = self.image:getWidth()
    local h = self.image:getHeight()
    self.quad = love.graphics.newQuad(
        self.icon.x, self.icon.y,
        self.size.x, self.size.y,
        w, h)
end

function MapItem:hear(game, pt) end -- Noise made in the vicinity
function MapItem:tick(game, pt) end -- Player does something time-consuming
function MapItem:bump(game, pt) end -- Player walks into us

-- Takes the point (map coords) where the enemy is
function MapItem:draw(pt)
    local g = love.graphics
    local offset = (Point(40, 40) - self.size) / 2
    g.drawq(self.image, self.quad, pt.x*40+offset.x, pt.y*40+offset.y)
end

--------------------------------------------------

Stairs = class('Stairs', MapItem)

function Stairs:initialize()
    self:init{
        name = "Stairs",
        icon = Point(40, 40),
        size = Point(40, 40),
        image = Game.images.decoration
    }
end

function Stairs:bump(game, pt)
    game:set_freeze(true)
    local prom = utils.dialog("Next level", "Go down the stairs?")

    prom:add(function(btn)
                 game:set_freeze(false)
                 if btn == 'Yes' then
                     game:log("You descend to level " .. (game.level_num+1), {255, 255, 0})
                     game:next_level()
                 end
             end)
end

--------------------------------------------------

Scepter = class('Scepter', MapItem)

function Scepter:initialize()
    self:init{
        name = "Scepter",
        icon = Point(140, 0),
        size = Point(32, 32),
        image = Game.images.custom
    }
end

function Scepter:bump(game, pt)
    game:set_freeze(true)
    local prom = utils.dialog("You win!",
                              "You have found the \n royal scepter, and \n win the game! \n Your final score is " .. game.score,
                              "Restart",
                              "Quit",
                              30)

    prom:add(function(btn)
                 game:set_freeze(false)
                 if btn == 'Quit' then
                     love.event.push('quit')
                     REALLY_QUIT = true
                 else
                     START_GAME()
                 end
             end)
end

--------------------------------------------------

Chest = class('Chest', MapItem)

function Chest:initialize(item1, item2)
    self:init{
        name = "Chest",
        icon = Point(96, 0),
        size = Point(32, 32),
        image = Game.images.extras
    }

    self.item1 = item1 ; assert(item1)
    self.item2 = item2 ; assert(item2)
end

function Chest:bump(game, pt)
    game:set_freeze(true)
    local prom = self:make_dialog(game)

    prom:add(function(_, btn)
                 game:set_freeze(false)
                 if btn.item then
                     game:add_item(btn.item)
                     game.map_items:delete(pt)
                 end
             end)
end

function Chest:make_dialog(game)
    -- Raise a standard dialog
    local prom, dialog = utils.dialog("Chest", "Which item do you want?")

    -- Make it look like a chest dialog
    dialog.dialog:SetSize(200, 170)
    dialog.dialog:Center()
    dialog.btn1:SetPos(10, 140)
    dialog.btn2:SetPos(105, 140)
    dialog.dialog:ShowCloseButton(true)

    dialog.dialog.OnClose = function()
                                CURRENT_DIALOG = nil
                                prom:finish()
                                game:set_freeze(false)
                            end

    local item1 = self.item1:create_icon(dialog.dialog)
    item1:SetPos(34, 80)
    dialog.btn1:SetText(self.item1.name)
    dialog.btn1.item = self.item1

    local item2 = self.item2:create_icon(dialog.dialog)
    item2:SetPos(134, 80)
    dialog.btn2:SetText(self.item2.name)
    dialog.btn2.item = self.item2

    return prom
end

--------------------------------------------------

return MapItem