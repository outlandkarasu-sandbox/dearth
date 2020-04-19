/**
OpenGL vertex array object module.
*/
module dearth.opengl.vao;

import std.traits :
    FieldNameTuple,
    Fields,
    hasUDA,
    isCallable,
    isScalarType;
import std.typecons :
    RefCounted,
    RefCountedAutoInitialize;

import bindbc.opengl :
    GLuint,
    GLushort,
    GLvoid;
import bindbc.opengl :
    GL_ARRAY_BUFFER,
    GL_BYTE,
    GL_DYNAMIC_DRAW,
    GL_ELEMENT_ARRAY_BUFFER,
    GL_FALSE,
    GL_FLOAT,
    GL_SHORT,
    GL_TRUE,
    GL_UNSIGNED_BYTE,
    GL_UNSIGNED_SHORT;
import bindbc.opengl :
    glBindBuffer,
    glBindVertexArray,
    glBufferData,
    glDeleteBuffers,
    glDeleteVertexArrays,
    glEnableVertexAttribArray,
    glGenBuffers,
    glGenVertexArrays,
    glVertexAttribPointer;

import dearth.opengl.exception : enforceGL;

/**
True if T can use vertex struct.

Params:
    T = target type.
*/
enum isVertexStruct(T) = is(T == struct) && __traits(isPOD, T);

///
@nogc nothrow pure @safe unittest
{
    struct Vertex
    {
        float[4] position;
        ubyte[3] color;
    }

    struct NonVertex
    {
        float[4] position;
        ~this() {}
    }

    static assert( isVertexStruct!Vertex);
    static assert(!isVertexStruct!NonVertex);
}

/**
Get vertex attribute names.

Params:
    T = vertex struct type.
*/
template getVertexAttributeNames(T)
{
    static assert(isVertexStruct!T);

    alias getVertexAttributeNames = FieldNameTuple!T;
}

/**
Vertex array object.

Params:
    T = vertex structure type.
*/
struct VertexArrayObject(T)
{
    static assert(isVertexStruct!T);

    @disable this();

    /**
    During bind VAO.

    Params:
        Dg = delegate type.
        dg = delegate.
    */
    void duringBind(Dg)(scope Dg dg) scope
    in (dg)
    {
        static assert(isCallable!Dg);

        enforceGL!(() => glBindVertexArray(payload_.vaoID));
        scope(exit) glBindVertexArray(0);

        dg();
    }

    void loadVertices(scope const(T)[] vertices) scope
    {
        enforceGL!(() => glBindBuffer(GL_ARRAY_BUFFER, payload_.verticesID));
        scope(exit) glBindBuffer(GL_ARRAY_BUFFER, 0);
        enforceGL!(() => glBufferData(GL_ARRAY_BUFFER, vertices.length * T.sizeof, vertices.ptr, GL_DYNAMIC_DRAW));
    }

    void loadIndices(scope const(ushort)[] indices) scope
    {
        enforceGL!(() => glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, payload_.indicesID));
        scope(exit) glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
        enforceGL!(() => glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices.length * GLushort.sizeof, indices.ptr, GL_DYNAMIC_DRAW));
    }

private:

    this(GLuint verticesID, GLuint indicesID, GLuint vaoID) scope
    in (verticesID)
    in (indicesID)
    in (vaoID)
    {
        enforceGL!(() => glBindVertexArray(vaoID));
        scope(exit) glBindVertexArray(0);

        enforceGL!(() => glBindBuffer(GL_ARRAY_BUFFER, verticesID));
        scope(exit) glBindBuffer(GL_ARRAY_BUFFER, 0);

        static foreach (i, name; getVertexAttributeNames!T)
        {
            enforceGL!(() {
                alias FieldType = Fields!(T)[i];
                immutable size = getFieldSize!FieldType;
                immutable type = getGLType!FieldType;
                immutable normalized = hasUDA!(mixin("T." ~ name), VertexAttribute.normalized) ? GL_TRUE : GL_FALSE;
                auto offset = cast(const(GLvoid)*) mixin("T." ~ name ~ ".offsetof");
                glVertexAttribPointer(i, size, type, normalized, T.sizeof, offset);
            });

            enforceGL!(() => glEnableVertexAttribArray(i));
        }

        this.payload_ = Payload(verticesID, indicesID, vaoID);
    }

    struct Payload
    {
        GLuint verticesID;
        GLuint indicesID;
        GLuint vaoID;

        ~this() @nogc nothrow scope
        {
            glDeleteVertexArrays(1, &vaoID);

            GLuint[2] buffers = [verticesID, indicesID];
            glDeleteBuffers(2, buffers.ptr);
        }
    }

    RefCounted!(Payload, RefCountedAutoInitialize.no) payload_;
}

VertexArrayObject!T createVAO(T)()
{
    GLuint[2] buffers;
    enforceGL!(() => glGenBuffers(2, buffers.ptr));
    scope(failure) glDeleteBuffers(2, buffers.ptr);

    GLuint vaoID;
    enforceGL!(() => glGenVertexArrays(1, &vaoID));
    scope(failure) glDeleteVertexArrays(1, &vaoID);

    return VertexArrayObject!T(buffers[0], buffers[1], vaoID);
}

/**
Vertex attribute flag for struct field.
*/
enum VertexAttribute
{
    /**
    Normalized field.
    */
    normalized
}

private:

/**
Type to OpenGL type.
*/
template getGLType(T)
{
    static if (is(T == byte))
    {
        enum getGLType = GL_BYTE;
    }
    else static if (is(T == ubyte))
    {
        enum getGLType = GL_UNSIGNED_BYTE;
    }
    else static if (is(T == short))
    {
        enum getGLType = GL_SHORT;
    }
    else static if (is(T == ushort))
    {
        enum getGLType = GL_UNSIGNED_SHORT;
    }
    else static if (is(T == float))
    {
        enum getGLType = GL_FLOAT;
    }
    else static if (is(T E : E[len], int len))
    {
        enum getGLType = getGLType!E;
    }
    else
    {
        static assert(false, "Cannot get OpenGL type:" ~ T.stringof);
    }
}

///
@nogc nothrow pure @safe unittest
{
    static assert(getGLType!byte == GL_BYTE);
    static assert(getGLType!ubyte == GL_UNSIGNED_BYTE);
    static assert(getGLType!short == GL_SHORT);
    static assert(getGLType!ushort == GL_UNSIGNED_SHORT);
    static assert(getGLType!float == GL_FLOAT);
}

/**
Get field size.
*/
template getFieldSize(T)
{
    static if (isScalarType!T)
    {
        enum getFieldSize = 1;
    }
    else static if (is(T E : E[len], uint len))
    {
        enum getFieldSize = len;
    }
    else
    {
        static assert(false, "Cannot get field size:" ~ T.stringof);
    }
}

///
@nogc nothrow pure @safe unittest
{
    static assert (getFieldSize!ubyte== 1);
    static assert (getFieldSize!(ubyte[1]) == 1);
    static assert (getFieldSize!byte== 1);
    static assert (getFieldSize!(byte[2]) == 2);
    static assert (getFieldSize!short == 1);
    static assert (getFieldSize!(short[3]) == 3);
    static assert (getFieldSize!ushort == 1);
    static assert (getFieldSize!(ushort[4]) == 4);
    static assert (getFieldSize!float == 1);
    static assert (getFieldSize!(float[4]) == 4);
}

