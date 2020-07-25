import std.stdio : writefln;

import bindbc.sdl : SDL_QuitEvent;
import bindbc.opengl :
    GL_COLOR_BUFFER_BIT,
    GL_DEPTH_BUFFER_BIT,
    GL_DEPTH_TEST;
import bindbc.opengl :
    glClearColor,
    glClear,
    glEnable,
    glFlush,
    glViewport;

import dearth :
    createFragmentShader,
    createPlane,
    createProgram,
    createTexture,
    createVAO,
    createVertexShader,
    duringOpenGL,
    duringSDL,
    duringWindow,
    MainLoop,
    Mat4,
    PixelRGBA,
    ShaderProgram,
    ShapeVertex,
    Texture,
    TextureType,
    TextureMinFilter,
    TextureMagFilter,
    TextureWrap,
    VertexAttribute,
    VertexArrayObject;

struct Vertex
{
    float[3] position;

    @(VertexAttribute.normalized)
    ubyte[2] uv;
}

enum WINDOW_WIDTH = 640;
enum WINDOW_HEIGHT = 480;

void main()
{
    duringSDL((sdlSupport)
    {
        duringWindow("", 0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, (window)
        {
            duringOpenGL((glSupport)
            {
                writefln("%s,%s", sdlSupport, glSupport);

                glViewport(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT);
                glEnable(GL_DEPTH_TEST);

                auto vertexShader = createVertexShader(import("earth.vert"));
                auto fragmentShader = createFragmentShader(import("earth.frag"));
                auto shaderProgram = createProgram!Vertex(vertexShader, fragmentShader);
                auto vao = createPlane!Vertex(
                        2, 2,
                        (ShapeVertex v) => Vertex(
                            [v.x - 0.5, v.y - 0.5, v.z],
                            [cast(ubyte)(v.h * ubyte.max / 2), cast(ubyte)(v.v * ubyte.max / 2)]));

                auto texture = createTexture(
                        TextureType.texture2D,
                        TextureMinFilter.linear,
                        TextureMagFilter.linear,
                        TextureWrap.repeat,
                        TextureWrap.repeat);

                immutable PixelRGBA[4] pixels = [
                    PixelRGBA(255,   0,   0, 255),
                    PixelRGBA(  0, 255,   0, 255),
                    PixelRGBA(  0,   0, 255, 255),
                    PixelRGBA(  0,   0,   0, 255),
                ];
                texture.image2D(2, 2, pixels[]);
                texture.activeAndBind(0);

                scope mainLoop = new MainLoop();
                mainLoop.onDraw({
                    draw(
                        shaderProgram,
                        vao,
                        texture,
                        WINDOW_WIDTH,
                        WINDOW_HEIGHT);
                }).run(window);
            });
        });
    });
}

void draw(
    scope ref ShaderProgram!Vertex program,
    scope ref VertexArrayObject!Vertex vao,
    scope ref Texture texture,
    uint width,
    uint height)
{
    glClearColor(0.0f, 0.0f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    scope(exit) glFlush();

    immutable modelLocation = program.getUniformLocation("modelMatrix");
    immutable viewLocation = program.getUniformLocation("viewMatrix");
    immutable projectionLocation = program.getUniformLocation("projectionMatrix");

    program.duringUse({
        immutable m = Mat4.unit;
        Mat4 projection = m;
        projection[0, 0] = (cast(float) height) / width;
        program
            .uniform(modelLocation, m)
            .uniform(viewLocation, m)
            .uniform(projectionLocation, projection);
        vao.duringBind(()
        {
            vao.drawElements();
        });
    });
}

