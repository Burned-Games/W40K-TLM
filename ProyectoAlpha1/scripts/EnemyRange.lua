local enemy = require("scripts/utils/enemy")

local range_enemy = enemy:new()
range_enemy.health = 5
range_enemy.attack_range = 15

local enemyTransf = nil
local player = nil
local playerTransf = nil

function on_ready() 
    enemyTransf = self:get_component("TransformComponent")
    player = current_scene:get_entity_by_name("Player")
    playerTransf = player:get_component("TransformComponent")
end

function on_update(dt) 
    range_enemy.get_distance(enemyTransf, playerTransf)
end

function range_enemy.attack_state()

end

function on_exit() end
