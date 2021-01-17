#version 100

attribute vec3 position;
attribute vec2 uv;
attribute float plane;

uniform mat4 modelMatrix;
uniform mat4 viewMatrix;
uniform mat4 projectionMatrix;

varying vec2 vUV;
varying float vPlane;

void main()
{
    gl_Position = projectionMatrix * viewMatrix * modelMatrix * vec4(position, 1.0);
    vUV = uv;
    vPlane = plane;
}

