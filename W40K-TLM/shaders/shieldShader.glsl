#[vertex]

#version 450 core
layout (location = 0) in vec3 aPosition;
layout (location = 1) in vec2 aTexCoord;

layout (std140, binding = 0) uniform camera
{
    mat4 projection;
    mat4 view;
    vec3 cameraPos;
};

struct VertexData
{
    vec2 TexCoords;
    vec3 WorldPos;
    vec3 camPos;
    vec3 sphereCenter;
};

layout (location = 2) out VertexData Output;

uniform mat4 model;

void main()
{
    Output.TexCoords = aTexCoord;
    Output.WorldPos = vec3(model * vec4(aPosition, 1.0));
    Output.camPos = cameraPos;
    Output.sphereCenter = vec3(model[3]);

    gl_Position = projection * view * vec4(Output.WorldPos, 1.0);
}

#[fragment]

#version 450 core
layout(location = 0) out vec4 FragColor;
layout(location = 1) out vec4 EntityID;

uniform vec3 entityID;
uniform vec3 baseColor;
uniform vec3 fresnelColor;

struct VertexData
{
    vec2 TexCoords;
    vec3 WorldPos;
    vec3 camPos;
    vec3 sphereCenter;
};

layout (location = 2) in VertexData VertexInput;

void main()
{
    vec3 normal = normalize(VertexInput.WorldPos - VertexInput.sphereCenter);

    vec3 viewDir = normalize(VertexInput.camPos - VertexInput.WorldPos);

    float fresnel = pow(1.0 - max(dot(normal, viewDir), 0.0), 2.5);

    vec3 shieldColor = mix(baseColor, fresnelColor, fresnel);

    float alpha = 0.1 + fresnel * 0.8;

    FragColor = vec4(shieldColor, alpha);
    EntityID = vec4(entityID, 1.0f);
}