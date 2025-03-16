local fighting_music
local exploring_music
local exploring_active = true

function on_ready()
    local fighting_music_entity = current_scene:get_entity_by_name("FightingMusic")
    fighting_music = fighting_music_entity:get_component("AudioSourceComponent")

    local exploring_music_entity = current_scene:get_entity_by_name("ExploringMusic")
    exploring_music = exploring_music_entity:get_component("AudioSourceComponent")

    exploring_music:play()
end

function on_update(dt)
    if Input.is_key_pressed(Input.keycode.N) then
        exploring_active = not exploring_active
        if exploring_active then
            --fighting_music:pause()
            exploring_music:pause()
            fighting_music:play()
        else
            --exploring_music:pause()
            fighting_music:pause()
            exploring_music:play()
        end
    end
end

function on_exit()
    exploring_music:pause()
    fighting_music:pause()
end