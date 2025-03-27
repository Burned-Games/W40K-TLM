local maxAmmo = 30
local currentAmmo = maxAmmo
local maxHealth = 100
local currentHealth = maxHealth
local chatarraCount = 0

local ammoTextComponent
local lifeTextComponent
local chatarraTextComponent

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


function on_ready()
    -- Add initialization code here
    ammoTextComponent = current_scene:get_entity_by_name("BalasRestantes"):get_component("UITextComponent")
    lifeTextComponent = current_scene:get_entity_by_name("VidaValor"):get_component("UITextComponent")
    chatarraTextComponent = current_scene:get_entity_by_name("ChatarraTexto"):get_component("UITextComponent")
    skill1 = current_scene:get_entity_by_name("Habilidad1"):get_component("UIImageComponent")
    skill1TextCooldown = current_scene:get_entity_by_name("Habilidad1Cooldown"):get_component("UITextComponent")
    skill2 = current_scene:get_entity_by_name("Habilidad2"):get_component("UIImageComponent")
    skill2TextCooldown = current_scene:get_entity_by_name("Habilidad2Cooldown"):get_component("UITextComponent")
    skill3 = current_scene:get_entity_by_name("Habilidad3"):get_component("UIImageComponent")
    skill3TextCooldown = current_scene:get_entity_by_name("Habilidad3Cooldown"):get_component("UITextComponent")
    arma1 = current_scene:get_entity_by_name("Arma1"):get_component("UIImageComponent")
    arma2 = current_scene:get_entity_by_name("Arma2"):get_component("UIImageComponent")

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
    -- Reducimos el cooldown con el tiempo
    if weaponSwitchTimer > 0 then
        weaponSwitchTimer = weaponSwitchTimer - dt
    end

    -- Si se presiona Skill3 y el cooldown ha terminado, cambiar de arma
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
    end
end
