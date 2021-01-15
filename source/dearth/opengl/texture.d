/**
OpenGL texture module.
*/
module dearth.opengl.texture;

import std.typecons :
    RefCounted,
    RefCountedAutoInitialize;
import std.traits:
    isCallable;

import bindbc.opengl :
    GL_CLAMP_TO_EDGE,
    GL_LINEAR,
    GL_LINEAR_MIPMAP_LINEAR,
    GL_LINEAR_MIPMAP_NEAREST,
    GL_MIRRORED_REPEAT,
    GL_NEAREST,
    GL_NEAREST_MIPMAP_LINEAR,
    GL_NEAREST_MIPMAP_NEAREST,
    GL_REPEAT,
    GL_RGBA,
    GL_TEXTURE_2D,
    GL_TEXTURE_CUBE_MAP,
    GL_TEXTURE_MIN_FILTER,
    GL_TEXTURE_MAG_FILTER,
    GL_TEXTURE_WRAP_S,
    GL_TEXTURE_WRAP_T,
    GL_TEXTURE0,
    GL_UNSIGNED_BYTE,
    glActiveTexture,
    glBindTexture,
    glDeleteTextures,
    glGenTextures,
    glTexImage2D,
    glTexParameteri,
    GLuint;

import dearth.opengl.exception : enforceGL;

enum TextureType
{
    texture2D = GL_TEXTURE_2D,
    cubeMap = GL_TEXTURE_CUBE_MAP,
}

enum TextureMinFilter
{
    nearest = GL_NEAREST,
    linear = GL_LINEAR,
    nearestMipmapNearest = GL_NEAREST_MIPMAP_NEAREST,
    linearMipmapNearest = GL_LINEAR_MIPMAP_NEAREST,
    nearestMipmapLinear = GL_NEAREST_MIPMAP_LINEAR,
    linearMipamapLinear = GL_LINEAR_MIPMAP_LINEAR,
}

enum TextureMagFilter
{
    nearest = GL_NEAREST,
    linear = GL_LINEAR,
}

enum TextureWrap
{
    clampToEdge = GL_CLAMP_TO_EDGE,
    mirroredRepeat = GL_MIRRORED_REPEAT,
    repeat = GL_REPEAT,
}

/**
RGBA pixel struct.
*/
struct PixelRGBA
{
    enum PixelFormat = GL_RGBA;
    enum PixelType = GL_UNSIGNED_BYTE;

    ubyte r;
    ubyte g;
    ubyte b;
    ubyte a;
}

enum isPixelType(T) = is(T == PixelRGBA);

/**
Texture struct.
*/
struct Texture
{
    @disable this();

    /**
    During bind texture.

    Params:
        Dg = delegate type.
        dg = delegate.
    */
    void duringBind(Dg)(scope Dg dg) const scope
    in (dg)
    {
        static assert(isCallable!Dg);

        enforceGL!(() => glBindTexture(payload_.type, payload_.textureID));
        scope(exit) glBindTexture(payload_.type, 0);

        dg();
    }

    /**
    Activate texture unit and bind this texture.

    Params:
        textureUnit = texture unit number.
    */
    void activeAndBind(uint textureUnit) scope
    {
        enforceGL!(() => glActiveTexture(GL_TEXTURE0 + textureUnit));
        enforceGL!(() => glBindTexture(payload_.type, payload_.textureID));
    }

    /**
    Draw pixels to texture.

    Params:
        T = pixel type.
        textureUnit = texture unit number.
        width = image width.
        height = image height.
        pixels = image pixels.
    */
    void image2D(T)(uint textureUnit, uint width, uint height, scope const(T)[] pixels) scope if(isPixelType!T)
    in (pixels.length == width * height)
    {
        activeAndBind(textureUnit);
        scope(exit) glBindTexture(payload_.type, 0);

        enforceGL!(() => glTexImage2D(
            GL_TEXTURE_2D,
            0,
            T.PixelFormat,
            width,
            height,
            0,
            T.PixelFormat,
            T.PixelType,
            pixels.ptr));
    }

private:

    this(GLuint textureID, TextureType type, TextureMinFilter minFilter, TextureMagFilter magFilter, TextureWrap wrapS, TextureWrap wrapT) scope
    {
        enforceGL!(() => glBindTexture(type, textureID));
        scope(exit) glBindTexture(type, 0);

        glTexParameteri(type, GL_TEXTURE_MIN_FILTER, minFilter);
        glTexParameteri(type, GL_TEXTURE_MAG_FILTER, magFilter);
        glTexParameteri(type, GL_TEXTURE_WRAP_S, wrapS);
        glTexParameteri(type, GL_TEXTURE_WRAP_T, wrapT);

        this.payload_ = Payload(textureID, type);
    }

    struct Payload
    {
        GLuint textureID;
        TextureType type;

        ~this() @nogc nothrow scope
        {
            glDeleteTextures(1, &textureID);
        }
    }

    RefCounted!(Payload, RefCountedAutoInitialize.no) payload_;
}

Texture createTexture(
    TextureType type,
    TextureMinFilter minFilter,
    TextureMagFilter magFilter,
    TextureWrap wrapS,
    TextureWrap wrapT)
{
    GLuint textureID;
    enforceGL!(() => glGenTextures(1, &textureID));
    scope(failure) glDeleteTextures(1, &textureID);

    return Texture(textureID, type, minFilter, magFilter, wrapS, wrapT);
}

