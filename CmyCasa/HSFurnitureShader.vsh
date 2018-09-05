attribute vec3 position;
attribute vec2 texCoord;
uniform mat4 modelViewProjectionMatrix;
varying vec2 ftexCoord;

uniform float gamma;
uniform float strength;
uniform vec3 additionalColor;

void main()
{
    ftexCoord = texCoord;
    gl_Position = modelViewProjectionMatrix * vec4(position, 1.0);
}