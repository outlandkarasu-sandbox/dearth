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
    createVAO,
    createVertexShader,
    duringOpenGL,
    duringSDL,
    duringWindow,
    MainLoop,
    Mat4,
    ShaderProgram,
    ShapeVertex,
    VertexAttribute,
    VertexArrayObject;

struct Vertex
{
    float[3] position;

    @(VertexAttribute.normalized)
    ubyte[4] color;
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
                        (ShapeVertex v) => Vertex([v.x - 0.5, v.y - 0.5, v.z], [255, 0, 0, 255]));

                scope mainLoop = new MainLoop();
                mainLoop.onDraw(() => draw(shaderProgram, vao, WINDOW_WIDTH, WINDOW_HEIGHT)).run(window);
            });
        });
    });
}

void draw(
    scope ref ShaderProgram!Vertex program,
    scope ref VertexArrayObject!Vertex vao,
    uint width,
    uint height)
{
    glClearColor(0.0f, 0.0f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    scope(exit) glFlush();

    immutable modelLocation = program.getUniformLocation("modelMatrix");
    immutable viewLocation = program.getUniformLocation("viewMatrix");
    immutable projectionLocation = program.getUniformLocation("projectionMatrix");

    program.duringUse(()
    {
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

