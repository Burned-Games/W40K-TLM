-- UI components
local popupNormal = nil
local popupBoss = nil

-- Animation state for popup image
local popupIsActive = false
local popupTimer = 0.0
local popupState = "idle" -- "enter", "hold", "exit"
local popupDuration = 2.0 -- seconds hold

local popupYStart = -200
local popupYTarget = -200
local popupYExit = -400
local popupSpeed = 4.0 -- higher = faster

local useBossImage = false

-- Text component and its animation variables
local popupText = nil
local popupTextYStart = -400     -- Text initial position (off-screen)
local popupTextYTarget = -185    -- Text target position when popup is open
local popupTextYExit = -400      -- Text exit position

local actualAlpha = 0

-- Initialization
function on_ready()
    -- 获取 UI 组件
    popupNormal = current_scene:get_entity_by_name("PopupNewZoneIMG"):get_component("UIImageComponent")
    popupBoss = current_scene:get_entity_by_name("PopUpBossZoneIMG"):get_component("UIImageComponent") -- 注意拼写！
    popupText = current_scene:get_entity_by_name("PopUpText"):get_component("UITextComponent")

    -- 初始化为透明
    set_popup_alpha_Start(0)
end

-- 每帧更新
function on_update(dt)
    if popupIsActive then
        update_popup(dt)
    end

    if Input.is_key_pressed(Input.keycode.R) then
        show_popup(false, "ssssssw")
    end
end

-- 显示弹窗：isBoss 表示是否是Boss区域，message 是显示的文字
function show_popup(isBoss, message)
    popupIsActive = true
    popupState = "enter"
    popupTimer = 0.0
    useBossImage = isBoss

    actualAlpha = 0

    if popupText then
        popupText:set_text(message or " ")
    end
end

-- 每帧调用：控制动画状态机
function update_popup(dt)
    local currentPopup = useBossImage and popupBoss or popupNormal

    if popupState == "enter" then
        actualAlpha = lerp(actualAlpha, 1.0, dt * popupSpeed)
        set_popup_alpha(actualAlpha)

        if math.abs(actualAlpha - 1.0) < 0.01 then
            actualAlpha = 1.0
            set_popup_alpha(actualAlpha)
            popupState = "hold"
            popupTimer = 0.0
        end

    elseif popupState == "hold" then
        popupTimer = popupTimer + dt
        if popupTimer >= popupDuration then
            popupState = "exit"
        end

    elseif popupState == "exit" then
        actualAlpha = lerp(actualAlpha, 0.0, dt * popupSpeed)
        set_popup_alpha(actualAlpha)

        if actualAlpha < 0.01 then
            actualAlpha = 0.0
            set_popup_alpha(actualAlpha)
            popupState = "idle"
            popupIsActive = false
        end
    end
end

-- 辅助函数：设置三个组件的透明度
function set_popup_alpha(alpha)
    if useBossImage then
        if popupBoss then popupBoss:set_color(Vector4.new(1, 1, 1, alpha)) end
    else
        if popupNormal then popupNormal:set_color(Vector4.new(1, 1, 1, alpha)) end
    end
    if popupText then popupText:set_color(Vector4.new(1, 1, 1, alpha)) end
end

function set_popup_alpha_Start(alpha)
 
    if popupBoss then popupBoss:set_color(Vector4.new(1, 1, 1, alpha)) end
    if popupNormal then popupNormal:set_color(Vector4.new(1, 1, 1, alpha)) end
    if popupText then popupText:set_color(Vector4.new(1, 1, 1, alpha)) end
end

-- 线性插值函数
function lerp(a, b, t)
    return a + (b - a) * t
end
