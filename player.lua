
-- ARPG Prototype 2015
-- turtlesort.com
-- Kevin Sacro

local player = require('entity').new('player')
player:setSprite('healer_m.png')

function player:updateMovement(dt, forceVector)

    if love.keyboard.isDown('up') then forceVector.y = -1
    elseif love.keyboard.isDown('down') then forceVector.y = 1 end
    
    if love.keyboard.isDown('left') then forceVector.x = -1
    elseif love.keyboard.isDown('right') then forceVector.x = 1 end

end

function love.keypressed(key,unicode)

    if key == 'x' then

        local slash = require('entity').new()

        slash.speed = 50000
        slash.mass = 1
        slash.shape = love.physics.newCircleShape(8)
        slash.friction = 0
        slash.duration = 0.05
        
        slash.draw = function(self)
            love.graphics.setColor(0,0,255,255)
            love.graphics.circle('line', self.x, self.y, self.physics.shape:getRadius())
        end
        
        game.entities:add(slash)

        local vector = game.vector.new(0,0)
        
        if player.direction == 'up' then
            vector.y = vector.y - 1
            slash:setLocation(player.x, player.y - 20)
        elseif player.direction == 'down' then
            vector.y = vector.y + 1
            slash:setLocation(player.x, player.y + 20)
        elseif player.direction == 'left' then
            vector.x = vector.x - 1
            slash:setLocation(player.x - 20, player.y)
        elseif player.direction == 'right' then
            vector.x = vector.x + 1
            slash:setLocation(player.x + 20, player.y)
        end

        slash:applyForce(vector, slash.speed)
        player.attackCooldown = 1
    
	elseif key == " " or key == "return" then
    
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