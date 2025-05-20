local tankBar = nil
local tankBarBase = nil 
local tankBarLife = nil
local tankNam = nil
local tankManager = nil
local playerManager = nil
local alpha = 0
local fadeActive = false
local arenaIn = nil
local arenaOut = nil
local doorInAnimator = nil
local doorOutAnimator = nil
local doorsClosed = false

function on_ready()
    tankBar = current_scene:get_entity_by_name("TankBar")
    tankBarBase = current_scene:get_entity_by_name("TankBarBase"):get_component("UIImageComponent")
    tankBarLife = current_scene:get_entity_by_name("TankLifeUI"):get_component("UIImageComponent")
    tankNam = current_scene:get_entity_by_name("TankName"):get_component("UITextComponent")
    tankManager = current_scene:get_entity_by_name("EnemyTank1"):get_component("ScriptComponent")
    playerManager = current_scene:get_entity_by_name("Player"):get_component("ScriptComponent")
    
    arenaIn = current_scene:get_entity_by_name("ArenaEnter")
    arenaOut = current_scene:get_entity_by_name("ArenaExit")
    
    doorInAnimator = current_scene:get_entity_by_name("PuertaEntradaColiseo"):get_component("AnimatorComponent")
    doorOutAnimator = current_scene:get_entity_by_name("PuertaSalidaColiseo"):get_component("AnimatorComponent")

    arenaIn:set_active(false)
    arenaOut:set_active(false)
    
    triggerArenaBattle = current_scene:get_entity_by_name("TankBattleTrigger"):get_component("RigidbodyComponent")

    tankBarBase:set_color(Vector4.new(1, 1, 1, 0))
    tankBarLife:set_color(Vector4.new(1, 1, 1, 0))
    tankNam:set_color(Vector4.new(0.55, 0, 0, 0))
    
    doorInAnimator:set_current_animation(1) 
    doorOutAnimator:set_current_animation(1) 
    
    triggerArenaBattle:on_collision_enter(function(entityA, entityB)
        local nameA = entityA:get_component("TagComponent").tag
        local nameB = entityB:get_component("TagComponent").tag

        if (nameA == "Player" or nameB == "Player") and not doorsClosed then
           tankBar:set_active(true)
           
           arenaIn:set_active(true) 
           arenaOut:set_active(true)
           
           doorInAnimator:set_current_animation(0) 
           doorOutAnimator:set_current_animation(0) 
           alpha = 0
           fadeActive = true
           
           doorsClosed = true
        end
    end)
end

function on_update(dt)
    local vida = tankManager.tank.health
    local maxHealth = 350  

    -- Handle fade-in effect
    if fadeActive and alpha < 1 then 
        alpha = alpha + dt * 0.7
        if alpha > 1 then
            alpha = 1
            fadeActive = false
        end
        tankBarBase:set_color(Vector4.new(1, 1, 1, alpha))
        tankBarLife:set_color(Vector4.new(1, 1, 1, alpha))
        tankNam:set_color(Vector4.new(0.55, 0, 0, alpha))
    end

    if vida <= 0 and doorsClosed then
        tankBar:set_active(false)
 
        doorInAnimator:set_current_animation(1)  
        doorOutAnimator:set_current_animation(1)  
        
        arenaIn:set_active(false)
        arenaOut:set_active(false)
        
        doorsClosed = false
    end

    -- Update health bar
    local healthPercentage = vida / maxHealth
    local cropPercentage = 1 - healthPercentage
    
    local x = 0
    local y = 0
    local width = 1
    local height = 1
    
    local lifeTank = Vector4.new(x, y, width * healthPercentage, height)
    tankBarLife:set_rect(lifeTank)
end

function on_exit()
    -- Add cleanup code here
end