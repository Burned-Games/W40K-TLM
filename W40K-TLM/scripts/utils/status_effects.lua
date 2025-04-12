local effect = {}

local bleedDamage = 4
local bleedTimer = 0.0
local bleedDuration = 6.0
local timeSinceLastBleed = 0.0
local bleedInterval = 1.0

function effect:apply_bleed(entityScript)

    entityScript.isBleeding = true
    bleedTimer = bleedDuration
    timeSinceLastBleed = 0

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

return effect