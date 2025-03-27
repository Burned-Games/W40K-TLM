
using = false
local radiusAttack = 2.5
local damage = 50
local HpStealed = 20
local coolDown = 6
local coolDownCounter = 6

local playerScript = nil
local shootParticlesComponent = nil
local bulletDamageParticleComponent = nil

function on_ready()

    playerScript = current_scene:get_entity_by_name("Player"):get_component("ScriptComponent")

    shootParticlesComponent = current_scene:get_entity_by_name("ParticulasDisparo"):get_component("ParticlesSystemComponent")
    bulletDamageParticleComponent = current_scene:get_entity_by_name("ParticlePlayerBullet"):get_component("ParticlesSystemComponent")


end

function on_update(dt)
    if using then
        local rightTrigger = Input.get_button(Input.action.Shoot)

        if rightTrigger == Input.state.Down and coolDownCounter >= coolDown then

            Slash()
            
            coolDownCounter = 0
        end

        if coolDownCounter < coolDown then
            coolDownCounter = coolDownCounter + dt
        end
    end
end


function Slash()
    
    for _, entity in ipairs(entities) do 
        if entity ~= self and entity:has_component("RigidbodyComponent") then
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

            if distance < radiusAttack then
                local name = entity:get_component("TagComponent").tag

                if name == "EnemyOrk" then  
                    enemyOrkScript = entity:get_component("ScriptComponent")
                    if enemyOrkScript ~= nil then
                
                        if enemyOrkScript.shieldHealth > 0 then
                            bulletDamageParticleComponent:emit(20)
                            enemyOrkScript.shieldHealth = enemyOrkScript.shieldHealth - damage
                            playerScript.makeDamage = true
                            playerScript.playerHealth = HpStealed
                        else
                            bulletDamageParticleComponent:emit(20)
                            enemyOrkScript.enemyHealth = enemyOrkScript.enemyHealth - damage
                            playerScript.makeDamage = true
                            playerScript.playerHealth = HpStealed
                        end
                        print("damage dealed")
                    end
                end

                if name == "EnemySupp" then
                    enemySuppScript = entity:get_component("ScriptComponent")
                    if enemySuppScript ~= nil then
                
                        bulletDamageParticleComponent:emit(20)
                        enemySuppScript.enemyHealth = enemySuppScript.enemyHealth - damage
                        playerScript.makeDamage = true
                        playerScript.playerHealth = HpStealed
                    end
                    print("damage dealed")
                end              
            end
        end
    end

   
end





function on_exit()

end