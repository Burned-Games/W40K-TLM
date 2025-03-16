local godMode = false
local playerCollider

function on_ready()
    playerCollider = entity:get_component("RigidbodyComponent")

end

function on_update(dt)
    if Input.is_key_pressed(Input.keycode.L) then
        godMode = not godMode
        if godMode then
            playerCollider:set_enabled(false)
            log("GodMode On")
        else
            playerCollider:set_enabled(true) 
            log("GodMode Off")
        end
    end
end

function on_exit()
   
end
