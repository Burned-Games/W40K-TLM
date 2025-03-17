local player
local playerPos
local cameraSpeed = 5
local zoom = 0
local minZoom = -3.5
local maxZoom = 0
local zoomStep = 0.5
local baseOffset = Vector3.new(-10, 15, 10)
local cameraTransform = nill

-- Camera Rotation -45,-45, 0
function on_ready()
    -- Add initialization code here
    player = current_scene:get_entity_by_name("Player")
    
    playerPos = player:get_component("TransformComponent").position;

    cameraTransform = self:get_component("TransformComponent")

    cameraTransform.rotation = Vector3.new(-45, -45, 0)

end

function on_update(dt)
    -- Add update code here
    local zoomOffSet = Vector3.new(
        baseOffset.x * (1 + zoom * 0.2), 
        baseOffset.y * (1 + zoom * 0.2),  
        baseOffset.z * (1 + zoom * 0.2))  

    local targetPos = Vector3.new(playerPos.x + zoomOffSet.x, playerPos.y + zoomOffSet.y, playerPos.z + zoomOffSet.z)
    
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

function on_exit()
    -- Add cleanup code here
end
