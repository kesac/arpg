
-- ARPG Prototype 2015
-- turtlesort.com
-- Kevin Sacro

-- Movement patterns for entities

local lib = {}

function lib:basicRandom(dt, force)
  
    if not self.movedelay then
        self.movedelay = 0
        self.forceduration = 0
        self.applyX = 0
        self.applyY = 0
    end

    if self.forceduration > 0 then
        force.x = self.applyX
        force.y = self.applyY
        self.forceduration = self.forceduration - dt

    elseif self.movedelay > 0 then
        self.movedelay = self.movedelay - dt
    else
        if love.math.random() < 0.50 then

            local direction = love.math.random()
            
            self.applyX = 0
            self.applyY = 0
            
            if  direction < 0.25 then
                self.applyX = -1
            elseif direction < 0.50 then
                self.applyX = 1
            elseif direction < 0.75 then
                self.applyY = -1
            else
                self.applyY = 1
            end
            
            self.forceduration = 0.25
            self.movedelay = 1
        end
    end
end

return lib