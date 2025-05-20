local distanceShow = 3.0



local player  = nil
local playerTransform  = nil
local transform = nil

local spriteComponent = nil

local interactionSpriteTransitionTimerTarget = 0.4
local interactionSpriteTransitionTimer = 0.0
local outOfRange = true
local beforeFrameOutOfRange = true
local hasBeenHidden = false


function on_ready()
    -- Add initialization code 
    player = current_scene:get_entity_by_name("Player")
    playerTransform = player:get_component("TransformComponent")
    spriteComponent = self:get_component("SpriteComponent")
    transform = self:get_component("TransformComponent")
end

function on_update(dt)
    -- Add update code here
    beforeFrameOutOfRange = outOfRange

    local distance = Vector3.new(100,100,100)
    distance = Vector3.new(
            math.abs(playerTransform.position.x - transform.position.x),
            math.abs(playerTransform.position.y - transform.position.y),
            math.abs(playerTransform.position.z - transform.position.z)
    )

    if distance.x < distanceShow and distance.z < distanceShow then
        if not hasBeenHidden then
            outOfRange = false
        end
        
    else
        if not outOfRange then
            hasBeenHidden = true
        end
        outOfRange = true
        
    end

    if outOfRange ~= beforeFrameOutOfRange then
        interactionSpriteTransitionTimer = 0
    end

    if outOfRange then
        if spriteComponent then
            FadeToTransparent(dt)
        end
    else 
        if spriteComponent then
            FadeToBlack(dt)
        end
    end


end

function on_exit()
    -- Add cleanup code here
end

function FadeToTransparent(dt)
    interactionSpriteTransitionTimer = interactionSpriteTransitionTimer + dt
    local alpha = math.min(interactionSpriteTransitionTimer / interactionSpriteTransitionTimerTarget, 1.0)
    alpha = 1.0 - alpha -- invertir
    spriteComponent.tint_color = Vector4.new(1,1,1,alpha)
    if (interactionSpriteTransitionTimer > interactionSpriteTransitionTimerTarget) then
        spriteComponent.tint_color = Vector4.new(1,1,1,0)
    end
end

function FadeToBlack(dt)
    interactionSpriteTransitionTimer = interactionSpriteTransitionTimer + dt
    local alpha = math.min(interactionSpriteTransitionTimer / interactionSpriteTransitionTimerTarget, 1.0)
    spriteComponent.tint_color = Vector4.new(1,1,1,alpha)
    if (interactionSpriteTransitionTimer > interactionSpriteTransitionTimerTarget) then
        spriteComponent.tint_color = Vector4.new(1,1,1,1)
    end
end
