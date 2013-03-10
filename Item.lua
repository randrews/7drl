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
    self.usable = opts.usable
    self.wearable = opts.wearable
end

function Item:create_panel(panel, sidebar)
    local icon = loveframes.Create('image', panel)
    icon:SetImage(self.image)
    icon:SetSize(32, 32)
    icon:SetPos(0, 0)
    icon:SetOffset(self.icon())

    self.label = loveframes.Create('text', panel)
    self.label:SetPos(42, 10)
    self.label:SetText(self.name)

    if self.usable then
        self.use_button = loveframes.Create('button', panel)
        self.use_button:SetSize(32, 32)
        self.use_button:SetPos(panel:GetWidth()-32, 0)
        self.use_button:SetText("Use")
        self.use_button.OnClick = function() self:use(sidebar.game) end
    end
end

-- Override me
function Item:activate(game) end
function Item:use(game) print("Using " .. self.name) end

--------------------------------------------------------------------------------

Clothes = class('Clothes', Item)

function Clothes:initialize()
    self:init{
        name = 'Clothes',
        category = 'armor',
        wearable = true,
        icon = Point(3168, 0),
        image = Game.images.equipment
    }
end

function Clothes:activate(game)
    game.armor = 1
end

--------------------------------------------------------------------------------

HealthPotion = class('HealthPotion', Item)

function HealthPotion:initialize()
    self:init{
        name = 'Health potion',
        usable = true,
        icon = Point(160, 0),
        image = Game.images.extras
    }
end

function HealthPotion:use(game)
    game:remove_item(self)
    game.health = math.min(game.health + 10, game.max_health)
end

--------------------------------------------------------------------------------

return Item