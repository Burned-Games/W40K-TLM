

local objectNormal = nil
local objectSeparate = nil

local separateChildren = nil;

local hasDestroyed = false

local rbComponent = nil
local impulseStrength = 0


local disappearCounter = 0
local disappearCounterTarget = 5
local hasDisappeared = false

local actualSize = 1
local sizeDisappearSpeed = 3

function on_ready()
    -- Add initialization code here

    local children = self:get_children()
    for _, child in ipairs(children) do
        if child:get_component("TagComponent").tag == "Normal" then
            objectNormal = child
            
        elseif child:get_component("TagComponent").tag == "Separate" then
            objectSeparate = child
        end
    end

    separateChildren = objectSeparate:get_children()
    objectSeparate:set_active(false)
    objectNormal:set_active(true)

    rbComponent = self:get_component("RigidbodyComponent");
    rbComponent:on_collision_enter(function(entityA, entityB)

        local nameA = entityA:get_component("TagComponent").tag
        local nameB = entityB:get_component("TagComponent").tag
        if nameA == "Sphere1" or nameA == "Sphere2" or nameA == "Sphere3" or nameA == "Sphere4" or nameA == "Sphere5" or nameA == "Sphere6" or nameA == "Sphere7" or nameA == "Sphere8"
        or nameB == "Sphere1" or nameB == "Sphere2" or nameB == "Sphere3" or nameB == "Sphere4" or nameB == "Sphere5" or nameB == "Sphere6" or nameB == "Sphere7" or nameB == "Sphere8" then
            if not hasDestroyed then
                --cameraScript.startShake(0.2,5)
                give_phisycs()
                hasDestroyed = true
            end
            
        end


    end)
end


function give_phisycs()
    rbComponent.rb:set_trigger(true)
    rbComponent.rb:set_use_gravity(false)
    objectSeparate:set_active(true)
    objectNormal:set_active(false)

    for _, child in ipairs(separateChildren) do
        if not child:has_component("RigidbodyComponent") then
            child:add_component("RigidbodyComponent")
        end

        if child:has_component("RigidbodyComponent") then
            local rb = child:get_component("RigidbodyComponent").rb

            local pivotObjectPosition = self:get_component("TransformComponent").position
            local pivotChildPosition = child:get_component("TransformComponent").position

            local impulseForce = Vector3.new(pivotObjectPosition.x - pivotChildPosition.x, pivotObjectPosition.y - pivotChildPosition.y, pivotObjectPosition.z - pivotChildPosition.z )
            impulseForce = Vector3.new(impulseForce.x + impulseStrength, impulseForce.y  + impulseStrength, impulseForce.z  + impulseStrength)

            rb:apply_impulse(impulseForce)
            rb:apply_torque_impulse(impulseForce)
        
        end

    end



end

function on_update(dt)
    if Input.is_key_pressed(Input.keycode.J) then
        if not hasDestroyed then
            --cameraScript.startShake(0.2,5)
            give_phisycs()
            hasDestroyed = true
        end
    end

    if hasDestroyed and not hasDisappeared then
        disappearCounter = disappearCounter + dt

        if disappearCounter >= disappearCounterTarget then
            actualSize = actualSize - dt * sizeDisappearSpeed
            
            if actualSize <= 0 then
                actualSize = 0
                hasDisappeared = true
            end
            setChildrenSize(actualSize)
        end

    end
    local disappearCounter = 0
    local disappearCounterTarget = 5
    local hasDisappeared = false

end

function setChildrenSize(size)
    
    for _, child in ipairs(separateChildren) do
        child:get_component("TransformComponent").scale = Vector3.new(size,size,size)
    end
end

function on_exit()
    -- Add cleanup code here
end
