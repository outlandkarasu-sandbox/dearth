#version 100

precision mediump float;

varying vec2 vUV;
varying float vPlane;

void main()
{
    if (vPlane == 0.0) {
        gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
    } else if (vPlane == 1.0) {
        gl_FragColor = vec4(0.0, 1.0, 0.0, 1.0);
    } else if (vPlane == 2.0) {
        gl_FragColor = vec4(0.0, 0.0, 1.0, 1.0);
    } else if (vPlane == 3.0) {
        gl_FragColor = vec4(1.0, 1.0, 0.0, 1.0);
    } else if (vPlane == 4.0) {
        gl_FragColor = vec4(1.0, 0.0, 1.0, 1.0);
    } else if (vPlane == 5.0) {
        gl_FragColor = vec4(0.0, 1.0, 1.0, 1.0);
    } else {
        gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
    }
}

