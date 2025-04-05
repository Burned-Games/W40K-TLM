local enemy = require("scripts/utils/enemy")

local range_enemy = enemy:new()

function on_ready() 

    range_enemy.player = current_scene:get_entity_by_name("Player")
    range_enemy.playerTransf = range_enemy.player:get_component("TransformComponent")
    range_enemy.animator = self:get_component("AnimatorComponent")
    range_enemy.enemyTransf = self:get_component("TransformComponent")
    range_enemy.enemyRb = self:get_component("RigidbodyComponent").rb
    range_enemy.enemyNavmesh = self:get_component("NavigationAgentComponent")

    range_enemy:update_path(range_enemy.playerTransf)

    --distance = enemy.get_distance(enemy.enemyTransf, enemy.playerTransf)
end

function on_update(dt) 
    --range_enemy:enemy_raycast()
    --range_enemy:idle_state()

    --range_enemy:follow_path()
end

--function range_enemy.attack_state() end

function on_exit() end