

local objectNormal = nil

local separate = nil

local separateChildren = nil;

local hasDestroyed = false

local rbComponent = nil
local impulseStrength = 0


local disappearCounter = 0
local disappearCounterTarget = 5
local hasDisappeared = false

local actualSize = 1
local sizeDisappearSpeed = 3

local prefabScrap= "prefabs/Misc/Scrap.prefab"
local prefabScrapSeparate = "prefabs/Misc/SeparateScrapPile.prefab"

local transform = nil

local scrapSpawnArea = 4;

function on_ready()
    -- Add initialization code here

    local children = self:get_children()

    for _, child in ipairs(children) do
        if child:get_component("TagComponent").tag == "Normal" then
            objectNormal = child
        end
    end


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

    transform = self:get_component("TransformComponent")


end


function give_phisycs()
    rbComponent.rb:set_trigger(true)
    rbComponent.rb:set_use_gravity(false)

    --objectNormal:get_component("TransformComponent").position = Vector3.new(-100, -100, -100)

    separate = instantiate_prefab(prefabScrapSeparate)
    separate:get_component("TransformComponent").position = self:get_component("TransformComponent").position
    separate:get_component("TransformComponent").rotation = self:get_component("TransformComponent").rotation

    separateChildren = separate:get_children()

    for _, child in ipairs(separateChildren) do
        if child:has_component("RigidbodyComponent") then
            local rb = child:get_component("RigidbodyComponent").rb

            local pivotObjectPosition = self:get_component("TransformComponent").position
            local pivotChildPosition = child:get_component("TransformComponent").position

            local pivotChildPositionOffset = Vector3.new(pivotObjectPosition.x + pivotChildPosition.x, pivotObjectPosition.y + pivotChildPosition.y, pivotObjectPosition.z + pivotChildPosition.z)

            local impulseForce = Vector3.new(pivotObjectPosition.x - pivotChildPositionOffset.x, pivotObjectPosition.y - pivotChildPositionOffset.y, pivotObjectPosition.z - pivotChildPositionOffset.z )

            impulseForce = Vector3.new((impulseForce.x + impulseStrength) * math.random(-1,1), (impulseForce.y  + 0) + math.random(-1,1), (impulseForce.z  + impulseStrength) * math.random(-1,1))

            rb:apply_impulse(impulseForce)
            rb:apply_torque_impulse(impulseForce)
        
        end

    end

    local randomNumberSpawnScrap = math.random(1,3)

    for i = 1, randomNumberSpawnScrap do
        local scrap = instantiate_prefab(prefabScrap)

        --local randomX = math.random((transform.position.x - scrapSpawnArea), (transform.position.x + scrapSpawnArea))
        --local randomZ = math.random((transform.position.z - scrapSpawnArea), (transform.position.z + scrapSpawnArea))

        local positionXMIN = transform.position.x - scrapSpawnArea
        local positionXMAX = transform.position.x + scrapSpawnArea
        local positionZMIN = transform.position.z - scrapSpawnArea
        local positionZMAX = transform.position.z + scrapSpawnArea

        local randomX = positionXMIN + (positionXMAX - positionXMIN) * math.random()
        local randomZ = positionZMIN + (positionZMAX - positionZMIN) * math.random()

        scrap:get_component("TransformComponent").position = Vector3.new(randomX, transform.position.y, randomZ)

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
end

function setChildrenSize(size)
    
    for _, child in ipairs(separateChildren) do
        child:get_component("TransformComponent").scale = Vector3.new(size,size,size)
    end
end

function on_exit()
    -- Add cleanup code here
end
