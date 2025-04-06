--local enemy = require("scripts/utils/enemy")

--local range_enemy = enemy:new()
-- range_enemy.health = 5
-- range_enemy.attack_range = 15

-- enemy.player = nil
-- enemy.playerTransf = nil

-- enemy.animator = nil
-- enemy.enemyTransf = nil
-- enemy.enemyNavmesh = nil

-- local distance = 0

function on_ready() 
    print("On ready Range")
    -- enemy.player = current_scene:get_entity_by_name("Player")
    -- enemy.playerTransf = enemy.player:get_component("TransformComponent")

    -- enemy.animator = self:get_component("AnimatorComponent")
    -- enemy.enemyTransf = self:get_component("TransformComponent")
    -- enemy.enemyNavmesh = self:get_component("NavigationAgentComponent")

    -- enemy.update_path(enemy.playerTransf)

    --distance = enemy.get_distance(enemy.enemyTransf, enemy.playerTransf)

    local kamikazeEntity = current_scene:get_entity_by_name("EnemyKamikaze")
    local kamikazeScript = kamikazeEntity:get_component("ScriptComponent")

    local kamikazeEnemy = kamikazeScript.enemy_instance

    if kamikazeEnemy then
        print("Kamikaze health: " .. kamikazeEnemy.health)
    else
        print("No se puede acceder a kamikazeEnemy")
    end
end

function on_update(dt) 
    --enemy.detect_area()
    --enemy.update_path()
    --range_enemy.get_distance(enemyTransf, playerTransf)
    --range_enemy.attack_state()
    --log("Player position z: " .. range_enemy.playerTransf.position.z)
    --enemy.idle_state()
end

--function range_enemy.attack_state() end

function on_exit() end
