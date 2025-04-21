-- UI components
local popupNormal = nil
local popupBoss = nil

-- Animation state for popup image
local popupIsActive = false
local popupTimer = 0.0
local popupState = "idle" -- "enter", "hold", "exit"
local popupDuration = 2.0 -- seconds to hold

local popupYStart = -200
local popupYTarget = -200
local popupYExit = -400
local popupSpeed = 4.0 -- higher = faster

local useBossImage = false

-- Text component and its animation variables
local popupText = nil
local popupTextYStart = -400     -- Initial position (off-screen)
local popupTextYTarget = -185    -- Target position when popup is open
local popupTextYExit = -400      -- Exit position

local actualAlpha = 0

-- Initialization
function on_ready()
    -- Get UI components
    popupNormal = current_scene:get_entity_by_name("PopupNewZoneIMG"):get_component("UIImageComponent")
    popupBoss = current_scene:get_entity_by_name("PopUpBossZoneIMG"):get_component("UIImageComponent") -- Pay attention to spelling!
    popupText = current_scene:get_entity_by_name("PopUpText"):get_component("UITextComponent")

    -- Initialize as transparent
    set_popup_alpha_Start(0)
end

-- Update per frame
function on_update(dt)
    if popupIsActive then
        update_popup(dt)
    end

    if Input.is_key_pressed(Input.keycode.R) then
        show_popup(false, "ssssssw")
    end
end

-- Show popup: isBoss indicates whether it's a Boss area, message is the displayed text
function show_popup(isBoss, message)
    popupIsActive = true
    popupState = "enter"
    popupTimer = 0.0
    useBossImage = isBoss

    actualAlpha = 0

    if popupText then
        popupText:set_text(message or " ")
    end
end

-- Called every frame: Controls the animation state machine
function update_popup(dt)
    local currentPopup = useBossImage and popupBoss or popupNormal

    if popupState == "enter" then
        actualAlpha = lerp(actualAlpha, 1.0, dt * popupSpeed)
        set_popup_alpha(actualAlpha)

        if math.abs(actualAlpha - 1.0) < 0.01 then
            actualAlpha = 1.0
            set_popup_alpha(actualAlpha)
            popupState = "hold"
            popupTimer = 0.0
        end

    elseif popupState == "hold" then
        popupTimer = popupTimer + dt
        if popupTimer >= popupDuration then
            popupState = "exit"
        end

    elseif popupState == "exit" then
        actualAlpha = lerp(actualAlpha, 0.0, dt * popupSpeed)
        set_popup_alpha(actualAlpha)

        if actualAlpha < 0.01 then
            actualAlpha = 0.0
            set_popup_alpha(actualAlpha)
            popupState = "idle"
            popupIsActive = false
        end
    end
end

-- Helper function: Sets transparency for three components
function set_popup_alpha(alpha)
    if useBossImage then
        if popupBoss then popupBoss:set_color(Vector4.new(1, 1, 1, alpha)) end
    else
        if popupNormal then popupNormal:set_color(Vector4.new(1, 1, 1, alpha)) end
    end
    if popupText then popupText:set_color(Vector4.new(1, 1, 1, alpha)) end
end

function set_popup_alpha_Start(alpha)
    if popupBoss then popupBoss:set_color(Vector4.new(1, 1, 1, alpha)) end
    if popupNormal then popupNormal:set_color(Vector4.new(1, 1, 1, alpha)) end
    if popupText then popupText:set_color(Vector4.new(1, 1, 1, alpha)) end
end

-- Linear interpolation function
function lerp(a, b, t)
    return a + (b - a) * t
end
