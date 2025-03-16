local shotgun_shot
local shotgun_reload
local shotgun_firerate = 1.2

local shotgun_firerate_timer = 0

local grenade_launch
local grenade_explosion
local is_grenade_launch = false
local grenade_explosion_timer = 0
local grenade_explosion_delay = 1.5


function on_ready()
    local shotgun_shot_entity = current_scene:get_entity_by_name("ShotgunShot")
    shotgun_shot = shotgun_shot_entity:get_component("AudioSourceComponent")

    local shotgun_reload_entity = current_scene:get_entity_by_name("ShotgunReload")
    shotgun_reload = shotgun_reload_entity:get_component("AudioSourceComponent")

    local grenade_launch_entity = current_scene:get_entity_by_name("GrenadeLaunch")
    grenade_launch = grenade_launch_entity:get_component("AudioSourceComponent")

    local grenade_explosion_entity = current_scene:get_entity_by_name("GrenadeExplosion")
    grenade_explosion = grenade_explosion_entity:get_component("AudioSourceComponent")
end

function on_update(dt)
    shotgun_firerate_timer = shotgun_firerate_timer + dt

    grenade_explosion_timer = grenade_explosion_timer + dt

    if is_grenade_launch then
        if grenade_explosion_timer >= grenade_explosion_delay then
            grenade_explosion:pause()
            grenade_explosion:play()
            grenade_explosion_timer = 0 
            is_grenade_launch = false
        end
    end

    if shotgun_firerate_timer > shotgun_firerate then
        if Input.is_key_pressed(Input.keycode.F) then
            shotgun_firerate_timer = 0
            shotgun_reload:pause()
            shotgun_shot:pause()
            grenade_launch:pause()
            shotgun_shot:play()            
        end
        if Input.is_key_pressed(Input.keycode.G) then
            shotgun_firerate_timer = 0
            shotgun_reload:pause()
            shotgun_shot:pause()
            grenade_launch:pause()
            shotgun_reload:play()            
        end

        if Input.is_key_pressed(Input.keycode.H) then
            shotgun_firerate_timer = 0
            grenade_explosion_timer = 0
            is_grenade_launch = true
            shotgun_reload:pause()
            shotgun_shot:pause()
            grenade_launch:pause()
            grenade_launch:play()            
        end
    end
end

function on_exit()
    -- Add cleanup code here
end