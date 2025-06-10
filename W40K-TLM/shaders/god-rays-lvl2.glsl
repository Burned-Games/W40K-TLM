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
    vec3 color = vec3(1.0, 0.96, 0.49); // Default color
    float intensity = 1.0; // Default intensity

    // Vertical gradient in alpha using TexCoords.y (0 at bottom, 1 at top)
    float alpha = smoothstep(0.0,10.0, VertexInput.TexCoords.y);

    FragColor = vec4(color * intensity, alpha); // intensity only affects color, not alpha
    EntityID = vec4(entityID, 1.0f);
}
