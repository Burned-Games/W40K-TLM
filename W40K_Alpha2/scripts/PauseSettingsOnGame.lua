local button1
local button2
local button3
local button4
local visibilidad1
local visibilidad2
local slider1
local slider2
local VolumeText
local FXText
local ContinueText
local SettingsText
local SaveGameText
local ExitText
local PauseText
local SettingsBaseText

isPaused = false

local index = 0
local currentSelectedIndex = 1
local buttonCooldown = 0
local buttonCooldownTime = 0.2
local sceneChanged = false
local contadorMovimientoBotones = 0
local currentSelectedSlider = 1 
local inputCooldown = 0 
local cooldownTime = 0.15 

function on_ready()
    -- Add initialization code here
    button1 = current_scene:get_entity_by_name("Continue"):get_component("UIButtonComponent")
    button2 = current_scene:get_entity_by_name("Settings"):get_component("UIButtonComponent")
    button3 = current_scene:get_entity_by_name("SaveGame"):get_component("UIButtonComponent")
    button4 = current_scene:get_entity_by_name("Exit"):get_component("UIButtonComponent")

    visibilidad1 = current_scene:get_entity_by_name("BasePause"):get_component("UIImageComponent")
    visibilidad2 = current_scene:get_entity_by_name("BaseSettings"):get_component("UIImageComponent")

    VolumeText = current_scene:get_entity_by_name("VolumeText"):get_component("UITextComponent")
    FXText = current_scene:get_entity_by_name("FXText"):get_component("UITextComponent")

    slider1 = current_scene:get_entity_by_name("Volume"):get_component("UISliderComponent")
    slider2 = current_scene:get_entity_by_name("FX"):get_component("UISliderComponent")

    ContinueText = current_scene:get_entity_by_name("ContinueText"):get_component("UITextComponent")
    SettingsText = current_scene:get_entity_by_name("SettingsText"):get_component("UITextComponent")
    SaveGameText = current_scene:get_entity_by_name("SaveText"):get_component("UITextComponent")
    ExitText = current_scene:get_entity_by_name("ExitText"):get_component("UITextComponent")
    PauseText = current_scene:get_entity_by_name("PauseText"):get_component("UITextComponent")
    SettingsBaseText = current_scene:get_entity_by_name("SettingsBaseText"):get_component("UITextComponent")

    visibilidad2:set_visible(false)
    VolumeText:set_visible(false)
    FXText:set_visible(false)
    SettingsBaseText:set_visible(false)
    slider1:set_visible(false)
    slider2:set_visible(false)
    button1:set_visible(false)
    button2:set_visible(false)
    button3:set_visible(false)
    button4:set_visible(false)

end

function on_update(dt)
    -- Add update code here

    value = Input.get_button(Input.action.Pause)
    if ((value == Input.state.Down) or (Input.is_key_pressed(Input.keycode.K))) then
        if(isPaused) then
            isPaused = false
            ContinueText:set_visible(false)
            SettingsText:set_visible(false)
            SaveGameText:set_visible(false)
            ExitText:set_visible(false)
            PauseText:set_visible(false)
            button1:set_visible(false)
            button2:set_visible(false)
            button3:set_visible(false)
            button4:set_visible(false)
            visibilidad1:set_visible(false)
            slider1:set_visible(false)
            slider2:set_visible(false)
            VolumeText:set_visible(false)
            FXText:set_visible(false)
            SettingsBaseText:set_visible(false)
            visibilidad2:set_visible(false)

        else
            isPaused = true
            ContinueText:set_visible(true)
            SettingsText:set_visible(true)
            SaveGameText:set_visible(true)
            ExitText:set_visible(true)
            PauseText:set_visible(true)
            button1:set_visible(true)
            button2:set_visible(true)
            button3:set_visible(true)
            button4:set_visible(true)
            visibilidad1:set_visible(true)
        end
    end

    if isPaused == false then
        return
    end

    if index == 0 then
        button1:set_state("Selected")
        button2:set_state("Base")
        button3:set_state("Base")
        button4:set_state("Base")

        value = Input.get_button(Input.action.Interact)
        if((value == Input.state.Down) or (Input.is_key_pressed(Input.keycode.K))) then
            if(index == 0) then
                button1:set_state("Pressed")
                sceneChanged = true
                ContinueText:set_visible(false)
                SettingsText:set_visible(false)
                SaveGameText:set_visible(false)
                ExitText:set_visible(false)
                PauseText:set_visible(false)
                button1:set_visible(false)
                button2:set_visible(false)
                button3:set_visible(false)
                button4:set_visible(false)
                visibilidad1:set_visible(false)
                isPaused = false
            end
        end

    elseif index == 1 then
        button1:set_state("Base")
        button2:set_state("Selected")
        button3:set_state("Base")
        button4:set_state("Base")

        value = Input.get_button(Input.action.Interact)
        if((value == Input.state.Down) or (Input.is_key_pressed(Input.keycode.K))) then
            if(index == 1) then
                button2:set_state("Pressed")
                sceneChanged = true
                visibilidad2:set_visible(true)
                VolumeText:set_visible(true)
                FXText:set_visible(true)
                SettingsBaseText:set_visible(true)
                slider1:set_visible(true)
                slider2:set_visible(true)
                button1:set_visible(false)
                button2:set_visible(false)
                button3:set_visible(false)
                button4:set_visible(false)
                ContinueText:set_visible(false)
                SettingsText:set_visible(false)
                ExitText:set_visible(false)
                SaveGameText:set_visible(false)
                PauseText:set_visible(false)
            end
        end
        
    elseif index == 2 then
        button1:set_state("Base")
        button2:set_state("Base")
        button3:set_state("Selected")
        button4:set_state("Base")

        value = Input.get_button(Input.action.Confirm)
        if((value == Input.state.Down) or (Input.is_key_pressed(Input.keycode.K))) then
            button3:set_state("Pressed")
            if(index == 2) then
                sceneChanged = true
                --print("Saving game...")
            end
        end

    else
        button1:set_state("Base")
        button2:set_state("Base")
        button3:set_state("Base")
        button4:set_state("Selected")

        value = Input.get_button(Input.action.Interact)
        if((value == Input.state.Down) or (Input.is_key_pressed(Input.keycode.K))) then
            button4:set_state("Pressed")
            if(index == 3) then
                -- preguntar como cerrar el juego 
               SceneManager.change_scene("Default.TeaScene")
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

    if inputCooldown > 0 then
        inputCooldown = inputCooldown - dt
        return
    end

    local horizontalInput = Input.get_axis(Input.action.UiMoveHorizontal)
    if math.abs(horizontalInput) > 0.5 then
        local selectedSlider = (currentSelectedSlider == 1) and slider1 or slider2
        local currentValue = selectedSlider:get_value()
        
       
        local newValue = currentValue + (horizontalInput * 0.05) 
        newValue = math.max(0.0, math.min(1.0, newValue))
        
        selectedSlider:set_value(newValue)
        inputCooldown = cooldownTime / 2 
    end

    local verticalInput = Input.get_axis(Input.action.UiMoveVertical)
    if math.abs(verticalInput) > 0.5 then
        if verticalInput > 0 then
            currentSelectedSlider = currentSelectedSlider - 1
            if currentSelectedSlider < 1 then
                currentSelectedSlider = 2
            end
        else 
            currentSelectedSlider = currentSelectedSlider + 1
            if currentSelectedSlider > 2 then
                currentSelectedSlider = 1
            end
        end
        inputCooldown = cooldownTime
        return
    end


    value = Input.get_button(Input.action.Cancel)
    if((value == Input.state.Down) or (Input.is_key_pressed(Input.keycode.K))) then
        sceneChanged = true
        visibilidad2:set_visible(false)
        VolumeText:set_visible(false)
        FXText:set_visible(false)
        SettingsBaseText:set_visible(false)
        slider1:set_visible(false)
        slider2:set_visible(false)
        button1:set_visible(true)
        button2:set_visible(true)
        button3:set_visible(true)
        button4:set_visible(true)
        ContinueText:set_visible(true)
        SettingsText:set_visible(true)
        ExitText:set_visible(true)
        SaveGameText:set_visible(true)
        PauseText:set_visible(true)
    end
        
end

function on_exit()
    -- Add cleanup code here
end