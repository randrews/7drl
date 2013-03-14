MapItem = class('MapItem')

function MapItem:init(opts)
    self.name = opts.name ; assert(self.name)
    self.icon = opts.icon ; assert(self.icon)
    self.image = opts.image or Game.images.chars

    local w = self.image:getWidth()
    local h = self.image:getHeight()
    self.quad = love.graphics.newQuad(
        self.icon.x, self.icon.y,
        32, 32,
        w, h)
end

function MapItem:hear(game, pt) end
function MapItem:tick(game, pt) end
function MapItem:bump(game, pt) end

--------------------------------------------------

Stairs = class('Stairs', MapItem)



return MapItem