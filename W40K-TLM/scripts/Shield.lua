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
    if shieldTransform then
        local currentPos = shieldTransform.position
        shieldTransform.position = Vector3.new(5000, currentPos.y, currentPos.z)
    end
end

function on_exit() end