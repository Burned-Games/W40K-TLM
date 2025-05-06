local effect = {}
--bleeding
local bleedDamage = 4
local bleedTimer = 0.0
local bleedDuration = 6.0
local timeSinceLastBleed = 0.0
local bleedInterval = 1.0
--Neural Inhibition
local movementSpeedMultiplier = 0.5
local attackSpeedMultiplier = 0.7
local neuralTimer = 0.0
local neuralDuration = 6.0
--Stun
local stunTimer = 0.0
local stunDuration = 1.5





function effect:apply_bleed(entityScript)

    entityScript.isBleeding = true
    bleedTimer = bleedDuration
    timeSinceLastBleed = 0

end

function effect:bleed(entityScript,health, dt)

    bleedTimer = bleedTimer - dt
    timeSinceLastBleed = timeSinceLastBleed + dt

    if timeSinceLastBleed >= bleedInterval then
        if health > 0 then
            health = health - bleedDamage
        end
        timeSinceLastBleed = 0
    end
    
    if bleedTimer <= 0 then
        entityScript.isBleeding = false
    end

    return health
end

function effect:neural(dt)

    neuralTimer = neuralTimer - dt
    if neuralTimer <= 0 then
        return false
    end
    return true
end

function effect:ApplyNeuralChanges(speed, attackSpeed)
    
    local newSpeed = speed * movementSpeedMultiplier
    local newattackSpeed = 0
    if attackSpeed then
        newattackSpeed = attackSpeed * attackSpeedMultiplier
    end
    neuralTimer = neuralDuration
    return Vector2.new(newSpeed, newattackSpeed)
end

function effect:ApplyStun()
    self.isStunned = true
    stunTimer = stunDuration
end

function effect:ManageStun(dt)
    stunTimer = stunTimer - dt
    if stunTimer <= 0 then
        return false
    end
    return true
end

return effect