Game = class('Game')

Game:include(Drawing)
Game:include(DamageEffect)

function Game.static.setup()
    Game.images = {}

    Game.images.chars = love.graphics.newImage("art/characters-32x32.png")
    Game.images.walls = love.graphics.newImage("art/wall-tiles-40x40.png")
    Game.images.floors = love.graphics.newImage("art/floor-tiles-20x20.png")
    Game.images.equipment = love.graphics.newImage("art/custom-equipment-32x32.png")
    Game.images.extras = love.graphics.newImage("art/extras-32x32.png")
    Game.images.decoration = love.graphics.newImage("art/decoration-20x20-40x40.png")
    Game.images.custom = love.graphics.newImage("art/custom-32x32.png")

    Game.quads = {
        player = love.graphics.newQuad(0, 0, 32, 32, 320, 32),
        floor = love.graphics.newQuad(340, 0, 20, 20, 400, 260),
        hall_floor = love.graphics.newQuad(160, 80, 20, 20, 400, 260),
        door = love.graphics.newQuad(40, 200, 40, 40, 120, 260),
        open_door = love.graphics.newQuad(80, 200, 40, 40, 120, 260),
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

    -- Remove me before release!
    -- game:add_item(DevWand())
    -- game:add_item(ShortSword())
    -- game:add_item(Hammer())
    -- game:add_item(Axe())
    -- game:add_item(Longsword())
    -- game:add_item(Spear())
    -- game:add_item(Mace())
    -- game:add_item(Leather())
    -- game:add_item(Chainmail())
    -- game:add_item(Plate())

    for n = 1, 2 do -- Start with two pots
        local potion = HealthPotion()
        game:add_item(potion)
    end

    game.health = 20
    game.max_health = 20
    game.armor = 0
    game.score = 0

    game:log("Welcome to the dungeon!")
end

--------------------------------------------------

function Game:initialize(strs)
    self.sidebar = Sidebar(self)
    self.inventory = List{}
    self.health = 0
    self.max_health = 0
    self.armor = 0
    self.level_num = 0
    self.score = 0
    self.bg_effect = {value=255}
    self.key_repeat_clock = nil
    self.freeze = false -- When frozen, ignore kbd input

    self:next_level()
end

function Game:next_level()
    self.level_num = self.level_num + 1
    self.level = Level.LEVELS[self.level_num]
    self.generator = MapGenerator()
    self.map = self.generator.map

    local hp = self.health / self.max_health
    self.max_health = self.level.max_health
    self.health = math.ceil(self.level.max_health * hp)

    self.visibility = Map(self.map.width, self.map.height)
    self.map_items = SparseMap(self.map.width, self.map.height)
    self.decoration = SparseMap(self.map.width, self.map.height)
    self.visibility:clear(false)

    self.player_loc = self.map:find_value('@'):shift()
    self.map:at(self.player_loc, '.')

    self.stairs_loc = self.map:find_value('='):shift()
    self.map:at(self.stairs_loc, '.')

    if Level.LEVELS[self.level_num + 1] then -- Stairs, to the next level
        self.map_items:at(self.stairs_loc, Stairs())
    else -- This is the last level! A scepter for the winner.
        self.map_items:at(self.stairs_loc, Scepter())
    end

    self:reveal(self.player_loc)
    self.sidebar:redraw_minimap()
end

function Game:reveal(pt)
    local v = self.map:at(pt)
    local hidden = self.map:connected_value(pt, v)
    hidden:each(function(pt)
                    self.visibility:at(pt, true)
                    -- Also reveal all the neighbors, so we get to see
                    -- pretty walls
                    self.map:neighbors(pt, nil, true):each(
                        function(pt)
                            self.visibility:at(pt, true)
                        end)
                end)

    return hidden
end

function Game:add_item(item)
    if instanceOf(Gold, item) then
        self.score = self.score + item.value
    elseif not item.usable and self:has_item(item.class) then
        -- We already got one; sell it
        self:log("You already have one of these, but you can sell it back in town.", {255, 255, 0})
        self.score = self.score + self.level_num * 25
    else
        self.inventory:push(item)
        self.sidebar:add_item(item)
    end
end

function Game:has_item(klass)
    return self.inventory:select(function(i) return instanceOf(klass, i) end):shift()
end

function Game:remove_item(item)
    self.inventory = self.inventory:select(function(i) return i ~= item end)
    self.sidebar:remove_item(item)
end

-- Move an item in self.map_items
function Game:move_item(old, new)
    local sm = self.map_items
    assert(new ~= old)
    assert(sm(old) ~= nil)
    assert(sm(new) == nil)
    self.map_items:at(new, self.map_items:at(old))
    self.map_items:delete(old)
end

-- Return the active item (if any) for the given category
function Game:active_item(category)
    return self.inventory:select(function(i)
                                     return i.active and i.category == category
                                 end):shift()
end

function Game:keypressed(key)
    if self.freeze then return end -- Ignore all input, loveframes has the show

    local pt = Point[key]
    if pt then
        local new_loc = pt + self.player_loc
        if self.map:inside(new_loc) and self.map:at(new_loc) ~= '#' then
            if self.map:at(new_loc) == '+' then -- Open door
                self:open_door(new_loc)
                self:tick()
            elseif self.map_items:at(new_loc) then
                local it = self.map_items:at(new_loc)
                it:bump(self, new_loc)
                self:tick()
            else
                self.player_loc = new_loc
                self:tick()

                if not self:active_item('shoes') then -- Don't make noise walking if we have shoes
                    self:make_noise()
                end
            end
        else
            self.bg_effect = Tween(140, 255, 0.5)
        end

        if not self.key_repeat_clock then
            -- First, make a clock to delay a second
            self.key_repeat_clock =
                Clock.oneoff(0.6,
                             function()
                                 -- Then, after a second, start repeating 0.1 secs
                                 self.key_repeat_clock =
                                     Clock(0.1, self.keypressed, self, key)
                             end)
        end
    elseif key == ' ' then
        self:tick()
    elseif key == 'escape' then
        self.sidebar:exit_dialog()
    elseif key == 'm' then
        self.sidebar:toggle_map()
    elseif key == 'l' then
        self.sidebar:toggle_log()
    end
end

-- returns a List of all points containing awake map items,
-- sorted by ascending distance from player
function Game:awake_items()
    local all_awake = {}
    for pt in self.map_items:each() do
        local it = self.map_items:at(pt)
        if it.awake then
            table.insert(all_awake, {pt, it})
        end
    end

    local p = self.player_loc
    table.sort(all_awake, function(a, b)
                              local da = p:dist(a[1])
                              return da < p:dist(b[1])
                          end)

    for n, i in ipairs(all_awake) do all_awake[n] = i[1] end
    return List(all_awake)
end

-- Do everything that needs doing every time the player takes a turn.
-- Client code (like Item.on_use) should call this!
-- (meaning, it's important it not need any parameters)
function Game:tick()
    local points = self:awake_items()
    local items = points:map(function(p) return self.map_items:at(p) end)

    for n = 1, points:length() do
        local p = points:at(n)
        items:at(n):tick(self, p)
    end

    if self.health <= 0 then -- Sorry, you are dead...
        self:set_freeze(true)
        local str = string.format(
            "You have died on level %s, \n with a score of %s. \n Would you like to try again?",
            self.level_num, self.score)
        local prom = utils.dialog('You have died', str, 'Restart', 'Quit', 35)

        prom:add(function(btn)
                     if btn == 'Quit' then
                         love.event.push('quit')
                         REALLY_QUIT = true
                     elseif btn == 'Restart' then
                         START_GAME()
                     end
                 end)
    end
end

-- Call this when the player does something that might make noise, like walking.
-- It should be called AFTER tick, so that things can't move as soon as they awaken.
function Game:make_noise()
    for pt in self.map_items:each(self.player_loc-Point(3, 3), 7, 7) do
        if self.player_loc:dist(pt, 3) then
            self.map_items:at(pt):hear(self, pt)
        end
    end
end

function Game:open_door(pt)
    self.map:at(pt, '_')

    local hidden = self.map:neighbors(pt, nil, true)

    hidden:each(function(p)
                    if not self.visibility:at(p) then
                        self.visibility:at(p, true)

                        local v = self.map:at(p)
                        if v == '.' or v == ',' then
                            local revealed = self:reveal(p)
                            self:reveal_items(revealed, v == ',')
                        end
                    end
                end)

    self.sidebar:redraw_minimap() -- This is a great candidate for pubsub
end

function Game:hit_player(enemy, damage)
    local blocked = self.armor
    local final = damage - blocked

    if damage == 0 then
        self:show_miss(self.player_loc)
        self:log("The " .. enemy.name .. " attacks you but misses.", {160, 0, 0})
    elseif final == 0 then
        self:show_clang(self.player_loc)
        self:log("The " .. enemy.name .. " is stopped by your armor.", {160, 160, 0})
    else
        self:show_damage(self.player_loc, -final)
        self.health = self.health - final
        self:log("The " .. enemy.name .. " attacks you for " .. damage .. " damage!", {255, 0, 0})
    end        
end

function Game:reveal_items(revealed, hallway)
    -- Drop the places, if any, that there's already an item.
    revealed = revealed:select(function(p) return not self.map_items:at(p) end)

    local num_enemies = 0
    local chest = false
    if hallway then
        num_enemies = math.floor(revealed:length() * self.level.hall_enemy_rate)
    else
        num_enemies = math.floor(revealed:length() * self.level.room_enemy_rate)
        chest = num_enemies >= self.level.chest_guards
    end

    -- Pull a random point out
    local function get_point()
        local i = math.random(#(revealed.items))
        return table.remove(revealed.items, i)
    end

    for n = 1, num_enemies do
        local p = get_point()
        local enemy = (self.level.enemies:random())()
        self.map_items:at(p, enemy)
    end

    if chest and math.random() <= self.level.chest_chance then
        local p = get_point()
        self.map_items:at(p, self.level:chest())
    end
end

function Game:log(str, color)
    self.sidebar:add_log_message(str, color)
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
