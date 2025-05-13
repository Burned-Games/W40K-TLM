dialogLines = {
    { name = "Decius Marcellus", text = "This is Decius Marcellus, commander of Guilliman's Fist..." },
    { name = "Decius Marcellus", text = "Has anyone successfully made planetfall? I repeat: are there any survivors?" },
    { name = "Decius Marcellus", text = "I think you're the only survivor, Brother Quintus Maxillian. Maintain course toward Martyria Eterna." },
    { name = "Decius Marcellus", text = "We detect enemies along your path. May the Emperor be with you." }
}


 local dialogScriptComponent = nil

function on_ready()
     --Mission
    -- dialogScriptComponent = current_scene:get_entity_by_name("DialogManager"):get_component("ScriptComponent")
    -- log(dialogLines[1].text)
    -- log(current_scene:get_entity_by_name("DialogManager"):get_component("TagComponent").tag)
    -- dialogScriptComponent.start_dialog(dialogLines)
end

function on_update(dt)
    -- Add update code here
    --dialogScriptComponent = current_scene:get_entity_by_name("DialogManager"):get_component("ScriptComponent")
    --dialogScriptComponent.start_dialog(dialogLines)
    --print("sss")
end

function on_exit()
    -- Add cleanup code here
end
