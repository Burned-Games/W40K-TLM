


local fadeToBlackImage = nil

local starting = true
local contador = 0
local fadeToBlackTimer = 2.5

local fading = false
fadeToBlackDoned = false

local all_text_component = {}
local all_text_original_colors = {}

local targetSFXVolume = nil
local targetMusicVolume = nil

local actualSFXVolume = 0
local actualMusicVolume = 0

function on_ready()
    -- Add initialization code here
    fadeToBlackImage = self:get_component("UIImageComponent")
    contador = 0
    starting = true
    fadeToBlackImage:set_color(Vector4.new(1,1,1, 1))


    local allEntities = current_scene:get_all_entities()
    for _, entity in ipairs(allEntities) do 
        if entity:has_component("UITextComponent") then
            local textComponent = entity:get_component("UITextComponent")
            local textColor = textComponent:get_color()
            table.insert(all_text_original_colors, textColor)
            textComponent:set_color(Vector4.new(textColor.x,textColor.y,textColor.z, 0))
            table.insert(all_text_component, textComponent)
        end 
    end

    targetMusicVolume = load_progress("musicVolumeGeneral", 50.0) / 100
    targetSFXVolume = load_progress("fxVolume", 50.0) / 100


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
    targetMusicVolume = load_progress("musicVolumeGeneral", 50.0) / 100
    targetSFXVolume = load_progress("fxVolume", 50.0) / 100
end

function FadeToTransparent(dt)
    contador = contador + dt
    local alpha = math.min(contador / fadeToBlackTimer, 1.0)
    alpha = 1.0 - alpha -- invertir

    set_music_volume((1.0 - alpha) * targetMusicVolume)
    set_sfx_volume((1.0 - alpha) * targetSFXVolume)

    if (contador > fadeToBlackTimer) then
        starting = false;
        fadeToBlackImage:set_color(Vector4.new(1,1,1, 0))

        for i, textComponent in ipairs(all_text_component) do  
            textComponent:set_color(Vector4.new(all_text_original_colors[i].x, all_text_original_colors[i].y, all_text_original_colors[i].z, 1))
        end

    else
        fadeToBlackImage:set_color(Vector4.new(1,1,1, alpha))
        for i, textComponent in ipairs(all_text_component) do  
            textComponent:set_color(Vector4.new(all_text_original_colors[i].x, all_text_original_colors[i].y, all_text_original_colors[i].z, 1.0 - alpha))
        end
    end
end

function FadeToBlack(dt)
    contador = contador + dt
    local alpha = math.min(contador / fadeToBlackTimer, 1.0)
   
    set_music_volume((1.0 - alpha) * targetMusicVolume)
    set_sfx_volume((1.0 - alpha) * targetSFXVolume)

    if (contador > fadeToBlackTimer) then
        fading = false;
        fadeToBlackImage:set_color(Vector4.new(1,1,1, 1))
        for i, textComponent in ipairs(all_text_component) do  
            textComponent:set_color(Vector4.new(all_text_original_colors[i].x,all_text_original_colors[i].y,all_text_original_colors[i].z,0))
        end
        fadeToBlackDoned = true
    else 
        fadeToBlackImage:set_color(Vector4.new(1,1,1, alpha))
        for i, textComponent in ipairs(all_text_component) do  
            if textComponent:get_color().w == 0 then
                textComponent:set_color(Vector4.new(all_text_original_colors[i].x,all_text_original_colors[i].y,all_text_original_colors[i].z, 0))
            else
                textComponent:set_color(Vector4.new(all_text_original_colors[i].x,all_text_original_colors[i].y,all_text_original_colors[i].z,1.0 - alpha))
            end
            
        end

    end
end

function on_exit()
    -- Add cleanup code here
end
