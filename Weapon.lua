Weapon = class('Weapon', Item)

function Weapon:init(opts)
    opts.wearable = true
    opts.category = 'weapon'
    Item.init(self, opts)

    self.damage = opts.damage
    assert(type(self.damage) == 'number' or
       type(self.damage) == 'table' and #self.damage == 2)
end

--------------------------------------------------------------------------------

Dagger = class('Dagger', Weapon)

function Dagger:initialize()
    self:init{
        name = 'Dagger',
        icon = Point(544, 0),
        paperdoll = Point(512, 0),
        image = Game.images.equipment,
        damage = {1, 3}
    }
end

--------------------------------------------------------------------------------

return Weapon