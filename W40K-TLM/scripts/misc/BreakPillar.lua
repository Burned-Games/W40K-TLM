

local objectNormal = {}

local prefabPillar1 = "prefabs/Misc/Pillars/Pillar1Destruible.prefab"
local prefabPillar2 = "prefabs/Misc/Pillars/Pillar2Destruible.prefab"




local rbComponent = nil


local separateChildrenWithParentMoved = {}
local separate = {}
local separateChildren = {}


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

    rbComponent = self:get_component("RigidbodyComponent");

end


function give_phisycs()

    separate = nil
    hasDestroyed = true

    local tag = self:get_component("TagComponent").tag

    if tag == "Pillar1" then
        local instantiated = instantiate_prefab(prefabPillar1)
        log("holaaaaaaaaaaaaaaaa")
        table.insert(separate, instantiated)
        
    elseif tag == "Pillar2" then
        table.insert(separate, instantiate_prefab(prefabPillar1))
        table.insert(separate, instantiate_prefab(prefabPillar2))
    elseif tag == "Pillar3" then
        table.insert(separate, instantiate_prefab(prefabPillar1))
        table.insert(separate, instantiate_prefab(prefabPillar2))
        table.insert(separate, instantiate_prefab(prefabPillar2))
    end



    for i, parentColumns in ipairs(separate) do
        local transform = self:get_component("TransformComponent")
        
        parentColumns:get_component("TransformComponent").position = Vector3.new(transform.position.x, transform.position.y+(4*i), transform.position.z)
        parentColumns:get_component("TransformComponent").rotation = self:get_component("TransformComponent").rotation
        separateChildren = parentColumns:get_children()

        local parentsChildren = parentColumns:get_children()
        for _, parentChild in ipairs(parentsChildren) do
            
            table.insert(separateChildren, parentChild)
        end
    end

    for _, child in ipairs(separateChildren) do
        if child:has_component("RigidbodyComponent") then
            local rb = child:get_component("RigidbodyComponent").rb

            child:set_parent(position00)
            table.insert(separateChildrenWithParentMoved, child)

            local pivotObjectPosition = self:get_component("TransformComponent").position
            local pivotChildPosition = child:get_component("TransformComponent").position

            local pivotChildPositionOffset = Vector3.new(pivotObjectPosition.x + pivotChildPosition.x, pivotObjectPosition.y + pivotChildPosition.y, pivotObjectPosition.z + pivotChildPosition.z)

            rb:set_position(pivotChildPositionOffset)

            local impulseForce = Vector3.new(pivotObjectPosition.x - pivotChildPositionOffset.x, pivotObjectPosition.y - pivotChildPositionOffset.y, pivotObjectPosition.z - pivotChildPositionOffset.z )

            impulseForce = Vector3.new((impulseForce.x + impulseStrength) * math.random(-1,1), (impulseForce.y  + 0) + math.random(-1,1), (impulseForce.z  + impulseStrength) * math.random(-1,1))

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
    
    for _, child in ipairs(separateChildren) do
        child:get_component("TransformComponent").scale = Vector3.new(size,size,size)
    end
end

function on_exit()
    -- Add cleanup code here
end
