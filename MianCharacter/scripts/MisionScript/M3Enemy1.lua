m3_enemy1_die = false

function on_ready()
    -- Add initialization code here
end

function on_update(dt)
    -- Add update code here
    if Input.is_key_pressed(Input.keycode.N) then
        m3_enemy1_die = true
    end
end

function on_exit()
    -- Add cleanup code here
end
