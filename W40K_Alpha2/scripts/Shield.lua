shieldHealth = 35
local shield = nil
local shieldTransform = nil

enemies = {}
enemyTransform = nil


function on_ready()
    -- Add initialization code here
    shield = self:getEntity("shield")
    shieldTransform = shield:get_component("TransformComponent")

end


function on_update(dt)
    -- Add update code here

    if shieldHealth <= 0 then
        shieldDestroy()
    end
end

function shieldDestroy()

    
end
function on_exit()
    -- Add cleanup code here
end
