local velocidad = 50
local entidadCreditos
local posicionY = 0
local limiteSuperiorY = -1963
local fondo = nil
local fadeToBlackScript = nil

-- NUEVAS VARIABLES
local tiempoParaActivarFondo = 2.5
local temporizadorFondo = 0
local fondoActivado = false

function on_ready()
    entidadCreditos = current_scene:get_entity_by_name("CreditsImage")
    fadeToBlackScript = current_scene:get_entity_by_name("FadeToBlack"):get_component("ScriptComponent")
    fondo = current_scene:get_entity_by_name("CreditosFondoD")
    fondo:set_active(false)

    posicionY = 2500
    move_ui_element(entidadCreditos, 0, posicionY)
end

function on_update(dt)
    -- Activar fondo después de cierto tiempo
    if not fondoActivado then
        temporizadorFondo = temporizadorFondo + dt
        if temporizadorFondo >= tiempoParaActivarFondo then
            fondo:set_active(true)
            fondoActivado = true
        end
    end

    -- Mover créditos hacia arriba
    local desplazamiento = velocidad * dt
    posicionY = posicionY - desplazamiento
    move_ui_element(entidadCreditos, 0, -desplazamiento)

    if posicionY <= limiteSuperiorY then
        fadeToBlackScript:DoFade()
        SceneManager.change_scene("scenes/mainMenu.TeaScene")
    end
end
