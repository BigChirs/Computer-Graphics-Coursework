#version 330 core

# define maxLights 10

// Inputs
in vec2 UV;
in vec3 fragmentPosition;
in vec3 Normal;

// Outputs
out vec3 fragmentColour;

// Light struct
struct Light
{
    vec3 position;
    vec3 colour;
    float constant;
    float linear;
    float quadratic;
    int type;
};

// Uniforms
uniform sampler2D diffuseMap;
uniform float ka;
uniform float kd;
uniform float ks;
uniform float Ns;
uniform Light lightSources[maxLights];

// Function prototypes
vec3 pointLight(vec3 lightPosition, vec3 lightColour, float constant, float linear, float quadratic);

void main ()
{
    fragmentColour = vec3(0.0, 0.0, 0.0);
    for (int i = 0; i < maxLights; i++)
    {
        // Determine light properties for current light source
        vec3 lightPosition  = lightSources[i].position;
        vec3 lightColour    = lightSources[i].colour;
        float constant      = lightSources[i].constant;
        float linear        = lightSources[i].linear;
        float quadratic     = lightSources[i].quadratic;
        
        // Calculate point light
        if (lightSources[i].type == 1)
            fragmentColour += pointLight(lightPosition, lightColour, constant, linear, quadratic);
    }
}

// Calculate point light
vec3 pointLight(vec3 lightPosition, vec3 lightColour, float constant, float linear, float quadratic)
{
    // Object colour
    vec3 objectColour = vec3(texture(diffuseMap, UV));
    
    // Ambient reflection
    vec3 ambient = ka * objectColour;
    
    // Diffuse reflection
    vec3 light      = normalize(lightPosition - fragmentPosition);
    vec3 normal     = normalize(Normal);
    float cosTheta  = max(dot(normal, light), 0);
    vec3 diffuse    = kd * lightColour * objectColour * cosTheta;
    
    // Specular reflection
    vec3 reflection = - light + 2 * dot(light, normal) * normal;
    vec3 camera     = normalize(-fragmentPosition);
    float cosAlpha  = max(dot(camera, reflection), 0);
    vec3 specular   = ks * lightColour * pow(cosAlpha, Ns);
    
    // Attenuation
    float distance    = length(lightPosition - fragmentPosition);
    float attenuation = 1.0 / (constant + linear * distance +
                               quadratic * distance * distance);
    
    // Fragment colour
    return (ambient + diffuse + specular) * attenuation;
}
