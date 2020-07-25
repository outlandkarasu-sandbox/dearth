/**
OpenGL texture module.
*/
module dearth.opengl.texture;

import std.typecons :
    RefCounted,
    RefCountedAutoInitialize;

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
    GL_UNSIGNED_BYTE,
    glActiveTexture,
    glBindTexture,
    glDeleteTextures,
    glGenTextures,
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
    liner = GL_LINEAR,
    nearestMipmapNearest = GL_NEAREST_MIPMAP_NEAREST,
    linearMipmapNearest = GL_LINEAR_MIPMAP_NEAREST,
    nearestMipmapLiner = GL_NEAREST_MIPMAP_LINEAR,
    linearMipamapLiner = GL_LINEAR_MIPMAP_LINEAR,
}

enum TextureMagFilter
{
    nearest = GL_NEAREST,
    liner = GL_LINEAR,
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
    Draw pixels to texture.

    Params:
        T = pixel type.
        width = image width.
        height = image height.
        pixels = image pixels.
    */
    void image2D(T)(uint width, uint height, scope const(T)[] pixels) scope if(isPixelType!T)
    in (pixels.length == width * height)
    {
        enforceGL!(() => glBindTexture(payload_.type, payload_.textureID));
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

