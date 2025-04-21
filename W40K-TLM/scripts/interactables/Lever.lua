local leverAnimator = nil
local hasInteracted = false
local transform

playerTransform = nil
doorTransform = nil
doorScript = nil

function on_ready()
    doorScript = self:get_parent():get_component("ScriptComponent")
    playerTransform = current_scene:get_entity_by_name("Player"):get_component("TransformComponent")
    doorTransform = self:get_parent():get_component("TransformComponent")
    transform = self:get_component("TransformComponent")
    leverAnimator = self:get_component("AnimatorComponent")
end

function on_update(dt)

    local distance = Vector3.new(
        math.abs(playerTransform.position.x - (transform.position.x + doorTransform.position.x)),
        math.abs(playerTransform.position.y - (transform.position.y + doorTransform.position.y)),
        math.abs(playerTransform.position.z - (transform.position.z + doorTransform.position.z))
    )

    if distance.x < 1 and distance.z < 1 and Input.get_button(Input.action.Confirm) == Input.state.Down then
        if not hasInteracted then
            hasInteracted = true
            log("lever")
            leverAnimator:set_current_animation(0)
            doorScript:on_interact()
        end
    end

end

function on_exit()
    -- Add cleanup code here
end
