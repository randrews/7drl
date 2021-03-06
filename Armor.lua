Armor = class('Armor', Item)

function Armor:init(opts)
    opts.category = 'armor'
    opts.wearable = true
    opts.image = opts.image or Game.images.equipment
    self.value = opts.value or 0
    Item.init(self, opts)
end

function Armor:on_activate(game)
    game.armor = game.armor + self.value
end

function Armor:on_deactivate(game)
    game.armor = game.armor - self.value
end

--------------------------------------------------------------------------------

Clothes = class('Clothes', Armor)

function Clothes:initialize()
    self:init{
        name = 'Clothes',
        value = 0,
        icon = Point(32, 0),
        paperdoll = Point(0, 0),
        description = "Normal street clothes: jeans, and a t-shirt you bought from the Internet. They aren't going to offer much protection."
    }
end

--------------------------------------------------------------------------------

Leather = class('Leather', Armor)

function Leather:initialize()
    self:init{
        name = 'Leather',
        value = 1,
        icon = Point(96, 0),
        paperdoll = Point(64, 0),
        description = "Leather armor, it will offer some protection."
    }
end

--------------------------------------------------------------------------------

Chainmail = class('Chainmail', Armor)

function Chainmail:initialize()
    self:init{
        name = 'Chainmail',
        value = 3,
        icon = Point(32, 32),
        paperdoll = Point(0, 32),
        description = "Chainmail armor, it will protect against medium blows."
    }
end

--------------------------------------------------------------------------------

Plate = class('Plate', Armor)

function Plate:initialize()
    self:init{
        name = 'Plate',
        value = 5,
        icon = Point(96, 32),
        paperdoll = Point(64, 32),
        description = "Plate armor, it will protect against almost all damage."
    }
end
