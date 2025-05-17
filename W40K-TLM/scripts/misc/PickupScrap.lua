local actualYRotation = 0
local transform;
local playerTrans = nil
local rotationSpeed = 100

local actualSize = Vector3.new(0, 0, 0)
local sizeSpeed = 2

local attractionSpeed = 2


local direction = true -- true = up, false = down
local offsetYPosition = 0
local initialYPosition = nil
local positionRangeOffset = 0.1
local positionSpeed = 3;


local time = 0
local frequency = 0.5
local amplitude = 0.1 

local onReadyDoned = false
local playerScript 

local pickUpRange = 5

--Audio
local scrapPickUpSFX = nil


function on_ready()
    -- Add initialization code here
    transform = self:get_component("TransformComponent")
    transform.rotation = Vector3.new(0, actualYRotation, 0)
    transform.scale = actualSize
    initialYPosition = transform.position.y

    local player = current_scene:get_entity_by_name("Player")
    playerTrans = player:get_component("TransformComponent")
    playerScript = player:get_component("ScriptComponent")


    onReadyDoned = true

    --Audio
    scrapPickUpSFX = current_scene:get_entity_by_name("ScrapPickUpSFX"):get_component("AudioSourceComponent")

end

function on_update(dt)
    -- Add update code here

    if not onReadyDoned then
        on_ready()
    end

    actualYRotation = actualYRotation + (dt * rotationSpeed)
    transform.rotation = Vector3.new(0, actualYRotation, 0)

    if(actualSize.x < 1) then
        actualSize = lerp(actualSize, Vector3.new(1,1,1), dt * sizeSpeed)
        if(actualSize.x > 1) then
            actualSize = Vector3.new(1, 1, 1)
        end
        transform.scale = actualSize
    end

    time = time + dt
    offsetYPosition = math.sin(time * frequency * 2 * math.pi) * amplitude
    transform.position.y = initialYPosition + offsetYPosition

    if playerTrans then
        updatePosition(dt) 
    end
    

end

function on_exit()
    -- Add cleanup code here
end

function lerp(a, b, t)
    return a + (b - a) * t
end

function updatePosition(dt)
    local playerPos = playerTrans.position
    local scrapPos = transform.position

    local distance = Vector3.new(
        math.abs(playerPos.x - scrapPos.x),
        math.abs(playerPos.y - scrapPos.y),
        math.abs(playerPos.z - scrapPos.z)
    )

    if distance.x < pickUpRange and distance.y < pickUpRange and distance.z < pickUpRange then
        local direction = Vector3.new(
            playerPos.x - scrapPos.x,
            playerPos.y - scrapPos.y,
            playerPos.z - scrapPos.z
        )

        local l = attractionSpeed * dt
        local p = Vector3.new(direction.x * l, direction.y * l, direction.z * l)
        local newPos = Vector3.new(
            scrapPos.x + p.x,
            scrapPos.y + p.y,
            scrapPos.z + p.z
        )
        transform.position = newPos

        local proximity = Vector3.new(
            math.abs(playerPos.x - newPos.x),
            math.abs(playerPos.y - newPos.y),
            math.abs(playerPos.z - newPos.z)
        )

        if proximity.x < 2 and proximity.y < 2 and proximity.z < 2 then
            self:set_active(false)
            scrapCollected = true
            playerScript.scrapCounter = playerScript.scrapCounter + 23
            scrapPickUpSFX:play()
        end
    end
end