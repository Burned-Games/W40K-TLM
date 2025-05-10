local upgradeManager = nil
local hud = nil
local missionManager = nil
local dialogManager = nil
local popUpManager = nil
local pauseMenu = nil

-- Shared UI elements (General)
local gBackgroundEntity, gBackground
local gDot1ButtonEntity, gDot1Button
local gDot2ButtonEntity, gDot2Button
local gScrapTxtEntity, gScrapTxt

-- Weapon UI elements
local wNameTxtEntity, wNameTxt
local wDescTxtEntity, wDescTxt
local wTitleTxtEntity, wTitleTxt
local wCostTxtEntity, wCostTxt
local wBuyTxtEntity, wBuyTxt
local wScrapIconEntity, wScrapIcon
local wRenderEntity, wRender
local wUpgradesBackgroundEntity, wUpgradesBackground
-- Weapon upgrade indicators
local wIEntity, wI
local wIIEntity, wII
local wIIIEntity, wIII
local wIVEntity, wIV
local wIBoughtEntity, wIBought
local wIIBoughtEntity, wIIBought
local wIIIBoughtEntity, wIIIBought
local wIVBoughtEntity, wIVBought
-- Weapon selection buttons
local wISelButtonEntity, wISelButton
local wIISelButtonEntity, wIISelButton
local wIIISelButtonEntity, wIIISelButton
local wIVSelButtonEntity, wIVSelButton
local wUpgradeSelButtonEntity, wUpgradeSelButton

-- Armor UI elements
local aNameTxtEntity, aNameTxt
local aDescTxtEntity, aDescTxt
local aTitleTxtEntity, aTitleTxt
local aCostTxtEntity, aCostTxt
local aBuyTxtEntity, aBuyTxt
local aScrapIconEntity, aScrapIcon
local aRenderEntity, aRender
local aUpgradesBackgroundEntity, aUpgradesBackground
-- Armor upgrade indicators
local aIEntity, aI
local aIIEntity, aII
local aIIIEntity, aIII
local aIBoughtEntity, aIBought
local aIIBoughtEntity, aIIBought
local aIIIBoughtEntity, aIIIBought
-- Armor selection buttons
local aISelButtonEntity, aISelButton
local aIISelButtonEntity, aIISelButton
local aIIISelButtonEntity, aIIISelButton
local aUpgradeSelButtonEntity, aUpgradeSelButton

-- Indexes for each screen
local weaponIndex = 0  -- 0 for upgrade select, 1-4 for individual upgrades
local armorIndex = 0   -- 0 for upgrade select, 1-3 for individual upgrades
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

local playerScript = nil

function on_ready()
    -- Initialize upgrade manager
    upgradeManager = current_scene:get_entity_by_name("UpgradeManager"):get_component("ScriptComponent")
    
    -- Initialize HUD
    hud = current_scene:get_entity_by_name("HUD")
    
    missionManager = current_scene:get_entity_by_name("MisionManager")
    dialogManager = current_scene:get_entity_by_name("DialogManager")
    popUpManager = current_scene:get_entity_by_name("PopUpManager")

    -- Initialize pause menu
    pauseMenu = current_scene:get_entity_by_name("PauseBase"):get_component("ScriptComponent")

    playerScript = current_scene:get_entity_by_name("Player"):get_component("ScriptComponent")

    -- Get all workbench UI elements
    local workbenchUIEntity = current_scene:get_entity_by_name("WorkBenchUI2")
    if workbenchUIEntity then
        -- General UI elements
        gBackgroundEntity = current_scene:get_entity_by_name("GBackground")
        gBackground = gBackgroundEntity:get_component("UIButtonComponent")
        
        gDot1ButtonEntity = current_scene:get_entity_by_name("GDot1BUTTON")
        gDot1Button = gDot1ButtonEntity:get_component("UIButtonComponent")
        
        gDot2ButtonEntity = current_scene:get_entity_by_name("GDot2BUTTON")
        gDot2Button = gDot2ButtonEntity:get_component("UIButtonComponent")
        
        gScrapTxtEntity = current_scene:get_entity_by_name("GScrapTXT")
        gScrapTxt = gScrapTxtEntity:get_component("UITextComponent")
        
        -- Weapon UI elements
        wNameTxtEntity = current_scene:get_entity_by_name("WNameTXT")
        wNameTxt = wNameTxtEntity:get_component("UITextComponent")
        
        wDescTxtEntity = current_scene:get_entity_by_name("WDescTXT")
        wDescTxt = wDescTxtEntity:get_component("UITextComponent")
        
        wTitleTxtEntity = current_scene:get_entity_by_name("WTitleTXT")
        wTitleTxt = wTitleTxtEntity:get_component("UITextComponent")
        
        wCostTxtEntity = current_scene:get_entity_by_name("WCostTXT")
        wCostTxt = wCostTxtEntity:get_component("UITextComponent")
        
        wBuyTxtEntity = current_scene:get_entity_by_name("WBuyTXT")
        wBuyTxt = wBuyTxtEntity:get_component("UITextComponent")
        
        wScrapIconEntity = current_scene:get_entity_by_name("WScrapIcon")
        wScrapIcon = wScrapIconEntity:get_component("UIImageComponent")
        
        wRenderEntity = current_scene:get_entity_by_name("WRender")
        wRender = wRenderEntity:get_component("UIImageComponent")
        
        wUpgradesBackgroundEntity = current_scene:get_entity_by_name("WUpgradesBackground")
        wUpgradesBackground = wUpgradesBackgroundEntity:get_component("UIImageComponent")
        
        -- Weapon upgrade indicators
        wIEntity = current_scene:get_entity_by_name("WI")
        wI = wIEntity:get_component("UIImageComponent")
        
        wIIEntity = current_scene:get_entity_by_name("WII")
        wII = wIIEntity:get_component("UIImageComponent")
        
        wIIIEntity = current_scene:get_entity_by_name("WIII")
        wIII = wIIIEntity:get_component("UIImageComponent")
        
        wIVEntity = current_scene:get_entity_by_name("WIV")
        wIV = wIVEntity:get_component("UIImageComponent")
        
        wIBoughtEntity = current_scene:get_entity_by_name("WIBought")
        wIBought = wIBoughtEntity:get_component("UIImageComponent")
        
        wIIBoughtEntity = current_scene:get_entity_by_name("WIIBought")
        wIIBought = wIIBoughtEntity:get_component("UIImageComponent")
        
        wIIIBoughtEntity = current_scene:get_entity_by_name("WIIIBought")
        wIIIBought = wIIIBoughtEntity:get_component("UIImageComponent")
        
        wIVBoughtEntity = current_scene:get_entity_by_name("WIVBought")
        wIVBought = wIVBoughtEntity:get_component("UIImageComponent")
        
        -- Weapon selection buttons
        wISelButtonEntity = current_scene:get_entity_by_name("WISelBUTTON")
        wISelButton = wISelButtonEntity:get_component("UIButtonComponent")
        
        wIISelButtonEntity = current_scene:get_entity_by_name("WIISelBUTTON")
        wIISelButton = wIISelButtonEntity:get_component("UIButtonComponent")
        
        wIIISelButtonEntity = current_scene:get_entity_by_name("WIIISelBUTTON")
        wIIISelButton = wIIISelButtonEntity:get_component("UIButtonComponent")
        
        wIVSelButtonEntity = current_scene:get_entity_by_name("WIVSelBUTTON")
        wIVSelButton = wIVSelButtonEntity:get_component("UIButtonComponent")
        
        wUpgradeSelButtonEntity = current_scene:get_entity_by_name("WUpgradeSelBUTTON")
        wUpgradeSelButton = wUpgradeSelButtonEntity:get_component("UIButtonComponent")
        
        -- Armor UI elements
        aNameTxtEntity = current_scene:get_entity_by_name("ANameTXT")
        aNameTxt = aNameTxtEntity:get_component("UITextComponent")
        
        aDescTxtEntity = current_scene:get_entity_by_name("ADescTXT")
        aDescTxt = aDescTxtEntity:get_component("UITextComponent")
        
        aTitleTxtEntity = current_scene:get_entity_by_name("ATitleTXT")
        aTitleTxt = aTitleTxtEntity:get_component("UITextComponent")
        
        aCostTxtEntity = current_scene:get_entity_by_name("ACostTXT")
        aCostTxt = aCostTxtEntity:get_component("UITextComponent")
        
        aBuyTxtEntity = current_scene:get_entity_by_name("ABuyTXT")
        aBuyTxt = aBuyTxtEntity:get_component("UITextComponent")
        
        aScrapIconEntity = current_scene:get_entity_by_name("AScrapIcon")
        aScrapIcon = aScrapIconEntity:get_component("UIImageComponent")
        
        aRenderEntity = current_scene:get_entity_by_name("ARender")
        aRender = aRenderEntity:get_component("UIImageComponent")
        
        aUpgradesBackgroundEntity = current_scene:get_entity_by_name("AUpgradesBackground")
        aUpgradesBackground = aUpgradesBackgroundEntity:get_component("UIImageComponent")
        
        -- Armor upgrade indicators
        aIEntity = current_scene:get_entity_by_name("AI")
        aI = aIEntity:get_component("UIImageComponent")
        
        aIIEntity = current_scene:get_entity_by_name("AII")
        aII = aIIEntity:get_component("UIImageComponent")
        
        aIIIEntity = current_scene:get_entity_by_name("AIII")
        aIII = aIIIEntity:get_component("UIImageComponent")
        
        aIBoughtEntity = current_scene:get_entity_by_name("AIBought")
        aIBought = aIBoughtEntity:get_component("UIImageComponent")
        
        aIIBoughtEntity = current_scene:get_entity_by_name("AIIBought")
        aIIBought = aIIBoughtEntity:get_component("UIImageComponent")
        
        aIIIBoughtEntity = current_scene:get_entity_by_name("AIIIBought")
        aIIIBought = aIIIBoughtEntity:get_component("UIImageComponent")
        
        -- Armor selection buttons
        aISelButtonEntity = current_scene:get_entity_by_name("AISelBUTTON")
        aISelButton = aISelButtonEntity:get_component("UIButtonComponent")
        
        aIISelButtonEntity = current_scene:get_entity_by_name("AIISelBUTTON")
        aIISelButton = aIISelButtonEntity:get_component("UIButtonComponent")
        
        aIIISelButtonEntity = current_scene:get_entity_by_name("AIIISelBUTTON")
        aIIISelButton = aIIISelButtonEntity:get_component("UIButtonComponent")
        
        aUpgradeSelButtonEntity = current_scene:get_entity_by_name("AUpgradeSelBUTTON")
        aUpgradeSelButton = aUpgradeSelButtonEntity:get_component("UIButtonComponent")
    end

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

function is_next_available_upgrade(category, index)
    local upgradeName = upgradeTypes[category][index + 1]
    
    -- If this upgrade is already purchased, it's not available
    if upgradeManager.upgrades[category][upgradeName] then
        return false
    end
    
    -- For the first upgrade (index 0), it's available if not purchased
    if index == 0 then
        return true
    end
    
    -- For subsequent upgrades, check if all previous upgrades are purchased
    for i = 0, index - 1 do
        local prevUpgradeName = upgradeTypes[category][i + 1]
        if not upgradeManager.upgrades[category][prevUpgradeName] then
            return false -- A previous upgrade is not purchased
        end
    end
    
    return true -- All previous upgrades are purchased
end

function update_ui()
    if currentScreen == "gun" then
        update_gun_ui()
    else
        update_char_ui()
    end
    
    if upgradeManager then
        gScrapTxt:set_text(tostring(playerScript.scrapCounter))
    end
end

function update_gun_ui()
    update_gun_perk_buttons()
    
    local currentUpgrade = upgradeTypes.weapons[currentUpgradeIndex.weapons + 1]
    
    if upgradeManager then
        -- Update name and description
        wNameTxt:set_text(upgradeManager.upgradeNames.weapons[currentUpgrade])
        wDescTxt:set_text(upgradeManager.upgradeDescriptions.weapons[currentUpgrade])
        
        -- Update cost text (numeric cost)
        local cost = upgradeManager.costs.weapons[currentUpgrade]
        wCostTxt:set_text(tostring(cost))
        
        -- Determine if this upgrade is already purchased
        local isPurchased = upgradeManager.upgrades.weapons[currentUpgrade]
        
        -- Determine if this is the next available upgrade in the sequence
        local isNextAvailable = is_next_available_upgrade("weapons", currentUpgradeIndex.weapons)
        
        -- Update buy text based on status
        if isPurchased then
            wBuyTxt:set_text("Bought")
        elseif isNextAvailable then
            wBuyTxt:set_text("Upgrade")
        else
            wBuyTxt:set_text("Locked")
        end
    end
end

function update_char_ui()
    update_char_perk_buttons()
    
    -- Update the text for the current upgrade
    local currentUpgrade = upgradeTypes.armor[currentUpgradeIndex.armor + 1]
    
    if upgradeManager then
        -- Update name and description
        aNameTxt:set_text(upgradeManager.upgradeNames.armor[currentUpgrade])
        aDescTxt:set_text(upgradeManager.upgradeDescriptions.armor[currentUpgrade])
        
        -- Update cost text (numeric cost)
        local cost = upgradeManager.costs.armor[currentUpgrade]
        aCostTxt:set_text(tostring(cost))
        
        -- Determine if this upgrade is already purchased
        local isPurchased = upgradeManager.upgrades.armor[currentUpgrade]
        
        -- Determine if this is the next available upgrade in the sequence
        local isNextAvailable = is_next_available_upgrade("armor", currentUpgradeIndex.armor)
        
        -- Update buy text based on status
        if isPurchased then
            aBuyTxt:set_text("Bought")
        elseif isNextAvailable then
            aBuyTxt:set_text("Upgrade")
        else
            aBuyTxt:set_text("Locked")
        end
    end
end

function update_gun_perk_buttons()
    if upgradeManager then
        
        -- First upgrade (reload reduction)
        local upgrade1 = upgradeManager.upgrades.weapons.reloadReduction
        wIEntity:set_active(not upgrade1)
        wIBoughtEntity:set_active(upgrade1)
        wISelButtonEntity:set_active(true)
        
        -- Second upgrade (damage boost)
        local upgrade2 = upgradeManager.upgrades.weapons.damageBoost
        wIIEntity:set_active(not upgrade2)
        wIIBoughtEntity:set_active(upgrade2)
        wIISelButtonEntity:set_active(true)
        
        -- Third upgrade (fire rate boost)
        local upgrade3 = upgradeManager.upgrades.weapons.fireRateBoost
        wIIIEntity:set_active(not upgrade3)
        wIIIBoughtEntity:set_active(upgrade3)
        wIIISelButtonEntity:set_active(true)
        
        -- Fourth upgrade (special ability)
        local upgrade4 = upgradeManager.upgrades.weapons.specialAbility
        wIVEntity:set_active(not upgrade4)
        wIVBoughtEntity:set_active(upgrade4)
        wIVSelButtonEntity:set_active(true)
    end
end

function update_char_perk_buttons()
    if upgradeManager then
        
        -- First upgrade (health boost)
        local upgrade1 = upgradeManager.upgrades.armor.healthBoost
        aIEntity:set_active(not upgrade1)
        aIBoughtEntity:set_active(upgrade1)
        aISelButtonEntity:set_active(true)
        
        -- Second upgrade (protection)
        local upgrade2 = upgradeManager.upgrades.armor.protection
        aIIEntity:set_active(not upgrade2)
        aIIBoughtEntity:set_active(upgrade2)
        aIISelButtonEntity:set_active(true)
        
        -- Third upgrade (special ability)
        local upgrade3 = upgradeManager.upgrades.armor.specialAbility
        aIIIEntity:set_active(not upgrade3)
        aIIIBoughtEntity:set_active(upgrade3)
        aIIISelButtonEntity:set_active(true)
    end
end

function toggle_screen()
    if currentScreen == "gun" then
        weaponIndex = weaponIndex
        currentScreen = "character"
        show_character_ui()
        hide_gun_ui(false) -- false means don't hide shared elements
    else
        armorIndex = armorIndex
        currentScreen = "gun"
        show_gun_ui()
        hide_character_ui(false) -- false means don't hide shared elements
    end

    if currentScreen == "gun" then
        show_gun_ui()
        -- Set dot1 to hover and dot2 to normal
        if gDot1Button then gDot1Button.state = 1 end
        if gDot2Button then gDot2Button.state = 0 end
    else
        show_character_ui()
        -- Set dot1 to normal and dot2 to hover
        if gDot1Button then gDot1Button.state = 0 end
        if gDot2Button then gDot2Button.state = 1 end
    end
    
    update_ui()
end

function on_update(dt)
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


    local cancelState = Input.get_button(Input.action.Cancel)
    if cancelState == Input.state.Down and isWorkBenchOpen then
        hide_ui()
    end
end

function handle_gun_controls(dt)
    -- Reset button states
    wUpgradeSelButton.state = 0
    wISelButton.state = 0
    wIISelButton.state = 0
    wIIISelButton.state = 0
    wIVSelButton.state = 0
    
    -- Set active button based on current index
    if weaponIndex == 0 then
        wUpgradeSelButton.state = 1
    elseif weaponIndex == 1 then
        wISelButton.state = 1
    elseif weaponIndex == 2 then
        wIISelButton.state = 1
    elseif weaponIndex == 3 then
        wIIISelButton.state = 1
    elseif weaponIndex == 4 then
        wIVSelButton.state = 1
    end

    local confirmState = Input.get_button(Input.action.Confirm)
    if confirmState == Input.state.Repeat and not confirmPressed then
        confirmPressed = true
        
        -- Handle action based on selected index
        if weaponIndex == 0 then
            wUpgradeSelButton.state = 2
            -- Buy the currently selected upgrade
            local currentUpgrade = upgradeTypes.weapons[currentUpgradeIndex.weapons + 1]
            local isPreviousPurchased = upgradeTypes.weapons[currentUpgradeIndex.weapons]
            if isPreviousPurchased == nil then
                isPreviousPurchased = true
            end
            -- local upgradeManager.has_upgrade("weapons", isPreviousPurchased)
            -- print(currentUpgradeIndex.weapons)

            if currentUpgrade and upgradeManager.has_upgrade("weapons", isPreviousPurchased) then
                local success = upgradeManager.buy_upgrade("weapons", currentUpgrade)
                if success then
                    find_next_available_upgrade("weapons")
                    update_ui()
                end
            elseif currentUpgrade and isPreviousPurchased and currentUpgrade == "reloadReduction" then
                local success = upgradeManager.buy_upgrade("weapons", "reloadReduction")
                if success then
                    find_next_available_upgrade("weapons")
                    update_ui()
                end
            end
        elseif weaponIndex == 1 then
            wISelButton.state = 1  
             
            currentUpgradeIndex.weapons = 0
            update_ui()
            weaponIndex = 0
            wUpgradeSelButton.state = 1  
        elseif weaponIndex == 2 then
            wIISelButton.state = 1  
             
            currentUpgradeIndex.weapons = 1
            update_ui()
            weaponIndex = 0
            wUpgradeSelButton.state = 1  
        elseif weaponIndex == 3 then
            wIIISelButton.state = 1  
             
            currentUpgradeIndex.weapons = 2
            update_ui()
            weaponIndex = 0
            wUpgradeSelButton.state = 1  
        elseif weaponIndex == 4 then
            wIVSelButton.state = 1  
             
            currentUpgradeIndex.weapons = 3
            update_ui()
            weaponIndex = 0
            wUpgradeSelButton.state = 1  
        end
    elseif confirmState ~= Input.state.Repeat then
        confirmPressed = false
    end
      -- Handle vertical navigation
    local verticalValue = Input.get_axis(Input.action.UiMoveVertical)
    if (verticalValue ~= 0 and contadorMovimientoBotones > 0.05) then
        contadorMovimientoBotones = 0
        
        if verticalValue < 0 then  -- Down
            if weaponIndex == 0 then
                -- If currently on upgrade button, go to the first weapon upgrade button
                weaponIndex = 1
                
                currentUpgradeIndex.weapons = 0  -- First upgrade
                update_ui()
            else
                -- If on weapon upgrade buttons, go to main upgrade button
                weaponIndex = 0
            end
        elseif verticalValue > 0 then  -- Up
            if weaponIndex == 0 then
                -- If currently on upgrade button, go to the first weapon upgrade button
                weaponIndex = 1
                
                currentUpgradeIndex.weapons = 0  -- First upgrade
                update_ui()
            else
                -- If on weapon upgrade buttons, go to main upgrade button
                weaponIndex = 0
            end
        end
    end
      -- Handle horizontal navigation (only when on weapon upgrade buttons)
    local horizontalValue = Input.get_axis(Input.action.UiMoveHorizontal)
    if (horizontalValue ~= 0 and contadorMovimientoBotones > 0.05 and weaponIndex > 0) then
        contadorMovimientoBotones = 0
        
        if horizontalValue > 0 then  -- Right
            weaponIndex = weaponIndex + 1
            if weaponIndex > 4 then
                weaponIndex = 1  -- Loop back to first upgrade button
            end
            
            -- Auto-update upgrade info when navigating horizontally 
            if weaponIndex == 1 then
                currentUpgradeIndex.weapons = 0  -- First upgrade
            elseif weaponIndex == 2 then
                currentUpgradeIndex.weapons = 1  -- Second upgrade
            elseif weaponIndex == 3 then
                currentUpgradeIndex.weapons = 2  -- Third upgrade
            elseif weaponIndex == 4 then
                currentUpgradeIndex.weapons = 3  -- Fourth upgrade
            end
            update_ui()
        elseif horizontalValue < 0 then  -- Left
            weaponIndex = weaponIndex - 1
            if weaponIndex < 1 then
                weaponIndex = 4  -- Loop to last upgrade button
            end
            
            -- Auto-update upgrade info when navigating horizontally
            if weaponIndex == 1 then
                currentUpgradeIndex.weapons = 0  -- First upgrade
            elseif weaponIndex == 2 then
                currentUpgradeIndex.weapons = 1  -- Second upgrade
            elseif weaponIndex == 3 then
                currentUpgradeIndex.weapons = 2  -- Third upgrade
            elseif weaponIndex == 4 then
                currentUpgradeIndex.weapons = 3  -- Fourth upgrade
            end
            update_ui()
        end
    end
    
    if verticalValue == 0 and horizontalValue == 0 then
        contadorMovimientoBotones = contadorMovimientoBotones + dt
    end
end

function handle_character_controls(dt)
    -- Reset button states
    aUpgradeSelButton.state = 0
    aISelButton.state = 0
    aIISelButton.state = 0
    aIIISelButton.state = 0
    
    -- Set active button based on current index
    if armorIndex == 0 then
        aUpgradeSelButton.state = 1
    elseif armorIndex == 1 then
        aISelButton.state = 1
    elseif armorIndex == 2 then
        aIISelButton.state = 1
    elseif armorIndex == 3 then
        aIIISelButton.state = 1
    end
      -- Handle confirm button press
    local confirmState = Input.get_button(Input.action.Confirm)
    if confirmState == Input.state.Repeat and not confirmPressed then
        confirmPressed = true
        
        -- Handle action based on selected index
        if armorIndex == 0 then
            aUpgradeSelButton.state = 2
            -- Buy the currently selected upgrade
            local currentUpgrade = upgradeTypes.armor[currentUpgradeIndex.armor + 1]

            local isPreviousPurchased = upgradeTypes.armor[currentUpgradeIndex.armor]
            if isPreviousPurchased == nil then
                isPreviousPurchased = true
            end               

            if currentUpgrade and upgradeManager.has_upgrade("armor", isPreviousPurchased) then
                local success = upgradeManager.buy_upgrade("armor", currentUpgrade)
                if success then
                    find_next_available_upgrade("armor")
                    update_ui()
                end  
            elseif currentUpgrade and isPreviousPurchased and currentUpgrade == "healthBoost" then
                local success = upgradeManager.buy_upgrade("armor", "healthBoost")
                if success then
                    find_next_available_upgrade("armor")
                    update_ui()
                end
            end
        elseif armorIndex == 1 then
            aISelButton.state = 1  
             
            currentUpgradeIndex.armor = 0
            update_ui()
            armorIndex = 0
            aUpgradeSelButton.state = 1  
        elseif armorIndex == 2 then
            aIISelButton.state = 1  
             
            currentUpgradeIndex.armor = 1
            update_ui()
            armorIndex = 0
            aUpgradeSelButton.state = 1  
        elseif armorIndex == 3 then
            aIIISelButton.state = 1  
             
            currentUpgradeIndex.armor = 2
            update_ui()
            armorIndex = 0
            aUpgradeSelButton.state = 1  
        end
    elseif confirmState ~= Input.state.Repeat then
        confirmPressed = false
    end
      -- Handle vertical navigation
    local verticalValue = Input.get_axis(Input.action.UiMoveVertical)
    if (verticalValue ~= 0 and contadorMovimientoBotones > 0.05) then
        contadorMovimientoBotones = 0
        
        if verticalValue < 0 then  -- Down
            if armorIndex == 0 then
                -- If currently on upgrade button, go to the first armor upgrade button
                armorIndex = 1
                
                -- Auto-update displayed upgrade info
                currentUpgradeIndex.armor = 0  -- First upgrade
                update_ui()
            else
                -- If on armor upgrade buttons, go to main upgrade button
                armorIndex = 0
            end
        elseif verticalValue > 0 then  -- Up
            if armorIndex == 0 then
                -- If currently on upgrade button, go to the first armor upgrade button
                armorIndex = 1
                
                -- Auto-update displayed upgrade info
                currentUpgradeIndex.armor = 0  -- First upgrade
                update_ui()
            else
                -- If on armor upgrade buttons, go to main upgrade button
                armorIndex = 0
            end
        end
    end
      -- Handle horizontal navigation (only when on armor upgrade buttons)
    local horizontalValue = Input.get_axis(Input.action.UiMoveHorizontal)
    if (horizontalValue ~= 0 and contadorMovimientoBotones > 0.05 and armorIndex > 0) then
        contadorMovimientoBotones = 0
        
        if horizontalValue > 0 then  -- Right
            armorIndex = armorIndex + 1
            if armorIndex > 3 then
                armorIndex = 1  -- Loop back to first upgrade button
            end
            
            -- Auto-update upgrade info when navigating horizontally
            if armorIndex == 1 then
                currentUpgradeIndex.armor = 0  -- First upgrade
            elseif armorIndex == 2 then
                currentUpgradeIndex.armor = 1  -- Second upgrade
            elseif armorIndex == 3 then
                currentUpgradeIndex.armor = 2  -- Third upgrade
            end
            update_ui()
        elseif horizontalValue < 0 then  -- Left
            armorIndex = armorIndex - 1
            if armorIndex < 1 then
                armorIndex = 3  -- Loop to last upgrade button
            end
            
            -- Auto-update upgrade info when navigating horizontally
            if armorIndex == 1 then
                currentUpgradeIndex.armor = 0  -- First upgrade
            elseif armorIndex == 2 then
                currentUpgradeIndex.armor = 1  -- Second upgrade
            elseif armorIndex == 3 then
                currentUpgradeIndex.armor = 2  -- Third upgrade
            end
            update_ui()
        end
    end
    
    if verticalValue == 0 and horizontalValue == 0 then
        contadorMovimientoBotones = contadorMovimientoBotones + dt
    end
end

function show_ui()
    -- Show shared UI elements
    gBackgroundEntity:set_active(true)
    gDot1ButtonEntity:set_active(true)
    gDot2ButtonEntity:set_active(true)
    gScrapTxtEntity:set_active(true)
    
    if currentScreen == "gun" then
        show_gun_ui()
        -- Set dot1 to hover and dot2 to normal
        if gDot1Button then gDot1Button.state = 0 end
        if gDot2Button then gDot2Button.state = 1 end
    else
        show_character_ui()
        -- Set dot1 to normal and dot2 to hover
        if gDot1Button then gDot1Button.state = 1 end
        if gDot2Button then gDot2Button.state = 0 end
    end
    
    find_next_available_upgrade("weapons")
    find_next_available_upgrade("armor")
    update_ui()
    
    isWorkBenchOpen = true
    openCooldownTimer = 0

    hud:set_active(false)
    if missionManager then
        missionManager:set_active(false)
    end
    if dialogManager then
        dialogManager:set_active(false)
    end
    if popUpManager then
        popUpManager:set_active(false)
    end
end

function show_gun_ui()
    -- Show gun UI elements
    wNameTxtEntity:set_active(true)
    wDescTxtEntity:set_active(true)
    wTitleTxtEntity:set_active(true)
    wCostTxtEntity:set_active(true)
    wBuyTxtEntity:set_active(true)
    wScrapIconEntity:set_active(true)
    wRenderEntity:set_active(true)
    wUpgradesBackgroundEntity:set_active(true)
    
    -- Show upgrade indicators and buttons
    wUpgradeSelButtonEntity:set_active(true)
    
    -- Show appropriate upgrade indicators based on purchase status
    if upgradeManager then
        -- First upgrade (reload reduction)
        local upgrade1 = upgradeManager.upgrades.weapons.reloadReduction
        wIEntity:set_active(not upgrade1)
        wIBoughtEntity:set_active(upgrade1)
        wISelButtonEntity:set_active(true)
        
        -- Second upgrade (damage boost)
        local upgrade2 = upgradeManager.upgrades.weapons.damageBoost
        wIIEntity:set_active(not upgrade2)
        wIIBoughtEntity:set_active(upgrade2)
        wIISelButtonEntity:set_active(true)
        
        -- Third upgrade (fire rate boost)
        local upgrade3 = upgradeManager.upgrades.weapons.fireRateBoost
        wIIIEntity:set_active(not upgrade3)
        wIIIBoughtEntity:set_active(upgrade3)
        wIIISelButtonEntity:set_active(true)
        
        -- Fourth upgrade (special ability)
        local upgrade4 = upgradeManager.upgrades.weapons.specialAbility
        wIVEntity:set_active(not upgrade4)
        wIVBoughtEntity:set_active(upgrade4)
        wIVSelButtonEntity:set_active(true)
    else
        -- If upgradeManager not available, show default state (unpurchased)
        wIEntity:set_active(true)
        wIIEntity:set_active(true)
        wIIIEntity:set_active(true)
        wIVEntity:set_active(true)
        wIBoughtEntity:set_active(false)
        wIIBoughtEntity:set_active(false)
        wIIIBoughtEntity:set_active(false)
        wIVBoughtEntity:set_active(false)
        wISelButtonEntity:set_active(true)
        wIISelButtonEntity:set_active(true)
        wIIISelButtonEntity:set_active(true)
        wIVSelButtonEntity:set_active(true)
    end
end

function show_character_ui()
    -- Show character UI elements
    aNameTxtEntity:set_active(true)
    aDescTxtEntity:set_active(true)
    aTitleTxtEntity:set_active(true)
    aCostTxtEntity:set_active(true)
    aBuyTxtEntity:set_active(true)
    aScrapIconEntity:set_active(true)
    aRenderEntity:set_active(true)
    aUpgradesBackgroundEntity:set_active(true)
    
    -- Show upgrade indicators and buttons
    aUpgradeSelButtonEntity:set_active(true)
    
    -- Show appropriate upgrade indicators based on purchase status
    if upgradeManager then
        -- First upgrade (health boost)
        local upgrade1 = upgradeManager.upgrades.armor.healthBoost
        aIEntity:set_active(not upgrade1)
        aIBoughtEntity:set_active(upgrade1)
        aISelButtonEntity:set_active(true)
        
        -- Second upgrade (protection)
        local upgrade2 = upgradeManager.upgrades.armor.protection
        aIIEntity:set_active(not upgrade2)
        aIIBoughtEntity:set_active(upgrade2)
        aIISelButtonEntity:set_active(true)
        
        -- Third upgrade (special ability)
        local upgrade3 = upgradeManager.upgrades.armor.specialAbility
        aIIIEntity:set_active(not upgrade3)
        aIIIBoughtEntity:set_active(upgrade3)
        aIIISelButtonEntity:set_active(true)
    else
        -- If upgradeManager not available, show default state (unpurchased)
        aIEntity:set_active(true)
        aIIEntity:set_active(true)
        aIIIEntity:set_active(true)
        aIBoughtEntity:set_active(false)
        aIIBoughtEntity:set_active(false)
        aIIIBoughtEntity:set_active(false)
        aISelButtonEntity:set_active(true)
        aIISelButtonEntity:set_active(true)
        aIIISelButtonEntity:set_active(true)
    end
end

function hide_ui()
    hide_gun_ui(true) 
    hide_character_ui(true)
    
    -- Hide shared UI elements
    gBackgroundEntity:set_active(false)
    gDot1ButtonEntity:set_active(false)
    gDot2ButtonEntity:set_active(false)
    gScrapTxtEntity:set_active(false)
    
    isWorkBenchOpen = false

    hud:set_active(true)
    if missionManager then
        missionManager:set_active(true)
    end
    if dialogManager then
        dialogManager:set_active(true)
    end
    if popUpManager then
        popUpManager:set_active(true)
    end
end

function hide_gun_ui(hideShared)
    -- Hide gun UI elements
    wNameTxtEntity:set_active(false)
    wDescTxtEntity:set_active(false)
    wTitleTxtEntity:set_active(false)
    wCostTxtEntity:set_active(false)
    wBuyTxtEntity:set_active(false)
    wScrapIconEntity:set_active(false)
    wRenderEntity:set_active(false)
    wUpgradesBackgroundEntity:set_active(false)
    
    -- Hide upgrade indicators
    wIEntity:set_active(false)
    wIIEntity:set_active(false)
    wIIIEntity:set_active(false)
    wIVEntity:set_active(false)
    wIBoughtEntity:set_active(false)
    wIIBoughtEntity:set_active(false)
    wIIIBoughtEntity:set_active(false)
    wIVBoughtEntity:set_active(false)
    
    -- Hide selection buttons
    wISelButtonEntity:set_active(false)
    wIISelButtonEntity:set_active(false)
    wIIISelButtonEntity:set_active(false)
    wIVSelButtonEntity:set_active(false)
    wUpgradeSelButtonEntity:set_active(false)
    
    -- Hide shared elements if required
    if hideShared then
        -- This is handled in hide_ui now
    end
end

function hide_character_ui(hideShared)
    -- Hide character UI elements
    aNameTxtEntity:set_active(false)
    aDescTxtEntity:set_active(false)
    aTitleTxtEntity:set_active(false)
    aCostTxtEntity:set_active(false)
    aBuyTxtEntity:set_active(false)
    aScrapIconEntity:set_active(false)
    aRenderEntity:set_active(false)
    aUpgradesBackgroundEntity:set_active(false)
    
    -- Hide upgrade indicators
    aIEntity:set_active(false)
    aIIEntity:set_active(false)
    aIIIEntity:set_active(false)
    aIBoughtEntity:set_active(false)
    aIIBoughtEntity:set_active(false)
    aIIIBoughtEntity:set_active(false)
    
    -- Hide selection buttons
    aISelButtonEntity:set_active(false)
    aIISelButtonEntity:set_active(false)
    aIIISelButtonEntity:set_active(false)
    aUpgradeSelButtonEntity:set_active(false)
    
    -- Hide shared elements if required
    if hideShared then
        -- This is handled in hide_ui now
    end
end

function is_workbench_open()
    return isWorkBenchOpen
end

function on_exit()
    -- Add cleanup code here
end
