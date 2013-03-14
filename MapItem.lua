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
                     game:next_level()
                 end
             end)
end

--------------------------------------------------

return MapItem