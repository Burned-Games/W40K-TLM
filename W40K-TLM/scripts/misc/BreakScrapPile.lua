

local objectNormal = nil

local separate = nil

local separateChildren = nil;

hasDestroyed = false

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

local camera = nil
local cameraScript = nil


local originalMaterial = nil
local actualRGBA = Vector4.new(1,1,1,1)
local targetColor = Vector4.new(255/255,99/255,36/255,1)
local changeColorSpeed = 300
local colorDirection = 0 -- 0 = To target | 1 = To actual

--Audio
local scrapDestroySFX = nil

function on_ready()
    -- Add initialization code here

    local children = self:get_children()

    camera = current_scene:get_entity_by_name("Camera")
    cameraScript = camera:get_component("ScriptComponent")

    for _, child in ipairs(children) do
        if child:get_component("TagComponent").tag == "Normal" then
            objectNormal = child
        end
    end

    originalMaterial = objectNormal:get_component("MaterialComponent").material

     --Audio
     scrapDestroySFX = current_scene:get_entity_by_name("ScrapDestroySFX"):get_component("AudioSourceComponent")

    rbComponent = self:get_component("RigidbodyComponent");
    rbComponent.rb:get_collider():set_box_size(Vector3.new(2.5,3.0,2.6))
    rbComponent:on_collision_enter(function(entityA, entityB)

        local nameA = entityA:get_component("TagComponent").tag
        local nameB = entityB:get_component("TagComponent").tag
        if nameA == "Sphere1" or nameA == "Sphere2" or nameA == "Sphere3" or nameA == "Sphere4" or nameA == "Sphere5" or nameA == "Sphere6" or nameA == "Sphere7" or nameA == "Sphere8"
        or nameB == "Sphere1" or nameB == "Sphere2" or nameB == "Sphere3" or nameB == "Sphere4" or nameB == "Sphere5" or nameB == "Sphere6" or nameB == "Sphere7" or nameB == "Sphere8" then
            if not hasDestroyed then
                cameraScript.startShake(0.1,3)
                give_phisycs()
                hasDestroyed = true
                scrapDestroySFX:play()
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

    separateChildren = separate:get_children();

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
     self:get_component("RigidbodyComponent").rb:set_position(Vector3.new(-100,-100,-100))

end

function on_update(dt)
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

    if not hasDestroyed then
        changeColor(dt)
    end

    if hasDisappeared then
        separate:set_active(false)
        self:set_active(false)
    end


end

function setChildrenSize(size)
    
    for _, child in ipairs(separateChildren) do
        child:get_component("TransformComponent").scale = Vector3.new(size,size,size)
    end
end

function changeColor(dt)
    local step = (dt / 255) * changeColorSpeed

    if colorDirection == 0 then
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

    if originalMaterial then
        originalMaterial.color = actualRGBA
    end
end


function on_exit()
    -- Add cleanup code here
end
