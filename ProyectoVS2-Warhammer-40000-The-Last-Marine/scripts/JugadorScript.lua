local sphere = nil
local sphere1RigidBody = nil
local sphere1RigidBodyComponent = nil
local sphereSpeed = 100

local playerTransf
local playerWorldTransf
local forwardVector
local transformSphere
local disparado = false

local currentAnim = -1;
local animator;


local contadorDisparo = 0
local contadorDisparo2 = 0
local angleRotation = 0;


local audioSource;
local setMuted = false;
local timerShootSound = 2
local contadorShootSound = 0
local playShoot = false;

maxAmmo = 24;
ammo = 0;
local maxReloadTime = 2.5;
local reloadTime = 0;
local shootsCounter = 0;
local timeBetweenBursts = 0.5
local timeBetweenShoots = 0.1

playerHealth = 100;

local playerRb = nil
local moveSpeed = 6
local lastValidRotation = 0
local currentSpeed = 0         
local acceleration = 10      
local deceleration = 8

isMoving = false
local isAiming = false

local rifleAudioManagerScript 
local escopetaAudioManagerScript 

local actualweapon = 0 -- 0 = rifle; 1 = escopeta

local animacionEntradaRealizada = false;
local timerAnimacionEntrada = 0

local disparable = true


--granadas
local transformGranade
local granadeCooldown= 12;
local timerGranade = 0;
local throwingGranade = false
local granadeEntity = nil
local floorEntity = nil

local granadeVelocity = Vector3.new(0, 0, 0)
local granadeGravity = Vector3.new(0, -9.81, 0) 
local granadeInitialSpeed = 12

local explosionRadius = 7.0
local explosionForce = 13.0
local explosionUpward = 2.0


local shootParticlesComponent
local bulletDamageParticleComponent

local godMode = false
local pressedButton = false

local prevBackgroundMusicToPlay = -1
backgroundMusicToPlay = 0 -- 0 exploration; 1 combat

local explorationMusic = nil
local combatMusic = nil

local combatMusicVolume = 0;
local explorationMusicVolume = 0.05;



function on_ready()
    -- Add initialization code here

    explorationMusic = current_scene:get_entity_by_name("MusicExploration"):get_component("AudioSourceComponent")
    combatMusic = current_scene:get_entity_by_name("MusicCombat"):get_component("AudioSourceComponent")
    

    rifleAudioManagerScript = current_scene:get_entity_by_name("AudiosRifle"):get_component("ScriptComponent")
    escopetaAudioManagerScript = current_scene:get_entity_by_name("AudiosEscopeta"):get_component("ScriptComponent")
    shootParticlesComponent = current_scene:get_entity_by_name("ParticulasDisparo"):get_component("ParticlesSystemComponent");
    bulletDamageParticleComponent = current_scene:get_entity_by_name("ParticlePlayerBullet"):get_component("ParticlesSystemComponent");
    --aleix

    playerTransf = self:get_component("TransformComponent")
    playerWorldTransf = playerTransf:get_world_transform();
    
    playerRb = self:get_component("RigidbodyComponent").rb

    playerRb:set_angular_velocity(Vector3.new(0, 0, 0))

    forwardVector = Vector3.new(1,0,0)
    disparado = false

    --enemyOrk = current_scene:get_entity_by_name("EnemyOrk")
    --enemyOrkScript = enemyOrk:get_component("ScriptComponent")

    sphere1 = current_scene:get_entity_by_name("Sphere1")
    --sphere2 = current_scene:get_entity_by_name("Sphere2")
    --sphere3 = current_scene:get_entity_by_name("Sphere3")

    transformSphere1 = sphere1:get_component("TransformComponent")

    sphere1RigidBodyComponent = sphere1:get_component("RigidbodyComponent")
    sphere1RigidBody = sphere1:get_component("RigidbodyComponent").rb
    sphere1RigidBody:set_trigger(true)

    sphere1RigidBodyComponent:on_collision_enter(function(entityA, entityB)                -- El OnCollisionEnter no funciona, hay que mirar porque
        local nameA = entityA:get_component("TagComponent").tag
        local nameB = entityB:get_component("TagComponent").tag


        if nameA == "EnemyOrk" or nameB == "EnemyOrk" then
            local enemyOrk = nil
            local enemyOrkScript = nil
            if nameA == "EnemyOrk" then
                enemyOrk = entityA
                
            end

            if nameB == "EnemyOrk" then
                enemyOrk = entityB
            end
            if enemyOrk ~= nil then               
                enemyOrkScript = enemyOrk:get_component("ScriptComponent")
            end

            if enemyOrk ~= nil then
                if enemyOrkScript ~= nil then
                    local damage = 10
                    bulletDamageParticleComponent:emit(20)
                    enemyOrkScript.enemyHealth = enemyOrkScript.enemyHealth - damage
                    print("enemyOrkScript: " .. enemyOrkScript.enemyHealth)
            
                end
            end
           
            --make_damage()
        end
    end)



    animator = self:get_component("AnimatorComponent")


    granadeEntity = current_scene:get_entity_by_name("Granade")
    transformGranade = granadeEntity:get_component("TransformComponent")

    floorEntity = current_scene:get_entity_by_name("FloorCollider")

    local rb = granadeEntity:get_component("RigidbodyComponent").rb
    rb:set_use_gravity(true)
    rb:set_mass(1.0) 
    rb:set_trigger(false)


    local rbComponent = granadeEntity:get_component("RigidbodyComponent")
    rbComponent:on_collision_enter(function(entityA, entityB)

        local nameA = entityA:get_component("TagComponent").tag
        local nameB = entityB:get_component("TagComponent").tag

        if nameA == "FloorCollider" or nameB == "FloorCollider" then
            explodeGranade()
        end
    end)

    combatMusic:play()
    explorationMusic:play()


end

function on_update(dt)
    -- Add update code here




    if backgroundMusicToPlay == 0 and prevBackgroundMusicToPlay ~= backgroundMusicToPlay then



        if explorationMusicVolume >= 0.05 then
            explorationMusicVolume = 0.05;
            combatMusicVolume = 0;
            explorationMusic:set_volume(explorationMusicVolume)
            combatMusic:set_volume(combatMusicVolume)
            prevBackgroundMusicToPlay = 0
        else 
            explorationMusicVolume = explorationMusicVolume + dt * 0.05;
            combatMusicVolume = combatMusicVolume - dt  * 0.05;
            explorationMusic:set_volume(explorationMusicVolume)
            combatMusic:set_volume(combatMusicVolume)
        end
        


        
    elseif backgroundMusicToPlay == 1 and prevBackgroundMusicToPlay ~= backgroundMusicToPlay then
        if combatMusicVolume >= 0.05 then
            combatMusicVolume = 0.05;
            explorationMusicVolume = 0;
            combatMusic:set_volume(combatMusicVolume)
            explorationMusic:set_volume(explorationMusicVolume)
            prevBackgroundMusicToPlay = 1
        else 
            explorationMusicVolume = explorationMusicVolume - dt * 0.05;
            combatMusicVolume = combatMusicVolume + dt * 0.05;
            explorationMusic:set_volume(explorationMusicVolume)
            combatMusic:set_volume(combatMusicVolume)
        end
    end

    if Input.is_key_pressed(Input.keycode.F1) then
        if pressedButton == false then
            godMode = not godMode
        end
        pressedButton = true
    else
        pressedButton = false
    end

    if godMode then
        playerHealth = 100
        ammo = 0
        playerRb:set_trigger(true)
    else
        playerRb:set_trigger(false)
    end


    if animacionEntradaRealizada == false then
        if(currentAnim ~= 3) then
            currentAnim = 3
            animator:set_current_animation(currentAnim)
        end
        timerAnimacionEntrada = timerAnimacionEntrada + dt;

        if(timerAnimacionEntrada > 6.2 )then
            animacionEntradaRealizada = true;
            currentAnim = 4
            animator:set_current_animation(currentAnim)
        end

        print(timerAnimacionEntrada)

        return;
    end


    contadorDisparo = contadorDisparo + dt;

    playerMovement(dt)
    handleGranade(dt)

    if Input.is_button_pressed(Input.controllercode.North) == true then -- TODO
        
        if actualweapon == 0 then
            actualweapon = 1
        else
            actualweapon = 0
        end
    end

    backgroundMusicToPlay = 0
end 

function on_exit()
    -- Add cleanup code here
end



function shoot(dt)
    
    local playerPosition = playerTransf.position;
    local playerRotation = playerTransf.rotation;


    playShoot = true


    forwardVector = Vector3.new(math.sin(angleRotation), 0, math.cos(angleRotation))
    
    local newPosition = Vector3.new((forwardVector.x + playerPosition.x) , (forwardVector.y+ playerPosition.y)  , (forwardVector.z+ playerPosition.z) )

    transformSphere1.position = newPosition
    transformSphere1.rotation = Vector3.new(45,45,0)

    sphere1RigidBody:set_position(playerPosition)

    local velocity = Vector3.new(forwardVector.x * sphereSpeed, 0, forwardVector.z * sphereSpeed)
    sphere1RigidBody:set_velocity(velocity)

   
end





function playerMovement(dt)

    local axisX_l = Input.get_axis_position(Input.axiscode.LeftX)
    local axisY_l = Input.get_axis_position(Input.axiscode.LeftY)

    local axisX_r = Input.get_axis_position(Input.axiscode.RightX)
    local axisY_r = Input.get_axis_position(Input.axiscode.RightY)

    local rightTrigger = Input.get_axis_position(Input.axiscode.RightTrigger)


    -- Angulo de la camara en radianes (45 grados)
    local cameraAngle = math.rad(45)

    -- Rotar los ejes de entrada para alinearlos con la camara
    local moveDirectionX = axisX_l * math.cos(cameraAngle) - axisY_l * math.sin(cameraAngle)
    local moveDirectionY = axisX_l * math.sin(cameraAngle) + axisY_l * math.cos(cameraAngle)

    local rotationDirectionX = axisX_r * math.cos(cameraAngle) - axisY_r * math.sin(cameraAngle)
    local rotationDirectionY = axisX_r * math.sin(cameraAngle) + axisY_r * math.cos(cameraAngle)

    local moveDirection = Vector3.new(moveDirectionX, 0, moveDirectionY)


    if moveDirectionX ~= 0 or moveDirectionY ~= 0 then
        isMoving = true
        -- Animacian walk

        if actualweapon == 0 then
            if currentAnim ~= 7 then
                currentAnim = 7
                animator:set_current_animation(currentAnim)
            end
        else
            if currentAnim ~= 8 then
                currentAnim = 8
                animator:set_current_animation(currentAnim)
            end
        end
        
    
        -- Aceleraci�n progresiva hasta alcanzar moveSpeed
        currentSpeed = math.min(currentSpeed + acceleration * dt, moveSpeed)
    
        -- Calcular la nueva velocidad
        local velocity = Vector3.new(moveDirection.x * currentSpeed, 0, moveDirection.z * currentSpeed)
    
        -- Aplicar velocidad al Rigidbody
        playerRb:set_velocity(velocity)
    
        -- Rotar el jugador en la direcci�n del movimiento solo si no est� usando el joystick derecho
        if axisX_r == 0 and axisY_r == 0 then
            angleRotation = math.atan(moveDirection.x, moveDirection.z)
            playerTransf.rotation.y = math.deg(angleRotation) 
        end
    
    else
        isMoving = false
        -- Si no hay movimiento, desacelerar suavemente
        if currentSpeed > 0 then
            currentSpeed = math.max(currentSpeed - deceleration * dt, 0) -- Reducir velocidad gradualmente
            local velocity = Vector3.new(moveDirection.x * currentSpeed, 0, moveDirection.z * currentSpeed)
            playerRb:set_velocity(velocity)
        else
            -- Cuando la velocidad llegue a 0, detener al jugador completamente
            playerRb:set_velocity(Vector3.new(0, 0, 0))
        end
    
        if rightTrigger == 0 then
            -- Animaci�n idle
            if actualweapon == 0 then
                if currentAnim ~= 4 then
                    currentAnim = 4
                    animator:set_current_animation(currentAnim)
                end
            else
                if currentAnim ~= 5 then
                    currentAnim = 5
                    animator:set_current_animation(currentAnim)
                end
            end


        end
    end

    if ammo >= maxAmmo then
        if reloadTime == 0 then
            rifleAudioManagerScript:playReload()
        end
        reloadTime = reloadTime + dt
        if reloadTime >= maxReloadTime then
            ammo = 0
            reloadTime = 0
        end
    end

    if Input.is_key_pressed(Input.keycode.Z) then

        rightTrigger = 1
    end


    

    if rightTrigger >= 0.8 and rightTrigger <= 1 and disparable and ammo < maxAmmo then
        
        if contadorDisparo > timeBetweenShoots and shootsCounter < 3 then
            if shootsCounter == 0 then
                if actualweapon == 0 then
                    animator:set_current_animation(0)
                    rifleAudioManagerScript:playShoot()
                else
                    animator:set_current_animation(1)
                    escopetaAudioManagerScript:playShoot();
                end
                
            end
            shoot(dt)
            shootParticlesComponent:emit(6)
            contadorDisparo = 0
            shootsCounter = shootsCounter + 1
            ammo = ammo + 1
        end
        
      
        if shootsCounter >= 3 then
            contadorDisparo2 = contadorDisparo2 + dt
        end

        
        if contadorDisparo2 > timeBetweenBursts then
            shootsCounter = 0
            contadorDisparo2 = 0
        end

  
        if currentAnim ~= 0 then
            --animator:set_current_animation(0)
            currentAnim = 0
        end
    else

        contadorDisparo2 = 0
        shootsCounter = 0
    end

    if rightTrigger == 0 then
        disparable = true
    elseif rightTrigger > 0 and rightTrigger < 0.8 then
        disparable = false
    else
        disparable = true
    end

    contadorDisparo = contadorDisparo + dt





    --Rotacion
    if (rotationDirectionX ~= 0 or rotationDirectionY ~= 0) then
        local lookLength = rotationDirectionX*rotationDirectionX + rotationDirectionY*rotationDirectionY
        if(lookLength > 0) then
            angleRotation = math.atan(rotationDirectionX, rotationDirectionY)
            playerTransf.rotation.y = angleRotation * 57.2958
        end
    end

    --assegurar problemas de rotacion
    if rotationDirectionX ~= 0 or rotationDirectionY ~= 0 then
        -- Rotar con el joystick derecho
        lastValidRotation = math.atan(rotationDirectionX, rotationDirectionY)
        playerTransf.rotation.y = math.deg(lastValidRotation)  
        isAiming = true
    elseif moveDirectionX ~= 0 or moveDirectionY ~= 0 then
        -- Actualizar la ultima rotacion valida
        lastValidRotation = math.atan(moveDirection.x, moveDirection.z)
        playerTransf.rotation.y = math.deg(lastValidRotation)
    else
        -- Si no hay entrada, mantener la ultima rotacion
        playerTransf.rotation.y = math.deg(lastValidRotation)
        isAiming = false
    end

    --[[if(isMoving and isAiming) then   
        local moveAngle = math.atan(moveDirection.x, moveDirection.z)
        local angleDifference = math.deg(math.abs(moveAngle - lastValidRotation))
        
        if angleDifference <= 90 then
            -- Permitir girar dentro de 180 en total (90 a cada lado)
            lastValidRotation = moveAngle
            playerTransf.rotation.y = math.deg(lastValidRotation)
        end
    end]]



    if Input.is_key_pressed(Input.keycode.A) then
        playerTransf.position.x = playerTransf.position.x + 5 * dt;
        
    end
    if Input.is_key_pressed(Input.keycode.D) then
        playerTransf.position.x = playerTransf.position.x - 5 * dt;
    end
    if Input.is_key_pressed(Input.keycode.W) then
        playerTransf.position.z = playerTransf.position.z + 5 * dt;
    end
    if Input.is_key_pressed(Input.keycode.S) then
        playerTransf.position.z = playerTransf.position.z - 5 * dt;
    end

end


function handleGranade(dt)
    if timerGranade > 0 then
        timerGranade = timerGranade - dt
    end

    if Input.is_button_pressed(Input.controllercode.South) and timerGranade <= 0 then
        throwGranade()
        escopetaAudioManagerScript:playLaunchGranade()
        timerGranade = granadeCooldown
    end
end

function throwGranade()
    if granadeEntity ~= nil then
        local rb = granadeEntity:get_component("RigidbodyComponent").rb
        
        local direction = Vector3.new(math.sin(math.rad(playerTransf.rotation.y)), 0.5, math.cos(math.rad(playerTransf.rotation.y)))
        
        local vectorPosition = Vector3.new(playerTransf.position.x + math.sin(math.rad(playerTransf.rotation.y)), playerTransf.position.y+2, playerTransf.position.z + math.cos(math.rad(playerTransf.rotation.y)))
        rb:set_position(vectorPosition)

       
        
        
        local velocity = Vector3.new(direction.x * granadeInitialSpeed, direction.y * granadeInitialSpeed, direction.z * granadeInitialSpeed)
        rb:set_velocity(velocity)
        throwingGranade = true
    end
end

function explodeGranade()
    if granadeEntity ~= nil then
        local rb = granadeEntity:get_component("RigidbodyComponent").rb
        local explosionPos = rb:get_position()

        local entities = current_scene:get_all_entities()

        for _, entity in ipairs(entities) do 
            if entity ~= granadeEntity and entity:has_component("RigidbodyComponent") then 
                local entityRb = entity:get_component("RigidbodyComponent").rb
                local entityPos = entityRb:get_position()

                local direction = Vector3.new(
                    entityPos.x - explosionPos.x,
                    entityPos.y - explosionPos.y,
                    entityPos.z - explosionPos.z
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

                if distance < explosionRadius then
                    local forceFactor = (explosionRadius - distance) / explosionRadius
                    direction.y = direction.y + explosionUpward
                    local finalForce = Vector3.new(
                        direction.x * explosionForce * forceFactor,
                        direction.y * explosionForce * forceFactor,
                        direction.z * explosionForce * forceFactor
                    )
                    entityRb:apply_impulse(finalForce)

                    local rotationFactor = explosionForce * forceFactor 
                    local randomRotation = Vector3.new(
                        (math.random() - 0.5) * rotationFactor,
                        (math.random() - 0.5) * rotationFactor,
                        (math.random() - 0.5) * rotationFactor
                    )

                    entityRb:set_angular_velocity(randomRotation)
                end
            end
        end
        
        rb:set_velocity(Vector3.new(0, 0, 0))
        rb:set_angular_velocity(Vector3.new(0, 0, 0))
        escopetaAudioManagerScript:playExplodeGranade();
        throwingGranade = false
    end
end

