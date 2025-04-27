local imageComponent
local imageEntity
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

local delayBeforeStart = 0 -- segundos de espera
local delayTimer = 0
local startedAnimation = false

function on_ready()
    imageComponent = self:get_component("UIImageComponent")
    imageEntity = current_scene:get_entity_by_name("BotonSalidaNewGame")
    rect = Vector4.new(0, 0, spriteWidth / sheetWidth, spriteHeight / sheetHeight)
    imageComponent:set_rect(rect)
end

function on_update(dt)
    if animationFinished then
        return
    end

    if not startedAnimation then
        delayTimer = delayTimer + dt
        if delayTimer >= delayBeforeStart then
            startedAnimation = true
        else
            return -- todavía esperando, no empieza animación
        end
    end

    animationTime = animationTime + dt
    local totalSprites = 12
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
