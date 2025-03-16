local footstep_one
local footstep_two
local footstep_three
local footstep_four

local footstep_timer = 0

local footstep_delay = 0.4

local randomFootstep


function on_ready()
    local footstep_one_entity = current_scene:get_entity_by_name("SandFootstep1")
    footstep_one = footstep_one_entity:get_component("AudioSourceComponent")

    local footstep_two_entity = current_scene:get_entity_by_name("SandFootstep2")
    footstep_two = footstep_two_entity:get_component("AudioSourceComponent")

    local footstep_three_entity = current_scene:get_entity_by_name("SandFootstep3")
    footstep_three = footstep_three_entity:get_component("AudioSourceComponent")

    local footstep_four_entity = current_scene:get_entity_by_name("SandFootstep4")
    footstep_four = footstep_four_entity:get_component("AudioSourceComponent")

end

function on_update(dt)
    footstep_timer = footstep_timer + dt

    if footstep_timer > footstep_delay then
        footstep_timer = 0

        randomNumber = math.random(1, 4)

        footstep_one:pause()
        footstep_two:pause()
        footstep_three:pause()
        footstep_four:pause()

        if randomNumber == 1 then
            footstep_one:play()
        
        elseif randomNumber == 2 then
            footstep_two:play()
        
        elseif randomNumber == 3 then
            footstep_three:play()
        
        elseif randomNumber == 4 then
            footstep_four:play()
        end
    end
end

function on_exit()
    -- Add cleanup code here
end
