
-- ARPG Prototype 2015
-- turtlesort.com
-- Kevin Sacro

function love.load()

    -- libtsl: my personal library
    game         = require 'libtsl.scenemanager' -- state management
    game.utf8    = require 'libtsl.utf8'         -- utf8 string manipulation
    game.font    = require 'libtsl.font'         -- convenience object for font calls
	game.text    = require 'libtsl.rpg.text'     -- rpg-like text system
    game.data    = require 'libtsl.data'         -- save to file
    game.async   = require 'libtsl.async'
    game.sprite  = require 'libtsl.sprite'
    game.sprites = require 'libtsl.spritemanager'
    game.entity  = require 'libtsl.rpg.entity'

    -- HUMP: vlrd's LÖVE Helper Utilities for Massive Progression
    game.camera  = require('hump.camera').new()
    game.timer   = require 'hump.timer'
    game.vector  = require 'hump.vector'

    -- kikito's Inspect for debugging
    game.inspect = require 'inspect.inspect'

    game.addScene(require 'scene.world', 'world')
    game.setCurrentScene('world')

    -- The following are defined in the world scene:
    -- game.maps
    -- game.player
    -- game.entities (shortcut to entities of current map)

    game.font.setDefaultFont('fonts/PressStart2P/PressStart2P.ttf')
	game.text.init(game.font.get(16))    
    game.debug = false

    game.windowWidth = love.graphics.getWidth()
    game.windowHeight = love.graphics.getHeight()
    
end

function love.update(dt)
	game.update(dt)
    game.sprites.update(dt)
    game.text.update(dt)
    game.timer.update(dt)
end

function love.draw()

    game.draw()

    game.camera:attach()
    game.sprites.draw()
    game.camera:detach()

    game.text.draw()
end

function love.keypressed(key,unicode)
	game.keypressed(key,unicode)
    
    if key == 'escape' then
      love.event.quit()
    end

end

function love.keyreleased(key)
	game.keyreleased(key)
end