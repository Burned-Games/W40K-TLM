local leverAnimator = nil
local hasInteracted = false
local transform
local isArenaLever = false
local canInteract = false
local maxInteractions = 0
local currentInteractions = 0

playerTransform = nil
parentTransform = nil
parentScript = nil

function on_ready()
    parentScript = self:get_parent():get_component("ScriptComponent")
    playerTransform = current_scene:get_entity_by_name("Player"):get_component("TransformComponent")
    parentTransform = self:get_parent():get_component("TransformComponent")
    transform = self:get_component("TransformComponent")
    leverAnimator = self:get_component("AnimatorComponent")
    
    local parentTag = self:get_parent():get_component("TagComponent").tag
    isArenaLever = parentTag == "ArenaMain"

    if isArenaLever and parentScript then
        maxInteractions = 3
    end

    mission_Component = current_scene:get_entity_by_name("MisionManager"):get_component("ScriptComponent")        


end

function on_update(dt)
    if isArenaLever and not parentScript.waitingForKeyPress then
        canInteract = false
    else
        canInteract = true
    end
    
    if isArenaLever and currentInteractions >= maxInteractions then
        canInteract = false
    end

    local distance = Vector3.new(
        math.abs(playerTransform.position.x - (transform.position.x + parentTransform.position.x)),
        math.abs(playerTransform.position.y - (transform.position.y + parentTransform.position.y)),
        math.abs(playerTransform.position.z - (transform.position.z + parentTransform.position.z))
    )

    if distance.x < 1 and distance.z < 1 and Input.get_button(Input.action.Cancel) == Input.state.Down then
        if mission_Component.getCurrerTaskIndex(true) == 4 and mission_Component.getCurrerLevel() == 1 then
            mission_Component.m4_lever = true
        end

        if mission_Component.getCurrerTaskIndex(true) == 2 and mission_Component.getCurrerLevel() == 2 then
            mission_Component.m2_lever = true
        end

        if mission_Component.getCurrerTaskIndex(true) == 6 and mission_Component.getCurrerLevel() == 2 then
            mission_Component.m6_lever = true
        end

        if mission_Component.getCurrerTaskIndex(true) == 7 and mission_Component.getCurrerLevel() == 2 then
            mission_Component.m7_lever = mission_Component.m7_lever + 1
        end
        
        if canInteract and not hasInteracted then
            interact()
        end
    else
        hasInteracted = false
    end
end

function interact()
    hasInteracted = true
    currentInteractions = currentInteractions + 1
    leverAnimator:set_current_animation(0)
    
    if isArenaLever then
        parentScript:advanceToNextWave()
    else
        parentScript:on_interact()
    end
end

function on_exit()
    -- Add cleanup code here
end
