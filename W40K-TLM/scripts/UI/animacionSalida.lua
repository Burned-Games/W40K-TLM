local imageComponent

local baseImagen
local logoImagen
local settingsScript
local fadeToBlackScript = nil

local rect
local spriteWidth = 579
local spriteHeight = 1080
local sheetWidth = 6948
local sheetHeight = 5400
local horizontalSprites = sheetWidth / spriteWidth
local verticalSprites = sheetHeight / spriteHeight
local animationTime = 0
local speed = 1/24
local animationFinished = false

function on_ready()
    imageComponent = self:get_component("UIImageComponent")
    baseImagen = current_scene:get_entity_by_name("Base")

    fadeToBlackScript = current_scene:get_entity_by_name("FadeToBlack"):get_component("ScriptComponent")
    rect = Vector4.new(0, 0, spriteWidth / sheetWidth, spriteHeight / sheetHeight)
    imageComponent:set_rect(rect)
    baseImagen:set_active(false)

end

function on_update(dt)
    if animationFinished then
        return
    end

    animationTime = animationTime + dt
    local totalSprites = 60
    local spriteIndex = math.floor(animationTime / speed)

    if spriteIndex >= totalSprites then
        animationFinished = true
        fadeToBlackScript:DoFade()
        return
    end

    local horizontalIndex = spriteIndex % horizontalSprites
    local verticalIndex = math.floor(spriteIndex / horizontalSprites)

    rect.x = horizontalIndex * (spriteWidth / sheetWidth)
    rect.y = (verticalSprites - 1 - verticalIndex) * (spriteHeight / sheetHeight)

    imageComponent:set_rect(rect)
end

function on_exit()
    -- Add cleanup code here
end