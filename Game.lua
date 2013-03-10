require('middleclass')
require('Map')
require('Point')
require('Sidebar')
require('Item')

Game = class('Game')

function Game.static.setup()
    Game.images = {}

    Game.images.chars = love.graphics.newImage("art/characters-32x32.png")
    Game.images.walls = love.graphics.newImage("art/wall-tiles-40x40.png")
    Game.images.floors = love.graphics.newImage("art/floor-tiles-20x20.png")
    Game.images.equipment = love.graphics.newImage("art/equipment-32x32.png")
    Game.images.extras = love.graphics.newImage("art/extras-32x32.png")

    Game.quads = {
        player = love.graphics.newQuad(0, 0, 32, 32, 320, 32),
        floor = love.graphics.newQuad(340, 0, 20, 20, 400, 260),
        wall = love.graphics.newQuad(300, 20, 40, 40, 520, 160),
    }
end

-- Add start-of-game items, etc
function Game.static.start(game)
    local clothes = Clothes()
    clothes:activate(game)
    game:add_item(clothes)

    for n = 1, 2 do -- Start with two pots
        local potion = HealthPotion()
        game:add_item(potion)
    end

    local clothes2 = Clothes()
    game:add_item(clothes2)
end

function Game:initialize(strs)
    self.map = Map.new_from_strings(strs)

    self.player_loc = self.map:find_value('@'):shift()
    self.map:at(self.player_loc, '.')

    self.bg_effect = {value=255}
    self.key_repeat_clock = nil
    self.freeze = false

    self.health = 20
    self.max_health = 20
    self.armor = 0
    self.level = 1
    self.score = 0
    self.inventory = List{}

    self.sidebar = Sidebar(self)
end

function Game:add_item(item)
    self.inventory:push(item)
    self.sidebar:add_item(item)
end

function Game:remove_item(item)
    self.inventory = self.inventory:select(function(i) return i ~= item end)
    self.sidebar:remove_item(item)
end

function Game:draw()
    local g = love.graphics

    if self.bg_effect then
        g.setColor(self.bg_effect.value, self.bg_effect.value, self.bg_effect.value)
    end

    g.push()
    g.setScissor(0, 0, 40*20, 40*15)
    g.translate(
            -(self.player_loc.x*40 - 9.5*40),
            -(self.player_loc.y*40 - 7*40))


    for pt in self.map:each(self.player_loc-Point(10, 8), 21, 16) do
        local c = self.map:at(pt)

        if c == '#' then
            g.drawq(Game.images.walls, Game.quads.wall, pt.x*40, pt.y*40)
        elseif c == '.' then
            g.drawq(Game.images.floors, Game.quads.floor, pt.x*40, pt.y*40)
            g.drawq(Game.images.floors, Game.quads.floor, pt.x*40+20, pt.y*40)
            g.drawq(Game.images.floors, Game.quads.floor, pt.x*40, pt.y*40+20)
            g.drawq(Game.images.floors, Game.quads.floor, pt.x*40+20, pt.y*40+20)
        else
        end
    end

    g.drawq(Game.images.chars, Game.quads.player,
            self.player_loc.x * 40 + 4,
            self.player_loc.y * 40 + 4)

    g.pop()
    g.setScissor()
    self.sidebar:update()
end

function Game:keypressed(key)
    if self.freeze then return end -- Ignore all input, loveframes has the show

    local pt = Point[key]
    if pt then
        local new_loc = pt + self.player_loc
        if self.map:inside(new_loc) and self.map:at(new_loc) ~= '#' then
            self.player_loc = new_loc
        else
            self.bg_effect = Tween(140, 255, 0.5)
        end

        if not self.key_repeat_clock then
            self.key_repeat_clock = Clock(0.2, function() self:keypressed(key) end)
        end
    elseif key == 'escape' then
        self.sidebar:exit_dialog()
    end
end

function Game:keyreleased()
    if self.key_repeat_clock then
        self.key_repeat_clock:stop()
        self.key_repeat_clock = nil
    end
end

function Game:set_freeze(f)
    self.freeze = f
    if f then self:keyreleased() end
end
