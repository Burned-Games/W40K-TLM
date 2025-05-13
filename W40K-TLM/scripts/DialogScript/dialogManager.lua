-- dialogSystem.lua



-- UI Components
local nameComponent = nil
local textComponent = nil
local dialogImgComponent = nil

-- Dialog state control
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
local autoNextEnabled = true
local autoNextTimer = 0
local autoNextDelay = 3.0
local waitingForNext = false
local isTyping = false
local spacePressedLastFrame = false

-- Animation control
local dialogAnimationTime = 0.0
local dialogAnimationDuration = 0.5
local dialogCurrentAlpha = 0.0
local dialogAnimating = false
local dialogOpening = true
local waitingDialogStart = false
local dialogStartQueued = false

-- Audio control
local currentAudio = nil

-- Initialization
function on_ready()
    nameComponent = current_scene:get_entity_by_name("DialogName"):get_component("UITextComponent")
    textComponent = current_scene:get_entity_by_name("DialogText"):get_component("UITextComponent")
    dialogImgComponent = current_scene:get_entity_by_name("DialogIMG"):get_component("UIImageComponent")

    dialogImgComponent:set_color(Vector4.new(1, 1, 1, 0))
    nameComponent:set_text(" ")
    textComponent:set_text(" ")
end

-- Per-frame update
function on_update(dt)
    update_dialog_animation(dt)

    if not isDialogPlaying then return end

    local spacePressedNow = Input.get_button(Input.action.Cancel) == Input.state.Down
    local spacePressed = spacePressedNow and not spacePressedLastFrame
    spacePressedLastFrame = spacePressedNow

    if spacePressed then
        if isTyping then
            textComponent:set_text(insert_line_breaks(fullText, 45))
            textIndex = #fullText + 1
            isTyping = false
            waitingForNext = true
            autoNextTimer = 0

            if currentAudio then
                currentAudio:pause()
                currentAudio = nil
            end  

        elseif waitingForNext then
            if currentAudio then
                currentAudio:pause()
                currentAudio = nil
            end

            waitingForNext = false
            autoNextTimer = 0
            nextDialogLine()
        end
        return
    end

    if waitingForNext and autoNextEnabled then
        autoNextTimer = autoNextTimer + dt
        if autoNextTimer >= autoNextDelay then
            -- Stop current audio when auto-advancing
            if currentAudio then
                currentAudio:pause()
                currentAudio = nil
            end

            waitingForNext = false
            autoNextTimer = 0
            nextDialogLine()
        end
        return
    end

    if isTyping then
        timer = timer + dt
        if timer >= typeSpeed and textIndex <= #fullText then
            local char = fullText:sub(textIndex, textIndex)
            visibleText = visibleText .. char
            textComponent:set_text(insert_line_breaks(visibleText, 45))
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

function start_dialog(lines)
    dialogQueue = lines
    currentDialogIndex = 1
    isDialogPlaying = false
    waitingDialogStart = true
    dialogStartQueued = true
    start_dialog_open_animation()
end

function start_dialog_open_animation()
    dialogAnimationTime = 0.0
    dialogAnimating = true
    dialogOpening = true
    dialogCurrentAlpha = 0.0
end

function start_dialog_close_animation()
    dialogAnimationTime = 0.0
    dialogAnimating = true
    dialogOpening = false
    dialogCurrentAlpha = 1.0
end

function update_dialog_animation(dt)
    if not dialogAnimating then return end

    dialogAnimationTime = dialogAnimationTime + dt
    local t = dialogAnimationTime / dialogAnimationDuration

    if dialogOpening then
        dialogCurrentAlpha = lerp(0, 1, t)
    else
        dialogCurrentAlpha = lerp(1, 0, t)
    end

    dialogImgComponent:set_color(Vector4.new(1, 1, 1, dialogCurrentAlpha))
    nameComponent:set_color(Vector4.new(1, 1, 1, dialogCurrentAlpha))
    textComponent:set_color(Vector4.new(1, 1, 1, dialogCurrentAlpha))

    if t >= 1 then
        dialogAnimating = false
        if dialogOpening then
            if waitingDialogStart and dialogStartQueued then
                waitingDialogStart = false
                dialogStartQueued = false
                isDialogPlaying = true
                play_current_line()
            end
        else
            dialogImgComponent:set_color(Vector4.new(1, 1, 1, 0))
            nameComponent:set_color(Vector4.new(1, 1, 1, 0))
            textComponent:set_color(Vector4.new(1, 1, 1, 0))
            isDialogPlaying = false
        end
    end
end

function play_current_line()
    local line = dialogQueue[currentDialogIndex]
    if not line then
        end_dialog()
        return
    end

    if currentAudio then
        currentAudio:pause()
        currentAudio = nil
    end

    fullText = line.text or " "
    visibleText = " "
    textIndex = 1
    timer = 0
    waitingForNext = false
    autoNextTimer = 0
    isTyping = true

    nameComponent:set_text(line.name or " ")
    textComponent:set_text(" ")

    if line.audio then
        currentAudio = line.audio
        currentAudio:play()
    end
end

function nextDialogLine()
    currentDialogIndex = currentDialogIndex + 1
    if currentDialogIndex > #dialogQueue then
        end_dialog()
    else
        play_current_line()
    end
end

function end_dialog()
    if currentAudio then
        currentAudio:pause()
        currentAudio = nil
    end
    start_dialog_close_animation()
end

function lerp(a, b, t)
    return a + (b - a) * math.min(math.max(t, 0), 1)
end

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

function changeAutoTime(time)
    autoNextDelay = time
end
