local shieldTransform = nil
targetEnemy = nil
isActive = false

local spriteComponent = nil
local actualAlpha = 0


local alertShowSpeed = 1.5
local alertShowDirection = 0 -- 0 -> Fodein | 1 -> FadeOut

local sistemaParticulas = nil

function on_ready()
    shieldTransform = self:get_component("TransformComponent")
    spriteComponent = self:get_component("SpriteComponent")
    sistemaParticulas = self:get_component("ParticlesSystemComponent")
    --spriteComponent.tint_color = Vector4.new(33/255,97/255,230/255,0)
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

    if spriteComponent then
        changeAlpha(dt)
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
    sistemaParticulas:emit(20)
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

function changeAlpha(dt)
    
    if alertShowDirection == 0 then
        actualAlpha = actualAlpha + (dt * alertShowSpeed)
        if actualAlpha < 1 then
            spriteComponent.tint_color = Vector4.new(33/255,97/255,230/255,actualAlpha) 
        else
            spriteComponent.tint_color = Vector4.new(33/255,97/255,230/255,1)
            alertShowDirection = 1
        end
    end
end

function on_exit() end