
local listUtils = require("scripts/ListHelper")

-- Child references - Names in hierarchy are in PascalCase with "Arena" as prefix

local enemyPool = nil -- child object with enemies inside
local battleTrigger = nil -- child object with rigidbody
--local spawnPoint = nil -- child object, no components required. Currently unused
local exitDoor = nil -- child object, no components required

local spawnRadius = 3 -- max distance from center to spawn enemies

-- Arena data

local currentRound = 0
local WaveData = {{"Ranged", "Ranged", "Ranged"}, {"Tank"}, {"Ranged", "Support", "Tank"}} -- TODO change to correct names
local activeEnemies = {}
local activeEnemyScripts = {}

local arenaEnded = true


function on_ready()
    -- Add initialization code here

    do return end
    
    enemyPool = current_scene:get_entity_by_name("ArenaEnemyPool")
    battleTrigger = current_scene:get_entity_by_name("ArenaBattleTrigger")
    --spawnPoint = current_scene:get_entity_by_name("ArenaSpawnPoint")
    exitDoor = current_scene:get_entity_by_name("ArenaExitDoor")
    
    --[[
    local children = self:get_children()
    for _, child in ipairs(children) do
        local tag = child:get_component("TagComponent").tag
        if (tag == "ArenaEnemyPool") then
            enemyPool = child
        elseif (tag == "ArenaSpawnPoint") then
            spawnPoint = child
        elseif (tag == "ArenaBattleTrigger") then
            battleTrigger = child
        elseif (tag == "ArenaExitDoor") then
            exitDoor = child
        end
    end
    --]]

    configureBattleTrigger()

end

function on_update(dt)
    -- Add update code here
    do return end
    if true then return end
    if not arenaEnded then 

    local enemyCount = 0
    local enemiesDead = 0
    for _, enemy in ipairs(activeEnemyScripts) do
        enemyCount = enemyCount + 1
        if (enemy.enemyHealth <= 0) then
            log("Enemy dead")
            enemiesDead = enemiesDead + 1
        end
    end

    -- If all enemies are dead spawn next wave
    if (enemiesDead == enemyCount) then
        spawnLogic()

        -- Check if there's enemies spawned (no enemies after a call to spawnLogic == arena battle ended)
        local elementsInList = false
        for _, e in ipairs(activeEnemies) do
            elementsInList = true
            break
        end

        if (listUtils:listIsEmpty(activeEnemies)) then
            openDoor()
            log("Open Door")
        end
    end

    end
end

function on_exit()
    -- Add cleanup code here
end

function spawnEnemies()
    -- TODO change logic when prefabs and/or safe entity deletion are implemented

    local arenaCenter = self:get_component("TransformComponent").position
    local position = Vector3.new(0,0,0)
    
    for _, entity in ipairs(activeEnemies) do
        local scriptComponent = entity:get_component("ScriptComponent")
        local transformComponent = entity:get_component("TransformComponent")
        -- TODO need a "reset enemy" function OR prefab instantiation

        scriptComponent.enemyHealth = 50
        scriptComponent.isDead = false
        scriptComponent.currentState = 1 -- state.Idle
        scriptComponent.shield_destroyed = false

        position = Vector3.new(math.cos(math.random()*2*math.pi),0,math.sin(math.random()*2*math.pi))
        transformComponent:set_position(arenaCenter+position)

        --log("Spawned at ("..(arenaCenter.x+position.x)..","..(arenaCenter.z+position.z)..")")
    end

end

function despawnEnemies()
    for _, entity in ipairs(activeEnemies) do
        entity:get_component("TransformComponent"):set_position(Vector3.new(5000,0,5000))
    end
    activeEnemies = {}
    activeEnemyScripts = {}
    --log("Enemies despawned")
end

function spawnLogic()
    -- retrieve next enemy group and prepare to spawn

    currentRound = currentRound + 1

    despawnEnemies()

    -- for each entry in the wave data table loop the pool searching for the correct type of enemy
    local enemyList = enemyPool:get_children()
    local enemyCount = 1
    for _, enemyType in ipairs(WaveData[currentRound]) do
        for _, entity in ipairs(enemyList) do
            local tag = entity:get_component("TagComponent").tag
            if (tag == enemyType and not listUtils.listContainsValue(activeEnemies, entity)) then
                activeEnemies[enemyCount] = entity
                activeEnemyScripts[enemyCount] = entity:get_component("ScriptComponent")
                enemyCount = enemyCount + 1
                break
            end
        end
    end
    spawnEnemies()

end

function openDoor()
    -- Open the door once the arena waves are over
    -- Add animation?
    -- TODO Change for entity disable once that's implemented
    local t = exitDoor:get_component("TransformComponent")
    t:set_position(Vector3.new(5000,100,-5050))
end

function configureBattleTrigger()

    local rbComponent = battleTrigger:get_component("RigidbodyComponent")
    local rb = rbComponent.rb
    rb:set_trigger(true)
    rb:set_use_gravity(false)
    rbComponent:on_collision_enter(function(entityA, entityB)
    
        if (entityB:get_component("TagComponent").tag == "Player") then
            arenaEnded = false
            currentRound = 0
            -- TODO change for entity disable when that's implemented
            local t = entityA:get_component("TransformComponent")
            t:set_position(Vector3.new(5000,-458760,5000))
        --[[
        elseif (entityA:get_component("TagComponent").tag == "Player") then
            arenaEnded = false
            currentRound = 0
            -- TODO change for entity disable when that's implemented
            local t = entityB:get_component("TransformComponent")
            t:set_position(Vector3.new(5000,-458760,5000))
        --]]
        end

    end)


end
