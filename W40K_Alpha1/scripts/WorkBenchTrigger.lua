local playerInRange = false
local workbenchUIManagerScript = nil
local rigidbodyComponent = nil
local initialPosition = nil

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
    workbenchUIManagerScript = current_scene:get_entity_by_name("WorkBenchUI"):get_component("ScriptComponent")
    initialPosition = Vector3.new(rigidbodyComponent.rb:get_position().x, rigidbodyComponent.rb:get_position().y, rigidbodyComponent.rb:get_position().z)

     --Mission
    mission_Component = current_scene:get_entity_by_name("MisionManager"):get_component("ScriptComponent")
    mission4Component = current_scene:get_entity_by_name("Mission4Collider"):get_component("ScriptComponent")
    mission8Component = current_scene:get_entity_by_name("Mission8Collider"):get_component("ScriptComponent")

end

function on_update(dt)
    if playerInRange and Input.get_button(Input.action.Confirm) == Input.state.Down then
        -- Open the workbench UI
        local workbenchOpen = workbenchUIManagerScript.isWorkBenchOpen
        if workbenchOpen == false and rigidbodyComponent.rb:get_position() ~= Vector3.new(0, -20, 0) then
            workbenchUIManagerScript:show_ui()
            rigidbodyComponent.rb:set_position(Vector3.new(0, -20, 0))

        end

        if mission4Component.m4_Clear == true then
            mission_Component.M5_WorkBrech = true
        end

        if mission8Component.m8_Clear == true then
            mission_Component.M9_WorkBrech = true
        end
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
        playerInRange = true
    end
end

function handle_collision_exit(entityA, entityB)
    local nameA = entityA:get_component("TagComponent").tag
    local nameB = entityB:get_component("TagComponent").tag

    if nameA == "Player" or nameB == "Player" then
        playerInRange = false
    end
end
