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
    print("Shield destroyed")
    current_scene:destroy_entity(self)
end

function on_exit() end