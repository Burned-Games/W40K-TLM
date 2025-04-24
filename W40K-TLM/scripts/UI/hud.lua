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
    local skill1VisualCooldownEntity
    local skill1VisualCooldown
    local skill1VisualCooldownTransform
    local skill1VisualCooldownStartingPosition
    local skill1TextCooldownEntity
    local skill1TextCooldown
    local skill1Cooldown = false
    local skill1Timer = 0
    
    local skill2
    local skill2ButtonEntity    
    local skill2Button
    local skill2VisualCooldownEntity
    local skill2VisualCooldown
    local skill2VisualCooldownTransform
    local skill2VisualCooldownStartingPosition
    local skill2Cooldown = false
    local skill2Timer = 0

    local skill3
    local skill3Button    
    local skill3VisualCooldown
    local skill3VisualCooldownTransform
    local skill3VisualCooldownStartingPosition
    local skill3Cooldown = false
    local skill3Timer = 0

    local skillsArmasTextCooldown
    local skillArma1
    local skillArma1Cooldown
    local skillArma2
    local skillArma2Cooldown
    local skillsArmasCooldown = false
    local skillsArmasTimer = 0
    local skillArma1VisualCooldownTransform
    local skillArma1VisualCooldownStartingPosition
    local skillArma2VisualCooldownTransform
    local skillArma2VisualCooldownStartingPosition

    local arma1
    local arma2
    local currentWeapon = 1
    local weaponSwitchCooldown = 0.2 
    local weaponSwitchTimer = 0

    local maxChatarraDisplay = 1000
    local currentChatarra = 0

    local chatarraTextComponent
    local chatarraBarComponent
    local chatarraTransform
    local chatarraStartingPosition

    local player = nil
    local playerScript = nil
    local lifeFullStartingPosition

    local rifleScript = nil
    local rifleAbilityCooldown
    local maxRifleAbilityCooldown

    local shotGunScript
    local sawSwordScript

    local armorUpgrade = nil
    local armorUpgradeScript = nil

    local upgradeManager = nil
    local upgradeManagerScript = nil

    function on_ready()
        --Vida
        lifeFullComponent = current_scene:get_entity_by_name("VidaFull"):get_component("UIImageComponent")
        lifeTextComponent = current_scene:get_entity_by_name("VidaValor"):get_component("UITextComponent")
        lifeFullTransform = current_scene:get_entity_by_name("VidaFull"):get_component("TransformComponent")
        lifeFullStartingPosition = Vector3.new(lifeFullTransform.position.x, lifeFullTransform.position.y + 49, lifeFullTransform.position.z)

        --Habilidades
        skill1 = current_scene:get_entity_by_name("Habilidad1"):get_component("UIImageComponent")
        skill1VisualCooldownEntity = current_scene:get_entity_by_name("Habilidad1Cooldown")
        skill1VisualCooldown = skill1VisualCooldownEntity:get_component("UIImageComponent")
        skill1TextCooldownEntity = current_scene:get_entity_by_name("Habilidad1CooldownText")
        skill1TextCooldown = skill1TextCooldownEntity:get_component("UITextComponent")
        skill1VisualCooldownTransform = skill1VisualCooldownEntity:get_component("TransformComponent")
        skill1VisualCooldownStartingPosition = Vector3.new(skill1VisualCooldownTransform.position.x, skill1VisualCooldownTransform.position.y, skill1VisualCooldownTransform.position.z)

        skill2 = current_scene:get_entity_by_name("Habilidad2Activable"):get_component("UIToggleComponent")
        skill2ButtonEntity = current_scene:get_entity_by_name("Habilidad2Boton")
        skill2Button = skill2ButtonEntity:get_component("UIImageComponent")
        skill2VisualCooldownEntity = current_scene:get_entity_by_name("Habilidad2Cooldown")
        skill2VisualCooldown = skill2VisualCooldownEntity:get_component("UIImageComponent")
        skill2TextCooldownEntity = current_scene:get_entity_by_name("Habilidad2CooldownText")
        skill2TextCooldown = skill2TextCooldownEntity:get_component("UITextComponent")
        skill2VisualCooldownTransform = skill2VisualCooldownEntity:get_component("TransformComponent")
        skill2VisualCooldownStartingPosition = Vector3.new(skill2VisualCooldownTransform.position.x, skill2VisualCooldownTransform.position.y, skill2VisualCooldownTransform.position.z)

        skill3 = current_scene:get_entity_by_name("Habilidad3Activable"):get_component("UIToggleComponent")
        skill3ButtonEntity = current_scene:get_entity_by_name("Habilidad3Boton")
        skill3Button = skill3ButtonEntity:get_component("UIImageComponent")
        skill3VisualCooldownEntity = current_scene:get_entity_by_name("Habilidad3Cooldown")
        skill3VisualCooldown = skill3VisualCooldownEntity:get_component("UIImageComponent")
        skill3TextCooldownEntity = current_scene:get_entity_by_name("Habilidad3CooldownText")
        skill3TextCooldown = skill3TextCooldownEntity:get_component("UITextComponent")
        skill3VisualCooldownTransform = skill3VisualCooldownEntity:get_component("TransformComponent")
        skill3VisualCooldownStartingPosition = Vector3.new(skill3VisualCooldownTransform.position.x, skill3VisualCooldownTransform.position.y, skill3VisualCooldownTransform.position.z)

        skillsArmasTextCooldownEntity = current_scene:get_entity_by_name("HabilidadesArmasCooldown")
        skillsArmasTextCooldown = skillsArmasTextCooldownEntity:get_component("UITextComponent")
        skillArma1Entity = current_scene:get_entity_by_name("HabilidadArma1")
        skillArma1 = skillArma1Entity:get_component("UIToggleComponent")
        skillArma1CooldownEntity = current_scene:get_entity_by_name("HabilidadArma1Cooldown")
        skillArma1Cooldown = skillArma1CooldownEntity:get_component("UIImageComponent")
        skillArma2Entity = current_scene:get_entity_by_name("HabilidadArma2")
        skillArma2 = skillArma2Entity:get_component("UIToggleComponent")
        skillArma2CooldownEntity = current_scene:get_entity_by_name("HabilidadArma2Cooldown")
        skillArma2Cooldown = skillArma2CooldownEntity:get_component("UIImageComponent")
        skillArma1VisualCooldownTransform = current_scene:get_entity_by_name("HabilidadArma1Cooldown"):get_component("TransformComponent")
        skillArma1VisualCooldownStartingPosition = Vector3.new(skillArma1VisualCooldownTransform.position.x, skillArma1VisualCooldownTransform.position.y, skillArma1VisualCooldownTransform.position.z)
        skillArma2VisualCooldownTransform = current_scene:get_entity_by_name("HabilidadArma2Cooldown"):get_component("TransformComponent")
        skillArma2VisualCooldownStartingPosition = Vector3.new(skillArma2VisualCooldownTransform.position.x, skillArma2VisualCooldownTransform.position.y, skillArma2VisualCooldownTransform.position.z)

        rifleScript = current_scene:get_entity_by_name("BolterManager"):get_component("ScriptComponent")
        rifleAbilityCooldown = rifleScript.cooldownDisruptorBulletTimeCounter
        maxRifleAbilityCooldown = rifleScript.cooldownDisruptorBulletTime

        shotGunScript = current_scene:get_entity_by_name("ShotgunManager"):get_component("ScriptComponent")
        sawSwordScript = current_scene:get_entity_by_name("SawSwordManager"):get_component("ScriptComponent")

        --Armas
        arma1 = current_scene:get_entity_by_name("Arma1")
        arma2 = current_scene:get_entity_by_name("Arma2")
        maxAmmoTextComponent = current_scene:get_entity_by_name("BalasMax"):get_component("UITextComponent")
        ammoTextComponent = current_scene:get_entity_by_name("BalasRestantes"):get_component("UITextComponent")
        
        --Chatarra
        chatarraTextComponent = current_scene:get_entity_by_name("ChatarraTexto"):get_component("UITextComponent")
        chatarraBar = current_scene:get_entity_by_name("ChatarraCantidad")
        chatarraBarComponent = chatarraBar:get_component("UIImageComponent") 
        chatarraTransform = chatarraBar:get_component("TransformComponent")
        chatarraStartingPosition = Vector3.new(chatarraTransform.position.x, chatarraTransform.position.y, chatarraTransform.position.z)

        player = current_scene:get_entity_by_name("Player")
        playerScript = player:get_component("ScriptComponent")

        --armorUpgrade = current_scene:get_entity_by_name("ArmorUpgradeSystem")
        --armorUpgradeScript = armorUpgrade:get_component("ScriptComponent")

        upgradeManager = current_scene:get_entity_by_name("UpgradeManager")
        upgradeManagerScript = upgradeManager:get_component("ScriptComponent")

        skill1TextCooldownEntity:set_active(false)
        skill1VisualCooldownEntity:set_active(false)

        skill2TextCooldownEntity:set_active(false)
        skill2VisualCooldownEntity:set_active(false)

        skill3TextCooldownEntity:set_active(false)
        skill3VisualCooldownEntity:set_active(false)

        skillArma1CooldownEntity:set_active(false)
        skillArma2CooldownEntity:set_active(false)
        skillsArmasTextCooldownEntity:set_active(false)

        skill2.value = true
        skill3.value = true

        skillArm1.value = true
        skillArm2.value = true

    end

    function on_update(dt)
        
        abilityManager(dt)

        weaponManager(dt)

        update_health_display()

        update_scrap_display() 
    end

    function on_exit()
        -- Add cleanup code here
    end


        function abilityManager(dt)
        
            if playerScript.dashAvailable == false then
                skill1TextCooldown:set_text(tostring(playerScript.dashColdownCounter))
                skill1TextCooldownEntity:set_active(true)
                skill1VisualCooldownEntity:set_active(true)
                skill1Timer = 0
                skill1Cooldown = true
            end
            
            if skill1Cooldown then 
                skill1Timer = skill1Timer + dt 
                local remainingTime = playerScript.dashColdown - playerScript.dashColdownCounter 
                local totalCooldown = playerScript.dashColdown
                
                local porcentaje = remainingTime / totalCooldown
                if porcentaje > 1 then 
                    porcentaje = 1 
                end
            
                local cooldownRect = Vector4.new(0, 0, 1, porcentaje)
                skill1VisualCooldown:set_rect(cooldownRect)
                
                if playerScript.dashAvailable == true then
                    skill1TextCooldownEntity:set_active(false)
                    skill1VisualCooldownEntity:set_active(false)
                    skill1Cooldown = false
                    
                    -- Reset the rect and color when cooldown is complete
                    skill1VisualCooldown:set_rect(Vector4.new(0, 0, 1, 1))
                    skill1VisualCooldown:set_color(Vector4.new(1, 1, 1, 1))
                else
                    if remainingTime <= 1.1 and remainingTime > 0 then
                        skill1TextCooldown:set_text(string.format("%.1f", remainingTime))
                    else
                        skill1TextCooldown:set_text(string.format("%d", math.ceil(remainingTime)))
                    end
                    skill1TextCooldownEntity:set_active(true)
                end
            end
            
            
            if sawSwordScript.sawSwordAvailable == false then
                skill2TextCooldown:set_text(tostring(sawSwordScript.coolDownCounter))
                skill2TextCooldownEntity:set_active(true)
                skill2VisualCooldownEntity:set_active(true) 
                skill2Timer = 0
                skill2Cooldown = true
            end
            
            if skill2Cooldown then
                skill2Timer = skill2Timer + dt
                local remainingTime = sawSwordScript.coolDown - sawSwordScript.coolDownCounter
                local totalCooldown = sawSwordScript.coolDown
        
                local porcentaje = remainingTime / totalCooldown
                if porcentaje > 1 then 
                    porcentaje = 1 
                end
        
                local cooldownRect = Vector4.new(0, 0, 1, porcentaje)
                skill2VisualCooldown:set_rect(cooldownRect)

                if sawSwordScript.sawSwordAvailable == true then
                    skill2TextCooldownEntity:set_active(false)
                    skill2VisualCooldownEntity:set_active(false) 
                    skill2Cooldown = false
        
                    skill2VisualCooldown:set_rect(Vector4.new(0, 0, 1, 1))
                else
                    if remainingTime <= 1.1 and remainingTime > 0 then
                        skill2TextCooldown:set_text(string.format("%.1f", remainingTime))
                    else
                        skill2TextCooldown:set_text(string.format("%d", math.ceil(remainingTime)))
                    end
                    skill2TextCooldownEntity:set_active(true)        
                end
            end
        
    
        --[[if armorUpgradeScript.fervorAstartesAvailable == false then
            skill3TextCooldownEntity:set_active(true)
            skill3VisualCooldownEntity:set_active(true) 
            skill3Timer = 0
            skill3Cooldown = true
        end
        
        if skill3Cooldown then
            skill3Timer = skill3Timer + dt
            local remainingTime = armorUpgradeScript.fervorAstartesCooldown
            local totalCooldown = 25
    
            local porcentaje = remainingTime / totalCooldown
            if porcentaje > 1 then 
                porcentaje = 1 
            end
    
            local alpha = porcentaje
            alpha = math.max(0, math.min(1, alpha))
            
            skill3VisualCooldown:set_color(Vector4.new(1, 1, 1, alpha))
    
            if armorUpgradeScript.fervorAstartesAvailable == true then
                skill3TextCooldownEntity:set_active(false)
                skill3VisualCooldownEntity:set_active(false) 
                skill3Cooldown = false
                
                skill3VisualCooldown:set_color(Vector4.new(1, 1, 1, 1))
            else
                if remainingTime <= 1.1 and remainingTime > 0 then
                    skill3TextCooldown:set_text(string.format("%.1f", remainingTime))
                else
                    skill3TextCooldown:set_text(string.format("%d", math.ceil(remainingTime)))
                end
                skill3TextCooldownEntity:set_active(true)      
            end
        end
        ]]--
    
    end     
    
    function weaponManager(dt)
        if weaponSwitchTimer > 0 then
            weaponSwitchTimer = weaponSwitchTimer - dt
        end

        skillArma1.value = true
        skillArma2.value = true
    
        if playerScript.actualweapon == 0 then
            arma1:set_active(true)
            arma2:set_active(false)
            
            skillArma1Entity:set_active(true)
            skillArma2Entity:set_active(false)
            
            skillArma2CooldownEntity:set_active(false)
    
            local remainingTime = rifleScript.cooldownDisruptorBulletTime - rifleScript.cooldownDisruptorBulletTimeCounter
            if remainingTime > 0 then
                if remainingTime <= 1.1 then
                    skillsArmasTextCooldown:set_text(string.format("%.1f", remainingTime))
                else
                    skillsArmasTextCooldown:set_text(string.format("%d", math.ceil(remainingTime)))
                end
                skillsArmasTextCooldownEntity:set_active(true)
                skillArma1CooldownEntity:set_active(true)
                
                local totalCooldown = rifleScript.cooldownDisruptorBulletTime
                local porcentaje = remainingTime / totalCooldown
                if porcentaje > 1 then
                    porcentaje = 1
                end
                
                local cooldownRect = Vector4.new(0, 0, 1, porcentaje)
                skillArma1Cooldown:set_rect(cooldownRect)
            else
                skillsArmasTextCooldown:set_text("")
                skillsArmasTextCooldownEntity:set_active(false)
                skillArma1CooldownEntity:set_active(false)
            end
    
        elseif playerScript.actualweapon == 1 then
            arma1:set_active(false)
            arma2:set_active(true)
            
            skillArma1Entity:set_active(false)
            skillArma2Entity:set_active(true)
            
            skillArma1CooldownEntity:set_active(false)
    
            local remainingTime = shotGunScript.timerGranade
            if remainingTime > 0 then
                if remainingTime <= 1.1 then
                    skillsArmasTextCooldown:set_text(string.format("%.1f", remainingTime))
                else
                    skillsArmasTextCooldown:set_text(string.format("%d", math.ceil(remainingTime)))
                end
                skillsArmasTextCooldownEntity:set_active(true)
                skillArma2CooldownEntity:set_active(true)
                
                local totalCooldown = shotGunScript.granadeCooldown
                local porcentaje = remainingTime / totalCooldown
                if porcentaje > 1 then
                    porcentaje = 1
                end
                
                local cooldownRect = Vector4.new(0, 0, 1, porcentaje)
                skillArma2Cooldown:set_rect(cooldownRect)
            else
                skillsArmasTextCooldown:set_text("")
                skillsArmasTextCooldownEntity:set_active(false)
                skillArma2CooldownEntity:set_active(false)
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
            local vida = playerScript.health
            local maxHealth = 100  
            
            local healthPercentage = vida / maxHealth
            
            lifeTextComponent:set_text(tostring(math.floor(vida)))
            
            local cropPercentage = 1 - healthPercentage
            
            local x = 0
            local y = 0
            local width = 1
            local height = 1
            
            local newRect = Vector4.new(x, y, width, height * healthPercentage)
            lifeFullComponent:set_rect(newRect)
            
        end
    end
    
    function update_scrap_display()
        if playerScript ~= nil then
            local chatarra = playerScript.scrapCounter
            local max_chatarra = maxChatarraDisplay
            local percentage = chatarra / max_chatarra
            percentage = math.max(0, math.min(1, percentage))
            
            chatarraTextComponent:set_text(tostring(chatarra))
            
            local newRect = Vector4.new(0, 0, percentage, 1)
            chatarraBarComponent:set_rect(newRect)
            chatarraTextComponent:set_color(Vector4.new(1, 1, 1, 1))
        end
    end