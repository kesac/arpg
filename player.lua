
-- ARPG Prototype 2015
-- turtlesort.com
-- Kevin Sacro

local player = game.entity.new('player')
player:setSprite('healer_m.png')

function player:updateMovement(dt, forceVector)

    if love.keyboard.isDown('up') then forceVector.y = -1
    elseif love.keyboard.isDown('down') then forceVector.y = 1 end
    
    if love.keyboard.isDown('left') then forceVector.x = -1
    elseif love.keyboard.isDown('right') then forceVector.x = 1 end

end

function player.keypressed(key,unicode)

    if key == 'x' then

        local radius = 12
        local slash = game.entity.new('slash', love.physics.newCircleShape(radius))

        slash.speed = 10000
        slash.duration = 0.08
        
        slash.draw = function(self)
            love.graphics.setColor(0,0,255,255)
            love.graphics.circle('line', self.x, self.y, radius)
        end
        
        game.entities:add(slash)
        slash:initializeBody()
        slash.physics.body:setMass(0.75)
        slash.physics.body:setLinearDamping(0)

        local vector = game.vector.new(0,0) + game.vector.new(player.physics.body:getLinearVelocity())
        local distance = 25
        
        if game.vector.new(player.physics.body:getLinearVelocity()):len() > 0 then
            distance = distance + 10
            slash.speed = slash.speed * 1.5
        end
        
        if player.direction == 'up' then
            vector.y = vector.y - 1
            slash:setLocation(player.x, player.y - distance)
        elseif player.direction == 'down' then
            vector.y = vector.y + 1
            slash:setLocation(player.x, player.y + distance)
        elseif player.direction == 'left' then
            vector.x = vector.x - 1
            slash:setLocation(player.x - distance, player.y)
        elseif player.direction == 'right' then
            vector.x = vector.x + 1
            slash:setLocation(player.x + distance, player.y)
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