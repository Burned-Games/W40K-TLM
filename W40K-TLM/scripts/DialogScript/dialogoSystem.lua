
--Dialogo 2

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

local isCineScene = false

function on_ready()

    current_scene_name = SceneManager:get_scene_name()
    current_scene_tag = self:get_component("TagComponent").tag

    if current_scene_name== "IntroCinematic.TeaScene" then
        isCineScene = true
    else
        isCineScene = false
    end

   
    dialogScriptComponent = current_scene:get_entity_by_name("DialogManager"):get_component("ScriptComponent")

    if isCineScene == false then
        mission_Component = current_scene:get_entity_by_name("MisionManager"):get_component("ScriptComponent")  
    end


    

    if current_scene_name == "level1.TeaScene" then


        --Dialogo
        dialogLines1 = {
            { name = "Decius Marcellus", text = "This is Decius Marcellus, Commander of Guilliman's Fist. Has anyone successfully made planetfall? Does anyone still live?",  time =3},
            { name = "Quintus Maxillian", text = "This is Brother Quintus Maxillian, Ultramarine of the 3rd Company. As far as I can tell, I am the only one left.", time = 3},
            { name = "Decius Marcellus", text = "It appears you are the sole survivor. Nonetheless, the mission stands. The Emperor protects, Brother.", time = 3}
        }
        
        dialogLines5L = {
            { name = "Decius Marcellus", text = "Brother Maxillian, a supply pod is en route to your position. Use it to upgrade your gear. May the Emperor's light guide your hand.", time = 3}
        }

        dialogLines5S = {
            { name = "Decius Marcellus", text = "We're detecting medical injectors nearby. Tend to your wounds with them before proceeding. The mission must not falter.", time = 3}
        }

        dialogLines8 = {
            { name = "Decius Marcellus", text = "Brother, the scanner reveals heavy Ork presence. One of them can protect others, be careful.", time = 3}
        }

        dialogLines9L = {
            { name = "Quintus Maxillian", text = "Commander Decius, I hear Orks nearby. Can you confirm their numbers?", time = 3},
            { name = "Decius Marcellus", text = "You are surrounded, Brother. Prepare for a brutal confrontation. The Emperor protects brother.", time = 3}
        }

        dialogLines9S = {
            { name = "Decius Marcellus", text = "Status report, are you still with us, Brother?", time = 3},
            { name = "Quintus Maxillian", text = "I remain unbroken. Still in one piece. Anything ahead I should be wary of?", time = 3},
            { name = "Decius Marcellus", text = "There is a brutal combat on the next door Brother. A big one will try to harrass you, be careful.", time = 3}
        }

        dialogLines10 = {
            { name = "Decius Marcellus", text = "That was a huge fight, brother. A supply pot should be in your way.", time = 3},
            { name = "Decius Marcellus", text = "Few enemies left. Go ahead brother, clean this place and proceed with the mission.", time = 3}
        }
    
    elseif current_scene_name == "level2.TeaScene" then
        --DialogoText
        dialogLines12 = {
            { name = "Decius Marcellus", text = "Welcome to Martyria Eterna brother. Find your way into the cathedral and finish Gorklaw to end this invasion.", time = 3}
        }
        
        dialogLines13 = {
            { name = "Decius Marcellus", text = "You've reached a sealed sector. Find a manual override, a lever or control panel. Time is not on our side, Brother.", time = 3}
        }

        dialogLines14 = {
            { name = "Decius Marcellus", text = "Purge all remaining hostiles in the area. Leave no greenskin standing. Martyria Eterna depends on your advance.", time = 3}
        }

        dialogLines15 = {
            { name = "Quintus Maxillian", text = "I've reached the Central Square of Martyria Eterna. I must explore the area. There has to be a way deeper into the city.", time = 3}
        }
        
        dialogLines16 = {
            { name = "Decius Marcellus", text = "Brother Maxillian, supply pod nearby. Upgrade your gear before advancing. The deeper you go, the deadlier it becomes.", time = 3}
        }
        dialogLines17 = {
            { name = "Decius Marcellus", text = "You're approaching the Great Bridge, but the access gate is sealed. Search the area for a lever. Force the passage open.", time = 3}
        }
        dialogLines18 = {
            { name = "Decius Marcellus", text = "Security protocols have raised the bridge gates. There must be manual overrides nearby. Activate and continue your advance.", time = 3}
        }
        
        dialogLines19 = {
            { name = "Decius Marcellus", text = "This is it, Brother. Upgrade your gear and tend to your wounds. The final confrontation awaits in the heart of Martyria Eterna.", time = 3}
        }
       
    elseif current_scene_name == "level3.TeaScene" then
        dialogLinesFind = {
            { name = "Decius Marcellus", text = "This is Gorklaw chamber, the old church of Martyria Eterna, end him brother. The Emperor protects brother.", time = 3}
        }

    elseif current_scene_name == "IntroCinematic.TeaScene" then
        dialogLinesCine = {
            { name = "Decius Marcellus", text = "Approaching Temperis, 1 minute until planetfall. Be ready for the landing, we detect multiple green skins lurking around.", audio = diaCine ,time = 3},
            { name = "Decius Marcellus", text = "The way to Martyria Eterna won't be easy. Good luck brother, the Emperor protects.", audio = diaCine ,time = 2.5}
        }
    end


    if isCineScene == false then
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

end

function on_update(dt)

    if isCineScene == false then
        if mission_Component.blueTaskIndex == 1 and firstCallDialogo then
            firstCallDialogo = false    
            isTimerStarted = true      
            timer = 0                  
        end
    else
        if firstCallDialogo then
            firstCallDialogo = false    
            isTimerStarted = true      
            timer = 0                  
        end
    end

    if isTimerStarted then
        timer = timer + dt        
        if timer >= 3 then          
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
        if detect and first and current_scene_tag =="dialogLinesFind" then
            dialogFind = true
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
    elseif current_scene_name == "IntroCinematic.TeaScene" then
       if openDialog then
            dialogScriptComponent.start_dialog(dialogLinesCine)
            openDialog = false
        end
    end


end

function on_exit()
    -- Add cleanup code here
end
