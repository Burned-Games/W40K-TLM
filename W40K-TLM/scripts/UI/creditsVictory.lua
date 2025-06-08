local velocidad = 100
local posicionY = 0
local limiteSuperiorY = -2517

local creditsMusic = nil

function on_ready()
    posicionY = 2600  
    move_ui_element(self, 0, posicionY)

    creditsMusic = current_scene:get_entity_by_name("CreditsMusic"):get_component("AudioSourceComponent")

    creditsMusic:play()
end

function on_update(dt)
   
    local velocidadActual = velocidad
    if Input.is_button_pressed(Input.action.Confirm) then
        velocidadActual = velocidad * 5
    end

    local desplazamiento = velocidadActual * dt
    posicionY = posicionY - desplazamiento
    move_ui_element(self, 0, -desplazamiento)

    if posicionY <= limiteSuperiorY then
        SceneManager.change_scene("scenes/mainMenu.TeaScene")
    end
end

function on_exit()
    -- Cleanup opcional
end
