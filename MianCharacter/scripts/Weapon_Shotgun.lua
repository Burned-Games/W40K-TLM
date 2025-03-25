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
local knockbackForce = 100  -- force


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
    end
end


function on_exit()
    -- Add cleanup code here
end


function shoot(dt)
    local playerPosition = playerTransf.position
    local baseAngle = playerScript.angleRotation  
    
    for i, bullet in ipairs(bullets) do
        local angleOffset = (i - (bulletCount / 2)) * spreadAngle  -- angle
        local shootAngle = baseAngle + math.rad(angleOffset) 
        
        local forwardVector = Vector3.new(math.sin(shootAngle), 0, math.cos(shootAngle))
        local newPosition = Vector3.new(
            playerPosition.x + forwardVector.x,
            playerPosition.y,
            playerPosition.z + forwardVector.z
        )
        
        bullet.transform.position = newPosition
        bullet.transform.rotation = Vector3.new(0, math.deg(shootAngle), 0)
        bullet.rigidBody:set_position(playerPosition)
        bullet.rigidBody:set_rotation(Vector3.new(0, math.deg(shootAngle), 0))
        
        local velocity = Vector3.new(forwardVector.x * sphereSpeed, 0, forwardVector.z * sphereSpeed)
        bullet.rigidBody:set_velocity(velocity)
    end
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
            enemyRigidBody:set_velocity(knockbackVelocity)
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

