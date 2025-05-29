local missionRigidBodyComponent = nil
local missionRigidBody = nil
local current_scene_tag = nil
local current_scene_name = nil

m4_Clear = false
function on_ready()
     --Mission
    mission_Component = current_scene:get_entity_by_name("MisionManager"):get_component("ScriptComponent")
    current_scene_tag = self:get_component("TagComponent").tag
    current_scene_name = SceneManager:get_scene_name()

    missionRigidBodyComponent = self:get_component("RigidbodyComponent")
    missionRigidBody = missionRigidBodyComponent.rb
    missionRigidBody:set_trigger(true)
    missionRigidBodyComponent:on_collision_enter(function(entityA, entityB)  
        local nameA = entityA:get_component("TagComponent").tag
        local nameB = entityB:get_component("TagComponent").tag   
    if nameA == "Player" or nameB == "Player" then

        if current_scene_name == "level1.TeaScene" then
            
           
            if current_scene_tag == "M56_Colider"then
                mission_Component.m6_heal = true
                mission_Component.m7_Defeate = true
            end

            if current_scene_tag == "M10_Colider"then
                mission_Component.m10_Upgrade = true
            end

            if current_scene_tag == "M11_Colider"then
                mission_Component.m11_NewZone = true
            end

            if current_scene_tag == "MR2_Colider"then
                mission_Component.mr2_orkzBase = true
            end

        elseif current_scene_name == "level2.TeaScene" then
            if current_scene_tag == "M3_Colider"then
                mission_Component.m3_throughCity = true
            end
            if current_scene_tag == "M4_Colider"then
                mission_Component.m4_exitCity = true
                mission_Component.mr1_Check = true
            end
            
        elseif current_scene_name == "level3.TeaScene" then
            print("Level 3")
        end

    end
    end)
    -- Add initialization code here
end

function on_update(dt)
    -- Add update code here
end

function on_exit()
    -- Add cleanup code here
end
