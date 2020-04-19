/**
Shader module.
*/
module dearth.opengl.shader;

import std.exception : assumeUnique, enforce;
import std.traits :
    isCallable;
import std.typecons :
    RefCounted,
    RefCountedAutoInitialize;

import bindbc.opengl :
    GL_COMPILE_STATUS,
    GL_FALSE,
    GL_FRAGMENT_SHADER,
    GL_INFO_LOG_LENGTH,
    GL_LINK_STATUS,
    GL_VERTEX_SHADER;
import bindbc.opengl :
    GLchar,
    GLenum,
    GLint,
    GLuint;
import bindbc.opengl :
    glAttachShader,
    glBindAttribLocation,
    glCompileShader,
    glCreateProgram,
    glCreateShader,
    glDeleteProgram,
    glDeleteShader,
    glDetachShader,
    glGetProgramInfoLog,
    glGetProgramiv,
    glGetShaderInfoLog,
    glGetShaderiv,
    glLinkProgram,
    glShaderSource,
    glUseProgram;

import dearth.opengl.exception :
    checkGLError,
    enforceGL,
    OpenGLException;
import dearth.opengl.vao :
    isVertexStruct,
    getVertexAttributeNames;

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

    this(string file, size_t line, scope const(char)[] source) scope
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
    compiled vertex shader.
Throws:
    OpenGLException if failed.
*/
VertexShader createVertexShader(string file = __FILE__, size_t line = __LINE__)(scope const(char)[] source)
{
    return VertexShader(file, line, source);
}

/**
Create fragment shader.

Params:
    file = source file name.
    line = source line number.
    source = shader source.
Returns:
    compiled fragment shader
Throws:
    OpenGLException if failed.
*/
FragmentShader createFragmentShader(string file = __FILE__, size_t line = __LINE__)(scope const(char)[] source)
{
    return FragmentShader(file, line, source);
}

/**
Shader program.

Params:
    T = vertex struct type.
*/
struct ShaderProgram(T)
{
    static assert (isVertexStruct!T);

    @disable this();

    /**
    During use program.

    Params:
        dg = delegate.
    */
    void duringUse(Dg)(scope Dg dg) scope
    in (dg)
    {
        static assert (isCallable!Dg);

        enforceGL!(() => glUseProgram(payload_.id));
        scope(exit) glUseProgram(0);

        dg();
    }

private:

    this(
        string file,
        size_t line,
        scope ref const(VertexShader) vertexShader,
        scope ref const(FragmentShader) fragmentShader) scope
    {
        // create program.
        immutable id = glCreateProgram();
        checkGLError();
        scope(failure) glDeleteProgram(id);

        // attach shaders.
        immutable vertexShaderId = vertexShader.payload_.id;
        enforceGL!(() => glAttachShader(id, vertexShaderId));
        scope(exit) glDetachShader(id, vertexShaderId);

        immutable fragmentShaderId = fragmentShader.payload_.id;
        enforceGL!(() => glAttachShader(id, fragmentShaderId));
        scope(exit) glDetachShader(id, fragmentShaderId);

        // bind vertex attributes.
        static foreach (i, name; getVertexAttributeNames!T)
        {
            enforceGL!(() => glBindAttribLocation(id, i, name.ptr));
        }

        // link program
        enforceGL!(() => glLinkProgram(id));

        // get error log if failed.
        GLint status;
        glGetProgramiv(id, GL_LINK_STATUS, &status);
        if(status == GL_FALSE) {
            GLint logLength;
            glGetProgramiv(id, GL_INFO_LOG_LENGTH, &logLength);
            auto log = new GLchar[logLength];
            glGetProgramInfoLog(id, logLength, null, log.ptr);
            throw new OpenGLException(assumeUnique(log), file, line);
        }

        this.payload_ = Payload(id);
    }

    struct Payload
    {
        GLuint id;

        ~this() @nogc nothrow scope
        {
            glDeleteProgram(id);
        }
    }

    RefCounted!(Payload, RefCountedAutoInitialize.no) payload_;
}

/**
Create shader program.

Params:
    T = vertex struct type.
    file = source file name.
    line = source line number.
    vertexShader = vertex shader.
    fragmentShader = fragment shader.
Returns:
    linked shader program.
Throws:
    OpenGLException if failed.
*/
ShaderProgram!T createProgram(T, string file = __FILE__, size_t line = __LINE__)(
    scope ref const(VertexShader) vertexShader,
    scope ref const(FragmentShader) fragmentShader)
{
    return ShaderProgram!T(file, line, vertexShader, fragmentShader);
}

