MapGenerator = class('MapGenerator')

function MapGenerator:initialize(level)
    self.level = level or 1
    self:generate()
end

--------------------------------------------------------------------------------

function MapGenerator:generate()
    self.maze = self:create_maze(10, 10)
    self:create_rooms(self.maze) -- Turn 1/3 of the cells into rooms
    self.map = self:expand(self.maze) -- Make a map that follows the layout of the maze
    self:add_walls(self.map) -- Add walls and doors
    -- self:place_monsters(self.map) -- Monsters!
    -- self:place_chests(self.map) -- Chests and treasure piles
    self:place_player(self.map) -- Player start and exit

    return self.map
end

function MapGenerator:create_maze(w, h)
    --Create an empty map
    local map = Map(w, h)
    for pt in map:each() do map:at(pt, {}) end

    -- Util fns
    local function empty(map, pt)
        local t = map:at(pt)
        return not t.n and not t.s and not t.e and not t.w
    end

    local function hall(map, pt)
        local t = map:at(pt)
        local c = 0
        if t.n then c = c + 1 end
        if t.s then c = c + 1 end
        if t.e then c = c + 1 end
        if t.w then c = c + 1 end

        local empty_neighbors = map:neighbors(pt, empty)
        return c == 2 and empty_neighbors:length() == 2
    end

    local function connect(a, b)
        if b == a+Point.north then
            map:at(a).n = true ; map:at(b).s = true
        elseif b == a+Point.south then
            map:at(a).s = true ; map:at(b).n = true
        elseif b == a+Point.east then
            map:at(a).e = true ; map:at(b).w = true
        elseif b == a+Point.west then
            map:at(a).w = true ; map:at(b).e = true
        else error("Points aren't adjacent: " .. a .. ", " .. b) end
    end

    local function random_walk(map, start)
        if map:neighbors(start, empty):empty() then return end

        local prev = start
        local curr = map:neighbors(start, empty):random()

        while curr do
            connect(prev, curr)
            prev = curr
            curr = map:neighbors(curr, empty):random()
        end

        local next = map:neighbors(prev):random()
        connect(prev, next)
    end

    ------------------------------

    local start = map:random()
    while start do
        random_walk(map, start)
        start = map:random(hall)
    end

    return map
end

function MapGenerator:create_rooms(maze)
    local function count(map, pt)
        local t = map:at(pt)
        local c = 0
        for k, v in pairs(t) do c = c + 1 end
        return c
    end

    for pt in maze:each() do
        local t = maze:at(pt)
        local c = count(maze, pt)
        if c > 0 and math.random(3) == 1 or c == 1 then
            t.room = true
        end
    end
end

function MapGenerator:expand(maze)
    local map = Map(maze.width*11, maze.height*11)

    -- Lay out hallways
    for pt in maze:each() do
        local t = maze:at(pt)
        if t.n then
            for n=0,5 do
                map:at(Point(pt.x*11+5, pt.y*11+n), ',')
            end
        end

        if t.s then
            for n=5, 10 do
                map:at(Point(pt.x*11+5, pt.y*11+n), ',')
            end
        end

        if t.e then
            for n=5, 10 do
                map:at(Point(pt.x*11+n, pt.y*11+5), ',')
            end
        end

        if t.w then
            for n=0, 5 do
                map:at(Point(pt.x*11+n, pt.y*11+5), ',')
            end
        end
    end

    -- Rooms
    for pt in maze:each() do
        local t = maze:at(pt)
        if t.room then
            local x = math.random(5)
            local y = math.random(5)
            local w = math.random(5)+(5-x)
            local h = math.random(5)+(5-y)

            for f in map:each(Point(pt.x*11 + x, pt.y*11 + y), w, h) do
                map:at(f, '.')
            end
        end
    end

    return map
end

function MapGenerator:add_walls(map)
    local function floor(map, pt) return map:at(pt) == '.' or map:at(pt) == ',' end
    local function room_floor(map, pt) return map:at(pt) == '.' end

    for pt in map:each() do
        if not floor(map, pt) and not map:neighbors(pt, floor, true):empty() then
            map:at(pt, '#')
        elseif map:at(pt) == ',' and not map:neighbors(pt, room_floor):empty() then
            map:at(pt, '+')
        end
    end
end

function MapGenerator:place_player(map)
    local function floor(map, pt) return map:at(pt) == '.' end
    map:at(map:random(floor), '@')
end

--------------------------------------------------------------------------------

return MapGenerator