local playerTransf
local playerWorldTransf
local forwardVector
local transformGranade
local granadeCooldown= 12;
local timerGranade = 0;
local throwingGranade = false
local granadeEntity = nil
local floorEntity = nil

local granadeVelocity = Vector3.new(0, 0, 0)
local granadeGravity = Vector3.new(0, -9.81, 0) 
local granadeInitialSpeed = 12

local explosionRadius = 7.0
local explosionForce = 13.0
local explosionUpward = 2.0

function on_ready()
    playerTransf = self:get_component("TransformComponent")
    playerWorldTransf = playerTransf:get_world_transform();
    forwardVector = Vector3.new(1,0,0)

    granadeEntity = current_scene:get_entity_by_name("Granade")
    transformGranade = granadeEntity:get_component("TransformComponent")

    floorEntity = current_scene:get_entity_by_name("FloorCollider")

    if not granadeEntity:has_component("RigidbodyComponent") then
        granadeEntity:add_component("RigidbodyComponent")
    end

    local rb = granadeEntity:get_component("RigidbodyComponent").rb
    rb:set_use_gravity(true)
    rb:set_mass(1.0) 
    rb:set_trigger(false)  


    local rbComponent = granadeEntity:get_component("RigidbodyComponent")
    rbComponent:on_collision_enter(function(entityA, entityB)

        local nameA = entityA:get_component("TagComponent").tag
        local nameB = entityB:get_component("TagComponent").tag

        if nameA == "Floor" or nameB == "Floor" then
            explodeGranade()
        end
    end)
end

function on_update(dt)

    playerMovement(dt)
    handleGranade(dt)

end

function on_exit()
    -- Add cleanup code here
end

function playerMovement(dt)

    local axisX_l = Input.get_axis_position(Input.axiscode.LeftX)
    local axisY_l = Input.get_axis_position(Input.axiscode.LeftY)

    local axisX_r = Input.get_axis_position(Input.axiscode.RightX)
    local axisY_r = Input.get_axis_position(Input.axiscode.RightY)

    local rightTrigger = Input.get_axis_position(Input.axiscode.RightTrigger)

    -- Camera angle in radians (45 degrees)
    local cameraAngle = math.rad(45)

    -- Rotate input axis to align them with the camera 
    local moveDirectionX = axisX_l * math.cos(cameraAngle) - axisY_l * math.sin(cameraAngle)
    local moveDirectionY = axisX_l * math.sin(cameraAngle) + axisY_l * math.cos(cameraAngle)

    local rotationDirectionX = axisX_r * math.cos(cameraAngle) - axisY_r * math.sin(cameraAngle)
    local rotationDirectionY = axisX_r * math.sin(cameraAngle) + axisY_r * math.cos(cameraAngle)

    --Transform
    playerTransf.position.x = playerTransf.position.x + moveDirectionX*5 * dt;
    playerTransf.position.z = playerTransf.position.z + moveDirectionY*5 * dt;
    
    -- Rotation
    if (rotationDirectionX ~= 0 or rotationDirectionY ~= 0) then
        local lookLength = rotationDirectionX*rotationDirectionX + rotationDirectionY*rotationDirectionY
        if(lookLength > 0) then
            angleRotation = math.atan(rotationDirectionX, rotationDirectionY)
            playerTransf.rotation.y = angleRotation * 57.2958
        end
    end

    if Input.is_key_pressed(Input.keycode.A) then
        playerTransf.position.x = playerTransf.position.x + 5 * dt;
        
    end
    if Input.is_key_pressed(Input.keycode.D) then
        playerTransf.position.x = playerTransf.position.x - 5 * dt;
    end
    if Input.is_key_pressed(Input.keycode.W) then
        playerTransf.position.z = playerTransf.position.z + 5 * dt;
    end
    if Input.is_key_pressed(Input.keycode.S) then
        playerTransf.position.z = playerTransf.position.z - 5 * dt;
    end

end


function handleGranade(dt)
    if timerGranade > 0 then
        timerGranade = timerGranade - dt
    end

    if Input.is_button_pressed(Input.controllercode.South) and timerGranade <= 0 then
        throwGranade()
        timerGranade = granadeCooldown
    end
end

function throwGranade()
    if granadeEntity ~= nil then
        local rb = granadeEntity:get_component("RigidbodyComponent").rb
        rb:set_position(playerTransf.position)

        local direction = Vector3.new(math.sin(math.rad(playerTransf.rotation.y)), 0.5, math.cos(math.rad(playerTransf.rotation.y)))
        local velocity = Vector3.new(direction.x * granadeInitialSpeed, direction.y * granadeInitialSpeed, direction.z * granadeInitialSpeed)
        rb:set_velocity(velocity)
        throwingGranade = true
    end
end

function explodeGranade()
    if granadeEntity ~= nil then
        local rb = granadeEntity:get_component("RigidbodyComponent").rb
        local explosionPos = rb:get_position()

        local entities = current_scene:get_all_entities()

        for _, entity in ipairs(entities) do 
            if entity ~= granadeEntity and entity:has_component("RigidbodyComponent") then 
                local entityRb = entity:get_component("RigidbodyComponent").rb
                local entityPos = entityRb:get_position()

                local direction = Vector3.new(
                    entityPos.x - explosionPos.x,
                    entityPos.y - explosionPos.y,
                    entityPos.z - explosionPos.z
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

                if distance < explosionRadius then
                    local forceFactor = (explosionRadius - distance) / explosionRadius
                    direction.y = direction.y + explosionUpward
                    local finalForce = Vector3.new(
                        direction.x * explosionForce * forceFactor,
                        direction.y * explosionForce * forceFactor,
                        direction.z * explosionForce * forceFactor
                    )
                    entityRb:apply_impulse(finalForce)

                    local rotationFactor = explosionForce * forceFactor 
                    local randomRotation = Vector3.new(
                        (math.random() - 0.5) * rotationFactor,
                        (math.random() - 0.5) * rotationFactor,
                        (math.random() - 0.5) * rotationFactor
                    )

                    entityRb:set_angular_velocity(randomRotation)
                end
            end
        end
        
        rb:set_velocity(Vector3.new(0, 0, 0))
        rb:set_angular_velocity(Vector3.new(0, 0, 0))
        throwingGranade = false
    end
end
