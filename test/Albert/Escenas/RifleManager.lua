local burst_shot
local rifle_reload
local rifle_firerate = 0.8

local rifle_firerate_count = 0

function on_ready()
    local burst_shot_entity = current_scene:get_entity_by_name("BurstShot")
    burst_shot = burst_shot_entity:get_component("AudioSourceComponent")

    local rifle_reload_entity = current_scene:get_entity_by_name("RifleReload")
    rifle_reload = rifle_reload_entity:get_component("AudioSourceComponent")
end

function on_update(dt)

    rifle_firerate_count = rifle_firerate_count + dt
    if rifle_firerate_count > rifle_firerate then
        if Input.is_key_pressed(Input.keycode.C) then
            rifle_firerate_count = 0
            rifle_reload:pause()
            burst_shot:pause()
            burst_shot:play()            
        end
        if Input.is_key_pressed(Input.keycode.V) then
            rifle_firerate_count = 0
            burst_shot:pause()
            rifle_reload:pause()
            rifle_reload:play()
        end
    end
end

function on_exit()
    -- Add cleanup code here
end