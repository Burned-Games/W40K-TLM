--Audio
local dia1_audio1 = nil
local dia1_audio2 = nil
local dia1_audio3 = nil
local dia5L_audio1 = nil
local dia5S_audio1 = nil
local dia8_audio1 = nil
local dia9L_audio1 = nil
local dia9L_audio2 = nil
local dia9S_audio1 = nil
local dia9S_audio2 = nil
local dia10_audio1 = nil
local dia11_audio1 = nil
--Dialogo
local dialogLines1 = nil
local dialogLines5L = nil
local dialogLines5S = nil
local dialogLines8 = nil
local dialogLines9L = nil
local dialogLines9S = nil
local dialogLines10 = nil
local dialogLines11 = nil


dialog5L = false
dialog5S = false
dialog8 = false
dialog9L = false
dialog9S = false
dialog10 = false
dialog11 = false

function on_ready()

    --Audio
    dia1_audio1 = current_scene:get_entity_by_name("dia1_audio1"):get_component("AudioSourceComponent")
    dia1_audio2 = current_scene:get_entity_by_name("dia1_audio2"):get_component("AudioSourceComponent")
    dia1_audio3 = current_scene:get_entity_by_name("dia1_audio3"):get_component("AudioSourceComponent")

    dia5L_audio1 = current_scene:get_entity_by_name("dia5L_audio1"):get_component("AudioSourceComponent")
    dia5S_audio1 = current_scene:get_entity_by_name("dia5S_audio1"):get_component("AudioSourceComponent")
    dia8_audio1 = current_scene:get_entity_by_name("dia8_audio1"):get_component("AudioSourceComponent")
    dia9L_audio1 = current_scene:get_entity_by_name("dia9L_audio1"):get_component("AudioSourceComponent")
    dia9L_audio2 = current_scene:get_entity_by_name("dia9L_audio2"):get_component("AudioSourceComponent")
    dia9S_audio1 = current_scene:get_entity_by_name("dia9S_audio1"):get_component("AudioSourceComponent")
    dia9S_audio2 = current_scene:get_entity_by_name("dia9S_audio2"):get_component("AudioSourceComponent")
    dia10_audio1 = current_scene:get_entity_by_name("dia10_audio1"):get_component("AudioSourceComponent")
    dia11_audio1 = current_scene:get_entity_by_name("dia11_audio1"):get_component("AudioSourceComponent")

    -- dialogLines = {
    --     { name = "Carlos", text = "Hola, bienvenido al mundo", audio = dia1_audio1 },
    --      { name = "Carlos", text = "Hola, bienvenido al mundo", audio = dia1_audio2 }
    -- }

    --Dialogo
    dialogLines1 = {
        { name = "DeciusMarcellus", text = "This is Decius Marcellus, Commander of Guilliman's Fist. Has anyone successfully made planetfall? Does anyone still live?", audio = dia1_audio1, time =9.6},
        { name = "DeciusMarcellus", text = "This is Brother Quintus Maxillian, Ultramarine of the 3rd Company. As far as I can tell, I am the only one left.", audio = dia1_audio2, time = 7.5},
        { name = "DeciusMarcellus", text = "It appears you are the sole survivor. Nonetheless, the mission stands. The Emperor protects, Brother.", audio = dia1_audio3, time = 8}
    }
    
    dialogLines5L = {
        { name = "DeciusMarcellus", text = "Brother Maxillian, a supply pod is en route to your position. Use it to upgrade your gear. May the Emperor's light guide your hand.", audio = dia5L_audio1, time = 9}
    }

    dialogLines5S = {
        { name = "DeciusMarcellus", text = "We're detecting medicae injectors nearby. Tend to your wounds with them before proceeding. The mission must not falter.", audio = dia5S_audio1, time = 7.8}
    }

    dialogLines8 = {
        { name = "QuintusMaxillian", text = "Brother, the scanner reveals heavy Ork presence. Enter their stronghold and purge them all.", audio = dia8_audio1, time = 6}
    }

    dialogLines9L = {
        { name = "QuintusMaxillian", text = "Commander Decius, I hear Orks nearby. Can you confirm their numbers?", audio = dia9L_audio1, time = 4},
        { name = "DeciusMarcellus", text = "You are surrounded, Brother. Prepare for a brutal confrontation. The Emperor protects brother.", audio = dia9L_audio2, time = 6}
    }

    dialogLines9S = {
        { name = "DeciusMarcellus", text = "Status report-are you still with us, Brother?", audio = dia9S_audio1, time = 4},
        { name = "QuintusMaxillian", text = "I remain unbroken. Still in one piece. Anything ahead I should be wary of?", audio = dia9S_audio2, time = 5}
    }

    dialogLines10 = {
        { name = "DeciusMarcellus", text = "Nothing more brother, few enemies left. Go ahead brother, clean this place and proceed with the mission.", audio = dia10_audio1, time = 6.5}
    }

    dialogLines11 = {
        { name = "DeciusMarcellus", text = "Little resistance remains. Once you clear the path ahead, proceed directly to Martyria Eterna. Finish this, Brother.", audio = dia11_audio1, time = 8}
    }
    
    dialogScriptComponent = current_scene:get_entity_by_name("DialogManager"):get_component("ScriptComponent")
    dialogScriptComponent.start_dialog(dialogLines1)


end

function on_update(dt)


    if dialog5L then 
        dialogScriptComponent.start_dialog(dialogLines5L)
        dialog5L = false
    end

    if dialog5S then 
        dialogScriptComponent.start_dialog(dialogLines5S)
        dialog5S = false
    end

    if dialog8 then 
        dialogScriptComponent.start_dialog(dialogLines8)
        dialog8 = false
    end

    if dialog9L then 
        dialogScriptComponent.start_dialog(dialogLines9L)
        dialog9L = false
    end

    if dialog9S then 
        dialogScriptComponent.start_dialog(dialogLines9S)
        dialog9S = false
    end

    if dialog10 then 
        dialogScriptComponent.start_dialog(dialogLines10)
        dialog10 = false
    end

    if dialog11 then 
        dialogScriptComponent.start_dialog(dialogLines11)
        dialog11 = false
    end



end

function on_exit()
    -- Add cleanup code here
end
