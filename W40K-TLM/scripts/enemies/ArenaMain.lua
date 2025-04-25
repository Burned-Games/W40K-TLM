--local listUtils = require("scripts/ListHelper")

-- Child references - Names in hierarchy are in PascalCase with "Arena" as prefix

--local enemyPool = nil -- child object with enemies inside (no se usará el pool)
local battleTrigger = nil -- child object with rigidbody
local spawnPoint = nil -- child object, no components required
local exitDoor = nil -- child object, no components required

local spawnRadius = 1.5 -- max distance from center to spawn enemies

local enemies = {}
local enemyScripts = {}
local enemyTypes = {}

-- Arena data
local currentRound = 0
local WaveData = {
    {{type="tank", id=1}},
    {{type="range", id=1}, {type="range", id=2}, {type="range", id=3}, {type="range", id=4}}, -- TODO CHANGE ONE RANGE FOR ONE SUPP
    {{type="range", id=5}, {type="range", id=6}, {type="tank", id=2}} -- TODO TANK2 NOT WORKING (NO TANK2 IN SCENE)
}
local activeEnemies = {}
local activeEnemyScripts = {}
local activeEnemyTypes = {}

local arenaEnded = true
local waitingForKeyPress = false
local allWavesCompleted = false

local bBattleTrigger = false

-- Variables para controlar el estado de las teclas -- DELETE LATER
local m_key_pressed = false
local n_key_pressed = false
local player = nil

function on_ready()
    -- Add initialization code here
    
    --enemyPool = current_scene:get_entity_by_name("ArenaEnemyPool")
    battleTrigger = current_scene:get_entity_by_name("ArenaBattleTrigger")
    spawnPoint = current_scene:get_entity_by_name("ArenaSpawnCenter"):get_component("TransformComponent").position
    exitDoor = current_scene:get_entity_by_name("ArenaExitDoor")
    playerTransf = current_scene:get_entity_by_name("Player"):get_component("TransformComponent")
    
    -- Range enemies
    for i = 1, 6 do -- Serían 5 según el figma (falta poner un SUPP)
        registerEnemy("range", i, "EnemyRange" .. i)
    end
    
    -- Tank enemies
    for i = 1, 2 do -- Falat un tank en la escena (peta por alguna razón con 2 tanks?)
        registerEnemy("tank", i, "EnemyTank" .. i)
    end
    
    -- Support enemies
    for i = 1, 3 do
        registerEnemy("supp", i, "EnemySupport" .. i)
    end

    mission_Component = current_scene:get_entity_by_name("MisionManager"):get_component("ScriptComponent")

    configureBattleTrigger()
end

function registerEnemy(type, id, enemyName)
    local key = type .. "_" .. id
    local enemy = current_scene:get_entity_by_name(enemyName)
    if enemy and enemy:is_valid() then
        enemies[key] = enemy
        enemyScripts[key] = enemy:get_component("ScriptComponent")
        enemyTypes[key] = type
        log("Found enemy: " .. enemyName .. " of type " .. type)
        
        -- Set the arena enemy flag
        if type == "range" and enemyScripts[key].range then
            enemyScripts[key].range.isArenaEnemy = true
        elseif type == "tank" and enemyScripts[key].tank then
            enemyScripts[key].tank.isArenaEnemy = true
        elseif type == "supp" and enemyScripts[key].supp then
            enemyScripts[key].supp.isArenaEnemy = true
        end

        enemy:set_active(false)
    else
        log("WARNING: Enemy " .. enemyName .. " not found!")
    end
end

function advanceToNextWave()
    waitingForKeyPress = false
    if currentRound >= #WaveData then
        openDoor()
        arenaEnded = true
        allWavesCompleted = true
        log("All waves completed! Door opened.")
       
    else
        log("Starting next wave...")
        spawnLogic()
    end
    
    if mission_Component.getCurrerTaskIndex(true) == 9 then
        print("AREASADASADasdasdasdfasd")
        mission_Component.m9_EnemyCount = mission_Component.m9_EnemyCount + 1
    end
end

function checkEnemyStatus()
    local enemyCount = 0
    local enemiesDead = 0
    
    for i, enemy in ipairs(activeEnemyScripts) do
        enemyCount = enemyCount + 1
        local enemyType = activeEnemyTypes[i]
        local isDead = false
        local enemyInstance = nil
        
        if enemyType == "range" then
            enemyInstance = enemy.range
            isDead = enemyInstance.health <= 0 or enemyInstance.isDead
        elseif enemyType == "tank" then
            enemyInstance = enemy.tank
            isDead = enemyInstance.health <= 0 or enemyInstance.isDead
        elseif enemyType == "supp" then
            enemyInstance = enemy.supp
            isDead = enemyInstance.health <= 0 or enemyInstance.isDead
        end
        
        if isDead then
            enemiesDead = enemiesDead + 1
        end
    end
    
    return enemyCount, enemiesDead
end

function checkWaveCompletion(enemyCount, enemiesDead)
    -- All enemies in current wave are defeated
    if enemyCount > 0 and enemiesDead == enemyCount then
        if not waitingForKeyPress then
            log("Wave " .. currentRound .. " completed! Press N for next wave.")
            waitingForKeyPress = true
        end
        
        -- Control de tecla N (siguiente oleada) - Anti-spam
        local current_n_state = Input.is_key_pressed(Input.keycode.N)
        if current_n_state and not n_key_pressed and waitingForKeyPress then
            advanceToNextWave()
        end
        n_key_pressed = current_n_state
    end
end

function on_update(dt)
    if not arenaEnded then 
        -- Control de tecla M (matar enemigos) -- DELETE LATER
        local current_m_state = Input.is_key_pressed(Input.keycode.M)
        if current_m_state and not m_key_pressed then
            if #activeEnemyScripts > 0 then
                log("DEBUG: Killing all enemies with M key")
                for i, enemy in ipairs(activeEnemyScripts) do
                    local enemyType = activeEnemyTypes[i]
                    if enemyType == "range" then
                        enemy.range.health = 0
                    elseif enemyType == "tank" then
                        enemy.tank.health = 0
                    elseif enemyType == "supp" then
                        enemy.supp.health = 0
                    end
                    log("Enemy killed by debug command")
                end
            else
                log("No active enemies to kill")
            end
        end
        m_key_pressed = current_m_state
        
        local enemyCount, enemiesDead = checkEnemyStatus()
        checkWaveCompletion(enemyCount, enemiesDead)
    end
end

function on_exit()
    -- Add cleanup code here
end

function spawnEnemies()
    local arenaCenter = spawnPoint
    
    for i, entity in ipairs(activeEnemies) do
        -- Set enemy to active and spawn at random position
        entity:set_active(true)
        local scriptComponent = entity:get_component("ScriptComponent")
        local rigidbodyComponent = entity:get_component("RigidbodyComponent")
        local navComponent = entity:get_component("NavigationAgentComponent")
        
        local enemyType = activeEnemyTypes[i]
        local enemyEntity = nil
        
        if enemyType == "range" then
            enemyEntity = scriptComponent.range
        elseif enemyType == "tank" then
            enemyEntity = scriptComponent.tank
        elseif enemyType == "supp" then
            enemyEntity = scriptComponent.supp
        end
        
        if enemyEntity then
            enemyEntity.isArenaEnemy = true
            enemyEntity.zoneNumber = 3 -- Setting this to a high value to ensure it's always above player zone
            enemyEntity.zoneSet = true  -- Prevent check_spawn from running again

            enemyEntity.currentState = 1 -- state.Idle

            -- Initial spawn position
            local spawnOffset = Vector3.new(
                math.cos(math.random() * 2 * math.pi) * spawnRadius,
                0,
                math.sin(math.random() * 2 * math.pi) * spawnRadius
            )
            
            local spawnPos = Vector3.new(arenaCenter.x + spawnOffset.x, 0, arenaCenter.z + spawnOffset.z)
            rigidbodyComponent.rb:set_position(spawnPos)
            
            -- Log the spawn for debugging
            log("Enemy " .. enemyType .. " spawned at position: " .. spawnPos.x .. ", " .. spawnPos.y .. ", " .. spawnPos.z)

            if navComponent then
                log("Enemy path updated")
                enemyEntity:update_path(playerTransf)
                enemyEntity.currentState = enemyEntity.state.Move
            end
        end
    end
end

function despawnEnemies()
    for _, entity in ipairs(activeEnemies) do
        entity:set_active(false)
    end
    activeEnemies = {}
    activeEnemyScripts = {}
    activeEnemyTypes = {}
end

function spawnLogic()
    -- Increment round and prepare to spawn
    currentRound = currentRound + 1
    
    despawnEnemies()

    activeEnemies = {}
    activeEnemyScripts = {}
    activeEnemyTypes = {}
    
    for _, enemyData in ipairs(WaveData[currentRound]) do
        local key = enemyData.type .. "_" .. enemyData.id
        if enemies[key] and enemies[key]:is_valid() then
            table.insert(activeEnemies, enemies[key])
            table.insert(activeEnemyScripts, enemyScripts[key])
            table.insert(activeEnemyTypes, enemyData.type)
            log("Activating enemy " .. enemyData.type .. " " .. enemyData.id)
        else
            log("WARNING: Enemy " .. enemyData.type .. " " .. enemyData.id .. " not available!")
        end
    end
    
    log("Wave " .. currentRound .. " starting with " .. #activeEnemies .. " enemies")
    spawnEnemies()
end

-- Helper function to check if list contains a value
function listContainsValue(list, value)
    for _, v in ipairs(list) do
        if v == value then
            return true
        end
    end
    return false
end

function openDoor()
    log("Opening exit door")
    -- TODO -> Guillem??
end

function configureBattleTrigger()
    local rbComponent = battleTrigger:get_component("RigidbodyComponent")
    local rb = rbComponent.rb
    rb:set_trigger(true)
    rb:set_use_gravity(false)
    
    rbComponent:on_collision_enter(function(entityA, entityB)
        if entityB:get_component("TagComponent").tag == "Player" then

            if bBattleTrigger then return end
            log("Player entered arena - Battle starting!")
            arenaEnded = false
            currentRound = 0
            waitingForKeyPress = false
            allWavesCompleted = false
            bBattleTrigger = true
            
            -- Start the first wave immediately
            spawnLogic()
        end
    end)
end