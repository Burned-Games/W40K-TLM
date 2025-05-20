local bossScript = nil
local bossBar = nil
local bossBarBase = nil 
local bossBarLife = nil
local bossName = nil
local bossManager = nil
local playerManager = nil
local alpha = 0
local fadeActive = false

function on_ready()
    bossScript = current_scene:get_entity_by_name("MainBoss"):get_component("ScriptComponent")
    bossBar = current_scene:get_entity_by_name("BossBar")
    bossBarBase = current_scene:get_entity_by_name("BossBarBase"):get_component("UIImageComponent")
    bossBarLife = current_scene:get_entity_by_name("BossLifeUI"):get_component("UIImageComponent")
    bossName = current_scene:get_entity_by_name("BossName"):get_component("UITextComponent")
    bossManager = current_scene:get_entity_by_name("MainBoss"):get_component("ScriptComponent")
    playerManager = current_scene:get_entity_by_name("Player"):get_component("ScriptComponent")
    
    triggerBossBattle = current_scene:get_entity_by_name("TriggerBossBattle"):get_component("RigidbodyComponent")
    triggerBossBattle.rb:set_trigger(true)

    bossBarBase:set_color(Vector4.new(1, 1, 1, 0))
    bossBarLife:set_color(Vector4.new(1, 1, 1, 0))
    bossName:set_color(Vector4.new(0.55, 0, 0, 0))
    
    triggerBossBattle:on_collision_enter(function(entityA, entityB)
        local nameA = entityA:get_component("TagComponent").tag
        local nameB = entityB:get_component("TagComponent").tag

        if nameA == "Player" or nameB == "Player" then
            bossScript.main_boss.battleStart = true
            bossBar:set_active(true)
            alpha = 0
            fadeActive = true
        end
    end)
end

function on_update(dt)
    local vida = bossManager.main_boss.health
    local maxHealth = 1000  

    -- Handle fade-in effect
    if fadeActive and alpha < 1 then 
        alpha = alpha + dt * 0.7
        if alpha > 1 then
            alpha = 1
            fadeActive = false
        end
        bossBarBase:set_color(Vector4.new(1, 1, 1, alpha))
        bossBarLife:set_color(Vector4.new(1, 1, 1, alpha))
        bossName:set_color(Vector4.new(0.55, 0, 0, alpha))
    end

    if vida <= 0 then
        bossBar:set_active(false)
    end

    local healthPercentage = vida / maxHealth
    local cropPercentage = 1 - healthPercentage
    
    local x = 0
    local y = 0
    local width = 1
    local height = 1
    
    local lifeBoss = Vector4.new(x, y, width * healthPercentage, height)
    bossBarLife:set_rect(lifeBoss)
end

function on_exit()
    -- Add cleanup code here
end