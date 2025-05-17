--Audio
--local dia1_audio1 = nil

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
    --dia1_audio1 = current_scene:get_entity_by_name("dia1_audio1"):get_component("AudioSourceComponent")
    --dia1_audio2 = current_scene:get_entity_by_name("dia1_audio2"):get_component("AudioSourceComponent")

    -- dialogLines = {
    --     { name = "Carlos", text = "Hola, bienvenido al mundo", audio = dia1_audio1 },
    --      { name = "Carlos", text = "Hola, bienvenido al mundo", audio = dia1_audio2 }
    -- }

    dialogLines1 = {
        { name = "DeciusMarcellus", text = "This is Decius Marcellus, Commander of Guilliman's Fist. Has anyone successfully made planetfall? Does anyone still live?"},
        { name = "DeciusMarcellus", text = "This is Brother Quintus Maxillian, Ultramarine of the 3rd Company. As far as I can tell, I am the only one left."},
        { name = "DeciusMarcellus", text = "It appears you are the sole survivor. Nonetheless, the mission stands. The Emperor protects, Brother."}
    }
    
    dialogLines5L = {
        { name = "DeciusMarcellus", text = "Brother Maxillian, a supply pod is en route to your position. Use it to upgrade your gear. May the Emperor's light guide your hand."}
    }

    dialogLines5S = {
        { name = "DeciusMarcellus", text = "We're detecting medicae injectors nearby. Tend to your wounds with them before proceeding. The mission must not falter."}
    }

    dialogLines8 = {
        { name = "QuintusMaxillian", text = "Brother, the scanner reveals heavy Ork presence. Enter their stronghold and purge them all."}
    }

    dialogLines9L = {
        { name = "QuintusMaxillian", text = "Commander Decius, I hear Orks nearby. Can you confirm their numbers?"},
        { name = "DeciusMarcellus", text = "You are surrounded, Brother. Prepare for a brutal confrontation. The Emperor protects brother."}
    }

    dialogLines9S = {
        { name = "DeciusMarcellus", text = "Status report-are you still with us, Brother?"},
        { name = "QuintusMaxillian", text = "I remain unbroken. Still in one piece. Anything ahead I should be wary of?"}
    }

    dialogLines10 = {
        { name = "DeciusMarcellus", text = "Nothing more brother, few enemies left. Go ahead brother, clean this place and proceed with the mission."}
    }

    dialogLines11 = {
        { name = "DeciusMarcellus", text = "Little resistance remains. Once you clear the path ahead, proceed directly to Martyria Eterna. Finish this, Brother."}
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
        dialogScriptComponent.start_dialog(dialogLines9)
        dialog9 = false
    end

    if dialog9S then 
        dialogScriptComponent.start_dialog(dialogLines9)
        dialog9 = false
    end

    if dialog10 then 
        dialogScriptComponent.start_dialog(dialogLines10)
        dialog = false
    end

    if dialog11 then 
        dialogScriptComponent.start_dialog(dialogLines11)
        dialog11 = false
    end



end

function on_exit()
    -- Add cleanup code here
end
