explosionPool = {}
explosionTimers = {}
explosionLifetime = 0.5

function on_ready()
    local explosionPoolChildren = self:get_children()
    local i = 1
    for _, child in ipairs(explosionPoolChildren) do
        local explosion = {
            entity = child,
            transform = child:get_component("TransformComponent"),
            active = false
        }

        explosion.transform.position = Vector3.new(-1000, 0, -1000)

        explosionPool[i] = explosion
        explosionTimers[i] = 0
        
        i = i + 1
    end
end

function on_update(dt)
    for i, explosion in ipairs(explosionPool) do
        if explosion.active then
            explosionTimers[i] = explosionTimers[i] + dt
            if explosionTimers[i] >= explosionLifetime then
                deactivate(i)
            end
        end
    end
end

function get_free_explosion(position)
    for i, explosion in ipairs(explosionPool) do
        if not explosion.active then
            explosion.active = true
            explosionTimers[i] = 0
            explosion.transform.position = Vector3.new(position.x, position.y + 0.1, position.z)

            return explosion, i
        end
    end

    return nil
end

function deactivate(index)
    local explosion = explosionPool[index]
    explosion.active = false
    explosion.transform.position = Vector3.new(-1000, 0, -1000)
    explosionTimers[index] = 0
end

function on_exit() end
