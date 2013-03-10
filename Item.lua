require('middleclass')
require('Point')

Item = class('Item')

function Item:init(opts)
    self.name = opts.name ; assert(self.name)
    -- Only one item of a category can be active at a time
    self.category = opts.category
    self.active = opts.active
    self.icon = opts.icon ; assert(instanceOf(Point, self.icon))
    self.image = opts.image ; assert(self.image)

    local img_w = self.image:getWidth()
    local img_h = self.image:getHeight()
    self.quad = love.graphics.newQuad(self.icon.x, self.icon.y, 32, 32, img_w, img_h)
end

-- Override me
function Item:activate(game) end

function Item:create_panel()
    
end

--------------------------------------------------------------------------------

Clothes = class('Clothes', Item)

function Clothes:initialize()
    self:init{
        name = 'Clothes',
        category = 'armor',
        icon = Point(3168, 0),
        image = Game.images.equipment
    }
end

return Item