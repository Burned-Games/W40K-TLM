local slider1 
local slider2 

local text1
local text2

local currentSelectedSlider = 1 
local inputCooldown = 0 
local cooldownTime = 0.15 
local sceneChanged = false
local value = nil

local newValue = 1.0

local defaultColor = Vector4.new(130/255, 19/255, 7/255, 1.0)
local selectedColor = Vector4.new(1.0, 1.0, 1.0, 1.0)


function on_ready()
    slider1 = current_scene:get_entity_by_name("Volume"):get_component("UISliderComponent")
    slider2 = current_scene:get_entity_by_name("FX"):get_component("UISliderComponent")

    text1 = current_scene:get_entity_by_name("VolumeText"):get_component("UITextComponent")
    text2 = current_scene:get_entity_by_name("FXText"):get_component("UITextComponent")

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
  
    if inputCooldown > 0 then
        inputCooldown = inputCooldown - dt
        return
    end

    value = Input.get_button(Input.action.Cancel)
    if((value == Input.state.Down and sceneChanged == false) or (Input.is_key_pressed(Input.keycode.K) and sceneChanged == false)) then
        -- lógica de la actualización del volumen y de fxs
        save_progress("musicVolumeGeneral", slider1.value)
        save_progress("fxVolume", slider2.value)
        sceneChanged = true
        SceneManager.change_scene("Default.TeaScene")
        
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
            text1:set_color(selectedColor)
            text2:set_color(defaultColor)
        else
            text1:set_color(defaultColor)
            text2:set_color(selectedColor)
        end
        inputCooldown = cooldownTime
        return
    end

   
    local horizontalInput = Input.get_axis(Input.action.UiMoveHorizontal)
    if math.abs(horizontalInput) > 0.5 then
        local selectedSlider = (currentSelectedSlider == 1) and slider1 or slider2
        local currentValue = selectedSlider.value
        
       
        newValue = currentValue + (horizontalInput * 0.05) 
        newValue = math.max(0.0, math.min(1.0, newValue))
        
        selectedSlider.value = newValue
        inputCooldown = cooldownTime / 2 
    end

    
end

function on_exit()
   
end