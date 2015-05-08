
local scene = {}

function scene.load()

    data = {}
    data.key = 'value'
    data.nested = {}
    data.nested.name = 'John'
    data.nested.level = 17
    data.flags = {}
    data.flags.hasFinishedFireTemple = true
    
    game.data.save(data, 'gamedata2')
    
    loadedData = require 'gamedata2'
    print('Loaded nested level:' .. loadedData.nested.level)

    game.async.run(
        function(callback)
            game.text.displayText(
                {
                    "{#7755EE}???{#white}",
                    "Hello adventurer! You've",
                    "finally woken up!",

                    "{#7755EE}Alice{#white}",
                    "My name is Alice. You have",
                    "been asleep for 14 days{$9}...{$1}",

                    "{#7755EE}Alice{#white}",
                    "We have much to talk about.",
                    "Come to me once you're up!",
                },
                callback
            )
        end,
        function(callback)
            game.text.displayText(
                {
                    "Page 2"
                },
                callback
            )    
        end,
        function(callback)
            game.text.displayText(
                {
                    "Page 3",
                },
                callback
            )    
        end,
        function()
            game.transitionTo('test2')
        end
    )
    

end

function scene.unload()
    print('scene-test unloaded')
end

function scene.update(dt)
	
end

function scene.draw()
     love.graphics.setColor(255, 255, 255)
	 love.graphics.print("Hello World!", 200, 400)
end

return scene