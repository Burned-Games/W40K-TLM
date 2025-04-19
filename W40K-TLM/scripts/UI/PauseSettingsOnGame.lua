local button1
local button2
local button3
local button4
local visibilidad1Entity
local visibilidad2Entity
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
local BaseTextureBG

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
local isOnPauseSettings = false

local visibilidadtotal

local workbenchUIManagerScript = nil

local defaultColor = Vector4.new(130/255, 19/255, 7/255, 1.0)
local selectedColor = Vector4.new(1.0, 1.0, 1.0, 1.0)

musicVolume = 0.0
fxVolume = 0.0

function on_ready()
    -- Add initialization code here
    button1 = current_scene:get_entity_by_name("Continue"):get_component("UITextComponent")
    button2 = current_scene:get_entity_by_name("SettingsButton"):get_component("UITextComponent")
    button3 = current_scene:get_entity_by_name("SaveGame"):get_component("UITextComponent")
    button4 = current_scene:get_entity_by_name("Exit"):get_component("UITextComponent")

    visibilidad1Entity = current_scene:get_entity_by_name("Pause")
    visibilidad2Entity = current_scene:get_entity_by_name("Settings")

    VolumeText = current_scene:get_entity_by_name("VolumeText"):get_component("UITextComponent")
    FXText = current_scene:get_entity_by_name("FXText"):get_component("UITextComponent")

    slider1 = current_scene:get_entity_by_name("Volume"):get_component("UISliderComponent")
    slider2 = current_scene:get_entity_by_name("FX"):get_component("UISliderComponent")


    PauseText = current_scene:get_entity_by_name("PauseText"):get_component("UITextComponent")
    SettingsBaseText = current_scene:get_entity_by_name("SettingsText"):get_component("UITextComponent")

    visibilidadtotal = current_scene:get_entity_by_name("PauseBase")

    --workbenchUIManagerScript = current_scene:get_entity_by_name("WorkBenchUI"):get_component("ScriptComponent")

    --BaseTextureBGEntity = current_scene:get_entity_by_name("PauseBase")
    --BaseTextureBG = BaseTextureBGEntity:get_component("UIImageComponent")

    -- audio
   -- explorationMusic = current_scene:get_entity_by_name("MusicExploration"):get_component("AudioSourceComponent")
    --combatMusic = current_scene:get_entity_by_name("MusicCombat"):get_component("AudioSourceComponent")

    -- fx
    --[[footstep_one = current_scene:get_entity_by_name("PlayerStep1"):get_component("AudioSourceComponent")
    footstep_two = current_scene:get_entity_by_name("PlayerStep2"):get_component("AudioSourceComponent")
    footstep_three = current_scene:get_entity_by_name("PlayerStep3"):get_component("AudioSourceComponent")
    footstep_four = current_scene:get_entity_by_name("PlayerStep4"):get_component("AudioSourceComponent")
    burst_shot = current_scene:get_entity_by_name("RifleDisparoAudio"):get_component("AudioSourceComponent")
    rifle_reload = current_scene:get_entity_by_name("RifleRecargaAudio"):get_component("AudioSourceComponent")
    shotgun_shot = current_scene:get_entity_by_name("EscopetaDisparoAudio"):get_component("AudioSourceComponent")
    shotgun_reload = current_scene:get_entity_by_name("EscopetaRecargaAudio"):get_component("AudioSourceComponent")
    grenade_launch = current_scene:get_entity_by_name("GranadeLaunchAudio"):get_component("AudioSourceComponent")
    grenade_explosion = current_scene:get_entity_by_name("GranadeExplosionAudio"):get_component("AudioSourceComponent") --]]

    local savedFXVolume = load_progress("fxVolume", 1.0)
                             --slider2:set_value(savedFXVolume) este estaba descomentado

    --local savedVolumeGeneral = load_progress("musicVolumeGeneral", 0.05)
    --xplorationMusic:set_volume(savedVolumeGeneral)

                   --slider1:set_value(load_progress("musicVolumeGeneral", 1.0)) este estaba descomentado
    -- slider2:set_value(load_progress("fxVolume", 1.0))

    visibilidad1Entity:set_active(false)
    visibilidad2Entity:set_active(false)
    visibilidadtotal:set_active(false)
    --BaseTextureBGEntity:set_active(false)
    --[[VolumeText:set_visible(false)
    FXText:set_visible(false)
    SettingsBaseText:set_visible(false)
    slider1:set_visible(false)
    slider2:set_visible(false)
    button1:set_visible(false)
    button2:set_visible(false)
    button3:set_visible(false)
    button4:set_visible(false)
    BaseTextureBG:set_visible(false) --]]

end

function on_update(dt)
    -- Add update code here
    
    value = Input.get_button(Input.action.Pause)
    if ((value == Input.state.Down) or (Input.is_key_pressed(Input.keycode.K))) then
        if(isPaused) then
            isPaused = false
            visibilidad1Entity:set_active(false)
            visibilidad2Entity:set_active(false)
            isOnPauseSettings = false

        else
            isPaused = true
            visibilidad1Entity:set_active(true)
            --[[if workbenchUIManagerScript.isWorkBenchOpen == true then
                workbenchUIManagerScript:hide_ui() 
            end--]]
        end
    end 


    if index == 0 then
        --[[button1.state = "Hover"
        button2.state = "Normal"
        button3.state = "Normal"
        button4.state = "Normal"--]]

        button1:set_color(selectedColor)
        button2:set_color(defaultColor)
        button3:set_color(defaultColor)
        button4:set_color(defaultColor)

        value = Input.get_button(Input.action.Interact)
        if((value == Input.state.Down) or (Input.is_key_pressed(Input.keycode.K))) then
            if(index == 0) then
                visibilidad1Entity:set_active(false)
                isPaused = false
            end
        end

    elseif index == 1 then
        button1:set_color(defaultColor)
        button2:set_color(selectedColor)
        button3:set_color(defaultColor)
        button4:set_color(defaultColor)

        value = Input.get_button(Input.action.Interact)
        if((value == Input.state.Down) or (Input.is_key_pressed(Input.keycode.K))) then
            if(index == 1) then
                --button2:set_state("Pressed")
                sceneChanged = true
                visibilidad2Entity:set_active(true)
                visibilidad1Entity:set_active(false)
                isOnPauseSettings = true
            end
        end
        
    elseif index == 2 then
        button1:set_color(defaultColor)
        button2:set_color(defaultColor)
        button3:set_color(selectedColor)
        button4:set_color(defaultColor)

        value = Input.get_button(Input.action.Confirm)
        if((value == Input.state.Down) or (Input.is_key_pressed(Input.keycode.K))) then
            --button3:set_state("Pressed")
            if(index == 2) then
                sceneChanged = true
                --print("Saving game...")
            end
        end

    else
        button1:set_color(defaultColor)
        button2:set_color(defaultColor)
        button3:set_color(defaultColor)
        button4:set_color(selectedColor)

        value = Input.get_button(Input.action.Interact)
        if((value == Input.state.Down) or (Input.is_key_pressed(Input.keycode.K))) then
            --button4:set_state("Pressed")
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


    if isOnPauseSettings then
        local horizontalInput = Input.get_axis(Input.action.UiMoveHorizontal)
        if math.abs(horizontalInput) > 0.5 then
            inputCooldown = cooldownTime / 2
            print("horizontal")
            if currentSelectedSlider == 1 then
               
                local currentValue = slider1.value
                musicVolume = currentValue + (horizontalInput * 0.05)
                musicVolume = math.max(0.0, math.min(1.0, musicVolume))
                slider1.value = musicVolume
    
                
                explorationMusic:set_volume(musicVolume)
                combatMusic:set_volume(musicVolume)
    
                
                save_progress("musicVolumeGeneral", musicVolume)
    
            elseif currentSelectedSlider == 2 then
                
                local currentValue = slider2.value
                fxVolume = currentValue + (horizontalInput * 0.05)
                fxVolume = math.max(0.0, math.min(1.0, fxVolume))
                slider2.value = fxVolume
    
                
                --[[footstep_one:set_volume(fxVolume)
                footstep_two:set_volume(fxVolume)
                footstep_three:set_volume(fxVolume)
                footstep_four:set_volume(fxVolume)
                rifle_reload:set_volume(fxVolume)
                burst_shot:set_volume(fxVolume)
                shotgun_reload:set_volume(fxVolume)
                shotgun_shot:set_volume(fxVolume)
                grenade_explosion:set_volume(fxVolume)
                grenade_launch:set_volume(fxVolume)--]]
    
                
                save_progress("fxVolume", fxVolume)
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
        inputCooldown = cooldownTime
        return
    end


    value = Input.get_button(Input.action.Cancel)
    if((value == Input.state.Down) or (Input.is_key_pressed(Input.keycode.K))) then
        sceneChanged = true
        --visibilidad2Entity:set_active(false)
        --[[VolumeText:set_visible(false)
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
        PauseText:set_visible(true)--]]
        isOnPauseSettings = false
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