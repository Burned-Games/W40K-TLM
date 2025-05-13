local minimumInteractions = 0
local currentInteractions = 0
local rigidBody = nil
local isClosed = true
local exitPosition = nil
local playerPosition = nil
local doorPosition = nil

local animator = nil
local openAnimation = 0
local closeAnimation = 1

local doorSFX = nil

function on_ready()

    doorSFX = current_scene:get_entity_by_name("EnviroMetaldoorSFX"):get_component("AudioSourceComponent")

    rigidBody = self:get_component("RigidbodyComponent").rb
    local children = self:get_children()
    for _, child in ipairs(children) do
        local childTag = child:get_component("TagComponent").tag
        if childTag:match("^Lever") then
            minimumInteractions = minimumInteractions + 1
        end
        if childTag:match("^Door") then
            animator = child:get_component("AnimatorComponent")
        end
        if childTag:match("^ExitTrigger") then
            exitPosition = child:get_component("TransformComponent").position
        end
    end
    
    playerPosition = current_scene:get_entity_by_name("Player"):get_component("TransformComponent").position
    doorPosition = self:get_component("TransformComponent").position
end

function on_update(dt)
    if not isClosed and exitPosition then
        local distance = Vector3.new(
            math.abs(playerPosition.x - (doorPosition.x + exitPosition.x)),
            0,
            math.abs(playerPosition.z - (doorPosition.z + exitPosition.z))
        )

        if distance:length() < 1 then
            currentInteractions = 0
            if animator then
                animator:set_current_animation(closeAnimation)
            end
            rigidBody:set_trigger(false)
            isClosed = true
        end
    end
end

function on_interact()
    currentInteractions = currentInteractions + 1
    if currentInteractions >= minimumInteractions and isClosed then
        if animator then
            animator:set_current_animation(openAnimation)
        end
        rigidBody:set_trigger(true)
        isClosed = false
        doorSFX:play()
    end
end

function on_exit()
    -- Add cleanup code here
end
