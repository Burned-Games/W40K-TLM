
local children = nil
local should_apply_physics = true


function on_ready()
    children = self:get_children() 
    local p = self:get_component("RigidbodyComponent")

    p:on_collision_enter(function(entityA, entityB)               
        local nameA = entityA:get_component("TagComponent").tag
        local nameB = entityB:get_component("TagComponent").tag

        if nameA == "Sphere1" or nameB == "Sphere1" then
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