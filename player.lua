
-- ARPG Prototype 2015
-- turtlesort.com
-- Kevin Sacro

local player = require('entity').new('player')
player:setSprite('healer_m.png')

function player:updateMovement(dt, forceVector)
    if love.keyboard.isDown('w') then forceVector.y = -1
    elseif love.keyboard.isDown('s') then forceVector.y = 1 end
    
    if love.keyboard.isDown('a') then forceVector.x = -1
    elseif love.keyboard.isDown('d') then forceVector.x = 1 end
end

function love.keypressed(key,unicode)
	if key == " " or key == "return" then
    
        if game.text.isVisible then
            game.text.advanceText()
        else
            local checkX = player.tileX
            local checkY = player.tileY
            
            player.notifyObservers(player.id,'oninteract', checkX, checkY)
            
            if player.direction == 'up' then
                checkY = checkY - 1
            elseif player.direction == 'down' then
                checkY = checkY + 1
            elseif player.direction == 'left' then
                checkX = checkX - 1
            elseif player.direction == 'right' then
                checkX = checkX + 1
            end
            
            player.notifyObservers(player.id,'oninteract', checkX, checkY)
            
        end
	end
    
end

return player