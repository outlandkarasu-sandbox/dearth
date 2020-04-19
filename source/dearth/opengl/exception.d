/**
OpenGL exception module.
*/
module dearth.opengl.exception;

import std.exception : basicExceptionCtors;
import std.traits : isCallable;

import bindbc.opengl :
    glGetError,
    GL_NO_ERROR,
    GL_INVALID_ENUM,
    GL_INVALID_VALUE,
    GL_INVALID_OPERATION,
    GL_INVALID_FRAMEBUFFER_OPERATION,
    GL_OUT_OF_MEMORY,
    GLenum;

/**
Exception for OpenGL errors.
*/
@safe
class OpenGLException : Exception
{
    ///
    mixin basicExceptionCtors;
}

/**
Enforce OpenGL result.

Params:
    F = calling function.
    file = file name.
    line = line no.
Throws:
    OpenGLException if failed.
*/
void enforceGL(alias F, string file = __FILE__, size_t line = __LINE__)() if (isCallable!F)
{
    F();
    immutable error = glGetError();
    if (error != GL_NO_ERROR)
    {
        throw new OpenGLException(glErrorToString(error), file, line);
    }
}

/**
OpenGL error code to string.

Params:
    error = OpenGL error code.
Returns:
    error code string.
*/
string glErrorToString(GLenum error) @nogc nothrow pure @safe
{
    switch(error)
    {
        case GL_NO_ERROR:
            return "GL_NO_ERROR";
        case GL_INVALID_ENUM:
            return "GL_INVALID_ENUM";
        case GL_INVALID_VALUE:
            return "GL_INVALID_VALUE";
        case GL_INVALID_OPERATION:
            return "GL_INVALID_OPERATION";
        case GL_INVALID_FRAMEBUFFER_OPERATION:
            return "GL_INVALID_FRAMEBUFFER_OPERATION";
        case GL_OUT_OF_MEMORY:
            return "GL_NO_ERROR";
        default:
            return "Unknown OpenGL error";
    }
}

