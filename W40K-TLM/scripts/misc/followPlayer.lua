local playerTransf = nil
local objectTransf = nil
function on_ready()
    -- Add initialization code here
    playerTransf = current_scene:get_entity_by_name("Player"):get_component("TransformComponent")

    objectTransf = self:get_component("TransformComponent") 
end

function on_update(dt)
    
    objectTransf.position = Vector3.new(playerTransf.position.x, 3, playerTransf.position.z)

end

function on_exit() end
