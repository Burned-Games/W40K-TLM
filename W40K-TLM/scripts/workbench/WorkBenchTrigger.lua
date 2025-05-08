local playerInRange = false
local workbenchUIManagerScript = nil
local workbenchRB = nil
local workbenchAreaTrigger = nil
local areaTriggerRB = nil
local workbenchInitialPosition = nil
local playerScript = nil
local workbenchNumber = nil
local workbenchAnimator = nil
local currentAnimation = nil

-- Animation indices
local ANIM_ARMOR = 0
local ANIM_FLY = 1
local ANIM_IDLE_ARMOR = 2
local ANIM_IDLE_WEAPONS = 3
local ANIM_LAND = 4
local ANIM_WEAPONS = 5

local workbenchInGround = false
local idleCycleActive = false
local landAnimationTimer = 0
local LAND_ANIMATION_DURATION = 0.5

-- Animation state management for idle animations
local idleAnimationTimer = 0
local idleAnimationState = 0  -- 0: Armor, 1: IdleArmor, 2: Weapons, 3: IdleWeapons

-- Time to display each idle animation (in seconds)
local IDLE_TRANSITION_TIME = 0.8  -- Time for the transition animations (Armor/Weapons)
local IDLE_DISPLAY_TIME = 1.0     -- Time for the idle animations (IdleArmor/IdleWeapons)

function on_ready()
    workbenchAnimator = self:get_component("AnimatorComponent")
    if not workbenchAnimator then
        print("Warning: No AnimatorComponent found on workbench")
    end

    -- Ensure the collider is set as a trigger
    workbenchRB = self:get_component("RigidbodyComponent")
    if workbenchRB then
        -- print("Found RigidBodyComponent on Workbench")
        workbenchRB.rb:set_trigger(true)
        workbenchRB.rb:set_freeze_y(true)
        workbenchInitialPosition = Vector3.new(workbenchRB.rb:get_position().x, workbenchRB.rb:get_position().y, workbenchRB.rb:get_position().z)
        workbenchRB:on_collision_enter(function(entityA, entityB)
            handle_collision_stay(entityA, entityB)
        end)
        workbenchRB:on_collision_exit(function(entityA, entityB)
            handle_workbench_collision_exit(entityA, entityB)
        end)
        workbenchRB:on_collision_stay(function(entityA, entityB)
            handle_workbench_collision_stay(entityA, entityB)
        end)
    end

    local thisEntityName = self:get_component("TagComponent").tag
    workbenchNumber = string.match(thisEntityName, "Workbench(%d+)")
    -- print("Workbench number: " .. (workbenchNumber or "unknown"))

    if workbenchNumber then
        -- Find the corresponding WorkbenchAreaTriggerX entity
        local areaTriggerName = "WorkbenchAreaTrigger" .. workbenchNumber
        workbenchAreaTrigger = current_scene:get_entity_by_name(areaTriggerName)
        
        if workbenchAreaTrigger then
            -- print("Found area trigger: " .. areaTriggerName)
            areaTriggerRB = workbenchAreaTrigger:get_component("RigidbodyComponent")
            
            if areaTriggerRB then
                -- print("Found RigidBodyComponent on " .. areaTriggerName)
                -- Configure the area trigger
                areaTriggerRB.rb:set_trigger(true)
                areaTriggerRB.rb:set_position(Vector3.new(workbenchInitialPosition.x, workbenchInitialPosition.y, workbenchInitialPosition.z))
                areaTriggerRB:on_collision_enter(function(entityA, entityB)
                    handle_area_collision_enter(entityA, entityB)
                end)
                areaTriggerRB:on_collision_exit(function(entityA, entityB)
                    handle_area_collision_exit(entityA, entityB)
                end)
            else
                -- print("No RigidBodyComponent found on " .. areaTriggerName)
            end
        else
            -- print("Warning: WorkbenchAreaTrigger" .. workbenchNumber .. " not found")
        end
    end

    -- print("Workbench position: " .. workbenchRB.rb:get_position().x .. ", " .. workbenchRB.rb:get_position().y .. ", " .. workbenchRB.rb:get_position().z)

    workbenchUIManagerScript = current_scene:get_entity_by_name("WorkBenchUIManager"):get_component("ScriptComponent")
    mission_Component = current_scene:get_entity_by_name("MisionManager"):get_component("ScriptComponent")
    playerScript = current_scene:get_entity_by_name("Player"):get_component("ScriptComponent")
    
    if workbenchAnimator then
        playAnimation(ANIM_FLY)
    end
end

function on_update(dt)
    -- Manage idle animation cycle
    if workbenchInGround then
        update_idle_animations(dt)
    else
        idleCycleActive = false
    end

    -- Manage Land animation transition to IdleWeapons
    if currentAnimation == ANIM_LAND then
        landAnimationTimer = landAnimationTimer + dt
        if landAnimationTimer >= LAND_ANIMATION_DURATION then
            landAnimationTimer = 0
            if playerInRange then
                on_animation_end("Land")
            end
        end
    end

    if playerInRange and Input.get_button(Input.action.Confirm) == Input.state.Down then
        -- Open the workbench UI
        local workbenchOpen = workbenchUIManagerScript.isWorkBenchOpen
        if workbenchOpen == false then
            workbenchUIManagerScript:show_ui()
        end
    end
end

function handle_collision_stay(entityA, entityB)
    local nameA = entityA:get_component("TagComponent").tag
    local nameB = entityB:get_component("TagComponent").tag

    if nameA == "Player" or nameB == "Player" then
        if not playerInRange then
            playerInRange = true
            
            if currentAnimation ~= ANIM_LAND and currentAnimation ~= ANIM_IDLE_WEAPONS then
                workbenchFall()
            end
        end
    end
end

function handle_workbench_collision_stay(entityA, entityB)
    local nameA = entityA:get_component("TagComponent").tag
    local nameB = entityB:get_component("TagComponent").tag

    if nameA == "Player" or nameB == "Player" then
        playerInRange = true
        -- print("Player is in range of the workbench")
    end
end

function handle_workbench_collision_exit(entityA, entityB)
    local nameA = entityA:get_component("TagComponent").tag
    local nameB = entityB:get_component("TagComponent").tag

    if nameA == "Player" or nameB == "Player" then
        playerInRange = false

        if tonumber(workbenchNumber) > playerScript.zonePlayer then
            playerScript:saveProgress()
        else
            playerScript:saveUpgrades()
        end
        -- print("Player exited the workbench range")
    end
end

function handle_area_collision_enter(entityA, entityB)
    local nameA = entityA:get_component("TagComponent").tag
    local nameB = entityB:get_component("TagComponent").tag

    if nameA == "Player" or nameB == "Player" then
        -- print("Player entered area trigger")
        workbenchFall()
    end
end

function handle_area_collision_exit(entityA, entityB)
    local nameA = entityA:get_component("TagComponent").tag
    local nameB = entityB:get_component("TagComponent").tag

    if nameA == "Player" or nameB == "Player" then
        -- print("Player exited area trigger")
        workbenchRise()
    end
end

function workbenchFall()
    if workbenchAnimator and not workbenchInGround then
        playAnimation(ANIM_LAND)
        print("Playing workbench landing animation")
        landAnimationTimer = 0
        workbenchInGround = true
    end
    
    if mission_Component.getCurrerTaskIndex(false) == 1 and mission_Component.getCurrerLevel() == 1 then
        mission_Component.mr1_supply = true
    end
end

function workbenchRise()
    if workbenchAnimator and workbenchInGround then
        playAnimation(ANIM_FLY)
        workbenchInGround = false
        idleAnimationTimer = 0
        idleAnimationState = 0
    end
 
    -- Track mission objectives
    if mission_Component.getCurrerTaskIndex(true) == 5 and mission_Component.getCurrerLevel() == 1  then
        mission_Component.m5_Upgrade = true
    end

    if mission_Component.getCurrerTaskIndex(true) == 8 and mission_Component.getCurrerLevel() == 1 then
        mission_Component.m7_Upgrade = true
    end

    if mission_Component.getCurrerTaskIndex(true) == 11 and mission_Component.getCurrerLevel() == 1 then
        mission_Component.m7_Upgrade = true
    end

   
    if mission_Component.getCurrerTaskIndex(true) == 1 and mission_Component.getCurrerLevel() == 2 then
        mission_Component.m1_Upgrade = true
    end
    
    if mission_Component.getCurrerTaskIndex(true) == 5 and mission_Component.getCurrerLevel() == 2 then
        mission_Component.m5_Upgrade = true
    end

    mission_Component.m1_Upgrade = true
end

function playAnimation(animationIndex)
    if workbenchAnimator and currentAnimation ~= animationIndex then
        workbenchAnimator:set_current_animation(animationIndex)
        currentAnimation = animationIndex
        
        local animNames = {"Armor", "Fly", "IdleArmor", "IdleWeapons", "Land", "Weapons"}
        -- print("Playing workbench animation: " .. animNames[animationIndex + 1])
    end
end

function on_animation_end(animationName)
    print("Animation ended: " .. animationName)
    if animationName == "Land" and playerInRange then
        playAnimation(ANIM_IDLE_WEAPONS)
    end
end

function update_idle_animations(dt)
    idleAnimationTimer = idleAnimationTimer + dt
    
    local timerThreshold = 0
    if idleAnimationState == 0 then  -- Armor
        timerThreshold = IDLE_TRANSITION_TIME
    elseif idleAnimationState == 1 then  -- IdleArmor
        timerThreshold = IDLE_DISPLAY_TIME
    elseif idleAnimationState == 2 then  -- Weapons
        timerThreshold = IDLE_TRANSITION_TIME
    elseif idleAnimationState == 3 then  -- IdleWeapons
        timerThreshold = IDLE_DISPLAY_TIME
    end
    
    if idleAnimationTimer >= timerThreshold then
        idleAnimationTimer = 0
        idleAnimationState = (idleAnimationState + 1) % 4
        
        if idleAnimationState == 0 then  -- Armor
            playAnimation(ANIM_ARMOR)
        elseif idleAnimationState == 1 then  -- IdleArmor
            playAnimation(ANIM_IDLE_ARMOR)
        elseif idleAnimationState == 2 then  -- Weapons
            playAnimation(ANIM_WEAPONS)
        elseif idleAnimationState == 3 then  -- IdleWeapons
            playAnimation(ANIM_IDLE_WEAPONS)
        end
    end
end