

local radiusAttack = 5
local damage = 50
local HpStealed = 10
coolDown = 6
coolDownCounter = 6
local impulseDirection = nil
local impulseForce = 10

local player = nil
local playerTransf = nil
local playerScript = nil

local entities = nil
local enemies = nil
slashed = false
--local ----------shootParticlesComponent = nil
--local --bulletDamageParticleComponent = nil

sawSwordAvailable = true

function on_ready()
    player = current_scene:get_entity_by_name("Player")
    playerTransf = player:get_component("TransformComponent")
    playerScript = current_scene:get_entity_by_name("Player"):get_component("ScriptComponent")

    --------------shootParticlesComponent = current_scene:get_entity_by_name("ParticulasDisparo"):get_component("ParticlesSystemComponent")
    ----bulletDamageParticleComponent = current_scene:get_entity_by_name("ParticlePlayerBullet"):get_component("ParticlesSystemComponent")

    entities = current_scene:get_all_entities()
    enemies = {} 
    for _, entity in ipairs(entities) do 
        if entity:get_component("TagComponent").tag == "EnemyOrk" or entity:get_component("TagComponent").tag == "EnemySupp" then
            print("sooooooooooooooooo")
            table.insert(enemies, entity)
        end
    end

end

function on_update(dt)

    local rightShoulder = Input.get_button(Input.action.Melee)

    if (rightShoulder == Input.state.Down or Input.is_key_pressed(Input.keycode.U)) and sawSwordAvailable == true then
        slashed = true
        Slash()
            
        sawSwordAvailable = false
        
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
    
    for _, entity in ipairs(enemies) do 
        if entity ~= player and entity:has_component("RigidbodyComponent") then
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
                local name = entity:get_component("TagComponent").tag

                if name == "EnemyOrk" then  
                    enemyOrkScript = entity:get_component("ScriptComponent")
                    if enemyOrkScript ~= nil then
                
                        if enemyOrkScript.shieldHealth > 0 then
                            --bulletDamageParticleComponent:emit(20)
                            enemyOrkScript.shieldHealth = enemyOrkScript.shieldHealth - damage
                            playerScript.makeDamage = true
                            playerScript.playerHealth = playerScript.playerHealth + HpStealed
                        else
                            ----bulletDamageParticleComponent:emit(20)
                            enemyOrkScript.enemyHealth = enemyOrkScript.enemyHealth - damage
                            playerScript.makeDamage = true
                            playerScript.playerHealth = playerScript.playerHealth + HpStealed
                        end
                        enemyOrkScript.pushed = true
                        impulseDirection = Vector3.new(
                        entityPos.x - playerTransf.position.x,
                        entityPos.y - playerTransf.position.y,
                        entityPos.z - playerTransf.position.z)
                        entityRb:apply_impulse(Vector3.new(impulseDirection.x * impulseForce, impulseDirection.y * impulseForce, impulseDirection.z * impulseForce))
                    end
                end

                if name == "EnemySupp" then
                    enemySuppScript = entity:get_component("ScriptComponent")
                    if enemySuppScript ~= nil then
                
                        ----bulletDamageParticleComponent:emit(20)
                        enemySuppScript.enemyHealth = enemySuppScript.enemyHealth - damage
                        playerScript.makeDamage = true
                        playerScript.playerHealth = playerScript.playerHealth + HpStealed

                        enemySuppScript.pushed = true
                        impulseDirection = Vector3.new(
                        entityPos.x - playerTransf.position.x,
                        entityPos.y - playerTransf.position.y,
                        entityPos.z - playerTransf.position.z)
                        entityRb:apply_impulse(Vector3.new(impulseDirection.x * impulseForce, impulseDirection.y * impulseForce, impulseDirection.z * impulseForce))
                    end
                    
                end 
                
                if name == "EnemyKamikaze" then  
                    enemyOrkScript = entity:get_component("ScriptComponent")
                    if enemyOrkScript ~= nil then
                
                        if enemyOrkScript.shieldHealth > 0 then
                            --bulletDamageParticleComponent:emit(20)
                            enemyOrkScript.shieldHealth = enemyOrkScript.shieldHealth - damage
                            playerScript.makeDamage = true
                            playerScript.playerHealth = playerScript.playerHealth + HpStealed
                        else
                            ----bulletDamageParticleComponent:emit(20)
                            enemyOrkScript.enemyHealth = enemyOrkScript.enemyHealth - damage
                            playerScript.makeDamage = true
                            playerScript.playerHealth = playerScript.playerHealth + HpStealed
                        end
                        enemyOrkScript.pushed = true
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