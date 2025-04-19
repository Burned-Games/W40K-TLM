local button1
local button2
local button3
local button4
local button5
local text1
local text2
local text3
local text4
local text5

local index = 0
local currentSelectedIndex = 1
local buttonCooldown = 0
local buttonCooldownTime = 0.2
local sceneChanged = false
local contadorMovimientoBotones = 0

local level = 1

local defaultColor = Vector4.new(130/255, 19/255, 7/255, 1.0)
local selectedColor = Vector4.new(1.0, 1.0, 1.0, 1.0)



function on_ready()
    -- Add initialization code here
    button1 = current_scene:get_entity_by_name("NewGame"):get_component("UIButtonComponent")
    text1 = current_scene:get_entity_by_name("NewGameText"):get_component("UITextComponent")

    button2 = current_scene:get_entity_by_name("Continue"):get_component("UIButtonComponent")
    text2 = current_scene:get_entity_by_name("ContinueText"):get_component("UITextComponent")

    button3 = current_scene:get_entity_by_name("Settings"):get_component("UIButtonComponent")
    text3 = current_scene:get_entity_by_name("SettingsText"):get_component("UITextComponent")

    button4 = current_scene:get_entity_by_name("Credits"):get_component("UIButtonComponent")
    text4 = current_scene:get_entity_by_name("CreditsText"):get_component("UITextComponent")

    button5 = current_scene:get_entity_by_name("Exit"):get_component("UIButtonComponent")
    text5 = current_scene:get_entity_by_name("ExitText"):get_component("UITextComponent")

    level = load_progress("level", 1)
end
function on_update(dt)
    -- Add update code here
    if index == 0 then
        button1.state = "Hover"
        button2.state = "Normal"
        button3.state = "Normal"
        button4.state = "Normal"
        button5.state = "Normal"

        text1:set_color(selectedColor)
        text2:set_color(defaultColor)
        text3:set_color(defaultColor)
        text4:set_color(defaultColor)
        text5:set_color(defaultColor)

        value = Input.get_button(Input.action.Confirm)
        if((value == Input.state.Down and sceneChanged == false) or (Input.is_key_pressed(Input.keycode.K) and sceneChanged == false)) then
            if(index == 0) then
                --button1:set_state("Pressed")
                sceneChanged = true
                save_progress("zonePlayer", 0)
                save_progress("level", 1)
                SceneManager.change_scene("scenes/level1.TeaScene")
            end
        end

    elseif index == 1 then
        button1.state = "Normal"
        button2.state = "Hover"
        button3.state = "Normal"
        button4.state = "Normal"
        button5.state = "Normal"

        text1:set_color(defaultColor)
       text2:set_color(selectedColor)
        text3:set_color(defaultColor)
        text4:set_color(defaultColor)
        text5:set_color(defaultColor)

        value = Input.get_button(Input.action.Confirm)
        if((value == Input.state.Down and sceneChanged == false) or (Input.is_key_pressed(Input.keycode.K) and sceneChanged == false)) then
            if(index == 1) then
                --button2:set_state("Pressed")
                sceneChanged = true
                if level == 1 then
                    SceneManager.change_scene("scenes/level1.TeaScene")
                elseif level == 2 then
                    SceneManager.change_scene("scenes/level2.TeaScene")
                elseif level == 3 then
                    SceneManager.change_scene("scenes/level3.TeaScene")
                end
            end
        end
        
    elseif index == 2 then
        button1.state = "Normal"
        button2.state = "Normal"
        button3.state = "Hover"
        button4.state = "Normal"
        button5.state = "Normal"

        text1:set_color(defaultColor)
        text2:set_color(defaultColor)
        text3:set_color(selectedColor)
        text4:set_color(defaultColor)
        text5:set_color(defaultColor)


        value = Input.get_button(Input.action.Confirm)
        if((value == Input.state.Down and sceneChanged == false) or (Input.is_key_pressed(Input.keycode.K) and sceneChanged == false)) then
            --button3:set_state("Pressed")
            if(index == 2) then
                sceneChanged = true
                SceneManager.change_scene("scenes/settings.TeaScene")
            end
        end

    elseif index == 3 then
        button1.state = "Normal"
        button2.state = "Normal"
        button3.state = "Normal"
        button4.state = "Hover"
        button5.state = "Normal"

        text1:set_color(defaultColor)
       text2:set_color(defaultColor)
        text3:set_color(defaultColor)
        text4:set_color(selectedColor)
        text5:set_color(defaultColor)

        value = Input.get_button(Input.action.Confirm)
        if((value == Input.state.Down and sceneChanged == false) or (Input.is_key_pressed(Input.keycode.K) and sceneChanged == false)) then
            --button3:set_state("Pressed")
            if(index == 3) then
                -- credits screen
            end
        end

    else
        button1.state = "Normal"
        button2.state = "Normal"
        button3.state = "Normal"
        button4.state = "Normal"
        button5.state = "Hover"

        text1:set_color(defaultColor)
        text2:set_color(defaultColor)
        text3:set_color(defaultColor)
        text4:set_color(defaultColor)
        text5:set_color(selectedColor)

        value = Input.get_button(Input.action.Confirm)
        if((value == Input.state.Down and sceneChanged == false) or (Input.is_key_pressed(Input.keycode.K) and sceneChanged == false)) then
            --button4:set_state("Pressed")
            if(index == 4) then
                -- preguntar como cerrar el juego 
                --print("Exiting game...")
            end
        end
    end

    local value = Input.get_axis(Input.action.UiMoveVertical)
    if (value ~= 0 and contadorMovimientoBotones > 0.2) then
        contadorMovimientoBotones = 0
        
        if value < 0 then
            index = index - 1;
            if index < 0 then
                index = 4
            end
        end
        
        if value > 0 then
            index = index + 1
            if index > 4 then
                index = 0
            end
        end
    else
        contadorMovimientoBotones = contadorMovimientoBotones + dt
    end

end

function on_exit()
    -- Add cleanup code here
end
