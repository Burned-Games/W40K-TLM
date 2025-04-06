local barricadeHealth = 100
isPlayerInRange = false
local rbBarricade = nil

function on_ready()
    rbBarricade = self:get_component("RigidbodyComponent").rb
    rbBarricade:set_trigger(true)

    self:get_component("RigidbodyComponent"):on_collision_enter(function(entityA, entityB)
        local nameA = entityA:get_component("TagComponent").tag
        local nameB = entityB:get_component("TagComponent").tag

        if nameA == "Player" or nameB == "Player" then
            isPlayerInRange = true
            print("Player is in range of the barricade")
        end

        if nameA == "EnemyBullet" or nameB == "EnemyBullet" then
            barricadeHealth = barricadeHealth - 10 
            print("Barricade hit!")
            print(barricadeHealth)
            
        end
    end)

    self:get_component("RigidbodyComponent"):on_collision_exit(function(entityA, entityB)
        local nameA = entityA:get_component("TagComponent").tag
        local nameB = entityB:get_component("TagComponent").tag

        if nameA == "Player" or nameB == "Player" then
            isPlayerInRange = false
            print("Player is out of range of the barricade")
        end
    end)

end

function on_update(dt)
    if barricadeHealth <= 0 then
        print("Barricade destroyed!")
        self:set_active(false)
    end
end

function on_exit()
    -- Add cleanup code here
end
