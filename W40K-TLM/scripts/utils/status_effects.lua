local effect = {}
--bleeding
local bleedDamage = 4
local bleedTimer = 0.0
local bleedDuration = 6.0
local timeSinceLastBleed = 0.0
local bleedInterval = 1.0
--Neural Inhibition
local movementSpeedMultiplier = 0.5
local speedMultiplier = 0.3
local neuralTimer = 0.0
local neuralDuration = 6.0





function effect:apply_bleed(entityScript)

    entityScript.isBleeding = true
    bleedTimer = bleedDuration
    timeSinceLastBleed = 0

end

function effect:apply_neural_inhibition(entityScript)

    entityScript.isNeuralInhibitioning = true
    neuralTimer = neuralDuration

end

function effect:bleed(health, dt)

    bleedTimer = bleedTimer - dt
    timeSinceLastBleed = timeSinceLastBleed + dt

    if timeSinceLastBleed >= bleedInterval then
        if health > 0 then
            health = health - bleedDamage
        end
        timeSinceLastBleed = 0
    end

    if bleedTimer <= 0 then
        self.isBleeding = false
    end

    return health
end

function effect:neural(speed, attackSpeed)

    neuralTimer = neuralTimer - dt
    
    local newSpeed = speed * speedMultiplier
    local newattackSpeed = attackSpeed * speedMultiplier

    if neuralTimer <= 0 then
        self.isNeuralInhibitioning = false
    end

    return newSpeed, newattackSpeed
end

return effect