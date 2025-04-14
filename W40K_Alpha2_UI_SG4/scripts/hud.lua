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
    local skill1VisualCooldown
    local skill1VisualCooldownTransform
    local skill1VisualCooldownStartingPosition
    local skill1TextCooldown
    local skill1Cooldown = false
    local skill1Timer = 0
    
    local skill2
    local skill2Button    
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
        skill1VisualCooldown = current_scene:get_entity_by_name("Habilidad1Cooldown"):get_component("UIImageComponent")
        skill1TextCooldown = current_scene:get_entity_by_name("Habilidad1CooldownText"):get_component("UITextComponent")
        skill1VisualCooldownTransform = current_scene:get_entity_by_name("Habilidad1Cooldown"):get_component("TransformComponent")
        skill1VisualCooldownStartingPosition = Vector3.new(skill1VisualCooldownTransform.position.x, skill1VisualCooldownTransform.position.y, skill1VisualCooldownTransform.position.z)

        skill2 = current_scene:get_entity_by_name("Habilidad2Activable"):get_component("UIToggleComponent")
        skill2Button = current_scene:get_entity_by_name("Habilidad2Boton"):get_component("UIImageComponent")
        skill2VisualCooldown = current_scene:get_entity_by_name("Habilidad2Cooldown"):get_component("UIImageComponent")
        skill2TextCooldown = current_scene:get_entity_by_name("Habilidad2CooldownText"):get_component("UITextComponent")
        skill2VisualCooldownTransform = current_scene:get_entity_by_name("Habilidad2Cooldown"):get_component("TransformComponent")
        skill2VisualCooldownStartingPosition = Vector3.new(skill2VisualCooldownTransform.position.x, skill2VisualCooldownTransform.position.y, skill2VisualCooldownTransform.position.z)

        skill3 = current_scene:get_entity_by_name("Habilidad3Activable"):get_component("UIToggleComponent")
        skill3Button = current_scene:get_entity_by_name("Habilidad3Boton"):get_component("UIImageComponent")
        skill3VisualCooldown = current_scene:get_entity_by_name("Habilidad3Cooldown"):get_component("UIImageComponent")
        skill3TextCooldown = current_scene:get_entity_by_name("Habilidad3CooldownText"):get_component("UITextComponent")
        skill3VisualCooldownTransform = current_scene:get_entity_by_name("Habilidad3Cooldown"):get_component("TransformComponent")
        skill3VisualCooldownStartingPosition = Vector3.new(skill3VisualCooldownTransform.position.x, skill3VisualCooldownTransform.position.y, skill3VisualCooldownTransform.position.z)

        skillsArmasTextCooldown = current_scene:get_entity_by_name("HabilidadesArmasCooldown"):get_component("UITextComponent")
        skillArma1 = current_scene:get_entity_by_name("HabilidadArma1"):get_component("UIToggleComponent")
        skillArma1Cooldown = current_scene:get_entity_by_name("HabilidadArma1Cooldown"):get_component("UIImageComponent")
        skillArma2 = current_scene:get_entity_by_name("HabilidadArma2"):get_component("UIToggleComponent")
        skillArma2Cooldown = current_scene:get_entity_by_name("HabilidadArma2Cooldown"):get_component("UIImageComponent")
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
        arma1 = current_scene:get_entity_by_name("Arma1"):get_component("UIImageComponent")
        arma2 = current_scene:get_entity_by_name("Arma2"):get_component("UIImageComponent")
        maxAmmoTextComponent = current_scene:get_entity_by_name("BalasMax"):get_component("UITextComponent")
        ammoTextComponent = current_scene:get_entity_by_name("BalasRestantes"):get_component("UITextComponent")
        
        --Chatarra
        chatarraTextComponent = current_scene:get_entity_by_name("ChatarraTexto"):get_component("UITextComponent")
        chatarraBarComponent = current_scene:get_entity_by_name("ChatarraCantidad"):get_component("UIImageComponent") 
        chatarraTransform = current_scene:get_entity_by_name("ChatarraCantidad"):get_component("TransformComponent")
        chatarraStartingPosition = Vector3.new(chatarraTransform.position.x - 123, chatarraTransform.position.y, chatarraTransform.position.z)

        player = current_scene:get_entity_by_name("Player")
        playerScript = player:get_component("ScriptComponent")

        armorUpgrade = current_scene:get_entity_by_name("ArmorUpgradeSystem")
        armorUpgradeScript = armorUpgrade:get_component("ScriptComponent")

        upgradeManager = current_scene:get_entity_by_name("UpgradeManager")
        upgradeManagerScript = upgradeManager:get_component("ScriptComponent")

        skill1TextCooldown:set_visible(false)
        skill1VisualCooldown:set_visible(false)

        skill2TextCooldown:set_visible(false)
        skill2VisualCooldown:set_visible(false)
        skill2Button:set_visible(false)

        skill3Button:set_visible(false)
        skill3TextCooldown:set_visible(false)
        skill3VisualCooldown:set_visible(false)

        skillArma1Cooldown:set_visible(false)
        skillArma2Cooldown:set_visible(false)

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
            skill1TextCooldown:set_visible(true)
            skill1VisualCooldown:set_visible(true) 
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
            
            local nuevoAlto = 32.5 * porcentaje
            skill1VisualCooldown:set_size(Vector2.new(35, nuevoAlto))
            
            skill1VisualCooldownTransform.position.y = skill1VisualCooldownStartingPosition.y + ((32.5 - nuevoAlto) / 2)
            
            if playerScript.dashAvailable == true then
                skill1TextCooldown:set_visible(false)
                skill1VisualCooldown:set_visible(false)
                skill1Cooldown = false
                
                skill1VisualCooldown:set_size(Vector2.new(35, 32.5))
                skill1VisualCooldownTransform.position.y = skill1VisualCooldownStartingPosition.y
            else
                if remainingTime <= 1.1 and remainingTime > 0 then
                    skill1TextCooldown:set_text(string.format("%.1f", remainingTime))
                else
                    skill1TextCooldown:set_text(string.format("%d", math.ceil(remainingTime)))
                end
                skill1TextCooldown:set_visible(true)        
            end
        end
        
        if sawSwordScript.sawSwordAvailable == false then
            skill2TextCooldown:set_text(tostring(sawSwordScript.coolDownCounter))
            skill2TextCooldown:set_visible(true)
            skill2VisualCooldown:set_visible(true) 
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

            local nuevoAlto = 32.5 * porcentaje
            skill2VisualCooldown:set_size(Vector2.new(35, nuevoAlto))
            
            skill2VisualCooldownTransform.position.y = skill1VisualCooldownStartingPosition.y + ((32.5 - nuevoAlto) / 2)
            
            if sawSwordScript.sawSwordAvailable == true then
                skill2TextCooldown:set_visible(false)
                skill2VisualCooldown:set_visible(false) 
                skill2Cooldown = false

                skill2VisualCooldown:set_size(Vector2.new(35, 32.5))
                skill2VisualCooldownTransform.position.y = skill2VisualCooldownStartingPosition.y
            else
                if remainingTime <= 1.1 and remainingTime > 0 then
                    skill2TextCooldown:set_text(string.format("%.1f", remainingTime))
                else
                    skill2TextCooldown:set_text(string.format("%d", math.ceil(remainingTime)))
                end
                skill2TextCooldown:set_visible(true)        
            end
        end

        if armorUpgradeScript.fervorAstartesAvailable == false then
            skill3TextCooldown:set_visible(true)
            skill3VisualCooldown:set_visible(true) 
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

            local nuevoAlto = 32.5 * porcentaje
            skill3VisualCooldown:set_size(Vector2.new(35, nuevoAlto))
            
            skill3VisualCooldownTransform.position.y = skill3VisualCooldownStartingPosition.y + ((32.5 - nuevoAlto) / 2)

            if armorUpgradeScript.fervorAstartesAvailable == true then
                skill3TextCooldown:set_visible(false)
                skill3VisualCooldown:set_visible(false) 
                skill3Cooldown = false
            else
                if remainingTime <= 1.1 and remainingTime > 0 then
                    skill3TextCooldown:set_text(string.format("%.1f", remainingTime))
                else
                    skill3TextCooldown:set_text(string.format("%d", math.ceil(remainingTime)))
                end
                skill3TextCooldown:set_visible(true)      
            end
        end

        if(upgradeManagerScript:has_weapon_special()) then
            skill2:set_active(true)
            skill2Button:set_visible(true)
            skillArma1:set_active(true)
            skillArma2:set_active(true)
        end

        if(upgradeManagerScript:has_armor_special()) then
            skill3:set_active(true)
            skill3Button:set_visible(true)
        end    
    end     

    function weaponManager(dt)
        if playerScript.actualweapon == 0 then
            arma1:set_visible(true)
            arma2:set_visible(false)
            skillArma1:set_visible(true)
            skillArma2:set_visible(false)
            skillArma2Cooldown:set_visible(false)
    
            local remainingTime = rifleScript.cooldownDisruptorBulletTime - rifleScript.cooldownDisruptorBulletTimeCounter
            if remainingTime > 0 then
                if remainingTime <= 1.1 then
                    skillsArmasTextCooldown:set_text(string.format("%.1f", remainingTime))
                else
                    skillsArmasTextCooldown:set_text(string.format("%d", math.ceil(remainingTime)))
                end
                skillArma1Cooldown:set_visible(true)
                local totalCooldown = rifleScript.cooldownDisruptorBulletTime
                local porcentaje = remainingTime / totalCooldown
                if porcentaje > 1 then
                    porcentaje = 1
                end
                local nuevoAlto = 32.5 * porcentaje
                skillArma1Cooldown:set_size(Vector2.new(35, nuevoAlto))
                skillArma1VisualCooldownTransform.position.y = skillArma1VisualCooldownStartingPosition.y + ((32.5 - nuevoAlto) / 2)
            else
                skillsArmasTextCooldown:set_text("")
                skillArma1Cooldown:set_visible(false)
                skillArma1Cooldown:set_size(Vector2.new(35, 32.5))
                skillArma1VisualCooldownTransform.position.y = skillArma1VisualCooldownStartingPosition.y
            end
    
        elseif playerScript.actualweapon == 1 then
            arma1:set_visible(false)
            arma2:set_visible(true)
            skillArma1:set_visible(false)
            skillArma2:set_visible(true)
            skillArma1Cooldown:set_visible(false)
    
            local remainingTime = shotGunScript.timerGranade
            if remainingTime > 0 then
                if remainingTime <= 1.1 then
                    skillsArmasTextCooldown:set_text(string.format("%.1f", remainingTime))
                else
                    skillsArmasTextCooldown:set_text(string.format("%d", math.ceil(remainingTime)))
                end
                skillArma2Cooldown:set_visible(true)
                local totalCooldown = 12
                local porcentaje = remainingTime / totalCooldown
                if porcentaje > 1 then
                    porcentaje = 1
                end
                local nuevoAlto = 32.5 * porcentaje
                skillArma2Cooldown:set_size(Vector2.new(35, nuevoAlto))
                skillArma2VisualCooldownTransform.position.y = skillArma2VisualCooldownStartingPosition.y + ((32.5 - nuevoAlto) / 2)
            else
                skillsArmasTextCooldown:set_text("")
                skillArma2Cooldown:set_visible(false)
                skillArma2Cooldown:set_size(Vector2.new(35, 32.5))
                skillArma2VisualCooldownTransform.position.y = skillArma2VisualCooldownStartingPosition.y
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

    function update_scrap_display()
        if playerScript ~= nil then
            local chatarra = playerScript.scrapCounter
            local max_chatarra = maxChatarraDisplay
            local porcentaje = chatarra / max_chatarra

            if porcentaje > 1 then 
                porcentaje = 1 
            end
            
            local nuevoAncho = 248 * porcentaje
            
            chatarraBarComponent:set_size(Vector2.new(nuevoAncho, 30))
            
            if(chatarra <= 1000) then
                chatarraTransform.position.x = chatarraStartingPosition.x + (nuevoAncho / 2)
            end
            
            chatarraTextComponent:set_text(tostring(chatarra))
        end
    end