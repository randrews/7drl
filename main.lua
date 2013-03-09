require('middleclass')
require('loveframes')

require('Point')
require('Clock')
require('List')
require('Map')
require('Tween')
require('Promise')

require('Game')

function love.load()
   math.randomseed(os.time())
   love.graphics.setBackgroundColor(0, 0, 20)
   Game.setup()
   current_game = Game()
end

function love.draw()
   if FPS then love.graphics.setColor(255, 255, 255) ; love.graphics.print(FPS, 0, 0) end
   loveframes.draw()
   current_game:draw()
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
   loveframes.keypressed(key, unicode)
end

function love.keyreleased(key)
   loveframes.keyreleased(key)
end