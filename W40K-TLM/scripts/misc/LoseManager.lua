local changeScene = false
local fadeToBlackScript = nil

local ContinueButton = nil
local ExitButton = nil

local index = 0
local contadorMovimientoBotones = 0

local levelToLoad = -1
local changed = false

function on_ready()
    fadeToBlackScript = current_scene:get_entity_by_name("FadeToBlack"):get_component("ScriptComponent")

    ContinueButton = current_scene:get_entity_by_name("ContinueButton"):get_component("UIButtonComponent")
    ExitButton = current_scene:get_entity_by_name("ExitButton"):get_component("UIButtonComponent")

    levelToLoad = load_progress("level", 1) 
end

function on_update(dt)
    if index == 0 then
        ContinueButton.state = State.Hover
        ExitButton.state = State.Normal

        if(Input.get_button(Input.action.Confirm) == Input.state.Down and not changeScene) then
            changeScene = true
            fadeToBlackScript:DoFade()
        end

    elseif index == 1 then
        ContinueButton.state = State.Normal
        ExitButton.state = State.Hover

        if(Input.get_button(Input.action.Confirm) == Input.state.Down and not changeScene) then
            changeScene = true
            fadeToBlackScript:DoFade()
        end
    end

    if fadeToBlackScript.fadeToBlackDoned and changeScene and not changed then
        if index == 0 then
            
            SceneManager.change_scene("scenes/loading.TeaScene")
        else
           
            SceneManager.change_scene("scenes/mainMenu.TeaScene")
        end
        changed = true
    end

    local value = Input.get_direction("UiY")
    if (value ~= 0 and contadorMovimientoBotones > 0.2) then
        contadorMovimientoBotones = 0

        if value < 0 then
            index = index - 1
            if index < 0 then index = 1 end
        end

        if value > 0 then
            index = index + 1
            if index > 1 then index = 0 end
        end
    else
        contadorMovimientoBotones = contadorMovimientoBotones + dt
    end
end

function on_exit()
    -- Cleanup si es necesario
end
