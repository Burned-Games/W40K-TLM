local alertTimer = 0
local alertTransf = nil
enemyTransf = nil
alertDistance = 2

function on_ready()
    alertTransf = self:get_component("TransformComponent")
end

function on_update(dt)
    alertTransf.position = Vector3.new(enemyTransf.position.x, enemyTransf.position.y + alertDistance, enemyTransf.position.z)

    alertTimer = alertTimer + dt
    if alertTimer >= 5 then
        current_scene:destroy_entity(self)
    end
end

function on_exit()
    -- Add cleanup code here
end