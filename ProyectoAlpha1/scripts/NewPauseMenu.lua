local button1
local button2
local button3
local button4

local index = 0
local currentSelectedIndex = 1
local buttonCooldown = 0
local buttonCooldownTime = 0.2
local sceneChanged = false
local contadorMovimientoBotones = 0

function on_ready()
    -- Add initialization code here
    button1 = current_scene:get_entity_by_name("botonContinue"):get_component("UIButtonComponent")
    button2 = current_scene:get_entity_by_name("botonSettings"):get_component("UIButtonComponent")
    button3 = current_scene:get_entity_by_name("botonSaveGame"):get_component("UIButtonComponent")
    button4 = current_scene:get_entity_by_name("botonExit"):get_component("UIButtonComponent")
end

function on_update(dt)
    -- Add update code here
    if index == 0 then
        button1:set_state("Selected")
        button2:set_state("Base")
        button3:set_state("Base")
        button4:set_state("Base")

        value = Input.get_button(Input.action.Confirm)
        if((value == Input.state.Down and sceneChanged == false) or (Input.is_key_pressed(Input.keycode.K) and sceneChanged == false)) then
            if(index == 0) then
                button1:set_state("Pressed")
                sceneChanged = true
                SceneManager.change_scene("level1.TeaScene")
            end
        end

    elseif index == 1 then
        button1:set_state("Base")
        button2:set_state("Selected")
        button3:set_state("Base")
        button4:set_state("Base")

        value = Input.get_button(Input.action.Confirm)
        if((value == Input.state.Down and sceneChanged == false) or (Input.is_key_pressed(Input.keycode.K) and sceneChanged == false)) then
            if(index == 1) then
                button2:set_state("Pressed")
                sceneChanged = true
                SceneManager.change_scene("settings.TeaScene")
            end
        end
        
    elseif index == 2 then
        button1:set_state("Base")
        button2:set_state("Base")
        button3:set_state("Selected")
        button4:set_state("Base")

        value = Input.get_button(Input.action.Confirm)
        if((value == Input.state.Down and sceneChanged == false) or (Input.is_key_pressed(Input.keycode.K) and sceneChanged == false)) then
            button3:set_state("Pressed")
            if(index == 2) then
                sceneChanged = true
                print("Saving game...")
            end
        end

    else
        button1:set_state("Base")
        button2:set_state("Base")
        button3:set_state("Base")
        button4:set_state("Selected")

        value = Input.get_button(Input.action.Confirm)
        if((value == Input.state.Down and sceneChanged == false) or (Input.is_key_pressed(Input.keycode.K) and sceneChanged == false)) then
            button4:set_state("Pressed")
            if(index == 3) then
                -- preguntar como cerrar el juego 
                print("Exiting game...")
            end
        end
    end

    local value = Input.get_axis(Input.action.UiMoveVertical)
    if (value ~= 0 and contadorMovimientoBotones > 0.2) then
        contadorMovimientoBotones = 0
        
        if value < 0 then
            index = index - 1;
            if index < 0 then
                index = 3
            end
        end
        
        if value > 0 then
            index = index + 1
            if index > 3 then
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