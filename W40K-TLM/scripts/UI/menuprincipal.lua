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
local musicaFondoDefault
--local changeScene = false
local SettingsManager
local Ajustes
ajustesOpened = false



local index = 0
local currentSelectedIndex = 1
local buttonCooldown = 0
local buttonCooldownTime = 0.2
local sceneChanged = false
local contadorMovimientoBotones = 0

local level = 1

local defaultColor = Vector4.new(130/255, 19/255, 7/255, 1.0)
local selectedColor = Vector4.new(1.0, 1.0, 1.0, 1.0)

local changingScene = 0
local fadeToBlackScript = nil

function on_ready()
    -- Add initialization code here
    button1 = current_scene:get_entity_by_name("NewGame"):get_component("UIButtonComponent")
    text1 = current_scene:get_entity_by_name("NewGameText"):get_component("UITextComponent")

    button2 = current_scene:get_entity_by_name("Continue"):get_component("UIButtonComponent")
    text2 = current_scene:get_entity_by_name("ContinueText"):get_component("UITextComponent")

    button3 = current_scene:get_entity_by_name("SettingsButton"):get_component("UIButtonComponent")
    text3 = current_scene:get_entity_by_name("SettingsText"):get_component("UITextComponent")

    button4 = current_scene:get_entity_by_name("Credits"):get_component("UIButtonComponent")
    text4 = current_scene:get_entity_by_name("CreditsText"):get_component("UITextComponent")

    button5 = current_scene:get_entity_by_name("Exit"):get_component("UIButtonComponent")
    text5 = current_scene:get_entity_by_name("ExitText"):get_component("UITextComponent")

    SettingsManager = current_scene:get_entity_by_name("SettingsManager"):get_component("ScriptComponent")

    Ajustes = current_scene:get_entity_by_name("Settings")

    level = load_progress("level", 1)

    fadeToBlackScript = current_scene:get_entity_by_name("FadeToBlack"):get_component("ScriptComponent")
    
end

function on_update(dt)
    -- Add update code here
    if index == 0 then
        
            button1.state = State.Hover
            button2.state = State.Normal
            button3.state = State.Normal
            button4.state = State.Normal
            button5.state = State.Normal

            text1:set_color(selectedColor)
            text2:set_color(defaultColor)
            text3:set_color(defaultColor)
            text4:set_color(defaultColor)
            text5:set_color(defaultColor)

            value = Input.get_button(Input.action.Confirm)
            if((value == Input.state.Down and sceneChanged == false) or (Input.is_key_pressed(Input.keycode.K) and sceneChanged == false)) then
                if(index == 0) then
                    --button1:set_state("Pressed")
                    --sceneChanged = true
                    --save_progress("zonePlayer", 0)
                    --save_progress("level", 1)
                    --SceneManager.change_scene("scenes/level1.TeaScene")
                    fadeToBlackScript:DoFade()
                    changingScene = 1
                    sceneChanged = true
                end
            end
        

    elseif index == 1 then
        button1.state = State.Normal
        button2.state = State.Hover
        button3.state = State.Normal
        button4.state = State.Normal
        button5.state = State.Normal

        text1:set_color(defaultColor)
       text2:set_color(selectedColor)
        text3:set_color(defaultColor)
        text4:set_color(defaultColor)
        text5:set_color(defaultColor)

        value = Input.get_button(Input.action.Confirm)
        if((value == Input.state.Down and sceneChanged == false) or (Input.is_key_pressed(Input.keycode.K) and sceneChanged == false)) then
            if(index == 1) then
                --button2:set_state("Pressed")
                fadeToBlackScript:DoFade()
                changingScene = 2
                sceneChanged = true
            end
        end
        
    elseif index == 2 then
        button1.state = State.Normal
        button2.state = State.Normal
        button3.state = State.Hover
        button4.state = State.Normal
        button5.state = State.Normal

        text1:set_color(defaultColor)
        text2:set_color(defaultColor)
        text3:set_color(selectedColor)
        text4:set_color(defaultColor)
        text5:set_color(defaultColor)


        value = Input.get_button(Input.action.Confirm)
        if((value == Input.state.Down) or (Input.is_key_pressed(Input.keycode.K))) then
            --button3:set_state("Pressed")
            if(index == 2) then
                ajustesOpened = true
            end
        end

    elseif index == 3 then
        button1.state = State.Normal
        button2.state = State.Normal
        button3.state = State.Normal
        button4.state = State.Hover
        button5.state = State.Normal

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
        button1.state = State.Normal
        button2.state = State.Normal
        button3.state = State.Normal
        button4.state = State.Normal
        button5.state = State.Hover

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

    if ajustesOpened == false then
        local value = Input.get_direction("UiY")
            if (value ~= 0 and contadorMovimientoBotones > 0.2) then
                contadorMovimientoBotones = 0
                log("Valor que estoy encontrando" .. value)
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
                log("Valor del indice" .. index)
            else
                contadorMovimientoBotones = contadorMovimientoBotones + dt
            end
        end
        if changingScene ~= 0 then
            if fadeToBlackScript.fadeToBlackDoned and not changeScene then
    
                if changingScene == 1 then
                    save_progress("zonePlayer", 0)
                    save_progress("level", 1)
                    SceneManager.change_scene("scenes/level1.TeaScene")
                end
                if changingScene == 2 then
                    if level == 1 then
                        SceneManager.change_scene("scenes/level1.TeaScene")
                    elseif level == 2 then
                        SceneManager.change_scene("scenes/level2.TeaScene")
                    elseif level == 3 then
                        SceneManager.change_scene("scenes/level3.TeaScene")
                    end
                end
    
                changeScene = true
            end
        end

end

function on_exit()
    -- Add cleanup code here
end
