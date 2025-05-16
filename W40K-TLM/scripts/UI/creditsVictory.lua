local velocidad = 50 
local entidadCreditos
local posicionY = 0
local limiteSuperiorY = 1000

function on_ready()
    entidadCreditos = self:get_component("UIImageComponent")
    posicionY = 600  
    move_ui_element(self, 0, posicionY)
end

function on_update(dt)

   
    local desplazamiento = velocidad * dt
    posicionY = desplazamiento +  posicionY

   
    move_ui_element(self, 0, -desplazamiento)

   
    --[[if posicionY > limiteSuperiorY then
        entidadCreditos:Destroy()
    end--]]
end

function on_exit()
    -- Cleanup opcional
end
