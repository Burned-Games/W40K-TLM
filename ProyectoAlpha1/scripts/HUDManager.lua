local maxAmmo = 30
local currentAmmo = maxAmmo
local maxHealth = 100
local currentHealth = maxHealth
local chatarraCount = 0

local skillCooldowns = {
    [Input.action.Skill1] = { current = 0, max = 3.0 },
    [Input.action.Skill2] = { current = 0, max = 5.0 },
    [Input.action.Skill3] = { current = 0, max = 10.0 }
}

local ammoTextComponent
local lifeTextComponent
local chatarraTextComponent
local skill1, skill2, skill3
local currentWeapon

function on_ready()
    ammoTextComponent = current_scene:get_entity_by_name("BalasRestantes"):get_component("UITextComponent")
    lifeTextComponent = current_scene:get_entity_by_name("VidaCantidad"):get_component("UITextComponent")
    chatarraTextComponent = current_scene:get_entity_by_name("ChatarraTexto"):get_component("UITextComponent")
    skill1 = current_scene:get_entity_by_name("Habilidad1"):get_component("UIImageComponent")
    skill2 = current_scene:get_entity_by_name("Habilidad2"):get_component("UIImageComponent")
    skill3 = current_scene:get_entity_by_name("Habilidad3"):get_component("UIImageComponent")
    currentWeapon = current_scene:get_entity_by_name("Arma"):get_component("UIImageComponent")
end

function on_update(dt)

    if(Input.action.Dash) then
        skill1.is_visible(false)
    end        
end

function on_exit()
    --Add Clean up code here
end