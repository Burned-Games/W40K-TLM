local player
local playerPos

function on_ready()
    -- Add initialization code here
    player = current_scene:get_entity_by_name("Player")
    
    playerPos = player:get_component("TransformComponent").position;

end

function on_update(dt)
    -- Add update code here
    local offSet = Vector3.new(-6, 20, 6)
    self:get_component("TransformComponent").position = Vector3.new(playerPos.x + offSet.x, playerPos.y+offSet.y, playerPos.z + offSet.z)


end

function on_exit()
    -- Add cleanup code here
end
