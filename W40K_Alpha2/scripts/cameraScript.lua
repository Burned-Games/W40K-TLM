local player
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

-- Camera Rotation -45,-45, 0
function on_ready()
    -- Add initialization code here
    player = current_scene:get_entity_by_name("Player")



    playerScript = player:get_component("ScriptComponent")

    

    
    
    playerPos = player:get_component("TransformComponent").position;

    cameraTransform = self:get_component("TransformComponent")

    cameraTransform.rotation = Vector3.new(-45, -45, 0)

    

    local zoomOffSet = Vector3.new(baseOffset.x * (1 + zoom * 0.2), baseOffset.y * (1 + zoom * 0.2), baseOffset.z * (1 + zoom * 0.2))

    
    local targetPos = Vector3.new(playerPos.x + zoomOffSet.x, playerPos.y + zoomOffSet.y, playerPos.z + zoomOffSet.z)

    cameraTransform.position = targetPos

end

function on_update(dt)

    if playerScript and playerScript.moveDirection then

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

function on_exit()
    -- Add cleanup code here
end
