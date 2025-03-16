local player_damage_one
local player_damage_two
local player_damage_three
local player_die_one
local player_die_two

local random_player_damage
local random_player_die

local timer = 0
local timer_count = 0.5


function on_ready()
    local player_damage_one_entity = current_scene:get_entity_by_name("PlayerDamage1")
    player_damage_one = player_damage_one_entity:get_component("AudioSourceComponent")

    local player_damage_two_entity = current_scene:get_entity_by_name("PlayerDamage2")
    player_damage_two = player_damage_two_entity:get_component("AudioSourceComponent")

    local player_damage_three_entity = current_scene:get_entity_by_name("PlayerDamage3")
    player_damage_three = player_damage_three_entity:get_component("AudioSourceComponent")

    local player_die_one_entity = current_scene:get_entity_by_name("PlayerDie1")
    player_die_one = player_die_one_entity:get_component("AudioSourceComponent")

    local player_die_two_entity = current_scene:get_entity_by_name("PlayerDie2")
    player_die_two = player_die_two_entity:get_component("AudioSourceComponent")
end

function on_update(dt)

    timer = timer + dt

    if Input.is_key_pressed(Input.keycode.T) and timer > timer_count then
        
        random_player_damage = math.random(1, 3)

        player_damage_one:pause()
        player_damage_two:pause()
        player_damage_three:pause()
        player_die_one:pause()
        player_die_two:pause()

        if random_player_damage == 1 then
            player_damage_one:play()
        elseif random_player_damage == 2 then
            player_damage_two:play()
        elseif random_player_damage == 3 then
            player_damage_three:play()
        end
        timer = 0
    end

    if Input.is_key_pressed(Input.keycode.Y) and timer > timer_count then

        random_player_die = math.random(1, 2)

        player_damage_one:pause()
        player_damage_two:pause()
        player_damage_three:pause()
        player_die_one:pause()
        player_die_two:pause()

        if random_player_die == 1 then
            player_die_one:play()
        elseif random_player_die == 2 then
            player_die_two:play()
        end
        timer = 0
    end

end

function on_exit()
    player_damage_one:pause()
    player_damage_two:pause()
    player_damage_three:pause()
    player_die_one:pause()
    player_die_two:pause()
end