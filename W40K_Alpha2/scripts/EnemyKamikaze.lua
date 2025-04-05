local enemy = require("scripts/utils/enemy")

local enemy_kamikaze = enemy:new()

local pathUpdateTimer = 0.0
local pathUpdateInterval = 0.5
local attackTimer = 0.0
local attackDelay = 0.75

function on_ready() 

    enemy_kamikaze.player = current_scene:get_entity_by_name("Player")
    enemy_kamikaze.playerTransf = enemy_kamikaze.player:get_component("TransformComponent")
    enemy_kamikaze.playerScript = enemy_kamikaze.player:get_component("ScriptComponent")

    enemy_kamikaze.enemyTransf = self:get_component("TransformComponent")
    enemy_kamikaze.animator = self:get_component("AnimatorComponent")
    enemy_kamikaze.enemyRbComponent = self:get_component("RigidbodyComponent")
    enemy_kamikaze.enemyRb = enemy_kamikaze.enemyRbComponent.rb
    enemy_kamikaze.enemyNavmesh = self:get_component("NavigationAgentComponent")

    enemy_kamikaze.explosiveBarrel = current_scene:get_entity_by_name("explosiveBarrel")
    enemy_kamikaze.explosiveBarrelRb = enemy_kamikaze.explosiveBarrel:get_component("RigidbodyComponent").rb



    -- Stats of the Kamikaze
    enemy_kamikaze.health = 45
    enemy_kamikaze.speed = 10
    enemy_kamikaze.damage = 40
    enemy_kamikaze.detectionRange = 20
    enemy_kamikaze.attackRange = 1
    enemy_kamikaze.explosionRange = 5



    enemy_kamikaze.idleAnim = 3
    enemy_kamikaze.moveAnim = 5
    enemy_kamikaze.attackAnim = 7
    enemy_kamikaze.dieAnim = 0

    enemy_kamikaze.playerDistance = enemy_kamikaze:get_distance(enemy_kamikaze.enemyTransf.position, enemy_kamikaze.playerTransf.position) + 100        -- **ESTO HAY QUE ARREGLARLO**
    enemy_kamikaze.lastTargetPos = enemy_kamikaze.playerTransf.position
    enemy_kamikaze.isExploding = false
    enemy_kamikaze.hasExploded = false
    enemy_kamikaze.hasDealtDamage = false

end

function on_update(dt) 

    if enemy_kamikaze.isDead then return end

    change_state()

    if enemy_kamikaze.isExploding then
        attackTimer = attackTimer + dt
        enemy_kamikaze:attack_state()
        return
    end

    if not enemy_kamikaze.hasExploded and enemy_kamikaze.health <= 0 then
        drop_bomb()
        enemy_kamikaze:die_state()
    elseif enemy_kamikaze.hasExploded and enemy_kamikaze.health <= 0 then
        enemy_kamikaze:die_state()
    end

    pathUpdateTimer = pathUpdateTimer + dt
    local currentTargetPos = enemy_kamikaze.playerTransf.position

    if pathUpdateTimer >= pathUpdateInterval or enemy_kamikaze:get_distance(enemy_kamikaze.lastTargetPos, currentTargetPos) > 1.0 then
        enemy_kamikaze.lastTargetPos = currentTargetPos
        enemy_kamikaze:update_path(enemy_kamikaze.playerTransf)
        pathUpdateTimer = 0
    end

    if enemy_kamikaze.playerDetected then
        enemy_kamikaze:rotate_enemy(enemy_kamikaze.playerTransf.position)
    end

    if enemy_kamikaze.currentState == enemy_kamikaze.state.Idle then
        enemy_kamikaze:idle_state()

    elseif enemy_kamikaze.currentState == enemy_kamikaze.state.Move then
        enemy_kamikaze:move_state()
    
    elseif enemy_kamikaze.currentState == enemy_kamikaze.state.Attack then
        enemy_kamikaze:attack_state()
    end

end

function change_state()

    enemy_kamikaze:enemy_raycast()

    if enemy_kamikaze.playerDetected and enemy_kamikaze.playerDistance <= enemy_kamikaze.detectionRange then
        enemy_kamikaze.currentState = enemy_kamikaze.state.Move
        enemy_kamikaze.playerDetected = true
    end

    if enemy_kamikaze.playerDetected and enemy_kamikaze.playerDistance <= enemy_kamikaze.attackRange then
        enemy_kamikaze.currentState = enemy_kamikaze.state.Attack
        enemy_kamikaze.isExploding = true
    end

end

function enemy_kamikaze:attack_state()
    enemy_kamikaze.enemyRb:set_velocity(Vector3.new(0, 0, 0))

    if enemy_kamikaze.currentAnim ~= enemy_kamikaze.attackAnim then
        enemy_kamikaze.currentAnim = enemy_kamikaze.attackAnim
        enemy_kamikaze.animator:set_current_animation(enemy_kamikaze.currentAnim)
    end

    if attackTimer >= attackDelay and not enemy_kamikaze.hasDealtDamage then
        local explosionPos = enemy_kamikaze.enemyRb:get_position()
        local playerPos = enemy_kamikaze.playerTransf.position

        local distance = enemy_kamikaze:get_distance(explosionPos, playerPos)
        
        if distance < enemy_kamikaze.explosionRange then
            enemy_kamikaze:make_damage(enemy_kamikaze.damage)
        end

        enemy_kamikaze.hasDealtDamage = true
        enemy_kamikaze.health = 0
        enemy_kamikaze.hasExploded = true
        enemy_kamikaze:die_state()
    end
end

function on_exit() end