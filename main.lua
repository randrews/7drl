require('middleclass')
require('loveframes')
require('inspect')

require('Point')
require('Clock')
require('List')
require('Map')
require('SparseMap')
require('Tween')
require('Promise')
require('utils')

require('Drawing')
require('DamageEffect')
require('Game')
require('Sidebar')
require('Item')
require('Weapon')
require('Armor')
require('MapGenerator')
require('MapItem')
require('Enemy')
require('Decoration')
require('Level')

function love.load()
    math.randomseed(os.time())
    love.graphics.setBackgroundColor(15, 10, 10)
    loveframes.util.SetActiveSkin('Rogue')
    Game.setup()
    Decoration.setup()
    START_GAME()
end

function START_GAME()
    if current_game then
        current_game.sidebar.log_window.frame:SetVisible(false)
        current_game.sidebar.minimap.frame:SetVisible(false)
    end

    current_game = Game()
    Game.start(current_game)
end

function love.draw()
    -- if FPS then love.graphics.setColor(255, 255, 255) ; love.graphics.print(FPS, 0, 0) end
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
    if utils.capture_input() then
        utils.keypressed(key)
    else
        current_game:keypressed(key)
    end

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