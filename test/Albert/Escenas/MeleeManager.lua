local melee_idle
local melee_attack_one
local melee_attack_two
local melee_attack_three

local random_melee_attack
local melee_attack_delay = 1.5 
local melee_attack_timer = 0  
local melee_equipped = false 

function on_ready()
    local melee_idle_entity = current_scene:get_entity_by_name("MeleeIdle")
    melee_idle = melee_idle_entity:get_component("AudioSourceComponent")

    local melee_attack_one_entity = current_scene:get_entity_by_name("MeleeAttack1")
    melee_attack_one = melee_attack_one_entity:get_component("AudioSourceComponent")

    local melee_attack_two_entity = current_scene:get_entity_by_name("MeleeAttack2")
    melee_attack_two = melee_attack_two_entity:get_component("AudioSourceComponent")

    local melee_attack_three_entity = current_scene:get_entity_by_name("MeleeAttack3")
    melee_attack_three = melee_attack_three_entity:get_component("AudioSourceComponent")
end

function on_update(dt)
    melee_attack_timer = melee_attack_timer + dt

    if Input.is_key_pressed(Input.keycode.J) then
        if not melee_equipped then  
            melee_equipped = true
            melee_idle:pause()
            melee_idle:play()
            melee_attack_timer = 0  
        else
            melee_equipped = false
            melee_idle:pause()
            melee_attack_one:pause()
            melee_attack_two:pause()
            melee_attack_three:pause()
        end
    end

    if melee_equipped and melee_attack_timer > melee_attack_delay then
        if Input.is_key_pressed(Input.keycode.K) then

            random_melee_attack = math.random(1, 3)

            melee_attack_one:pause()
            melee_attack_two:pause()
            melee_attack_three:pause()
            melee_idle:pause()
            melee_idle:play()

            if random_melee_attack == 1 then
                melee_attack_one:play()
            elseif random_melee_attack == 2 then
                melee_attack_two:play()
            elseif random_melee_attack == 3 then
                melee_attack_three:play()
            end

            melee_attack_timer = 0
        end
    end
end

function on_exit()
    melee_idle:pause()
    melee_attack_one:pause()
    melee_attack_two:pause()
    melee_attack_three:pause()
end
