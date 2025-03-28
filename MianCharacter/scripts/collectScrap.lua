local playerScript = nil
local upgradeManager = nil
local scrapRb = nil
local scrapTransform = nil
local scrapValue = 10

function on_ready()
    playerScript = current_scene:get_entity_by_name("Player"):get_component("ScriptComponent")
    upgradeManager = current_scene:get_entity_by_name("UpgradeManager"):get_component("ScriptComponent")

    local scrapComponent = self:get_component("RigidbodyComponent")
    scrapTransform = self:get_component("TransformComponent")
    scrapRb = scrapComponent.rb
    scrapRb:set_trigger(true)

    -- On collision to check if the player is colliding with the scrap
    scrapComponent:on_collision_enter(function(entityA, entityB)
        local player = nil
        local scrap = nil

        if entityA:get_component("TagComponent").tag == "Player" then
            player = entityA
            scrap = entityB
        elseif entityB:get_component("TagComponent").tag == "Player" then
            player = entityB
            scrap = entityA
        end
        
        -- if player is colliding with the scrap, add scrap to the player and move the scrap out of the way
        if player then
            upgradeManager.add_scrap(scrapValue)
            
            scrapTransform.position = Vector3.new(0, -100, 0)
            scrapRb:set_position(scrapTransform.position)
        end
    end)
end

function on_update(dt)
    -- Add update code here
end

function on_exit()
    -- Add cleanup code here
end
