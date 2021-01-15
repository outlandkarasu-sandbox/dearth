#version 100

precision mediump float;

varying vec2 vUV;
uniform sampler2D textureSampler1;
uniform sampler2D textureSampler2;

void main()
{
    gl_FragColor = texture2D(textureSampler1, vUV);
}

