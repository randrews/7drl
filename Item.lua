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

    if self.paperdoll then
        local w = self.image:getWidth()
        local h = self.image:getHeight()
        self.paperdoll_quad = love.graphics.newQuad(
            self.paperdoll.x, self.paperdoll.y,
            32, 32,
            w, h)
    end
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

Clothes = class('Clothes', Item)

function Clothes:initialize()
    self:init{
        name = 'Clothes',
        category = 'armor',
        wearable = true,
        icon = Point(3168, 0),
        paperdoll = Point(3136, 0),
        image = Game.images.equipment
    }
end

function Clothes:on_activate(game)
    game.armor = 1
end

function Clothes:on_deactivate(game)
    game.armor = 0
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