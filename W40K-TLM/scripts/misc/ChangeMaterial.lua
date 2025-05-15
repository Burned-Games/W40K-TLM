
local originalMaterial = nil
local shaderMaterial = nil
local usingShaderMaterial = false


function on_ready()
    -- Add initialization code here
    originalMaterial = self:get_component("MaterialComponent").material
    local shader = load("/shaders/white.glsl")

    if not shader then
        print("Error: No se pudo cargar el shader")
        return
    end
    
    shaderMaterial = ShaderMaterial.new("WhiteMaterialShader")
    shaderMaterial.shader = shader

end

function on_update(dt)
    -- Add update code here
    if Input.is_key_pressed(Input.keycode.M) then
        toggle_material()
    end
end

function on_exit()
    -- Add cleanup code here
end

function toggle_material()
    local materialComp = self:get_component("MaterialComponent")
    
    if usingShaderMaterial then
        -- Cambiar al material original (PBR)
        materialComp.material = originalMaterial
        print("Cambiado a material PBR original")
    else
        -- Cambiar al ShaderMaterial
        materialComp.material = shaderMaterial
        print("Cambiado a ShaderMaterial")
    end
    
    usingShaderMaterial = not usingShaderMaterial
end
