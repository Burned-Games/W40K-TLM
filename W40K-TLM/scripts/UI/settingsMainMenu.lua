local slider1 
local slider2 

local text1
local text2

local mainMenuBase = nil
local mainMenuScript = nil


local currentSelectedSlider = 1 
local inputCooldown = 0 
local cooldownTime = 0.15 
local sceneChanged = false
local value = nil
local defaultMusicVolume = 0.210

local newValue = 1.0

local selectedColor = Vector4.new(130/255, 19/255, 7/255, 1.0)
local defaultColor = Vector4.new(1.0, 1.0, 1.0, 1.0)

local settingsMainMenu = nil


function on_ready()
    slider1 = current_scene:get_entity_by_name("Volume"):get_component("UISliderComponent")
    slider2 = current_scene:get_entity_by_name("FX"):get_component("UISliderComponent")

    text1 = current_scene:get_entity_by_name("VolumeText"):get_component("UITextComponent")
    text2 = current_scene:get_entity_by_name("FXText"):get_component("UITextComponent")

    mainMenuBase = current_scene:get_entity_by_name("Base")
    mainMenuScript = current_scene:get_entity_by_name("BaseManager"):get_component("ScriptComponent")
    settingsMainMenu = current_scene:get_entity_by_name("Settings")

    musicaFondoDefault = current_scene:get_entity_by_name("BackgroundMusic"):get_component("AudioSourceComponent")

    -- guardar el nivel de volumen actual
    mainMenuBase:set_active(false)


    local savedVolumeGeneral = load_progress("musicVolumeGeneral", 1.0)
    savedVolumeGeneral = savedVolumeGeneral / 100
    slider1.value = savedVolumeGeneral
    set_music_volume(savedVolumeGeneral)
    slider1.value = savedVolumeGeneral
    
    local savedFXVolume = load_progress("fxVolume", 1.0)
    savedFXVolume = savedFXVolume / 100
    slider2.value = savedFXVolume
    set_sfx_volume(savedFXVolume)

    
    --ajustes de audio
    --explorationMusic = current_scene:get_entity_by_name("MusicExploration"):get_component("AudioSourceComponent")

    if currentSelectedSlider == 1 then
        text1:set_color(selectedColor)
        text2:set_color(defaultColor)
    else
        text1:set_color(defaultColor)
        text2:set_color(selectedColor)
    end
end

function on_update(dt)

    if mainMenuScript.saliendoDeMenu == false then
        if mainMenuScript.ajustesOpened then
            mainMenuBase:set_active(false)
            settingsMainMenu:set_active(true)
        else
            mainMenuBase:set_active(true)
            settingsMainMenu:set_active(false)
        end
    end
    
    if inputCooldown > 0 then
        inputCooldown = inputCooldown - dt
        return
    end

    value = Input.get_button(Input.action.Cancel)
    if((value == Input.state.Down) or (Input.is_key_pressed(Input.keycode.K))) then
        -- lógica de la actualización del volumen y de fxs
        save_progress("musicVolumeGeneral", slider1.value * 100)
        
        save_progress("fxVolume", slider2.value * 100)

        
        mainMenuScript.ajustesOpened = false
    end
   
    if mainMenuScript.ajustesOpened == true then
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
                text1:set_color(selectedColor)
                text2:set_color(defaultColor)
            else
                text1:set_color(defaultColor)
                text2:set_color(selectedColor)
            end
            inputCooldown = cooldownTime
            return
        end
    end

   if mainMenuScript.ajustesOpened == true then
        local horizontalInput = Input.get_axis(Input.action.UiMoveHorizontal)
        if math.abs(horizontalInput) > 0.5 then
            local selectedSlider = (currentSelectedSlider == 1) and slider1 or slider2
            local currentValue = selectedSlider.value
            
        
            newValue = currentValue + (horizontalInput * 0.05) 
            newValue = math.max(0.0, math.min(1.0, newValue))

            
            
            selectedSlider.value = newValue

            if currentSelectedSlider == 1 then
                set_music_volume(newValue)
                
            elseif currentSelectedSlider == 2 then
                set_sfx_volume(newValue)
                
            end

            inputCooldown = cooldownTime / 2 
        end
    end
    
end

function on_exit()
   
end