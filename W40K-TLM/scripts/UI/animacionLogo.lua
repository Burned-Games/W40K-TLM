local imageComponent
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

local delayTimer = 0
local delayDuration = 1.0

function on_ready()
    imageComponent = self:get_component("UIImageComponent")
    imageComponentEntity = current_scene:get_entity_by_name("Logo")
    rect = Vector4.new(0, 0, spriteWidth / sheetWidth, spriteHeight / sheetHeight)
    imageComponent:set_rect(rect)

    
end

function on_update(dt)
    if animationFinished then
        return
    end

    
    if delayTimer < delayDuration then
        delayTimer = delayTimer + dt
        return
    end
    
    
    animationTime = animationTime + dt
    local totalSprites = 48
    local spriteIndex = math.floor(animationTime / speed)

    if spriteIndex >= totalSprites then
        animationFinished = true
        return
    end

    local reversedIndex = (totalSprites - 1) - spriteIndex
    local horizontalIndex = reversedIndex % horizontalSprites
    local verticalIndex = math.floor(reversedIndex / horizontalSprites)

    rect.x = horizontalIndex * (spriteWidth / sheetWidth)
    rect.y = (verticalSprites - 1 - verticalIndex) * (spriteHeight / sheetHeight)

    imageComponent:set_rect(rect)
end

function on_exit()
    -- Add cleanup code here
end
