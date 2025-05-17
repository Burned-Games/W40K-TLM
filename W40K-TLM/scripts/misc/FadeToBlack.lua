


local fadeToBlackImage = nil

local starting = true
local contador = 0
local fadeToBlackTimer = 2.5

local fading = false
fadeToBlackDoned = false

local all_text_component = {}

function on_ready()
    -- Add initialization code here
    fadeToBlackImage = self:get_component("UIImageComponent")
    contador = 0
    starting = true
    fadeToBlackImage:set_color(Vector4.new(1,1,1, 1))


    local allEntities = current_scene:get_all_entities()
    for _, entity in ipairs(allEntities) do 
        if entity:has_component("UITextComponent") then
            log("found!" .. entity:get_component("TagComponent").tag)
            local textComponent = entity:get_component("UITextComponent")
            textComponent:set_color(Vector4.new(1,1,1, 0))
            table.insert(all_text_component, textComponent)
        end 
    end


end

function on_update(dt)
    -- Add update code here
    if starting then
        FadeToTransparent(dt)
    end

    if fading then
        FadeToBlack(dt)
    end


end


function DoFade()
    fading = true;
    fadeToBlackImage:set_color(Vector4.new(1,1,1, 0))
    contador = 0;
end

function FadeToTransparent(dt)
    contador = contador + dt
    local alpha = math.min(contador / fadeToBlackTimer, 1.0)
    alpha = 1.0 - alpha -- invertir
    


    

    if (contador > fadeToBlackTimer) then
        starting = false;
        fadeToBlackImage:set_color(Vector4.new(1,1,1, 0))

        for _, textComponent in ipairs(all_text_component) do  
            textComponent:set_color(Vector4.new(1,1,1,1))
        end

    else
        fadeToBlackImage:set_color(Vector4.new(1,1,1, alpha))
        for _, textComponent in ipairs(all_text_component) do  
            textComponent:set_color(Vector4.new(1,1,1, 1.0 - alpha))
        end
    end
end

function FadeToBlack(dt)
    contador = contador + dt
    local alpha = math.min(contador / fadeToBlackTimer, 1.0)
   

    if (contador > fadeToBlackTimer) then
        fading = false;
        fadeToBlackImage:set_color(Vector4.new(1,1,1, 1))
        for _, textComponent in ipairs(all_text_component) do  
            textComponent:set_color(Vector4.new(1,1,1,0))
        end
        fadeToBlackDoned = true
    else 
        fadeToBlackImage:set_color(Vector4.new(1,1,1, alpha))
        for _, textComponent in ipairs(all_text_component) do  
            textComponent:set_color(Vector4.new(1,1,1,1.0 - alpha))
        end

    end
end

function on_exit()
    -- Add cleanup code here
end
