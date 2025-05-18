local alertTimer = 0
local alertTransf = nil
local alertSprite = nil
local actualAlpha = 0


local alertShowSpeed = 1.5
local alertShowDirection = 0 -- 0 -> Fodein | 1 -> FadeOut

enemyTransf = nil
alertDistance = 2

function on_ready()
    alertTransf = self:get_component("TransformComponent")
    alertSprite = self:get_component("SpriteComponent")
end

function on_update(dt)
    if enemyTransf then
        alertTransf.position = Vector3.new(enemyTransf.position.x, enemyTransf.position.y + alertDistance, enemyTransf.position.z)
    end
    
    if alertSprite then
        changeAlpha(dt)
    end
    

    alertTimer = alertTimer + dt
    if alertTimer >= 2.5 then
        current_scene:destroy_entity(self)
    end
end

function changeAlpha(dt)
    if alertShowDirection == 0 then
        actualAlpha = actualAlpha + (dt * alertShowSpeed)
        if actualAlpha < 1 then
            alertSprite.tint_color = Vector4.new(1,1,1,actualAlpha) 
        else
            alertSprite.tint_color = Vector4.new(1,1,1,1)
            alertShowDirection = 1
        end
    else
        actualAlpha = actualAlpha - (dt * alertShowSpeed)
        if actualAlpha > 0 then
            alertSprite.tint_color = Vector4.new(1,1,1,actualAlpha) 
        else
            alertSprite.tint_color = Vector4.new(1,1,1,0)
            alertShowDirection = 1
        end
    end
end

function on_exit()
    -- Add cleanup code here
end