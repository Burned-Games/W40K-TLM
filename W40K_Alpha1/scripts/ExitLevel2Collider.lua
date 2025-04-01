local colliderComponent = nil
local collider = nil
local changeScene = false

function on_ready()
    colliderComponent = self:get_component("RigidbodyComponent")
    collider = colliderComponent.rb
    collider:set_trigger(true)

    colliderComponent:on_collision_enter(function(entityA, entityB)                
        local nameA = entityA:get_component("TagComponent").tag
        local nameB = entityB:get_component("TagComponent").tag
       
        if nameA == "Player" or nameB == "Player" then
            changeScene = true
            
        end

     

    end)
    
end

function on_update(dt)
    -- Add update code here
    if changeScene == true then
        SceneManager.change_scene("level3.TeaScene")
    end



end

function on_exit()
    -- Add cleanup code here
end
