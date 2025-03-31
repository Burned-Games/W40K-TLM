local maxAmmoWeapon1 = 15
local maxAmmoTextComponent
local currentAmmoWeapon1 = maxAmmoWeapon1
local maxAmmoWeapon2 = 30
local currentAmmoWeapon2 = maxAmmoWeapon2
local ammoTextComponent

local lifeFullComponent
local life75Component
local lifeTextComponent
local lifeFullTransform

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
local skillsArmasTextCooldown
local skillsArmasCooldown = false
local skillsArmasTimer = 0

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

local player = nil
local playerScript = nil
local lifeFullStartingPosition

local rifleScript = nil
local rifleAbilityCooldown
local maxRifleAbilityCooldown

local shotGunScript
local sawSwordScript

function on_ready()
    --Vida
    lifeFullComponent = current_scene:get_entity_by_name("VidaFull"):get_component("UIImageComponent")
    life75Component = current_scene:get_entity_by_name("Vida75"):get_component("UIImageComponent")
    lifeTextComponent = current_scene:get_entity_by_name("VidaValor"):get_component("UITextComponent")
    lifeFullTransform = current_scene:get_entity_by_name("VidaFull"):get_component("TransformComponent")
    lifeFullStartingPosition = Vector3.new(lifeFullTransform.position.x, lifeFullTransform.position.y + 49, lifeFullTransform.position.z)

    --Habilidades
    skill1 = current_scene:get_entity_by_name("Habilidad1"):get_component("UIImageComponent")
    skill1TextCooldown = current_scene:get_entity_by_name("Habilidad1Cooldown"):get_component("UITextComponent")
    skill2 = current_scene:get_entity_by_name("Habilidad2"):get_component("UIImageComponent")
    skill2TextCooldown = current_scene:get_entity_by_name("Habilidad2Cooldown"):get_component("UITextComponent")
    skill3 = current_scene:get_entity_by_name("Habilidad3"):get_component("UIImageComponent")
    skill3TextCooldown = current_scene:get_entity_by_name("Habilidad3Cooldown"):get_component("UITextComponent")
    skillsArmasTextCooldown = current_scene:get_entity_by_name("HabilidadesArmasCooldown"):get_component("UITextComponent")

    rifleScript = current_scene:get_entity_by_name("BolterManager"):get_component("ScriptComponent")
    rifleAbilityCooldown = rifleScript.cooldownDisruptorBulletTimeCounter
    maxRifleAbilityCooldown = rifleScript.cooldownDisruptorBulletTime

    shotGunScript = current_scene:get_entity_by_name("ShotgunManager"):get_component("ScriptComponent")
    sawSwordScript = current_scene:get_entity_by_name("SawSwordManager"):get_component("ScriptComponent")

    --Armas
    arma1 = current_scene:get_entity_by_name("Arma1"):get_component("UIImageComponent")
    arma2 = current_scene:get_entity_by_name("Arma2"):get_component("UIImageComponent")
    maxAmmoTextComponent = current_scene:get_entity_by_name("BalasMax"):get_component("UITextComponent")
    ammoTextComponent = current_scene:get_entity_by_name("BalasRestantes"):get_component("UITextComponent")
    
    --Chatarra
    chatarraTextComponent = current_scene:get_entity_by_name("ChatarraTexto"):get_component("UITextComponent")
    --chatarraFullComponent = current_scene:get_entity_by_name("ChatarraCantidad100"):get_component("UIImageComponent")

    player = current_scene:get_entity_by_name("Player")
    playerScript = player:get_component("ScriptComponent")

    skill1TextCooldown:set_visible(false)
    skill2TextCooldown:set_visible(false)
    skill3TextCooldown:set_visible(false)

    life75Component:set_visible(false)

    --updateAmmoText()


end

function on_update(dt)
    
    abilityManager(dt)

    weaponManager(dt)

    update_health_display()

    chatarraTextComponent:set_text(tostring(playerScript.scrap))
end

function on_exit()
    -- Add cleanup code here
end


function abilityManager(dt)

    if playerScript.dashAvailable == false then
        skill1:set_visible(false)
        skill1TextCooldown:set_text(tostring(playerScript.dashColdownCounter))
        skill1TextCooldown:set_visible(true)
        skill1Timer = 0
        skill1Cooldown = true
    end
    
    if skill1Cooldown then
        skill1Timer = skill1Timer + dt

        if playerScript.dashAvailable == true then
            skill1:set_visible(true)
            skill1TextCooldown:set_visible(false)
            skill1Cooldown = false
        else
            local remainingTime = playerScript.dashColdown - playerScript.dashColdownCounter
            skill1TextCooldown:set_text(string.format("%.1f", remainingTime))
        end
    end

    if sawSwordScript.sawSwordAvailable == false then
        skill2:set_visible(false)
        skill2TextCooldown:set_text(tostring(sawSwordScript.coolDownCounter))
        skill2TextCooldown:set_visible(true)
        skill2Timer = 0
        skill2Cooldown = true
    end
    
    if skill2Cooldown then
        skill2Timer = skill2Timer + dt
        
        if sawSwordScript.sawSwordAvailable == true then
            skill2:set_visible(true)
            skill2TextCooldown:set_visible(false)
            skill2Cooldown = false
        else
            local remainingTime = sawSwordScript.coolDown - sawSwordScript.coolDownCounter
            skill2TextCooldown:set_text(string.format("%.1f", remainingTime))
        end
    end

    if Input.get_button(Input.action.Skill3) == Input.state.Down and not skill3Cooldown then
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

    if playerScript.actualweapon == 0 then
        arma1:set_visible(false)
        arma2:set_visible(true)
    else
        arma1:set_visible(true)
        arma2:set_visible(false)
    end
    
    
    if(playerScript.actualweapon == 0) then
        skillsArmasTextCooldown:set_text(string.format("%.1f", rifleScript.cooldownDisruptorBulletTime - rifleScript.cooldownDisruptorBulletTimeCounter))
        if((rifleScript.cooldownDisruptorBulletTime - rifleScript.cooldownDisruptorBulletTimeCounter)  <= 0) then
            skillsArmasTextCooldown:set_text("")
            
        end
    end

    if(playerScript.actualweapon == 1) then
        skillsArmasTextCooldown:set_text(string.format("%.1f", shotGunScript.timerGranade))
        if((shotGunScript.timerGranade)  <= 0) then
            skillsArmasTextCooldown:set_text("")
            
        end
    end   
    
    updateAmmoText()

end

function updateAmmoText()
    if playerScript.actualweapon == 0 then
        ammoTextComponent:set_text(tostring(rifleScript.maxAmmo - rifleScript.ammo))
        maxAmmoTextComponent:set_text(tostring(rifleScript.maxAmmo))
    else
        ammoTextComponent:set_text(tostring(shotGunScript.ammo))
        maxAmmoTextComponent:set_text(tostring(shotGunScript.maxAmmo))
    end
end

function update_health_display()
    
    if playerScript ~= nil then
        local vida = playerScript.playerHealth
        lifeFullComponent:set_size(Vector2.new(-94, -vida))
        lifeFullTransform.position.y = lifeFullStartingPosition.y - (vida/2)
        lifeTextComponent:set_text(tostring(math.floor(vida)))
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
