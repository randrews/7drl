require('middleclass')
require('Map')
require('Point')

Game = class('Game')

function Game:initialize()
    self.map = Map.new_from_strings{
        "                                        ",
        "                                        ",
        "                                        ",
        "                                        ",
        "                                        ",
        "                             #######    ",
        "            ###############  #.....#    ",
        "            #.............#  #.....#    ",
        "            #.............#  ##.####    ",
        "            #.............#   #.#       ",
        "            #.............#...#.#       ",
        "            #.............#####.#       ",
        "            #...@...............#       ",
        "            #.............#######       ",
        "            #.............#             ",
        "            ###.###########             ",
        "              #.#                       ",
        "              #.#                       ",
        "              #.#           #####       ",
        "              #.#############...#       ",
        "              #.................#       ",
        "              #.#############...#       ",
        "              #.#           #...#       ",
        "     ##########.#########   #...#       ",
        "     #..................#   #####       ",
        "     #..................#               ",
        "     #..................#               ",
        "     #..................#               ",
        "     ####################               ",
        "                                        ",
        "                                        ",
        "                                        ",
        "                                        ",
        "                                        ",
        "                                        ",
        "                                        ",
        "                                        ",
        "                                        ",
        "                                        ",
        "                                        ",
    };

    self.player_loc = self.map:find_value('@'):shift()
end

function Game:draw()
    local g = love.graphics

    g.push()
    g.setScissor(0, 0, 40*20, 40*15)
    g.translate(
            -(self.player_loc.x*40 - 9.5*40),
            -(self.player_loc.y*40 - 7*40))

    for pt in self.map:each(self.player_loc-Point(10, 8), 21, 16) do
        local c = self.map:at(pt)
        if c == '#' then g.setColor(128, 128, 128)
        elseif c == '.' then g.setColor(0, 128, 0)
        else g.setColor(0, 0, 0) end

        g.rectangle('fill', pt.x*40, pt.y*40, 40, 40)
        g.setColor(255, 0, 0)
        g.rectangle('line', pt.x*40, pt.y*40, 40, 40)
    end

    g.pop()
end