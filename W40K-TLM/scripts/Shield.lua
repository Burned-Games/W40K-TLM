local shieldTransform = nil
targetEnemy = nil
isActive = false

function on_ready()
    shieldTransform = self:get_component("TransformComponent")
end

function on_update(dt)
    if not isActive then
        local scriptComponent = self:get_component("ScriptComponent")
        if scriptComponent and scriptComponent.targetEnemy then
            targetEnemy = scriptComponent.targetEnemy
            isActive = true
            
            -- Update the target enemy's shield status when shield is activated
            if targetEnemy and targetEnemy.script then
                targetEnemy.script.haveShield = true
            end
        else
            return
        end
    end
    
    if not targetEnemy or not targetEnemy.script then
        shieldDestroy()
        return
    end

    shieldTransform.position = Vector3.new(targetEnemy.transform.position.x, targetEnemy.transform.position.y + 0.75, targetEnemy.transform.position.z)

    if targetEnemy.script.shieldHealth <= 0 then
        shieldDestroy()
    end
end

function shieldDestroy()
    if shieldTransform then
        local currentPos = shieldTransform.position
        shieldTransform.position = Vector3.new(5000, currentPos.y, currentPos.z)
        
        -- Update the target enemy's shield status when shield is destroyed
        if targetEnemy and targetEnemy.script then
            targetEnemy.script.haveShield = false
        end
        
        isActive = false
        targetEnemy = nil
    end
end

function on_exit() end