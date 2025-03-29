m5_IndicateTable = false


function on_ready()
    -- Add initialization code here
end

function on_update(dt)
    -- Add update code here
    if Input.is_key_pressed(Input.keycode.B) then
        m5_IndicateTable = true
    end

end

function on_exit()
    -- Add cleanup code here
end
