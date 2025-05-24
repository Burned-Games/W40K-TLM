

local objectNormal = nil

local prefabBarril = "prefabs/Misc/BarrilSeparado.prefab"
local prefabCaja = "prefabs/Misc/CajaSeparado.prefab"
local prefabCajaV2 = "prefabs/Misc/CajaSeparadoV2.prefab"

local rbComponent = nil

local separateChildren = nil
local separateChildrenWithParentMoved = {}
local separate = nil

hasDestroyed = false

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
            objectNormal = child
        end
    end

    position00 = current_scene:get_entity_by_name("Position00")

    camera = current_scene:get_entity_by_name("Camera")
    cameraScript = camera:get_component("ScriptComponent")

    --Audio
    boxBarrelDestroySFX = current_scene:get_entity_by_name("BoxBarrelDestroySFX"):get_component("AudioSourceComponent")

    rbComponent = self:get_component("RigidbodyComponent");
    rbComponent.rb:get_collider():set_box_size(Vector3.new(0.8,0.8,0.8))
    rbComponent.rb:set_freeze_x(true)
    rbComponent.rb:set_freeze_y(true)
    rbComponent.rb:set_freeze_z(true)
    rbComponent.rb:set_freeze_rot_x(true)
    rbComponent.rb:set_freeze_rot_y(true)
    rbComponent.rb:set_freeze_rot_z(true)

    rbComponent:on_collision_enter(function(entityA, entityB)

        local nameA = entityA:get_component("TagComponent").tag
        local nameB = entityB:get_component("TagComponent").tag
        if nameA == "Sphere1" or nameA == "Sphere2" or nameA == "Sphere3" or nameA == "Sphere4" or nameA == "Sphere5" or nameA == "Sphere6" or nameA == "Sphere7" or nameA == "Sphere8"
        or nameB == "Sphere1" or nameB == "Sphere2" or nameB == "Sphere3" or nameB == "Sphere4" or nameB == "Sphere5" or nameB == "Sphere6" or nameB == "Sphere7" or nameB == "Sphere8" then
            if not hasDestroyed then
                cameraScript.startShake(0.05,2)
                give_phisycs()
                hasDestroyed = true
                boxBarrelDestroySFX:play()
            end
            
        end


    end)

end


function give_phisycs()
    rbComponent.rb:set_trigger(true)
    rbComponent.rb:set_use_gravity(false)

    separate = nil

    local tag = self:get_component("TagComponent").tag

    if tag == "BarrilDestruible" then
        separate = instantiate_prefab(prefabBarril)
    elseif tag == "CajaDestruible" then
        separate = instantiate_prefab(prefabCaja)
    elseif tag == "CajaDestruibleV2" then
        separate = instantiate_prefab(prefabCajaV2)
    end

    if separate == nil then return end

    separate:get_component("TransformComponent").position = self:get_component("TransformComponent").position
    separate:get_component("TransformComponent").rotation = self:get_component("TransformComponent").rotation

    separateChildren = separate:get_children()

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
