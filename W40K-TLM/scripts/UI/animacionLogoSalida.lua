local imageComponent
local imageEntity
local imageComponentEntity
local rect
local spriteWidth = 1154
local spriteHeight = 508
local sheetWidth = 9232
local sheetHeight = 3048
local horizontalSprites = sheetWidth / spriteWidth
local verticalSprites = sheetHeight / spriteHeight
local animationTime = 0
local speed = 1/24
local animationFinished = false

function on_ready()
    imageComponent = self:get_component("UIImageComponent")
    imageEntity = current_scene:get_entity_by_name("LogoSalida")
    imageComponentEntity = current_scene:get_entity_by_name("Logo")
    rect = Vector4.new(0, 0, spriteWidth / sheetWidth, spriteHeight / sheetHeight)
    imageComponent:set_rect(rect)
end

function on_update(dt)
    if animationFinished then
        return
    end

    animationTime = animationTime + dt
    local totalSprites = 48
    local spriteIndex = math.floor(animationTime / speed)

    if spriteIndex >= totalSprites then
        animationFinished = true
        imageEntity:set_active(false)
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
