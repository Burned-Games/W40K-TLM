local maxAmmoWeapon1 = 30
local currentAmmoWeapon1 = maxAmmoWeapon1
local maxAmmoWeapon2 = 15
local currentAmmoWeapon2 = maxAmmoWeapon2
local ammoTextComponent

local maxHealth = 100
local currentHealth = maxHealth

local lifeFullComponent
local life75Component
local life50Component
local life25Component
local life10Component
local lifeTextComponent

local skill1
local skill1TextCooldown
local skill1Cooldown = false
local skill1Timer = 0
local skill2
local skill2Cooldown = false
local skill2Timer = 0
local skill3
local skill3Cooldown = false
local skill3Timer = 0

local arma1
local arma2
local currentWeapon = 1
local weaponSwitchCooldown = 0.2 
local weaponSwitchTimer = 0

local maxChatarraDisplay = 1000
local currentChatarra = 0

local chatarraTextComponent
local chatarraFullComponent
local chatarra75Component
local chatarra50Component
local chatarra25Component

function on_ready()
    --Vida
    lifeFullComponent = current_scene:get_entity_by_name("VidaFull"):get_component("UIImageComponent")
    life75Component = current_scene:get_entity_by_name("Vida75"):get_component("UIImageComponent")
    life50Component = current_scene:get_entity_by_name("Vida50"):get_component("UIImageComponent")
    life25Component = current_scene:get_entity_by_name("Vida25"):get_component("UIImageComponent")
    life10Component = current_scene:get_entity_by_name("Vida10"):get_component("UIImageComponent")
    lifeTextComponent = current_scene:get_entity_by_name("VidaValor"):get_component("UITextComponent")

    --Habilidades
    skill1 = current_scene:get_entity_by_name("Habilidad1"):get_component("UIImageComponent")
    skill1TextCooldown = current_scene:get_entity_by_name("Habilidad1Cooldown"):get_component("UITextComponent")
    skill2 = current_scene:get_entity_by_name("Habilidad2"):get_component("UIImageComponent")
    skill2TextCooldown = current_scene:get_entity_by_name("Habilidad2Cooldown"):get_component("UITextComponent")
    skill3 = current_scene:get_entity_by_name("Habilidad3"):get_component("UIImageComponent")
    skill3TextCooldown = current_scene:get_entity_by_name("Habilidad3Cooldown"):get_component("UITextComponent")

    --Armas
    arma1 = current_scene:get_entity_by_name("Arma1"):get_component("UIImageComponent")
    arma2 = current_scene:get_entity_by_name("Arma2"):get_component("UIImageComponent")
    ammoTextComponent = current_scene:get_entity_by_name("BalasRestantes"):get_component("UITextComponent")
    
    --Chatarra
    chatarraTextComponent = current_scene:get_entity_by_name("ChatarraTexto"):get_component("UITextComponent")
    chatarraFullComponent = current_scene:get_entity_by_name("ChatarraCantidad100"):get_component("UIImageComponent")
    chatarra75Component = current_scene:get_entity_by_name("ChatarraCantidad75"):get_component("UIImageComponent")
    chatarra50Component = current_scene:get_entity_by_name("ChatarraCantidad50"):get_component("UIImageComponent")
    chatarra25Component = current_scene:get_entity_by_name("ChatarraCantidad25"):get_component("UIImageComponent")

end

function on_update(dt)

    abilityManager(dt)

    weaponManager(dt)

end

function on_exit()
    -- Add cleanup code here
end


function abilityManager(dt)
    if Input.is_button_pressed(Input.action.Dash) and not skill1Cooldown then
        skill1:set_visible(false)
        skill1TextCooldown:set_text("5")
        skill1TextCooldown:set_visible(true)
        skill1Timer = 0
        skill1Cooldown = true
    end
    
    if skill1Cooldown then
        skill1Timer = skill1Timer + dt
        local remainingTime = 5 - skill1Timer
        
        skill1TextCooldown:set_text(string.format("%.1f", remainingTime))
        
        if remainingTime <= 0 then
            skill1:set_visible(true)
            skill1TextCooldown:set_visible(false)
            skill1Cooldown = false
        end
    end

    if Input.is_button_pressed(Input.action.Skill1) and not skill2Cooldown then
        skill2:set_visible(false)
        skill2TextCooldown:set_text("8")
        skill2TextCooldown:set_visible(true)
        skill2Timer = 0
        skill2Cooldown = true
    end
    
    if skill2Cooldown then
        skill2Timer = skill2Timer + dt
        local remainingTime = 8 - skill2Timer
        
        skill2TextCooldown:set_text(string.format("%.1f", remainingTime))
        
        if remainingTime <= 0 then
            skill2:set_visible(true)
            skill2TextCooldown:set_visible(false)
            skill2Cooldown = false
        end
    end

    if Input.is_button_pressed(Input.action.Skill2) and not skill3Cooldown then
        skill3:set_visible(false)
        skill3TextCooldown:set_text("10")
        skill3TextCooldown:set_visible(true)
        skill3Timer = 0
        skill3Cooldown = true
    end
    
    if skill3Cooldown then
        skill3Timer = skill3Timer + dt
        local remainingTime = 10 - skill3Timer
        
        skill3TextCooldown:set_text(string.format("%.1f", remainingTime))
        
        if remainingTime <= 0 then
            skill3:set_visible(true)
            skill3TextCooldown:set_visible(false)
            skill3Cooldown = false
        end
    end
end

function weaponManager(dt)
    if weaponSwitchTimer > 0 then
        weaponSwitchTimer = weaponSwitchTimer - dt
    end

    if Input.is_button_pressed(Input.action.Skill3) and weaponSwitchTimer <= 0 then
        if currentWeapon == 1 then
            arma1:set_visible(false)
            arma2:set_visible(true)
            currentWeapon = 2
        else
            arma1:set_visible(true)
            arma2:set_visible(false)
            currentWeapon = 1
        end
        weaponSwitchTimer = weaponSwitchCooldown
        
        updateAmmoText()
    end
end

function updateAmmoText()
    if currentWeapon == 1 then
        ammoTextComponent:set_text(tostring(currentAmmoWeapon1))
    else
        ammoTextComponent:set_text(tostring(currentAmmoWeapon2))
    end
end

function reload()
    if currentWeapon == 1 then
        currentAmmoWeapon1 = maxAmmoWeapon1
    else
        currentAmmoWeapon2 = maxAmmoWeapon2
    end
    updateAmmoText()
end

function use_ammo(amount)
    if currentWeapon == 1 then
        currentAmmoWeapon1 = math.max(0, currentAmmoWeapon1 - amount)
    else
        currentAmmoWeapon2 = math.max(0, currentAmmoWeapon2 - amount)
    end
    updateAmmoText()
end

function update_health_display()

    lifeFullComponent:set_visible(false)
    life75Component:set_visible(false)
    life50Component:set_visible(false)
    life25Component:set_visible(false)
    life10Component:set_visible(false)

    if currentHealth > 75 then
        lifeFullComponent:set_visible(true)
    elseif currentHealth > 50 then
        life75Component:set_visible(true)
    elseif currentHealth > 25 then
        life50Component:set_visible(true)
    elseif currentHealth > 10 then
        life25Component:set_visible(true)
    elseif currentHealth > 0 then
        life10Component:set_visible(true)
    end

    lifeTextComponent:set_text(tostring(math.floor(currentHealth)))
end

function take_damage(damage)
    currentHealth = math.max(0, currentHealth - damage)
    
    update_health_display()
    
    if currentHealth <= 0 then
        --Logic to restart game
        --print("Game Over!")
    end
end

function update_chatarra_display()
    chatarraFullComponent:set_visible(false)
    chatarra75Component:set_visible(false)
    chatarra50Component:set_visible(false)
    chatarra25Component:set_visible(false)

    local displayChatarra = math.min(currentChatarra, maxChatarraDisplay)

    if currentChatarra > 1000 then  
        chatarraFullComponent:set_visible(true)
    elseif displayChatarra > 750 then
        chatarra75Component:set_visible(true)
    elseif displayChatarra > 500 then
        chatarra50Component:set_visible(true)
    elseif displayChatarra > 250 then
        chatarra25Component:set_visible(true)
    end

    chatarraTextComponent:set_text(tostring(math.floor(currentChatarra)))
end

function add_chatarra(amount)
    currentChatarra = currentChatarra + amount
    update_chatarra_display()
end
