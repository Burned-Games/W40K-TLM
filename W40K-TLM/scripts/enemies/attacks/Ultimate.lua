local stats_data = require("scripts/utils/enemy_stats")

local enemyTransf = nil
local enemyScript = nil
local player = nil
local playerTransf = nil
local playerScript = nil
local ultimateTransf = nil
local pillarToDestroy = nil

-- Audio
local bossChargeUltimateSFX = nil
local bossUltimateExplosionSFX = nil

-- Timers
local ultiAttackTimer = 0.0
local ultiHittingTimer = 0.0
ultiTimer = 0.0
local colliderUpdateInterval = 0.1

-- Bools
ultimateThrown = false
ultimateCasting = false
local isUltimateDamaging = false

-- Vector3
local ultimateVibration = Vector3.new(1, 1, 200)

ultimateDamage = 0
ultiAttackDuration = 0.0
ultiHittingDuration = 0.0

-- Lists
local scalingAttacks = {}

function on_ready()

    -- Main Boss
    enemyTransf = current_scene:get_entity_by_name("MainBoss"):get_component("TransformComponent")
    enemyScript = current_scene:get_entity_by_name("MainBoss"):get_component("ScriptComponent")

    -- Player
    player = current_scene:get_entity_by_name("Player")
    playerTransf = player:get_component("TransformComponent")
    playerScript = player:get_component("ScriptComponent")

    -- Ultimate
    ultimateTransf = self:get_component("TransformComponent")

    -- Audio
    bossChargeUltimateSFX = current_scene:get_entity_by_name("BossChargeUltimateSFX"):get_component("AudioSourceComponent")
    bossUltimateExplosionSFX = current_scene:get_entity_by_name("BossUltimateExplosionSFX"):get_component("AudioSourceComponent")

    -- Level
    local enemy_type = "main_boss"
    local level = 1
    stats = stats_data[enemy_type] and stats_data[enemy_type][level]
    -- Debug in case is not working
    if not stats then log("No stats for type: " .. enemy_type .. " level: " .. level) return end

    ultimateDamage = stats.ultimateDamage
    ultiAttackDuration = stats.ultiAttackDuration
    ultiHittingDuration = stats.ultiHittingDuration

end

function on_update(dt)

    if enemyScript.main_boss.isDead then return end

    if enemyScript.main_boss.isRaging then
        ultiTimer = ultiTimer + dt
    end

    if ultimateThrown then
        bossChargeUltimateSFX:play()
        enemyScript.main_boss.invulnerable = true
        ultiAttackTimer = ultiAttackTimer + dt

        if ultiAttackTimer >= ultiAttackDuration then
            ultimateCasting = true
        end

        if ultimateCasting then
            if not isUltimateDamaging then
                isUltimateDamaging = true
                bossUltimateExplosionSFX:play()
            end

            ultiHittingTimer = ultiHittingTimer + dt

            check_ulti_collision()
            Input.send_rumble(ultimateVibration.x, ultimateVibration.y, ultimateVibration.z)
            
            if ultiHittingTimer >= ultiHittingDuration then
                ultimateTransf.position = Vector3.new(-500, 0, -150)

                ultimateThrown = false
                ultimateCasting = false
                isUltimateDamaging = false
                enemyScript.main_boss.invulnerable = false
                ultiAttackTimer = 0.0
                ultiHittingTimer = 0.0
                ultiTimer = 0.0

                check_ulti_collision()

                if pillarToDestroy ~= nil then
                    manage_destroyed_pillar()
                end
            end
        end
    end

    update_scaling_attacks(dt)
end

function ultimate()
    ultimateTransf.position = Vector3.new(enemyTransf.position.x, enemyTransf.position.y, enemyTransf.position.z)
    ultimateTransf.scale = Vector3.new(1, 1, 1)

    -- Configurar el escalado
    table.insert(scalingAttacks, {
        transform = ultimateTransf, 
        elapsed = 0,
        duration = ultiAttackDuration,
        startScale = Vector3.new(1, 1, 1),
        targetScale = Vector3.new(24, 24, 24) 
    })

    ultimateThrown = true
    ultiTimer = 0.0
    ultiAttackTimer = 0.0
end

function check_ulti_collision()

    if enemyScript.main_boss.currentAnim ~= enemyScript.main_boss.ultiAnim then
        enemyScript.main_boss:play_blocking_animation(enemyScript.main_boss.ultiAnim, enemyScript.main_boss.ultiDuration)
    end

    local origin = ultimateTransf.position
    local direction = Vector3.new(playerTransf.position.x - origin.x, 0, playerTransf.position.z - origin.z)
    local rayLength = 40
    local tag = "Pilar"

    local rayHit = Physics.Raycast(origin, direction, rayLength)

    if enemyScript.main_boss:detect(rayHit, player) then
        if isUltimateDamaging then
            log("Player hit with ultimate")
            enemyScript.main_boss:make_damage(ultimateDamage)
            isUltimateDamaging = false
        end
    elseif enemyScript.main_boss:detect_by_tag(rayHit, tag) then
        log("Pillar hit with ultimate")
        pillarToDestroy = rayHit.hitEntity
    end

    if playerScript.godMode then
        Physics.DebugDrawRaycast(origin, direction, rayLength, Vector4.new(1, 0, 0, 1), Vector4.new(1, 1, 0, 1))
    end

end

function update_scaling_attacks(dt)

    for i = #scalingAttacks, 1, -1 do
        local data = scalingAttacks[i]
        data.elapsed = data.elapsed + dt
        data.colliderTimer = (data.colliderTimer or 0) + dt

        local t = math.min(data.elapsed / data.duration, 1.0)
        local newScale = Vector3.new(
            data.startScale.x + (data.targetScale.x - data.startScale.x) * t,
            data.startScale.y + (data.targetScale.y - data.startScale.y) * t,
            data.startScale.z + (data.targetScale.z - data.startScale.z) * t
        )

        if data.transform then
            data.transform.scale = newScale
        end

        if data.colliderTimer >= colliderUpdateInterval then
            if data.transformRb then
                data.transformRb.rb:get_collider():set_sphere_radius(newScale.x * 0.5)
                data.transformRb.rb:set_trigger(true)
            end
            data.colliderTimer = 0.0
        end

        if data.elapsed >= data.duration then
            if data.transform then
                data.transform.scale = data.targetScale
            end
            if data.transformRb then
                data.transformRb.rb:get_collider():set_sphere_radius(data.targetScale.x * 0.5)
                data.transformRb.rb:set_trigger(true)
            end
            table.remove(scalingAttacks, i)
        end
    end
    
end

function manage_destroyed_pillar()

    local pillarRb = pillarToDestroy:get_component("RigidbodyComponent").rb
    pillarRb:set_position(Vector3.new(-800, 0, -800))

    pillarToDestroy = nil

end

function on_exit() end