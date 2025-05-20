local stats_data = require("scripts/utils/enemy_stats")

--Prefabs locations
local fistPrefab = "prefabs/Enemies/attacks/BossFist.prefab"
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

-- Lists
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

-- Ints
local fistMaxNumbers = 4
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

    -- Fists
    for i = 1, fistMaxNumbers do
        local fistEntity = instantiate_prefab(fistPrefab)
        fistAttacks[i] = fistEntity
        fistAnimator[i] = fistAttacks[i]:get_component("AnimatorComponent")
        fistTransf[i] = fistAttacks[i]:get_component("TransformComponent")
        fistRbComponent[i] = fistAttacks[i]:get_component("RigidbodyComponent")
        fistRbs[i] = fistRbComponent[i].rb
        fistRbs[i]:set_position(Vector3.new(-500, 0, -500))
        fistRbs[i]:set_trigger(true)
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
    if fistsAttackPending then
        fistsAttackDelayTimer = fistsAttackDelayTimer + dt
        if fistsAttackDelayTimer >= fistsAttackDelay then
            execute_fists_attack()
            fistsAttackPending = false
            fistsAttackDelayTimer = 0.0
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

        if not isFistsDamaging then
            timeSinceLastFistHit = timeSinceLastFistHit + dt
            if timeSinceLastFistHit > fistsDamageCooldown then
                isFistsDamaging = true
                timeSinceLastFistHit = 0.0
            end
        elseif rangeAttackTimer >= rangeAttackDuration then
            -- Send them back
            for i = 1, fistMaxNumbers do
                fistRbComponent[i].rb:set_position(Vector3.new(-500, 0, -150))
            end
        
            fistsThrown = false
        end
    end

    update_scaling_attacks(dt)
end

function fist()

    if fistsThrown or fistsAttackPending then return end

    fistsAttackPending = true
    fistsAttackDelayTimer = 0.0

    fistPositions = {Vector3.new(playerTransf.position.x, 0, playerTransf.position.z)}

    -- Generate the other positions with some variability
    for i = 1, fistMaxNumbers - 1 do
        local angle = math.rad((360 / (fistMaxNumbers - 1)) * (i - 1))
        local randRadius = radius + math.random() * 5
        local offsetX = math.cos(angle) * randRadius + (math.random() * 2 - 1) * 5
        local offsetZ = math.sin(angle) * randRadius + (math.random() * 2 - 1) * 5

        table.insert(fistPositions, Vector3.new(playerTransf.position.x + offsetX, 0, playerTransf.position.z + offsetZ))
    end

    for i = 1, fistMaxNumbers do
        if fistIndicatorsTransform[i] then
            fistIndicatorsTransform[i].position = fistPositions[i]
            fistIndicatorsTransform[i].position.y = 0.1
        end
        if fistIndicatorsScript[i] then
            fistIndicatorsScript[i]:startIndicator()
        end
    end
end

function execute_fists_attack()

    if fistsThrown then return end

    log("Fists Attack")

    -- Clear previous scaling operations
    scalingAttacks = {}

    for i = 1, fistMaxNumbers do
        if fistRbs[i] and fistTransf[i] then
            -- Set initial position
            fistRbComponent[i].rb:set_position(fistPositions[i])
            currentAnim = 1
            fistAnimator[i]:set_current_animation(currentAnim)

            bossSmashDescendSFX:play()

            -- Reset scale
            fistRbComponent[i].rb:get_collider():set_sphere_radius(1.0)
            fistRbComponent[i].rb:set_trigger(true)
            
            -- Add to scaling list with reference to the specific fist transform
            table.insert(scalingAttacks, {
                transformRb = fistRbComponent[i],
                elapsed = 0,
                duration = rangeAttackDuration,
                startScale = Vector3.new(1.5, 1.5, 1.5),
                targetScale = Vector3.new(fistTargetScale, fistTargetScale, fistTargetScale),
                colliderTimer = 0.0
            })
        end
    end

    fistsThrown = true
    rangeAttackTimer = 0.0

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

        if data.colliderTimer >= colliderUpdateInterval then
            if data.transformRb then
                data.transformRb.rb:get_collider():set_sphere_radius(newScale.x * 0.5)
                data.transformRb.rb:set_trigger(true)
            end
            data.colliderTimer = 0.0
        end

        if data.elapsed >= data.duration then
            if data.transformRb then
                data.transformRb.rb:get_collider():set_sphere_radius(data.targetScale.x * 0.5)
                data.transformRb.rb:set_trigger(true)
            end
            table.remove(scalingAttacks, i)
        end
    end
    
end

function on_exit() end