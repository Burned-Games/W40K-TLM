local minimumInteractions = 0
local currentInteractions = 0
local rigidBody = nil
local isClosed = true

function on_ready()
    rigidBody = self:get_component("RigidbodyComponent").rb
    local children = self:get_children()
    for _, child in ipairs(children) do
        local childTag = child:get_component("TagComponent").tag
        if childTag:match("^Lever") then
            minimumInteractions = minimumInteractions + 1
        end
    end
end

function on_update(dt)
    -- Add update code here
end

function on_interact()
    currentInteractions = currentInteractions + 1
    if currentInteractions >= minimumInteractions and isClosed then
        rigidBody:set_trigger(true)
        isClosed = false
    end
end

function on_exit()
    -- Add cleanup code here
end
