
-- ARPG Prototype 2015
-- turtlesort.com
-- Kevin Sacro

local entity = {}
local _tileWidth = love.physics.getMeter() or 1

function entity.new(id)

    local newEntity = require('libtsl.observable').new()
    newEntity.id = id
    newEntity.canMove = true

    newEntity.x = 50
    newEntity.y = 150
    newEntity.tileX = entity._toTileCoordinate(newEntity.x)
    newEntity.tileY = entity._toTileCoordinate(newEntity.y)
    

    newEntity.mode = 'moving'
    newEntity.direction = 'down'
    
    newEntity.initializePhysics = entity.initializePhysics
    newEntity.setSprite = entity.setSprite
    
    newEntity.stopMovement = entity.stopMovement
    newEntity.moveToTile = entity.moveToTile
    newEntity.update = entity.update
    newEntity.draw = entity.draw
    
    newEntity._preInteract = entity._preInteract
    newEntity.onInteract = entity.onInteract
    newEntity._postInteract = entity._postInteract
    
    return newEntity

end

function entity:initializePhysics(physicsWorld)
    self.speed = 2000
    self.friction = 20
    self.radius = 16
    
    self.physics = {}
    self.physics.world = physicsWorld
    self.physics.shape = love.physics.newCircleShape(self.radius)
    self.physics.body = love.physics.newBody(physicsWorld, self.x, self.y, 'dynamic')
    self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)
    self.physics.body:setLinearDamping(self.friction)

    self.destroyBody = entity.destroyBody
    self.restoreBody = entity.restoreBody
end

function entity:setSprite(imagePath)
    self.image = love.graphics.newImage(imagePath)
    self.sprite = {}
    self.sprite.moving = {}
    self.sprite.moving.up    = game.sprite.create(self.image, 4, 4, 0.15, 1,  4):loop()
    self.sprite.moving.down  = game.sprite.create(self.image, 4, 4, 0.15, 9,  12):loop()
    self.sprite.moving.down  = game.sprite.create(self.image, 4, 4, 0.15, 9,  12):loop()
    self.sprite.moving.left  = game.sprite.create(self.image, 4, 4, 0.15, 13, 16):loop()
    self.sprite.moving.right = game.sprite.create(self.image, 4, 4, 0.15, 5,  8):loop()
    
    self.sprite.stationary = {}
    self.sprite.stationary.up    = game.sprite.create(self.image, 4, 4, 0.15, 2,  2):loop()
    self.sprite.stationary.down  = game.sprite.create(self.image, 4, 4, 0.15, 10, 10):loop()
    self.sprite.stationary.left  = game.sprite.create(self.image, 4, 4, 0.15, 14, 14):loop()
    self.sprite.stationary.right = game.sprite.create(self.image, 4, 4, 0.15, 6,  6):loop()
end

function entity._toTileCoordinate(coordinate)
    return math.floor(coordinate/_tileWidth)
end

function entity:moveToTile(tileX, tileY)
    self.tileX = tileX
    self.tileY = tileY

    self.x = self.tileX * _tileWidth + _tileWidth/2
    self.y = self.tileY * _tileWidth + _tileWidth/2

    self.physics.body:setX(self.x)
    self.physics.body:setY(self.y)
end

function entity:stopMovement()
    self.physics.body:setLinearVelocity(0,0)
end

function entity:restoreBody(physicsWorld)

    self.physics.body = love.physics.newBody(physicsWorld, self.x, self.y, 'dynamic')
    self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)
    self.physics.body:setLinearDamping(self.friction)
end

function entity:destroyBody()
    self.physics.body:destroy()
    self.physics.body = nil
end


function entity:update(dt)


    if self.canMove then
    
        local force = game.vector.new(0,0)

        if self.updateMovement then
            self:updateMovement(dt, force)
        end
        
        force:normalize_inplace() 
        force = force * self.speed

        self.physics.body:applyForce(force.x, force.y)

        self.x = self.physics.body:getX()
        self.y = self.physics.body:getY()

        local newTileX = entity._toTileCoordinate(self.x)
        local newTileY = entity._toTileCoordinate(self.y)
        
        if newTileX ~= self.tileX or newTileY ~= self.tileY then
            self.notifyObservers(self.id, 'onenter', newTileX, newTileY)
            self.notifyObservers(self.id, 'onleave', self.tileX, self.tileY)
            self.tileX = newTileX
            self.tileY = newTileY
        end

        if force.x > 0 then
            self.direction = 'right'
        elseif force.x < 0 then
            self.direction = 'left'
        end
        
        if force.y > 0 then
            self.direction = 'down'
        elseif force.y < 0 then
            self.direction = 'up'
        end
        
    end
    
    -- find out which sprite animation to play based on what direction and speed
    -- the self physics body is doing
    local dx, dy = self.physics.body:getLinearVelocity()
    if math.abs(dx) + math.abs(dy) > 50 then
        self.mode = 'moving'
    else
        self.mode = 'stationary'
    end


    self.sprite.current = self.sprite[self.mode][self.direction]
    self.sprite.current.x = self.x - 32
    self.sprite.current.y = self.y - 36 - 20

    self.sprite.current:update(dt)
    --end
end

function entity:draw()

    love.graphics.setColor(255,255,255,255)
    
    if self.sprite.current then
        self.sprite.current:draw()
    end

    if game.debug then
        love.graphics.setColor(0,0,255,255)
        love.graphics.circle('line', self.x, self.y, self.radius)
    end
end

function entity:_preInteract(sourceEntity)

    -- It's weird to keep moving when something is interacting with us
    self:stopMovement()
    self.canMove = false
    
    -- Face the entity that is interacting with us
    if sourceEntity.direction == 'left' then
        self.direction = 'right'
    elseif sourceEntity.direction == 'right' then
        self.direction = 'left'
    elseif sourceEntity.direction == 'up' then
        self.direction = 'down'
    else
        self.direction = 'up'
    end
end

function entity:onInteract(sourceEntity)
    if self.interact then
        self:_preInteract(sourceEntity)
        self.interact(function()
            self:_postInteract(sourceEntity)
        end)
    end
end

function entity:_postInteract(sourceEntity)
    self.canMove = true
end


return entity