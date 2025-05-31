local stats_data = require("scripts/utils/enemy_stats")

--Prefabs locations
local fistIndicatorPrefab = "prefabs/Enemies/attacks/BossFistIndicator.prefab"

-- Fists
local fistAttacks = {}
local fistAnimator = {}
local fistTransf = {}
local fistRbComponent = {}
local fistRbs = {}

-- Fists Indicators
local fistIndicators = {}
local fistIndicatorsScript = {}
local fistIndicatorsTransform = {}

-- Arena
local arenaCenter = nil
local playerTransf = nil
local enemyScript = nil

-- Lists
local fistsUsed = {}
local fistsToUseThisWave = {}
local fistPositions = {}
local scalingAttacks = {}

-- Timers
fistsDamageCooldown = 0.0
local fistsAttackDelay = 2.0
local timeSinceLastFistHit = 0.0
local fistsAttackDelayTimer = 0.0
local rangeAttackTimer = 0.0
rangeAttackDuration = 0.0
local colliderUpdateInterval = 0.1
local fistsExtraTime = 0.5

-- Ints
local fistMaxNumbers = 25
local fistsPerWave = 5
local radius = 6
rangeDamage = 0
fistTargetScale = 0

-- Bools
fistsThrown = false
fistsAttackPending = false
local isFistsDamaging = true

-- Animation
local currentAnim = 0

-- Audio
local bossSmashDescendSFX = nil
local bossSmashImpactSFX = nil

function on_ready()

    -- Main Boss
    enemyScript = current_scene:get_entity_by_name("MainBoss"):get_component("ScriptComponent")

    -- Player
    playerTransf = current_scene:get_entity_by_name("Player"):get_component("TransformComponent")

    -- Audio
    bossSmashDescendSFX = current_scene:get_entity_by_name("BossSmashDescendSFX"):get_component("AudioSourceComponent")
    bossSmashImpactSFX = current_scene:get_entity_by_name("BossSmashImpactSFX"):get_component("AudioSourceComponent")

    -- Arena
    arenaCenter = current_scene:get_entity_by_name("ArenaCenter"):get_component("TransformComponent").position

    -- Fists
    local fistChildren = self:get_children()
    local i = 1
    for _, child in ipairs(fistChildren) do
        child:set_active(true)
        fistAttacks[i] = child
        fistAnimator[i] = child:get_component("AnimatorComponent")
        fistTransf[i] = child:get_component("TransformComponent")
        fistRbComponent[i] = child:get_component("RigidbodyComponent")
        fistRbs[i] = fistRbComponent[i].rb
        fistRbs[i]:set_position(Vector3.new(-500, 0, -500))
        fistRbs[i]:set_trigger(true)
        
        i = i + 1
    end

    -- Fists Indicators
    for i = 1, fistMaxNumbers do
        local fistIndicator = instantiate_prefab(fistIndicatorPrefab)
        fistIndicators[i] = fistIndicator
        fistIndicatorsScript[i] = fistIndicators[i]:get_component("ScriptComponent")
        fistIndicatorsTransform[i] = fistIndicators[i]:get_component("TransformComponent")
        fistIndicatorsTransform[i].position = Vector3.new(-1000, 0, -1000)
        fistIndicatorsTransform[i].scale = Vector3.new(5, 0, 5)
        fistIndicatorsScript[i]:on_ready()
    end

    -- Level
    local enemy_type = "main_boss"
    local level = 1
    stats = stats_data[enemy_type] and stats_data[enemy_type][level]
    -- Debug in case is not working
    if not stats then log("No stats for type: " .. enemy_type .. " level: " .. level) return end

    fistsDamageCooldown = stats.fistsDamageCooldown
    rangeAttackDuration = stats.rangeAttackDuration
    rangeDamage = stats.rangeDamage
    fistTargetScale = stats.fistTargetScale


    -- Collision
    for i = 1, fistMaxNumbers do
        fistRbComponent[i]:on_collision_stay(function(entityA, entityB)
            local nameA = entityA:get_component("TagComponent").tag
            local nameB = entityB:get_component("TagComponent").tag

            if (nameA == "Player" or nameB == "Player") and isFistsDamaging then
                log("Player in fist")
                enemyScript.main_boss:make_damage(rangeDamage)
                isFistsDamaging = false
            end
        end)
    end

end

function on_update(dt)
    if enemyScript.main_boss.isDead then return end

    if fistsAttackPending then
        fistsAttackDelayTimer = fistsAttackDelayTimer + dt
        if fistsAttackDelayTimer >= fistsAttackDelay then
            execute_fists_attack()
            fistsAttackPending = false
            fistsAttackDelayTimer = 0.0
            fistsThrown = true
        end
    end

    if not isFistsDamaging then
        timeSinceLastFistHit = timeSinceLastFistHit + dt
        if timeSinceLastFistHit > fistsDamageCooldown then
            isFistsDamaging = true
            timeSinceLastFistHit = 0.0
        end
    end

    if fistsThrown then
        rangeAttackTimer = rangeAttackTimer + dt

        if rangeAttackTimer >= 0.5 then
            if currentAnim ~= 0 then
                currentAnim = 0
                for i = 1, fistMaxNumbers do
                    fistAnimator[i]:set_current_animation(currentAnim)
                end
                bossSmashDescendSFX:pause()
                bossSmashImpactSFX:play()
            end
        end
    end

    update_scaling_attacks(dt)
end

function fist()

    fistsAttackPending = true
    fistsAttackDelayTimer = 0.0

    local arenaRadius = 20
    fistsToUseThisWave = get_next_fists()

    for _, i in ipairs(fistsToUseThisWave) do
        local attempts = 0
        local maxAttempts = 10
        local valid = false
        local pos = nil

        if i == 1 then
            pos = Vector3.new(playerTransf.position.x, 0, playerTransf.position.z)
        else
            while not valid and attempts < maxAttempts do
                local angle = math.rad(math.random() * 360)
                local randRadius = radius + math.random() * 5
                local offsetX = math.cos(angle) * randRadius + (math.random() * 2 - 1) * 5
                local offsetZ = math.sin(angle) * randRadius + (math.random() * 2 - 1) * 5
                pos = Vector3.new(playerTransf.position.x + offsetX, 0, playerTransf.position.z + offsetZ)

                if is_within_arena(pos, arenaCenter, arenaRadius) then
                    valid = true
                end

                attempts = attempts + 1
            end

            if not valid then
                pos = Vector3.new(playerTransf.position.x, 0, playerTransf.position.z)
            end
        end

        fistPositions[i] = pos

        if fistIndicatorsTransform[i] then
            fistIndicatorsTransform[i].position = pos
            fistIndicatorsTransform[i].position.y = 0.1
        end
        if fistIndicatorsScript[i] then
            fistIndicatorsScript[i]:startIndicator()
        end
    end
end

function execute_fists_attack()
    log("Fists Attack")

    for _, i in ipairs(fistsToUseThisWave) do
        local pos = fistPositions[i]
        if fistRbComponent[i] and pos then
            fistRbComponent[i].rb:set_position(pos)
            currentAnim = 1
            fistAnimator[i]:set_current_animation(currentAnim)
            bossSmashDescendSFX:play()

            fistRbComponent[i].rb:get_collider():set_sphere_radius(1.0)
            fistRbComponent[i].rb:set_trigger(true)

            table.insert(scalingAttacks, {
                transformRb = fistRbComponent[i],
                elapsed = 0,
                duration = rangeAttackDuration,
                startScale = Vector3.new(1.5, 1.5, 1.5),
                targetScale = Vector3.new(fistTargetScale, fistTargetScale, fistTargetScale),
                colliderTimer = 0.0,
                finishedScaling = false,
                lingerElapsed = 0.0,
                lingerDuration = 3.0
            })
        end
    end

    fistsThrown = true
    rangeAttackTimer = 0.0
end

function update_scaling_attacks(dt)

    for i = #scalingAttacks, 1, -1 do
        local data = scalingAttacks[i]

        if not data.finishedScaling then
            data.elapsed = data.elapsed + dt
            data.colliderTimer = (data.colliderTimer or 0) + dt

            local t = math.min(data.elapsed / data.duration, 1.0)
            local newScale = Vector3.new(
                data.startScale.x + (data.targetScale.x - data.startScale.x) * t,
                data.startScale.y + (data.targetScale.y - data.startScale.y) * t,
                data.startScale.z + (data.targetScale.z - data.startScale.z) * t
            )

            if data.colliderTimer >= colliderUpdateInterval then
                if data.transformRb then
                    data.transformRb.rb:get_collider():set_sphere_radius(newScale.x * 0.5)
                    data.transformRb.rb:set_trigger(true)
                end
                data.colliderTimer = 0.0
            end

            if data.elapsed >= data.duration then
                data.finishedScaling = true
                data.lingerElapsed = 0.0
                data.lingerDuration = fistsExtraTime
            end
        else
            data.lingerElapsed = data.lingerElapsed + dt
            if data.lingerElapsed >= data.lingerDuration then
                -- Return the fists
                if data.transformRb and data.transformRb.rb then
                    data.transformRb.rb:set_position(Vector3.new(-500, 0, -150))
                end
                table.remove(scalingAttacks, i)
            end
        end
    end
    
end

function get_next_fists()
    local result = {}

    local usedCount = 0
    for i = 1, fistMaxNumbers do
        if fistsUsed[i] then
            usedCount = usedCount + 1
        end
    end

    if usedCount >= fistMaxNumbers then
        reset_fist_wave()
    end

    for i = 1, fistMaxNumbers do
        if not fistsUsed[i] then
            table.insert(result, i)
            fistsUsed[i] = true
        end
        if #result >= fistsPerWave then break end
    end

    return result
end

function reset_fist_wave()
    fistsUsed = {}
    fistsThrown = false
end

function is_within_arena(position, center, radius)
    local dx = position.x - center.x
    local dz = position.z - center.z
    return dx * dx + dz * dz <= radius * radius
end

function on_exit() end