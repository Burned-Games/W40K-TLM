--Audio
--local dia1_audio1 = nil

--Dialogo
local dialogLines12 = nil
local dialogLines13 = nil
local dialogLines13Ac = nil
local dialogLines14 = nil
local dialogLines15 = nil
local dialogLines16 = nil
local dialogLines17 = nil
local dialogLines18 = nil
local dialogLines19 = nil

dialog12 = false
dialog13 = false
dialog13Ac = false
dialog14 = false
dialog15 = false
dialog16 = false
dialog17 = false
dialog18 = false
dialog19 = false

function on_ready()
    --dia1_audio1 = current_scene:get_entity_by_name("dia1_audio1"):get_component("AudioSourceComponent")
    --dia1_audio2 = current_scene:get_entity_by_name("dia1_audio2"):get_component("AudioSourceComponent")
    -- dialogLines = {
    --     { name = "Carlos", text = "Hola, bienvenido al mundo", audio = dia1_audio1 },
    --      { name = "Carlos", text = "Hola, bienvenido al mundo", audio = dia1_audio2 }
    -- }


    dialogLines12 = {
        { name = "DeciusMarcellus", text = "Welcome to Martyria Eterna brother. Find your way into the cathedral and finish Garrosh to end this invasion."}
    }
    
    dialogLines13 = {
        { name = "DeciusMarcellus", text = "You've reached a sealed sector. Find a manual override, a lever or control panel. Time is not on our side, Brother."}
    }

    dialogLines13Ac = {
        { name = "QuintusMaxillian", text = "Lever engaged, moving forward."}
    }

    dialogLines14 = {
        { name = "DeciusMarcellus", text = "Purge all remaining hostiles in the area. Leave no greenskin standing. Martyria Eterna depends on your advance."}
    }

    dialogLines15 = {
        { name = "QuintusMaxillian", text = "I've reached the Central Square of Martyria Eterna. I must explore the area. There has to be a way deeper into the city."}
    }
    
    dialogLines16 = {
        { name = "DeciusMarcellus", text = "Brother Maxillian, supply pod nearby. Upgrade your gear before advancing. The deeper you go, the deadlier it becomes."}
    }
    dialogLines17 = {
        { name = "DeciusMarcellus", text = "You're approaching the Great Bridge-but the access gate is sealed. Search the area for a lever. Force the passage open."}
    }
    dialogLines18 = {
        { name = "DeciusMarcellus", text = "Security protocols have raised the bridge gates. There must be manual overrides nearby. Activate and continue your advance."}
    }
    
    dialogLines19 = {
        { name = "DeciusMarcellus", text = "This is it, Brother. Upgrade your gear and tend to your wounds. The final confrontation awaits in the heart of Martyria Eterna."}
    }
   
    
    dialogScriptComponent = current_scene:get_entity_by_name("DialogManager"):get_component("ScriptComponent")
    dialogScriptComponent.start_dialog(dialogLines12)


end

function on_update(dt)

    if dialog12 then 
        dialogScriptComponent.start_dialog(dialogLines12)
        dialog12 = false
    end

    if dialog13 then 
        dialogScriptComponent.start_dialog(dialogLines13)
        dialog13 = false
    end

    if dialog13Ac then 
        dialogScriptComponent.start_dialog(dialogLines13Ac)
        dialog13Ac = false
    end

    if dialog14 then 
        dialogScriptComponent.start_dialog(dialogLines14)
        dialog14 = false
    end

    if dialog15 then 
        dialogScriptComponent.start_dialog(dialogLines15)
        dialog15 = false
    end

    if dialog16 then 
        dialogScriptComponent.start_dialog(dialogLines16)
        dialog16 = false
    end

    if dialog17 then 
        dialogScriptComponent.start_dialog(dialogLines17)
        dialog17 = false
    end

    if dialog18 then 
        dialogScriptComponent.start_dialog(dialogLines18)
        dialog18 = false
    end

    if dialog19 then 
        dialogScriptComponent.start_dialog(dialogLines19)
        dialog19 = false
    end



end

function on_exit()
    -- Add cleanup code here
end
