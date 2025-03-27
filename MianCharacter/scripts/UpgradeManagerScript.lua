scrap = 3

-- Multipliers 
local MULTIPLIERS = {
    weapons = {
        reloadReduction = 0.8,   -- 20% less reload time
        damageBoost = 1.15,      -- 15% more damage
        fireRateBoost = 0.9      -- 10% faster firing 
    },
    armor = {
        healthBoost = 1.2        -- 20% more health
    }
}

local BASE_VALUES = {
    maxHealth = 100,

    -- Rifle values
    reloadTimeRifle = 2.5,
    shootCoolDownRifle = 0.6,
    damageRifle = 25,

    -- Shotgun values
    reloadTimeShotgun = 2.8,
    shootCoolDownShotgun = 1.3,
    damageShotgun = 120
}

-- Upgrade status (true = purchased, false = not purchased)
upgrades = {
    weapons = {
        reloadReduction = false,  -- -20% reload time (250 scrap)
        damageBoost = false,      -- +15% base damage (400 scrap)
        fireRateBoost = false,    -- +10% fire rate (600 scrap)
        specialAbility = false    -- Special ability (800 scrap)
    },
    armor = {
        healthBoost = false,      -- +20% max health (300 scrap)
        protection = false,       -- idk q hace? (500 scrap)
        specialAbility = false    -- Special ability (700 scrap)
    }
}

-- Upgrade costs
costs = {
    weapons = {
        reloadReduction = 250,
        damageBoost = 400,
        fireRateBoost = 600,
        specialAbility = 800
    },
    armor = {
        healthBoost = 300,
        protection = 500,
        specialAbility = 700
    }
}

-- Upgrade selection system
local selectedCategory = "weapons"  -- Selected category (weapons or armor)
local selectedUpgrades = {
    weapons = "reloadReduction",
    armor = "healthBoost"
}

-- Ordered list of upgrades for each category
local upgradeOrder = {
    weapons = {"reloadReduction", "damageBoost", "fireRateBoost", "specialAbility"},
    armor = {"healthBoost", "protection", "specialAbility"}
}

-- Upgrade names
upgradeNames = {
    weapons = {
        reloadReduction = "Reload reduction (-20%)... CAMBIAR POR NOMBRE QUE DIGA DESIGN",
        damageBoost = "Damage boost (+15%)... CAMBIAR POR NOMBRE QUE DIGA DESIGN",
        fireRateBoost = "Fire rate (+10%)... CAMBIAR POR NOMBRE QUE DIGA DESIGN",
        specialAbility = "Weapon special ability... CAMBIAR POR NOMBRE QUE DIGA DESIGN"
    },
    armor = {
        healthBoost = "Max health increase (+20%)... CAMBIAR POR NOMBRE QUE DIGA DESIGN",
        protection = "Protection after 5s out of combat... CAMBIAR POR NOMBRE QUE DIGA DESIGN",
        specialAbility = "Armor special ability... CAMBIAR POR NOMBRE QUE DIGA DESIGN"
    }
}

upgradeDescriptions = {
    weapons = {
        reloadReduction = "Reduces reload time by 20%... CAMBIAR POR DESCRIPCION QUE DIGA DESIGN",
        damageBoost = "Increases base damage by 15%... CAMBIAR POR DESCRIPCION QUE DIGA DESIGN",
        fireRateBoost = "Increases fire rate by 10%... CAMBIAR POR DESCRIPCION QUE DIGA DESIGN",
        specialAbility = "Unlocks a special ability for the weapon... CAMBIAR POR DESCRIPCION QUE DIGA DESIGN"
    },
    armor = {
        healthBoost = "Increases max health by 20%... CAMBIAR POR DESCRIPCION QUE DIGA DESIGN",
        protection = "Grants protection after 5 seconds out of combat... CAMBIAR POR DESCRIPCION QUE DIGA DESIGN",
        specialAbility = "Unlocks a special ability for the armor... CAMBIAR POR DESCRIPCION QUE DIGA DESIGN"
    }
}

----------------------------------
-- TEST UPGRADES START (DELETE)
local xPressed = false
local onePressed = false
local twoPressed = false
local cPressed = false
local mPressed = false
-- TEST UPGRADES END (DELETE)
----------------------------------

function add_scrap(amount)
    scrap = scrap + amount
    print("Scrap added: " .. amount .. " - Total: " .. scrap)
end

function get_scrap()
    return scrap
end

-- Checker for buying an upgrade
function can_buy(category, upgrade)
    return not upgrades[category][upgrade] and 
           scrap >= costs[category][upgrade]
end

-- Buy upgrade
function buy_upgrade(category, upgrade)
    if can_buy(category, upgrade) then
        scrap = scrap - costs[category][upgrade]
        upgrades[category][upgrade] = true
        print("Upgrade purchased: " .. upgradeNames[category][upgrade] .. " - Remaining scrap: " .. scrap)
        return true
    else
        if upgrades[category][upgrade] then
            print("ERROR: This upgrade has already been purchased")
        else
            print("ERROR: Not enough scrap. You need: " .. costs[category][upgrade] .. ", You have: " .. scrap)
        end
        return false
    end
end

-- Check if player has an upgrade
function has_upgrade(category, upgrade)
    return upgrades[category][upgrade]
end

-- Select next upgrade in category
function select_next_upgrade(category)
    local currentIndex = 1
    for i, upgradeName in ipairs(upgradeOrder[category]) do
        if upgradeName == selectedUpgrades[category] then
            currentIndex = i
            break
        end
    end
    
    -- Look for the next unpurchased upgrade, starting from the next one
    local startIndex = currentIndex
    repeat
        currentIndex = currentIndex + 1
        if currentIndex > #upgradeOrder[category] then
            currentIndex = 1
        end
        
        if currentIndex == startIndex then
            break
        end
    until not upgrades[category][upgradeOrder[category][currentIndex]]
    
    -- Update selection
    selectedUpgrades[category] = upgradeOrder[category][currentIndex]
end

----------------------------------
-- Display currently selected upgrade (DEBUG)
----------------------------------
function print_selected_upgrade()
    local category = selectedCategory
    local upgrade = selectedUpgrades[category]
    local status = upgrades[category][upgrade] and "PURCHASED" or "NOT PURCHASED"
    local price = costs[category][upgrade]
    
    print("\n=== SELECTED UPGRADE ===")
    print("Category: " .. (category == "weapons" and "WEAPONS" or "ARMOR"))
    print("Upgrade: " .. upgradeNames[category][upgrade])
    print("Status: " .. status)
    print("Price: " .. price .. " scrap")
    print("Your scrap: " .. scrap)
    
    if can_buy(category, upgrade) then
        print("YOU CAN BUY THIS UPGRADE (Press C)")
    elseif upgrades[category][upgrade] then
        print("YOU ALREADY PURCHASED THIS UPGRADE")
    else
        print("NOT ENOUGH SCRAP (You need " .. (price - scrap) .. " more)")
    end
    print("===========================\n")
end

----------------------------------
-- UPGRADE APPLICATION
----------------------------------
function get_reload_time(baseTime)
    if has_upgrade("weapons", "reloadReduction") then
        return baseTime * MULTIPLIERS.weapons.reloadReduction
    end
    return baseTime
end

function get_shoot_cooldown(baseCooldown)
    if has_upgrade("weapons", "fireRateBoost") then
        return baseCooldown * MULTIPLIERS.weapons.fireRateBoost
    end
    return baseCooldown
end

function get_damage(baseDamage)
    if has_upgrade("weapons", "damageBoost") then
        return baseDamage * MULTIPLIERS.weapons.damageBoost
    end
    return baseDamage
end

function get_max_health(baseHealth)
    if has_upgrade("armor", "healthBoost") then
        return baseHealth * MULTIPLIERS.armor.healthBoost
    end
    return baseHealth
end

----------------------------------
-- SPECIAL ABILITIES
----------------------------------
function has_weapon_special()
    return has_upgrade("weapons", "specialAbility")
end

function has_armor_special()
    return has_upgrade("armor", "specialAbility")
end

function has_protection()
    return has_upgrade("armor", "protection")
end

----------------------------------
-- APPLY UPGRADES TO PLAYER
----------------------------------
function apply_to_player(player)
    -- Health
    player.playerHealth = get_max_health(BASE_VALUES.maxHealth)
    
    -- Rifle
    player.maxReloadTimeRifle = get_reload_time(BASE_VALUES.reloadTimeRifle)
    player.shootCoolDownRifle = get_shoot_cooldown(BASE_VALUES.shootCoolDownRifle)
    player.damageRifle = get_damage(BASE_VALUES.damageRifle)

    -- Shotgun
    player.maxReloadTimeShotgun = get_reload_time(BASE_VALUES.reloadTimeShotgun)
    player.shootCoolDownShotgun = get_shoot_cooldown(BASE_VALUES.shootCoolDownShotgun)
    player.damageShotgun = get_damage(BASE_VALUES.damageShotgun)
    
    print("Upgrades applied to player")
    return player
end

----------------------------------
-- PRINT ALL VALUES (DEBUG)
----------------------------------
function print_all_values()
    print("\n======= UPGRADE SYSTEM STATUS =======")
    print("Scrap: " .. scrap)
    
    print("\n--- WEAPON UPGRADES ---")
    print("Reload reduction: " .. tostring(upgrades.weapons.reloadReduction) .. 
          " (Cost: " .. costs.weapons.reloadReduction .. 
          ", Effect: " .. (MULTIPLIERS.weapons.reloadReduction * 100) .. "% of base time)")
    
    print("Damage boost: " .. tostring(upgrades.weapons.damageBoost) .. 
          " (Cost: " .. costs.weapons.damageBoost .. 
          ", Effect: +" .. ((MULTIPLIERS.weapons.damageBoost - 1) * 100) .. "% damage)")
    
    print("Fire rate: " .. tostring(upgrades.weapons.fireRateBoost) .. 
          " (Cost: " .. costs.weapons.fireRateBoost .. 
          ", Effect: " .. (MULTIPLIERS.weapons.fireRateBoost * 100) .. "% of base cooldown)")
    
    print("Special ability: " .. tostring(upgrades.weapons.specialAbility) .. 
          " (Cost: " .. costs.weapons.specialAbility .. ")")
    
    print("\n--- ARMOR UPGRADES ---")
    print("Health boost: " .. tostring(upgrades.armor.healthBoost) .. 
          " (Cost: " .. costs.armor.healthBoost .. 
          ", Effect: +" .. ((MULTIPLIERS.armor.healthBoost - 1) * 100) .. "% health)")
    
    print("Protection: " .. tostring(upgrades.armor.protection) .. 
          " (Cost: " .. costs.armor.protection .. ")")
    
    print("Special ability: " .. tostring(upgrades.armor.specialAbility) .. 
          " (Cost: " .. costs.armor.specialAbility .. ")")
    
    print("\n--- CALCULATED VALUES ---")
    print("\n| Rifle |")
    print("Reload time RIFLE (base " .. BASE_VALUES.reloadTimeRifle .. "s): " .. 
          get_reload_time(BASE_VALUES.reloadTimeRifle) .. "s")
    
    print("Shoot cooldown RIFLE (base " .. BASE_VALUES.shootCoolDownRifle .. "s): " .. 
          get_shoot_cooldown(BASE_VALUES.shootCoolDownRifle) .. "s")

    print("Damage RIFLE (base " .. BASE_VALUES.damageRifle .. "): " .. 
          get_damage(BASE_VALUES.damageRifle))

    print("\n| SHOTGUN |")
    print("Reload time SHOTGUN (base " .. BASE_VALUES.reloadTimeShotgun .. "s): " .. 
          get_reload_time(BASE_VALUES.reloadTimeShotgun) .. "s")
    
    print("Shoot cooldown SHOTGUN (base " .. BASE_VALUES.shootCoolDownShotgun .. "s): " ..
          get_shoot_cooldown(BASE_VALUES.shootCoolDownShotgun) .. "s")

    print("Damage SHOTGUN (base " .. BASE_VALUES.damageShotgun .. "): " ..
          get_damage(BASE_VALUES.damageShotgun))
    
    print("\n| HEALTH |")
    print("Max health (base " .. BASE_VALUES.maxHealth .. "): " .. 
          get_max_health(BASE_VALUES.maxHealth))
    
    print("============================================\n")
end

function on_ready()
    -- Add initialization code here

    ----------------------------------
    -- TEST UPGRADES START (DELETE)
    print("Upgrade system initialized")
    print("\nControls:")
    print("O - Select WEAPONS upgrades")
    print("P - Select ARMOR upgrades")
    print("C - Purchase selected upgrade")
    print("X - Show complete system status")
    print_selected_upgrade()
    -- TEST UPGRADES END (DELETE)
    ----------------------------------
end

function on_update(dt)
    ----------------------------------
    -- TEST UPGRADES START (DELETE)
    
    -- O: Select weapons category
    if Input.is_key_pressed(Input.keycode.O) then
        if not onePressed then
            onePressed = true
            selectedCategory = "weapons"
            print("\n> SELECTED CATEGORY: WEAPONS")
            print_selected_upgrade()
        end
    else
        onePressed = false
    end
    
    -- P: Select armor category
    if Input.is_key_pressed(Input.keycode.P) then
        if not twoPressed then
            twoPressed = true
            selectedCategory = "armor"
            print("\n> SELECTED CATEGORY: ARMOR")
            print_selected_upgrade()
        end
    else
        twoPressed = false
    end
    
    -- C: Buy upgrade selected
    if Input.is_key_pressed(Input.keycode.C) then
        if not cPressed then
            cPressed = true
            local category = selectedCategory
            local upgrade = selectedUpgrades[category]
            
            if buy_upgrade(category, upgrade) then
                select_next_upgrade(category)
                print("> Selected next available upgrade")
                print_selected_upgrade()
            end
        end
    else
        cPressed = false
    end
    
    -- X: Print all values
    if Input.is_key_pressed(Input.keycode.X) then
        if not xPressed then
            xPressed = true
            print_all_values()
        end
    else
        xPressed = false
    end

    -- M: Add scrap
    if Input.is_key_pressed(Input.keycode.M) then
        if not mPressed then
            mPressed = true
            add_scrap(1000)
        end
    else
        mPressed = false
    end
    -- TEST UPGRADES END (DELETE)
    ----------------------------------
end