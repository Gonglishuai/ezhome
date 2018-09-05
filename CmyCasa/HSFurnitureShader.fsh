precision highp float;

uniform sampler2D s_texture;
varying vec2 ftexCoord;

uniform float gamma;
uniform float strength;
uniform vec3 additionalColor;

vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
    
    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec4 gammaCorrect(vec4 pixel, float gamma)
{
    vec3 vertexHSV = rgb2hsv(pixel.xyz);
    vec3 gammaVertexHSV = vec3(vertexHSV.x, vertexHSV.y, pow(vertexHSV.z, gamma));
    return vec4(hsv2rgb(gammaVertexHSV.xyz), pixel.a);
}

void main()
{
    vec4 fragmentColor = texture2D(s_texture, ftexCoord);
    
    // Gamma correct only if Gamma is not 1.0 (No change for such value)
    if (gamma != 1.0)
        fragmentColor = gammaCorrect(fragmentColor, gamma);
    
    // Linearly blend the fragment color with the scene's color in case there
    // is no Alpha-cutoff
    if (fragmentColor.a > 0.6)
        fragmentColor = mix(fragmentColor, vec4(additionalColor, fragmentColor.a), strength);
    
    gl_FragColor = fragmentColor;
}