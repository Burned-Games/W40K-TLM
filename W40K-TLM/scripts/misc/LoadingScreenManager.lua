local fadeToBlackScript = nil
local textLoading = nil
local loadingGif = nil

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


local counterLoading = 0

function on_ready()
    -- Add initialization code here
    fadeToBlackScript = current_scene:get_entity_by_name("FadeToBlack"):get_component("ScriptComponent")
    textLoading = current_scene:get_entity_by_name("TextLoading"):get_component("UITextComponent")

    textLoading:set_text(tipTexts[textIndex])

    counterLoading = 0

end

function on_update(dt)


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
        SceneManager.change_scene("scenes/level3.TeaScene")
        changed = true
    end

end

function on_exit()
    -- Add cleanup code here
end
