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
    createCube,
    createFragmentShader,
    createPlane,
    createProgram,
    createTexture,
    createVAO,
    createVertexShader,
    CubePoint,
    dearthMain,
    Mat4,
    PixelRGBA,
    Point,
    ShaderProgram,
    Texture,
    TextureType,
    TextureMinFilter,
    TextureMagFilter,
    TextureWrap,
    VertexAttribute,
    VertexArrayObject;

import life : Life, TorusWorld;

struct Vertex
{
    float[3] position;

    @(VertexAttribute.normalized)
    ubyte[2] uv;
}

enum WINDOW_WIDTH = 640;
enum WINDOW_HEIGHT = 480;

enum WORLD_WIDTH = 64;
enum WORLD_HEIGHT = 64;

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
            (CubePoint p) => Vertex(
                [p.x / 2.0 - 0.5, p.y / 2.0 - 0.5, p.z / 2.0 - 0.5],
                [
                    cast(ubyte)(p.x * ubyte.max / 2),
                    cast(ubyte)(p.y * ubyte.max / 2),
                ]));

        auto texture = createTexture(
            TextureType.texture2D,
            TextureMinFilter.linear,
            TextureMagFilter.linear,
            TextureWrap.repeat,
            TextureWrap.repeat);

        // initialize world.
        scope world = new TorusWorld(WORLD_WIDTH, WORLD_HEIGHT);
        scope lifeChoices = [Life.empty, Life.exist];
        foreach (size_t x, size_t y, ref Life life; world)
        {
            life = lifeChoices.choice;
        }

        scope pixels = new PixelRGBA[WORLD_WIDTH * WORLD_HEIGHT];
        immutable existsPixel = PixelRGBA(255, 0, 0, 255);
        immutable emptyPixel = PixelRGBA(0, 0, 0, 255);

        float actualFPS = info.actualFPS;
        float rx = 0.0;
        float ry = 0.0;
        float rz = 0.0;
        info.run({
            // show FPS.
            if (actualFPS != info.actualFPS)
            {
                writefln("FPS: %s", actualFPS);
                actualFPS = info.actualFPS;
            }

            world.nextGeneration();
            foreach (size_t x, size_t y, ref const(Life) life; world)
            {
                pixels[y * WORLD_WIDTH + x] = (world[x, y] == Life.exist)
                    ? existsPixel : emptyPixel;
            }

            texture.image2D(WORLD_WIDTH, WORLD_HEIGHT, pixels[]);
            texture.activeAndBind(0);

            draw(
                shaderProgram,
                vao,
                texture,
                WINDOW_WIDTH,
                WINDOW_HEIGHT,
                rx,
                ry,
                rz);

            rx += 0.05f;
            ry += 0.05f;
            rz += 0.05f;
        });
    });
}

void draw(
    scope ref ShaderProgram!Vertex program,
    scope ref VertexArrayObject!Vertex vao,
    scope ref Texture texture,
    uint width,
    uint height,
    float x,
    float y,
    float z)
{
    glClearColor(0.0f, 0.0f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    scope(exit) glFlush();

    immutable modelLocation = program.getUniformLocation("modelMatrix");
    immutable viewLocation = program.getUniformLocation("viewMatrix");
    immutable projectionLocation = program.getUniformLocation("projectionMatrix");

    program.duringUse({
        Mat4 tmp;
        Mat4 model;
        tmp.mul(Mat4.rotateY(y), Mat4.rotateX(x));
        model.mul(Mat4.rotateZ(z), tmp);

        immutable view = Mat4.unit;
        auto projection = Mat4.unit;
        projection[0, 0] = (cast(float) height) / width;
        program
            .uniform(modelLocation, model)
            .uniform(viewLocation, view)
            .uniform(projectionLocation, projection);
        vao.duringBind(()
        {
            vao.drawElements();
        });
    });
}

