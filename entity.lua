
-- ARPG Prototype 2015
-- turtlesort.com
-- Kevin Sacro

local entity = {}
entity.tileWidth = love.physics.getMeter() or 1

function entity.new(id, shape)

    local newEntity = require('libtsl.observable').new()

    newEntity.id = id
    newEntity.x = 0
    newEntity.y = 0
    newEntity.tileX = entity._toTileCoordinate(newEntity.x)
    newEntity.tileY = entity._toTileCoordinate(newEntity.y)

    newEntity.canMove = true
    newEntity.mode = 'moving'
    newEntity.direction = 'down'

    newEntity.physics = {}
    newEntity.speed = 2000
    newEntity.friction = 20
    newEntity.physics.shape = shape or love.physics.newCircleShape(16)

    -- functions
    newEntity.setPhysicsWorld = entity.setPhysicsWorld
    newEntity.initializeBody = entity.initializeBody
    newEntity.destroyBody = entity.destroyBody
    
    newEntity.setSprite = entity.setSprite
    
    newEntity.applyForce = entity.applyForce
    newEntity.stopMovement = entity.stopMovement
    newEntity.setLocation = entity.setLocation
    newEntity.setTileLocation = entity.setTileLocation
    newEntity.update = entity.update
    newEntity.draw = entity.draw

    newEntity._prePlayerInteract = entity._prePlayerInteract
    newEntity.onPlayerInteract = entity.onPlayerInteract
    newEntity._postPlayerInteract = entity._postPlayerInteract

    return newEntity
end

function entity:setPhysicsWorld(physicsWorld)

    if self.physics.body then
        self:destroyBody()
    end

    self.physics.world = physicsWorld
      
end

function entity:setSprite(imagePath, spriteTable)
    self.image = love.graphics.newImage(imagePath)
    
    if spriteTable then
        self.sprite = spriteTable
    else
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
end

function entity:setLocation(x,y)
    self.x = x
    self.y = y
    self.tileX = x * entity.tileWidth
    self.tileY = y * entity.tileWidth
    
    if self.physics then
        self.physics.body:setX(x)
        self.physics.body:setY(y)
    end
end

function entity:setTileLocation(tileX, tileY)
    self.tileX = tileX
    self.tileY = tileY

    self.x = self.tileX * entity.tileWidth + entity.tileWidth/2
    self.y = self.tileY * entity.tileWidth + entity.tileWidth/2

    if self.physics then
        self.physics.body:setX(self.x)
        self.physics.body:setY(self.y)
    end
end

function entity:initializeBody()
    self.physics.body = love.physics.newBody(self.physics.world, self.x, self.y, 'dynamic')
    self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)
    self.physics.body:setLinearDamping(self.friction)
end

function entity:destroyBody()
    if self.physics.body then
        self.physics.body:destroy()
        self.physics.body = nil
    end
end

function entity:applyForce(vector,speed)
    if self.physics.body then
        vector:normalize_inplace()
        speed = speed or self.speed
        vector = vector * speed
        self.physics.body:applyForce(vector.x, vector.y)
    end
end

function entity:stopMovement()
    if self.physics.body then
        self.physics.body:setLinearVelocity(0,0)
    end
end

function entity:update(dt)

    if self.duration then
        self.duration = self.duration - dt
    end
    
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

    if self.sprite then
        self.sprite.current = self.sprite[self.mode][self.direction]
        self.sprite.current.x = self.x - 32
        self.sprite.current.y = self.y - 36 - 20

        self.sprite.current:update(dt)
    end
    --end
end

function entity:draw()

    love.graphics.setColor(255,255,255,255)
    
    if self.sprite.current then
        self.sprite.current:draw()
    end

    if game.debug then
        love.graphics.setColor(0,0,255,255)
        love.graphics.circle('line', self.x, self.y, self.physics.shape:getRadius())
    end
end

function entity:_prePlayerInteract(sourceEntity)

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

function entity:onPlayerInteract(sourceEntity)
    if self.interact then
        self:_prePlayerInteract(sourceEntity)
        self.interact(function()
            self:_postPlayerInteract(sourceEntity)
        end)
    end
end

function entity:_postPlayerInteract(sourceEntity)
    self.canMove = true
end

function entity._toTileCoordinate(coordinate)
    return math.floor(coordinate/entity.tileWidth)
end

return entity