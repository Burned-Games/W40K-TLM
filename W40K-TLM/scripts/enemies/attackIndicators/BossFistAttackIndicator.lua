
local transform = nil
local indicator = nil
local background = nil

local backgroundColor = nil
local indicatorColor = nil

local backgroundSprite = nil
local indicatorSprite = nil

local indicatorTransform = nil

local isRunning = false
local actualSize = 0
local actualAlpha = 0;
local speedIndicator = 0.6

function on_ready()
    -- Add initialization code here

    transform = self:get_component("TransformComponent")

    

    local children = self:get_children()
    for _, child in ipairs(children) do
        if child:get_component("TagComponent").tag == "Indicator" then
            indicator = child
        end
        if child:get_component("TagComponent").tag == "Background" then
            background = child
        end
    end
    indicatorTransform = indicator:get_component("TransformComponent")
    indicatorTransform.scale = Vector3.new(0,0,0)

    backgroundSprite = background:get_component("SpriteComponent")
    indicatorSprite = indicator:get_component("SpriteComponent")

    

    backgroundColor = backgroundSprite.tint_color
    indicatorColor = indicatorSprite.tint_color

    backgroundSprite.tint_color = Vector4.new(backgroundColor.x, backgroundColor.y, backgroundColor.z, 0)
    indicatorSprite.tint_color = Vector4.new(indicatorColor.x, indicatorColor.y, indicatorColor.z, 0)


end


function startIndicator()
    isRunning = true;
    indicatorTransform.scale = Vector3.new(0,0,0)
    backgroundSprite.tint_color = Vector4.new(backgroundColor.x, backgroundColor.y, backgroundColor.z, actualAlpha)
    indicatorSprite.tint_color = Vector4.new(indicatorColor.x, indicatorColor.y, indicatorColor.z, actualAlpha)

    actualAlpha = 0
    actualSize = 0
end



function on_update(dt)
    -- Add update code here

    if Input.is_key_pressed(Input.keycode.J) then
        if not isRunning then
            startIndicator()
        end
    end


    if isRunning then

        --Appear
        actualAlpha = actualAlpha + (dt * 0.5)
        if actualAlpha >= 1 then
            actualAlpha = 1
        end



        backgroundSprite.tint_color = Vector4.new(backgroundColor.x, backgroundColor.y, backgroundColor.z, actualAlpha)
        indicatorSprite.tint_color = Vector4.new(indicatorColor.x, indicatorColor.y, indicatorColor.z, actualAlpha)


        actualSize = actualSize + (dt * speedIndicator)
        if(actualSize >= 1) then
            actualSize = 1
            isRunning = false
            backgroundSprite.tint_color = Vector4.new(backgroundColor.x, backgroundColor.y, backgroundColor.z, 0)
            indicatorSprite.tint_color = Vector4.new(indicatorColor.x, indicatorColor.y, indicatorColor.z, 0)
            
        end
        indicatorTransform.scale = Vector3.new(actualSize,actualSize,actualSize)
    end

end

function on_exit()
    -- Add cleanup code here
end
