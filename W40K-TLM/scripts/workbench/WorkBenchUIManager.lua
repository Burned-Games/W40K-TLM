local upgradeManager = nil
local hud = nil
local pauseMenu = nil

local gunBuyButtonEntity, gunBuyButton
local charBuyButtonEntity, charBuyButton
local gunExitButtonEntity, gunExitButton
local charExitButtonEntity, charExitButton
-- Perk button references
local gunPerk1ButtonEntity, gunPerk1Button
local gunPerk2ButtonEntity, gunPerk2Button
local gunPerk3ButtonEntity, gunPerk3Button
local gunPerk4ButtonEntity, gunPerk4Button
-- Character perk button references
local charPerk1ButtonEntity, charPerk1Button
local charPerk2ButtonEntity, charPerk2Button
local charPerk3ButtonEntity, charPerk3Button
-- Text components
local gunPerk1TextEntity, gunPerk1Text
local gunPerk2TextEntity, gunPerk2Text
local gunPerk3TextEntity, gunPerk3Text
local gunPerk4TextEntity, gunPerk4Text
local charPerk1TextEntity, charPerk1Text
local charPerk2TextEntity, charPerk2Text
local charPerk3TextEntity, charPerk3Text
local gunDescriptionTextEntity, gunDescriptionText
local gunBuyTextEntity, gunBuyText
local gunNameTextEntity, gunNameText
local charDescriptionTextEntity, charDescriptionText
local charBuyTextEntity, charBuyText
local charNameTextEntity, charNameText

local gunExitTextEntity, gunExitText
local charExitTextEntity, charExitText

-- Image components  
local gunScrapIconEntity, gunScrapIcon
local gunBackgroundEntity, gunBackground
local charScrapIconEntity, charScrapIcon
local charBackgroundEntity, charBackground

-- Indexes for each screen
local gunIndex = 0
local charIndex = 0
local buttonCooldown = 0
local buttonCooldownTime = 0.1
local contadorMovimientoBotones = 0

-- Button press tracking to prevent spamming
local confirmPressed = false
local leftShoulderPressed = false
local rightShoulderPressed = false

-- Workbench state
isWorkBenchOpen = false
local currentScreen = "gun" -- "gun" or "character"

-- Cooldown timer for opening the workbench :p
local openCooldownTimer = 0
local openCooldownDuration = 0.2

-- Current category and upgrade
local selectedCategory = "weapons"
local upgradeTypes = {
    weapons = {"reloadReduction", "damageBoost", "fireRateBoost", "specialAbility"},
    armor = {"healthBoost", "protection", "specialAbility"}
}
local currentUpgradeIndex = {
    weapons = 0,
    armor = 0
}

local BUTTON_STATES = {
    NORMAL = 0,
    HOVER = 1,
    PRESSED = 2
}

function on_ready()
    -- Initialize upgrade manager
    upgradeManager = current_scene:get_entity_by_name("UpgradeManager"):get_component("ScriptComponent")
    
    -- Initialize HUD
    hud = current_scene:get_entity_by_name("HUD")
    
    -- Initialize pause menu
    pauseMenu = current_scene:get_entity_by_name("PauseBase"):get_component("ScriptComponent")

    -- Initialize buttons from the scene
    gunBuyButtonEntity = current_scene:get_entity_by_name("GunBuyButton")
    gunBuyButton = gunBuyButtonEntity:get_component("UIButtonComponent")
    charBuyButtonEntity = current_scene:get_entity_by_name("CharBuyButton")
    charBuyButton = charBuyButtonEntity:get_component("UIButtonComponent")
    
    -- Initialize exit buttons for each screen
    gunExitButtonEntity = current_scene:get_entity_by_name("GunExitButton")
    gunExitButton = gunExitButtonEntity:get_component("UIButtonComponent")
    charExitButtonEntity = current_scene:get_entity_by_name("CharExitButton")
    charExitButton = charExitButtonEntity:get_component("UIButtonComponent")
    
    -- Initialize gun perk buttons
    gunPerk1ButtonEntity = current_scene:get_entity_by_name("GunPerk1")
    gunPerk1Button = gunPerk1ButtonEntity:get_component("UIButtonComponent")
    gunPerk2ButtonEntity = current_scene:get_entity_by_name("GunPerk2")
    gunPerk2Button = gunPerk2ButtonEntity:get_component("UIButtonComponent")
    gunPerk3ButtonEntity = current_scene:get_entity_by_name("GunPerk3")
    gunPerk3Button = gunPerk3ButtonEntity:get_component("UIButtonComponent")
    gunPerk4ButtonEntity = current_scene:get_entity_by_name("GunPerk4")
    gunPerk4Button = gunPerk4ButtonEntity:get_component("UIButtonComponent")
    
    -- Initialize character perk buttons
    charPerk1ButtonEntity = current_scene:get_entity_by_name("CharPerk1")
    charPerk1Button = charPerk1ButtonEntity:get_component("UIButtonComponent")
    charPerk2ButtonEntity = current_scene:get_entity_by_name("CharPerk2")
    charPerk2Button = charPerk2ButtonEntity:get_component("UIButtonComponent")
    charPerk3ButtonEntity = current_scene:get_entity_by_name("CharPerk3")
    charPerk3Button = charPerk3ButtonEntity:get_component("UIButtonComponent")
    
    -- Initialize text components - Gun
    gunPerk1TextEntity = current_scene:get_entity_by_name("GunPerk1TXT")
    gunPerk1Text = gunPerk1TextEntity:get_component("UITextComponent")
    gunPerk2TextEntity = current_scene:get_entity_by_name("GunPerk2TXT")
    gunPerk2Text = gunPerk2TextEntity:get_component("UITextComponent")
    gunPerk3TextEntity = current_scene:get_entity_by_name("GunPerk3TXT")
    gunPerk3Text = gunPerk3TextEntity:get_component("UITextComponent")
    gunPerk4TextEntity = current_scene:get_entity_by_name("GunPerk4TXT")
    gunPerk4Text = gunPerk4TextEntity:get_component("UITextComponent")
    gunDescriptionTextEntity = current_scene:get_entity_by_name("GunDescriptionTXT")
    gunDescriptionText = gunDescriptionTextEntity:get_component("UITextComponent")
    gunBuyTextEntity = current_scene:get_entity_by_name("GunBuyTXT")
    gunBuyText = gunBuyTextEntity:get_component("UITextComponent")
    gunNameTextEntity = current_scene:get_entity_by_name("GunNameTXT")
    gunNameText = gunNameTextEntity:get_component("UITextComponent")
    
    -- Initialize text components - Character
    charPerk1TextEntity = current_scene:get_entity_by_name("CharPerk1TXT")
    charPerk1Text = charPerk1TextEntity:get_component("UITextComponent")
    charPerk2TextEntity = current_scene:get_entity_by_name("CharPerk2TXT")
    charPerk2Text = charPerk2TextEntity:get_component("UITextComponent")
    charPerk3TextEntity = current_scene:get_entity_by_name("CharPerk3TXT")
    charPerk3Text = charPerk3TextEntity:get_component("UITextComponent")
    charDescriptionTextEntity = current_scene:get_entity_by_name("CharDescriptionTXT")
    charDescriptionText = charDescriptionTextEntity:get_component("UITextComponent")
    charBuyTextEntity = current_scene:get_entity_by_name("CharBuyTXT")
    charBuyText = charBuyTextEntity:get_component("UITextComponent")
    charNameTextEntity = current_scene:get_entity_by_name("CharNameTXT")
    charNameText = charNameTextEntity:get_component("UITextComponent")
    
    -- Initialize shared text components
    gunExitTextEntity = current_scene:get_entity_by_name("GunExitTXT")
    gunExitText = gunExitTextEntity:get_component("UITextComponent")
    charExitTextEntity = current_scene:get_entity_by_name("CharExitTXT")
    charExitText = charExitTextEntity:get_component("UITextComponent")
    currentScrapTextEntity = current_scene:get_entity_by_name("CurrentScrapTXT")
    currentScrapText = currentScrapTextEntity:get_component("UITextComponent")
    
    -- Initialize image components
    gunScrapIconEntity = current_scene:get_entity_by_name("GunScrapIcon")
    gunScrapIcon = gunScrapIconEntity:get_component("UIImageComponent")
    gunBackgroundEntity = current_scene:get_entity_by_name("GunBackground")
    gunBackground = gunBackgroundEntity:get_component("UIImageComponent")
    charScrapIconEntity = current_scene:get_entity_by_name("CharScrapIcon")
    charScrapIcon = charScrapIconEntity:get_component("UIImageComponent")
    charBackgroundEntity = current_scene:get_entity_by_name("CharBackground")
    charBackground = charBackgroundEntity:get_component("UIImageComponent")
    
    hide_ui()
end

function find_next_available_upgrade(category)
    for i, upgradeName in ipairs(upgradeTypes[category]) do
        if not upgradeManager.upgrades[category][upgradeName] then
            currentUpgradeIndex[category] = i - 1
            return true
        end
    end
    return false
end

function update_ui()
    if currentScreen == "gun" then
        update_gun_ui()
    else
        update_char_ui()
    end
    
    if upgradeManager then
        currentScrapText:set_text(tostring(upgradeManager.scrap))
    end
end

function update_gun_ui()
    update_gun_perk_buttons()
    
    local currentUpgrade = upgradeTypes.weapons[currentUpgradeIndex.weapons + 1]
    
    if upgradeManager then
        -- Update name and description
        gunNameText:set_text(upgradeManager.upgradeNames.weapons[currentUpgrade])
        gunDescriptionText:set_text(upgradeManager.upgradeDescriptions.weapons[currentUpgrade])
        
        -- Update buy button text with cost
        local cost = upgradeManager.costs.weapons[currentUpgrade]
        gunBuyText:set_text(tostring(cost))
        
        -- Check player enough scrap to purchase
        local canBuy = not upgradeManager.upgrades.weapons[currentUpgrade] and 
                       upgradeManager.scrap >= cost
                       

        -- Set button state 
        if upgradeManager.upgrades.weapons[currentUpgrade] then
            gunBuyText:set_text("PURCHASED")
            find_next_available_upgrade("weapons")
        else
            gunBuyText:set_text(tostring(cost))
        end
    end
end

function update_char_ui()
    update_char_perk_buttons()
    
    -- Update the text for the current upgrade
    local currentUpgrade = upgradeTypes.armor[currentUpgradeIndex.armor + 1]
    
    if upgradeManager then
        -- Update name and description
        charNameText:set_text(upgradeManager.upgradeNames.armor[currentUpgrade])
        charDescriptionText:set_text(upgradeManager.upgradeDescriptions.armor[currentUpgrade])
        
        -- Update buy button text with cost
        local cost = upgradeManager.costs.armor[currentUpgrade]
        charBuyText:set_text(tostring(cost))
        
        -- Check player enough scrap to purchase
        local canBuy = not upgradeManager.upgrades.armor[currentUpgrade] and 
                       upgradeManager.scrap >= cost
                       

        -- Set button state 
        if upgradeManager.upgrades.armor[currentUpgrade] then
            charBuyText:set_text("PURCHASED")
            find_next_available_upgrade("armor")
        else
            charBuyText:set_text(tostring(cost))
        end
    end
end

function update_gun_perk_buttons()
    if upgradeManager then
        if upgradeManager.upgrades.weapons.reloadReduction then
            gunPerk1Button.state = 1
        else
            gunPerk1Button.state = 0
        end
        
        if upgradeManager.upgrades.weapons.damageBoost then
            gunPerk2Button.state = 1
        else
            gunPerk2Button.state = 0
        end
        
        if upgradeManager.upgrades.weapons.fireRateBoost then
            gunPerk3Button.state = 1
        else
            gunPerk3Button.state = 0
        end
        
        if upgradeManager.upgrades.weapons.specialAbility then
            gunPerk4Button.state = 1
        else
            gunPerk4Button.state = 0
        end
    end
end

function update_char_perk_buttons()
    if upgradeManager then
        if upgradeManager.upgrades.armor.healthBoost then
            charPerk1Button.state = 1
        else
            charPerk1Button.state = 0
        end
        
        if upgradeManager.upgrades.armor.protection then
            charPerk2Button.state = 1
        else
            charPerk2Button.state = 0
        end
        
        if upgradeManager.upgrades.armor.specialAbility then
            charPerk3Button.state = 1
        else
            charPerk3Button.state = 0
        end
    end
end

function toggle_screen()
    if currentScreen == "gun" then
        gunIndex = gunIndex
        currentScreen = "character"
        show_character_ui()
        hide_gun_ui(false) -- false means don't hide shared elements
    else
        charIndex = charIndex
        currentScreen = "gun"
        show_gun_ui()
        hide_character_ui(false) -- false means don't hide shared elements
    end
    
    update_ui()
end

function on_update(dt)
    -- if not isWorkBenchOpen then
    --     if Input.is_key_pressed(Input.keycode.U) then
    --         show_ui()
    --     end
    --     return
    -- end
    
    -- if Input.is_key_pressed(Input.keycode.I) then
    --     hide_ui()
    -- end

    if isWorkBenchOpen or pauseMenu.isPaused then
        hud:set_active(false)
    else
        hud:set_active(true)
    end

    if not isWorkBenchOpen then
        return
    end
    
    -- Timer for opening the workbench (fix for input bug)
    if openCooldownTimer < openCooldownDuration then
        openCooldownTimer = openCooldownTimer + dt
        return
    end
    
    local leftShoulderState = Input.get_button(Input.action.Skill2)
    local rightShoulderState = Input.get_button(Input.action.Melee)
    
    if (leftShoulderState == Input.state.Down and not leftShoulderPressed) or 
       (rightShoulderState == Input.state.Down and not rightShoulderPressed)  then
        leftShoulderPressed = (leftShoulderState == Input.state.Down)
        rightShoulderPressed = (rightShoulderState == Input.state.Down)
        
        if isWorkBenchOpen then
            toggle_screen()
        end
    else
        if leftShoulderState ~= Input.state.Down then
            leftShoulderPressed = false
        end
        if rightShoulderState ~= Input.state.Down then
            rightShoulderPressed = false
        end
    end
    
    -- Handle button selection and actions based on current screen
    if currentScreen == "gun" then
        handle_gun_controls(dt)
    else
        handle_character_controls(dt)
    end


    local cancelState = Input.get_button(Input.action.Confirm)
    if cancelState == Input.state.Down and isWorkBenchOpen then
        hide_ui()
    end
end

function handle_gun_controls(dt)
    if gunIndex == 0 then
        gunBuyButton.state = 1
        gunExitButton.state = 0

        local confirmState = Input.get_button(Input.action.Cancel)

        if confirmState == Input.state.Repeat and not confirmPressed then
            confirmPressed = true
            gunBuyButton.state = 2
            
            -- Buy the currently selected upgrade
            local currentUpgrade = upgradeTypes.weapons[currentUpgradeIndex.weapons + 1]
            if currentUpgrade then
                local success = upgradeManager.buy_upgrade("weapons", currentUpgrade)
                
                if success then
                    find_next_available_upgrade("weapons")
                    update_ui()
                end
            end
        elseif confirmState ~= Input.state.Repeat then
            confirmPressed = false
        end
    else
        gunBuyButton.state = 0
        gunExitButton.state = 1

        local confirmState = Input.get_button(Input.action.Cancel)
        if(confirmState == Input.state.Repeat and not confirmPressed) then
            confirmPressed = true
            gunExitButton.state = 2
            hide_ui()
        elseif confirmState ~= Input.state.Repeat then
            confirmPressed = false
        end
    end
    
    -- Handle navigation for gun screen
    local value = Input.get_axis(Input.action.UiMoveVertical)
    if (value ~= 0 and contadorMovimientoBotones > 0.2) then
        contadorMovimientoBotones = 0
        
        if value < 0 then
            gunIndex = gunIndex - 1
            if gunIndex < 0 then
                gunIndex = 1
            end
        end
        
        if value > 0 then
            gunIndex = gunIndex + 1
            if gunIndex > 1 then
                gunIndex = 0
            end
        end
    else
        contadorMovimientoBotones = contadorMovimientoBotones + dt
    end
end

function handle_character_controls(dt)
    if charIndex == 0 then
        charBuyButton.state = 1
        charExitButton.state = 0

        local confirmState = Input.get_button(Input.action.Cancel)
        if(confirmState == Input.state.Repeat and not confirmPressed) then
            confirmPressed = true
            charBuyButton.state = 2
            
            -- Buy the currently selected upgrade
            local currentUpgrade = upgradeTypes.armor[currentUpgradeIndex.armor + 1]
            if currentUpgrade then
                local success = upgradeManager.buy_upgrade("armor", currentUpgrade)
                
                if success then
                    find_next_available_upgrade("armor")
                    update_ui()
                end
            end
        elseif confirmState ~= Input.state.Repeat then
            confirmPressed = false
        end
    else
        charBuyButton.state = 0
        charExitButton.state = 1

        local confirmState = Input.get_button(Input.action.Cancel)
        if(confirmState == Input.state.Repeat and not confirmPressed) then
            confirmPressed = true
            charExitButton.state = 2
            hide_ui()
        elseif confirmState ~= Input.state.Repeat then
            confirmPressed = false
        end
    end
    
    -- Handle navigation for character screen
    local value = Input.get_axis(Input.action.UiMoveVertical)
    if (value ~= 0 and contadorMovimientoBotones > 0.2) then
        contadorMovimientoBotones = 0
        
        if value < 0 then
            charIndex = charIndex - 1
            if charIndex < 0 then
                charIndex = 1
            end
        end
        
        if value > 0 then
            charIndex = charIndex + 1
            if charIndex > 1 then
                charIndex = 0
            end
        end
    else
        contadorMovimientoBotones = contadorMovimientoBotones + dt
    end
end

function show_ui()
    currentScrapTextEntity:set_active(true)
    
    if currentScreen == "gun" then
        show_gun_ui()
    else
        show_character_ui()
    end
    
    find_next_available_upgrade("weapons")
    find_next_available_upgrade("armor")
    update_ui()
    
    isWorkBenchOpen = true
    openCooldownTimer = 0
end

function show_gun_ui()
    -- Show gun UI elements
    gunBuyButtonEntity:set_active(true)
    gunExitButtonEntity:set_active(true)
    gunExitTextEntity:set_active(true)
    gunPerk1ButtonEntity:set_active(true)
    gunPerk2ButtonEntity:set_active(true)
    gunPerk3ButtonEntity:set_active(true)
    gunPerk4ButtonEntity:set_active(true)
    gunPerk1TextEntity:set_active(true)
    gunPerk2TextEntity:set_active(true)
    gunPerk3TextEntity:set_active(true)
    gunPerk4TextEntity:set_active(true)
    gunDescriptionTextEntity:set_active(true)
    gunBuyTextEntity:set_active(true)
    gunNameTextEntity:set_active(true)
    gunScrapIconEntity:set_active(true)
    gunBackgroundEntity:set_active(true)
end

function show_character_ui()
    -- Show character UI elements
    charBuyButtonEntity:set_active(true)
    charExitButtonEntity:set_active(true)
    charExitTextEntity:set_active(true)
    charPerk1ButtonEntity:set_active(true)
    charPerk2ButtonEntity:set_active(true)
    charPerk3ButtonEntity:set_active(true)
    charPerk1TextEntity:set_active(true)
    charPerk2TextEntity:set_active(true)
    charPerk3TextEntity:set_active(true)
    charDescriptionTextEntity:set_active(true)
    charBuyTextEntity:set_active(true)
    charNameTextEntity:set_active(true)
    charScrapIconEntity:set_active(true)
    charBackgroundEntity:set_active(true)
end

function hide_ui()
    hide_gun_ui(true) 
    hide_character_ui(true)
    isWorkBenchOpen = false
end

function hide_gun_ui(hideShared)
    -- Hide gun UI elements
    gunBuyButtonEntity:set_active(false)
    gunExitButtonEntity:set_active(false)
    gunExitTextEntity:set_active(false)
    gunPerk1ButtonEntity:set_active(false)
    gunPerk2ButtonEntity:set_active(false)
    gunPerk3ButtonEntity:set_active(false)
    gunPerk4ButtonEntity:set_active(false)
    gunPerk1TextEntity:set_active(false)
    gunPerk2TextEntity:set_active(false)
    gunPerk3TextEntity:set_active(false)
    gunPerk4TextEntity:set_active(false)
    gunDescriptionTextEntity:set_active(false)
    gunBuyTextEntity:set_active(false)
    gunNameTextEntity:set_active(false)
    gunScrapIconEntity:set_active(false)
    gunBackgroundEntity:set_active(false)
    
    -- Hide shared elements if required
    if hideShared then
        currentScrapTextEntity:set_active(false)
    end
end

function hide_character_ui(hideShared)
    -- Hide character UI elements
    charBuyButtonEntity:set_active(false)
    charExitButtonEntity:set_active(false)
    charExitTextEntity:set_active(false)
    charPerk1ButtonEntity:set_active(false)
    charPerk2ButtonEntity:set_active(false)
    charPerk3ButtonEntity:set_active(false)
    charPerk1TextEntity:set_active(false)
    charPerk2TextEntity:set_active(false)
    charPerk3TextEntity:set_active(false)
    charDescriptionTextEntity:set_active(false)
    charBuyTextEntity:set_active(false)
    charNameTextEntity:set_active(false)
    charScrapIconEntity:set_active(false)
    charBackgroundEntity:set_active(false)
    
    -- Hide shared elements if required
    if hideShared then
        currentScrapTextEntity:set_active(false)
    end
end

function is_workbench_open()
    return isWorkBenchOpen
end

function on_exit()
    -- Add cleanup code here
end
