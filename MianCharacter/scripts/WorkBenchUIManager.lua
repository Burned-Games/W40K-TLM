local upgradeManager = nil

local gunBuyButton
local exitButton
-- Perk button references
local gunPerk1Button, gunPerk2Button, gunPerk3Button, gunPerk4Button
-- Text components
local gunPerk1Text, gunPerk2Text, gunPerk3Text, gunPerk4Text
local gunDescriptionText, gunBuyText, gunNameText
-- Image components  
local gunScrapIcon, gunBackground, characterBackground

local index = 0
local buttonCooldown = 0
local buttonCooldownTime = 0.1
local contadorMovimientoBotones = 0


-- Current category and upgrade
local selectedCategory = "weapons"  -- We're using the weapons category
local upgradeTypes = {"reloadReduction", "damageBoost", "fireRateBoost", "specialAbility"}
local currentUpgradeIndex = 0  -- Index of the current upgrade being offered

function on_ready()
    -- Initialize upgrade manager
    upgradeManager = current_scene:get_entity_by_name("UpgradeManager"):get_component("ScriptComponent")

    -- Initialize buttons from the scene
    gunBuyButton = current_scene:get_entity_by_name("GunBuyButton"):get_component("UIButtonComponent")
    exitButton = current_scene:get_entity_by_name("ExitButton"):get_component("UIButtonComponent")
    
    -- Initialize perk buttons
    gunPerk1Button = current_scene:get_entity_by_name("GunPerk1"):get_component("UIButtonComponent")
    gunPerk2Button = current_scene:get_entity_by_name("GunPerk2"):get_component("UIButtonComponent")
    gunPerk3Button = current_scene:get_entity_by_name("GunPerk3"):get_component("UIButtonComponent")
    gunPerk4Button = current_scene:get_entity_by_name("GunPerk4"):get_component("UIButtonComponent")
    
    -- Initialize text components
    gunPerk1Text = current_scene:get_entity_by_name("GunPerk1TXT"):get_component("UITextComponent")
    gunPerk2Text = current_scene:get_entity_by_name("GunPerk2TXT"):get_component("UITextComponent")
    gunPerk3Text = current_scene:get_entity_by_name("GunPerk3TXT"):get_component("UITextComponent")
    gunPerk4Text = current_scene:get_entity_by_name("GunPerk4TXT"):get_component("UITextComponent")
    gunDescriptionText = current_scene:get_entity_by_name("GunDescriptionTXT"):get_component("UITextComponent")
    gunBuyText = current_scene:get_entity_by_name("GunBuyTXT"):get_component("UITextComponent")
    gunNameText = current_scene:get_entity_by_name("GunNameTXT"):get_component("UITextComponent")
    
    -- Initialize image components
    gunScrapIcon = current_scene:get_entity_by_name("GunScrapIcon"):get_component("UIImageComponent")
    gunBackground = current_scene:get_entity_by_name("GunBackground"):get_component("UIImageComponent")
    characterBackground = current_scene:get_entity_by_name("CharacterBackground"):get_component("UIImageComponent")
    gunBuyButton:set_visible(false)


    -- -- Find the first available upgrade)
    -- find_next_available_upgrade()
    
    -- -- Update the UI to show the current upgrade
    -- update_ui()
end

function find_next_available_upgrade()
    -- Find the next unpurchased upgrade
    for i, upgradeName in ipairs(upgradeTypes) do
        if not upgradeManager.upgrades.weapons[upgradeName] then
            currentUpgradeIndex = i - 1  -- Arrays in Lua are 1-indexed, but we use 0-indexed
            return true
        end
    end
    return false
end

function update_ui()
    -- Update perk buttons to show which perks are purchased
    update_perk_buttons()
    
    -- Update the text for the current upgrade
    local currentUpgrade = upgradeTypes[currentUpgradeIndex + 1]
    
    if upgradeManager then
        -- Update name and description
        gunNameText:set_text(upgradeManager.upgradeNames.weapons[currentUpgrade])
        gunDescriptionText:set_text(upgradeManager.upgradeDescriptions.weapons[currentUpgrade])
        
        -- Update buy button text with cost
        local cost = upgradeManager.costs.weapons[currentUpgrade]
        gunBuyText:set_text(tostring(cost))
        
        -- Check if the player has enough scrap to purchase
        local canBuy = not upgradeManager.upgrades.weapons[currentUpgrade] and 
                       upgradeManager.scrap >= cost
                       
        -- Set button state based on whether player can buy
        if canBuy then
            --gunBuyButton:set_visible(true)
        else
            -- If all upgrades are purchased or not enough scrap, show appropriate message
            if upgradeManager.upgrades.weapons[currentUpgrade] then
                gunBuyText:set_text("PURCHASED")
                --gunBuyButton:set_visible(false)
                
                -- Find next upgrade if available
                find_next_available_upgrade()
            else
                gunBuyText:set_text("NEED " .. cost .. " SCRAP")
                --gunBuyButton:set_visible(true)
            end
        end
    end
end

function update_perk_buttons()
    -- Update perk buttons based on purchase status
    if upgradeManager then
        -- Set button states based on purchase status
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

function on_update(dt)
    if Input.is_key_pressed(Input.keycode.U) then
        show_ui()
    end
    if Input.is_key_pressed(Input.keycode.I) then
        hide_ui()
    end
    -- Handle button selection and actions
    if index == 0 then
        gunBuyButton:set_state("Selected")
        exitButton:set_state("Base")

        value = Input.get_button(Input.action.Confirm)
        if(value == Input.state.Down or Input.is_key_pressed(Input.keycode.K)) then
            if(index == 0) then
                gunBuyButton:set_state("Pressed")
                
                -- Buy the currently selected upgrade
                local currentUpgrade = upgradeTypes[currentUpgradeIndex + 1]
                if currentUpgrade then
                    -- Fix: Call buy_upgrade with dot notation instead of colon notation
                    local success = upgradeManager.buy_upgrade("weapons", currentUpgrade)
                    
                    if success then
                        -- Play purchase sound or effect here
                        print("Purchased upgrade: " .. currentUpgrade)
                        
                        -- Find and select the next available upgrade
                        find_next_available_upgrade()
                        
                        -- Update UI to reflect changes
                        update_ui()
                    end
                else
                    print("Error: Invalid upgrade index")
                end
            end
        end
    else
        gunBuyButton:set_state("Base")
        exitButton:set_state("Selected")

        value = Input.get_button(Input.action.Confirm)
        if(value == Input.state.Down or Input.is_key_pressed(Input.keycode.K)) then
            if(index == 1) then
                exitButton:set_state("Pressed")
                print("Exit button pressed!")
                -- Exit workbench logic here
            end
        end
    end

    -- Handle navigation between buttons
    local value = Input.get_axis(Input.action.UiMoveVertical)
    if (value ~= 0 and contadorMovimientoBotones > 0.2) then
        contadorMovimientoBotones = 0
        
        if value < 0 then
            index = index - 1;
            if index < 0 then
                index = 1
            end
        end
        
        if value > 0 then
            index = index + 1
            if index > 1 then
                index = 0
            end
        end
    else
        contadorMovimientoBotones = contadorMovimientoBotones + dt
    end
end

function show_ui()
    -- Show all UI elements
    -- gunBuyButton:set_visible(true)
    -- exitButton:set_visible(true)
    -- gunPerk1Button:set_visible(true)
    -- gunPerk2Button:set_visible(true)
    -- gunPerk3Button:set_visible(true)
    -- gunPerk4Button:set_visible(true)
    gunPerk1Text:set_visible(true)
    gunPerk2Text:set_visible(true)
    gunPerk3Text:set_visible(true)
    gunPerk4Text:set_visible(true)
    gunDescriptionText:set_visible(true)
    gunBuyText:set_visible(true)
    gunNameText:set_visible(true)
    gunScrapIcon:set_visible(true)
    gunBackground:set_visible(true)
    characterBackground:set_visible(true)
    find_next_available_upgrade()
    update_ui()

end

function hide_ui()
    -- Hide all UI elements
    -- gunBuyButton:set_visible(false)
    -- exitButton:set_visible(false)
    -- gunPerk1Button:set_visible(false)
    -- gunPerk2Button:set_visible(false)
    -- gunPerk3Button:set_visible(false)
    -- gunPerk4Button:set_visible(false)
    gunPerk1Text:set_visible(false)
    gunPerk2Text:set_visible(false)
    gunPerk3Text:set_visible(false)
    gunPerk4Text:set_visible(false)
    gunDescriptionText:set_visible(false)
    gunBuyText:set_visible(false)
    gunNameText:set_visible(false)
    gunScrapIcon:set_visible(false)
    gunBackground:set_visible(false)
    characterBackground:set_visible(false)
end

function on_exit()
    -- Add cleanup code here
end
