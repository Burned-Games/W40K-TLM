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

function on_ready()
    introBossDone = load_progress("introBossDone", introBossDone)

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
    else
        playerTransf.position = outroPos
        cameraTransf.position, cameraTransf.rotation = cameraOutroPos, cameraOutroRot
    end
end

function on_update(dt)
    
    if not introBossDone then
        if bossCurrentAnim ~= bossIntroAnim then
            bossCurrentAnim = bossIntroAnim
            bossAnimator:set_current_animation(bossCurrentAnim)
        end

        introBossDone = true
        save_progress("introBossDone", introBossDone)
    else
        if bossCurrentAnim ~= bossOutroAnim then
            bossCurrentAnim = bossOutroAnim
            bossAnimator:set_current_animation(bossCurrentAnim)
        end
    end

end

function on_exit() end
