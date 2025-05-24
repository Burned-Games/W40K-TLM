local timer = 0.0

function on_ready() end

function on_update(dt)
    timer = timer + dt

    if timer > 2 then
        current_scene:destroy_entity(self)
    end
end

function on_exit() end
