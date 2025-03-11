local player
local playerPos
local cameraSpeed = 5
-- Camera Rotation -60, -45, 0
function on_ready()
    -- Add initialization code here
    player = current_scene:get_entity_by_name("Player")
    
    playerPos = player:get_component("TransformComponent").position;

end

function on_update(dt)
    -- Add update code here
    local offSet = Vector3.new(-6, 20, 6)
    local targetPos = Vector3.new(playerPos.x + offSet.x, playerPos.y + offSet.y, playerPos.z + offSet.z)
    
    local cameraTransform = self:get_component("TransformComponent")
    local currentPos = cameraTransform.position

    local smoothPos = Vector3.lerp(currentPos, targetPos, dt * cameraSpeed)

    --self:get_component("TransformComponent").position = Vector3.new(playerPos.x + offSet.x, playerPos.y+offSet.y, playerPos.z + offSet.z)

    cameraTransform.position = smoothPos
end

function on_exit()
    -- Add cleanup code here
end
