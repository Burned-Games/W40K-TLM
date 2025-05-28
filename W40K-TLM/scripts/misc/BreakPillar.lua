

local objectNormal = {}

local prefabPillar1 = "prefabs/Misc/Pillars/DestructiblePillar1.prefab"
local prefabPillar2 = "prefabs/Misc/Pillars/DestructiblePillar2.prefab"
local prefabPillar3 = "prefabs/Misc/Pillars/DestructiblePillar3.prefab"




local rbComponent = nil
local transform = nil

local separateChildren = nil
local separateChildrenWithParentMoved = {}
local separate = nil


local hasDestroyed = false

local impulseStrength = 0

local disappearCounter = 0
local disappearCounterTarget = 5  --TIME FOR DISAPPEAR
local hasDisappeared = false
local actualSize = 1
local sizeDisappearSpeed = 3

local finished = false

local camera = nil
local cameraScript = nil

local position00 = nil

--Audio
local boxBarrelDestroySFX = nil

function on_ready()
    -- Add initialization code here
    local children = self:get_children()
    for _, child in ipairs(children) do
        if child:get_component("TagComponent").tag == "Normal" then
            table.insert(objectNormal, child)
        end
    end

    position00 = current_scene:get_entity_by_name("Position00")

    camera = current_scene:get_entity_by_name("Camera")
    cameraScript = camera:get_component("ScriptComponent")

    --Audio
    --boxBarrelDestroySFX = current_scene:get_entity_by_name("BoxBarrelDestroySFX"):get_component("AudioSourceComponent")

    rbComponent = self:get_component("RigidbodyComponent")
    transform = self:get_component("TransformComponent")

end


function give_phisycs()

    separate = nil
    hasDestroyed = true

    local tag = self:get_component("TagComponent").tag

    if tag == "Pillar1" then
        separate = instantiate_prefab(prefabPillar1)
    elseif tag == "Pillar2" then
        separate = instantiate_prefab(prefabPillar2)
    elseif tag == "Pillar3" then
        separate = instantiate_prefab(prefabPillar3)
    end

    if separate == nil then return end

    separate:get_component("TransformComponent").position = transform.position
    separate:get_component("TransformComponent").rotation = transform.rotation

    separateChildren = separate:get_children()

    for i, separateChild in ipairs(separateChildren) do
        local pieces = separateChild:get_children()
        for j, piece in ipairs(pieces) do

            local rb = piece:get_component("RigidbodyComponent").rb


            piece:set_parent(position00)
            table.insert(separateChildrenWithParentMoved, piece)

            local pivotObjectPosition = self:get_component("TransformComponent").position
            local pivotSeparateChild = separateChild:get_component("TransformComponent").position
            local pivotChildPosition = piece:get_component("TransformComponent").position
            local pivotChildPositionOffset = Vector3.new(pivotObjectPosition.x + pivotSeparateChild.x + pivotChildPosition.x, pivotObjectPosition.y + pivotSeparateChild.y + pivotChildPosition.y, pivotObjectPosition.z + pivotSeparateChild.z + pivotChildPosition.z)

            rb:set_position(pivotChildPositionOffset)
            local impulseForce = Vector3.new((1 + impulseStrength) * math.random(-1,1), (1  + 0) + math.random(-1,1), (1  + impulseStrength) * math.random(-1,1))
            rb:apply_impulse(impulseForce)
            rb:apply_torque_impulse(impulseForce)
        end
    end
    self:get_component("RigidbodyComponent").rb:set_position(Vector3.new(-100,-100,-100))

end


function on_update(dt)
    -- Add update code here
    
    if Input.is_key_pressed(Input.keycode.J) and not hasDestroyed then
        give_phisycs()
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

    if hasDisappeared and not finished then
        separate:set_active(false)
        self:set_active(false)
        for _, child in ipairs(separateChildren) do
            child:set_active(false)
        end
        finished = true
    end

end

function setChildrenSize(size)
    
    for _, child in ipairs(separateChildrenWithParentMoved) do
        child:get_component("TransformComponent").scale = Vector3.new(size,size,size)
    end
end

function on_exit()
    -- Add cleanup code here
end
