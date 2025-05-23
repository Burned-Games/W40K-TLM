--Base shoot
using = false
local bullets = {}
local bulletCount = 3  -- Bullet Num
local sphere1RigidBody = nil
local sphere1RigidBodyComponent = nil
local sphereSpeed = 50
local contadorDisparo = 0
maxReloadTime = 2.5
local reloadTime = 0
maxAmmo = 24
ammo = 0
local reloadTimeRifle = 0
local shootCoolDown = 0
shootCoolDownRifle = 1.3
local damageRifle = 15
local tripleShootTimer = 0
local tripleShootCount = 0
local tripleShootInterval = 0.1

local attackSpeedMultiplier = 1.0
local reloadSpeedMultiplier = 1.0

local shootParticlesComponent
local bulletDamageParticleComponent

local player = nil
local playerTransf = nil
local playerScript = nil

local shooted = true

damage = 15

local yPositionBullet = 1.5
local yPositionDisruptorBullet = 1

--Audio
local rifle_firerate = 0.8

local bolterShotSFX = nil
local bolterReloadSFX = nil
local bolterSkillAreaSFX = nil
local bolterSkillChargeSFX = nil
local bolterSkillExplosionSFX = nil
local bolterSkillShotSFX = nil
local bolterBulletImpactSFX = nil
local playerNoAmmoSFX = nil

local rifle_firerate_count = 0

-- Particles
local particle_cargdisruptor = nil
local particle_expldisruptor = nil
local particle_cargdisruptor_transform = nil
local particle_expldisruptor_transform = nil

-- Special ability

    --Bullet
    local disruptorBullet = nil
    local disruptorBulletTransf = nil
    local disruptorBulletRbComponent = nil
    local disruptorBulletRb = nil

    local disruptorBulletDamage = 125

    local shieldMultiplier = 0.3

    cooldownDisruptorBulletTime = 8
    cooldownDisruptorBulletTimeCounter = cooldownDisruptorBulletTime
    disruptorShooted = true
    local disruptorShooted2 = false
    local disruptorChargeTime = 1
    local disruptorChargeTimeCounter = 0

    --Zone
    local activateZone = false
    local chargeZone = nil
    local chargeZoneTransf = nil
    local chargeZoneRbComponent = nil
    local chargeZoneRb = nil

    local zoneRadius = 4
    local chargeZoneDamagePerSecond = 15
    local chargeZoneDuration = 5
    local secondCounter = 0
    local secondCounterTimes = 0
    local damageDealed = false

    --Workbench
    local upgradeManager = nil

    local workbenchUIManager = nil

shootAnimation = false
reloadAnimation = false

charging = false
chaaarging = false

local pauseMenu = nil

local hudManager = nil

local vibrationNormalSettings = Vector3.new(1, 0, 20)
local vibrationDisrruptorShootSettings = Vector3.new(1, 1, 200)
local vibrationDisrruptorChargeSettings = Vector3.new(0.2, 0.2, 100)

local manualReload = false

local vfxShoot = nil

local enemies = nil

local cameraScript = nil

local astartesFervorManager = nil

vfxShootTransf = nil

vfxShootPosY =  1.533

local particleCharging = nil

local bulletTimers = nil

local bulletPool = nil

function on_ready()
    cameraScript = current_scene:get_entity_by_name("Camera"):get_component("ScriptComponent")
    player = current_scene:get_entity_by_name("Player")
    playerTransf = player:get_component("TransformComponent")
    playerScript = player:get_component("ScriptComponent")
    astartesFervorManager = current_scene:get_entity_by_name("ArmorUpgradeSystem"):get_component("ScriptComponent")

    upgradeManager = current_scene:get_entity_by_name("UpgradeManager"):get_component("ScriptComponent")
    workbenchUIManager = current_scene:get_entity_by_name("WorkBenchUIManager"):get_component("ScriptComponent")

    particleCharging = current_scene:get_entity_by_name("ChargingDisruptorChargeParticle"):get_component("ParticlesSystemComponent")

    -- sphere1 = current_scene:get_entity_by_name("Sphere1")
    -- transformSphere1 = sphere1:get_component("TransformComponent")

    -- sphere1RigidBodyComponent = sphere1:get_component("RigidbodyComponent")
    -- sphere1RigidBody = sphere1:get_component("RigidbodyComponent").rb
    -- sphere1RigidBody:set_trigger(true)

    -- local children = player:get_children()
    -- for _, child in ipairs(children) do
    --     if child:get_component("TagComponent").tag == "vfxShoot" then
    --         vfxShoot = child
    --         vfxShoot:get_component("TransformComponent").position.y = -830
    --     end
    -- end
    vfxShootTransf = current_scene:get_entity_by_name("vfxShoot"):get_component("TransformComponent")
    vfxShootTransf.position.y = -83
    bulletTimers = {}
    bulletPool = {}
    for i = 1, bulletCount do
        local bulletName = "Sphere" .. i  
        local bullet = {}
        
        bullet.entity = current_scene:get_entity_by_name(bulletName)
        bullet.transform = bullet.entity:get_component("TransformComponent")
        bullet.rigidBodyComponent = bullet.entity:get_component("RigidbodyComponent")
        bullet.rigidBody = bullet.rigidBodyComponent.rb
        bullet.rigidBody:set_trigger(true)
        
        table.insert(bullets, bullet)  -- save to table
        bulletPool[i] = bullet
        bulletTimers[i] = 0
        bullet.rigidBodyComponent:on_collision_enter(function(entityA, entityB)
            handle_bullet_collision(entityA, entityB)
        end)
    end

    -- Audio 
    bolterShotSFX = current_scene:get_entity_by_name("BolterShotSFX"):get_component("AudioSourceComponent")
    bolterReloadSFX = current_scene:get_entity_by_name("BolterReloadSFX"):get_component("AudioSourceComponent")
    bolterSkillAreaSFX = current_scene:get_entity_by_name("BolterSkillAreaSFX"):get_component("AudioSourceComponent")
    bolterSkillChargeSFX = current_scene:get_entity_by_name("BolterSkillChargeSFX"):get_component("AudioSourceComponent")
    bolterSkillExplosionSFX = current_scene:get_entity_by_name("BolterSkillExplosionSFX"):get_component("AudioSourceComponent")
    bolterSkillShotSFX = current_scene:get_entity_by_name("BolterSkillShotSFX"):get_component("AudioSourceComponent")
    bolterBulletImpactSFX = current_scene:get_entity_by_name("BolterBulletImpactsSFX"):get_component("AudioSourceComponent")
    playerNoAmmoSFX = current_scene:get_entity_by_name("PlayerNoAmmoSFX"):get_component("AudioSourceComponent")

    -- Particles
    particle_cargdisruptor = current_scene:get_entity_by_name("particle_cargdisruptor"):get_component("ParticlesSystemComponent")
    particle_expldisruptor = current_scene:get_entity_by_name("particle_expldisruptor"):get_component("ParticlesSystemComponent")
    particle_cargdisruptor_transform = current_scene:get_entity_by_name("particle_cargdisruptor"):get_component("TransformComponent")
    particle_expldisruptor_transform = current_scene:get_entity_by_name("particle_expldisruptor"):get_component("TransformComponent")
    

    disruptorBullet = current_scene:get_entity_by_name("DisruptorBullet")
    disruptorBulletTransf = disruptorBullet:get_component("TransformComponent")
    disruptorBulletRbComponent = disruptorBullet:get_component("RigidbodyComponent")
    disruptorBulletRb = disruptorBulletRbComponent.rb
    disruptorBulletRb:set_trigger(true)

    disruptorBulletRbComponent:on_collision_enter(function(entityA, entityB)               
        local nameA = entityA:get_component("TagComponent").tag
        local nameB = entityB:get_component("TagComponent").tag

        local entityARB = entityA:get_component("RigidbodyComponent").rb
        local entityBRB = entityB:get_component("RigidbodyComponent").rb

        if entityARB and nameA ~= "Player" and nameA ~= "FloorCollider" then
            if entityARB:get_is_trigger() == false then
                disruptorBulletRbComponent.rb:set_position(Vector3.new(0,-150,0))
                disruptorBulletRbComponent.rb:set_velocity(Vector3.new(0,0,0))
            end 
        end

        if entityBRB and nameB ~= "Player" and nameB ~= "FloorCollider" then
    
            if entityBRB:get_is_trigger() == false then
                disruptorBulletRbComponent.rb:set_position(Vector3.new(0,-150,0))
                disruptorBulletRbComponent.rb:set_velocity(Vector3.new(0,0,0))
            end
        end
        
        if nameA == "EnemyRange" or nameA == "EnemyRange1" or nameA == "EnemyRange2" or nameA == "EnemyRange3"  or nameA == "EnemyRange4" or nameA == "EnemyRange5" or nameA == "EnemyRange6" then 
            makeDisruptorDamage(entityA)
        end

        if nameB == "EnemyRange" or nameB == "EnemyRange1" or nameB == "EnemyRange2" or nameB == "EnemyRange3"  or nameB == "EnemyRange4" or nameB == "EnemyRange5" or nameB == "EnemyRange6" then
            makeDisruptorDamage(entityB)
            
        end

        if nameA == "EnemySupport" then 
            makeDisruptorDamage(entityA)
        end

        if nameB == "EnemySupport" then
            makeDisruptorDamage(entityB)
        end

        if nameA == "EnemyKamikaze" then 
            makeDisruptorDamage(entityA)
        end

        if nameB == "EnemyKamikaze" then
            makeDisruptorDamage(entityB)
        end

        if nameA == "EnemyTank" or nameA == "EnemyTank1" or nameA == "EnemyTank2" or nameA == "EnemyTank3"  or nameA == "EnemyTank4" or nameA == "EnemyTank5" or nameA == "EnemyTank6" then 
            makeDisruptorDamage(entityA)
        end

        if nameB == "EnemyTank" or nameB == "EnemyTank1" or nameB == "EnemyTank2" or nameB == "EnemyTank3"  or nameB == "EnemyTank4" or nameB == "EnemyTank5" or nameB == "EnemyTank6" then
            makeDisruptorDamage(entityB)
            
        end

        if nameA == "MainBoss" then 
            makeDisruptorDamage(entityA)
        end

        if nameB == "MainBoss" then
            makeDisruptorDamage(entityB)
        end

        if nameA == "BarrilDestruible" or nameA == "CajaDestruible" or nameA == "CajaDestruibleV2" or nameA == "ScrapPile" then 
            local script = entityA:get_component("ScriptComponent")
            script:give_phisycs()
            script.hasDestroyed = true

            activateZone = true
            chargeZoneRb:set_position(Vector3.new(disruptorBulletTransf.position.x, disruptorBulletTransf.position.y, disruptorBulletTransf.position.z))
            disruptorBulletRb:set_position(Vector3.new(0,1500,0))
            disruptorBulletRb:set_velocity(Vector3.new(0,0,0))

            bolterSkillExplosionSFX:play()
            bolterSkillAreaSFX:play()
        end

        if nameB == "BarrilDestruible" or nameB == "CajaDestruible" or nameB == "CajaDestruibleV2" or nameB == "ScrapPile" then 
            local script = entityB:get_component("ScriptComponent")
            script:give_phisycs()
            script.hasDestroyed = true

            activateZone = true
            chargeZoneRb:set_position(Vector3.new(disruptorBulletTransf.position.x, disruptorBulletTransf.position.y, disruptorBulletTransf.position.z))
            disruptorBulletRb:set_position(Vector3.new(0,1500,0))
            disruptorBulletRb:set_velocity(Vector3.new(0,0,0))

            bolterSkillExplosionSFX:play()
            bolterSkillAreaSFX:play()
        end

        

    end)

    chargeZone = current_scene:get_entity_by_name("ChargeZone")
    chargeZoneTransf = chargeZone:get_component("TransformComponent")
    chargeZoneRbComponent = chargeZone:get_component("RigidbodyComponent")
    chargeZoneRb = chargeZoneRbComponent.rb
    chargeZoneRb:set_trigger(true)

    pauseMenu = current_scene:get_entity_by_name("PauseBase"):get_component("ScriptComponent")

    hudManager = current_scene:get_entity_by_name("HUD"):get_component("ScriptComponent")

    if current_scene:get_entity_by_name("SawSwordManager"):has_component("ScriptComponent") then

        swordScript = current_scene:get_entity_by_name("SawSwordManager"):get_component("ScriptComponent")
    end

end

function on_update(dt)

    for i = 1, bulletCount do

        if bulletTimers[i] ~= 0 then
            bulletTimers[i] = bulletTimers[i] + dt

            if bulletTimers[i] > 0.5 then
                bullets[i].rigidBody:set_position(Vector3.new(0,-150,0))
                bulletTimers[i] = 0
            end
        end




        
    end

    if astartesFervorManager.isPlayerInRadius then
        set_attack_speed_multiplier(2.0)
        set_reload_speed_multiplier(1.5)
    else
        set_attack_speed_multiplier(1.0)
        set_reload_speed_multiplier(1.0)
    end


    if playerScript.health <= 0 or workbenchUIManager.isWorkBenchOpen then
        return
    end

    if not pauseMenu.isPaused then

        -- Applying multipliers
        local currentShootCoolDownRifle = shootCoolDownRifle * (1 / attackSpeedMultiplier)
        local currentDisruptorBulletTimeCooldown = cooldownDisruptorBulletTime * (1 / attackSpeedMultiplier)
        local currentMaxReloadTime = maxReloadTime * (1 / reloadSpeedMultiplier)

        if using then
            local rightTrigger = Input.get_button(Input.action.Shoot)
            local leftShoulder = Input.get_button(Input.action.Skill2)

            if Input.is_button_pressed(Input.controllercode.West) and manualReload == false and ammo > 0 then
                manualReload = true
            end
            if ammo >= maxAmmo or manualReload then
                
                if playerScript.currentUpAnim ~= playerScript.reload_Bolter and reloadAnimation == false then
                    playReload()
                    playerScript.currentUpAnim = playerScript.reload_Bolter
                    playerScript.animator:set_upper_animation(playerScript.currentUpAnim)
                    reloadAnimation = true
                end
                if reloadTime == 0 then
                end
                reloadTime = reloadTime + dt
                if reloadTime >= currentMaxReloadTime then
                    ammo = 0
                    reloadTime = 0
                    reloadAnimation = false
                    playerScript.currentAnim = -1
                    manualReload = false
                end
            end
            if shooted == true then
                shootCoolDown = shootCoolDown + dt
            end

            if rightTrigger == Input.state.Repeat and (ammo < maxAmmo) and swordScript.slasheeed == false and reloadAnimation == false then
                playerScript.activateAutoAim = true
                if playerScript.currentUpAnim ~= playerScript.attack and shootAnimation == false then
                    playerScript.currentUpAnim = playerScript.attack
                    playerScript.animator:set_upper_animation(playerScript.currentUpAnim)
                    shootAnimation = true
                end
                
                if shootCoolDown >= currentShootCoolDownRifle then
                    
                    tripleShoot()
                    vfxShootTransf.position.y = vfxShootPosY
                    --shootParticlesComponent:emit(6)
                    ammo = ammo + 3
                    shooted = true
                    shootCoolDown = 0
                    --shootAnimation = false
                else
                    
                end
                playerScript.shootingIndicator = true
            else
                playerScript.activateAutoAim = false
                vfxShootTransf.position.y = 830
                if disruptorShooted2 == false then
                    playerScript.activateAutoAim = false
                end
                if playerScript.currentAnim ~= -1 and shootAnimation == true then
                    playerScript.currentAnim = -1
                end
                shootAnimation = false

                playerScript.shootingIndicator = false
            end

            if rightTrigger == Input.state.Down and (ammo == maxAmmo) then
                playerNoAmmoSFX:play()
                hudManager.arma1Texture:set_color(Vector4.new(1, 0, 0, 1))
                hudManager.ammoTextComponent:set_color(Vector4.new(1, 0, 0, 1))            
            else
                hudManager.arma1Texture:set_color(Vector4.new(1, 1, 1, 1))
                hudManager.ammoTextComponent:set_color(Vector4.new(1, 1, 1, 1))    
            end

            tripleShootTimer = tripleShootTimer - dt

            if tripleShootCount > 0 and tripleShootTimer <= 0 then
                
                shoot(dt, tripleShootCount)
                tripleShootCount = tripleShootCount - 1
                tripleShootTimer = tripleShootInterval
            end

            if (leftShoulder == Input.state.Repeat or Input.is_key_pressed(Input.keycode.L)) and cooldownDisruptorBulletTimeCounter >= currentDisruptorBulletTimeCooldown and upgradeManager.has_weapon_special() then
                charging = true
                local aimVector = Vector3.new(0,0,0)
                
                aimVector = Vector3.new(math.sin(playerScript.angleRotation), 0, math.cos(playerScript.angleRotation))
                
                Physics.DebugDrawRaycast(player:get_component("TransformComponent").position, aimVector, 10, Vector4.new(1, 0, 0, 1), Vector4.new(0, 1, 0, 1))
            end

            if charging then
                Input.send_rumble(vibrationDisrruptorChargeSettings.x, vibrationDisrruptorChargeSettings.y, vibrationDisrruptorChargeSettings.z)
            end

            if leftShoulder == Input.state.Up and charging then

                disruptorChargeTimeCounter = disruptorChargeTimeCounter + dt
                if disruptorChargeTimeCounter >= disruptorChargeTime then
                    cooldownDisruptorBulletTimeCounter = 0
                    disruptorShooted = true
                    disruptorShooted2 = true
                    charging = false
                    chaaarging = false
                else

                    if chaaarging == false then bolterSkillChargeSFX:play() end

                    playerScript.moveSpeed = 0
                    playerScript.playerRb:set_velocity(Vector3.new(0, 0, 0))
                    chaaarging = true
                    particleCharging:emit(1)
                    if playerScript.currentAnim ~= playerScript.h1_Bolter then
                        playerScript.currentAnim = playerScript.h1_Bolter
                        playerScript.currentUpAnim = playerScript.h1_Bolter
                        playerScript.animator:set_current_animation(playerScript.currentAnim)
                    end
                end
                
            end

            

            if disruptorShooted2 then
                playerScript.activateAutoAim = true
                disruptiveCharge()
                disruptorChargeTimeCounter = 0
                disruptorShooted2 = false
            end

            
        end

        if disruptorShooted and cooldownDisruptorBulletTimeCounter < currentDisruptorBulletTimeCooldown then
            cooldownDisruptorBulletTimeCounter = cooldownDisruptorBulletTimeCounter + dt
            

        end
        
        if activateZone == true then
            chargedZoneUpdate(dt)
        end
    end


end

-- multiplyer of the armor ability
function set_attack_speed_multiplier(multiplier)
    attackSpeedMultiplier = multiplier
end

-- multiplyer of the armor ability
function set_reload_speed_multiplier(multiplier)
    reloadSpeedMultiplier = multiplier
end

function tripleShoot()
    tripleShootCount = 3
    tripleShootTimer = 0
end

function shoot(dt, bulletNum)

    shootCoolDownTimer = shootCoolDown
    Input.send_rumble(vibrationNormalSettings.x, vibrationNormalSettings.y, vibrationNormalSettings.z)
    print(bulletNum)

    local playerPosition = playerTransf.position
    local playerRotation = playerTransf.rotation


    playShoot()
    local forwardVector = Vector3.new(0,0,0)

    if playerScript.enemyDirection ~= nil then
        forwardVector = playerScript.enemyDirection
        playerScript.angleRotation = math.atan(forwardVector.x, forwardVector.z)
    else
        forwardVector = Vector3.normalize(Vector3.new(math.sin(playerScript.angleRotation), 0, math.cos(playerScript.angleRotation)))
    end
    
    
    local newPosition = Vector3.new((forwardVector.x + playerPosition.x) , yPositionBullet  , (forwardVector.z+ playerPosition.z) )

    bullets[bulletNum].rigidBody:set_position(newPosition)

    bullets[bulletNum].rigidBody:set_rotation(Vector3.new(0,math.deg(playerScript.angleRotation),0))

    local velocity = Vector3.new(forwardVector.x * sphereSpeed, 0, forwardVector.z * sphereSpeed)
    bullets[bulletNum].rigidBody:set_velocity(velocity)
    bulletTimers[bulletNum] = 0.1


    

   
end

function disruptiveCharge()

    local playerPosition = playerTransf.position
    local playerRotation = playerTransf.rotation

    Input.send_rumble(vibrationDisrruptorShootSettings.x, vibrationDisrruptorShootSettings.y, vibrationDisrruptorShootSettings.z)

    bolterSkillShotSFX:play()

    if playerScript.enemyDirection ~= nil then
        forwardVector = playerScript.enemyDirection
        playerScript.angleRotation = math.atan(forwardVector.x, forwardVector.z)
    else
        forwardVector = Vector3.new(math.sin(playerScript.angleRotation), 0, math.cos(playerScript.angleRotation))
    end
    
    local offsetDistance = 2.5 -- Puedes ajustar esto al gusto
    local offsetPosition = Vector3.new(forwardVector.x * offsetDistance, 0, forwardVector.z * offsetDistance)
    local newPosition = Vector3.new(
    playerPosition.x + offsetPosition.x,
    playerPosition.y + offsetPosition.y,
    playerPosition.z + offsetPosition.z
)
    newPosition.y = yPositionDisruptorBullet

    particle_cargdisruptor_transform.position = newPosition
    --particle_cargdisruptor:emit(1)
    

    disruptorBulletTransf.position = newPosition
    disruptorBulletTransf.rotation = Vector3.new(0,math.deg(playerScript.angleRotation),0)

    disruptorBulletRb:set_position(Vector3.new(newPosition.x, newPosition.y, newPosition.z ))

    disruptorBulletRb:set_rotation(Vector3.new(0,math.deg(playerScript.angleRotation),0))

    local velocity = Vector3.new(forwardVector.x * sphereSpeed, 0, forwardVector.z * sphereSpeed)
    disruptorBulletRb:set_velocity(velocity)

end

function chargedZoneUpdate(dt)

    
     if secondCounterTimes < 5 then
            
        secondCounter = secondCounter + dt

     else
        chargeZoneRb:set_position(Vector3.new(0,-100,0))
        activateZone = false
        secondCounterTimes = 0
     end

     if secondCounter >= 1 then
        
         

        for _, entity in ipairs(cameraScript.enemies) do 

            if entity ~= chargeZone and entity:has_component("RigidbodyComponent") and entity ~= nil then
                local entityRb = entity:get_component("RigidbodyComponent").rb
                local entityPos = entityRb:get_position()

                local direction = Vector3.new(
                    entityPos.x - chargeZoneTransf.position.x,
                    entityPos.y - chargeZoneTransf.position.y,
                    entityPos.z - chargeZoneTransf.position.z
                )

                local distance = math.sqrt(
                    direction.x * direction.x +
                    direction.y * direction.y +
                    direction.z * direction.z
                )

                if distance > 0 then
                    direction.x = direction.x / distance
                    direction.y = direction.y / distance
                    direction.z = direction.z / distance
                end

                if distance < zoneRadius then

                    local name = entity:get_component("TagComponent").tag

                    if name== "EnemyRange" or name== "EnemyRange1" or name== "EnemyRange2" or name== "EnemyRange3" or name== "EnemyRange4" or name== "EnemyRange5" or name== "EnemyRange6" then  
                        enemyOrkScript = entity:get_component("ScriptComponent")
                        if enemyOrkScript ~= nil then                          
                            enemyOrkScript.range:take_damage(chargeZoneDamagePerSecond, shieldMultiplier)
                            playerScript.makeDamage = true

                        end
                    end

                    if name == "EnemySupport" then
                        enemySuppScript = entity:get_component("ScriptComponent")
                        if enemySuppScript ~= nil then
                            enemySuppScript.support:take_damage(chargeZoneDamagePerSecond, shieldMultiplier)
                            playerScript.makeDamage = true

                        end
                    end 
                    
                    if name == "EnemyKamikaze" then  
                        enemyKamikazeScript = entity:get_component("ScriptComponent")
                        if enemyKamikazeScript ~= nil then
                            enemyKamikazeScript.kamikaze:take_damage(chargeZoneDamagePerSecond, shieldMultiplier)
                            playerScript.makeDamage = true
                        end
                    end

                    if name == "EnemyTank" or name == "EnemyTank1" or name == "EnemyTank2" or name == "EnemyTank3" or name == "EnemyTank4" or name == "EnemyTank5" or name == "EnemyTank6" then  
                        enemyTankScript = entity:get_component("ScriptComponent")
                        if enemyTankScript ~= nil then
                            enemyTankScript.tank:take_damage(chargeZoneDamagePerSecond, shieldMultiplier)
                            playerScript.makeDamage = true
                        end
                    end

                    if name == "MainBoss" then 
                        enemyBossScript = entity:get_component("ScriptComponent")
                        if enemyBossScript ~= nil then
                            enemyBossScript.main_boss:take_damage(chargeZoneDamagePerSecond, shieldMultiplier)
                            playerScript.makeDamage = true
                        end
                    end

                        if name == "BarrilDestruible" or name == "CajaDestruible" or name == "CajaDestruibleV2" or name == "ScrapPile" then 
                            local script = entity:get_component("ScriptComponent")
                            script:give_phisycs()
                            script.hasDestroyed = true

                            activateZone = true
                            chargeZoneRb:set_position(Vector3.new(disruptorBulletTransf.position.x, disruptorBulletTransf.position.y, disruptorBulletTransf.position.z))
                            disruptorBulletRb:set_position(Vector3.new(0,1500,0))
                            disruptorBulletRb:set_velocity(Vector3.new(0,0,0))

                            bolterSkillExplosionSFX:play()
                            bolterSkillAreaSFX:play()
                        end
                end
            end
        end
        
        
        secondCounter = 0
        secondCounterTimes = secondCounterTimes + 1
        

    end


   
    


end

function makeDamage(enemy)

    local enemyTag = nil
    local enemyScript = nil
    local enemyInstance = nil

    if enemy ~= nil then    
        enemyTag = enemy:get_component("TagComponent").tag           
        enemyScript = enemy:get_component("ScriptComponent")
    end

    if enemy ~= nil then
        if enemyScript ~= nil then
            if enemyTag == "EnemyRange" or enemyTag == "EnemyRange1" or enemyTag == "EnemyRange2" or enemyTag == "EnemyRange3" or enemyTag == "EnemyRange4" or enemyTag == "EnemyRange5" or enemyTag == "EnemyRange6" then
                enemyInstance = enemyScript.range
            elseif enemyTag == "EnemySupport" then
                enemyInstance = enemyScript.support
            elseif enemyTag == "EnemyTank" or enemyTag == "EnemyTank1" or enemyTag == "EnemyTank2" or enemyTag == "EnemyTank3" or enemyTag == "EnemyTank4" or enemyTag == "EnemyTank5" or enemyTag == "EnemyTank6" then
                enemyInstance = enemyScript.tank
            elseif enemyTag == "EnemyKamikaze" then
                enemyInstance = enemyScript.kamikaze
            elseif enemyTag == "MainBoss" then
                enemyInstance = enemyScript.main_boss
            end
            
            if enemyInstance ~= nil then
                enemyInstance:take_damage(damageRifle)
                bolterBulletImpactSFX:play()
                playerScript.makeDamage = true
            end
        end
    end

end



function makeDisruptorDamage(enemy)

    local enemyTag = nil
    local enemyScript = nil
    local enemyInstance = nil

    if enemy ~= nil then  
        enemyTag = enemy:get_component("TagComponent").tag   
        enemyScript = enemy:get_component("ScriptComponent")
        
    end
    if enemy ~= nil then
        if enemyScript ~= nil then
            if enemyTag == "EnemyRange" or enemyTag == "EnemyRange1" or enemyTag == "EnemyRange2" or enemyTag == "EnemyRange3" or enemyTag == "EnemyRange4" or enemyTag == "EnemyRange5" or enemyTag == "EnemyRange6" then
                enemyInstance = enemyScript.range
            elseif enemyTag == "EnemySupport" then
                enemyInstance = enemyScript.support
            elseif enemyTag == "EnemyTank" or enemyTag == "EnemyTank1" or enemyTag == "EnemyTank2" or enemyTag == "EnemyTank3" or enemyTag == "EnemyTank4" or enemyTag == "EnemyTank5" or enemyTag == "EnemyTank6" then
                enemyInstance = enemyScript.tank
            elseif enemyTag == "EnemyKamikaze" then
                enemyInstance = enemyScript.kamikaze
            elseif enemyTag == "MainBoss" then
                enemyInstance = enemyScript.main_boss
            end
            enemyInstance:take_damage(disruptorBulletDamage, shieldMultiplier)

            playerScript.makeDamage = true
            activateZone = true
            chargeZoneRb:set_position(Vector3.new(disruptorBulletTransf.position.x, disruptorBulletTransf.position.y, disruptorBulletTransf.position.z))
            disruptorBulletRb:set_position(Vector3.new(0,1500,0))
            disruptorBulletRb:set_velocity(Vector3.new(0,0,0))

            bolterSkillExplosionSFX:play()
            bolterSkillAreaSFX:play()

        end
    end

end

function handle_bullet_collision(entityA, entityB)
   
    local nameA = entityA:get_component("TagComponent").tag
    local nameB = entityB:get_component("TagComponent").tag

    local entityARB = entityA:get_component("RigidbodyComponent").rb
    local entityBRB = entityB:get_component("RigidbodyComponent").rb

    

    if nameA == "EnemyRange" or nameA == "EnemyRange1" or nameA == "EnemyRange2" or nameA == "EnemyRange3"  or nameA == "EnemyRange4" or nameA == "EnemyRange5" or nameA == "EnemyRange6" or nameB == "EnemyRange" or nameB == "EnemyRange1" or nameB == "EnemyRange2" or nameB == "EnemyRange3"  or nameB == "EnemyRange4" or nameB == "EnemyRange5" or nameB == "EnemyRange6" then
        local enemy = ((nameA == "EnemyRange" or nameA == "EnemyRange1" or nameA == "EnemyRange2" or nameA == "EnemyRange3"  or nameA == "EnemyRange4" or nameA == "EnemyRange5" or nameA == "EnemyRange6") and entityA) or ((nameB == "EnemyRange" or nameB == "EnemyRange1" or nameB == "EnemyRange2" or nameB == "EnemyRange3"  or nameB == "EnemyRange4" or nameB == "EnemyRange5" or nameB == "EnemyRange6") and entityB)
        makeDamage(enemy)

    end

    if nameA == "EnemySupport" or nameB == "EnemySupport" then
        local enemy = (nameA == "EnemySupport" and entityA) or (nameB == "EnemySupport" and entityB)
        makeDamage(enemy)
    end

    if nameA == "EnemyKamikaze" or nameB == "EnemyKamikaze" then
        local enemy = (nameA == "EnemyKamikaze" and entityA) or (nameB == "EnemyKamikaze" and entityB)
        makeDamage(enemy)
    end

    if nameA == "EnemyTank" or nameA== "EnemyTank1" or nameA == "EnemyTank2" or nameA == "EnemyTank3"  or nameA == "EnemyTank4" or nameA == "EnemyTank5" or nameA == "EnemyTank6" or nameA == "EnemyTank1" or nameA == "EnemyTank2" or nameA == "EnemyTank3"  or nameA == "EnemyTank4" or nameA == "EnemyTank5" or nameA == "EnemyTank6" or nameB == "EnemyTank" or nameB == "EnemyTank1" or nameB == "EnemyTank2" or nameB == "EnemyTank3"  or nameB == "EnemyTank4" or nameB == "EnemyTank5" or nameB == "EnemyTank6" or nameB == "EnemyTank1" or nameB == "EnemyTank2" or nameB == "EnemyTank3"  or nameB == "EnemyTank4" or nameB == "EnemyTank5" or nameB == "EnemyTank6" then
        local enemy = ((nameA == "EnemyTank" or nameA== "EnemyTank1" or nameA == "EnemyTank2" or nameA == "EnemyTank3"  or nameA == "EnemyTank4" or nameA == "EnemyTank5" or nameA == "EnemyTank6") and entityA) or ((nameB == "EnemyTank" or nameB == "EnemyTank1" or nameB == "EnemyTank2" or nameB == "EnemyTank3"  or nameB == "EnemyTank4" or nameB == "EnemyTank5" or nameB == "EnemyTank6") and entityB)
        makeDamage(enemy)
    end

    if nameA == "MainBoss" or nameB == "MainBoss" then
        local enemy = (nameA == "MainBoss" and entityA) or (nameB == "MainBoss" and entityB)
        
        makeDamage(enemy)
    end
    if entityARB and nameB ~= "Player"  and nameB ~= "FloorCollider" and nameB ~= "Sphere1"  and nameB ~= "Sphere2"  and nameB ~= "Sphere3"  and nameB ~= "Sphere4"  and nameB ~= "Sphere5" and nameB ~= "Sphere6" and nameB ~= "Sphere7" and nameB ~= "Sphere8" then
        if entityBRB:get_is_trigger() == false then
            entityARB:set_position(Vector3.new(0,-150,0))
        end 
    end

    if entityBRB and nameA ~= "Player"  and nameA ~= "FloorCollider" and nameA ~= "Sphere1"  and nameA ~= "Sphere2"  and nameA ~= "Sphere3"  and nameA ~= "Sphere4"  and nameA ~= "Sphere5" and nameA ~= "Sphere6" and nameA ~= "Sphere7" and nameA ~= "Sphere8" then
        if entityARB:get_is_trigger() == false then
            entityBRB:set_position(Vector3.new(0,-150,0))
        end 
    end
    
end

function playShoot()
    bolterShotSFX:pause()
    bolterShotSFX:play()  
end

function playReload()
    bolterReloadSFX:play() 
end


function on_exit()
    -- Add cleanup code here
end