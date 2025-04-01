local player
local playerTransf = nil
local playerScript = nil
local playerPos
local playerDirectionX = 0
local playerDirectionY = 0
local playerDirectionZ = 0
local cameraSpeed = 2
local zoom = -1.5
local minZoom = -3.5
local maxZoom = -1.5
local zoomStep = 0.5
local baseOffset = Vector3.new(-10, 15, 10)
local cameraTransform = nil
local directionCached = false

local offsetPlayer = 5

local radiusSpawn = 20

local entities = nil

local orkEntities = nil

-- Camera Rotation -45,-45, 0
function on_ready()
    -- Add initialization code here
    player = current_scene:get_entity_by_name("Player")

    playerTransf = player:get_component("TransformComponent")

    playerScript = player:get_component("ScriptComponent")

    

    
    
    playerPos = player:get_component("TransformComponent").position;

    cameraTransform = self:get_component("TransformComponent")

    cameraTransform.rotation = Vector3.new(-45, -45, 0)

    

    local zoomOffSet = Vector3.new(baseOffset.x * (1 + zoom * 0.2), baseOffset.y * (1 + zoom * 0.2), baseOffset.z * (1 + zoom * 0.2))

    
    local targetPos = Vector3.new(playerPos.x + zoomOffSet.x, playerPos.y + zoomOffSet.y, playerPos.z + zoomOffSet.z)

    cameraTransform.position = targetPos

    entities = current_scene:get_all_entities()

    orkEntities = {} 

    for _, entity in ipairs(entities) do 
        if entity:get_component("TagComponent").tag == "EnemyOrk" then
            table.insert(orkEntities, entity) 
            entity:set_active(false)
        end
    end

end

function on_update(dt)

    if playerScript and playerScript.moveDirection then
        if playerScript.moveDirection.x ~= 0 and playerScript.moveDirection.z ~= 0 then
            --updateEnemyActivation()
        end
        -- Add update code here
        local zoomOffSet = Vector3.new(baseOffset.x * (1 + zoom * 0.2), baseOffset.y * (1 + zoom * 0.2), baseOffset.z * (1 + zoom * 0.2))  


        local targetPos = Vector3.new(playerPos.x + zoomOffSet.x + playerScript.moveDirection.x * offsetPlayer, playerPos.y + zoomOffSet.y + playerScript.moveDirection.y * offsetPlayer, playerPos.z + zoomOffSet.z + playerScript.moveDirection.z * offsetPlayer)
    
        local currentPos = cameraTransform.position

        local smoothPos = Vector3.lerp(currentPos, targetPos, dt * cameraSpeed)

   
        cameraTransform.position = smoothPos

        if Input.is_button_pressed(Input.controllercode.DpadUp) then
            if zoom > minZoom then
                zoom = zoom - zoomStep
            end
        elseif Input.is_button_pressed(Input.controllercode.DpadDown) then
            if zoom < maxZoom then
                zoom = zoom + zoomStep
            end
        end

    end
end

function updateEnemyActivation()


    for _, entity in ipairs(orkEntities) do 
        if entity ~= player and entity:has_component("RigidbodyComponent") and entity:has_component("ScriptComponent")then
            local entityRb = entity:get_component("RigidbodyComponent").rb
            local entityPos = entityRb:get_position()

            local direction = Vector3.new(
                entityPos.x - playerTransf.position.x,
                entityPos.y - playerTransf.position.y,
                entityPos.z - playerTransf.position.z
            )

            local distance = math.sqrt(
                direction.x * direction.x +
                direction.y * direction.y +
                direction.z * direction.z
            )

            if distance > 0 then
                direction.x = direction.x / distance
                direction.y = direction.y / distance
                direction.z = direction.z / distance
            end

            if distance < radiusSpawn then
                     
                entity:set_active(true)

                
            end
        end
    end
end

function on_exit()
    -- Add cleanup code here
end
