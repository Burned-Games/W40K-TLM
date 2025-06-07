local leverAnimator = nil
local hasInteracted = false
local transform
local canInteract = true
local maxInteractions = 0
local currentInteractions = 0

local interactionDistance = 5;

playerTransform = nil
parentTransform = nil
parentScript = nil

local playerScript = nil

local interactionSprite = nil
local interactionSpriteTransitionTimerTarget = 0.4
local interactionSpriteTransitionTimer = 0.0
local outOfRange = true
local beforeFrameOutOfRange = true

local leverSFX = nil

local leverDont = nil

function on_ready()
    parentScript = self:get_parent():get_component("ScriptComponent")
    playerTransform = current_scene:get_entity_by_name("Player"):get_component("TransformComponent")
    playerScript = current_scene:get_entity_by_name("Player"):get_component("ScriptComponent")
    parentTransform = self:get_parent():get_component("TransformComponent")
    transform = self:get_component("TransformComponent")
    leverAnimator = self:get_component("AnimatorComponent")

    leverSFX = self:get_component("AudioSourceComponent")

    
    leverDont = current_scene:get_entity_by_name("NotInteractionIcon")
    leverDont:set_active(true)

    local children = self:get_children()
    for _, child in ipairs(children) do
        if child:get_component("TagComponent").tag == "InteractionIcon" then
            interactionSprite = child:get_component("SpriteComponent")
            
        end
    end
    if interactionSprite then
        interactionSprite.tint_color = Vector4.new(1,1,1,0)
    end

    mission_Component = current_scene:get_entity_by_name("MisionManager"):get_component("ScriptComponent")        

    leverAnimator:set_current_animation(1)

end

function on_update(dt)

    beforeFrameOutOfRange = outOfRange

    local distance = Vector3.new(100,100,100)
    if not hasInteracted then
        distance = Vector3.new(
            math.abs(playerTransform.position.x - (transform.position.x + parentTransform.position.x)),
            math.abs(playerTransform.position.y - (transform.position.y + parentTransform.position.y)),
            math.abs(playerTransform.position.z - (transform.position.z + parentTransform.position.z))
        )
    end
    

    if distance.x < interactionDistance and distance.z < interactionDistance and playerScript.combatTimer <= 3 then
        --Icon
        
        if  Input.get_button(Input.action.Confirm) == Input.state.Down then
            if mission_Component.getCurrerTaskIndex(true) == 4 and mission_Component.getCurrerLevel() == 1 and mission_Component.m4_EnemyCount >= 2 then
                mission_Component.m4_lever = true
            end

            if mission_Component.getCurrerTaskIndex(true) == 9 and mission_Component.getCurrerLevel() == 1 then
                mission_Component.m8_lever = mission_Component.m8_lever + 1
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
        end

        if canInteract and not hasInteracted then
            outOfRange = false
        else
            outOfRange = true
        end
        

    else
        outOfRange = true
    end

    if outOfRange ~= beforeFrameOutOfRange then
        interactionSpriteTransitionTimer = 0
    end

    if outOfRange then
        if interactionSprite then
            FadeToTransparent(dt)
        end
    else 
        if interactionSprite then
            FadeToBlack(dt)
        end
    end


end

function interact()
    hasInteracted = true
    currentInteractions = currentInteractions + 1
    leverAnimator:set_current_animation(2)
    if leverSFX then
        leverSFX:play()
    end
    parentScript:on_interact()
end

function on_exit()
    -- Add cleanup code here
end

function FadeToTransparent(dt)
    interactionSpriteTransitionTimer = interactionSpriteTransitionTimer + dt
    local alpha = math.min(interactionSpriteTransitionTimer / interactionSpriteTransitionTimerTarget, 1.0)
    alpha = 1.0 - alpha -- invertir
    interactionSprite.tint_color = Vector4.new(1,1,1,alpha)
    if (interactionSpriteTransitionTimer > interactionSpriteTransitionTimerTarget) then
        interactionSprite.tint_color = Vector4.new(1,1,1,0)
        leverDont:set_active(true)
    end
end

function FadeToBlack(dt)
    interactionSpriteTransitionTimer = interactionSpriteTransitionTimer + dt
    local alpha = math.min(interactionSpriteTransitionTimer / interactionSpriteTransitionTimerTarget, 1.0)
    interactionSprite.tint_color = Vector4.new(1,1,1,alpha)
    if (interactionSpriteTransitionTimer > interactionSpriteTransitionTimerTarget) then
        interactionSprite.tint_color = Vector4.new(1,1,1,1)
        leverDont:set_active(false)
    end
end
