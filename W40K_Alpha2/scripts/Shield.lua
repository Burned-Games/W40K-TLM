shieldHealth = 35
local shieldTransform = nil
local targetEnemy = nil
local isActive = false

function on_ready()
    shieldTransform = self:get_component("TransformComponent")

end

function on_update(dt)
    
    if not isActive then
        local scriptComponent = self:get_component("ScriptComponent")
        if scriptComponent and scriptComponent.targetEnemy then
            targetEnemy = scriptComponent.targetEnemy
            isActive = true
        else
            return  -- Seguir esperando
        end
    end
    -- Verificar validez del target
    if not targetEnemy or not targetEnemy.transform then
        shieldDestroy()
        return
    end

    -- Actualizar posición
    shieldTransform.position = targetEnemy.transform.position

    -- Destruir si no tiene salud
    if shieldHealth <= 0 then
        shieldDestroy()
    end
end

function shieldDestroy()

end

function on_exit() end