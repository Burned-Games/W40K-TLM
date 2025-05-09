local player
local playerTransf = nil
local playerScript = nil
local playerPos
local playerDirectionX = 0
local playerDirectionY = 0
local playerDirectionZ = 0
local cameraSpeed = 2
--zoom
local zoom = -1.5
local baseZoom = -1.5
local bossZoom = 5
local coliseumZoom = 1.5
local minZoom = -3.5
local maxZoom = -1.5
local zoomStep = 0.5
cameraBossActivated = false
local normalOffset = Vector3.new(-10, 15, 10)
local baseOffset = normalOffset
local backOffset = Vector3.new(-10, 10, 10)
local zoomedOffset = Vector3.new(-5, 7, 5)
local cameraTransform = nil
local directionCached = false
local smoothPos = Vector3.new(0, 0, 0)

local offsetPlayerBase = 5

local offsetPlayer = offsetPlayerBase

local backOffsetPlayer = 1

local radiusSpawn = 25

local entities = nil

enemies  = nil

local pauseScript = nil
local workbenchUIManagerScript = nil

--Shake
local shakeAmount = 0
local shakeDuration = 0
local shakeDecay = 3

local mapPolygonLevel1 = {
    {x = 0, z = 7},
    {x = 16, z = 0},
    {x = 32, z = 0},
    {x = 35, z = -12},
    {x = 35, z = -30},
    {x = 35, z = -65},
    {x = 60, z = -106},
    {x = 139, z = -106}, 
    {x = 165, z = -133},
    {x = 175, z = -144},
    {x = 125, z = -154},

    -- COLISEO INICIO

    {x = 169, z = -180},

    -- INICIO

    {x = 199, z = -200},
    {x = 250, z = -200},
    {x = 257, z = -254},
    {x = 219, z = -254},
    {x = 219, z = -269},

    -- MEDIO

    {x = 195, z = -274},
    {x = 195, z = -219},
    {x = 175, z = -220},

    -- FINAL

    -- COLISEO FINAL

    {x = 181, z = -209},
    {x = 136, z = -194},
    {x = 105, z = -166},
    {x = 102, z = -185},
    {x = 86, z = -192},
    {x = 73, z = -173},
    {x = 84, z = -165},
    {x = 107, z = -140},
    {x = 90, z = -116},
    {x = 68, z = -116},
    {x = 55, z = -128},
    {x = 37, z = -128},
    {x = 19, z = -112},
    {x = -40, z = -112},
    {x = -45, z = -108},
    {x = -40, z = -87},
    {x = -56, z = -40},
    {x = -50, z = -30},
    {x = -30, z = -28},
    {x = -10, z = -18},
    {x = -10,  z = 7}
}

-- local mapPolygonLevel2 = {
--     {x = -1000, z = -1000},
--     {x = 1000, z = -1000},
--     {x = 1000, z = 1000},
--     {x = -1000, z = 1000}
-- }

local mapPolygonLevel2 = {

    -- abajo derecha
    {x = -16, z = 18},
    {x = 5, z = 18},
    {x = 2, z = -12},
    {x = 17, z = -12},
    {x = 17, z = -32},
    {x = 46, z = -34},
    {x = 51, z = -57},
    {x = 72, z = -20},

    -- arriba derecha
    {x = 103, z = -32},


    -- arriba izquierda
    {x = 116, z = -65},
    {x = 85, z = -79},
    {x = 20, z = -70},


    -- abajo izquierda
    {x = -25, z = -44}

}

local mapPolygonLevel3 = {
    {x = -18, z = 4},
    {x = 2, z = 10},
    {x = 11, z = -89},
    {x = -25, z = -70},
    {x = -12, z = -53},
    {x = -12, z = -11}

}

local mapPolygonOthers= {
    {x = -1000, z = -1000},
    {x = 1000, z = -1000},
    {x = 1000, z = 1000},
    {x = -1000, z = 1000}
}

local actualMapPolygon = nil




function on_ready()
    -- Add initialization code here

    
    player = current_scene:get_entity_by_name("Player")

    playerTransf = player:get_component("TransformComponent")

    playerScript = player:get_component("ScriptComponent")

    pauseScript = current_scene:get_entity_by_name("PauseBase"):get_component("ScriptComponent")

    workbenchUIManagerScript = current_scene:get_entity_by_name("WorkBenchUIManager"):get_component("ScriptComponent")

    

    
    
    playerPos = player:get_component("TransformComponent").position; 

    cameraTransform = self:get_component("TransformComponent") 

    cameraTransform.rotation = Vector3.new(-45, -45, 0)

    

    local zoomOffSet = Vector3.new(baseOffset.x * (1 + zoom * 0.2), baseOffset.y * (1 + zoom * 0.2), baseOffset.z * (1 + zoom * 0.2)) 

    
    local targetPos = Vector3.new(playerPos.x + zoomOffSet.x, playerPos.y + zoomOffSet.y, playerPos.z + zoomOffSet.z) 

    cameraTransform.position = targetPos 

    entities = current_scene:get_all_entities() 

    enemies = {} 

    for _, entity in ipairs(entities) do 
        local tag = entity:get_component("TagComponent").tag 
        if tag == "EnemyRange" or tag == "EnemySupp" or tag == "EnemyKamikaze" or tag == "EnemyTank" or tag== "EnemyRange1" or tag== "EnemyRange2" or tag== "EnemyRange3" or tag== "EnemyRange4" or tag== "EnemyRange5" or tag== "EnemyRange6" or tag == "EnemyTank1" or tag == "EnemyTank2" or tag == "EnemyTank3" or tag == "EnemyTank4" or tag == "EnemyTank5" or tag == "EnemyTank6" or tag == "MainBoss" then 
            table.insert(enemies, entity)
            entity:set_active(false) 
        end
    end

    log(SceneManager:get_scene_name())

    if SceneManager:get_scene_name() == "level1.TeaScene" then
        actualMapPolygon = mapPolygonLevel1
    elseif SceneManager:get_scene_name() == "level2.TeaScene" then
        actualMapPolygon = mapPolygonLevel2
    elseif SceneManager:get_scene_name() == "level3.TeaScene" then
        actualMapPolygon = mapPolygonLevel3
    else
        actualMapPolygon = mapPolygonOthers
    end

end

function on_update(dt)

    if playerScript and playerScript.moveDirection then
        if playerScript.moveDirection.x ~= 0 and playerScript.moveDirection.z ~= 0 then
            updateEnemyActivation()
        end
        -- Add update code here
        local zoomOffSet = Vector3.new(baseOffset.x * (1 + zoom * 0.2), baseOffset.y * (1 + zoom * 0.2), baseOffset.z * (1 + zoom * 0.2))  

        local forwardVector = Vector3.new(math.sin(playerScript.angleRotation), 0, math.cos(playerScript.angleRotation))

        local targetPos = Vector3.new(playerPos.x + zoomOffSet.x + forwardVector.x * offsetPlayer, playerPos.y + zoomOffSet.y + forwardVector.y * offsetPlayer, playerPos.z + zoomOffSet.z + forwardVector.z * offsetPlayer)
    
        --Check camera in map bounds
        local targetX = targetPos.x
        local targetZ = targetPos.z

        -- Si está fuera del polígono, buscamos un punto válido cercano
        if playerScript.godMode and not IsPointInPolygon(targetX, targetZ, actualMapPolygon) then
            -- Busca el punto más cercano dentro del polígono
            local closest = GetClosestPointInPolygon(targetX, targetZ, actualMapPolygon)
            targetX = closest.x
            targetZ = closest.z
        end

        -- Usamos la Y original porque la cámara flota
        local adjustedTarget = Vector3.new(targetX, targetPos.y, targetZ)

        -- Movimiento suave como antes
        local currentPos = cameraTransform.position
        smoothPos = Vector3.lerp(currentPos, adjustedTarget, dt * cameraSpeed)
        cameraTransform.position = smoothPos

        if not cameraBossActivated and playerScript.godMode == false and pauseScript.isPaused == false and not workbenchUIManagerScript.isWorkBenchOpen then
            if Input.is_button_pressed(Input.controllercode.DpadUp) then
                if zoom > minZoom then
                    zoom = zoom - zoomStep
                end
            elseif Input.is_button_pressed(Input.controllercode.DpadDown) then
                if zoom < maxZoom then
                    zoom = zoom + zoomStep
                end
            end
        end
        
        if playerScript.movingBackLookingUp == true or playerScript.notMovingLookingUp == true or playerScript.notMovingnotLooking == true then
            offsetPlayer = backOffsetPlayer
        else
            offsetPlayer = offsetPlayerBase
        end

    end

    if shakeDuration > 0 then
        local shakeOffset = Vector3.new(
            (math.random() * 2 - 1) * shakeAmount,
            (math.random() * 2 - 1) * shakeAmount,
            (math.random() * 2 - 1) * shakeAmount
        )

        smoothPos = Vector3.new(smoothPos.x + shakeOffset.x, smoothPos.y + shakeOffset.y, smoothPos.z + shakeOffset.z) 

        shakeDuration = shakeDuration - dt
        shakeAmount = shakeAmount * math.exp(-shakeDecay * dt)
        cameraTransform.position = smoothPos

        
    end
end

function updateEnemyActivation()


    for _, entity in ipairs(enemies) do 
        if entity ~= player and entity:has_component("RigidbodyComponent") and entity:has_component("ScriptComponent")then
            local entityRb = entity:get_component("RigidbodyComponent").rb
            local entityPos = entityRb:get_position()

            local direction = Vector3.new(
                entityPos.x - playerTransf.position.x,
                entityPos.y - playerTransf.position.y,
                entityPos.z - playerTransf.position.z
            )

            local distance = math.sqrt(
                direction.x * direction.x +
                direction.y * direction.y +
                direction.z * direction.z
            )

            if distance > 0 then
                direction.x = direction.x / distance
                direction.y = direction.y / distance
                direction.z = direction.z / distance
            end

            if distance < radiusSpawn then
                     
                entity:set_active(true)

                
            end
        end
    end
end

function startShake(amount, duration)
    shakeAmount = amount
    shakeDuration = duration
end

function cameraBoss(self, bool)

    if bool == true then
        zoom = bossZoom
    else
        zoom = baseZoom
    end

    cameraBossActivated = bool
end

function cameraColisseum(self, activate)

    if activate == true then
        zoom = coliseumZoom
    else
        zoom = baseZoom
    end

    
    cameraBossActivated = activate

end

function IsPointInPolygon(x, z, polygon)
    local inside = false
    local j = #polygon
    for i = 1, #polygon do
        local xi, zi = polygon[i].x, polygon[i].z
        local xj, zj = polygon[j].x, polygon[j].z

        local intersect = ((zi > z) ~= (zj > z)) and
                          (x < (xj - xi) * (z - zi) / ((zj - zi) + 0.0001) + xi)
        if intersect then
            inside = not inside
        end
        j = i
    end
    return inside
end

function GetClosestPointInPolygon(x, z, polygon)
    local closest = {x = polygon[1].x, z = polygon[1].z}
    local minDistSq = math.huge

    for i = 1, #polygon do
        local a = polygon[i]
        local b = polygon[(i % #polygon) + 1]

        local proj = ProjectPointOnSegment(x, z, a.x, a.z, b.x, b.z)
        local dx = x - proj.x
        local dz = z - proj.z
        local distSq = dx * dx + dz * dz

        if distSq < minDistSq then
            minDistSq = distSq
            closest = proj
        end
    end

    return closest
end

function ProjectPointOnSegment(px, pz, ax, az, bx, bz)
    local abx = bx - ax
    local abz = bz - az
    local apx = px - ax
    local apz = pz - az
    local abLenSq = abx * abx + abz * abz
    if abLenSq == 0 then
        return {x = ax, z = az}
    end
    local t = (apx * abx + apz * abz) / abLenSq
    t = math.max(0, math.min(1, t))
    return {x = ax + t * abx, z = az + t * abz}
end



function on_exit()
    -- Add cleanup code here
end
