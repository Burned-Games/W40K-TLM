

local objectNormal = nil

local prefabBarril = "prefabs/Misc/BarrilSeparado.prefab"
local prefabCaja = "prefabs/Misc/CajaSeparado.prefab"

local rbComponent = nil

local hasDestroyed = false

local impulseStrength = 0

function on_ready()
    -- Add initialization code here
    local children = self:get_children()
    for _, child in ipairs(children) do
        if child:get_component("TagComponent").tag == "Normal" then
            objectNormal = child
        end
    end

    rbComponent = self:get_component("RigidbodyComponent");

end


function give_phisycs()
    rbComponent.rb:set_trigger(true)
    rbComponent.rb:set_use_gravity(false)

    local separate = nil

    local tag = self:get_component("TagComponent").tag

    if tag == "BarrilDestruible" then
        separate = instantiate_prefab(prefabBarril)
    elseif tag == "CajaDestruible" then
        separate = instantiate_prefab(prefabCaja)
    end

    if separate == nil then return end

    separate:get_component("TransformComponent").position = self:get_component("TransformComponent").position
    separate:get_component("TransformComponent").rotation = self:get_component("TransformComponent").rotation

    local separateChildren = separate:get_children()

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


end

function on_exit()
    -- Add cleanup code here
end
