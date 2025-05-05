local bossBar = nil
local bossBarLife = nil

function on_ready()
    bossBar = current_scene:get_entity_by_name("BossBar")
    bossBarLife = current_scene:get_entity_by_name("BossLifeUI"):get_component("UIImageComponent")
    bossManager = current_scene:get_entity_by_name("MainBoss"):get_component("ScriptComponent") 
    bossCamera = current_scene:get_entity_by_name("Camera"):get_component("ScriptComponent") 
end


function on_update(dt)

    if bossCamera.cameraBossActivated == true then 
        bossBar:set_active(true)
    end

    local vida = bossManager.main_boss.health
    local maxHealth = 1000
    
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

