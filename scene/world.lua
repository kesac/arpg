
-- ARPG Prototype 2015
-- turtlesort.com
-- Kevin Sacro

-- This scene is responsible for the main game. It coordinates,
-- updates, and renders the game world, including maps, 
-- player, and collisions.

local scene = {}

function scene.initialize(manager)

    game.maps = require 'libtsl.rpg.mapmanager'
    love.physics.setMeter(48)
    game.maps.tileWidth = love.physics.getMeter()

    game.maps.define('demo-start','maps/demo-map')
    game.maps.define('demo-basement','maps/demo-basement')
    game.maps.define('demo-outside','maps/demo-outside')
    
    game.maps.setCurrentMap('demo-start')
    game.entities = game.maps.currentMap.entities

    game.player  = require 'player' 
    game.player.addObserver(scene)

    game.player:setPhysicsWorld(game.maps.physics.world)
    game.player:initializeBody()
    game.player:setTileLocation(12,7)
    
    game.camera.target = game.player

    game.text.preDisplayText = function()
        game.player.canMove = false
        game.player:stopMovement()
    end
    
    game.text.postDisplayText = function ()
        game.player.canMove = true
    end

    game.maps.drawSprites = function()
        game.player:draw()
    end

end

function scene.update(dt)
	game.maps.physics.world:update(dt)
	game.maps.update(dt)
    game.player:update(dt)
    
    if game.camera.target then
        game.camera:lookAt(math.floor(game.camera.target.x), math.floor(game.camera.target.y))
    end

    -- centered on map
    --game.camera:lookAt(game.maps.currentMap.width/2 * game.maps.tileWidth, game.maps.currentMap.height/2 * game.maps.tileWidth)
end

function scene.draw()
    game.camera:attach()
	game.maps.draw()     -- the player is implicitly here inbetween map layers (see initialize() above)

    if game.debug then
        love.graphics.setColor(255, 0, 0, 255)
        game.maps.currentMap:drawWorldCollision(game.maps.physics.mapCollision)

        local bodies = game.maps.physics.world:getBodyList()
        
        love.graphics.setColor(0, 255, 0, 255)
        for i=1,#bodies do
            local body = bodies[i]
            love.graphics.circle("line", body:getX(), body:getY(), 10)
        end
        --]]
    end

    game.camera:detach()
end

function scene.keypressed(key,unicode)
    game.player.keypressed(key,unicode)
end

-- This scene listens to events the player script generates
-- and handles them here
function scene.notify(source, eventTrigger, ...)

    if source == 'player' then
        local args = {...}

        if not args[1] or not args[2] then -- expected to be x and y tile coordinates
            return
        end

        if eventTrigger == 'oninteract' and game.entities then
            local entity = game.entities:getEntityAtTile(args[1], args[2])

            if entity and entity.interact then
                entity:onPlayerInteract(game.player)
                return
            end
        end
        
        local mapEvent = game.maps.getEventAtTile(args[1], args[2], eventTrigger)
        
        if mapEvent then
            scene.handleEventAction(mapEvent.action)
        end

    end

end

function scene.handleEventAction(action)

    local tokens = game.utf8.split2(action,' ')
    local command = game.utf8.trim(tokens[1])

    if command == 'warpto' then -- warpto <mapname> <tilex> <tiley> [direction to face]

        local newMap = game.utf8.trim(tokens[2])
        local newTileX = tokens[3] or 1
        local newTileY = tokens[4] or 1
        
        local newDirection = game.player.direction
        
        if tokens[5] then
            newDirection = game.utf8.trim(tokens[5])
        end

        game.player.canMove = false
        game.player:stopMovement() -- reduces velocity to 0
        
        -- We transition to ourselves to make use of the fadeout/in
        -- ability of the scenemanager.
        game.transitionTo('world', 
            function()
                game.maps.setCurrentMap(newMap)
                game.entities = game.maps.currentMap.entities

                --game.player.setPhysicsWorld(game.maps.physics.world) -- physics world has changed because of new map
                game.player:setTileLocation(newTileX, newTileY)
                game.player.direction = newDirection
            end,
            function()
                game.player.canMove = true
            end
        )

    else
        -- pass on this command to the map script to handle
        if game.maps.currentMap.script then
            game.maps.currentMap.script.notify(command)
        end
    end -- if

end

return scene
