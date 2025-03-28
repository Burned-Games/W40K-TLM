
local children = nil
local should_apply_physics = true


function on_ready()
    children = self:get_children() 
    local p = self:get_component("RigidbodyComponent")



    local sphere1 = current_scene:get_entity_by_name("")

    print("voy a hacer lo de la colision")

    p:on_collision_enter(function(entityA, entityB)               
        local nameA = entityA:get_component("TagComponent").tag
        local nameB = entityB:get_component("TagComponent").tag
        print("dunciono")

        if nameA == "Sphere1" or nameB == "Sphere1" then
            give_phisycs()
        end
        
    end)
    
end

function on_update(dt)

    --[[
    if Input.is_key_pressed(Input.keycode.D) and should_apply_physics == true then
        give_phisycs()
        should_apply_physics = false
    end
    ]]
end

function on_exit()
    -- Add cleanup code here
end

function give_phisycs()
    for _, barril in ipairs(children) do
        print("no se si tiene rigid body")
        if barril:has_component("RigidbodyComponent") then
            print("tiene rigid body")

            local rb = barril:get_component("RigidbodyComponent").rb

            print("se lo configuro")
            


            rb:set_body_type(1)
            
            rb:set_use_gravity(true)
            rb:set_mass(1.0) 
            rb:set_trigger(false) 
            rb:set_freeze_x(false)
            rb:set_freeze_y(false)
            rb:set_freeze_z(false)

            rb:set_freeze_rot_x(false)
            rb:set_freeze_rot_y(false)
            rb:set_freeze_rot_z(false)

            print("configurado")

        end
        print("Explota")
        
        
    end
end
--Deberia activarse cuando algo lo toca
function on_collision_enter(other)
    should_apply_physics = true
end
--[[
local barril = nil
local playerTransf
local playerWorldTransf
local forwardVector
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
function on_ready()
    
barril = current_scene:get_entity_by_name("TestBarrilRoto.gltf")

if not barril:has_component("RigidbodyComponent") then
    print("paso por aqui")
    barril:add_component("RigidbodyComponent")
end

local rb = barril:get_component("RigidbodyComponent").rb
    rb:set_use_gravity(true)
    rb:set_mass(1.0) 
    rb:set_trigger(false)  
    
    playerTransf = self:get_component("TransformComponent")
    playerWorldTransf = playerTransf:get_world_transform();
    forwardVector = Vector3.new(1,0,0)

    granadeEntity = current_scene:get_entity_by_name("Barril Roto")
    transformGranade = granadeEntity:get_component("TransformComponent")

    floorEntity = current_scene:get_entity_by_name("FloorCollider")

    if not granadeEntity:has_component("RigidbodyComponent") then
        granadeEntity:add_component("RigidbodyComponent")
    end

    local rb = granadeEntity:get_component("RigidbodyComponent").rb
    rb:set_use_gravity(true)
    rb:set_mass(1.0) 
    rb:set_trigger(false)  


    local rbComponent = granadeEntity:get_component("RigidbodyComponent")
    rbComponent:on_collision_enter(function(entityA, entityB)

        local nameA = entityA:get_component("TagComponent").tag
        local nameB = entityB:get_component("TagComponent").tag

        if nameA == "Floor" or nameB == "Floor" then
            explodeGranade()
        end
    end)

end

function on_update(dt)

end

function on_exit()

end

]]