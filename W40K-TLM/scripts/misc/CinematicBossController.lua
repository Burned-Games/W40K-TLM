local introBossDone = false

local playerAnimator = nil
local playerTransf = nil
local bossAnimator = nil
local cameraTransf = nil

local introPos = Vector3.new(0, 0, -70)
local outroPos = Vector3.new(0, 0, -95)
local cameraIntroPos, cameraIntroRot = Vector3.new(0.0, 1.6, -87.0), Vector3.new(5.0, 0.0, 0.0)
local cameraOutroPos, cameraOutroRot = Vector3.new(4.2, 0.7, -87.0), Vector3.new(0.0, 50.0, 0.0)

local bossCurrentAnim = -1
local bossIntroAnim = 5
local bossOutroAnim = 1

local contador = 0.0
local timeToTransition = 3.0
local changeing = false
local changeScene = false
local timer = 0.0

local fadeDuration = 1.0

-- Shake
local isShaking = false
local shakeAmount = 0
local shakeDuration = 0
local shakeDecay = 3
local shakeDelay = 0.3

function on_ready()
    introBossDone = load_progress("introBossDone", introBossDone)

    -- Fade to Black
    fadeToBlackScript = current_scene:get_entity_by_name("FadeToBlack"):get_component("ScriptComponent")
    fadeToBlackScript.fadeToBlackTimer = fadeDuration

    -- Player
    playerAnimator = current_scene:get_entity_by_name("Player"):get_component("AnimatorComponent")
    playerTransf = current_scene:get_entity_by_name("Player"):get_component("TransformComponent")
    playerAnimator:set_looping(false)

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
        end
    else
        if bossCurrentAnim ~= bossOutroAnim then
            bossCurrentAnim = bossOutroAnim
            bossAnimator:set_current_animation(bossCurrentAnim)
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
