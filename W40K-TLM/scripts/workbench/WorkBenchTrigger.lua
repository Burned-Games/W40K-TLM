local workbenchUIManagerScript = nil
local workbenchRB = nil
local workbenchAreaTrigger = nil
local areaTriggerRB = nil
local workbenchInitialPosition = nil
local playerScript = nil
local workbenchNumber = nil
local workbenchAnimator = nil
local currentAnimation = nil

local workbenchTransform = nil

local interactionIconTransform = nil
local interactionIconSprite = nil

local interactionSpriteTransitionTimerTarget = 0.4
local interactionSpriteTransitionTimer = 0.0
local beforeFrameOutOfRange = false

-- Animation indices
local ANIM_ARMOR = 0
local ANIM_FLY = 1
local ANIM_IDLE_ARMOR = 2
local ANIM_IDLE_WEAPONS = 3
local ANIM_LAND = 4
local ANIM_WEAPONS = 5

workbenchInGround = false
playerInRange = false 

local idleCycleActive = false
local landAnimationTimer = 0
local LAND_ANIMATION_DURATION = 0.5

-- Animation state management for idle animations
local idleAnimationTimer = 0
local idleAnimationState = 0  -- 0: Armor, 1: IdleArmor, 2: Weapons, 3: IdleWeapons

currentUIScreen = "gun"  -- "gun" or "character"

local IDLE_TRANSITION_TIME = 0.8  -- Time for the transition animations (Armor/Weapons)
local IDLE_DISPLAY_TIME = 1.0     -- Time for the idle animations (IdleArmor/IdleWeapons)

--Audio
local workbenchFallSFX

function on_ready()
    workbenchAnimator = self:get_component("AnimatorComponent")
    if not workbenchAnimator then
        --print("Warning: No AnimatorComponent found on workbench")
    end

    --Audio
    workbenchFallSFX = current_scene:get_entity_by_name("WorkbenchFallSFX"):get_component("AudioSourceComponent")

    -- Ensure the collider is set as a trigger
    workbenchRB = self:get_component("RigidbodyComponent")
    if workbenchRB then
        -- --print("Found RigidBodyComponent on Workbench")
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
    -- --print("Workbench number: " .. (workbenchNumber or "unknown"))

    if workbenchNumber then
        -- Find the corresponding WorkbenchAreaTriggerX entity
        local areaTriggerName = "WorkbenchAreaTrigger" .. workbenchNumber
        workbenchAreaTrigger = current_scene:get_entity_by_name(areaTriggerName)
        
        if workbenchAreaTrigger then
            -- --print("Found area trigger: " .. areaTriggerName)
            areaTriggerRB = workbenchAreaTrigger:get_component("RigidbodyComponent")
            
            if areaTriggerRB then
                -- --print("Found RigidBodyComponent on " .. areaTriggerName)
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
                -- --print("No RigidBodyComponent found on " .. areaTriggerName)
            end
        else
            -- --print("Warning: WorkbenchAreaTrigger" .. workbenchNumber .. " not found")
        end
    end

    -- --print("Workbench position: " .. workbenchRB.rb:get_position().x .. ", " .. workbenchRB.rb:get_position().y .. ", " .. workbenchRB.rb:get_position().z)

    workbenchUIManagerScript = current_scene:get_entity_by_name("WorkBenchUIManager"):get_component("ScriptComponent")
    mission_Component = current_scene:get_entity_by_name("MisionManager"):get_component("ScriptComponent")
    playerScript = current_scene:get_entity_by_name("Player"):get_component("ScriptComponent")
    
    if workbenchAnimator then
        playAnimation(ANIM_FLY)
    end

    workbenchTransform = self:get_component("TransformComponent")

    interactionIconTransform = current_scene:get_entity_by_name("WorkbenchInteractionIcon"):get_component("TransformComponent")
    interactionIconSprite = current_scene:get_entity_by_name("WorkbenchInteractionIcon"):get_component("SpriteComponent")

end

function on_update(dt)
    -- Manage animations based on UI state
    if workbenchInGround and workbenchUIManagerScript and workbenchUIManagerScript.isWorkBenchOpen then

        if currentUIScreen ~= workbenchUIManagerScript.currentScreen then
            set_ui_screen(workbenchUIManagerScript.currentScreen)
        end
    elseif workbenchInGround then
        -- Default to idle weapons when not in UI but workbench is in ground
        if currentAnimation ~= ANIM_IDLE_WEAPONS and 
           currentAnimation ~= ANIM_LAND and
           currentAnimation ~= ANIM_WEAPONS then
            playAnimation(ANIM_IDLE_WEAPONS)
            idleAnimationState = 3
        end
    else
        -- When workbench is not in ground, no idle animations
        idleCycleActive = false
    end    -- Manage Land animation transition
    if currentAnimation == ANIM_LAND then
        landAnimationTimer = landAnimationTimer + dt
        if landAnimationTimer >= LAND_ANIMATION_DURATION then
            landAnimationTimer = 0
            if playerInRange then
                on_animation_end("Land")
            end
        end
    end

    -- Open the workbench UI when the player presses the confirm button
    if playerInRange and Input.get_button(Input.action.Confirm) == Input.state.Down then
        local workbenchOpen = workbenchUIManagerScript.isWorkBenchOpen
        if workbenchOpen == false then
            workbenchUIManagerScript:show_ui()
        end
    end

    -- Manage indicator
    if playerInRange ~= beforeFrameOutOfRange then
        interactionSpriteTransitionTimer = 0
    end


    if not playerInRange then
        if interactionIconSprite and interactionSpriteTransitionTimer <= interactionSpriteTransitionTimerTarget then
            log(interactionSpriteTransitionTimer .. " target: " .. interactionSpriteTransitionTimerTarget)
            FadeToTransparent(dt)
        end
    else 
        if interactionIconSprite then
            interactionIconTransform.position = Vector3.new(workbenchTransform.position.x, 4.5, workbenchTransform.position.z)
            FadeToBlack(dt)
        end
    end

end

function handle_collision_stay(entityA, entityB)
    local nameA = entityA:get_component("TagComponent").tag
    local nameB = entityB:get_component("TagComponent").tag

    beforeFrameOutOfRange = playerInRange
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

    beforeFrameOutOfRange = playerInRange
    if nameA == "Player" or nameB == "Player" then
        playerInRange = true
        -- --print("Player is in range of the workbench")
    end
end

function handle_workbench_collision_exit(entityA, entityB)
    local nameA = entityA:get_component("TagComponent").tag
    local nameB = entityB:get_component("TagComponent").tag

    beforeFrameOutOfRange = playerInRange
    if nameA == "Player" or nameB == "Player" then
        playerInRange = false

        if tonumber(workbenchNumber) > playerScript.zonePlayer then
            playerScript:saveProgress()
        else
            playerScript:saveUpgrades()
        end
        -- --print("Player exited the workbench range")
    end
end

function handle_area_collision_enter(entityA, entityB)
    local nameA = entityA:get_component("TagComponent").tag
    local nameB = entityB:get_component("TagComponent").tag

    if nameA == "Player" or nameB == "Player" then
        -- --print("Player entered area trigger")
        workbenchFall()
    end
end

function handle_area_collision_exit(entityA, entityB)
    local nameA = entityA:get_component("TagComponent").tag
    local nameB = entityB:get_component("TagComponent").tag

    if nameA == "Player" or nameB == "Player" then
        -- --print("Player exited area trigger")
        workbenchRise()
    end
end

function workbenchFall()
    if workbenchAnimator and not workbenchInGround then
        playAnimation(ANIM_LAND)
        workbenchFallSFX:play()
        --print("Playing workbench landing animation")
        landAnimationTimer = 0
        workbenchInGround = true
        
        -- Update current UI screen if the UI is open
        if workbenchUIManagerScript and workbenchUIManagerScript.isWorkBenchOpen then
            currentUIScreen = workbenchUIManagerScript.currentScreen
            --print("Workbench UI screen updated")
        end
    end
    
    if mission_Component.getCurrerTaskIndex(false) == 1 and mission_Component.getCurrerLevel() == 1 then
        mission_Component.mr1_supply = true
    end
end

function workbenchRise()
    if workbenchAnimator and workbenchInGround then
        playAnimation(ANIM_FLY)
        workbenchInGround = false
        
        -- Reset animation states
        idleAnimationTimer = 0
        idleAnimationState = 0
        currentUIScreen = "gun"
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
        --print("Playing workbench animation: " .. animNames[animationIndex + 1])
    end
end

function on_animation_end(animationName)
    --print("Animation ended: " .. animationName)
    if animationName == "Land" and playerInRange then
        if workbenchUIManagerScript and workbenchUIManagerScript.isWorkBenchOpen then
            if workbenchUIManagerScript.currentScreen == "gun" then
                playAnimation(ANIM_WEAPONS)
                idleAnimationState = 2
            else
                playAnimation(ANIM_ARMOR)
                idleAnimationState = 0
            end
        else
            playAnimation(ANIM_IDLE_WEAPONS)
        end
    elseif animationName == "Armor" and workbenchInGround then
        playAnimation(ANIM_IDLE_ARMOR)
        idleAnimationState = 1
    elseif animationName == "Weapons" and workbenchInGround then
        playAnimation(ANIM_IDLE_WEAPONS)
        idleAnimationState = 3
    end
end

-- Function to update workbench animation based on UI screen
function set_ui_screen(screen)
    if type(screen) ~= "string" then
        --print("Warning: Invalid screen parameter type in set_ui_screen: " .. type(screen))
        return
    end
    
    if screen ~= "gun" and screen ~= "character" then
        --print("Warning: Unexpected screen value: " .. screen)
        return
    end
    
    if screen ~= currentUIScreen and workbenchInGround then
        currentUIScreen = screen
        --print("Changing workbench UI screen to: " .. screen)
        
        if screen == "gun" then
            playAnimation(ANIM_WEAPONS)
        else
            playAnimation(ANIM_ARMOR)
        end
    end
end

function FadeToTransparent(dt)
    interactionSpriteTransitionTimer = interactionSpriteTransitionTimer + dt
    local alpha = math.min(interactionSpriteTransitionTimer / interactionSpriteTransitionTimerTarget, 1.0)
    alpha = 1.0 - alpha -- invertir
    interactionIconSprite.tint_color = Vector4.new(1,1,1,alpha)
    if (interactionSpriteTransitionTimer > interactionSpriteTransitionTimerTarget) then
        interactionIconSprite.tint_color = Vector4.new(1,1,1,0)
    end
end

function FadeToBlack(dt)
    log("IN")
    interactionSpriteTransitionTimer = interactionSpriteTransitionTimer + dt
    
    local alpha = math.min(interactionSpriteTransitionTimer / interactionSpriteTransitionTimerTarget, 1.0)
   
    interactionIconSprite.tint_color = Vector4.new(1,1,1,alpha)
    if (interactionSpriteTransitionTimer > interactionSpriteTransitionTimerTarget) then
        interactionIconSprite.tint_color = Vector4.new(1,1,1,1)
    end
end