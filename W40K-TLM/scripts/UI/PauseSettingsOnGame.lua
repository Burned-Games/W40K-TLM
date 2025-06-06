
local button1, button2, button3, button4, FullScreenButton
local slider1, slider2
local text1, text2
local VolumeText, FXText, PauseText, SettingsBaseText
local visibilidad1Entity, visibilidad2Entity, visibilidad3Entity
local visibilidadtotal, chatarraUI


isPaused = false
local isOnPauseSettings = false
local isOnControls = false
local sceneChanged = false


local mainMenuIndex = 0
local settingsIndex = 1
local inputCooldown = 0
local buttonCooldown = 0
local contadorMovimientoBotones = 0


local settingsSFX, indexHoverSFX, indexSelectionSFX
local musicVolume = 0.0
local fxVolume = 0.0


local workbenchUIManagerScript, fadeToBlackScript


local COOLDOWN_TIME = 0.15
local BUTTON_COOLDOWN_TIME = 0.2
local CANCEL_DELAY = 0.2


local selectedColor = Vector4.new(130/255, 19/255, 7/255, 1.0)
local defaultColor = Vector4.new(1.0, 1.0, 1.0, 1.0)


local cancelTimer = 0
local cancelTriggered = false


local MenuState = {
    MAIN_MENU = 1,
    SETTINGS = 2,
    CONTROLS = 3
}

local currentMenuState = MenuState.MAIN_MENU
local lastSelectedIndex = 0

function on_ready()
    initialize_ui_components()
    initialize_audio_components()
    initialize_scripts()
    load_saved_settings()
    setup_initial_state()
end

function initialize_ui_components()
    
    button1 = current_scene:get_entity_by_name("Continue"):get_component("UIButtonComponent")
    button2 = current_scene:get_entity_by_name("SettingsButton"):get_component("UIButtonComponent")
    button3 = current_scene:get_entity_by_name("Controls"):get_component("UIButtonComponent")
    button4 = current_scene:get_entity_by_name("Exit"):get_component("UIButtonComponent")
    FullScreenButton = current_scene:get_entity_by_name("FullScreen"):get_component("UIButtonComponent")

    
    slider1 = current_scene:get_entity_by_name("Volume"):get_component("UISliderComponent")
    slider2 = current_scene:get_entity_by_name("FX"):get_component("UISliderComponent")

   
    text1 = current_scene:get_entity_by_name("VolumeText"):get_component("UITextComponent")
    text2 = current_scene:get_entity_by_name("FXText"):get_component("UITextComponent")
    VolumeText = current_scene:get_entity_by_name("VolumeText"):get_component("UITextComponent")
    FXText = current_scene:get_entity_by_name("FXText"):get_component("UITextComponent")
    PauseText = current_scene:get_entity_by_name("PauseText"):get_component("UITextComponent")
    SettingsBaseText = current_scene:get_entity_by_name("SettingsText"):get_component("UITextComponent")

    
    visibilidad1Entity = current_scene:get_entity_by_name("Pause")
    visibilidad2Entity = current_scene:get_entity_by_name("Settings")
    visibilidad3Entity = current_scene:get_entity_by_name("ControlsBase")
    visibilidadtotal = current_scene:get_entity_by_name("PauseBase")
    chatarraUI = current_scene:get_entity_by_name("ChatarraUI")
end

function initialize_audio_components()
    settingsSFX = current_scene:get_entity_by_name("SettingsSFX"):get_component("AudioSourceComponent")
    indexHoverSFX = current_scene:get_entity_by_name("HoverButtonSFX"):get_component("AudioSourceComponent")
    indexSelectionSFX = current_scene:get_entity_by_name("PressButtonSFX"):get_component("AudioSourceComponent")
end

function initialize_scripts()
    workbenchUIManagerScript = current_scene:get_entity_by_name("WorkBenchUIManager"):get_component("ScriptComponent")
    fadeToBlackScript = current_scene:get_entity_by_name("FadeToBlack"):get_component("ScriptComponent")
end

function load_saved_settings()
    local savedVolumeGeneral = load_progress("musicVolumeGeneral", 50.0) / 100
    local savedFXVolume = load_progress("fxVolume", 50.0) / 100
    
    slider1.value = savedVolumeGeneral
    slider2.value = savedFXVolume
    
    set_music_volume(savedVolumeGeneral)
    set_sfx_volume(savedFXVolume)
end

function setup_initial_state()
    local currentMode = App.get_window_mode()
    update_fullscreen_button_state(currentMode == WindowMode.Fullscreen)
    
    visibilidad1Entity:set_active(false)
    visibilidad2Entity:set_active(false)
    visibilidad3Entity:set_active(false)
    
    update_settings_visual_selection()
end

function on_update(dt)
    update_cooldowns(dt)
    handle_pause_input()
    
    if isPaused then
        if currentMenuState == MenuState.MAIN_MENU then
            handle_main_menu_input(dt)
        elseif currentMenuState == MenuState.SETTINGS then
            handle_settings_input(dt)
        elseif currentMenuState == MenuState.CONTROLS then
            handle_controls_input(dt)
        end
    end
    
    handle_cancel_input()
    update_cancel_timer(dt)
    update_main_menu_buttons()
    play_hover_sound()
end

function update_cooldowns(dt)
    if inputCooldown > 0 then
        inputCooldown = inputCooldown - dt
    end
    
    if buttonCooldown > 0 then
        buttonCooldown = buttonCooldown - dt
    end
    
    contadorMovimientoBotones = contadorMovimientoBotones + dt
end

function handle_pause_input()
    local value = Input.get_button(Input.action.Pause)
    if value == Input.state.Down then
        toggle_pause()
        indexSelectionSFX:play()
    end
end

function toggle_pause()
    if isPaused then
        close_pause_menu()
    else
        open_pause_menu()
    end
end

function open_pause_menu()
    isPaused = true
    currentMenuState = MenuState.MAIN_MENU
    visibilidad1Entity:set_active(true)
    chatarraUI:set_active(false)
    
    if workbenchUIManagerScript.isWorkBenchOpen == true then
        workbenchUIManagerScript:hide_ui()
    end
end

function close_pause_menu()
    isPaused = false
    currentMenuState = MenuState.MAIN_MENU
    visibilidad1Entity:set_active(false)
    visibilidad2Entity:set_active(false)
    visibilidad3Entity:set_active(false)
    chatarraUI:set_active(true)
    isOnPauseSettings = false
    isOnControls = false
end

function handle_main_menu_input(dt)
    handle_main_menu_navigation(dt)
    handle_main_menu_confirm()
end

function handle_main_menu_navigation(dt)
    if contadorMovimientoBotones < BUTTON_COOLDOWN_TIME then
        return
    end
    
    local value = Input.get_axis(Input.action.UiMoveVertical)
    if value ~= 0 then
        contadorMovimientoBotones = 0
        
        if value < 0 then
            mainMenuIndex = mainMenuIndex - 1
            if mainMenuIndex < 0 then
                mainMenuIndex = 3
            end
        elseif value > 0 then
            mainMenuIndex = mainMenuIndex + 1
            if mainMenuIndex > 3 then
                mainMenuIndex = 0
            end
        end
    end
end

function handle_main_menu_confirm()
    local value = Input.get_button(Input.action.Confirm)
    if value == Input.state.Down then
        indexSelectionSFX:play()
        
        if mainMenuIndex == 0 then
            close_pause_menu()
        elseif mainMenuIndex == 1 then
            open_controls_menu()
        elseif mainMenuIndex == 2 then
            open_settings_menu()
        elseif mainMenuIndex == 3 then
            exit_to_main_menu()
        end
    end
end

function open_controls_menu()
    currentMenuState = MenuState.CONTROLS
    visibilidad3Entity:set_active(true)
    isOnControls = true
    sceneChanged = true
end

function open_settings_menu()
    currentMenuState = MenuState.SETTINGS
    visibilidad2Entity:set_active(true)
    isOnPauseSettings = true
    sceneChanged = true
    inputCooldown = COOLDOWN_TIME
end

function exit_to_main_menu()
    save_progress("skipIntroDelay", true)
    fadeToBlackScript:DoFade()
    SceneManager.change_scene("scenes/mainMenu.TeaScene")
end

function handle_settings_input(dt)
    if inputCooldown > 0 then
        return
    end
    
    handle_settings_navigation()
    handle_settings_horizontal_input()
    handle_settings_confirm()
end

function handle_settings_navigation()
    local verticalInput = Input.get_axis(Input.action.UiMoveVertical)
    if math.abs(verticalInput) > 0.5 then
        if verticalInput > 0 then
            settingsIndex = settingsIndex + 1
            if settingsIndex > 3 then
                settingsIndex = 1
            end
        else
            settingsIndex = settingsIndex - 1
            if settingsIndex < 1 then
                settingsIndex = 3
            end
        end
        
        update_settings_visual_selection()
        inputCooldown = COOLDOWN_TIME
    end
end

function handle_settings_horizontal_input()
    local horizontalInput = Input.get_axis(Input.action.UiMoveHorizontal)
    if math.abs(horizontalInput) > 0.5 and settingsIndex <= 2 then
        local selectedSlider = (settingsIndex == 1) and slider1 or slider2
        local currentValue = selectedSlider.value
        
        local newValue = currentValue + (horizontalInput * 0.10)
        newValue = math.max(0.0, math.min(1.0, newValue))
        selectedSlider.value = newValue
        
        if settingsIndex == 1 then
            set_music_volume(newValue)
            save_progress("musicVolumeGeneral", newValue * 100)
        else
            set_sfx_volume(newValue)
            save_progress("fxVolume", newValue * 100)
            if newValue ~= 1.0 then
                settingsSFX:play()
            end
        end
        
        inputCooldown = COOLDOWN_TIME
    end
end

function handle_settings_confirm()
    if settingsIndex == 3 then
        local value = Input.get_button(Input.action.Confirm)
        if value == Input.state.Down then
            toggle_fullscreen()
            inputCooldown = COOLDOWN_TIME
        end
    end
end

function handle_controls_input(dt)
    
end

function handle_cancel_input()
    local value = Input.get_button(Input.action.Cancel)
    if value == Input.state.Down then
        if currentMenuState == MenuState.SETTINGS then
            close_settings_menu()
        elseif currentMenuState == MenuState.CONTROLS then
            close_controls_menu()
        else
            start_cancel_sequence()
        end
    end
end

function close_settings_menu()
    visibilidad2Entity:set_active(false)
    currentMenuState = MenuState.MAIN_MENU
    isOnPauseSettings = false
end

function close_controls_menu()
    visibilidad3Entity:set_active(false)
    currentMenuState = MenuState.MAIN_MENU
    isOnControls = false
end

function start_cancel_sequence()
    sceneChanged = true
    visibilidad1Entity:set_active(false)
    visibilidad2Entity:set_active(false)
    visibilidad3Entity:set_active(false)
    chatarraUI:set_active(true)
    
    cancelTimer = 0
    cancelTriggered = true
end

function update_cancel_timer(dt)
    if cancelTriggered then
        cancelTimer = cancelTimer + dt
        if cancelTimer >= CANCEL_DELAY then
            isPaused = false
            cancelTriggered = false
            cancelTimer = 0
        end
    end
end

function update_main_menu_buttons()
    if currentMenuState ~= MenuState.MAIN_MENU then
        return
    end
    
    
    button1.state = State.Normal
    button2.state = State.Normal
    button3.state = State.Normal
    button4.state = State.Normal
    
    
    if mainMenuIndex == 0 then
        button1.state = State.Hover
    elseif mainMenuIndex == 1 then
        button3.state = State.Hover
    elseif mainMenuIndex == 2 then
        button2.state = State.Hover
    elseif mainMenuIndex == 3 then
        button4.state = State.Hover
    end
end

function play_hover_sound()
    if mainMenuIndex ~= lastSelectedIndex then
        indexHoverSFX:play()
        lastSelectedIndex = mainMenuIndex
    end
end

function toggle_fullscreen()
    local currentMode = App.get_window_mode()
    
    if currentMode == WindowMode.Fullscreen then
        App.set_window_mode(WindowMode.Windowed)
        update_fullscreen_button_state(false)
    else
        App.set_window_mode(WindowMode.Fullscreen)
        update_fullscreen_button_state(true)
    end
    
    update_settings_visual_selection()
end

function update_fullscreen_button_state(isFullscreen)
    if isFullscreen then
        FullScreenButton.state = State.Pressed
    else
        FullScreenButton.state = State.Normal
    end
end

function update_settings_visual_selection()
    slider1.selected = false
    slider2.selected = false
    
    local isFullscreen = (App.get_window_mode() == WindowMode.Fullscreen)
    
    if settingsIndex == 1 then
        slider1.selected = true
        update_fullscreen_button_state(isFullscreen)
    elseif settingsIndex == 2 then
        slider2.selected = true
        update_fullscreen_button_state(isFullscreen)
    elseif settingsIndex == 3 then
        FullScreenButton.state = State.Hover
    else
        update_fullscreen_button_state(isFullscreen)
    end
end

function hide_pause()
    
end

function on_exit()
    
end