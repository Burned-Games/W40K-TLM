using = false
-- Time
local current_time = 0  
local shotgun_fire_rate = 1.5 
local next_fire_time = 0 

-- ammo
maxAmmo = 6  -- maxammo
ammo = maxAmmo  -- curreamoo
local reload_time = 2.5  -- reloadtime
local is_reloading = false  -- inReloading?
local reload_end_time = 0  -- record_reload_time

--PlayerTransform
local playerTransf = nil
local playerScript = nil


-- Define the bullet speed
local bullet_speed = 10.0
local sphereSpeed = 100
-- BulletList
local bullets = {}
local bulletCount = 4  -- Bullet Num
local spreadAngle = 15  -- Bullet angle

local shootParticlesComponent
local bulletDamageParticleComponent
local damage = 1
local knockbackForce = 600  -- force


--granadas

local granadeCooldown= 1
local timerGranade = 0
local granadeEntity = nil
local granadeInitialSpeed = 12

local explosionRadius = 7.0
local explosionForce = 13.0
local explosionUpward = 2.0
local granadeParticlesExplosion = nil

local lbapretado = false
local dropGranade = false


local baseGranadePosition = nil       -- LB按下时记录玩家位置（固定起始点）
local targetGranadePosition = nil     -- 当前手雷目标位置
local granadeMoveSpeed = 0.1   

function on_ready()
    playerTransf = current_scene:get_entity_by_name("Player"):get_component("TransformComponent")
    playerScript = current_scene:get_entity_by_name("Player"):get_component("ScriptComponent")
    
    for i = 1, bulletCount do
        local bulletName = "Sphere" .. i  
        local bullet = {}
        
        bullet.entity = current_scene:get_entity_by_name(bulletName)
        bullet.transform = bullet.entity:get_component("TransformComponent")
        bullet.rigidBodyComponent = bullet.entity:get_component("RigidbodyComponent")
        bullet.rigidBody = bullet.rigidBodyComponent.rb
        bullet.rigidBody:set_trigger(true)
        
        table.insert(bullets, bullet)  -- save to table

        bullet.rigidBodyComponent:on_collision_enter(function(entityA, entityB)
            handle_bullet_collision(entityA, entityB)
        end)
    end

    shootParticlesComponent = current_scene:get_entity_by_name("ParticulasDisparo"):get_component("ParticlesSystemComponent")
    bulletDamageParticleComponent = current_scene:get_entity_by_name("ParticlePlayerBullet"):get_component("ParticlesSystemComponent")

    --Granada
   
    granadeEntity = current_scene:get_entity_by_name("Granade")
    transformGranade = granadeEntity:get_component("TransformComponent")
    granadeParticlesExplosion = granadeEntity:get_component("ParticlesSystemComponent")

    local rb = granadeEntity:get_component("RigidbodyComponent").rb
    rb:set_use_gravity(true)
    rb:set_mass(1.0) 
    rb:set_trigger(false)

    local rbComponent = granadeEntity:get_component("RigidbodyComponent")
    rbComponent:on_collision_enter(function(entityA, entityB)

        local nameA = entityA:get_component("TagComponent").tag
        local nameB = entityB:get_component("TagComponent").tag

        if nameA == "FloorCollider" or nameB == "FloorCollider" then
            explodeGranade()
        end
    end)


end


function on_update(dt)
    
    if using == true then
        -- updateTime
        current_time = current_time + dt  
        -- if in reload, check is fishing
        if is_reloading then
            if current_time >= reload_end_time then
                ammo = maxAmmo  -- reload bullet
                is_reloading = false
                print("Reload complet！")
            else
                --print("in reload")
                return  -- in reload cant shoot
            end
        end
        local rightTrigger = Input.get_axis_position(Input.axiscode.RightTrigger)
        -- shoot
        if rightTrigger ~= 0 then
            if ammo > 0 and current_time >= next_fire_time then
                ammo = ammo - 1  -- use bulle 
                print("fire")
                shoot(dt)
                next_fire_time = current_time + shotgun_fire_rate  -- next shoot time
            elseif ammo == 0 then
                --print("no bullet")
            else
                --print("fire colddown")
            end
        end

        -- reload
        if ammo==0 and not is_reloading then
            print("Start reload")
            is_reloading = true
            reload_end_time = current_time + reload_time  -- setting reload time
        end

        if Input.is_button_pressed(Input.controllercode.LeftShoulder) then
            lbapretado = true
            update_joystick_position()
        else
            if lbapretado then
                dropGranade = true
            end
            lbapretado = false
        end

        handleGranade(dt)
    end
end


function on_exit()
    -- Add cleanup code here
end


function handle_bullet_collision(entityA, entityB)
   
    local nameA = entityA:get_component("TagComponent").tag
    local nameB = entityB:get_component("TagComponent").tag
    
    local function damage_enemy(enemyEntity, bulletEntity)
        if enemyEntity then
            local enemyScript = enemyEntity:get_component("ScriptComponent")
            local enemyRigidBody = enemyEntity:get_component("RigidbodyComponent").rb
            local bulletTransform = bulletEntity:get_component("TransformComponent")
             
           
            if enemyScript then
                bulletDamageParticleComponent:emit(20)
                if enemyScript.shieldHealth and enemyScript.shieldHealth > 0 then
                    enemyScript.shieldHealth = enemyScript.shieldHealth - damage
                else
                    enemyScript.enemyHealth = enemyScript.enemyHealth - damage
                end
            end

            local enemyPosition = enemyEntity:get_component("TransformComponent").position
            local bulletPosition = bulletTransform.position
            local knockbackDirection = Vector3.normalize(Vector3.new(
                enemyPosition.x - bulletPosition.x,
                0,
                enemyPosition.z - bulletPosition.z
            ))
            
            print("Knockback Direction: ", knockbackDirection.x, knockbackDirection.z)
            
            local knockbackVelocity = Vector3.new(
                knockbackDirection.x * knockbackForce,
                0,
                knockbackDirection.z * knockbackForce
            )

            enemyRigidBody:apply_force(knockbackVelocity)
        end
    end
    
    if nameA == "EnemyOrk" or nameB == "EnemyOrk" then
        local enemy = (nameA == "EnemyOrk" and entityA) or (nameB == "EnemyOrk" and entityB)
        local bullet = (enemy == entityA) and entityB or entityA 
        damage_enemy(enemy, bullet)
    end


    if nameA == "EnemySupp" or nameB == "EnemySupp" then
        local enemy = (nameA == "EnemySupp" and entityA) or (nameB == "EnemySupp" and entityB)
        local bullet = (enemy == entityA) and entityB or entityA 
        damage_enemy(enemy, bullet)
    end
    
end


function update_joystick_position()
    local playerPos = playerTransf.position
    
    -- 初始化目标位置（不再需要视角锁定）
    if targetGranadePosition == nil then
        targetGranadePosition = Vector3.new(playerPos.x, playerPos.y + 1.5, playerPos.z)
    end

    -- 获取原始输入
    local inputX = Input.get_axis_position(Input.axiscode.RightX)
    local inputY = Input.get_axis_position(Input.axiscode.RightY)

    -- 直接根据输入计算偏移（X轴和Z轴平面）
    local offsetX = inputX * granadeMoveSpeed
    local offsetZ = inputY * granadeMoveSpeed

    -- 更新目标位置
    targetGranadePosition = Vector3.new(
        targetGranadePosition.x + offsetX,
        playerPos.y + 1.5,  -- Y轴保持玩家头顶高度
        targetGranadePosition.z + offsetZ
    )

    -- 更新手雷实体位置
    granadeEntity:get_component("TransformComponent").position = targetGranadePosition

    print("Joystick Input (X, Y):", inputX, inputY)
    print("Target Granade Position:", targetGranadePosition)
end

function handleGranade(dt)
    if timerGranade > 0 then
        timerGranade = timerGranade - dt
    end

    if  dropGranade and timerGranade <= 0 then
        throwGranade()
        dropGranade = false
        --escopetaAudioManagerScript:playLaunchGranade()
        timerGranade = granadeCooldown
    end
end

function throwGranade()
    if granadeEntity ~= nil and targetGranadePosition ~= nil then
        local rb = granadeEntity:get_component("RigidbodyComponent").rb
        local playerPos = playerTransf.position

        -- 设置手雷起始位置为玩家上方
        local startPos = Vector3.new(playerPos.x, playerPos.y + 1.5, playerPos.z)
        rb:set_position(startPos)

        -- 计算从起始位置到目标位置的方向向量
        local direction = Vector3.new(
            targetGranadePosition.x - startPos.x,
            targetGranadePosition.y - startPos.y,
            targetGranadePosition.z - startPos.z
        )
        direction = Vector3.normalize(direction)

        -- 计算投掷速度（手动对各分量进行乘法计算）
        local velocity = Vector3.new(
            direction.x * granadeInitialSpeed,
            direction.y * granadeInitialSpeed,
            direction.z * granadeInitialSpeed
        )
        rb:set_velocity(velocity)
        throwingGranade = true

        print("Throwing Granade from:", startPos.x, startPos.y, startPos.z)
        print("Throw Direction:", direction.x, direction.y, direction.z)
        print("Granade Velocity:", velocity.x, velocity.y, velocity.z)

        -- 投掷后重置目标位置和锁定角度，便于下次使用
        targetGranadePosition = nil
        baseViewAngleForGranade = nil
    end
end





function explodeGranade()
    if granadeEntity ~= nil then
        local rb = granadeEntity:get_component("RigidbodyComponent").rb
        local explosionPos = rb:get_position()

        local entities = current_scene:get_all_entities()

        for _, entity in ipairs(entities) do 
            if entity ~= granadeEntity and entity:has_component("RigidbodyComponent") then 
                local entityRb = entity:get_component("RigidbodyComponent").rb
                local entityPos = entityRb:get_position()

                local direction = Vector3.new(
                    entityPos.x - explosionPos.x,
                    entityPos.y - explosionPos.y,
                    entityPos.z - explosionPos.z
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

                if distance < explosionRadius then
                    local forceFactor = (explosionRadius - distance) / explosionRadius
                    direction.y = direction.y + explosionUpward
                    local finalForce = Vector3.new(
                        direction.x * explosionForce * forceFactor,
                        direction.y * explosionForce * forceFactor,
                        direction.z * explosionForce * forceFactor
                    )
                    entityRb:apply_impulse(finalForce)

                    local rotationFactor = explosionForce * forceFactor 
                    local randomRotation = Vector3.new(
                        (math.random() - 0.5) * rotationFactor,
                        (math.random() - 0.5) * rotationFactor,
                        (math.random() - 0.5) * rotationFactor
                    )

                    entityRb:set_angular_velocity(randomRotation)
                end
            end
        end
        
        rb:set_velocity(Vector3.new(0, 0, 0))
        rb:set_angular_velocity(Vector3.new(0, 0, 0))
        --escopetaAudioManagerScript:playExplodeGranade()
        granadeParticlesExplosion:emit(10)
        throwingGranade = false
    end
end

