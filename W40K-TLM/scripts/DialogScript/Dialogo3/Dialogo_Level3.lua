--Audio
--local dia1_audio1 = nil

--Dialogo
local dialogLinesFind = nil
local dialogLinesChange = nil
local dialogLinesDie = nil


dialogFind = false
dialogChange = false
dialogDie = false

function on_ready()
    --dia1_audio1 = current_scene:get_entity_by_name("dia1_audio1"):get_component("AudioSourceComponent")
    --dia1_audio2 = current_scene:get_entity_by_name("dia1_audio2"):get_component("AudioSourceComponent")
    -- dialogLines = {
    --     { name = "Carlos", text = "Hola, bienvenido al mundo", audio = dia1_audio1 },
    --      { name = "Carlos", text = "Hola, bienvenido al mundo", audio = dia1_audio2 }
    -- }


    dialogLinesFind = {
        { name = "DeciusMarcellus", text = "Heh... You'z got lucky, humie. But dis iz where it ends. Martyria Eterna belongs to da WAAAGH now!"}
    }
    
    dialogLinesChange = {
        { name = "DeciusMarcellus", text = "RAAAAGH! Youz made me ANGRY now! No more playin' around-time to show ya da real pawa of Garrosh!!"}
    }

    dialogLinesDie = {
        { name = "DeciusMarcellus", text = "No...! Dis... ain't over... Garrosh ... never dies..."}
    }

    
    dialogScriptComponent = current_scene:get_entity_by_name("DialogManager"):get_component("ScriptComponent")
    dialogScriptComponent.start_dialog(dialogLines12)


end

function on_update(dt)

    if dialogFind then 
        dialogScriptComponent.start_dialog(dialogLinesFind)
        dialogFind = false
    end

    if dialogChange then 
        dialogScriptComponent.start_dialog(dialogLinesChange)
        dialogChange = false
    end

    if dialogDie then 
        dialogScriptComponent.start_dialog(dialogLinesDie)
        dialogDie = false
    end



end

function on_exit()
    -- Add cleanup code here
end
