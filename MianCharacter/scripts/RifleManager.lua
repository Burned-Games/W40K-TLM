using = false
local sphere1RigidBody = nil
local sphere1RigidBodyComponent = nil
local sphereSpeed = 100
local contadorDisparo = 0
local maxReloadTime = 2.5
local reloadTime = 0
maxAmmo = 24
ammo = 0
local reloadTimeRifle = 0
local shootCoolDown = 0
local shootCoolDownRifle = 0.8
local damageRifle = 25
local tripleShootTimer = 0
local tripleShootCount = 0
local tripleShootInterval = 0.1

local shootParticlesComponent
local bulletDamageParticleComponent

local player = nil
local playerTransf = nil
local playerScript = nil

local shooted = true

local damage = 25

--audio
local burst_shot
local rifle_reload
local rifle_firerate = 0.8

local rifle_firerate_count = 0


function on_ready()

    player = current_scene:get_entity_by_name("Player")
    playerTransf = player:get_component("TransformComponent")
    playerScript = player:get_component("ScriptComponent")

    sphere1 = current_scene:get_entity_by_name("Sphere1")
    transformSphere1 = sphere1:get_component("TransformComponent")

    sphere1RigidBodyComponent = sphere1:get_component("RigidbodyComponent")
    sphere1RigidBody = sphere1:get_component("RigidbodyComponent").rb
    sphere1RigidBody:set_trigger(true)


    local burst_shot_entity = current_scene:get_entity_by_name("RifleDisparoAudio")
    burst_shot = burst_shot_entity:get_component("AudioSourceComponent")

    local rifle_reload_entity = current_scene:get_entity_by_name("RifleRecargaAudio")
    rifle_reload = rifle_reload_entity:get_component("AudioSourceComponent")

    shootParticlesComponent = current_scene:get_entity_by_name("ParticulasDisparo"):get_component("ParticlesSystemComponent")
    bulletDamageParticleComponent = current_scene:get_entity_by_name("ParticlePlayerBullet"):get_component("ParticlesSystemComponent")

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
                        bulletDamageParticleComponent:emit(20)
                        enemyOrkScript.shieldHealth = enemyOrkScript.shieldHealth - damage
                    else
                    bulletDamageParticleComponent:emit(20)
                    enemyOrkScript.enemyHealth = enemyOrkScript.enemyHealth - damage
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
                    
                    bulletDamageParticleComponent:emit(20)
                    enemySuppScript.enemyHealth = enemySuppScript.enemyHealth - damage
            
                end
            end
           
        end
    end)
end

function on_update(dt)
    if using then
        local rightTrigger = Input.get_axis_position(Input.axiscode.RightTrigger)
        local leftShoulder = Input.is_button_pressed(Input.controllercode.LeftShoulder)

        if ammo >= maxAmmo then
            if reloadTime == 0 then
                playReload()
            end
            reloadTime = reloadTime + dt
            if reloadTime >= maxReloadTime then
                
                ammo = 0
                reloadTime = 0
            end
        end
        if shooted == true then
            shootCoolDown = shootCoolDown + dt
        end

        if rightTrigger ~= 0 and (ammo < maxAmmo) and shootCoolDown >= shootCoolDownRifle then
        
            
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

        if leftShoulder then
            disruptiveCharge()
        end

        
    end
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
    print("Habilidad Especial")


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