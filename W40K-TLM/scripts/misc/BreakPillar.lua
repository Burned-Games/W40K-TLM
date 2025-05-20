
local childrenRBCDown = {}
local childrenRBCUp = {}
local childrenTransformDown = {}
local childrenTransformUp = {}

local tag = nil
local rigidbodyComponent = nil

local actualSize = 1
local sizeDisappearSpeed = 3
local hasDestroyed = false
local disappearCounterTarget = 5
local disappearCounter = 0
local hasDisappeared = false
local impulseStrength = 1

function on_ready()
    -- Add initialization code here
    tag = self:get_component("TagComponent").tag
    rigidbodyComponent = self:get_component("RigidbodyComponent")
    local children = self:get_children() 
    for _, pillarVers in ipairs(children) do 
        if pillarVers:get_component("TagComponent").tag == "Columna_v2.gltf" then
            local transform = pillarVers:get_component("TransformComponent")
            transform.position = Vector3.new(transform.position.x, 0, transform.position.z)
            local childrenPillar = pillarVers:get_children()
            for __, pillarPiece in ipairs(childrenPillar) do 
                local pillarPieceRB = pillarPiece:get_component("RigidbodyComponent")
                local pillarPieceTrans = pillarPiece:get_component("TransformComponent")
                pillarPieceRB.rb:set_position(Vector3.new(pillarPieceTrans.position.x, pillarPieceTrans.position.y+4, pillarPieceTrans.position.z))
                pillarPieceRB.rb:set_trigger(true)
                pillarPieceRB.rb:set_body_type(0)
                table.insert(childrenRBCUp, pillarPieceRB)
                table.insert(childrenTransformUp, pillarPieceTrans)
            end
        end
        if pillarVers:get_component("TagComponent").tag == "Columnas.gltf" then
            local childrenPillar = pillarVers:get_children()
            for __, pillarPiece in ipairs(childrenPillar) do 
                local pillarPieceRB = pillarPiece:get_component("RigidbodyComponent")
                local pillarPieceTrans = pillarPiece:get_component("TransformComponent")
                pillarPieceRB.rb:set_trigger(true)
                pillarPieceRB.rb:set_body_type(0)
                table.insert(childrenRBCDown, pillarPieceRB)
                table.insert(childrenTransformDown, pillarPieceTrans)
            end
        end
    end
end

function give_phisycs()
     hasDestroyed = true
     rigidbodyComponent.rb:set_trigger(true)

     for _, pillarRB in ipairs(childrenRBCUp) do 

            local impulseDir = Vector3.new(0,0,0)
            pillarRB.rb:set_trigger(false)
            pillarRB.rb:set_body_type(1)
            pillarRB.rb:apply_impulse(impulseDir * impulseStrength)
            pillarRB.rb:apply_torque_impulse(impulseDir * impulseStrength)
     end

     for _, pillarRB in ipairs(childrenRBCDown) do 
            local impulseDir = Vector3.new(0,0,0)
            pillarRB.rb:set_trigger(false)
            pillarRB.rb:set_body_type(1)
            pillarRB.rb:apply_impulse(impulseDir * impulseStrength)
            pillarRB.rb:apply_torque_impulse(impulseDir * impulseStrength)
     end
    
end

local function setChildrenSize(size)
    
    for _, child in ipairs(childrenTransformUp) do
        child.scale = Vector3.new(size,size,size)
    end

    for _, child in ipairs(childrenTransformDown) do
        child.scale = Vector3.new(size,size,size)
    end
end

function on_update(dt)
    -- Add update code here
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

    if hasDisappeared then
        self:set_active(false)
    end

end

function on_exit()
    -- Add cleanup code here
end
