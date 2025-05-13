

local radiusAttack = 2.5
local damage = 65
local HpStealed = 20
coolDown = 6
coolDownCounter = 6
local impulseDirection = nil
local impulseForce = 15

local player = nil
local playerTransf = nil
local playerScript = nil

local entities = nil
local enemies = nil
slashed = false

local slashCounter = 0
local slashTime = 0.8
slasheeed = false
--local ----------shootParticlesComponent = nil
--local --bulletDamageParticleComponent = nil

sawSwordAvailable = true

--Particles
local particle_blood_normal = nil
local particle_blood_spark = nil
local particle_blood_normal_transform = nil
local particle_blood_spark_transform = nil
local cameraScript = nil

-- Audio
local meleeHitSFX = nil
local meleeAttackSFX = nil

-- UpgradeManager
local workbenchUIManagerScript = nil
local pauseScript = nil

function on_ready()
    player = current_scene:get_entity_by_name("Player")
    playerTransf = player:get_component("TransformComponent")
    playerScript = current_scene:get_entity_by_name("Player"):get_component("ScriptComponent")

    --Particles
    particle_blood_normal = current_scene:get_entity_by_name("particle_blood_normal"):get_component("ParticlesSystemComponent")
    particle_blood_spark = current_scene:get_entity_by_name("particle_blood_spark"):get_component("ParticlesSystemComponent")
    particle_blood_normal_transform = current_scene:get_entity_by_name("particle_blood_normal"):get_component("TransformComponent")
    particle_blood_spark_transform = current_scene:get_entity_by_name("particle_blood_spark"):get_component("TransformComponent")

    -- Audio
    meleeHitSFX = current_scene:get_entity_by_name("MeleeHit"):get_component("AudioSourceComponent")
    meleeAttackSFX = current_scene:get_entity_by_name("MeleeAttack"):get_component("AudioSourceComponent")


    cameraScript = current_scene:get_entity_by_name("Camera"):get_component("ScriptComponent")

    workbenchUIManagerScript = current_scene:get_entity_by_name("WorkBenchUIManager"):get_component("ScriptComponent")
    pauseScript = current_scene:get_entity_by_name("PauseBase"):get_component("ScriptComponent")

end

function on_update(dt)

    if playerScript.health <= 0 or workbenchUIManagerScript.isWorkBenchOpen or pauseScript.isPaused then
        return
    end

    local rightShoulder = Input.get_button(Input.action.Melee)

    if (rightShoulder == Input.state.Down or Input.is_key_pressed(Input.keycode.U)) and sawSwordAvailable == true then
        
        slasheeed = true
            
        sawSwordAvailable = false

        meleeAttackSFX:play()

        local dashDirection = nil

        if playerScript.isMoving == false then
            dashDirection = Vector3.new(math.sin(playerScript.angleRotation), 0, math.cos(playerScript.angleRotation))
        else
            dashDirection = Vector3.new(playerScript.moveDirectionX, 0, playerScript.moveDirectionY)
        end
        local impulse = Vector3.new(dashDirection.x * 6, dashDirection.y * 6, dashDirection.z * 6)

        playerScript.playerRb:apply_impulse(Vector3.new(impulse.x, impulse.y, impulse.z))

        playerScript.meleeImpulseApplied = true
        
    end

    if slasheeed == true then
        if slashCounter == 0 then
            
        end

        slashCounter = slashCounter + dt
        
        if slashCounter >= slashTime and slashed == false then
            Slash()
            slashed = true
            playerScript.meleeImpulseApplied = false
        else
            --playerScript.moveSpeed = 1
        end
        
    else
        slashCounter = 0
    end
    
    if sawSwordAvailable == false then

        coolDownCounter = coolDownCounter + dt
        if coolDownCounter >= coolDown then
            sawSwordAvailable = true
            coolDownCounter = 0
        end
    end

end


function Slash()
    for _, entity in ipairs(cameraScript.enemies) do 
        if entity ~= player and entity:has_component("RigidbodyComponent") and entity:is_active() then
            local entityRb = entity:get_component("RigidbodyComponent").rb
            local entityPos = entityRb:get_position()

            local direction = Vector3.new(
                entityPos.x - playerTransf.position.x,
                entityPos.y - playerTransf.position.y,
                entityPos.z - playerTransf.position.z
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

            if distance < radiusAttack then
                local enemyTag = nil
                local enemyScript = nil
                local enemyInstance = nil

                if entity ~= nil then    
                    enemyTag = entity:get_component("TagComponent").tag
                    enemyScript = entity:get_component("ScriptComponent")
                end

                if entity ~= nil then
                    if enemyScript ~= nil then
                        local enemyTransform = entity:get_component("TransformComponent")
                        local enemyPos = enemyTransform.position
            
                        particle_blood_normal_transform.position = enemyPos
                        particle_blood_spark_transform.position = enemyPos

                        if enemyTag == "BarrilDestruible" or enemyTag == "CajaDestruible" or enemyTag == "CajaDestruibleV2" or enemyTag == "ScrapPile" then 
                            local script = entity:get_component("ScriptComponent")
                            script:give_phisycs()
                            script.hasDestroyed = true


                        else
                            if enemyTag == "EnemyRange" or enemyTag == "EnemyRange1" or enemyTag == "EnemyRange2" or enemyTag == "EnemyRange3" or enemyTag == "EnemyRange4" or enemyTag == "EnemyRange5" or enemyTag == "EnemyRange6" then
                                enemyInstance = enemyScript.range
                            elseif enemyTag == "EnemySupport" then
                                enemyInstance = enemyScript.support
                            elseif enemyTag == "EnemyTank" or enemyTag == "EnemyTank1" or enemyTag == "EnemyTank2" or enemyTag == "EnemyTank3" or enemyTag == "EnemyTank4" or enemyTag == "EnemyTank5" or enemyTag == "EnemyTank6" then
                                enemyInstance = enemyScript.tank
                            elseif enemyTag == "EnemyKamikaze" then
                                enemyInstance = enemyScript.kamikaze
                            end
                            enemyInstance:take_damage(damage)
                            particle_blood_normal:emit(5)
                            particle_blood_spark:emit(5)

                            meleeHitSFX:play()

                        
                            if playerScript.health + HpStealed >= playerScript.maxHealth then
                                playerScript.health = playerScript.maxHealth
                            else
                                playerScript.health = playerScript.health + HpStealed
                            end
                            playerScript.makeDamage = true
                        end
                        
                        enemyInstance.isPushed = true
                        impulseDirection = Vector3.new(
                        entityPos.x - playerTransf.position.x,
                        entityPos.y - playerTransf.position.y,
                        entityPos.z - playerTransf.position.z)
                        entityRb:apply_impulse(Vector3.new(impulseDirection.x * impulseForce, impulseDirection.y * impulseForce, impulseDirection.z * impulseForce))

                    end
                end
            end
        end
    end         

   
end





function on_exit()

end