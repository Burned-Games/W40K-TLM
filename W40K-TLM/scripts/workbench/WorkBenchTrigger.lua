local playerInRange = false
local workbenchUIManagerScript = nil
local workbenchRB = nil
local workbenchAreaTrigger = nil
local areaTriggerRB = nil
local workbenchInitialPosition = nil
local playerScript = nil
local playerExit = false
local workbenchNumber = nil

function on_ready()
    -- Ensure the collider is set as a trigger
    workbenchRB = self:get_component("RigidbodyComponent")
    if workbenchRB then
        -- print("Found RigidBodyComponent on Workbench")
        workbenchRB.rb:set_trigger(true)
        workbenchRB.rb:set_freeze_y(true)
        workbenchInitialPosition = Vector3.new(workbenchRB.rb:get_position().x, workbenchRB.rb:get_position().y, workbenchRB.rb:get_position().z)
        workbenchRB.rb:set_position(Vector3.new(workbenchInitialPosition.x, workbenchInitialPosition.y + 10, workbenchInitialPosition.z))
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
end

function on_update(dt)

    if workbenchRB.rb:get_position().y < 0 then
        workbenchRB.rb:set_freeze_y(true)
        workbenchRB.rb:set_position(Vector3.new(workbenchInitialPosition.x, workbenchInitialPosition.y, workbenchInitialPosition.z))
        workbenchRB.rb:set_velocity(Vector3.new(0, 0, 0))
    end

    if workbenchRB.rb:get_position().y > 10 then
        workbenchRB.rb:set_freeze_y(true)
        workbenchRB.rb:set_position(Vector3.new(workbenchInitialPosition.x, workbenchInitialPosition.y + 10, workbenchInitialPosition.z))
        workbenchRB.rb:set_velocity(Vector3.new(0, 0, 0))
    end

    if playerInRange and Input.get_button(Input.action.Cancel) == Input.state.Down then
        -- Open the workbench UI
        local workbenchOpen = workbenchUIManagerScript.isWorkBenchOpen
        if workbenchOpen == false then
            workbenchUIManagerScript:show_ui()
            
        end
    end
end

function handle_workbench_collision_stay(entityA, entityB)
    local nameA = entityA:get_component("TagComponent").tag
    local nameB = entityB:get_component("TagComponent").tag

    if nameA == "Player" or nameB == "Player" then
        playerInRange = true
        playerExit = false
        -- print("Player is in range of the workbench")
    end
end

function handle_workbench_collision_exit(entityA, entityB)
    local nameA = entityA:get_component("TagComponent").tag
    local nameB = entityB:get_component("TagComponent").tag

    if nameA == "Player" or nameB == "Player" then
        playerInRange = false
        playerExit = true
        playerScript:saveProgress()
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
    if workbenchRB then
        workbenchRB.rb:set_freeze_y(false)
        workbenchRB.rb:set_velocity(Vector3.new(0, -20, 0))
    end
    if mission_Component.getCurrerTaskIndex(false) == 1 and mission_Component.getCurrerLevel() == 1 then
        mission_Component.mr1_supply = true
    end
end

function workbenchRise()
    print("cuurrrelevel")
    if workbenchRB then
        workbenchRB.rb:set_freeze_y(false)
        workbenchRB.rb:set_velocity(Vector3.new(0, 20, 0))
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