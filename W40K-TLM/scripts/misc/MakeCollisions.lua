function on_ready()
    -- Add initialization code here
    local children = self:get_children()
    
    for _, child in ipairs(children) do
        
        if not child:has_component("RigidbodyComponent") then
            child:add_component("RigidbodyComponent")
            child:get_component("RigidbodyComponent").rb:set_body_type(0)
            
        end 
        child:remove_component("MeshComponent") 
    end
end

function on_update(dt)
    -- Add update code here
end

function on_exit()
    -- Add cleanup code here
end
