

local objectNormal = {}

local prefabPillar1 = "prefabs/Misc/Pillars/DestructiblePillar1.prefab"
local prefabPillar2 = "prefabs/Misc/Pillars/DestructiblePillar2.prefab"
local prefabPillar3 = "prefabs/Misc/Pillars/DestructiblePillar3.prefab"



local rbComponent = nil
local transform = nil

local separateChildren = nil
local separateChildrenWithParentMoved = {}
local separateChildrenWithParentMovedTransform = {}
local separateChildrenWithParentMovedRigidbody = {}
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

local originalMaterial = {}
local actualRGBA = Vector4.new(1,1,1,1)
local targetColor = Vector4.new(255/255,99/255,36/255,1)
local changeColorSpeed = 300
local colorDirection = 0 -- 0 = To target | 1 = To actual

local ultimateBossScript = nil

function on_ready()
    -- Add initialization code here
    local children = self:get_children()
    for _, child in ipairs(children) do
        local childTag = child:get_component("TagComponent").tag
        
        if childTag:match("^Normal") then
            table.insert(objectNormal, child)
            table.insert(originalMaterial, child:get_component("MaterialComponent").material)
        end
    end

    position00 = current_scene:get_entity_by_name("Position00")

    camera = current_scene:get_entity_by_name("Camera")
    cameraScript = camera:get_component("ScriptComponent")

    ultimateBossScript = current_scene:get_entity_by_name("Ultimate"):get_component("ScriptComponent")
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

            local rbC = piece:get_component("RigidbodyComponent")
            local rb = rbC.rb
            local pieceTransform = piece:get_component("TransformComponent")

            piece:set_parent(position00)
            table.insert(separateChildrenWithParentMoved, piece)
            table.insert(separateChildrenWithParentMovedTransform, pieceTransform)
            table.insert(separateChildrenWithParentMovedRigidbody, rbC)

            local pivotObjectPosition = self:get_component("TransformComponent").position
            local pivotSeparateChild = separateChild:get_component("TransformComponent").position
            local pivotChildPosition = pieceTransform.position
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
    if hasDisappeared then return end

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
        
        self:set_active(false)
        for _, child in ipairs(separateChildrenWithParentMovedRigidbody) do
            child.rb:set_position(Vector3.new(-1000,-1000,-1000))
            
            --child:set_active(false)
            --child:remove_component("RigidbodyComponent")
            --current_scene:destroy_entity(child)
            --child:set_parent(separate)
        end
        separate:set_active(false)
        finished = true
    end

    if not hasDestroyed then
        changeColor(dt)
    end

end

function setChildrenSize(size)
    
    for _, childTransform in ipairs(separateChildrenWithParentMovedTransform) do
        childTransform.scale = Vector3.new(size,size,size)
    end
end

function changeColor(dt)
    local step = (dt / 255) * changeColorSpeed

    if colorDirection == 0 and ultimateBossScript.ultimateThrown then
        -- Ir hacia el targetColor
        local r = math.max(actualRGBA.x - step, targetColor.x)
        local g = math.max(actualRGBA.y - step, targetColor.y)
        local b = math.max(actualRGBA.z - step, targetColor.z)
        local a = math.max(actualRGBA.w - step, targetColor.w)

        actualRGBA = Vector4.new(r, g, b, a)

        -- Si ya llegamos al target en todos los canales, cambiamos dirección
        if actualRGBA.x == targetColor.x and
           actualRGBA.y == targetColor.y and
           actualRGBA.z == targetColor.z and
           actualRGBA.w == targetColor.w then
            colorDirection = 1
        end

    else
        -- Volver a blanco (1,1,1,1)
        local r = math.min(actualRGBA.x + step, 1)
        local g = math.min(actualRGBA.y + step, 1)
        local b = math.min(actualRGBA.z + step, 1)
        local a = math.min(actualRGBA.w + step, 1)

        actualRGBA = Vector4.new(r, g, b, a)

        -- Si ya llegamos a blanco, cambiamos dirección
        if actualRGBA.x == 1 and
           actualRGBA.y == 1 and
           actualRGBA.z == 1 and
           actualRGBA.w == 1 then
            colorDirection = 0
        end
    end

    for i, mat in ipairs(originalMaterial) do 
        mat.color = actualRGBA
    end
end

function on_exit()
    -- Add cleanup code here
end
