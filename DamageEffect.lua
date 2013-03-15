module(..., package.seeall)

function _M:show_damage(pt, dmg, delay)
    if not self.damage_effects then
        self.damage_effects = List()
    end

    local col = nil
    if dmg < 0 then
        col = {255, 0, 0}
    elseif dmg == 0 then
        col = {255, 255, 255}
    else
        col = {0, 255, 0}
    end

    local s = tostring(dmg)
    if dmg > 0 then s = '+' .. dmg end
    

    self.damage_effects:push{
        damage = s,
        color = col,
        pt = pt,
        y = Tween(4, -16, delay or 1),
        transparency = Tween(255, 64, delay or 1)
    }
end

function _M:show_miss(pt, delay)
    if not self.damage_effects then
        self.damage_effects = List()
    end

    self.damage_effects:push{
        damage = 'miss',
        color = {255, 255, 255},
        pt = pt,
        y = Tween(4, -16, delay or 1),
        transparency = Tween(255, 64, delay or 1)
    }
end

function _M:show_clang(pt, delay)
    if not self.damage_effects then
        self.damage_effects = List()
    end

    self.damage_effects:push{
        damage = 'clang!',
        color = {255, 255, 0},
        pt = pt,
        y = Tween(4, -16, delay or 1),
        transparency = Tween(255, 64, delay or 1)
    }
end

function _M:draw_damage()
    if self.damage_effects and not self.damage_effects:empty() then
        local g = love.graphics
        local c = {g.getColor()}

        self.damage_effects:each(
            function(d)
                g.setColor(d.color[1], d.color[2], d.color[3], d.transparency.value)
                g.printf(d.damage, d.pt.x*40, d.pt.y*40+d.y.value, 40, 'center')
            end)

        self.damage_effects = self.damage_effects:select(
            function(d) return d.y:alive() end)

        g.setColor(c)
    end
end