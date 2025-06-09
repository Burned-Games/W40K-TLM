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
uniform vec3 time; // Añadido para animar el noise

struct VertexData
{
    vec2 TexCoords;
    vec3 WorldPos;
    vec3 camPos;
    vec3 sphereCenter;
};

layout (location = 2) in VertexData VertexInput;

// --- Simplex/Perlin-like noise function (GLSL classic 3D noise) ---
float hash(vec3 p) {
    p = fract(p * 0.3183099 + vec3(0.1,0.1,0.1));
    p *= 17.0;
    return fract(p.x * p.y * p.z * (p.x + p.y + p.z));
}

float noise(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);
    // Trilinear interpolation
    float n000 = hash(i + vec3(0,0,0));
    float n001 = hash(i + vec3(0,0,1));
    float n010 = hash(i + vec3(0,1,0));
    float n011 = hash(i + vec3(0,1,1));
    float n100 = hash(i + vec3(1,0,0));
    float n101 = hash(i + vec3(1,0,1));
    float n110 = hash(i + vec3(1,1,0));
    float n111 = hash(i + vec3(1,1,1));
    vec3 u = f*f*(3.0-2.0*f);
    return mix(
        mix(mix(n000, n100, u.x), mix(n010, n110, u.x), u.y),
        mix(mix(n001, n101, u.x), mix(n011, n111, u.x), u.y),
        u.z);
}

void main()
{
    vec3 normal = normalize(VertexInput.WorldPos - VertexInput.sphereCenter);
    vec3 viewDir = normalize(VertexInput.camPos - VertexInput.WorldPos);

    vec3 baseColor = vec3(0.34, 0.0, 0.66);
    vec3 fresnelColor = vec3(0.17, 0.0, 0.33);

    float fresnel = pow(1.0 - max(dot(normal, viewDir), 0.0), 2.5);

    // --- Calcular tamaño de la esfera ---
    float sphereRadius = length(VertexInput.WorldPos - VertexInput.sphereCenter);

    // --- Noise escalado por tamaño y tiempo ---
    float scale = 2.0 + sphereRadius * 0.5; // Ajusta el 0.5 para controlar el efecto con el tamaño
    float n = noise(normal * scale + time.x * 0.5);

    // --- Cuando el fresnel (alpha) es alto, añadir más noise ---
    float extraNoise = 0.0;
    if (fresnel > 0.7) { // Ajusta el umbral según lo que quieras
        extraNoise = noise(normal * (scale * 2.0) + time.x);
    }

    // --- Mezclar el noise en el color y alpha ---
    vec3 shieldColor = mix(baseColor, fresnelColor, fresnel);
    shieldColor += 0.15 * n + 0.15 * extraNoise; // Ajusta la intensidad del noise

    float alpha = 0.1 + fresnel * 0.8;
    alpha += 0.2 * n + 0.2 * extraNoise; // Añadir noise al alpha

    FragColor = vec4(shieldColor, clamp(alpha, 0.0, 1.0));
    EntityID = vec4(entityID, 1.0f);
}