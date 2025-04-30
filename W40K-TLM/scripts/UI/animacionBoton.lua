local imageComponent
local orderEntity
local baseScript
local rect
local spriteWidth = 579
local spriteHeight = 368
local sheetWidth = 3474
local sheetHeight = 736
local horizontalSprites = sheetWidth / spriteWidth
local verticalSprites = sheetHeight / spriteHeight
local animationTime = 0
local speed = 1/24
local animationFinished = false

function on_ready()
    imageComponent = self:get_component("UIImageComponent")
    orderEntity = current_scene:get_entity_by_name("Order")
    baseScript = current_scene:get_entity_by_name("BaseManager"):get_component("ScriptComponent")
    rect = Vector4.new(0, 0, spriteWidth / sheetWidth, spriteHeight / sheetHeight)
    imageComponent:set_rect(rect)
    orderEntity:set_active(false)
end

function on_update(dt)
    if animationFinished then
        return
    end

    animationTime = animationTime + dt
    local totalSprites = 12
    local spriteIndex = math.floor(animationTime / speed)

    if spriteIndex >= totalSprites then
        animationFinished = true
        orderEntity:set_active(true)
        baseScript.index = 0
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