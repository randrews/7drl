module(..., package.seeall)

function Drawing:draw()
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
        local v = self.visibility:at(pt)

        if v then
            if c == '#' then
                self:draw_wall(pt)
            elseif c == '.' then
                self:draw_floor(pt, Game.quads.floor)
            elseif c == ',' then
                self:draw_floor(pt, Game.quads.hall_floor)
            elseif c == '+' then
                self:draw_floor(pt, Game.quads.hall_floor)
                g.drawq(Game.images.decoration, Game.quads.door, pt.x*40, pt.y*40)
            elseif c == '_' then
                self:draw_floor(pt, Game.quads.hall_floor)
                g.drawq(Game.images.decoration, Game.quads.open_door, pt.x*40, pt.y*40)
            else
            end

            if self.map_items:at(pt) then self:draw_item(pt) end
        end
    end

    self:draw_player()

    g.pop()
    g.setScissor()
    self.sidebar:update()
end

function Drawing:draw_item(pt)
    local item = self.map_items:at(pt)
    assert(item)

    local g = love.graphics
    g.drawq(item.image, item.quad, pt.x*40+4, pt.y*40+4)
end

function Drawing:draw_floor(pt, quad)
    local g = love.graphics
    g.drawq(Game.images.floors, quad, pt.x*40, pt.y*40)
    g.drawq(Game.images.floors, quad, pt.x*40+20, pt.y*40)
    g.drawq(Game.images.floors, quad, pt.x*40, pt.y*40+20)
    g.drawq(Game.images.floors, quad, pt.x*40+20, pt.y*40+20)
end

function Drawing:draw_wall(pt)
    local g = love.graphics
    local function neighbor(dir)
        local t = self.map:at(pt + dir)
        return t == '.' or t == ',' or t == '+' or t == '_'
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

function Drawing:draw_player()
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
