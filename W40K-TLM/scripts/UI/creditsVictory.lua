local velocidad = 100 
local entidadCreditos
local posicionY = 0
local limiteSuperiorY = -2517

function on_ready()
    entidadCreditos = self:get_component("UIImageComponent")
    posicionY = 2600  
    move_ui_element(self, 0, posicionY)
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
