local imageComponent
local buttonComponent
local order
local rect
local BaseEntity
local baseScript

-- Datos de la animación de entrada
local entrySpriteWidth = 579
local entrySpriteHeight = 1080
local entrySheetWidth = 5790
local entrySheetHeight = 6480
local entryHorizontalSprites = entrySheetWidth / entrySpriteWidth
local entryVerticalSprites = entrySheetHeight / entrySpriteHeight
local entryTotalSprites = 57

-- Datos de la animación de selección
local selectSpriteWidth = 579
local selectSpriteHeight = 368
local selectSheetWidth = 3474
local selectSheetHeight = 736
local selectHorizontalSprites = selectSheetWidth / selectSpriteWidth
local selectVerticalSprites = selectSheetHeight / selectSpriteHeight
local selectTotalSprites = 12

-- Variables generales
local animationTime = 0
local speed = 1/24
local currentPhase = "entry" 
local animationFinished = false

local delayTimer = 0 
local delayDuration = 0.5

function on_ready()
    imageComponent = self:get_component("UIImageComponent")
    buttonEntity = current_scene:get_entity_by_name("Botones")
    buttonComponent = buttonEntity:get_component("UIImageComponent")
    BaseEntity = current_scene:get_entity_by_name("Base")
    baseScript = current_scene:get_entity_by_name("BaseManager"):get_component("ScriptComponent")

    order = current_scene:get_entity_by_name("Order")

    -- Inicializamos el rect de entrada
    local entryRect = Vector4.new(0, 0, entrySpriteWidth / entrySheetWidth, entrySpriteHeight / entrySheetHeight)
    imageComponent:set_rect(entryRect)

    -- Inicializamos el botón oculto
    buttonEntity:set_active(false)
    order:set_active(false)
    BaseEntity:set_active(false)
end

function on_update(dt)
    if animationFinished then
        return
    end

    
    if delayTimer < delayDuration then
        delayTimer = delayTimer + dt
        return
    end

    BaseEntity:set_active(true)
    animationTime = animationTime + dt
    local spriteIndex = math.floor(animationTime / speed)

    if currentPhase == "entry" then
        if spriteIndex >= entryTotalSprites then
            
            currentPhase = "select"
            animationTime = 0 
            buttonEntity:set_active(true)
        
            
            local reversedIndex = (selectTotalSprites - 1) - 0 
            local horizontalIndex = reversedIndex % selectHorizontalSprites
            local verticalIndex = math.floor(reversedIndex / selectHorizontalSprites)
        
            local x = horizontalIndex * (selectSpriteWidth / selectSheetWidth)
            local y = (selectVerticalSprites - 1 - verticalIndex) * (selectSpriteHeight / selectSheetHeight)
            local w = selectSpriteWidth / selectSheetWidth
            local h = selectSpriteHeight / selectSheetHeight
        
            buttonComponent:set_rect(Vector4.new(x, y, w, h))
        
            return
        end

        local horizontalIndex = spriteIndex % entryHorizontalSprites
        local verticalIndex = math.floor(spriteIndex / entryHorizontalSprites)

        local x = horizontalIndex * (entrySpriteWidth / entrySheetWidth)
        local y = (entryVerticalSprites - 1 - verticalIndex) * (entrySpriteHeight / entrySheetHeight)
        local w = entrySpriteWidth / entrySheetWidth
        local h = entrySpriteHeight / entrySheetHeight

        imageComponent:set_rect(Vector4.new(x, y, w, h))

    elseif currentPhase == "select" then
        if spriteIndex >= selectTotalSprites then
            animationFinished = true
            order:set_active(true)
            baseScript.index = 0
            buttonEntity:set_active(false)
            return
        end

        local reversedIndex = (selectTotalSprites - 1) - spriteIndex
        local horizontalIndex = reversedIndex % selectHorizontalSprites
        local verticalIndex = math.floor(reversedIndex / selectHorizontalSprites)

        local x = horizontalIndex * (selectSpriteWidth / selectSheetWidth)
        local y = (selectVerticalSprites - 1 - verticalIndex) * (selectSpriteHeight / selectSheetHeight)
        local w = selectSpriteWidth / selectSheetWidth
        local h = selectSpriteHeight / selectSheetHeight

        buttonComponent:set_rect(Vector4.new(x, y, w, h))
    end
end

function is_animation_finished()
    return animationFinished
end


function on_exit()
    -- Cleanup
end
