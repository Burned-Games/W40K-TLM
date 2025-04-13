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

-- Initialization
function on_ready()
    nameComponent = current_scene:get_entity_by_name("DialogName"):get_component("UITextComponent")
    textComponent = current_scene:get_entity_by_name("DialogText"):get_component("UITextComponent")

    -- Clear text at start
    if nameComponent then nameComponent:set_text("") end
    if textComponent then textComponent:set_text("") end
end

-- Update per frame
function on_update(dt)

    if Input.is_key_pressed(Input.keycode.M) then
        start_dialog(dialogLines)
    end

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
    isDialogPlaying = true
    play_current_line()
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
