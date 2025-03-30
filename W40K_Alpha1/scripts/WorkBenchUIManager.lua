local upgradeManager = nil

local gunBuyButton
local charBuyButton
local gunExitButton
local charExitButton
-- Perk button references
local gunPerk1Button, gunPerk2Button, gunPerk3Button, gunPerk4Button
-- Character perk button references
local charPerk1Button, charPerk2Button, charPerk3Button
-- Text components
local gunPerk1Text, gunPerk2Text, gunPerk3Text, gunPerk4Text
local charPerk1Text, charPerk2Text, charPerk3Text
local gunDescriptionText, gunBuyText, gunNameText
local charDescriptionText, charBuyText, charNameText


local gunExitText
local charExitText

-- Image components  
local gunScrapIcon, gunBackground
local charScrapIcon, charBackground

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
local isWorkBenchOpen = false
local currentScreen = "gun" -- "gun" or "character"

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

function on_ready()
    -- Initialize upgrade manager
    upgradeManager = current_scene:get_entity_by_name("UpgradeManager"):get_component("ScriptComponent")

    -- Initialize buttons from the scene
    gunBuyButton = current_scene:get_entity_by_name("GunBuyButton"):get_component("UIButtonComponent")
    charBuyButton = current_scene:get_entity_by_name("CharBuyButton"):get_component("UIButtonComponent")
    
    -- Initialize exit buttons for each screen
    gunExitButton = current_scene:get_entity_by_name("GunExitButton"):get_component("UIButtonComponent")
    charExitButton = current_scene:get_entity_by_name("CharExitButton"):get_component("UIButtonComponent")
    
    -- Initialize gun perk buttons
    gunPerk1Button = current_scene:get_entity_by_name("GunPerk1"):get_component("UIButtonComponent")
    gunPerk2Button = current_scene:get_entity_by_name("GunPerk2"):get_component("UIButtonComponent")
    gunPerk3Button = current_scene:get_entity_by_name("GunPerk3"):get_component("UIButtonComponent")
    gunPerk4Button = current_scene:get_entity_by_name("GunPerk4"):get_component("UIButtonComponent")
    
    -- Initialize character perk buttons
    charPerk1Button = current_scene:get_entity_by_name("CharPerk1"):get_component("UIButtonComponent")
    charPerk2Button = current_scene:get_entity_by_name("CharPerk2"):get_component("UIButtonComponent")
    charPerk3Button = current_scene:get_entity_by_name("CharPerk3"):get_component("UIButtonComponent")
    
    -- Initialize text components - Gun
    gunPerk1Text = current_scene:get_entity_by_name("GunPerk1TXT"):get_component("UITextComponent")
    gunPerk2Text = current_scene:get_entity_by_name("GunPerk2TXT"):get_component("UITextComponent")
    gunPerk3Text = current_scene:get_entity_by_name("GunPerk3TXT"):get_component("UITextComponent")
    gunPerk4Text = current_scene:get_entity_by_name("GunPerk4TXT"):get_component("UITextComponent")
    gunDescriptionText = current_scene:get_entity_by_name("GunDescriptionTXT"):get_component("UITextComponent")
    gunBuyText = current_scene:get_entity_by_name("GunBuyTXT"):get_component("UITextComponent")
    gunNameText = current_scene:get_entity_by_name("GunNameTXT"):get_component("UITextComponent")
    
    -- Initialize text components - Character
    charPerk1Text = current_scene:get_entity_by_name("CharPerk1TXT"):get_component("UITextComponent")
    charPerk2Text = current_scene:get_entity_by_name("CharPerk2TXT"):get_component("UITextComponent")
    charPerk3Text = current_scene:get_entity_by_name("CharPerk3TXT"):get_component("UITextComponent")
    charDescriptionText = current_scene:get_entity_by_name("CharDescriptionTXT"):get_component("UITextComponent")
    charBuyText = current_scene:get_entity_by_name("CharBuyTXT"):get_component("UITextComponent")
    charNameText = current_scene:get_entity_by_name("CharNameTXT"):get_component("UITextComponent")
    
    -- Initialize shared text components
    gunExitText = current_scene:get_entity_by_name("GunExitTXT"):get_component("UITextComponent")
    charExitText = current_scene:get_entity_by_name("CharExitTXT"):get_component("UITextComponent")
    currentScrapText = current_scene:get_entity_by_name("CurrentScrapTXT"):get_component("UITextComponent")
    
    -- Initialize image components
    gunScrapIcon = current_scene:get_entity_by_name("GunScrapIcon"):get_component("UIImageComponent")
    gunBackground = current_scene:get_entity_by_name("GunBackground"):get_component("UIImageComponent")
    charScrapIcon = current_scene:get_entity_by_name("CharScrapIcon"):get_component("UIImageComponent")
    charBackground = current_scene:get_entity_by_name("CharBackground"):get_component("UIImageComponent")

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
            gunBuyText:set_font_size(16)
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
            charBuyText:set_font_size(16)
            find_next_available_upgrade("armor")
        else
            charBuyText:set_text(tostring(cost))
        end
    end
end

function update_gun_perk_buttons()
    if upgradeManager then
        if upgradeManager.upgrades.weapons.reloadReduction then
            gunPerk1Button:set_state("Selected")
        else
            gunPerk1Button:set_state("Base")
        end
        
        if upgradeManager.upgrades.weapons.damageBoost then
            gunPerk2Button:set_state("Selected")
        else
            gunPerk2Button:set_state("Base")
        end
        
        if upgradeManager.upgrades.weapons.fireRateBoost then
            gunPerk3Button:set_state("Selected")
        else
            gunPerk3Button:set_state("Base")
        end
        
        if upgradeManager.upgrades.weapons.specialAbility then
            gunPerk4Button:set_state("Selected")
        else
            gunPerk4Button:set_state("Base")
        end
    end
end

function update_char_perk_buttons()
    if upgradeManager then
        if upgradeManager.upgrades.armor.healthBoost then
            charPerk1Button:set_state("Selected")
        else
            charPerk1Button:set_state("Base")
        end
        
        if upgradeManager.upgrades.armor.protection then
            charPerk2Button:set_state("Selected")
        else
            charPerk2Button:set_state("Base")
        end
        
        if upgradeManager.upgrades.armor.specialAbility then
            charPerk3Button:set_state("Selected")
        else
            charPerk3Button:set_state("Base")
        end
    end
end

function toggle_screen()
    if currentScreen == "gun" then
        -- Save current gun screen selection before switching
        gunIndex = gunIndex
        currentScreen = "character"
        show_character_ui()
        hide_gun_ui(false) -- false means don't hide shared elements
    else
        -- Save current character screen selection before switching
        charIndex = charIndex
        currentScreen = "gun"
        show_gun_ui()
        hide_character_ui(false) -- false means don't hide shared elements
    end
    
    update_ui()
end

function on_update(dt)
    if not isWorkBenchOpen then
        if Input.is_key_pressed(Input.keycode.U) then
            show_ui()
        end
        return
    end
    
    if Input.is_key_pressed(Input.keycode.I) then
        hide_ui()
    end
    
    local leftShoulderState = Input.get_button(Input.controllercode.LeftShoulder)
    local rightShoulderState = Input.get_button(Input.controllercode.RightShoulder)
    
    if (leftShoulderState == Input.state.Down and not leftShoulderPressed) or 
       (rightShoulderState == Input.state.Down and not rightShoulderPressed) then
        leftShoulderPressed = (leftShoulderState == Input.state.Down)
        rightShoulderPressed = (rightShoulderState == Input.state.Down)
        toggle_screen()
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
end

function handle_gun_controls(dt)
    if gunIndex == 0 then
        gunBuyButton:set_state("Selected")
        gunExitButton:set_state("Base")

        local confirmState = Input.get_button(Input.action.Confirm)
        if(confirmState == Input.state.Down and not confirmPressed) then
            confirmPressed = true
            gunBuyButton:set_state("Pressed")
            
            -- Buy the currently selected upgrade
            local currentUpgrade = upgradeTypes.weapons[currentUpgradeIndex.weapons + 1]
            if currentUpgrade then
                local success = upgradeManager.buy_upgrade("weapons", currentUpgrade)
                
                if success then
                    --print("Purchased upgrade: " .. currentUpgrade)
                    find_next_available_upgrade("weapons")
                    update_ui()
                end
            else
                --print("Error: Invalid upgrade index")
            end
        elseif confirmState ~= Input.state.Down then
            confirmPressed = false
        end
    else
        gunBuyButton:set_state("Base")
        gunExitButton:set_state("Selected")

        local confirmState = Input.get_button(Input.action.Confirm)
        if(confirmState == Input.state.Down and not confirmPressed) then
            confirmPressed = true
            gunExitButton:set_state("Pressed")
            --print("Gun Exit button pressed!")
            hide_ui()
        elseif confirmState ~= Input.state.Down then
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
        charBuyButton:set_state("Selected")
        charExitButton:set_state("Base")

        local confirmState = Input.get_button(Input.action.Confirm)
        if(confirmState == Input.state.Down and not confirmPressed) then
            confirmPressed = true
            charBuyButton:set_state("Pressed")
            
            -- Buy the currently selected upgrade
            local currentUpgrade = upgradeTypes.armor[currentUpgradeIndex.armor + 1]
            if currentUpgrade then
                local success = upgradeManager.buy_upgrade("armor", currentUpgrade)
                
                if success then
                    --print("Purchased character upgrade: " .. currentUpgrade)
                    find_next_available_upgrade("armor")
                    update_ui()
                end
            else
                --print("Error: Invalid character upgrade index")
            end
        elseif confirmState ~= Input.state.Down then
            confirmPressed = false
        end
    else
        charBuyButton:set_state("Base")
        charExitButton:set_state("Selected")

        local confirmState = Input.get_button(Input.action.Confirm)
        if(confirmState == Input.state.Down and not confirmPressed) then
            confirmPressed = true
            charExitButton:set_state("Pressed")
            --print("Character Exit button pressed!")
            hide_ui()
        elseif confirmState ~= Input.state.Down then
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
    currentScrapText:set_visible(true)
    
    if currentScreen == "gun" then
        show_gun_ui()
    else
        show_character_ui()
    end
    
    find_next_available_upgrade("weapons")
    find_next_available_upgrade("armor")
    update_ui()
    
    isWorkBenchOpen = true
end

function show_gun_ui()
    -- Show gun UI elements
    gunBuyButton:set_visible(true)
    gunExitButton:set_visible(true)
    gunExitText:set_visible(true)
    gunPerk1Button:set_visible(true)
    gunPerk2Button:set_visible(true)
    gunPerk3Button:set_visible(true)
    gunPerk4Button:set_visible(true)
    gunPerk1Text:set_visible(true)
    gunPerk2Text:set_visible(true)
    gunPerk3Text:set_visible(true)
    gunPerk4Text:set_visible(true)
    gunDescriptionText:set_visible(true)
    gunBuyText:set_visible(true)
    gunNameText:set_visible(true)
    gunScrapIcon:set_visible(true)
    gunBackground:set_visible(true)
end

function show_character_ui()
    -- Show character UI elements
    charBuyButton:set_visible(true)
    charExitButton:set_visible(true)
    charExitText:set_visible(true)
    charPerk1Button:set_visible(true)
    charPerk2Button:set_visible(true)
    charPerk3Button:set_visible(true)
    charPerk1Text:set_visible(true)
    charPerk2Text:set_visible(true)
    charPerk3Text:set_visible(true)
    charDescriptionText:set_visible(true)
    charBuyText:set_visible(true)
    charNameText:set_visible(true)
    charScrapIcon:set_visible(true)
    charBackground:set_visible(true)
end

function hide_ui()
    hide_gun_ui(true) 
    hide_character_ui(true)
    isWorkBenchOpen = false
end

function hide_gun_ui(hideShared)
    -- Hide gun UI elements
    gunBuyButton:set_visible(false)
    gunExitButton:set_visible(false)
    gunExitText:set_visible(false)
    gunPerk1Button:set_visible(false)
    gunPerk2Button:set_visible(false)
    gunPerk3Button:set_visible(false)
    gunPerk4Button:set_visible(false)
    gunPerk1Text:set_visible(false)
    gunPerk2Text:set_visible(false)
    gunPerk3Text:set_visible(false)
    gunPerk4Text:set_visible(false)
    gunDescriptionText:set_visible(false)
    gunBuyText:set_visible(false)
    gunNameText:set_visible(false)
    gunScrapIcon:set_visible(false)
    gunBackground:set_visible(false)
    
    -- Hide shared elements if required
    if hideShared then
        currentScrapText:set_visible(false)
    end
end

function hide_character_ui(hideShared)
    -- Hide character UI elements
    charBuyButton:set_visible(false)
    charExitButton:set_visible(false)
    charExitText:set_visible(false)
    charPerk1Button:set_visible(false)
    charPerk2Button:set_visible(false)
    charPerk3Button:set_visible(false)
    charPerk1Text:set_visible(false)
    charPerk2Text:set_visible(false)
    charPerk3Text:set_visible(false)
    charDescriptionText:set_visible(false)
    charBuyText:set_visible(false)
    charNameText:set_visible(false)
    charScrapIcon:set_visible(false)
    charBackground:set_visible(false)
    
    -- Hide shared elements if required
    if hideShared then
        currentScrapText:set_visible(false)
    end
end

function is_workbench_open()
    return isWorkBenchOpen
end

function on_exit()
    -- Add cleanup code here
end
