local enemy = {}

enemy.health = 95
enemy.speed = 3
enemy.detectionRange = 25
enemy.damage = 5

function enemy.new(obj)
    obj = obj or {}
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function enemy.idle_state()
    -- Your function implementation here
    log("Idle State")
end

function enemy.move_state()
    -- Your function implementation here
    log("Move State")
end

function enemy.chase_state()
    -- Your function implementation here
    log("Chase State")
end

function enemy.attack_state()
    -- Your function implementation here
    log("Attack State")
end

function enemy.die_state()
    log("Enemy dead")
end

function enemy.get_distance(origin, destination)

    local dx = destination.x - origin.x
    local dy = destination.y - origin.y
    local dz = destination.z - origin.z
    return math.sqrt(dx * dx + dy * dy + dz * dz)

end

return enemy
