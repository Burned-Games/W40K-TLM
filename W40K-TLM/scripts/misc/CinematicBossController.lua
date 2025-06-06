local introBossDone = false

local player = nil
local playerAnimator = nil
local playerTransf = nil
local bossAnimator = nil
local cameraTransf = nil

local introPos = Vector3.new(0, 0, -70)
local outroPos = Vector3.new(0, 0, -95)
local cameraIntroPos, cameraIntroRot = Vector3.new(0.0, 1.6, -87.0), Vector3.new(5.0, 0.0, 0.0)
local cameraOutroPos, cameraOutroRot = Vector3.new(4.221, 0.422, -88.772), Vector3.new(5.681, 56.712, 0.0)

local bossCurrentAnim = -1
local bossIntroAnim = 5
local bossOutroAnim = 1

local contador = 0.0
local timeToTransition = 3.0
local changeing = false
local changeScene = false
local timer = 0.0

local fadeDuration = 1.0

local backpack = false
local helmet = false

-- Shake
local isShaking = false
local shakeAmount = 0
local shakeDuration = 0
local shakeDecay = 3
local shakeDelay = 0.3

-- Audio
local introBossSFX = nil
local outroBossSFX = nil
local hasIntroPlayed = false
local hasOutroPlayed = false

function on_ready()
    introBossDone = load_progress("introBossDone", introBossDone)

    -- Fade to Black
    fadeToBlackScript = current_scene:get_entity_by_name("FadeToBlack"):get_component("ScriptComponent")
    fadeToBlackScript.fadeToBlackTimer = fadeDuration

    -- Upgrades
    backpack = load_progress("armorHealthBoost", false)
    helmet = load_progress("armorProtection", false)

    -- Audio
    introBossSFX = current_scene:get_entity_by_name("IntroBossSFX"):get_component("AudioSourceComponent")
    outroBossSFX = current_scene:get_entity_by_name("OutroBossSFX"):get_component("AudioSourceComponent")

    -- Player
    player = current_scene:get_entity_by_name("Player")
    playerAnimator = player:get_component("AnimatorComponent")
    playerTransf = player:get_component("TransformComponent")
    playerAnimator:set_looping(false)
    local children = player:get_children()
    for _, child in ipairs(children) do
        if child:get_component("TagComponent").tag == "Jetpack_lv2_player" and backpack then
            child:set_active(true)
        elseif child:get_component("TagComponent").tag == "Casco_lvl_2_player" and helmet then
            child:set_active(true)
        end
    end

    -- Main Boss
    bossAnimator = current_scene:get_entity_by_name("MainBoss"):get_component("AnimatorComponent")
    bossAnimator:set_looping(false)

    -- Camera
    cameraTransf = current_scene:get_entity_by_name("Camera"):get_component("TransformComponent")

    if not introBossDone then
        playerTransf.position = introPos
        cameraTransf.position, cameraTransf.rotation = cameraIntroPos, cameraIntroRot

        shakeDelay = 0.3
        timeToTransition = 5.0
    else
        playerTransf.position = outroPos
        cameraTransf.position, cameraTransf.rotation = cameraOutroPos, cameraOutroRot
        timeToTransition = 3.0
    end
end

function on_update(dt)
    
    if not introBossDone then
        if bossCurrentAnim ~= bossIntroAnim then
            bossCurrentAnim = bossIntroAnim
            bossAnimator:set_current_animation(bossCurrentAnim)

            if not hasIntroPlayed then
                introBossSFX:play()
                hasIntroPlayed = true
            end
        end
    else
        if bossCurrentAnim ~= bossOutroAnim then
            bossCurrentAnim = bossOutroAnim
            bossAnimator:set_current_animation(bossCurrentAnim)

            if not hasOutroPlayed then
                outroBossSFX:play()
                hasOutroPlayed = true
            end
        end
    end

    timer = timer + dt
    if timer >= shakeDelay then
        if not isShaking then
            start_shake(0.05, 0.2)
            isShaking = true
        end
    end

    if shakeDuration > 0 then
        local shakeOffset = Vector3.new(
            (math.random() * 2 - 1) * shakeAmount,
            (math.random() * 2 - 1) * shakeAmount,
            (math.random() * 2 - 1) * shakeAmount
        )
        smoothPos = Vector3.new(cameraTransf.position.x + shakeOffset.x, cameraTransf.position.y + shakeOffset.y, cameraTransf.position.z + shakeOffset.z) 

        shakeDuration = shakeDuration - dt
        log(shakeDuration)
        cameraTransf.position = smoothPos
    end

    contador = contador + dt
    if  not changeing and contador > timeToTransition then
        changeing = true
        fadeToBlackScript:DoFade()
    end
 
    if changeing and not changeScene then
        if fadeToBlackScript.fadeToBlackDoned then
            changeScene = true

            if not introBossDone then
                SceneManager.change_scene("scenes/bossArena.TeaScene")
            else
                SceneManager.change_scene("scenes/credits.TeaScene")
            end
        end
    end
end

function start_shake(amount, duration)
    shakeAmount = amount
    shakeDuration = duration
end

function on_exit() end
