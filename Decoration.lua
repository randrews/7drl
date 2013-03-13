Decoration = class('Decoration')

function Decoration:initialize(opts)
    self.image = opts.image or Game.images.extras
    self.icon = opts.icon ; assert(self.icon)

    local w = self.image:getWidth()
    local h = self.image:getHeight()
    self.quad = love.graphics.newQuad(
        self.icon.x, self.icon.y,
        32, 32,
        w, h)
end

function Decoration.static.setup()
    Decoration.corpse = Decoration{
        icon = Point(32*6, 0)
    }
end