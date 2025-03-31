--Base shoot
using = false
local sphere1RigidBody = nil
local sphere1RigidBodyComponent = nil
local sphereSpeed = 100
local contadorDisparo = 0
maxReloadTime = 2.5
local reloadTime = 0
maxAmmo = 24
ammo = 0
local reloadTimeRifle = 0
local shootCoolDown = 0
shootCoolDownRifle = 0.8
local damageRifle = 25
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

damage = 25

--audio
local burst_shot
local rifle_reload
local rifle_firerate = 0.8

local rifle_firerate_count = 0

-- Special ability

    --Bullet
    local disruptorBullet = nil
    local disruptorBulletTransf = nil
    local disruptorBulletRbComponent = nil
    local disruptorBulletRb = nil

    local disruptorBulletDamage = 40

    local shieldMultiplier = 0.3

    cooldownDisruptorBulletTime = 18
    cooldownDisruptorBulletTimeCounter = 18
    disruptorShooted = true
    local disruptorShooted2 = false
    local disruptorChargeTime = 0.8
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


function on_ready()

    player = current_scene:get_entity_by_name("Player")
    playerTransf = player:get_component("TransformComponent")
    playerScript = player:get_component("ScriptComponent")

    upgradeManager = current_scene:get_entity_by_name("UpgradeManager"):get_component("ScriptComponent")

    sphere1 = current_scene:get_entity_by_name("Sphere1")
    transformSphere1 = sphere1:get_component("TransformComponent")

    sphere1RigidBodyComponent = sphere1:get_component("RigidbodyComponent")
    sphere1RigidBody = sphere1:get_component("RigidbodyComponent").rb
    sphere1RigidBody:set_trigger(true)


    local burst_shot_entity = current_scene:get_entity_by_name("RifleDisparoAudio")
    burst_shot = burst_shot_entity:get_component("AudioSourceComponent")

    local rifle_reload_entity = current_scene:get_entity_by_name("RifleRecargaAudio")
    rifle_reload = rifle_reload_entity:get_component("AudioSourceComponent")

    --shootParticlesComponent = current_scene:get_entity_by_name("ParticulasDisparo"):get_component("ParticlesSystemComponent")
    ---- bulletDamageParticleComponent = current_scene:get_entity_by_name("ParticlePlayerBullet"):get_component("ParticlesSystemComponent")

    sphere1RigidBodyComponent:on_collision_enter(function(entityA, entityB)               
        local nameA = entityA:get_component("TagComponent").tag
        local nameB = entityB:get_component("TagComponent").tag


        if nameA == "EnemyOrk" or nameB == "EnemyOrk" then
            local enemyOrk = nil
            local enemyOrkScript = nil
            if nameA == "EnemyOrk" then
                enemyOrk = entityA
                
            end

            if nameB == "EnemyOrk" then
                enemyOrk = entityB
            end
            if enemyOrk ~= nil then               
                enemyOrkScript = enemyOrk:get_component("ScriptComponent")
            end

            if enemyOrk ~= nil then
                if enemyOrkScript ~= nil then
                    
                    if enemyOrkScript.shieldHealth > 0 then
                        -- bulletDamageParticleComponent:emit(20)
                        enemyOrkScript.shieldHealth = enemyOrkScript.shieldHealth - damage
                        playerScript.makeDamage = true
                    else
                    -- bulletDamageParticleComponent:emit(20)
                    enemyOrkScript.enemyHealth = enemyOrkScript.enemyHealth - damage
                    playerScript.makeDamage  =true
                    end
                end
            end
           
        end

        if nameA == "EnemySupp" or nameB == "EnemySupp" then
            local enemySupp = nil
            local enemySuppScript = nil
            if nameA == "EnemySupp" then
                enemySupp = entityA
                
            end

            if nameB == "EnemySupp" then
                enemySupp = entityB
            end
            if enemySupp ~= nil then               
                enemySuppScript = enemySupp:get_component("ScriptComponent")
            end

            if enemySupp ~= nil then
                if enemySuppScript ~= nil then
                    
                    -- bulletDamageParticleComponent:emit(20)
                    enemySuppScript.enemyHealth = enemySuppScript.enemyHealth - damage
                    playerScript.makeDamage = true
            
                end
            end
           
        end
    end)

    disruptorBullet = current_scene:get_entity_by_name("DisruptorBullet")
    disruptorBulletTransf = disruptorBullet:get_component("TransformComponent")
    disruptorBulletRbComponent = disruptorBullet:get_component("RigidbodyComponent")
    disruptorBulletRb = disruptorBulletRbComponent.rb
    disruptorBulletRb:set_trigger(true)

    disruptorBulletRbComponent:on_collision_enter(function(entityA, entityB)               
        local nameA = entityA:get_component("TagComponent").tag
        local nameB = entityB:get_component("TagComponent").tag


        if nameA == "EnemyOrk" or nameB == "EnemyOrk" then
            local enemyOrk = nil
            local enemyOrkScript = nil
            if nameA == "EnemyOrk" then
                enemyOrk = entityA
                
            end

            if nameB == "EnemyOrk" then
                enemyOrk = entityB
            end
            if enemyOrk ~= nil then               
                enemyOrkScript = enemyOrk:get_component("ScriptComponent")
            end

            if enemyOrk ~= nil then
                if enemyOrkScript ~= nil then
                    
                    if enemyOrkScript.shieldHealth > 0 then
                        -- bulletDamageParticleComponent:emit(20)
                        enemyOrkScript.shieldHealth = enemyOrkScript.shieldHealth - (disruptorBulletDamage + disruptorBulletDamage * shieldMultiplier)
                        playerScript.makeDamage = true
                    else
                    -- bulletDamageParticleComponent:emit(20)
                    enemyOrkScript.enemyHealth = enemyOrkScript.enemyHealth - disruptorBulletDamage
                    playerScript.makeDamage = true
                    end
                    activateZone = true
                    chargeZoneRb:set_position(Vector3.new(disruptorBulletTransf.position.x, disruptorBulletTransf.position.y, disruptorBulletTransf.position.z))
                    disruptorBulletRb:set_position(Vector3.new(0,1000,0))
                    disruptorBulletRb:set_velocity(Vector3.new(0,0,0))
                end
            end
           
        end

        if nameA == "EnemySupp" or nameB == "EnemySupp" then
            local enemySupp = nil
            local enemySuppScript = nil
            if nameA == "EnemySupp" then
                enemySupp = entityA
                
            end

            if nameB == "EnemySupp" then
                enemySupp = entityB
            end
            if enemySupp ~= nil then               
                enemySuppScript = enemySupp:get_component("ScriptComponent")
            end

            if enemySupp ~= nil then
                if enemySuppScript ~= nil then
                    
                    -- bulletDamageParticleComponent:emit(20)
                    enemySuppScript.enemyHealth = enemySuppScript.enemyHealth - disruptorBulletDamage
                    playerScript.makeDamage = true
            
                end
                activateZone = true
                chargeZoneRb:set_position(Vector3.new(disruptorBulletTransf.position.x, disruptorBulletTransf.position.y, disruptorBulletTransf.position.z))
                disruptorBulletRb:set_position(Vector3.new(0,1000,0))
                disruptorBulletRb:set_velocity(Vector3.new(0,0,0))

            end
           
        end
    end)

    chargeZone = current_scene:get_entity_by_name("ChargeZone")
    chargeZoneTransf = chargeZone:get_component("TransformComponent")
    chargeZoneRbComponent = chargeZone:get_component("RigidbodyComponent")
    chargeZoneRb = chargeZoneRbComponent.rb
    chargeZoneRb:set_trigger(true)

    
end

function on_update(dt)
    -- Applying multipliers
    local currentShootCoolDownRifle = shootCoolDownRifle * (1 / attackSpeedMultiplier)
    local currentDisruptorBulletTimeCooldown = cooldownDisruptorBulletTime * (1 / attackSpeedMultiplier)
    local currentMaxReloadTime = maxReloadTime * (1 / reloadSpeedMultiplier)

    if using then
        local rightTrigger = Input.get_button(Input.action.Shoot)
        local leftShoulder = Input.get_button(Input.action.Skill2)

        if ammo >= maxAmmo then
            if reloadTime == 0 then
                playReload()
            end
            reloadTime = reloadTime + dt
            if reloadTime >= currentMaxReloadTime then
                
                ammo = 0
                reloadTime = 0
            end
        end
        if shooted == true then
            shootCoolDown = shootCoolDown + dt
        end

        if rightTrigger == Input.state.Repeat and (ammo < maxAmmo) and shootCoolDown >= currentShootCoolDownRifle then

                playerScript.currentAnim = -1
                playerScript.animator:set_current_animation(playerScript.currentAnim)
                playerScript.currentUpAnim = 0
                playerScript.animator:set_upper_animation(playerScript.currentUpAnim)
                
            tripleShoot()

                --shootParticlesComponent:emit(6)
                ammo = ammo + 3
                shooted = true
                shootCoolDown = 0

        end




        tripleShootTimer = tripleShootTimer - dt

        if tripleShootCount > 0 and tripleShootTimer <= 0 then
            shoot(dt)
            tripleShootCount = tripleShootCount - 1
            tripleShootTimer = tripleShootInterval
        end

        if leftShoulder == Input.state.Down and cooldownDisruptorBulletTimeCounter >= currentDisruptorBulletTimeCooldown and upgradeManager.has_weapon_special() then
            
            cooldownDisruptorBulletTimeCounter = 0
            disruptorShooted = true
            disruptorShooted2 = true
        end

        if disruptorShooted and cooldownDisruptorBulletTimeCounter < currentDisruptorBulletTimeCooldown then
            cooldownDisruptorBulletTimeCounter = cooldownDisruptorBulletTimeCounter + dt
            

        end

        if disruptorShooted2 then
            disruptorChargeTimeCounter = disruptorChargeTimeCounter + dt
            if disruptorChargeTimeCounter >= disruptorChargeTime then
            print("dentrooooooooooooooo")
                disruptiveCharge()
                disruptorChargeTimeCounter = 0
                disruptorShooted2 = false
            end
        end

        
    end

    if activateZone == true then
        chargedZoneUpdate(dt)
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

function shoot(dt)
    
    shootCoolDownTimer = shootCoolDown



    local playerPosition = playerTransf.position
    local playerRotation = playerTransf.rotation


    playShoot()


    local forwardVector = Vector3.new(math.sin(playerScript.angleRotation), 0, math.cos(playerScript.angleRotation))
    
    local newPosition = Vector3.new((forwardVector.x + playerPosition.x) , (forwardVector.y+ playerPosition.y)  , (forwardVector.z+ playerPosition.z) )

    transformSphere1.position = newPosition
    transformSphere1.rotation = Vector3.new(0,math.deg(playerScript.angleRotation),0)

    sphere1RigidBody:set_position(playerPosition)

    sphere1RigidBody:set_rotation(Vector3.new(0,math.deg(playerScript.angleRotation),0))

    local velocity = Vector3.new(forwardVector.x * sphereSpeed, 0, forwardVector.z * sphereSpeed)
    sphere1RigidBody:set_velocity(velocity)

   
end

function disruptiveCharge()

    local playerPosition = playerTransf.position
    local playerRotation = playerTransf.rotation

     local forwardVector = Vector3.new(math.sin(playerScript.angleRotation), 0, math.cos(playerScript.angleRotation))
    
    local newPosition = Vector3.new((forwardVector.x + playerPosition.x) , (forwardVector.y+ playerPosition.y)  , (forwardVector.z+ playerPosition.z) )

    disruptorBulletTransf.position = newPosition
    disruptorBulletTransf.rotation = Vector3.new(0,math.deg(playerScript.angleRotation),0)

    disruptorBulletRb:set_position(playerPosition)

    disruptorBulletRb:set_rotation(Vector3.new(0,math.deg(playerScript.angleRotation),0))

    local velocity = Vector3.new(forwardVector.x * sphereSpeed, 0, forwardVector.z * sphereSpeed)
    disruptorBulletRb:set_velocity(velocity)

end

function chargedZoneUpdate(dt)

    

        
     if secondCounterTimes < 5 then
            
        secondCounter = secondCounter + dt
         --print("secondCounter", secondCounter)
     else
        print("chargedZone Finished")
        activateZone = false
     end

     if secondCounter >= 1 then
        
         

        local entities = current_scene:get_all_entities()

        for _, entity in ipairs(entities) do 
            if entity ~= chargeZone and entity:has_component("RigidbodyComponent") then
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
                print("closeeeee")
                    local name = entity:get_component("TagComponent").tag

                    if name == "EnemyOrk" then  
                        enemyOrkScript = entity:get_component("ScriptComponent")
                        if enemyOrkScript ~= nil then
                    
                            if enemyOrkScript.shieldHealth > 0 then
                                -- bulletDamageParticleComponent:emit(20)
                                enemyOrkScript.shieldHealth = enemyOrkScript.shieldHealth - (chargeZoneDamagePerSecond + chargeZoneDamagePerSecond * shieldMultiplier)
                                playerScript.makeDamage = true
                            else
                                -- bulletDamageParticleComponent:emit(20)
                                enemyOrkScript.enemyHealth = enemyOrkScript.enemyHealth - chargeZoneDamagePerSecond
                                playerScript.makeDamage = true
                            end
                            print("damage dealed")
                        end
                    end

                    if name == "EnemySupp" then
                        enemySuppScript = entity:get_component("ScriptComponent")
                        if enemySuppScript ~= nil then
                    
                            -- bulletDamageParticleComponent:emit(20)
                            enemySuppScript.enemyHealth = enemySuppScript.enemyHealth - chargeZoneDamagePerSecond
                            playerScript.makeDamage = true
                        end
                        print("damage dealed")
                    end              
                end
            end
        end
        
        
        secondCounter = 0
        secondCounterTimes = secondCounterTimes + 1
        print("secondCounterTimes", secondCounterTimes)

    end


   
    


end

function playShoot()
    rifle_reload:pause()
    burst_shot:pause()
    burst_shot:play()   
end

function playReload()
    rifle_reload:pause()
    rifle_reload:play()
end


function on_exit()
    -- Add cleanup code here
end