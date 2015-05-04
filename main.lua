
-- ARPG Prototype 2015
-- turtlesort.com
-- Kevin Sacro

function love.load()

    -- libtsl: my personal library
    game         = require 'libtsl.scenemanager' -- state management
    game.utf8    = require 'libtsl.utf8'         -- utf8 string manipulation
    game.font    = require 'libtsl.font'         -- convenience object for font calls
	game.text    = require 'libtsl.rpg.text'     -- rpg-like text system
    game.data    = require 'libtsl.data'
    game.async   = require 'libtsl.async'
    game.sprite  = require 'libtsl.sprite'
    game.sprites = require 'libtsl.spritemanager'

    -- HUMP: vlrd's LÖVE Helper Utilities for Massive Progression
    game.camera  = require('hump.camera').new()
    game.timer   = require 'hump.timer'
    game.vector  = require 'hump.vector'

    -- kikito's Inspect for debugging
    game.inspect = require 'inspect.inspect'

    -- Some initial text setup
	-- game.font.setDefaultFont('fonts/ken_fonts/kenpixel.ttf')
    game.font.setDefaultFont('fonts/PressStart2P/PressStart2P.ttf')
	game.text.init(game.font.get(16))

    game.addScene(require 'scene.test', 'test')
    game.addScene(require 'scene.test2', 'test2')
    game.addScene(require 'scene.world', 'world')

    game.setCurrentScene('world')
    game.debug = false

end

function love.update(dt)
	game.update(dt) -- Update the current scene
    game.sprites.update(dt)
    game.text.update(dt) -- For text scrolling
    game.timer.update(dt)
end

function love.draw()
    game.camera:attach()
    game.draw() -- Draw the current scene
    game.sprites.draw()
    game.camera:detach()
    game.text.draw() -- To display text boxes
end

function love.keypressed(key,unicode)
	game.keypressed(key,unicode) -- Delegate event to current scene
end

function love.keyreleased(key)
	game.keyreleased(key) -- Delegate event to current scene
end