bulletPool = {}
bulletTimers = {}
maxBullets = 5
bulletLifetime = 2.0

function on_ready()
    local bulletPoolChildren = self:get_children()
    local i = 1
    for _, child in ipairs(bulletPoolChildren) do
        local bullet = {
            entity = child,
            transform = child:get_component("TransformComponent"),
            rbComponent = child:get_component("RigidbodyComponent"),
            active = false
        }

        bullet.rb = bullet.rbComponent.rb
        bullet.rb:set_trigger(true)
        bullet.rb:set_position(Vector3.new(-1000, 0, -1000))

        bulletPool[i] = bullet
        bulletTimers[i] = 0
        
        i = i + 1
    end
end

function on_update(dt)
    for i, bullet in ipairs(bulletPool) do
        if bullet.active then
            bulletTimers[i] = bulletTimers[i] + dt
            if bulletTimers[i] >= bulletLifetime then
                deactivate(i)
            end
        end
    end
end

function get_free_bullet()
    for i, bullet in ipairs(bulletPool) do
        if not bullet.active then
            bullet.active = true
            bulletTimers[i] = 0
            return bullet, i
        end
    end

    return nil
end

function deactivate(index)
    local bullet = bulletPool[index]
    bullet.active = false
    bullet.rb:set_position(Vector3.new(-1000, 0, -1000))
    bullet.rb:set_velocity(Vector3.new(0, 0, 0))
    bulletTimers[index] = 0
end

function on_exit() end