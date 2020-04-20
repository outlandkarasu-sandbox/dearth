/**
OpenGL initialize module.
*/
module dearth.opengl.initialize;

import std.exception : enforce;

import bindbc.opengl :
    GLSupport,
    loadOpenGL,
    unloadOpenGL;

import bindbc.opengl :
    glEnable,
    GL_DEPTH_TEST;

import dearth.opengl.exception : OpenGLException;

/**
During OpenGL library.

Params:
    dg = application delegate.
Throws:
    OpenGLException if failed.
*/
void duringOpenGL(scope void delegate(GLSupport) dg)
{
    immutable support = loadOpenGL();
    enforce!OpenGLException(support != GLSupport.noLibrary, "No library");
    enforce!OpenGLException(support != GLSupport.badLibrary, "Bad library");
    enforce!OpenGLException(support != GLSupport.noContext, "No context");

    scope(exit) unloadOpenGL();

    // enable OpenGL functions.
    glEnable(GL_DEPTH_TEST);

    dg(support);
}

