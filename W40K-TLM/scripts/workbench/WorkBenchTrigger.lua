local playerInRange = false
local workbenchUIManagerScript = nil
local rigidbodyComponent = nil
local initialPosition = nil
local playerScript = nil
local playerExit = false

function on_ready()
    -- Ensure the collider is set as a trigger
    rigidbodyComponent = self:get_component("RigidbodyComponent")
    if rigidbodyComponent then
        rigidbodyComponent.rb:set_trigger(true)
        rigidbodyComponent:on_collision_enter(function(entityA, entityB)
            handle_collision_enter(entityA, entityB)
        end)
        rigidbodyComponent:on_collision_exit(function(entityA, entityB)
            handle_collision_exit(entityA, entityB)
        end)
    end
    workbenchUIManagerScript = current_scene:get_entity_by_name("WorkBenchUIManager"):get_component("ScriptComponent")
    initialPosition = Vector3.new(rigidbodyComponent.rb:get_position().x, rigidbodyComponent.rb:get_position().y, rigidbodyComponent.rb:get_position().z)

    mission_Component = current_scene:get_entity_by_name("MisionManager"):get_component("ScriptComponent")
    playerScript = current_scene:get_entity_by_name("Player"):get_component("ScriptComponent")

end

function on_update(dt)
    if playerInRange and Input.get_button(Input.action.Cancel) == Input.state.Down then
        -- Open the workbench UI
        local workbenchOpen = workbenchUIManagerScript.isWorkBenchOpen
        if workbenchOpen == false and rigidbodyComponent.rb:get_position() ~= Vector3.new(0, -20, 0) then
            workbenchUIManagerScript:show_ui()
            rigidbodyComponent.rb:set_position(Vector3.new(0, -20, 0))
            if mission_Component.getCurrerTaskIndex(true) == 5 then
                mission_Component.m5_Upgrade = true
            end

            if mission_Component.getCurrerTaskIndex(true) == 7 then
                mission_Component.m7_Upgrade = true
            end
        end

        -- Mission objectives (commented out)
        --if mission4Component.m4_Clear == true then
        --    mission_Component.M5_WorkBrech = true
        --end

        --if mission8Component.m8_Clear == true then
        --    mission_Component.M9_WorkBrech = true
        --end
    else         
        -- Close the workbench UI
        local workbenchOpen = workbenchUIManagerScript.isWorkBenchOpen
        if workbenchOpen == false and rigidbodyComponent.rb:get_position() ~= initialPosition then
            rigidbodyComponent.rb:set_position(initialPosition)
        end
    end
end

function handle_collision_enter(entityA, entityB)
    local nameA = entityA:get_component("TagComponent").tag
    local nameB = entityB:get_component("TagComponent").tag

    if nameA == "Player" or nameB == "Player" then
        if not playerExit then
            playerInRange = true
        end
    end
end

function handle_collision_exit(entityA, entityB)
    local nameA = entityA:get_component("TagComponent").tag
    local nameB = entityB:get_component("TagComponent").tag

    if nameA == "Player" or nameB == "Player" then
        playerInRange = false
        playerExit = true
        playerScript:saveProgress()
    end
end
