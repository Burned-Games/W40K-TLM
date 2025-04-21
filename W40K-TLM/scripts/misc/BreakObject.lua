
local children = nil
local should_apply_physics = true


function on_ready()
    children = self:get_children() 
    local p = self:get_component("RigidbodyComponent")
    cameraScript = current_scene:get_entity_by_name("Camera"):get_component("ScriptComponent")

    p:on_collision_enter(function(entityA, entityB)               
        local nameA = entityA:get_component("TagComponent").tag
        local nameB = entityB:get_component("TagComponent").tag

        if nameA == "Sphere1" or nameA == "Sphere2" or nameA == "Sphere3" or nameA == "Sphere4" or nameA == "Sphere5" or nameA == "Sphere6" or nameA == "Sphere7" or nameA == "Sphere8"
        or nameB == "Sphere1" or nameB == "Sphere2" or nameB == "Sphere3" or nameB == "Sphere4" or nameB == "Sphere5" or nameB == "Sphere6" or nameB == "Sphere7" or nameB == "Sphere8" then
            cameraScript.startShake(0.2,5)
            give_phisycs()
        end
        
    end)
    
end

function on_update(dt)

end

function on_exit()
    -- Add cleanup code here
end

function give_phisycs()
    self:get_component("RigidbodyComponent").rb:set_trigger(true)
    self:get_component("ParticlesSystemComponent"):emit(6)

    for _, barril in ipairs(children) do
        if not barril:has_component("RigidbodyComponent") then
            barril:add_component("RigidbodyComponent")
        end

        if barril:has_component("RigidbodyComponent") then

            local rb = barril:get_component("RigidbodyComponent").rb
            


            rb:set_body_type(1)
            
            rb:set_use_gravity(true)
            rb:set_mass(1.0) 
            rb:set_trigger(false) 
            rb:set_freeze_x(false)
            rb:set_freeze_y(false)
            rb:set_freeze_z(false)

            rb:set_freeze_rot_x(false)
            rb:set_freeze_rot_y(false)
            rb:set_freeze_rot_z(false)

        end
        
        
    end
end
--Deberia activarse cuando algo lo toca
function on_collision_enter(other)
    should_apply_physics = true
end