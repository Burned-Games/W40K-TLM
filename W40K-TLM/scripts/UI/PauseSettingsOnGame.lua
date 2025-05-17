local button1
local button2
local button3
local button4
local visibilidad1Entity
local visibilidad2Entity
local hudVisibility
local slider1
local slider2
local text1
local text2
local VolumeText
local FXText
local ContinueText
local SettingsText
local SaveGameText
local ExitText
local PauseText
local SettingsBaseText
local BaseTextureBG
local HUD = nil
local chatarraUI = nil

isPaused = false

local index = 0
local currentSelectedIndex = 0
local buttonCooldown = 0
local buttonCooldownTime = 0.2
local sceneChanged = false
local contadorMovimientoBotones = 0
local currentSelectedSlider = 1 
local inputCooldown = 0 
local cooldownTime = 0.15 
local isOnPauseSettings = false

local visibilidadtotal

local workbenchUIManagerScript = nil

local selectedColor = Vector4.new(130/255, 19/255, 7/255, 1.0)
local defaultColor = Vector4.new(1.0, 1.0, 1.0, 1.0)

musicVolume = 0.0
fxVolume = 0.0

--Audio
local settingsSFX = nil
local indexHoverSFX = nil
local indexSelectionSFX = nil

local fadeToBlackScript = nil

function on_ready()
    -- Add initialization code here
    button1 = current_scene:get_entity_by_name("Continue"):get_component("UIButtonComponent")
    button2 = current_scene:get_entity_by_name("SettingsButton"):get_component("UIButtonComponent")
    button4 = current_scene:get_entity_by_name("Exit"):get_component("UIButtonComponent")

    text1 = current_scene:get_entity_by_name("VolumeText"):get_component("UITextComponent")
    text2 = current_scene:get_entity_by_name("FXText"):get_component("UITextComponent")

    visibilidad1Entity = current_scene:get_entity_by_name("Pause")
    visibilidad2Entity = current_scene:get_entity_by_name("Settings")

    VolumeText = current_scene:get_entity_by_name("VolumeText"):get_component("UITextComponent")
    FXText = current_scene:get_entity_by_name("FXText"):get_component("UITextComponent")

    slider1 = current_scene:get_entity_by_name("Volume"):get_component("UISliderComponent")
    slider2 = current_scene:get_entity_by_name("FX"):get_component("UISliderComponent")

    chatarraUI = current_scene:get_entity_by_name("ChatarraUI")

    if currentSelectedSlider == 1 then
        slider1.selected = true
        slider2.selected = false
    elseif currentSelectedSlider == 2 then
        slider2.selected = true
        slider1.selected = false
    end

    --Audio
    settingsSFX = current_scene:get_entity_by_name("SettingsSFX"):get_component("AudioSourceComponent")
    indexHoverSFX = current_scene:get_entity_by_name("HoverButtonSFX"):get_component("AudioSourceComponent")
    indexSelectionSFX = current_scene:get_entity_by_name("PressButtonSFX"):get_component("AudioSourceComponent")

    PauseText = current_scene:get_entity_by_name("PauseText"):get_component("UITextComponent")
    SettingsBaseText = current_scene:get_entity_by_name("SettingsText"):get_component("UITextComponent")

    visibilidadtotal = current_scene:get_entity_by_name("PauseBase")

    workbenchUIManagerScript = current_scene:get_entity_by_name("WorkBenchUIManager"):get_component("ScriptComponent")

    local savedVolumeGeneral = load_progress("musicVolumeGeneral", 50.0)
    savedVolumeGeneral = savedVolumeGeneral / 100
    slider1.value = savedVolumeGeneral
    
    local savedFXVolume = load_progress("fxVolume", 50.0)
    savedFXVolume = savedFXVolume / 100
    slider2.value = savedFXVolume

    visibilidad1Entity:set_active(false)
    visibilidad2Entity:set_active(false)

    fadeToBlackScript = current_scene:get_entity_by_name("FadeToBlack"):get_component("ScriptComponent")

end

function on_update(dt)
    -- Add update code here
    
    value = Input.get_button(Input.action.Pause)
    if ((value == Input.state.Down)) then
        if(isPaused) then
            isPaused = false
            visibilidad1Entity:set_active(false)
            visibilidad2Entity:set_active(false)
            chatarraUI:set_active(true)
            isOnPauseSettings = false

        else
            isPaused = true
            visibilidad1Entity:set_active(true)
            chatarraUI:set_active(false)
            if workbenchUIManagerScript.isWorkBenchOpen == true then
                workbenchUIManagerScript:hide_ui() 
            end
        end
        indexSelectionSFX:play()
    end 


    if index == 0 then
        button1.state = State.Hover
        button2.state = State.Normal
        button4.state = State.Normal
        if isPaused then
            value = Input.get_button(Input.action.Confirm)
            if((value == Input.state.Down)) then
                indexSelectionSFX:play()
                if(index == 0) then
                    visibilidad1Entity:set_active(false)
                    isPaused = false
                end
            end
        end

    elseif index == 1 then
        button1.state = State.Normal
        button2.state = State.Hover
        button4.state = State.Normal
        if isPaused then
            value = Input.get_button(Input.action.Confirm)
            if((value == Input.state.Down)) then
                indexSelectionSFX:play()
                if(index == 1) then
                    --button2:set_state("Pressed")
                    sceneChanged = true
                    visibilidad2Entity:set_active(true)
                    isOnPauseSettings = true
                end
            end
        end
        
    else
        button1.state = State.Normal
        button2.state = State.Normal
        button4.state = State.Hover
        if isPaused then
            value = Input.get_button(Input.action.Confirm)
            if((value == Input.state.Down)) then
                indexSelectionSFX:play()
                --button4:set_state("Pressed")
                if(index == 2) then
                save_progress("skipIntroDelay", true)
                fadeToBlackScript:DoFade()
                SceneManager.change_scene("scenes/mainMenu.TeaScene")
                end
            end
        end
    end

    if isPaused and isOnPauseSettings == false then
        local value = Input.get_axis(Input.action.UiMoveVertical)
        if (value ~= 0 and contadorMovimientoBotones > 0.2) then
            contadorMovimientoBotones = 0
            
            if value < 0 then
                index = index - 1;
                if index < 0 then
                    index = 2
                end
            end
            
            if value > 0 then
                index = index + 1
                if index > 2 then
                    index = 0
                end
            end
        else
            contadorMovimientoBotones = contadorMovimientoBotones + dt
        end
    end

    if isOnPauseSettings then
        local horizontalInput = Input.get_axis(Input.action.UiMoveHorizontal)
        if math.abs(horizontalInput) > 0.5 then
            inputCooldown = cooldownTime / 2

            if currentSelectedSlider == 1 then
                slider1.value = math.max(0.0, math.min(1.0, slider1.value + (horizontalInput * 0.05)))
                musicVolume = slider1.value
                
                set_music_volume(musicVolume)
                musicVolume = musicVolume * 100
                save_progress("musicVolumeGeneral", musicVolume)

            elseif currentSelectedSlider == 2 then
                slider2.value = math.max(0.0, math.min(1.0, slider2.value + (horizontalInput * 0.05)))
                fxVolume = slider2.value
                
                log("Este es el valor del slider ahora: " .. fxVolume)
               
                set_sfx_volume(fxVolume)
            
                fxVolume = fxVolume * 100
                save_progress("fxVolume", fxVolume)
                if fxVolume ~= 100 then
                    settingsSFX:play()
                end
            end
        end
    end
        
    if inputCooldown > 0 then
        inputCooldown = inputCooldown - dt
        return
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

        if currentSelectedSlider == 1 then
            slider1.selected = true
            slider2.selected = false
        elseif currentSelectedSlider == 2 then
            slider2.selected = true
            slider1.selected = false
        end
        
        inputCooldown = cooldownTime
        return
    end


    value = Input.get_button(Input.action.Cancel)
    if((value == Input.state.Down)) then
        if isOnPauseSettings then
            visibilidad2Entity:set_active(false)
            isOnPauseSettings = false
        else
            
            sceneChanged = true
            visibilidad1Entity:set_active(false)
            visibilidad2Entity:set_active(false)
            chatarraUI:set_active(true)
            isPaused = false
        end
    end 

    if index ~= currentSelectedIndex then
        indexHoverSFX:play()
        currentSelectedIndex = index
    end
    
end 


function hide_pause()
    --[[isPaused = false
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
    BaseTextureBG:set_visible(false) --]]
end

function on_exit()
    -- Add cleanup code here
end