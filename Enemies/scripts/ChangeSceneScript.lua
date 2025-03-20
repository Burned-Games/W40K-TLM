function on_ready()
    -- Add initialization code here
end

function on_update(dt)
    -- Add update code here
    if Input.is_key_pressed(Input.keycode.Q) then
        SceneManager.change_scene("test1.TeaScene")
    end

    if Input.is_key_pressed(Input.keycode.W) then
        SceneManager.change_scene("test2.TeaScene")
    end

    if Input.is_key_pressed(Input.keycode.E) then
        SceneManager.change_scene("test3.TeaScene")
    end

    if Input.is_key_pressed(Input.keycode.R) then
        SceneManager.change_scene("test4.TeaScene")
    end

end

function on_exit()
    -- Add cleanup code here
end
