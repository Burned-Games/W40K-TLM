local velocidad = 250 
local entidadCreditos
local posicionY = 0
local limiteSuperiorY = -1100
local base = nil
local creditos = nil
local baseScript = nil
local logoEntrada = nil
local logoScript = nil
local salidaImagen = nil
local mm = nil
local mmscript = nil

function on_ready()
    entidadCreditos = current_scene:get_entity_by_name("CreditsImage")
    creditos = current_scene:get_entity_by_name("Credits")
    base = current_scene:get_entity_by_name("Base")
    logoEntrada = current_scene:get_entity_by_name("Logo")
    baseScript = current_scene:get_entity_by_name("Base"):get_component("ScriptComponent")
    mm = current_scene:get_entity_by_name("BaseManager")
    mmscript = current_scene:get_entity_by_name("BaseManager"):get_component("ScriptComponent")
    logoScript = current_scene:get_entity_by_name("Logo"):get_component("ScriptComponent")
    salidaImagen = current_scene:get_entity_by_name("Salida")
    salidaImagen:set_active(false)
    posicionY = 1200  
    move_ui_element(entidadCreditos, 0, posicionY)
end

function on_update(dt)

   
    local desplazamiento = velocidad * dt
    posicionY = posicionY - desplazamiento

   
    move_ui_element(entidadCreditos, 0, -desplazamiento)

   
    if posicionY <= limiteSuperiorY then
        baseScript.animationTime = 0
        baseScript.currentPhase = "entry"
        baseScript.animationFinished = false
        baseScript.delayTimer = 0
        base:set_active(true)
        logoEntrada:set_active(true)
        logoScript.on_ready()
        mm:set_active(true)
        mmscript.on_ready()
        creditos:set_active(false)
        
    end
end

function on_exit()
    -- Cleanup opcional
end
