


local fadeToBlackImage = nil

local starting = true
local contador = 0
local fadeToBlackTimer = 2.5

local fading = false
fadeToBlackDoned = false

function on_ready()
    -- Add initialization code here
    fadeToBlackImage = self:get_component("UIImageComponent")
    contador = 0
    starting = true
    fadeToBlackImage:set_color(Vector4.new(1,1,1, 1))
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
    fadeToBlackImage:set_color(Vector4.new(1,1,1, alpha))

    if (contador > fadeToBlackTimer) then
        starting = false;
        fadeToBlackImage:set_color(Vector4.new(1,1,1, 0))
    end
end

function FadeToBlack(dt)
    contador = contador + dt
    local alpha = math.min(contador / fadeToBlackTimer, 1.0)
    fadeToBlackImage:set_color(Vector4.new(1,1,1, alpha))

    if (contador > fadeToBlackTimer) then
        fading = false;
        fadeToBlackImage:set_color(Vector4.new(1,1,1, 1))
        fadeToBlackDoned = true
    end
end

function on_exit()
    -- Add cleanup code here
end
