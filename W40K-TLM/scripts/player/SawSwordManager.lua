

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
        if entity:get_component("TagComponent").tag == "EnemyRange" or entity:get_component("TagComponent").tag == "EnemySupport" or entity:get_component("TagComponent").tag == "EnemyKamikaze" or entity:get_component("TagComponent").tag == "EnemyTank" or entity:get_component("TagComponent").tag == "MainBoss" then
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
                        playerScript.playerHealth = playerScript.playerHealth + HpStealed
                        playerScript.makeDamage = true

                        enemyScript.pushed = true
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