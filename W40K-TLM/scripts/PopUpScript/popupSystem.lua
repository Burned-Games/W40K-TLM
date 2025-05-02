-- UI components
local popupNormal = nil
local popupBoss = nil
local popupText = nil

-- Animation state
local popupIsActive = false
local popupTimer = 0.0
local popupState = "idle" -- "enter", "hold", "exit"
local popupDuration = 2.0
local popupSpeed = 4.0

-- Popup visuals
local useBossImage = false
local actualAlpha = 0

-- Popup queue
local popupQueue = {}

-- Persistent popup data
local persistentPopup = nil
local isPersistentActive = false


local popupTimer = 0
local popupShouldRemove = false

-- Initialization
function on_ready()
    popupNormal = current_scene:get_entity_by_name("PopUpNewZoneIMG"):get_component("UIImageComponent")
    popupBoss = current_scene:get_entity_by_name("PopUpBossZoneIMG"):get_component("UIImageComponent")
    popupText = current_scene:get_entity_by_name("PopUpText"):get_component("UITextComponent")

    set_popup_alpha_Start(0)
end

-- Update per frame
function on_update(dt)
    if popupIsActive then
        update_popup(dt)
    end

    -- Example shortcut key test
    if Input.is_key_pressed(Input.keycode.R) then
        show_popup(false, "Normal area")
    end

    if Input.is_key_pressed(Input.keycode.T) then
        show_popup(false, "Defeat enemies 0/2", true) -- Persistent popup example
    end

    if Input.is_key_pressed(Input.keycode.Y) then
        remove_persistent_popup() -- Stop persistent popup
    end


    update_popup_timer(dt)
end

-- Show popup: isPersistent optional parameter (default false)
function show_popup(isBoss, message, isPersistent)
    if isPersistent then
        persistentPopup = { isBoss = isBoss, message = message }

        -- If currently playing, add to queue instead of playing immediately
        if popupIsActive then
            table.insert(popupQueue, { isBoss = isBoss, message = message, isPersistent = true })
        else
            isPersistentActive = true
            start_popup(isBoss, message)
        end
        return
    end

    -- Normal popup added to queue
    if popupIsActive or isPersistentActive then
        table.insert(popupQueue, { isBoss = isBoss, message = message })
        return
    end

    -- Otherwise, play immediately
    start_popup(isBoss, message)
end

function update_persistent_popup_text(newText)
    if isPersistentActive and persistentPopup then
        if popupText then
            popupText:set_text(newText or " ")
        end
    end
end


-- Start popup (used for internal calls)
function start_popup(isBoss, message)
    popupIsActive = true
    popupState = "enter"
    popupTimer = 0.0
    useBossImage = isBoss
    actualAlpha = 0

    if popupText then
        popupText:set_text(message or " ")
    end
end

-- Manually remove persistent popup
function remove_persistent_popup()
    -- Trigger exit animation (do not cancel immediately)
    isPersistentActive = false
    popupState = "exit"
    popupTimer = 0.0
end


function start_popup_removal_timer()
    popupTimer = 0
    popupShouldRemove = true
end

function update_popup_timer(dt)
    if popupShouldRemove then
        popupTimer = popupTimer + dt
        if popupTimer >= 1.0 then
            popupShouldRemove = false
            popupTimer = 0
            remove_persistent_popup()
        end
    end
end

-- Control popup animation state machine
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
        if isPersistentActive and persistentPopup then
            -- Persistent popup: Keep displaying, do not exit
            return
        end
    
        -- Normal popup: Countdown until exit
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
    
            -- Play next popup in queue
            if #popupQueue > 0 then
                local nextPopup = table.remove(popupQueue, 1)
    
                if nextPopup.isPersistent then
                    persistentPopup = nextPopup
                    isPersistentActive = true
                end
    
                start_popup(nextPopup.isBoss, nextPopup.message)
            end
        end
    end    
end

-- Set transparency
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

-- Linear interpolation
function lerp(a, b, t)
    return a + (b - a) * t
end
