local dia1_audio1 = nil
local dialogLines = nil

function on_ready()
    dia1_audio1 = current_scene:get_entity_by_name("dia1_audio1"):get_component("AudioSourceComponent")
    dia1_audio2 = current_scene:get_entity_by_name("dia1_audio2"):get_component("AudioSourceComponent")
    if not dia1_audio1 then
        print("Error: dia1_audio1 entity or AudioSourceComponent not found!")
        return
    end

    dialogLines = {
        { name = "Carlos", text = "Hola, bienvenido al mundo", audio = dia1_audio1 },
         { name = "Carlos", text = "Hola, bienvenido al mundo", audio = dia1_audio2 }
    }

    dialogScriptComponent = current_scene:get_entity_by_name("DialogManager"):get_component("ScriptComponent")
    if dialogScriptComponent then
        --dialogScriptComponent.start_dialog(dialogLines)
    else
        print("Error: DialogManager ScriptComponent not found!")
    end
end

function on_update(dt)

end

function on_exit()
    -- Add cleanup code here
end
