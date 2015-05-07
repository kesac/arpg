
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
    
    manager.getEntityAtTile = lib.getEntityAtTile
        
    manager.restorePhysicsBodies = lib.restorePhysicsBodies
    manager.removePhysicsBodies = lib.removePhysicsBodies
    manager.clear = lib.clear
    manager.update = lib.update
    manager.draw = lib.draw

    return manager
end

function lib:add(entity)
    entity:initializePhysics(self.physicsWorld)
    table.insert(self.entities,entity)
end

function lib:addNPC(id, imagePath, x, y)
    local entity = require('entity').new(id)
    entity.x = x or 0
    entity.y = y or 0

    entity:setSprite(imagePath)
    entity:initializePhysics(self.physicsWorld)
    entity.updateMovement = require('entitymovement').basicRandom

    table.insert(self.entities,entity)

    return entity
end

function lib:getEntityAtTile(tileX, tileY)

    for i = 1, #self.entities do
        if tileX == self.entities[i].tileX and tileY == self.entities[i].tileY then
            return self.entities[i]
        end
    end
    
    return nil
    
end

function lib:removePhysicsBodies()
    for i = #self.entities, 1, -1 do
        self.entities[i]:destroyBody()
    end
end

function lib:restorePhysicsBodies()
    for i = 1, #self.entities do
        self.entities[i]:restoreBody(self.physicsWorld)
    end
end

function lib:clear()
    for i = #self.entities, 1, -1 do
        self.entities[i]:destroyBody()
        table.remove(self.entities, i)
    end
end

function lib:update(dt)

    for i = #self.entities, 1, -1 do
        local entity = self.entities[i]
        if entity.update then
            entity:update(dt)
        
            if entity.duration and entity.duration <= 0 then
                entity:destroyBody()
                table.remove(self.entities, i)
            end
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




return lib