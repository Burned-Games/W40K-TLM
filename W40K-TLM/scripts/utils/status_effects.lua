local effect = {}
--bleeding
local bleedDamage = 4
local bleedTimer = 0.0
local bleedDuration = 6.0
local timeSinceLastBleed = 0.0
local bleedInterval = 1.0
--burning
local burnDamage = 4
local burnTimer = 0.0
local burnDuration = 6.0
local timeSinceLastBurn = 0.0
local burnInterval = 1.0
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

function effect:apply_burn(entityScript)
    entityScript.isBurning = true
    burnTimer = burnDuration
    timeSinceLastBurn = 0
end

function effect:bleed(entityScript, health, dt)
    return self:handle_periodic_damage(entityScript, health, dt, "bleed")
end

function effect:burn(entityScript, health, dt)
    return self:handle_periodic_damage(entityScript, health, dt, "burn")
end


function effect:handle_periodic_damage(entityScript, health, dt, effectType)
    local timer, damage, interval, duration, timeSince
    
    if effectType == "bleed" then
        timer = bleedTimer
        damage = bleedDamage
        interval = bleedInterval
        timeSince = timeSinceLastBleed
        sfx = entityScript.bleedingSFX
    elseif effectType == "burn" then
        timer = burnTimer
        damage = burnDamage
        interval = burnInterval
        timeSince = timeSinceLastBurn
        sfx = entityScript.bleedingSFX -- Cambiar a la SFX de quemadura cuando se tenga audio
    else
        return health
    end
    
    timer = timer - dt
    timeSince = timeSince + dt
    
    if timeSince >= interval then
        if health > 0 then
            health = health - damage
            sfx:play()
        end
        timeSince = 0
    end

    if effectType == "bleed" then
        bleedTimer = timer
        timeSinceLastBleed = timeSince
        if timer <= 0 then
            entityScript.isBleeding = false
        end
    elseif effectType == "burn" then
        burnTimer = timer
        timeSinceLastBurn = timeSince
        if timer <= 0 then
            entityScript.isBurning = false
        end
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