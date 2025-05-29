
--Dialogo 2
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

--Dialogo 2
--Audio
local dia12_audio1 = nil
local dia13_audio1 = nil
local dia13Ac_audio1 = nil
local dia14_audio1 = nil
local dia15_audio1 = nil
local dia16_audio1 = nil
local dia17_audio1 = nil
local dia18_audio1 = nil
local dia19_audio1 = nil


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

--Dialogo 3
--Dialogo
local dialogLinesFind = nil
local dialogLinesChange = nil
local dialogLinesDie = nil


dialogFind = false
dialogChange = false
dialogDie = false


--Time variables

firstCallDialogo = true
openDialog = false
local timer = 0
local isTimerStarted = false


current_scene_name = nil
current_scene_tag = nil

--Colider
local dialogoScriptComponent = nil
local RigidBodyComponent = nil
local RigidBody = nil

local detect = false
local first = true

function on_ready()

    dialogScriptComponent = current_scene:get_entity_by_name("DialogManager"):get_component("ScriptComponent")
    mission_Component = current_scene:get_entity_by_name("MisionManager"):get_component("ScriptComponent")  

    current_scene_name = SceneManager:get_scene_name()
    current_scene_tag = self:get_component("TagComponent").tag

    if current_scene_name == "level1.TeaScene" then
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
    
    elseif current_scene_name == "level2.TeaScene" then
        --Audio
        dia12_audio1 = current_scene:get_entity_by_name("dia12_audio1"):get_component("AudioSourceComponent")
        dia13_audio1 = current_scene:get_entity_by_name("dia13_audio1"):get_component("AudioSourceComponent")
        dia13Ac_audio1 = current_scene:get_entity_by_name("dia13Ac_audio1"):get_component("AudioSourceComponent")
        dia14_audio1 = current_scene:get_entity_by_name("dia14_audio1"):get_component("AudioSourceComponent")
        dia15_audio1 = current_scene:get_entity_by_name("dia15_audio1"):get_component("AudioSourceComponent")
        dia16_audio1 = current_scene:get_entity_by_name("dia16_audio1"):get_component("AudioSourceComponent")
        dia17_audio1 = current_scene:get_entity_by_name("dia17_audio1"):get_component("AudioSourceComponent")
        dia18_audio1 = current_scene:get_entity_by_name("dia18_audio1"):get_component("AudioSourceComponent")
        dia19_audio1 = current_scene:get_entity_by_name("dia19_audio1"):get_component("AudioSourceComponent")


        --DialogoText
        dialogLines12 = {
            { name = "DeciusMarcellus", text = "Welcome to Martyria Eterna brother. Find your way into the cathedral and finish Garrosh to end this invasion.", audio = dia12_audio1, time = 7.5}
        }
        
        dialogLines13 = {
            { name = "DeciusMarcellus", text = "You've reached a sealed sector. Find a manual override, a lever or control panel. Time is not on our side, Brother.", audio = dia13_audio1, time = 8}
        }

        dialogLines13Ac = {
            { name = "QuintusMaxillian", text = "Lever engaged, moving forward.", audio = dia13Ac_audio1, time = 2}
        }

        dialogLines14 = {
            { name = "DeciusMarcellus", text = "Purge all remaining hostiles in the area. Leave no greenskin standing. Martyria Eterna depends on your advance.", audio = dia14_audio1, time = 8.5}
        }

        dialogLines15 = {
            { name = "QuintusMaxillian", text = "I've reached the Central Square of Martyria Eterna. I must explore the area. There has to be a way deeper into the city.", audio = dia15_audio1, time = 7}
        }
        
        dialogLines16 = {
            { name = "DeciusMarcellus", text = "Brother Maxillian, supply pod nearby. Upgrade your gear before advancing. The deeper you go, the deadlier it becomes.", audio = dia16_audio1, time = 9}
        }
        dialogLines17 = {
            { name = "DeciusMarcellus", text = "You're approaching the Great Bridge-but the access gate is sealed. Search the area for a lever. Force the passage open.", audio = dia17_audio1, time = 8.5}
        }
        dialogLines18 = {
            { name = "DeciusMarcellus", text = "Security protocols have raised the bridge gates. There must be manual overrides nearby. Activate and continue your advance.", audio = dia18_audio1, time = 9}
        }
        
        dialogLines19 = {
            { name = "DeciusMarcellus", text = "This is it, Brother. Upgrade your gear and tend to your wounds. The final confrontation awaits in the heart of Martyria Eterna.", audio = dia19_audio1, time = 9}
        }
       
    elseif current_scene_name == "level3.TeaScene" then
        dialogLinesFind = {
            { name = "DeciusMarcellus", text = "Heh... You'z got lucky, humie. But dis iz where it ends. Martyria Eterna belongs to da WAAAGH now!"}
        }
        
        dialogLinesChange = {
            { name = "DeciusMarcellus", text = "RAAAAGH! Youz made me ANGRY now! No more playin' around-time to show ya da real pawa of Garrosh!!"}
        }

        dialogLinesDie = {
            { name = "DeciusMarcellus", text = "No...! Dis... ain't over... Garrosh ... never dies..."}
        }
    end



    RigidBodyComponent = self:get_component("RigidbodyComponent")
    RigidBody = RigidBodyComponent.rb
    RigidBody:set_trigger(true)
    RigidBodyComponent:on_collision_enter(function(entityA, entityB)  
        local nameA = entityA:get_component("TagComponent").tag
        local nameB = entityB:get_component("TagComponent").tag   
    if nameA == "Player" or nameB == "Player" then
        detect = true
    else
        detect =false
    end
    end)
    


end

function on_update(dt)
    if mission_Component.blueTaskIndex == 1 and firstCallDialogo then
        firstCallDialogo = false    
        isTimerStarted = true      
        timer = 0                  
    end


    if isTimerStarted then
        timer = timer + dt        
        if timer >= 4 then          
            isTimerStarted = false  
            openDialog = true     
        end
    end

    if current_scene_name == "level1.TeaScene" then
        --Colider
        if detect and first and current_scene_tag =="Dialogo_Col_5L" then
            dialog5L = true
            first = false


        elseif detect and first and current_scene_tag =="Dialogo_Col_5S" then
            dialog5S = true
            first = false
        

        elseif detect and first and current_scene_tag =="Dialogo_Col_8" then
            dialog8 = true
            first = false
        

        elseif detect and first and current_scene_tag =="Dialogo_Col_9L" then
            dialog9L = true
            first = false
        

        elseif detect and first and current_scene_tag =="Dialogo_Col_9S" then
            dialog9S = true
            first = false


        elseif detect and first and current_scene_tag =="Dialogo_Col_10" then
            dialog10 = true
            first = false


        elseif detect and first and current_scene_tag =="Dialogo_Col_11" then
            dialog11 = true
            first = false
        end

        --Dialogo
        if openDialog then
            dialogScriptComponent.start_dialog(dialogLines1)
            openDialog = false
        end


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

    elseif current_scene_name == "level2.TeaScene" then
        --Colider
        if detect and first and current_scene_tag =="Dialogo_Col_13" then
            dialog13 = true
            first = false


        elseif detect and first and current_scene_tag =="Dialogo_Col_13AC" then
            dialog13Ac = true
            first = false
        

        elseif detect and first and current_scene_tag =="Dialogo_Col_14" then
            dialog14 = true
            first = false
        

        elseif detect and first and current_scene_tag =="Dialogo_Col_15" then
            dialog15 = true
            first = false
        

        elseif detect and first and current_scene_tag =="Dialogo_Col_16" then
            dialog16 = true
            first = false


        elseif detect and first and current_scene_tag =="Dialogo_Col_17" then
            dialog17 = true
            first = false


        elseif detect and first and current_scene_tag =="Dialogo_Col_18" then
            dialog18 = true
            first = false

        elseif detect and first and current_scene_tag =="Dialogo_Col_19" then
            dialog19 = true
            first = false
        end

         --Dialogo

        if openDialog then
        dialogScriptComponent.start_dialog(dialogLines12)
        openDialog = false
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
       
    elseif current_scene_name == "level3.TeaScene" then
        --Colider
        if detect and first and current_scene_tag =="Dialogo_Col_Find" then
            dialogFind = true
            first = false

        elseif detect and first and current_scene_tag =="Dialogo_Col_Change" then
            dialogChange = true
            first = false

        elseif detect and first and current_scene_tag =="Dialogo_Col_Die" then
            dialogDie = true
            first = false
        end

         --Dialogo


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


end

function on_exit()
    -- Add cleanup code here
end
