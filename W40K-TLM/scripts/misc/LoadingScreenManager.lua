


-- loading timing
local loadingTime = 4


-- other things
local fadeToBlackScript = nil
local textLoading = nil


local changeScene = false
local changeing = false
local changed = false

local textIndex = 1
local maxTextIndex = 38
local tipTexts = {
"Upgrade on the drop pod supply to get stronger!",
"Chainsword heals for each enemy it hits!",
"Heal yourself by using a drop pod supply!",
"Use explosive barrels to damage groups of enemies!",
"Break scrap piles for lots of resources!",
"Dash with [B] to escape or gain space!",
"Swap weapons with [Y] when needed!",
"Armor upgrades can also change how you look!",
"Think before rushing into a fight!",
"Ultramarines follow the Codex better than anyone else.",
"Guilliman wrote the Codex Astartes to guide the chapters.",
"Each Ultramarine rank has a symbol in specific armor spots.",
"Black Templars do not follow the Codex but respect Ultramarines.",
"Fulgrim wounded Guilliman with a cursed sword.",
"Orks spread spores and grow from the ground.",
"Orks were made to fight in an ancient war.",
"Orks fight all the time, even among themselves.",
"Gork is brutal but cunning, Mork is cunning but brutal.",
"Ghazghkull spared Yarrick to keep fighting him later.",
"Guilliman was revived thanks to Cawl and the Aeldari.",
"Ultramarines nearly fell during the Battle of Macragge.",
"Titus resisted Chaos, but the Inquisition still doubted him.",
"Fulgrim nearly killed Guilliman with a daemon sword.",
"Ghazghkull is the most feared Ork warboss known.",
"Ghazghkull fought Yarrick in the War for Armageddon.",
"In the third war, Ghazghkull returned with a huge WAAAGH!",
"Ghazghkull wants war, not territory.",
"Orks existed before humans and fought Necrons and Eldar.",
"Ultramarines stopped a massive Ork WAAAGH! on Ichar IV.",
"Let the stars fall, I will free the galaxy or burn it. - Horus",
"War is hygiene for the galaxy. - Alpharius",
"I am wrath and death! - Lucius the Eternal",
"Blessed is the mind too small for doubt. - Mechanicus saying",
"Only in death does duty end. - Imperial saying",
"Sanguinius cast demons back to hell with his own hands.",
"I'm da hand of Gork and Mork, here to wake the boyz! - Ghazghkull",
"We stomp the galaxy flat, 'cause we was made to fight! - Ghazghkull",
"What doesn't kill me isn't trying hard enough. - Guilliman",
"No peace, only carnage and the gods laughter."
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
    if counterLoading >= loadingTime and not changeing then
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
