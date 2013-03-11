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
    }

    Game.quads.walls = {
        se = love.graphics.newQuad(20, 20, 20, 20, 520, 160),
        sw = love.graphics.newQuad(80, 20, 20, 20, 520, 160),
        ne = love.graphics.newQuad(20, 80, 20, 20, 520, 160),
        nw = love.graphics.newQuad(80, 80, 20, 20, 520, 160),

        s = love.graphics.newQuad(40, 20, 40, 20, 520, 160),
        n = love.graphics.newQuad(40, 80, 40, 20, 520, 160),
        e = love.graphics.newQuad(20, 40, 20, 40, 520, 160),
        w = love.graphics.newQuad(80, 40, 20, 40, 520, 160),

        se_inner = love.graphics.newQuad(420, 20, 20, 20, 520, 160),
        sw_inner = love.graphics.newQuad(440, 20, 20, 20, 520, 160),
        ne_inner = love.graphics.newQuad(420, 40, 20, 20, 520, 160),
        nw_inner = love.graphics.newQuad(440, 40, 20, 20, 520, 160),
    }
end

-- Add start-of-game items, etc
function Game.static.start(game)
    local clothes = Clothes()
    clothes:activate(game)
    game:add_item(clothes)

    local dagger = Dagger()
    dagger:activate(game)
    game:add_item(dagger)

    for n = 1, 2 do -- Start with two pots
        local potion = HealthPotion()
        game:add_item(potion)
    end
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

    self.maze = MapGenerator().map
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
            self:draw_wall(pt)
        elseif c == '.' then
            g.drawq(Game.images.floors, Game.quads.floor, pt.x*40, pt.y*40)
            g.drawq(Game.images.floors, Game.quads.floor, pt.x*40+20, pt.y*40)
            g.drawq(Game.images.floors, Game.quads.floor, pt.x*40, pt.y*40+20)
            g.drawq(Game.images.floors, Game.quads.floor, pt.x*40+20, pt.y*40+20)
        else
        end
    end

    self:draw_player()

    g.pop()
    g.setScissor()
    self.sidebar:update()

    for pt in self.maze:each() do
        g.setColor(0, 0, 0)
        g.rectangle('fill', pt.x*8, pt.y*8, 8, 8)
        g.setColor(255, 255, 255)
        local t = self.maze:at(pt)
        if t.n then g.line(pt.x*8+4, pt.y*8+4, pt.x*8+4, pt.y*8) end
        if t.s then g.line(pt.x*8+4, pt.y*8+4, pt.x*8+4, pt.y*8+8) end
        if t.e then g.line(pt.x*8+4, pt.y*8+4, pt.x*8+8, pt.y*8+4) end
        if t.w then g.line(pt.x*8+4, pt.y*8+4, pt.x*8, pt.y*8+4) end
    end
end

function Game:draw_wall(pt)
    local g = love.graphics
    local function neighbor(dir)
        local t = self.map:at(pt + dir)
        return t == '.' or t == ','
    end

    local n = neighbor(Point.north)
    local s = neighbor(Point.south)
    local e = neighbor(Point.east)
    local w = neighbor(Point.west)

    if n then
        g.drawq(Game.images.walls, Game.quads.walls.n, pt.x*40, pt.y*40)
    end

    if s then
        g.drawq(Game.images.walls, Game.quads.walls.s, pt.x*40, pt.y*40+20)
    end

    if e then
        g.drawq(Game.images.walls, Game.quads.walls.e, pt.x*40+20, pt.y*40)
    end

    if w then
        g.drawq(Game.images.walls, Game.quads.walls.w, pt.x*40, pt.y*40)
    end

    if neighbor(Point.southeast) then
        if not s and not e then
            g.drawq(Game.images.walls, Game.quads.walls.se, pt.x*40+20, pt.y*40+20)
        elseif s and e then
            g.drawq(Game.images.walls, Game.quads.walls.se_inner, pt.x*40+20, pt.y*40+20)
        end
    end

    if neighbor(Point.southwest) then
        if not s and not w then
            g.drawq(Game.images.walls, Game.quads.walls.sw, pt.x*40, pt.y*40+20)
        elseif s and w then
            g.drawq(Game.images.walls, Game.quads.walls.sw_inner, pt.x*40, pt.y*40+20)
        end
    end

    if neighbor(Point.northeast) then
        if not n and not e then
            g.drawq(Game.images.walls, Game.quads.walls.ne, pt.x*40+20, pt.y*40)
        elseif n and e then
            g.drawq(Game.images.walls, Game.quads.walls.ne_inner, pt.x*40+20, pt.y*40)
        end
    end

    if neighbor(Point.northwest) then
        if not n and not w then
            g.drawq(Game.images.walls, Game.quads.walls.nw, pt.x*40, pt.y*40)
        elseif n and w then
            g.drawq(Game.images.walls, Game.quads.walls.nw_inner, pt.x*40, pt.y*40)
        end
    end
end

function Game:draw_player()
    local g = love.graphics

    g.drawq(Game.images.chars, Game.quads.player,
            self.player_loc.x * 40 + 4,
            self.player_loc.y * 40 + 4)

    local armor = self.inventory:select(function(i) return i.category == 'armor' and i.active end):shift()
    local weapon = self.inventory:select(function(i) return i.category == 'weapon' and i.active end):shift()

    if armor then
        g.drawq(armor.image, armor.paperdoll_quad, 
                self.player_loc.x * 40 + 4,
                self.player_loc.y * 40 + 4)
    end

    if weapon then
        g.drawq(weapon.image, weapon.paperdoll_quad, 
                self.player_loc.x * 40 + 4,
                self.player_loc.y * 40 + 4)
    end
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
