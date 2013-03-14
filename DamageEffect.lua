module(..., package.seeall)

function _M:show_damage(pt, dmg, delay)
    if not self.damage_effects then
        self.damage_effects = List()
    end

    self.damage_effects:push{
        damage = dmg,
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
                if d.damage < 0 then
                    g.setColor(255, 0, 0, d.transparency.value)
                elseif d.damage == 0 then
                    g.setColor(255, 255, 255, d.transparency.value)
                else
                    g.setColor(0, 255, 0, d.transparency.value)
                end

                local s = d.damage
                if d.damage == 0 then s = 'miss'
                elseif d.damage > 0 then s = '+' .. d.damage end

                g.printf(s, d.pt.x*40, d.pt.y*40+d.y.value, 40, 'center')
            end)

        self.damage_effects = self.damage_effects:select(
            function(d) return d.y:alive() end)

        g.setColor(c)
    end
end