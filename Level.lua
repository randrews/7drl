Level = class('Level')

function Level:initialize(opts)
    -- Possible enemies to spawn and possible chest items
    self.enemies = opts.enemies ; assert(self.enemies and self.enemies:length() > 0)
    self.chest_items = opts.chest_items ; assert(self.chest_items and self.chest_items:length() > 0)

    -- If an enemy rate is 0.1, then we draw an enemy every 10 cells
    -- There's a separate rate for halls and rooms
    self.hall_enemy_rate = opts.hall_enemy_rate ; assert(self.hall_enemy_rate)
    self.room_enemy_rate = opts.room_enemy_rate ; assert(self.room_enemy_rate)

    -- Odds that we'll put a chest in a room, from 0 to 1
    self.chest_chance = opts.chest_chance ; assert(self.chest_chance)

    -- Never place a chest in rooms with fewer than this many enemies
    self.chest_guards = opts.chest_guards or 0
end

--------------------------------------------------

Level.static.LEVELS = {
    -- 1 --------------------
    Level{
        enemies = List{Orc},
        chest_items = List{HealthPotion},
        hall_enemy_rate = 0,
        room_enemy_rate = 0.1,
        chest_chance = 0.5,
        chest_guards = 0,
    },
}

--------------------------------------------------

return Level