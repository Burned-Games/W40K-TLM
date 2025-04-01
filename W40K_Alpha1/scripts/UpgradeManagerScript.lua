scrap = 9999
jetpacklvl1 = nil
jetpacklvl2 = nil
helmetlvl1 = nil
helmetlvl2 = nil
local player = nil

-- Multipliers 
local MULTIPLIERS = {
    weapons = {
        reloadReduction = 0.8,   -- 20% less reload time
        damageBoost = 1.15,      -- 15% more damage
        fireRateBoost = 0.9      -- 10% faster firing 
    },
    armor = {
        healthBoost = 20        -- 20% more health
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
        reloadReduction = "Battle effectivenes",
        damageBoost = "Blessed bolter",
        fireRateBoost = "Fire rate (+10%)...",
        specialAbility = "Weapon special ability..."
    },
    armor = {
        healthBoost = "Strenth through suffering",
        protection = "Emperor’s Blessing",
        specialAbility = "Ultramarine Ancient"
    }
}

upgradeDescriptions = {
    weapons = {
        reloadReduction = "Reduces reload time by 20%",
        damageBoost = "Increases base damage by 15%",
        fireRateBoost = "Increases fire rate by 10%",
        specialAbility = "Unlocks a special ability for the weapon"
    },
    armor = {
        healthBoost = "Increases max health by 20%",
        protection = "Grants protection after 5 seconds out of combat",
        specialAbility = "Unlocks a special ability for the armor"
    }
}

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
        apply_to_player(player)
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
        return baseHealth + MULTIPLIERS.armor.healthBoost
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
    rifle.maxReloadTime = get_reload_time(BASE_VALUES.reloadTimeRifle)
    rifle.shootCoolDownRifle = get_shoot_cooldown(BASE_VALUES.shootCoolDownRifle)
    rifle.damage = get_damage(BASE_VALUES.damageRifle)

    -- Shotgun
    shotgun.reload_time = get_reload_time(BASE_VALUES.reloadTimeShotgun)
    shotgun.shotgun_fire_rate = get_shoot_cooldown(BASE_VALUES.shootCoolDownShotgun)
    shotgun.damage = get_damage(BASE_VALUES.damageShotgun)
    
    print("Upgrades applied to player")
    print("Max health: " .. player.playerHealth)
    handle_visuals()
    return player
end

function on_ready()
    player = current_scene:get_entity_by_name("Player"):get_component("ScriptComponent")
    rifle = current_scene:get_entity_by_name("BolterManager"):get_component("ScriptComponent")
    shotgun = current_scene:get_entity_by_name("ShotgunManager"):get_component("ScriptComponent")
    helmetlvl1 = current_scene:get_entity_by_name("Casco_lv1")
    helmetlvl2 = current_scene:get_entity_by_name("Casco_lvl_2")
    jetpacklvl1 = current_scene:get_entity_by_name("Jetpack_lv1")
    jetpacklvl2 = current_scene:get_entity_by_name("Jetpack_lv2")
end

function on_update(dt)
end

function handle_visuals()
    if has_upgrade("armor", "healthBoost") then
        jetpacklvl2:set_active(true)
    end

    if has_upgrade("armor", "protection") then
        helmetlvl1:set_active(false)
        helmetlvl2:set_active(true)
    end
end