local fadeToBlackScript = nil
local textLoading = nil


local changeScene = false
local changeing = false
local changed = false

local textIndex = 1
local maxTextIndex = 5
local tipTexts = {
     "Find the drop pod supply",
     "Break out of the orkz base to the Hive City",
     "Boomboclat",
     "Rima con el 13",
     "Benito se apellida camela",
     "Producer juega mal al padel"
}


local loadingGif = nil
local spriteWidth = 50
local spriteHeight = 15
local sheetWidth = 200
local sheetHeight = 90
local horizontalSprites = sheetWidth / spriteWidth
local verticalSprites = sheetHeight / spriteHeight

local animationTime = 0
local speed = 1/24
local rect = nil


local counterLoading = 0

local levelToLoad = -1

function on_ready()
    -- Add initialization code here
    fadeToBlackScript = current_scene:get_entity_by_name("FadeToBlack"):get_component("ScriptComponent")
    textLoading = current_scene:get_entity_by_name("TextLoading"):get_component("UITextComponent")

    textLoading:set_text(tipTexts[textIndex])

    counterLoading = 0

    loadingGif = current_scene:get_entity_by_name("LoadingGif"):get_component("UIImageComponent")
    rect = Vector4.new(0, 0, spriteWidth / sheetWidth, spriteHeight / sheetHeight)
    loadingGif:set_rect(rect)


    levelToLoad = load_progress("level", 1)


end

function on_update(dt)

    handle_loading_gif(dt)

    counterLoading = counterLoading + dt
    if counterLoading >= 6 and not changeing then
        changeing = true
        fadeToBlackScript:DoFade()
    end


    -- Add update code here
    if Input.get_button(Input.action.Confirm) == Input.state.Down then
        textIndex = textIndex + 1
        if(textIndex >= maxTextIndex) then
            textIndex = 1
        end
        textLoading:set_text(tipTexts[textIndex])
    end 

    if(changeing)then
        if fadeToBlackScript.fadeToBlackDoned then
            changeScene = true
            
        end
    end


    if changeScene == true and not changed then
        if levelToLoad == 0 then
            save_progress("level", 1)
            SceneManager.change_scene("scenes/IntroCinematic.TeaScene")
        elseif levelToLoad == 1 then
            SceneManager.change_scene("scenes/level1.TeaScene")
        elseif levelToLoad == 2 then
            SceneManager.change_scene("scenes/level2.TeaScene")
        elseif levelToLoad == 3 then
            SceneManager.change_scene("scenes/level3.TeaScene")
        else
            SceneManager.change_scene("scenes/level1.TeaScene")
        end
        changed = true
    end

end


function handle_loading_gif(dt)
    animationTime = animationTime + dt
    local totalSprites = 20
    local spriteIndex = math.floor(animationTime / speed)

    if spriteIndex >= totalSprites then
        animationTime = 0
        spriteIndex = 1
    end

    local horizontalIndex = spriteIndex % horizontalSprites
    local verticalIndex = math.floor(spriteIndex / horizontalSprites)

    rect.x = horizontalIndex * (spriteWidth / sheetWidth)
    rect.y = (verticalSprites - 1 - verticalIndex) * (spriteHeight / sheetHeight)

    loadingGif:set_rect(rect)

end


function on_exit()
    -- Add cleanup code here
end
