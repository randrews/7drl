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

    self.zzz = nil -- The "zzz" animation when they're asleep
end

-- Called when noise is made near the enemy
function Enemy:hear(game)
    self.awake = true
end

-- Takes the point (map coords) where the enemy is
function Enemy:draw(pt)
    local g = love.graphics
    g.drawq(self.image, self.quad, pt.x*40+4, pt.y*40+4)

    if not self.awake then
        if not self.zzz or not self.zzz.y:alive() then
            self:makeZzz()
        end

        local c = {g.getColor()}
        g.setColor(255, 255, 255, self.zzz.transparency.value)
        g.print("Zzz", pt.x*40+self.zzz.x, pt.y*40+self.zzz.y.value)
        g.setColor(c)
    end
end

function Enemy:makeZzz()
    self.zzz = {
        x = math.random(8, 16),
        y = Tween(4, -16, 3),
        transparency = Tween(255, 64, 3)
    }
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