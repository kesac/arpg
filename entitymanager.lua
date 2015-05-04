
-- ARPG Prototype 2015
-- turtlesort.com
-- Kevin Sacro

local lib = {}

function lib.new(physicsWorld)  
    local manager = {}
    manager.entities = {}
    manager.physicsWorld = physicsWorld

    manager.add = lib.add
    manager.addNPC = lib.addNPC
    
    manager.restoreBodies = lib.restoreBodies
    manager.destroyBodies = lib.destroyBodies
    manager.clear = lib.clear
    manager.update = lib.update
    manager.draw = lib.draw

    return manager
end

function lib:add(entity)
    table.insert(self.entities,entity)
end

function lib:addNPC(id, imagePath, x, y)
    local entity = require('entity').new(id)
    entity.x = x
    entity.y = y
    
    entity:setSprite(imagePath)
    entity:initializePhysics(self.physicsWorld)
    entity.updateMovement = lib._basicMovement
    
    table.insert(self.entities,entity)
end

function lib:destroyBodies()
    for i = #self.entities, 1, -1 do
        self.entities[i]:destroyBody()
    end
end

function lib:restoreBodies()
    for i = 1, #self.entities do
        self.entities[i]:restoreBody(self.physicsWorld)
    end
end

function lib:clear()
    for i = #self.entities, 1, -1 do
        local entity = self.entities[i]
        entity:destroy()
        table.remove(self.entities, i)
    end
end

function lib:update(dt)
    for _,entity in pairs(self.entities) do
        if entity.update then
            entity:update(dt)
        end
    end
end

function lib:draw()
    for _,entity in pairs(self.entities) do
        if entity.draw then
            entity:draw()
        end
    end
end



function lib:_basicMovement(dt, force)
  
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