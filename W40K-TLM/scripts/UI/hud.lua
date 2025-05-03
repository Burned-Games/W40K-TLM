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
    local skillsArmasBoton
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

    local quemadoEntity = nil
    local quemado = nil
    local sangradoEntity = nil
    local sangrado = nil
    local ralentizadoEntity = nil
    local ralentizado = nil
    local aturdidoEntity = nil
    local aturdido = nil
    local silenciadoEntity = nil
    local silenciado = nil

    proteccionEntity = nil
    local proteccion = nil
    recargaEntity = nil
    local recarga = nil
    velocidadAtaqueEntity = nil
    local velocidadAtaque = nil

    local cantidadConsumible = nil

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

        skill2 = current_scene:get_entity_by_name("Habilidad2Activable"):get_component("UIToggleComponent")
        skill2ButtonEntity = current_scene:get_entity_by_name("Habilidad2Boton")
        skill2Button = skill2ButtonEntity:get_component("UIImageComponent")
        skill2VisualCooldownEntity = current_scene:get_entity_by_name("Habilidad2Cooldown")
        skill2VisualCooldown = skill2VisualCooldownEntity:get_component("UIImageComponent")
        skill2TextCooldownEntity = current_scene:get_entity_by_name("Habilidad2CooldownText")
        skill2TextCooldown = skill2TextCooldownEntity:get_component("UITextComponent")

        skill3 = current_scene:get_entity_by_name("Habilidad3Activable"):get_component("UIToggleComponent")
        skill3ButtonEntity = current_scene:get_entity_by_name("Habilidad3Boton")
        skill3Button = skill3ButtonEntity:get_component("UIImageComponent")
        skill3VisualCooldownEntity = current_scene:get_entity_by_name("Habilidad3Cooldown")
        skill3VisualCooldown = skill3VisualCooldownEntity:get_component("UIImageComponent")
        skill3TextCooldownEntity = current_scene:get_entity_by_name("Habilidad3CooldownText")
        skill3TextCooldown = skill3TextCooldownEntity:get_component("UITextComponent")

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
        skillsArmasBoton = current_scene:get_entity_by_name("HabilidadesArmasBoton")

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

        player = current_scene:get_entity_by_name("Player")
        playerScript = player:get_component("ScriptComponent")

        armorUpgrade = current_scene:get_entity_by_name("ArmorUpgradeSystem")
        armorUpgradeScript = armorUpgrade:get_component("ScriptComponent")

        upgradeManager = current_scene:get_entity_by_name("UpgradeManager"):get_component("ScriptComponent")

        --Debuffs
        quemadoEntity = current_scene:get_entity_by_name("Quemado")
        quemado = quemadoEntity:get_component("UIImageComponent")
        sangradoEntity = current_scene:get_entity_by_name("Sangrado")
        sangrado = sangradoEntity:get_component("UIImageComponent")
        ralentizadoEntity = current_scene:get_entity_by_name("Ralentizado")
        ralentizado = ralentizadoEntity:get_component("UIImageComponent")
        aturdidoEntity = current_scene:get_entity_by_name("Aturdido")
        aturdido = aturdidoEntity:get_component("UIImageComponent")
        silenciadoEntity = current_scene:get_entity_by_name("Silenciado")
        silenciado = silenciadoEntity:get_component("UIImageComponent")
        
        --Buffs
        proteccionEntity = current_scene:get_entity_by_name("Proteccion")
        proteccion = proteccionEntity:get_component("UIImageComponent")
        recargaEntity = current_scene:get_entity_by_name("Recarga")
        recarga = recargaEntity:get_component("UIImageComponent")
        velocidadAtaqueEntity = current_scene:get_entity_by_name("VelocidadAtaque")
        velocidadAtaque = velocidadAtaqueEntity:get_component("UIImageComponent")

        cantidadConsumible = current_scene:get_entity_by_name("ConsumibleCantidad"):get_component("UITextComponent")
        
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
        skill3.value = upgradeManager:has_armor_special()

        skillArma1.value = upgradeManager:has_weapon_special()
        skillArma2.value = upgradeManager:has_weapon_special() 

        quemadoEntity:set_active(false)
        sangradoEntity:set_active(false)
        ralentizadoEntity:set_active(false)
        aturdidoEntity:set_active(false)
        silenciadoEntity:set_active(false)

        proteccionEntity:set_active(false)
        recargaEntity:set_active(false)
        velocidadAtaqueEntity:set_active(false)

    end


    function on_update(dt)
        
        abilityManager(dt)

        weaponManager(dt)

        update_health_display()

        update_scrap_display() 

        buff_debuff_manager()

        cantidadConsumible:set_text(string.format("%d", math.ceil(playerScript.StimsCounter)))

    end

    function on_exit()
        -- Add cleanup code here
    end


    function abilityManager(dt)
        -- Skill 1 (Dash)
        local dashRemainingTime = playerScript.dashColdown - playerScript.dashColdownCounter
        if dashRemainingTime > 0 and not playerScript.dashAvailable then
            -- Mostrar cooldown
            skill1Timer = skill1Timer + dt 
            
            local totalCooldown = playerScript.dashColdown
            local porcentaje = dashRemainingTime / totalCooldown
            if porcentaje > 1 then 
                porcentaje = 1 
            end
        
            local cooldownRect = Vector4.new(0, 0, 1, porcentaje)
            skill1VisualCooldown:set_rect(cooldownRect)
            
            if dashRemainingTime <= 1.1 and dashRemainingTime > 0 then
                skill1TextCooldown:set_text(string.format("%.1f", dashRemainingTime))
            else
                skill1TextCooldown:set_text(string.format("%d", math.ceil(dashRemainingTime)))
            end
            
            skill1TextCooldownEntity:set_active(true)
            skill1VisualCooldownEntity:set_active(true)
        else
            -- Ocultar cooldown
            skill1TextCooldownEntity:set_active(false)
            skill1VisualCooldownEntity:set_active(false)
            -- Reset de rect y color
            skill1VisualCooldown:set_rect(Vector4.new(0, 0, 1, 1))
        end
        
        -- Skill 2 (Saw Sword)
        local sawSwordRemainingTime = sawSwordScript.coolDown - sawSwordScript.coolDownCounter
        if sawSwordRemainingTime > 0 and not sawSwordScript.sawSwordAvailable then
            -- Mostrar cooldown
            skill2Timer = skill2Timer + dt
            
            local totalCooldown = sawSwordScript.coolDown
            local porcentaje = sawSwordRemainingTime / totalCooldown
            if porcentaje > 1 then 
                porcentaje = 1 
            end
    
            local cooldownRect = Vector4.new(0, 0, 1, porcentaje)
            skill2VisualCooldown:set_rect(cooldownRect)
            
            if sawSwordRemainingTime <= 1.1 and sawSwordRemainingTime > 0 then
                skill2TextCooldown:set_text(string.format("%.1f", sawSwordRemainingTime))
            else
                skill2TextCooldown:set_text(string.format("%d", math.ceil(sawSwordRemainingTime)))
            end
            
            skill2TextCooldownEntity:set_active(true)
            skill2VisualCooldownEntity:set_active(true)
        else
            -- Ocultar cooldown
            skill2TextCooldownEntity:set_active(false)
            skill2VisualCooldownEntity:set_active(false)
            skill2VisualCooldown:set_rect(Vector4.new(0, 0, 1, 1))
        end
        
        -- Skill 3 (Fervor Astartes)
        skill3.value = upgradeManager:has_armor_special() 
        skill3ButtonEntity:set_active(skill3.value)
        
        local fervorRemainingTime = armorUpgradeScript.fervorAstartesCooldown
        if fervorRemainingTime > 0 and not armorUpgradeScript.fervorAstartesAvailable then
            -- Mostrar cooldown
            skill3Timer = skill3Timer + dt
            
            local totalCooldown = 25
            local porcentaje = fervorRemainingTime / totalCooldown
            if porcentaje > 1 then 
                porcentaje = 1 
            end
    
            local cooldownRect = Vector4.new(0, 0, 1, porcentaje)
            skill3VisualCooldown:set_rect(cooldownRect)
            
            if fervorRemainingTime <= 1.1 and fervorRemainingTime > 0 then
                skill3TextCooldown:set_text(string.format("%.1f", fervorRemainingTime))
            else
                skill3TextCooldown:set_text(string.format("%d", math.ceil(fervorRemainingTime)))
            end
            
            skill3TextCooldownEntity:set_active(true)
            skill3VisualCooldownEntity:set_active(true)
        else
            -- Ocultar cooldown
            skill3TextCooldownEntity:set_active(false)
            skill3VisualCooldownEntity:set_active(false)
            skill3VisualCooldown:set_rect(Vector4.new(0, 0, 1, 1))
        end
    end
    
    function weaponManager(dt)
        if weaponSwitchTimer > 0 then
            weaponSwitchTimer = weaponSwitchTimer - dt
        end
    
        local hasWeaponSpecial = upgradeManager:has_weapon_special()
        skillArma1.value = hasWeaponSpecial
        skillArma2.value = hasWeaponSpecial
        
        skillsArmasBoton:set_active(hasWeaponSpecial)
    
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
        
            local remainingTime = shotGunScript.granadeCooldown - shotGunScript.timerGranade
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
        else
            ammoTextComponent:set_text(tostring(shotGunScript.ammo))
        end
    end

    function update_health_display()
        if playerScript ~= nil then
            local vida = playerScript.health
            local maxHealth = playerScript.maxHealth  
            
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
            chatarraTextComponent:set_text(tostring(chatarra))
        end
    end

    function buff_debuff_manager()
        if playerScript.isBleeding then
            sangradoEntity:set_active(true)
        else
            sangradoEntity:set_active(false)
        end
        
        if playerScript.isStunned then
            aturdidoEntity:set_active(true)
        else
            aturdidoEntity:set_active(false)
        end

        if playerScript.isNeuralInhibitioning then
            ralentizadoEntity:set_active(true)
        else
            ralentizadoEntity:set_active(false)
        end

        quemadoEntity:set_active(false)
        silenciadoEntity:set_active(false)
    end
