Weapon = class('Weapon', Item)

function Weapon:init(opts)
    opts.wearable = true
    opts.category = 'weapon'
    Item.init(self, opts)

    self.verb = opts.verb or 'attack'
    self.damage = opts.damage
    assert(type(self.damage) == 'number' or
       type(self.damage) == 'table' and #self.damage == 2)

    self.hit = opts.hit or 0 -- between 0 and 1, higher means less chance of a miss
end

function Weapon:calculate_damage()
    if math.random() > self.hit then return 0
    elseif type(self.damage) == 'number' then return self.damage
    else return math.random(unpack(self.damage)) end
end

--------------------------------------------------------------------------------

Dagger = class('Dagger', Weapon)

function Dagger:initialize()
    self:init{
        name = 'Dagger',
        verb = 'stab',
        icon = Point(544, 0),
        paperdoll = Point(512, 0),
        image = Game.images.equipment,
        damage = {1, 3},
        hit = 0.5
    }
end

--------------------------------------------------------------------------------

Fist = class('Fist', Weapon)

function Fist:initialize()
    self:init{
        name = 'Fists',
        verb = "strike at",
        icon = Point(0, 0),
        paperdoll = Point(0, 0),
        image = Game.images.equipment,
        damage = 1,
        hit = 0.35
    }
end

--------------------------------------------------------------------------------

return Weapon