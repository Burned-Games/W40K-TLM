
--Audio
local diaCine = nil

--Dialogo
local dialogLines = nil
--dialog
local dialogScriptComponent = nil

function on_ready()

    --Audio
    --dia1_audio1 = current_scene:get_entity_by_name("dia1_audio1"):get_component("AudioSourceComponent")
    --dia1_audio2 = current_scene:get_entity_by_name("dia1_audio2"):get_component("AudioSourceComponent")
    -- dialogLines = {
    --     { name = "Carlos", text = "Hola, bienvenido al mundo", audio = dia1_audio1 },
    --      { name = "Carlos", text = "Hola, bienvenido al mundo", audio = dia1_audio2 }
    -- }

    --Dialogo
    dialogLines = {
        { name = "DeciusMarcellus", text = "Approaching Temperis, 1 minute until planetfall. Be ready for the landing, we detect multiple green skins lurking around, the way to Martyria Eterna won't be easy. Good luck brother, the Emperor protects."}
    }

   
    
    dialogScriptComponent = current_scene:get_entity_by_name("DialogManager"):get_component("ScriptComponent")
    dialogScriptComponent.start_dialog(dialogLines)



end

function on_update(dt)
end
