dialogLines = {
    { name = "Carlos", text = "Hola, bienvenido al mundo" },
    { name = "Ana", text = "Espero que estes preparado para la aventura." },
    { name = "Carlos", text = "Vamos alla" }
}

--dialog
local dialogScriptComponent = nil

function on_ready()

    dialogScriptComponent = current_scene:get_entity_by_name("DialogManager"):get_component("ScriptComponent")
    --dialogScriptComponent.changeAutoTime(1)
    dialogScriptComponent.start_dialog(dialogLines)
end

function on_update(dt)
end
