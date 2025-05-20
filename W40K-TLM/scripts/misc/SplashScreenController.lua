local timeToTransition = 5

local contador = 0
local fadeToBlackScript = nil
local changeing = false
local logoObj = nil
local logo = nil
local title = nil

-- Animation parameters
local expandDuration = 2.0  -- Duration of expansion phase (1 second)
local maxScale = 1.01       -- Maximum scale factor (reduced to avoid GL errors)
local originalScale = 1.0   -- Original scale to return to

function on_ready()

    fadeToBlackEntity = current_scene:get_entity_by_name("FadeToBlack")
    fadeToBlackScript = fadeToBlackEntity:get_component("ScriptComponent")
    logoObj = current_scene:get_entity_by_name("logo")
    logo = logoObj:get_component("UIImageComponent")
  
    
    local titleEntity = current_scene:get_entity_by_name("title")
    title = titleEntity:get_component("UITextComponent")

end

function on_update(dt)
    contador = contador + dt
    
    if not logoObj or not logo then
        if contador > timeToTransition and fadeToBlackScript and not changeing then
            changeing = true
            fadeToBlackScript:DoFade()
        end
        return
    end
    
    if contador <= expandDuration then

        local expandProgress = contador / expandDuration
        local scale = originalScale + (maxScale - originalScale) * expandProgress

        scale = math.max(0.1, math.min(scale, 2.0))
        scale_ui_element(logoObj, scale)
        
    elseif contador <= timeToTransition then
        local shrinkProgress = (contador - expandDuration) / (timeToTransition - expandDuration)
   
        local alpha = 1.0 - shrinkProgress
        alpha = math.max(0.0, math.min(alpha, 1.0))
        
        logo:set_color(Vector4.new(1, 1, 1, alpha))


    end

    if contador > timeToTransition and fadeToBlackScript and not changeing then
        changeing = true
        fadeToBlackScript:DoFade()
    end

    if changeing and not changeScene and fadeToBlackScript and fadeToBlackScript.fadeToBlackDoned then
        changeScene = true
        SceneManager.change_scene("scenes/mainMenu.TeaScene")
    end
end

function on_exit()
end