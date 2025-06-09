ammoTextComponent = nil
local maxAmmoTextComponent = nil

local lifeFullComponent
local lifeTextComponent
local originalLifeColor = nil

local skill1Entity
local skill1VisualCooldownEntity
local skill1VisualCooldown
local skill1TextCooldownEntity
local skill1TextCooldown
local skill1Timer = 0
local dashScaling = false
local dashScaleTimer = 0
local dashAvailableLastFrame = true

local skill2
local skill2Entity
local skill2VisualCooldownEntity
local skill2VisualCooldown
local skill2Timer = 0
local meleeCurrentScale = 1.0
local meleeScaleTimer = 0
local meleeAvailableLastFrame = true

local skill3
local skill3Entity
local skill3VisualCooldown
local fervorCurrentScale = 1.0
local fervorScaling = false
local fervorScaleTimer = 0
local fervorAvailableLastFrame = true

local skillsArmasTextCooldown
local skillArma1Entity
local skillArma1
local skillArma1Cooldown
local skillArma2Entity
local skillArma2
local skillArma2Cooldown
local skillsArmasBoton
local bolterCurrentScale = 1.0
local bolterScaling = false
local bolterScaleTimer = 0
local bolterAvailableLastFrame = true
local grenadeCurrentScale = 1.0
local grenadeScaling = false
local grenadeScaleTimer = 0
local grenadeAvailableLastFrame = true

arma1 = nil
arma1Texture = nil
arma2 = nil
arma2Texture = nil
local weaponChangerToggle = nil
local weaponSwitchTimer = 0


local chatarraTextComponent

local player = nil
local playerScript = nil

local rifleScript = nil

local shotGunScript
local sawSwordScript

local armorUpgrade = nil
local armorUpgradeScript = nil

local upgradeManager = nil

local quemadoEntity = nil
local sangradoEntity = nil
local ralentizadoEntity = nil
local aturdidoEntity = nil
local silenciadoEntity = nil

proteccionEntity = nil
recargaEntity = nil
velocidadAtaqueEntity = nil

local cantidadConsumible = nil

local dammageFeedback = nil
local dammageFeedbackTexture = nil
local dammageFadeOutActive = false
local dammageFadeOutAlpha = 1.0
local dammageFadeOutSpeed = 2.0
local bleedingFeedback = nil
local bleedingFeedbackTexture = nil
local wasHitted = false

function on_ready()

    --Vida
    lifeFullComponent = current_scene:get_entity_by_name("VidaFull"):get_component("UIImageComponent")
    lifeTextComponent = current_scene:get_entity_by_name("VidaValor"):get_component("UITextComponent")

    --Habilidades
    skill1Entity = current_scene:get_entity_by_name("Habilidad1")
    skill1VisualCooldownEntity = current_scene:get_entity_by_name("Habilidad1Cooldown")
    skill1VisualCooldown = skill1VisualCooldownEntity:get_component("UIImageComponent")
    skill1TextCooldownEntity = current_scene:get_entity_by_name("Habilidad1CooldownText")
    skill1TextCooldown = skill1TextCooldownEntity:get_component("UITextComponent")
    skill1Button = current_scene:get_entity_by_name("Habilidad1Boton")

    skill2Entity = current_scene:get_entity_by_name("Habilidad2Activable")
    skill2 = skill2Entity:get_component("UIToggleComponent")
    skill2ButtonEntity = current_scene:get_entity_by_name("Habilidad2Boton")
    skill2VisualCooldownEntity = current_scene:get_entity_by_name("Habilidad2Cooldown")
    skill2VisualCooldown = skill2VisualCooldownEntity:get_component("UIImageComponent")
    skill2TextCooldownEntity = current_scene:get_entity_by_name("Habilidad2CooldownText")
    skill2TextCooldown = skill2TextCooldownEntity:get_component("UITextComponent")

    skill3Entity = current_scene:get_entity_by_name("Habilidad3Activable")
    skill3 = skill3Entity:get_component("UIToggleComponent")
    skill3ButtonEntity = current_scene:get_entity_by_name("Habilidad3Boton")
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

    --Armas
    arma1 = current_scene:get_entity_by_name("Arma1")
    arma1Texture = arma1:get_component("UIImageComponent")
    arma2 = current_scene:get_entity_by_name("Arma2")
    arma2Texture = arma2:get_component("UIImageComponent")
    ammoTextComponent = current_scene:get_entity_by_name("BalasRestantes"):get_component("UITextComponent")
    maxAmmoTextComponent = current_scene:get_entity_by_name("BalasMax"):get_component("UITextComponent")
    weaponChangerToggle = current_scene:get_entity_by_name("BotonCambioArmas"):get_component("UIToggleComponent")

    rifleScript = current_scene:get_entity_by_name("BolterManager"):get_component("ScriptComponent")

    shotGunScript = current_scene:get_entity_by_name("ShotgunManager"):get_component("ScriptComponent")
    sawSwordScript = current_scene:get_entity_by_name("SawSwordManager"):get_component("ScriptComponent")

     --Debuffs
    quemadoEntity = current_scene:get_entity_by_name("Quemado")
    sangradoEntity = current_scene:get_entity_by_name("Sangrado")
    ralentizadoEntity = current_scene:get_entity_by_name("Ralentizado")
    aturdidoEntity = current_scene:get_entity_by_name("Aturdido")
    silenciadoEntity = current_scene:get_entity_by_name("Silenciado")
    
    --Buffs
    proteccionEntity = current_scene:get_entity_by_name("Proteccion")
    recargaEntity = current_scene:get_entity_by_name("Recarga")
    velocidadAtaqueEntity = current_scene:get_entity_by_name("VelocidadAtaque")
    
    bleedingFeedback = current_scene:get_entity_by_name("SangradoUI")
    bleedingFeedbackTexture = bleedingFeedback:get_component("UIImageComponent")

    dammageFeedback = current_scene:get_entity_by_name("DammageUI")
    dammageFeedbackTexture = dammageFeedback:get_component("UIImageComponent")

    cantidadConsumible = current_scene:get_entity_by_name("ConsumibleCantidad"):get_component("UITextComponent")
    

    --Chatarra
    local chatarraTextEntity = current_scene:get_entity_by_name("ChatarraTexto")
    if chatarraTextEntity:is_valid() then
        chatarraTextComponent = chatarraTextEntity:get_component("UITextComponent")
    end

    player = current_scene:get_entity_by_name("Player")
    playerScript = player:get_component("ScriptComponent")

    armorUpgrade = current_scene:get_entity_by_name("ArmorUpgradeSystem")
    armorUpgradeScript = armorUpgrade:get_component("ScriptComponent")

    upgradeManager = current_scene:get_entity_by_name("UpgradeManager"):get_component("ScriptComponent")

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

    originalLifeColor = lifeFullComponent:get_color()

    update_scrap_display() 
end


function on_update(dt)
    
    abilityManager(dt)

    weaponManager(dt)
   
    if playerScript.isHitted or playerScript.isHealing or playerScript.isSwordHealing then
        update_health_display()
    end

    buff_debuff_manager(dt)

end

function on_exit()
    -- Add cleanup code here
end


function abilityManager(dt)
    -- Skill 1 (Dash)
    local maxScale = 1.1
    local originalScale = 1.0
    local expandDuration = 0.15
    local contractDuration = 0.15
    local totalAnimationTime = expandDuration + contractDuration

    if dashCurrentScale == nil then
        dashCurrentScale = originalScale
    end

    if dashScaling == nil then
        dashScaling = false
    end

    if dashScaleTimer == nil then
        dashScaleTimer = 0
    end

    local dashJustBecameAvailable = not dashAvailableLastFrame and playerScript.dashAvailable

    if dashJustBecameAvailable then
        dashScaling = true
        dashScaleTimer = 0
    end

    if dashScaling then
        playerScript.dashAvailable = false

        dashScaleTimer = dashScaleTimer + dt

        local desiredScale = originalScale

        if dashScaleTimer <= expandDuration then
            -- Expansión
            local expandProgress = dashScaleTimer / expandDuration
            desiredScale = originalScale + (maxScale - originalScale) * expandProgress

        elseif dashScaleTimer <= totalAnimationTime then
            -- Contracción
            local shrinkProgress = (dashScaleTimer - expandDuration) / contractDuration
            desiredScale = maxScale - (maxScale - originalScale) * shrinkProgress
                
        else
            dashScaling = false
            desiredScale = originalScale
                
            playerScript.dashAvailable = true
        end

        local relativeScale = desiredScale / dashCurrentScale
        scale_ui_element(skill1Entity, relativeScale)
        dashCurrentScale = desiredScale
    end

    -- Mostrar cooldown
    local dashRemainingTime = playerScript.dashColdown - playerScript.dashColdownCounter
    if dashRemainingTime > 0 and not playerScript.dashAvailable and not dashScaling then
        skill1Timer = skill1Timer + dt
        
        local totalCooldown = playerScript.dashColdown
        local porcentaje = dashRemainingTime / totalCooldown
        if porcentaje > 1 then porcentaje = 1 end

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
        skill1TextCooldownEntity:set_active(false)
        skill1VisualCooldownEntity:set_active(false)
        skill1VisualCooldown:set_rect(Vector4.new(0, 0, 1, 1))
    end

    dashAvailableLastFrame = playerScript.dashAvailable

    -- Skill 2 (Saw Sword)
    if meleeCurrentScale == nil then
        meleeCurrentScale = originalScale
    end

    if meleScaling == nil then
        meleScaling = false
    end

    if meleeScaleTimer == nil then
        meleeScaleTimer = 0
    end

    local meleeJustBecameAvailable = not meleeAvailableLastFrame and sawSwordScript.sawSwordAvailable

    if meleeJustBecameAvailable then
        meleScaling = true
        meleeScaleTimer = 0
    end

    if meleScaling then
        --skill2:set_color(Vector4.new(0.952, 1, 0.258, 1))
        sawSwordScript.sawSwordAvailable = false

        meleeScaleTimer = meleeScaleTimer + dt

        local desiredScale = originalScale

        if meleeScaleTimer <= expandDuration then
            -- Expansión
            local expandProgress = meleeScaleTimer / expandDuration
            desiredScale = originalScale + (maxScale - originalScale) * expandProgress

        elseif meleeScaleTimer <= totalAnimationTime then
            -- Contracción
            local shrinkProgress = (meleeScaleTimer - expandDuration) / contractDuration
            desiredScale = maxScale - (maxScale - originalScale) * shrinkProgress
                
        else
            meleScaling = false
            desiredScale = originalScale
            --skill2:set_color(Vector4.new(1, 1, 1, 1))
                
            sawSwordScript.sawSwordAvailable = true
        end

        local relativeScale = desiredScale / meleeCurrentScale
        scale_ui_element(skill2Entity, relativeScale)
        meleeCurrentScale = desiredScale
    end

    local sawSwordRemainingTime = sawSwordScript.coolDown - sawSwordScript.coolDownCounter
    if sawSwordRemainingTime > 0 and not sawSwordScript.sawSwordAvailable and not meleScaling then
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
    
    meleeAvailableLastFrame = sawSwordScript.sawSwordAvailable

   -- Skill 3 (Fervor Astartes)
    if fervorCurrentScale == nil then
        fervorCurrentScale = originalScale
    end
    if fervorScaling == nil then
        fervorScaling = false
    end
    if fervorScaleTimer == nil then
        fervorScaleTimer = 0
    end

    -- Detectar si acaba de estar disponible
    local currentFervorAvailable = armorUpgradeScript.fervorAstartesAvailable or false
    local fervorJustBecameAvailable = not fervorAvailableLastFrame and currentFervorAvailable

    if fervorJustBecameAvailable then
        fervorScaling = true
        fervorScaleTimer = 0
    end

    if fervorScaling then
        --skill3:set_color(Vector4.new(0.952, 1, 0.258, 1)) 
        armorUpgradeScript.fervorAstartesAvailable = false

        fervorScaleTimer = fervorScaleTimer + dt
        local desiredScale = originalScale

        if fervorScaleTimer <= expandDuration then
            desiredScale = originalScale + (maxScale - originalScale) * (fervorScaleTimer / expandDuration)
        elseif fervorScaleTimer <= totalAnimationTime then
            desiredScale = maxScale - (maxScale - originalScale) * ((fervorScaleTimer - expandDuration) / contractDuration)
        else
            fervorScaling = false
            desiredScale = originalScale
            --skill3:set_color(Vector4.new(1, 1, 1, 1))
            armorUpgradeScript.fervorAstartesAvailable = true
        end

        local relativeScale = desiredScale / fervorCurrentScale
        scale_ui_element(skill3Entity, relativeScale)
        fervorCurrentScale = desiredScale
    end

    skill3.value = upgradeManager:has_armor_special()
    skill3ButtonEntity:set_active(skill3.value)

    -- Mostrar Cooldown
    local fervorRemainingTime = armorUpgradeScript.fervorAstartesCooldown
    if fervorRemainingTime > 0 and not armorUpgradeScript.fervorAstartesAvailable and not fervorScaling then
        local totalCooldown = 25
        local porcentaje = fervorRemainingTime / totalCooldown
        if porcentaje > 1 then porcentaje = 1 end
        skill3VisualCooldown:set_rect(Vector4.new(0, 0, 1, porcentaje))
        
        if fervorRemainingTime <= 1.1 and fervorRemainingTime > 0 then
            skill3TextCooldown:set_text(string.format("%.1f", fervorRemainingTime))
        else
            skill3TextCooldown:set_text(string.format("%d", math.ceil(fervorRemainingTime)))
        end
        
        skill3TextCooldownEntity:set_active(true)
        skill3VisualCooldownEntity:set_active(true)
    else
        skill3TextCooldownEntity:set_active(false)
        skill3VisualCooldownEntity:set_active(false)
        skill3VisualCooldown:set_rect(Vector4.new(0, 0, 1, 1))
    end

    -- Guardar estado anterior para comparación futura
    fervorAvailableLastFrame = currentFervorAvailable
end

function weaponManager(dt)
    if weaponSwitchTimer > 0 then
        weaponSwitchTimer = weaponSwitchTimer - dt
    end

    local hasWeaponSpecial = upgradeManager:has_weapon_special()
    skillArma1.value = hasWeaponSpecial
    skillArma2.value = hasWeaponSpecial
    
    skillsArmasBoton:set_active(hasWeaponSpecial)

    local maxScale = 1.1
    local originalScale = 1.0
    local expandDuration = 0.15
    local contractDuration = 0.15
    local totalAnimationTime = expandDuration + contractDuration

    if playerScript.actualweapon == 0 then
        arma1:set_active(true)
        arma2:set_active(false)
        maxAmmoTextComponent:set_text(tostring(rifleScript.maxAmmo))
        weaponChangerToggle.value = false
        
        skillArma1Entity:set_active(true)
        skillArma2Entity:set_active(false)
        
        skillArma2CooldownEntity:set_active(false)

        if bolterCurrentScale == nil then
            bolterCurrentScale = originalScale
        end

        if bolterScaling == nil then
            bolterScaling = false
        end

        if bolterScaleTimer == nil then
            bolterScaleTimer = 0
        end

        local bolterRemainingTime = rifleScript.cooldownDisruptorBulletTime - rifleScript.cooldownDisruptorBulletTimeCounter
        local bolterCurrentlyAvailable = bolterRemainingTime <= 0
        local bolterJustBecameAvailable = not bolterAvailableLastFrame and bolterCurrentlyAvailable

        if bolterJustBecameAvailable then
            bolterScaling = true
            bolterScaleTimer = 0
        end

        -- Animación de escala del bolter
        if bolterScaling then

            bolterScaleTimer = bolterScaleTimer + dt

            local desiredScale = originalScale

            if bolterScaleTimer <= expandDuration then
                -- Expansión
                local expandProgress = bolterScaleTimer / expandDuration
                desiredScale = originalScale + (maxScale - originalScale) * expandProgress

            elseif bolterScaleTimer <= totalAnimationTime then
                -- Contracción
                local shrinkProgress = (bolterScaleTimer - expandDuration) / contractDuration
                desiredScale = maxScale - (maxScale - originalScale) * shrinkProgress
                    
            else
                bolterScaling = false
                desiredScale = originalScale
            end

            local relativeScale = desiredScale / bolterCurrentScale
            scale_ui_element(skillArma1Entity, relativeScale) 
            bolterCurrentScale = desiredScale
        end

        bolterAvailableLastFrame = bolterCurrentlyAvailable

        -- Mostrar cooldown del bolter
        local remainingTime = rifleScript.cooldownDisruptorBulletTime - rifleScript.cooldownDisruptorBulletTimeCounter
        if remainingTime > 0 and not bolterScaling then 
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
        arma1:set_active(true)
        arma2:set_active(false)
        maxAmmoTextComponent:set_text(tostring(rifleScript.maxAmmo))
        weaponChangerToggle.value = false
        
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
        maxAmmoTextComponent:set_text(shotGunScript.maxAmmo)
        weaponChangerToggle.value = true
        
        skillArma1Entity:set_active(false)
        skillArma2Entity:set_active(true)
        
        skillArma1CooldownEntity:set_active(false)

        if grenadeCurrentScale == nil then
            grenadeCurrentScale = originalScale
        end

        if grenadeScaling == nil then
            grenadeScaling = false
        end

        if grenadeScaleTimer == nil then
            grenadeScaleTimer = 0
        end

        local grenadeRemainingTime = shotGunScript.granadeCooldown - shotGunScript.timerGranade
        local grenadeCurrentlyAvailable = grenadeRemainingTime <= 0
        local grenadeJustBecameAvailable = not grenadeAvailableLastFrame and grenadeCurrentlyAvailable

        if grenadeJustBecameAvailable then
            grenadeScaling = true
            grenadeScaleTimer = 0
        end

        -- Animación de escala de la granada
        if grenadeScaling then
            grenadeScaleTimer = grenadeScaleTimer + dt

            local desiredScale = originalScale

            if grenadeScaleTimer <= expandDuration then
                -- Expansión
                local expandProgress = grenadeScaleTimer / expandDuration
                desiredScale = originalScale + (maxScale - originalScale) * expandProgress

            elseif grenadeScaleTimer <= totalAnimationTime then
                -- Contracción
                local shrinkProgress = (grenadeScaleTimer - expandDuration) / contractDuration
                desiredScale = maxScale - (maxScale - originalScale) * shrinkProgress
                    
            else
                grenadeScaling = false
                desiredScale = originalScale
            end

            local relativeScale = desiredScale / grenadeCurrentScale
            scale_ui_element(skillArma2Entity, relativeScale)
            grenadeCurrentScale = desiredScale
        end

        grenadeAvailableLastFrame = grenadeCurrentlyAvailable

        -- Mostrar cooldown de la granada
        local remainingTime = shotGunScript.granadeCooldown - shotGunScript.timerGranade
        if remainingTime > 0 and not grenadeScaling then
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
    if playerScript ~= nil and chatarraTextComponent ~= nil then
        local chatarra = playerScript.scrapCounter
        chatarraTextComponent:set_text(tostring(chatarra))
    end
end

function buff_debuff_manager(dt)
   cantidadConsumible:set_text(string.format("%d", math.ceil(playerScript.StimsCounter)))

    if playerScript.isHitted then
        dammageFeedback:set_active(true)
        if playerScript.health < 100 then
            dammageFeedbackTexture:set_color(Vector4.new(1, 1, 1, 1))
        else
            dammageFeedbackTexture:set_color(Vector4.new(1, 1, 1, 0.33))
        end
        wasHitted = true
        dammageFadeOutActive = false 
    elseif wasHitted and not playerScript.isHitted then
        dammageFadeOutActive = true
        if playerScript.health < 100 then
            dammageFadeOutAlpha = 1
        else
            dammageFadeOutAlpha = 0.33
        end
        
        wasHitted = false
    end
    
    if dammageFadeOutActive then
        dammageFadeOutAlpha = dammageFadeOutAlpha - (dammageFadeOutSpeed * dt) 
        
        if dammageFadeOutAlpha <= 0 then
            dammageFadeOutActive = false
            dammageFadeOutAlpha = 0
            dammageFeedback:set_active(false)
        else
            dammageFeedbackTexture:set_color(Vector4.new(1, 1, 1, dammageFadeOutAlpha))
        end
    end

   if playerScript.health < 100 then
       bleedingFeedback:set_active(true)
       
       local healthPercent = playerScript.health / 100.0
       local targetAlpha = 0.25 + (1.0 - healthPercent) * 0.5 
       
       bleedingFeedbackTexture:set_color(Vector4.new(1, 1, 1, targetAlpha))
       
   else
       bleedingFeedback:set_active(false)
   end
   
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

   if playerScript.isBurning then
       quemadoEntity:set_active(true)
   else
       quemadoEntity:set_active(false)
   end
   
   local colorHealing = Vector4.new(0, 1, 0.031, 1)
   if playerScript.isHealing then
       lifeFullComponent:set_color(colorHealing)
   else
       lifeFullComponent:set_color(originalLifeColor)
   end
   
   silenciadoEntity:set_active(false)
end