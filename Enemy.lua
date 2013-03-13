Enemy = class('Enemy')

function Enemy:init(opts)
    self.name = opts.name ; assert(self.name)
    self.health = opts.health or 10
    self.damage = opts.damage or {2, 5}
    self.icon = opts.icon ; assert(self.icon)
    self.image = opts.image or Game.images.chars
    self.awake = false
    self.alive = true

    local w = self.image:getWidth()
    local h = self.image:getHeight()
    self.quad = love.graphics.newQuad(
        self.icon.x, self.icon.y,
        32, 32,
        w, h)
end

--------------------------------------------------

Orc = class('Orc', Enemy)

function Orc:initialize()
    self:init{
        name = "orc",
        health = math.random(3, 7),
        icon = Point(32, 0)
    }
end

return Enemy