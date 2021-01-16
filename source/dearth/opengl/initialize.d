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
    glCullFace,
    glEnable,
    glFrontFace,
    glPixelStorei,
    GL_CCW,
    GL_CULL_FACE,
    GL_DEPTH_TEST,
    GL_BACK,
    GL_UNPACK_ALIGNMENT;

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
    glEnable(GL_CULL_FACE);
    glCullFace(GL_BACK);
    glFrontFace(GL_CCW);

    // setting up texture pixel store alignment.
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);

    dg(support);
}

