Weapon = class('Weapon', Item)

function Weapon:init(opts)
    opts.wearable = true
    opts.category = 'weapon'
    self.verb = opts.verb or 'attack'
    self.damage = opts.damage
    assert(type(self.damage) == 'number' or type(self.damage) == 'table' and #self.damage == 2)
    self.hit = opts.hit or 0 -- between 0 and 1, higher means less chance of a miss
    opts.description = opts.description or self:make_description()
    Item.init(self, opts)
end

function Weapon:calculate_damage()
    if math.random() > self.hit then return 0
    elseif type(self.damage) == 'number' then return self.damage
    else return math.random(unpack(self.damage)) end
end

function Weapon:make_description()
    local dmg = nil
    if type(self.damage) == 'number' then dmg = self.damage .. " damage"
    else dmg = string.format("%s-%s damage", unpack(self.damage)) end

    local to_hit = math.floor(self.hit * 100) .. '%'
    return string.format("%s, %s chance to hit.", dmg, to_hit)
end

--------------------------------------------------------------------------------

Longsword = class('Longsword', Weapon)

function Longsword:initialize()
    self:init{
        name = 'Longsword',
        verb = 'cleave',
        icon = Point(1312, 0),
        paperdoll = Point(1280, 0),
        image = Game.images.equipment,
        damage = {5, 8},
        hit = 0.65
    }
end

--------------------------------------------------------------------------------

Axe = class('Axe', Weapon)

function Axe:initialize()
    self:init{
        name = 'Axe',
        verb = 'chop',
        icon = Point(1440, 0),
        paperdoll = Point(1408, 0),
        image = Game.images.equipment,
        damage = 6,
        hit = 0.35
    }
end

--------------------------------------------------------------------------------

Hammer = class('Hammer', Weapon)

function Hammer:initialize()
    self:init{
        name = 'Hammer',
        verb = 'whack',
        icon = Point(672, 0),
        paperdoll = Point(640, 0),
        image = Game.images.equipment,
        damage = 6,
        hit = 0.2
    }
end

--------------------------------------------------------------------------------

ShortSword = class('ShortSword', Weapon)

function ShortSword:initialize()
    self:init{
        name = 'Short sword',
        verb = 'slash',
        icon = Point(1184, 0),
        paperdoll = Point(1152, 0),
        image = Game.images.equipment,
        damage = {2, 5},
        hit = 0.65
    }
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

DevWand = class('DevWand', Weapon)

function DevWand:initialize()
    self:init{
        name = 'Wand of dev',
        verb = 'tweak reality around',
        icon = Point(992, 0),
        paperdoll = Point(960, 0),
        image = Game.images.equipment,
        damage = 1000000,
        hit = 1
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