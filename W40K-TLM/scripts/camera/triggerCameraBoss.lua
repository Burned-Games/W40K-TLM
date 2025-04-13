local colliderComponent = nil
local collider = nil

function on_ready()
    camera = current_scene:get_entity_by_name("Camera")
    cameraScript = camera:get_component("ScriptComponent")

    colliderComponent = self:get_component("RigidbodyComponent")
    collider = colliderComponent.rb
    collider:set_trigger(true)

    colliderComponent:on_collision_enter(function(entityA, entityB)                
        local nameA = entityA:get_component("TagComponent").tag
        local nameB = entityB:get_component("TagComponent").tag
       print("BB")
        if nameA == "Player" or nameB == "Player" then
            print("AAA")
            cameraScript:cameraBoss(true)
        end
    end)
    
end

function on_update(dt) end

function on_exit() end