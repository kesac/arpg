
local scene = {}

function scene.load()
    print('scene-test2 loaded')

    local healer = love.graphics.newImage('healer_f.png')
    game.sprites.add('walkingDown', game.sprite.create(healer, 4, 4, 0.15, 9, 12))
    game.sprites.loop('walkingDown', 500, 300)
    
    --game.camera:rotateTo(0)
    --game.timer.tween(5, game.camera, {x = 500, y = 300}, 'in-out-quad')
end

function scene.draw()
    love.graphics.setColor(255, 255, 255)
    love.graphics.print("!!Hello World!!", 200, 400)
end

return scene