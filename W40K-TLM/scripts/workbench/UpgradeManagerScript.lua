jetpacklvl1 = nil
jetpacklvl2 = nil
helmetlvl1 = nil
helmetlvl2 = nil
local player = nil

-- Multipliers 
local MULTIPLIERS = {
    weapons = {
        reloadReduction = 0.7,   -- 30% less reload time
        damageBoost = 1.20,      -- 20% more damage
        fireRateBoost = 0.75      -- 25% faster firing 
    },
    armor = {
        healthBoost = 50        -- 50 more health
    }
}

local BASE_VALUES = {
    maxHealth = 250,

    -- Rifle values
    reloadTimeRifle = 2.5,
    shootCoolDownRifle = 1.3,
    damageRifle = 12,

    -- Shotgun values
    reloadTimeShotgun = 2.8,
    shootCoolDownShotgun = 1.5,
    damageShotgun = 8
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
        fireRateBoost = "Sacred bullets",
        specialAbility = "Tactical Supremacy"
    },
    armor = {
        healthBoost = "Strength through suffering",
        protection = "Emperor's Blessing",
        specialAbility = "Ultramarine Ancient"
    }
}

upgradeDescriptions = {
    weapons = {
        reloadReduction = "Effect: -30% reload time",
        damageBoost = "+20% damage base",
        fireRateBoost = "+25% fire rate",
        specialAbility = "Unlock \n  - Disruptor Charge \n  - Neuroinhibitor Grenade"
    },
    armor = {
        healthBoost = "Increases max health \n by 20%",
        protection = "Grants protection after \n5 seconds out of combat",
        specialAbility = "Unlock Astartes Fervor"
    }
}

function add_scrap(amount)
    player.scrapCounter = player.scrapCounter + amount
    --print("Scrap added: " .. amount .. " - Total: " .. player.scrapCounter)
end

function get_scrap()
    return player.scrapCounter
end

-- Checker for buying an upgrade
function can_buy(category, upgrade)
    return not upgrades[category][upgrade] and 
           player.scrapCounter >= costs[category][upgrade]
end

-- Buy upgrade
function buy_upgrade(category, upgrade)
    if can_buy(category, upgrade) then
        player.scrapCounter = player.scrapCounter - costs[category][upgrade]
        upgrades[category][upgrade] = true
        --print("Upgrade purchased: " .. upgradeNames[category][upgrade] .. " - Remaining scrap: " .. player.scrapCounter)
        apply_to_player(player)
        return true
    else
        if upgrades[category][upgrade] then
            --print("ERROR: This upgrade has already been purchased")
        else
            --print("ERROR: Not enough scrap. You need: " .. costs[category][upgrade] .. ", You have: " .. player.scrapCounter)
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
    player.maxHealth = get_max_health(BASE_VALUES.maxHealth)
    
    -- Rifle
    rifle.maxReloadTime = get_reload_time(BASE_VALUES.reloadTimeRifle)
    rifle.shootCoolDownRifle = get_shoot_cooldown(BASE_VALUES.shootCoolDownRifle)
    rifle.damage = get_damage(BASE_VALUES.damageRifle)

    -- Shotgun
    shotgun.reload_time = get_reload_time(BASE_VALUES.reloadTimeShotgun)
    shotgun.shotgun_fire_rate = get_shoot_cooldown(BASE_VALUES.shootCoolDownShotgun)
    shotgun.damage = get_damage(BASE_VALUES.damageShotgun)
    
    --print("Upgrades applied to player")
    --print("Max health: " .. player.playerHealth)
    
    if jetpacklvl1 ~= nil and jetpacklvl2 ~= nil and helmetlvl1 ~= nil and helmetlvl2 ~= nil then
        handle_visuals()
    end
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

    
    -- Load upgrades from save
    load_upgrades()

    -- Load visuals
    -- if jetpacklvl1 ~= nil and jetpacklvl2 ~= nil and helmetlvl1 ~= nil and helmetlvl2 ~= nil then
    --     load_visuals()
    -- end
end

function on_update(dt)
end

-- function handle_visuals()
--     if has_upgrade("armor", "healthBoost") then
--         jetpacklvl2:set_active(true)
--     end

--     if has_upgrade("armor", "protection") then
--         helmetlvl1:set_active(false)
--         helmetlvl2:set_active(true)
--     end
-- end

function handle_visuals()
    if has_upgrade("armor", "healthBoost") then
        jetpacklvl1:set_active(false)
        jetpacklvl2:set_active(true)
    else
        jetpacklvl1:set_active(true)
        jetpacklvl2:set_active(false)
    end

    if has_upgrade("armor", "protection") then
        helmetlvl1:set_active(false)
        helmetlvl2:set_active(true)
    else
        helmetlvl1:set_active(true)
        helmetlvl2:set_active(false)
    end
end

function save_upgrades()
    save_progress("weaponsReloadReduction", upgrades.weapons.reloadReduction)
    save_progress("weaponsDamageBoost", upgrades.weapons.damageBoost)
    save_progress("weaponsFireRateBoost", upgrades.weapons.fireRateBoost)
    save_progress("weaponsSpecialAbility", upgrades.weapons.specialAbility)
    save_progress("armorHealthBoost", upgrades.armor.healthBoost)
    save_progress("armorProtection", upgrades.armor.protection)
    save_progress("armorSpecialAbility", upgrades.armor.specialAbility)
    
    --print("Upgrades saved")
end
function load_upgrades()
    upgrades.weapons.reloadReduction = load_progress("weaponsReloadReduction", false)
    upgrades.weapons.damageBoost = load_progress("weaponsDamageBoost", false)
    upgrades.weapons.fireRateBoost = load_progress("weaponsFireRateBoost", false)
    upgrades.weapons.specialAbility = load_progress("weaponsSpecialAbility", false)
    upgrades.armor.healthBoost = load_progress("armorHealthBoost", false)
    upgrades.armor.protection = load_progress("armorProtection", false)
    upgrades.armor.specialAbility = load_progress("armorSpecialAbility", false)

    apply_to_player(player)

    --print("\nUpgrades loaded\n")
end