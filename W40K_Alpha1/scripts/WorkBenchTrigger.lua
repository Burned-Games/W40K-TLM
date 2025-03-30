local playerInRange = false
local workbenchUIManagerScript = nil

function on_ready()
    -- Ensure the collider is set as a trigger
    local rigidbodyComponent = self:get_component("RigidbodyComponent")
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
end

function on_update(dt)
    if playerInRange and Input.get_button(Input.action.Confirm) == Input.state.Down then
        -- Open the workbench UI
        if workbenchUIManagerScript then
            workbenchUIManagerScript:show_ui()
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
