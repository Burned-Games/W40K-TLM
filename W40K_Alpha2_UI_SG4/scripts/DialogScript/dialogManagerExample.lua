dialogLines = {
    { name = "Carlos", text = "Hola, bienvenido al mundo" },
    { name = "Ana", text = "Espero que estés preparado para la aventura." },
    { name = "Carlos", text = "Vamos allá" }
}


local playerInRange = false
local workbenchUIManagerScript = nil
local rigidbodyComponent = nil
local initialPosition = nil
--dialog
local dialogScriptComponent = nil

function on_ready()

    dialogScriptComponent = current_scene:get_entity_by_name("DialogManager"):get_component("ScriptComponent")
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

end

function on_update(dt)

  
    if playerInRange and Input.get_button(Input.action.Confirm) == Input.state.Down then
        dialogScriptComponent.start_dialog(dialogLines)
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
