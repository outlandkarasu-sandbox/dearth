import std.stdio : writefln;
import std.random : choice;

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
    createCube,
    createProgram,
    createTexture,
    createVAO,
    createVertexShader,
    dearthMain,
    Mat4,
    PixelRGBA,
    ShaderProgram,
    CubeVertex,
    Texture,
    TextureType,
    TextureMinFilter,
    TextureMagFilter,
    TextureWrap,
    VertexAttribute,
    VertexArrayObject;

import life : World;

struct Vertex
{
    float[3] position;

    @(VertexAttribute.normalized)
    ubyte[2] uv;
}

enum WINDOW_WIDTH = 640;
enum WINDOW_HEIGHT = 480;

enum WORLD_WIDTH = 512;
enum WORLD_HEIGHT = 512;

void main()
{
    dearthMain("", 0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, (scope info)
    {
        writefln("%s,%s", info.sdlSupport, info.glSupport);
        glViewport(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT);
        glEnable(GL_DEPTH_TEST);

        auto vertexShader = createVertexShader(import("earth.vert"));
        auto fragmentShader = createFragmentShader(import("earth.frag"));
        auto shaderProgram = createProgram!Vertex(vertexShader, fragmentShader);
        auto vao = createCube!Vertex(
            2, 2, 2,
            (CubeVertex v) => Vertex(
                [v.x - 0.5, v.y - 0.5, v.z],
                [
                    cast(ubyte)(v.h * ubyte.max / 2),
                    cast(ubyte)(v.v * ubyte.max / 2),
                ]));

        auto texture = createTexture(
            TextureType.texture2D,
            TextureMinFilter.linear,
            TextureMagFilter.linear,
            TextureWrap.repeat,
            TextureWrap.repeat);

        // initialize world.
        scope world = new World(WORLD_WIDTH, WORLD_HEIGHT);
        scope lifeChoices = [World.Life.empty, World.Life.exist];
        foreach (size_t x, size_t y, ref World.Life life; world)
        {
            life = lifeChoices.choice;
        }

        scope pixels = new PixelRGBA[WORLD_WIDTH * WORLD_HEIGHT];
        immutable existsPixel = PixelRGBA(255, 0, 0, 255);
        immutable emptyPixel = PixelRGBA(0, 0, 0, 255);

        float actualFPS = info.actualFPS;
        info.run({
            // show FPS.
            if (actualFPS != info.actualFPS)
            {
                writefln("FPS: %s", actualFPS);
                actualFPS = info.actualFPS;
            }

            world.nextGeneration();
            foreach (size_t x, size_t y, ref const(World.Life) life; world)
            {
                pixels[y * WORLD_WIDTH + x]
                    = (world[x, y] == World.Life.exist)
                    ? existsPixel : emptyPixel;
            }

            texture.image2D(WORLD_WIDTH, WORLD_HEIGHT, pixels[]);
            texture.activeAndBind(0);

            draw(
                shaderProgram,
                vao,
                texture,
                WINDOW_WIDTH,
                WINDOW_HEIGHT);
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

