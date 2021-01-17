import std.stdio : writefln;
import std.random : choice;
import std.array : appender;
import std.algorithm : each;
import std.math : PI;

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
    CubeSide,
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

import life : Life, PlaneWorld, CubeWorld;

struct Vertex
{
    float[3] position;

    @(VertexAttribute.normalized)
    ubyte[2] uv;

    float plane;
}

enum WINDOW_WIDTH = 640;
enum WINDOW_HEIGHT = 480;

enum WORLD_WIDTH = 32;
enum WORLD_HEIGHT = 32;
enum WORLD_DEPTH = 32;

struct PlaneTexture
{
    @disable this();

    this(PlaneWorld plane, uint index) scope
    {
        this.plane_ = plane;
        this.texture_ = createTexture(
            TextureType.texture2D,
            TextureMinFilter.linear,
            TextureMagFilter.linear,
            TextureWrap.repeat,
            TextureWrap.repeat);
        this.pixels_.length = plane.width * plane.height;
        this.index_ = index;
    }

    void refresh() scope
    {
        immutable width = cast(uint) plane_.width;
        immutable height = cast(uint) plane_.height;
        foreach (size_t x, size_t y, ref const(Life) life; plane_)
        {
            pixels_[y * width + x] = (life == Life.exist)
                ? existsPixel : emptyPixel;
        }

        texture_.image2D(index_, width, height, pixels_[]);
        texture_.activeAndBind(index_);
    }

private:
    static immutable existsPixel = PixelRGBA(255, 0, 0, 255);
    static immutable emptyPixel = PixelRGBA(0, 0, 0, 255);

    PlaneWorld plane_;
    Texture texture_;
    PixelRGBA[] pixels_;
    uint index_;
}

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
                    cast(ubyte)(p.sideX * ubyte.max / 2),
                    cast(ubyte)(p.sideY * ubyte.max / 2),
                ],
                cast(float) p.side));

        // initialize world.
        scope world = new CubeWorld(WORLD_WIDTH, WORLD_HEIGHT, WORLD_DEPTH);
        scope lifeChoices = [Life.empty, Life.exist];
        scope textures = appender!(PlaneTexture[])();
        foreach (i, plane; [
                world.front,
                world.left,
                world.right,
                world.back,
                world.top,
                world.bottom,
            ])
        {
            foreach (size_t x, size_t y, ref Life life; plane)
            {
                life = lifeChoices.choice;
            }
            textures ~= PlaneTexture(plane, cast(uint) i);
        }

        float actualFPS = info.actualFPS;
        float rx = 0.3;
        float ry = 0.3;
        float rz = 0.0;
        info.run({
            // show FPS.
            if (actualFPS != info.actualFPS)
            {
                writefln("FPS: %s", actualFPS);
                actualFPS = info.actualFPS;
            }

            world.nextGeneration();
            textures.each!"a.refresh()";

            draw(
                shaderProgram,
                vao,
                WINDOW_WIDTH,
                WINDOW_HEIGHT,
                rx,
                ry,
                rz);

            //rx += 0.01f;
            ry += 0.01f;
            //rz += 0.01f;
        });
    });
}

void draw(
    scope ref ShaderProgram!Vertex program,
    scope ref VertexArrayObject!Vertex vao,
    uint width,
    uint height,
    float x,
    float y,
    float z)
{
    glClearColor(0.3f, 0.3f, 0.3f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    scope(exit) glFlush();

    immutable modelLocation = program.getUniformLocation("modelMatrix");
    immutable viewLocation = program.getUniformLocation("viewMatrix");
    immutable projectionLocation = program.getUniformLocation("projectionMatrix");
    immutable frontLocation = program.getUniformLocation("frontTexture");
    immutable leftLocation = program.getUniformLocation("leftTexture");
    immutable rightLocation = program.getUniformLocation("rightTexture");
    immutable backLocation = program.getUniformLocation("backTexture");
    immutable topLocation = program.getUniformLocation("topTexture");
    immutable bottomLocation = program.getUniformLocation("bottomTexture");

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
            .uniform(projectionLocation, projection)
            .uniform(frontLocation, 0)
            .uniform(leftLocation, 1)
            .uniform(rightLocation, 2)
            .uniform(backLocation, 3)
            .uniform(topLocation, 4)
            .uniform(bottomLocation, 5);
        vao.duringBind(()
        {
            vao.drawElements();
        });
    });
}

