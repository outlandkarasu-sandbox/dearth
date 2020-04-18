/**
OpenGL initialize module.
*/
module dearth.opengl.initialize;

import std.exception : enforce;

import bindbc.opengl :
    GLSupport,
    loadOpenGL,
    unloadOpenGL;

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
    switch (support)
    {
        case GLSupport.noLibrary:
            throw new OpenGLException("No library");
        case GLSupport.badLibrary:
            throw new OpenGLException("Bad library");
        case GLSupport.noContext:
            throw new OpenGLException("No context");
        default:
            break;
    }

    scope(exit) unloadOpenGL();

    dg(support);
}

