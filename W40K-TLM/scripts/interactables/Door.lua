local minimumInteractions = 0
local currentInteractions = 0
local rigidBody = nil
local isClosed = true

local animator = nil
local openAnimation = 0
local closeAnimation = 1

function on_ready()
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
    end
end

function on_update(dt)
    -- Add update code here
end

function on_interact()
    currentInteractions = currentInteractions + 1
    if currentInteractions >= minimumInteractions and isClosed then
        animator:set_current_animation(openAnimation)
        rigidBody:set_trigger(true)
        isClosed = false
    end
end

function on_exit()
    -- Add cleanup code here
end
