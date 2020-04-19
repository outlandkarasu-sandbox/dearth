/**
Shader module.
*/
module dearth.opengl.shader;

import std.exception : assumeUnique, enforce;
import std.typecons :
    RefCounted,
    RefCountedAutoInitialize;

import bindbc.opengl :
    GL_COMPILE_STATUS,
    GL_FALSE,
    GL_FRAGMENT_SHADER,
    GL_INFO_LOG_LENGTH,
    GL_VERTEX_SHADER,
    GLchar,
    GLenum,
    GLint,
    GLuint,
    glCompileShader,
    glCreateShader,
    glDeleteShader,
    glGetShaderInfoLog,
    glGetShaderiv,
    glShaderSource;

import dearth.opengl.exception :
    checkGLError,
    enforceGL,
    OpenGLException;

/**
OpenGL shader.

Params:
    shaderType = shader type.
*/
struct Shader(GLenum shaderType)
{
    static assert (shaderType == GL_VERTEX_SHADER || shaderType == GL_FRAGMENT_SHADER);

    @disable this();

private:

    this(string file = __FILE__, size_t line = __LINE__)(scope const(char)[] source) scope
    in (source.length < GLint.max)
    {
        // create shader.
        immutable id = glCreateShader(shaderType);
        checkGLError();
        enforce!OpenGLException(id != 0, "Cannot create shader");
        scope(failure) glDeleteShader(id);

        // compile shader.
        immutable length = cast(GLint) source.length;
        const sourcePointer = source.ptr;
        enforceGL!(() => glShaderSource(id, 1, &sourcePointer, &length));
        enforceGL!(() => glCompileShader(id));

        // get error log if failed.
        GLint status;
        glGetShaderiv(id, GL_COMPILE_STATUS, &status);
        if(status == GL_FALSE) {
            GLint logLength;
            glGetShaderiv(id, GL_INFO_LOG_LENGTH, &logLength);
            auto log = new GLchar[logLength];
            glGetShaderInfoLog(id, logLength, null, log.ptr);
            throw new OpenGLException(assumeUnique(log), file, line);
        }

        this.payload_ = Payload(id);
    }

    struct Payload
    {
        GLuint id;

        ~this() @nogc nothrow scope
        {
            glDeleteShader(id);
        }
    }

    RefCounted!(Payload, RefCountedAutoInitialize.no) payload_;
}

alias VertexShader = Shader!GL_VERTEX_SHADER;
alias FragmentShader = Shader!GL_FRAGMENT_SHADER;

/**
Create vertex shader.

Params:
    file = source file name.
    line = source line number.
    source = shader source.
Returns:
    vertex shader
*/
VertexShader createVertexShader(string file = __FILE__, size_t line = __LINE__)(scope const(char)[] source)
{
    return VertexShader(source);
}

/**
Create fragment shader.

Params:
    file = source file name.
    line = source line number.
    source = shader source.
Returns:
    fragment shader
*/
FragmentShader createFragmentShader(string file = __FILE__, size_t line = __LINE__)(scope const(char)[] source)
{
    return FragmentShader(source);
}

