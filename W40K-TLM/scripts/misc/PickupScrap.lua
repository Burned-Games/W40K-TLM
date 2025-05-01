--[[]]
local actualYRotation = 0
local transform;
local rotationSpeed = 100

local actualSize = Vector3.new(0, 0, 0)
local sizeSpeed = 1


local direction = true -- true = up, false = down
local offsetYPosition = 0
local initialYPosition = nil
local positionRangeOffset = 0.1
local positionSpeed = 3;


local time = 0
local frequency = 0.5
local amplitude = 0.1 

local onReadyDoned = false


function on_ready()
    -- Add initialization code here
    transform = self:get_component("TransformComponent")
    transform.rotation = Vector3.new(0, actualYRotation, 0)
    transform.scale = actualSize
    initialYPosition = transform.position.y

    onReadyDoned = true

end

function on_update(dt)--[[
    -- Add update code here


    if not onReadyDoned then
        on_ready()
    end


    actualYRotation = actualYRotation + (dt * rotationSpeed)
    transform.rotation = Vector3.new(0, actualYRotation, 0)

    if(actualSize.x < 1) then
        actualSize = lerp(actualSize, Vector3.new(1,1,1), dt * sizeSpeed)
        if(actualSize.x > 1) then
            actualSize = Vector3.new(1, 1, 1)
        end
        transform.scale = actualSize
    end

    time = time + dt
    offsetYPosition = math.sin(time * frequency * 2 * math.pi) * amplitude
    transform.position.y = initialYPosition + offsetYPosition]]

end

function on_exit()
    -- Add cleanup code here
end

function lerp(a, b, t)
    return a + (b - a) * t
end
