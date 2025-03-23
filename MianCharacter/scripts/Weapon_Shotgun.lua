using = false
-- 记录游戏当前运行时间
local current_time = 0  
local shotgun_fire_rate = 1.5  -- 设定射速（秒/每次射击）
local next_fire_time = 0  -- 记录下一次允许射击的时间

-- 弹夹相关
maxAmmo = 6  -- 弹夹最大容量
ammo = maxAmmo  -- 当前子弹数
local reload_time = 2.5  -- 换弹时间
local is_reloading = false  -- 是否正在换弹
local reload_end_time = 0  -- 记录换弹完成的时间

--PlayerTransform
local playerTransf = nil
local playerScript = nil


-- Define the bullet speed
local bullet_speed = 10.0

--Bullet
local sphere1RigidBody = nil
local sphere1RigidBodyComponent = nil
local sphereSpeed = 100
local sphere1 = nil

local shootParticlesComponent
local bulletDamageParticleComponent

function on_ready()
    playerTransf = current_scene:get_entity_by_name("Player"):get_component("TransformComponent")
    playerScript = current_scene:get_entity_by_name("Player"):get_component("ScriptComponent")
    
    sphere1 = current_scene:get_entity_by_name("Sphere1")
    transformSphere1 = sphere1:get_component("TransformComponent")

    sphere1RigidBodyComponent = sphere1:get_component("RigidbodyComponent")
    sphere1RigidBody = sphere1:get_component("RigidbodyComponent").rb
    sphere1RigidBody:set_trigger(true)

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
    
    if using == true then
        -- 更新游戏运行时间
        current_time = current_time + dt  
        -- 如果正在换弹，检查是否完成
        if is_reloading then
            if current_time >= reload_end_time then
                ammo = maxAmmo  -- 重新装满子弹
                is_reloading = false
                print("Reload complet！")
            else
                print("in reload")
                return  -- 换弹过程中不能射击
            end
        end

        -- 射击逻辑
        if Input.is_key_pressed(Input.keycode.U) then
            if ammo > 0 and current_time >= next_fire_time then
                ammo = ammo - 1  -- 消耗子弹
                print("fire")
                shoot(dt)
                next_fire_time = current_time + shotgun_fire_rate  -- 设定下一次开枪时间
            elseif ammo == 0 then
                print("no bullet")
            else
                print("fire colddown")
            end
        end

        -- 换弹逻辑
        if Input.is_key_pressed(Input.keycode.R) and not is_reloading then
            print("Start reload")
            is_reloading = true
            reload_end_time = current_time + reload_time  -- 设定换弹结束时间
        end
    end
end


function on_exit()
    -- Add cleanup code here
end


function shoot(dt)
    
    shootCoolDownTimer = shootCoolDown



    local playerPosition = playerTransf.position
    local playerRotation = playerTransf.rotation


    local forwardVector = Vector3.new(math.sin(playerScript.angleRotation), 0, math.cos(playerScript.angleRotation))
    
    local newPosition = Vector3.new((forwardVector.x + playerPosition.x) , (forwardVector.y+ playerPosition.y)  , (forwardVector.z+ playerPosition.z) )

    transformSphere1.position = newPosition
    transformSphere1.rotation = Vector3.new(0,math.deg(playerScript.angleRotation),0)

    sphere1RigidBody:set_position(playerPosition)

    sphere1RigidBody:set_rotation(Vector3.new(0,math.deg(playerScript.angleRotation),0))

    local velocity = Vector3.new(forwardVector.x * sphereSpeed, 0, forwardVector.z * sphereSpeed)
    sphere1RigidBody:set_velocity(velocity)

   
end


