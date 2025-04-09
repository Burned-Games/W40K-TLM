--local listUtils = require("scripts/ListHelper")

-- Child references - Names in hierarchy are in PascalCase with "Arena" as prefix

--local enemyPool = nil -- child object with enemies inside (no se usará el pool)
local battleTrigger = nil -- child object with rigidbody
local spawnPoint = nil -- child object, no components required
local exitDoor = nil -- child object, no components required

-- New target positions for enemies to move to
local targetPositions = {}

local spawnRadius = 0.1 -- max distance from center to spawn enemies

-- Array de enemigos específicos por nombre
local enemies = {}
local enemyScripts = {}

-- Arena data
local currentRound = 0
local WaveData = {
    {1}, -- Oleada 1: 1 enemigo
    {2,3,4,5}, -- Oleada 2: 4 enemigos
    {6,7,8} -- Oleada 3: 3 enemigos
}
local activeEnemies = {}
local activeEnemyScripts = {}

local arenaEnded = true
local waitingForKeyPress = false
local allWavesCompleted = false

-- Variables para controlar el estado de las teclas
local m_key_pressed = false
local n_key_pressed = false
local player = nil

function on_ready()
    -- Add initialization code here
    
    --enemyPool = current_scene:get_entity_by_name("ArenaEnemyPool")
    battleTrigger = current_scene:get_entity_by_name("ArenaBattleTrigger")
    spawnPoint = current_scene:get_entity_by_name("ArenaSpawnCenter"):get_component("TransformComponent").position
    exitDoor = current_scene:get_entity_by_name("ArenaExitDoor")
    player = current_scene:get_entity_by_name("Player"):get_component("TransformComponent")
    -- Enemies rangedX
    for i = 1, 8 do
        local enemyName = "EnemyRange" .. i
        local enemy = current_scene:get_entity_by_name(enemyName)
        if enemy and enemy:is_valid() then
            enemies[i] = enemy
            enemyScripts[i] = enemy:get_component("ScriptComponent")
            log("Found enemy: " .. enemyName)
            
            -- Mover enemigos fuera de la vista inicialmente
            enemy:set_active(false)
            --enemy:get_component("TransformComponent"):set_position(Vector3.new(5000, 0, 5000))
        else
            log("WARNING: Enemy " .. enemyName .. " not found!")
        end
    end
    
    --Get target position entities
    for i = 1, 4 do
        local targetPos = current_scene:get_entity_by_name("ArenaTargetPosition" .. i)
        if targetPos and targetPos:is_valid() then
            table.insert(targetPositions, targetPos)
        else
            log("Warning: ArenaTargetPosition" .. i .. " not found")
        end
    end
    
    configureBattleTrigger()
end

function on_update(dt)
    if not arenaEnded then 
        -- Control de tecla M (matar enemigos)
        local current_m_state = Input.is_key_pressed(Input.keycode.M)
        if current_m_state and not m_key_pressed then
            if #activeEnemyScripts > 0 then
                log("DEBUG: Killing all enemies with M key")
                for _, enemy in ipairs(activeEnemyScripts) do
                    enemy.health = 0
                    log("Enemy killed by debug command")
                end
            else
                log("No active enemies to kill")
            end
        end
        m_key_pressed = current_m_state
        
        -- Check enemy status
        local enemyCount = 0
        local enemiesDead = 0
        
        for _, enemy in ipairs(activeEnemyScripts) do
            enemyCount = enemyCount + 1
            if enemy.range.health <= 0 or enemy.range.isDead then
                enemiesDead = enemiesDead + 1
            end
        end

        -- All enemies in current wave are defeated
        if enemyCount > 0 and enemiesDead == enemyCount then
            if not waitingForKeyPress then
                log("Wave " .. currentRound .. " completed! Press N for next wave.")
                waitingForKeyPress = true
            end
            
            -- Control de tecla N (siguiente oleada) - Anti-spam
            local current_n_state = Input.is_key_pressed(Input.keycode.N)
            if current_n_state and not n_key_pressed and waitingForKeyPress then
                waitingForKeyPress = false
                -- Check if we've completed all waves
                if currentRound >= #WaveData then
                    openDoor()
                    arenaEnded = true
                    allWavesCompleted = true
                    log("All waves completed! Door opened.")
                else
                    log("Starting next wave...")
                    spawnLogic()
                end
            end
            n_key_pressed = current_n_state
        end
    end
end

function on_exit()
    -- Add cleanup code here
end

function spawnEnemies()
    local arenaCenter = spawnPoint
    
    for _, entity in ipairs(activeEnemies) do

        -- Set enemy to active and spawn at random position
        entity:set_active(true)
        local scriptComponent = entity:get_component("ScriptComponent")
        local rigidbodyComponent = entity:get_component("RigidbodyComponent")
        local navComponent = entity:get_component("NavigationAgentComponent")
        local enemyEntity = scriptComponent.range
        -- Reset enemy state
        enemyEntity.health = 95
        enemyEntity.isDead = false
        enemyEntity.currentState = 1 -- state.Idle
        if enemyEntity.shield_destroyed ~= nil then
            enemyEntity.shield_destroyed = false
        end
        
        -- -- Initial spawn position
        local spawnOffset = Vector3.new(
            math.cos(math.random() * 2 * math.pi) * spawnRadius,
            0,
            math.sin(math.random() * 2 * math.pi) * spawnRadius
        )
        rigidbodyComponent.rb:set_position(Vector3.new(arenaCenter.x + spawnOffset.x, 0, arenaCenter.z + spawnOffset.z))

        
        
        -- TODO - NOT WORKING: Set enemy to move to spawn point




        -- Set enemy to move to a random target position
        if navComponent and #targetPositions > 0 then
            local randomTargetPos = targetPositions[math.random(1, #targetPositions)]
            log("Moving enemy to random position")
            if enemyEntity then
                log("Enemy path updated")
                enemyEntity:update_path(player)
                enemyEntity.currentState = enemyEntity.state.Move
            end
        end
        
        log("Enemy spawned at (" .. (arenaCenter.x + spawnOffset.x) .. "," .. (arenaCenter.z + spawnOffset.z) .. ")")
    end
end

function despawnEnemies()
    for _, entity in ipairs(activeEnemies) do
        --entity:get_component("TransformComponent"):set_position(Vector3.new(5000, 0, 5000))
        entity:set_active(false)
    end
    activeEnemies = {}
    activeEnemyScripts = {}
end

function spawnLogic()
    -- Increment round and prepare to spawn
    currentRound = currentRound + 1
    
    despawnEnemies()

    -- Activar enemigos específicos según la oleada actual
    activeEnemies = {}
    activeEnemyScripts = {}
    
    for _, enemyIndex in ipairs(WaveData[currentRound]) do
        if enemies[enemyIndex] and enemies[enemyIndex]:is_valid() then
            table.insert(activeEnemies, enemies[enemyIndex])
            table.insert(activeEnemyScripts, enemyScripts[enemyIndex])
            log("Activating enemy EnemyRange" .. enemyIndex)
        else
            log("WARNING: Enemy EnemyRange" .. enemyIndex .. " not available!")
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
    -- TODO Change for entity disable once that's implemented
    local t = exitDoor:get_component("TransformComponent")
    t:set_position(Vector3.new(5000, 100, -5050))
end

function configureBattleTrigger()
    local rbComponent = battleTrigger:get_component("RigidbodyComponent")
    local rb = rbComponent.rb
    rb:set_trigger(true)
    rb:set_use_gravity(false)
    
    rbComponent:on_collision_enter(function(entityA, entityB)
        if entityB:get_component("TagComponent").tag == "Player" then
            log("Player entered arena - Battle starting!")
            arenaEnded = false
            currentRound = 0
            waitingForKeyPress = false
            allWavesCompleted = false
            
            -- Start the first wave immediately
            spawnLogic()
            
            -- Move trigger away to prevent re-triggering
            local t = entityA:get_component("TransformComponent")
            t:set_position(Vector3.new(5000, -458760, 5000))
        end
    end)
end