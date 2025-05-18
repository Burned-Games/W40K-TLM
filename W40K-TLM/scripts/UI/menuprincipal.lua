local button1
local button2
local button3
local button4
local button5
local text1
local text2
local text3
local text4
local text5
local musicaFondoDefault
--local changeScene = false
local SettingsManager
local SettingsEntity
local BaseEntity
local OrderEntity
local LogoEntity
local LogoSalidaEntity
local Ajustes
local Credits

local botonAnimadoScript

ajustesOpened = false
local salidaImagen
local botonSalida1
local botonSalida2
local salidaImagenScript = nil
local mm = nil

saliendoDeMenu = false


local index = 0
local currentSelectedIndex = 0
local buttonCooldown = 0
local buttonCooldownTime = 0.2
local sceneChanged = false
local contadorMovimientoBotones = 0

local level = 1

local defaultColor = Vector4.new(130/255, 19/255, 7/255, 1.0)
local selectedColor = Vector4.new(1.0, 1.0, 1.0, 1.0)

local changingScene = 0
local fadeToBlackScript = nil

--Audio
local indexHoverSFX = nil
local indexSelectionSFX = nil
local introSFX = nil
local outroSFX = nil

local creditsPrefab = "prefabs/Credits.prefab"

function on_ready()
    -- Add initialization code here
    button1 = current_scene:get_entity_by_name("NuevoJuego"):get_component("UIButtonComponent")
    --text1 = current_scene:get_entity_by_name("NewGameText"):get_component("UITextComponent")

    button2 = current_scene:get_entity_by_name("Continuar"):get_component("UIButtonComponent")
    --text2 = current_scene:get_entity_by_name("ContinueText"):get_component("UITextComponent")

    button3 = current_scene:get_entity_by_name("Ajuste"):get_component("UIButtonComponent")
    --text3 = current_scene:get_entity_by_name("SettingsText"):get_component("UITextComponent")

    button4 = current_scene:get_entity_by_name("Crdts"):get_component("UIButtonComponent")
    --text4 = current_scene:get_entity_by_name("CreditsText"):get_component("UITextComponent")

    button5 = current_scene:get_entity_by_name("Salir"):get_component("UIButtonComponent")
    --text5 = current_scene:get_entity_by_name("ExitText"):get_component("UITextComponent")

    botonAnimadoScript = current_scene:get_entity_by_name("Base"):get_component("ScriptComponent")

    salidaImagen = current_scene:get_entity_by_name("Salida")
    salidaImagenScript = current_scene:get_entity_by_name("Salida"):get_component("ScriptComponent")

    BaseEntity = current_scene:get_entity_by_name("Base")
    OrderEntity = current_scene:get_entity_by_name("Order")
    LogoEntity = current_scene:get_entity_by_name("Logo")
    LogoSalidaEntity = current_scene:get_entity_by_name("LogoSalida")
    botonSalida1 = current_scene:get_entity_by_name("BotonSalidaNewGame")
    botonSalida2 = current_scene:get_entity_by_name("BotonSalidaContinue")

    mm = current_scene:get_entity_by_name("BaseManager")


    SettingsManager = current_scene:get_entity_by_name("SettingsManager"):get_component("ScriptComponent")
    SettingsEntity = current_scene:get_entity_by_name("SettingsManager")

    Ajustes = current_scene:get_entity_by_name("Settings")

    Credits = current_scene:get_entity_by_name("Credits")


    fadeToBlackScript = current_scene:get_entity_by_name("FadeToBlack"):get_component("ScriptComponent")

    --Audio
    indexHoverSFX = current_scene:get_entity_by_name("HoverButtonSFX"):get_component("AudioSourceComponent")
    indexSelectionSFX = current_scene:get_entity_by_name("PressButtonSFX"):get_component("AudioSourceComponent")
    introSFX = current_scene:get_entity_by_name("IntroSFX"):get_component("AudioSourceComponent")
    outroSFX = current_scene:get_entity_by_name("OutroSFX"):get_component("AudioSourceComponent")
    
    introSFX:play()

    local savedLevel = load_progress("level", -1)

    if savedLevel == -1 then
        print("No hay nivel guardado")
        --button2.interactable = false
        button2.state = State.Disabled
    end
end

function on_update(dt)
    -- Add update code here
    if index == 0 then
        
            button1.state = State.Hover
            button2.state = State.Normal
            button3.state = State.Normal
            button4.state = State.Normal
            button5.state = State.Normal

            value = Input.get_button(Input.action.Confirm)
            if((value == Input.state.Down and sceneChanged == false)) then
                outroSFX:play()
                if(index == 0) then
                    save_progress("level", 0)

                    save_progress("weaponsReloadReduction", false)
                    save_progress("weaponsDamageBoost", false)
                    save_progress("weaponsFireRateBoost", false)
                    save_progress("weaponsSpecialAbility", false)
                    save_progress("armorHealthBoost", false)
                    save_progress("armorProtection", false)
                    save_progress("armorSpecialAbility", false)

                    save_progress("scrap", 0)
                    save_progress("health", 250)
                    save_progress("stims", 2)

                    save_progress("bluemision",1)
                    save_progress("redmision",1)
                    
                    saliendoDeMenu = true
                    botonSalida1:set_active(true)
                    salidaImagen:set_active(true)
                    salidaImagenScript.on_ready()
                    SettingsEntity:set_active(false)
                    BaseEntity:set_active(false)
                    OrderEntity:set_active(false)
                    LogoEntity:set_active(false)
                    LogoSalidaEntity:set_active(true)

                    fadeToBlackScript:DoFade()

                    changingScene = 1
                    sceneChanged = true
                end
            end
        

    elseif index == 1 then
        button1.state = State.Normal
        button2.state = State.Hover
        button3.state = State.Normal
        button4.state = State.Normal
        button5.state = State.Normal

        value = Input.get_button(Input.action.Confirm)
        if((value == Input.state.Down and sceneChanged == false)) then
            outroSFX:play()
            if(index == 1) then
                botonSalida2:set_active(true)
                salidaImagen:set_active(true)
                SettingsEntity:set_active(false)
                BaseEntity:set_active(false)
                OrderEntity:set_active(false)
                LogoEntity:set_active(false)
                LogoSalidaEntity:set_active(true)

                fadeToBlackScript:DoFade()

                changingScene = 2
                sceneChanged = true
            end
        end
        
    elseif index == 2 then
        button1.state = State.Normal
        button2.state = State.Normal
        button3.state = State.Hover
        button4.state = State.Normal
        button5.state = State.Normal

        value = Input.get_button(Input.action.Confirm)
        if((value == Input.state.Down)) then
            indexSelectionSFX:play()
            if(index == 2) then
                ajustesOpened = true
            end
        end

    elseif index == 3 then
        button1.state = State.Normal
        button2.state = State.Normal
        button3.state = State.Normal
        button4.state = State.Hover
        button5.state = State.Normal

        value = Input.get_button(Input.action.Confirm)
        if((value == Input.state.Down and sceneChanged == false)) then
            indexSelectionSFX:play()
            if(index == 3) then
                salidaImagen:set_active(true)
                SettingsEntity:set_active(false)
                Credits:set_active(true)
                OrderEntity:set_active(false)
                LogoEntity:set_active(false)
                LogoSalidaEntity:set_active(true)
                BaseEntity:set_active(false)
                mm:set_active(false)

            end
        end

    else
        button1.state = State.Normal
        button2.state = State.Normal
        button3.state = State.Normal
        button4.state = State.Normal
        button5.state = State.Hover

        value = Input.get_button(Input.action.Confirm)
        if((value == Input.state.Down and sceneChanged == false)) then
            outroSFX:play()
            if(index == 4) then
                App.quit()
            end
        end
    end

    if ajustesOpened == false and botonAnimadoScript:is_animation_finished() then
        local value = Input.get_direction("UiY")
            if (value ~= 0 and contadorMovimientoBotones > 0.2) then
                contadorMovimientoBotones = 0
                
                if value < 0 then
                    index = index - 1;
                    if index < 0 then
                        index = 4
                    end
                end
                
                if value > 0 then
                    index = index + 1
                    if index > 4 then
                        index = 0
                    end
                end
                
            else
                contadorMovimientoBotones = contadorMovimientoBotones + dt
            end
        end
        if changingScene ~= 0 then
            if fadeToBlackScript.fadeToBlackDoned and not changeScene then
    
                if changingScene == 1 then
                    save_progress("zonePlayer", 0)
                    save_progress("level", 0)
                end
                SceneManager.change_scene("scenes/loading.TeaScene")
    
                changeScene = true
            end
        end
    
    if index ~= currentSelectedIndex then
        indexHoverSFX:play()
        currentSelectedIndex = index
    end

end

function on_exit()
    -- Add cleanup code here
end
