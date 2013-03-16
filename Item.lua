require('middleclass')
require('Point')

Item = class('Item')

function Item:init(opts)
    self.name = opts.name ; assert(self.name)
    -- Only one item of a category can be active at a time
    self.category = opts.category
    self.active = opts.active
    self.icon = opts.icon ; assert(instanceOf(Point, self.icon))
    self.paperdoll = opts.paperdoll ; assert(not self.paperdoll or instanceOf(Point, self.paperdoll))
    self.image = opts.image ; assert(self.image)
    self.usable = opts.usable
    self.wearable = opts.wearable
    self.description = opts.description ; assert(self.description)

    if self.paperdoll then
        local w = self.image:getWidth()
        local h = self.image:getHeight()
        self.paperdoll_quad = love.graphics.newQuad(
            self.paperdoll.x, self.paperdoll.y,
            32, 32,
            w, h)
    end
end

function Item:create_tooltip()
    local tooltip = loveframes.Create('tooltip')
    tooltip:SetTextMaxWidth(150)
    tooltip:SetPadding(5)
    tooltip:SetOffsets(-165, 5)
    tooltip:SetText(self.name .. " \n \n " .. self.description)
    return tooltip
end

function Item:create_icon(parent)
    local icon = loveframes.Create('image', parent)
    icon:SetImage(self.image)
    icon:SetSize(32, 32)
    icon:SetOffset(self.icon())
    self:create_tooltip():SetObject(icon)
    return icon
end

function Item:create_panel(panel, sidebar)
    local icon = self:create_icon(panel)
    icon:SetPos(0, 0)

    self.label = loveframes.Create('text', panel)
    self.label:SetPos(42, 10)
    self.label:SetText(self.name)
    self:create_tooltip():SetObject(self.label)

    self:create_tooltip():SetObject(panel)

    if self.usable then
        self.use_button = loveframes.Create('button', panel)
        self.use_button:SetSize(32, 32)
        self.use_button:SetPos(148, 0)
        self.use_button:SetText("Use")
        self.use_button.OnClick = function() self:use(sidebar.game) end
    elseif self.wearable then
        self.active_checkbox = loveframes.Create('checkbox', panel)
        self.active_checkbox:SetSize(24, 24)
        self.active_checkbox:SetPos(152, 4)
        self.active_checkbox:SetChecked(self.active, true)
        self.active_checkbox.OnChanged =
            function()
                if self.active_checkbox:GetChecked() then
                    self:activate(sidebar.game)
                else
                    self:deactivate(sidebar.game)
                end
            end
    end
end

function Item:deactivate(game)
    self.active = false

    if self.active_checkbox then
        self.active_checkbox:SetChecked(false, true)
    end

    self:on_deactivate(game)
end

function Item:activate(game)
    if self.category then
        game.inventory:map(function(i)
                               if i.category == self.category and i.active then
                                   i:deactivate(game)
                               end
                           end)
    end

    if self.active_checkbox then
        self.active_checkbox:SetChecked(true, true)
    end

    self.active = true
    self:on_activate(game)
end

-- Override me
function Item:on_deactivate(game) end
function Item:on_activate(game) end
function Item:on_use(game) print("Using " .. self.name) end

--------------------------------------------------------------------------------

HealthPotion = class('HealthPotion', Item)

function HealthPotion:initialize()
    self:init{
        name = 'Health Potion',
        usable = true,
        icon = Point(160, 0),
        image = Game.images.extras,
        description = "A bright red potion. It looks healthy. \n (Restores up to 10 health)"
    }
end

function HealthPotion:use(game)
    if game.health == game.max_health then
        game:log("You don't feel you need to drink this now.")
    else
        game:remove_item(self)
        local new_health = math.min(game.health + 10, game.max_health)
        game:show_damage(game.player_loc, new_health - game.health)
        game.health = new_health
        game:log("You feel refreshed!", {0, 160, 0})
        game:tick() -- Using a potion counts as your turn
    end
end

--------------------------------------------------------------------------------

Gold = class('Gold', Item)

function Gold:initialize(value)
    self.value = value

    self:init{
        name = value .. ' gold',
        usable =  true, -- otherwise it'll dedupe it and give us gold
        icon = Point(128, 0),
        image = Game.images.extras,
        description = value .. " gold coins \n (increases your score)"
    }
end

--------------------------------------------------------------------------------

Mirror = class('Mirror', Item)

function Mirror:initialize()
    self:init{
        name = 'Magic Mirror',
        usable = true,
        icon = Point(0, 0),
        image = Game.images.custom,
        description = "Gazing into the mirror reveals the location of the staircase."
    }
end

function Mirror:use(game)
    local revealed = game:reveal(game.stairs_loc)
    game:reveal_items(revealed, false) -- Stairs are always in a room
    game.sidebar:redraw_minimap()
    game.sidebar.minimap.frame:SetVisible(true)
    game:remove_item(self)
    game:log("You see the way out!", {0, 0, 255})
    game:tick() -- Using a mirror counts as your turn
end

--------------------------------------------------------------------------------

Shoes = class('Shoes', Item)

function Shoes:initialize()
    self:init{
        name = 'Sneaking Shoes',
        category = 'shoes',
        wearable = true,
        icon = Point(32, 0),
        image = Game.images.custom,
        description = "These shoes make you much quieter \n (you will no longer awaken enemies by moving)"
    }
end

--------------------------------------------------------------------------------

AmuletStrength = class('AmuletStrength', Item)

function AmuletStrength:initialize()
    self:init{
        name = 'Strength Amulet',
        category = 'amulet',
        wearable = true,
        icon = Point(64, 0),
        image = Game.images.custom,
        description = "A glowing, fiery red amulet \n (increases damage by 2)"
    }
end

--------------------------------------------------------------------------------

AmuletSpeed = class('AmuletSpeed', Item)

function AmuletSpeed:initialize()
    self:init{
        name = 'Speed Amulet',
        category = 'amulet',
        wearable = true,
        icon = Point(102, 0),
        image = Game.images.custom,
        description = "A pale blue amulet \n (increases chance to hit by 15%)"
    }
end

--------------------------------------------------------------------------------

return Item