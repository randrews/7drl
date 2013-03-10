require('middleclass')
require('loveframes')
require('inspect')

require('Point')
require('Clock')
require('List')
require('Map')
require('Tween')
require('Promise')

require('Game')
require('Sidebar')
require('Item')
require('Weapon')

LEVEL = {
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
    "            #.............#   #.#       ",
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
}

function love.load()
    math.randomseed(os.time())
    love.graphics.setBackgroundColor(15, 10, 10)
    loveframes.util.SetActiveSkin('Rogue')
    Game.setup()
    current_game = Game(LEVEL)
    Game.start(current_game)
end

function love.draw()
    if FPS then love.graphics.setColor(255, 255, 255) ; love.graphics.print(FPS, 0, 0) end
    current_game:draw()
    loveframes.draw()
end

function love.update(dt)
    FPS = math.floor(1 / dt)
    Clock.update(dt)
    Tween.update(dt)
    loveframes.update(dt)
end

function love.mousepressed(x, y, button)
    loveframes.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
    loveframes.mousereleased(x, y, button)
end

function love.keypressed(key, unicode)
    current_game:keypressed(key)
    loveframes.keypressed(key, unicode)
end

function love.keyreleased(key)
    current_game:keyreleased(key)
    loveframes.keyreleased(key)
end

function love.quit()
    if current_game and not REALLY_QUIT then
        current_game.sidebar:exit_dialog()
        return true
    end
end