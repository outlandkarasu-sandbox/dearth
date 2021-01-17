#version 100

precision mediump float;

varying vec2 vUV;
varying float vPlane;

uniform sampler2D frontTexture;
uniform sampler2D leftTexture;
uniform sampler2D rightTexture;
uniform sampler2D backTexture;
uniform sampler2D topTexture;
uniform sampler2D bottomTexture;

vec4 getPlaneColor(sampler2D texture, float plane);

void main()
{
    gl_FragColor = getPlaneColor(frontTexture, 0.0);
    gl_FragColor += getPlaneColor(leftTexture, 1.0);
    gl_FragColor += getPlaneColor(rightTexture, 2.0);
    gl_FragColor += getPlaneColor(backTexture, 3.0);
    gl_FragColor += getPlaneColor(topTexture, 4.0);
    gl_FragColor += getPlaneColor(bottomTexture, 5.0);

/*
    if (vPlane == 0.0) {
        gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
    } else if (vPlane == 1.0) {
        gl_FragColor = vec4(0.0, 1.0, 0.0, 1.0);
    } else if (vPlane == 2.0) {
        gl_FragColor = vec4(0.0, 0.0, 1.0, 1.0);
    } else if (vPlane == 3.0) {
        gl_FragColor = vec4(1.0, 1.0, 0.0, 1.0);
    } else if (vPlane == 4.0) {
        gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
    } else if (vPlane == 5.0) {
        gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
    } else {
        discard;
    }
    */
}

vec4 getPlaneColor(sampler2D texture, float plane)
{
    if (plane == vPlane) {
        return texture2D(texture, vUV);
    }
    return vec4(0.0);
}

