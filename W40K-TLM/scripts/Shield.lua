-- Shield Script Corregido
local shieldTransform = nil
targetEnemy = nil
isActive = false

local spriteComponent = nil
local actualAlpha = 0

local alertShowSpeed = 1.5
local alertShowDirection = 0 

local sistemaParticulas = nil

function on_ready()
    shieldTransform = self:get_component("TransformComponent")

    -- Solo inicializar si no está ya activo
    if not isActive then
        actualAlpha = 0
        alertShowDirection = 0
    end

end

function on_update(dt)
    -- Verificar si necesita activarse
    if not isActive then
        local scriptComponent = self:get_component("ScriptComponent")
        if scriptComponent and scriptComponent.targetEnemy then
            targetEnemy = scriptComponent.targetEnemy
            isActive = true
            actualAlpha = 0 -- Reset alpha para la animación
            alertShowDirection = 0

            if targetEnemy and targetEnemy.script then
                targetEnemy.script.haveShield = true
            end
        end
    end

    if not isActive then
        return
    end

    if spriteComponent then
        changeAlpha(dt)
    end

    if not targetEnemy or not targetEnemy.script then
        log("Target enemy lost, destroying shield")
        shieldDestroy()
        return
    end


    if targetEnemy.script.shieldHealth and targetEnemy.script.shieldHealth <= 0 then
        shieldDestroy()
    end
    
end

function shieldDestroy()
    
    if targetEnemy and targetEnemy.script then
        targetEnemy.script.haveShield = false
    end
    
    isActive = false
    targetEnemy = nil
    actualAlpha = 0
    alertShowDirection = 0
    
    self:set_active(false)

end

function changeAlpha(dt)
    if alertShowDirection == 0 then
        actualAlpha = actualAlpha + (dt * alertShowSpeed)
        if actualAlpha < 1 then
            spriteComponent.tint_color = Vector4.new(33/255, 97/255, 230/255, actualAlpha) 
        else
            spriteComponent.tint_color = Vector4.new(33/255, 97/255, 230/255, 1)
            alertShowDirection = 1
        end
    end
end

function on_exit() 
    -- Limpiar al salir
    if targetEnemy and targetEnemy.script then
        targetEnemy.script.haveShield = false
    end
    isActive = false
    targetEnemy = nil
end