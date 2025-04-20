-- dialogSystem.lua

dialogLines = {
    { name = "Carlos", text = "Hola, bienvenido al mundo" },
    { name = "Ana", text = "Espero que estés preparado para la aventura." },
    { name = "Carlos", text = "Vamos allá" }
}

-- UI Components
local nameComponent = nil
local textComponent = nil

-- Dialog data
local dialogQueue = {}
local currentDialogIndex = 1
local isDialogPlaying = false

-- Typing animation state
local fullText = ""
local visibleText = ""
local textIndex = 1
local typeSpeed = 0.04
local timer = 0

-- Auto-next control
local autoNextEnabled = true        --  Set to false to disable auto-next
local autoNextTimer = 0
local autoNextDelay = 3.0
local waitingForNext = false
local isTyping = false
local spacePressedLastFrame = false

-- DialogUI
local dialogImgComponent = nil

-- Animation config
local dialogAnimationTime = 0.0
local dialogAnimationDuration = 0.3 -- seconds
local dialogMaxWidth = 600
local dialogHeight = 100
local dialogAnimating = false
local dialogOpening = true -- true = opening, false = closing
-- Control when to start dialog after opening
local waitingDialogStart = false
local dialogStartQueued = false


-- Initialization
function on_ready()
    nameComponent = current_scene:get_entity_by_name("DialogName"):get_component("UITextComponent")
    textComponent = current_scene:get_entity_by_name("DialogText"):get_component("UITextComponent")
    dialogImgComponent = current_scene:get_entity_by_name("DialogIMG"):get_component("UIImageComponent")
    -- Clear text at start
    --if nameComponent then nameComponent:set_text("") end
    --if textComponent then textComponent:set_text("") end
end

-- Update per frame
function on_update(dt)

    if Input.is_key_pressed(Input.keycode.M) then
        start_dialog(dialogLines)
    end

    if Input.is_key_pressed(Input.keycode.N) then
        start_dialog_close_animation()
    end

    update_dialog_open_animation(dt)

    

    if not isDialogPlaying then return end

    -- Space key press (once per press)
    local spacePressedNow = Input.is_key_pressed(Input.keycode.Space)
    local spacePressed = spacePressedNow and not spacePressedLastFrame
    spacePressedLastFrame = spacePressedNow

    if spacePressed then
        if isTyping then
            -- If still typing, skip to full text immediately
            visibleText = fullText
            textComponent:set_text(insert_line_breaks(visibleText, 28))
            textIndex = #fullText + 1
            isTyping = false
            waitingForNext = true
            autoNextTimer = 0
        elseif waitingForNext then
            -- If typing finished, go to next line
            waitingForNext = false
            autoNextTimer = 0
            nextDialogLine()
        end
        return
    end

    -- Waiting for auto-next
    if waitingForNext then
        if autoNextEnabled then
            autoNextTimer = autoNextTimer + dt
            if autoNextTimer >= autoNextDelay then
                waitingForNext = false
                autoNextTimer = 0
                nextDialogLine()
            end
        end
        return
    end

    -- Typing animation
    if isTyping then
        timer = timer + dt
        if timer >= typeSpeed and textIndex <= #fullText then
            local char = fullText:sub(textIndex, textIndex)
            visibleText = visibleText .. char
            textComponent:set_text(insert_line_breaks(visibleText, 28))
            textIndex = textIndex + 1
            timer = 0

            if textIndex > #fullText then
                isTyping = false
                waitingForNext = true
                autoNextTimer = 0
            end
        end
    end
end

-- Start new dialog (pass in a table)
function start_dialog(lines)
    dialogQueue = lines
    currentDialogIndex = 1
    isDialogPlaying = false  -- don't start typing yet
    waitingDialogStart = true
    dialogStartQueued = true
    start_dialog_open_animation()
end
-- call this when you want to open the dialog background
function start_dialog_open_animation()
    dialogAnimationTime = 0.0
    dialogAnimating = true
    dialogOpening = true
end
-- Call when you want to close dialog
function start_dialog_close_animation()
    dialogAnimationTime = 0.0
    dialogAnimating = true
    dialogOpening = false
end

function easeOutBack(t)
    local c1 = 1.70158
    local c3 = c1 + 1
    return 1 + c3 * (t - 1)^3 + c1 * (t - 1)^2
end
-- Replace the original update_dialog_open_animation with this:
function update_dialog_open_animation(dt)
    if not dialogAnimating then return end

    dialogAnimationTime = dialogAnimationTime + dt
    local t = dialogAnimationTime / dialogAnimationDuration
    if t >= 1 then
        dialogAnimating = false
        if waitingDialogStart and dialogStartQueued then
            waitingDialogStart = false
            dialogStartQueued = false
            isDialogPlaying = true
            play_current_line()
        end
    end

    local currentWidth = 0
    if dialogOpening then
        currentWidth = easeOutBack(t) * dialogMaxWidth
    else
        -- Close uses regular lerp for smooth shrinking
        currentWidth = lerp(dialogMaxWidth, 0, t)
    end

    dialogImgComponent:set_size(Vector2.new(currentWidth, -dialogHeight))

    if t >= 1 then
        dialogAnimating = false
        if not dialogOpening then
            -- Ensure it's fully closed at the end
            dialogImgComponent:set_size(Vector2.new(0, -dialogHeight))
        end
    
        -- Start dialog if we were waiting for open to finish
        if waitingDialogStart and dialogStartQueued then
            waitingDialogStart = false
            dialogStartQueued = false
            isDialogPlaying = true
            play_current_line()
        end
    end    
end
-- Play current line
function play_current_line()
    local line = dialogQueue[currentDialogIndex]
    if line == nil then
        end_dialog()
        return
    end

    fullText = line.text or ""
    visibleText = ""
    textIndex = 1
    timer = 0
    waitingForNext = false
    autoNextTimer = 0
    isTyping = true  --  Mark as typing

    if nameComponent then
        nameComponent:set_text(line.name or "")
    end

    if textComponent then
        textComponent:set_text("")
    end
end

-- Go to next line
function nextDialogLine()
    currentDialogIndex = currentDialogIndex + 1
    if currentDialogIndex > #dialogQueue then
        end_dialog()
    else
        play_current_line()
    end
end

-- End dialog
function end_dialog()
    isDialogPlaying = false
    if nameComponent then nameComponent:set_text("") end
    if textComponent then textComponent:set_text("") end
    start_dialog_close_animation()
end

-- Word wrap
function insert_line_breaks(text, max_chars_per_line)
    local result = {}
    local current_line = ""
    local current_length = 0

    for word in text:gmatch("%S+") do
        local word_length = utf8_char_count(word)

        if current_length + word_length > max_chars_per_line then
            table.insert(result, current_line)
            current_line = word
            current_length = word_length
        else
            if current_line ~= "" then
                current_line = current_line .. " " .. word
                current_length = current_length + 1 + word_length
            else
                current_line = word
                current_length = word_length
            end
        end
    end

    if current_line ~= "" then
        table.insert(result, current_line)
    end

    return table.concat(result, "\n")
end

function utf8_char_count(s)
    local _, count = s:gsub("[^\128-\191]", "")
    return count
end

function lerp(a, b, t)
    return a + (b - a) * t
end