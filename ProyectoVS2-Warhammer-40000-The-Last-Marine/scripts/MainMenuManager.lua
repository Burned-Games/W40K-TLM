local opcion1
local opcion2
local opcion3
local opcion4

local index = 0;
local pressedButton = false
local contadorMovimientoBotones = 0

function on_ready()
    -- Add initialization code here
    opcion1 = current_scene:get_entity_by_name("opcion1"):get_component("UIImageComponent")
    opcion2 = current_scene:get_entity_by_name("opcion2"):get_component("UIImageComponent")
    opcion3 = current_scene:get_entity_by_name("opcion3"):get_component("UIImageComponent")
    opcion4 = current_scene:get_entity_by_name("opcion4"):get_component("UIImageComponent")
end

function on_update(dt)
    -- Add update code here

    if index == 0 then
        opcion1:set_visible(true);
        opcion2:set_visible(false);
        opcion3:set_visible(false);
        opcion4:set_visible(false);
    elseif index == 1 then
        opcion1:set_visible(false);
        opcion2:set_visible(true);
        opcion3:set_visible(false);
        opcion4:set_visible(false);
        
    elseif index == 2 then
        opcion1:set_visible(false);
        opcion2:set_visible(false);
        opcion3:set_visible(true);
        opcion4:set_visible(false);

    else
        opcion1:set_visible(false);
        opcion2:set_visible(false);
        opcion3:set_visible(false);
        opcion4:set_visible(true);
    end;



    local value = 0
    value = Input.get_axis(Input.action.UiMoveVertical)
    if (value ~= 0 and contadorMovimientoBotones > 0.2) then
        contadorMovimientoBotones = 0
        
        if value > 0 then
            index = index - 1;
            if index < 0 then
                index = 3
            end
        end
        
        if value < 0 then
            index = index + 1
            if index > 3 then
                index = 0
            end
        end
        
    else
        contadorMovimientoBotones = contadorMovimientoBotones + dt
    end


    value = Input.get_button(Input.action.Confirm)
    if(value == Input.state.Down) then
        if(index == 0)then
            print("Cambiar escena")
        end
    end




end

function on_exit()
    -- Add cleanup code here
end
