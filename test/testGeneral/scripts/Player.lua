local sphere = nil

local playerTransf
local playerWorldTransf
local forwardVector
local transformSphere
local disparado = false

local currentAnim = 0;
local animator;


local contadorDisparo = 0
local angleRotation = 0;


local audioSource;
local setMuted = false;
local timerShootSound = 2
local contadorShootSound = 0
local playShoot = false;

function on_ready()
    -- Add initialization code here

    playerTransf = self:get_component("TransformComponent")
    playerWorldTransf = playerTransf:get_world_transform();
    forwardVector = Vector3.new(1,0,0)
    disparado = false

    sphere = current_scene:get_entity_by_name("Sphere")
    transformSphere = sphere:get_component("TransformComponent");


    animator = self:get_component("AnimatorComponent")
    audioSource  = self:get_component("AudioSourceComponent")

end

function on_update(dt)
    -- Add update code here

    contadorDisparo = contadorDisparo + dt;

    playerMovement(dt)

    if(playShoot) then
        contadorShootSound = contadorShootSound + dt
        if(contadorShootSound > timerShootSound) then
            audioSource:set_muted(true);
            contadorShootSound = 0
            playShoot = false
        end
    end
    

    -- Manage the bullet after the shot 
    if disparado then
        transformSphere = sphere:get_component("TransformComponent");
        transformSphere.position = Vector3.new((forwardVector.x * dt * 50) + transformSphere.position.x, transformSphere.position.y, (forwardVector.z * dt * 50) + transformSphere.position.z)
    end

end

function on_exit()
    -- Add cleanup code here
end



function shoot(dt)
    if sphere ~= nil then
            
        transformSphere = sphere:get_component("TransformComponent");
        disparado = true
    end
    local playerPosition  = playerTransf.position;
    local playerRotation = playerTransf.rotation;

    --setMuted = not setMuted
    --audioSource:set_muted(setMuted);
    audioSource:set_muted(false);
    playShoot = true

    local a = playerRotation.y
    forwardVector = Vector3.new(math.sin(a), 0, math.cos(a))

    -- angleRotation * 57.2958

    forwardVector = Vector3.new(math.sin(angleRotation), 0, math.cos(angleRotation))
    
    local newPosition = Vector3.new((forwardVector.x+ playerPosition.x) , (forwardVector.y+ playerPosition.y)  , (forwardVector.z+ playerPosition.z) )
    transformSphere.position = newPosition;
end


function playerMovement(dt)

    local axisX_l = Input.get_axis_position(Input.axiscode.LeftX)
    local axisY_l = Input.get_axis_position(Input.axiscode.LeftY)

    local axisX_r = Input.get_axis_position(Input.axiscode.RightX)
    local axisY_r = Input.get_axis_position(Input.axiscode.RightY)

    local rightTrigger = Input.get_axis_position(Input.axiscode.RightTrigger)


    -- Ángulo de la cámara en radianes (45 grados)
    local cameraAngle = math.rad(45)

    -- Rotar los ejes de entrada para alinearlos con la cámara
    local moveDirectionX = axisX_l * math.cos(cameraAngle) - axisY_l * math.sin(cameraAngle)
    local moveDirectionY = axisX_l * math.sin(cameraAngle) + axisY_l * math.cos(cameraAngle)

    local rotationDirectionX = axisX_r * math.cos(cameraAngle) - axisY_r * math.sin(cameraAngle)
    local rotationDirectionY = axisX_r * math.sin(cameraAngle) + axisY_r * math.cos(cameraAngle)


    if (axisX_l ~= 0 or axisY_l ~= 0) then

        -- Animacion walk
        if currentAnim ~= 2 then
            animator:set_current_animation(2)
            currentAnim = 2
        end


        --Transform
        playerTransf.position.x = playerTransf.position.x + moveDirectionX*5 * dt;
        playerTransf.position.z = playerTransf.position.z + moveDirectionY*5 * dt;

       
        

    else

        if(rightTrigger == 0) then
             -- Animacion idle
            if currentAnim ~= 1 then
                animator:set_current_animation(1)
                currentAnim = 1
            end
        end
       
    end


    if rightTrigger ~= 0 then
        
        if contadorDisparo > 0.2 then
            shoot(dt)
            contadorDisparo = 0
        end
        -- Animacion attack
        if currentAnim ~= 0 then
            animator:set_current_animation(0)
            currentAnim = 0
        end
    else
        audioSource:set_muted(true);
    end




    -- Rotacion
    if (rotationDirectionX ~= 0 or rotationDirectionY ~= 0) then
        local lookLength = rotationDirectionX*rotationDirectionX + rotationDirectionY*rotationDirectionY
        if(lookLength > 0) then
            angleRotation = math.atan(rotationDirectionX, rotationDirectionY)
            playerTransf.rotation.y = angleRotation * 57.2958
        end
    end







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
