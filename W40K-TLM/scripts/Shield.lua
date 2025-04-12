local shieldTransform = nil
targetEnemy = nil
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
            return
        end
    end
    
    if not targetEnemy or not targetEnemy.script then
        shieldDestroy()
        return
    end

    shieldTransform.position = targetEnemy.transform.position

    if targetEnemy.script.shieldHealth <= 0 then
        shieldDestroy()
    end
end

function shieldDestroy()
    if targetEnemy and targetEnemy.script then
        targetEnemy.script.haveShield = false
        targetEnemy.script.shieldHealth = 0
    end
    set_position(Vector3.new(-500, 0, 0))
end

function on_exit() end