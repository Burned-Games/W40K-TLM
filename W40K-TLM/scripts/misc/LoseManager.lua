
local changeScene = false
local fadeToBlackScript = nil

function on_ready()
    -- Add initialization code here
    fadeToBlackScript = current_scene:get_entity_by_name("FadeToBlack"):get_component("ScriptComponent")
end

function on_update(dt)
    -- Add update code here
    if(Input.get_button(Input.action.Confirm) == Input.state.Down) and not changeScene then
        changeScene = true
        fadeToBlackScript:DoFade()
    end

    if fadeToBlackScript.fadeToBlackDoned then
        SceneManager.change_scene("scenes/Default.TeaScene")
    end



end

function on_exit()
    -- Add cleanup code here
end
