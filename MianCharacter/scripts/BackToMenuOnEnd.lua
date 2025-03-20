
local sceneChanged = false
local value = false
function on_ready()
    -- Add initialization code here
end

function on_update(dt)
    -- Add update code here

    value = Input.get_button(Input.action.Confirm)
    if((value == Input.state.Down and sceneChanged == false) or (Input.is_key_pressed(Input.keycode.K) and sceneChanged == false)  ) then
        
        print("Cambiar escenu")
        sceneChanged = true
        SceneManager.change_scene("Default.TeaScene")
        
    end


end

function on_exit()
    -- Add cleanup code here
end
