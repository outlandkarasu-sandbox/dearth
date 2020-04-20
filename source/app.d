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
    createProgram,
    createVAO,
    createVertexShader,
    duringOpenGL,
    duringSDL,
    duringWindow,
    MainLoop,
    ShaderProgram,
    VertexAttribute,
    VertexArrayObject;

struct Vertex
{
    float[3] position;

    @(VertexAttribute.normalized)
    ubyte[4] color;
}

void main()
{
    duringSDL((sdlSupport)
    {
        duringWindow("", 0, 0, 640, 480, (window)
        {
            duringOpenGL((glSupport)
            {
                writefln("%s,%s", sdlSupport, glSupport);

                glViewport(0, 0, 640, 480);
                glEnable(GL_DEPTH_TEST);

                auto vertexShader = createVertexShader(import("earth.vert"));
                auto fragmentShader = createFragmentShader(import("earth.frag"));
                auto shaderProgram = createProgram!Vertex(vertexShader, fragmentShader);
                auto vao = createVAO!Vertex();

                scope vertices = [
                    Vertex([ 0.0,  0.5, 0.0], [255, 0, 0, 255]),
                    Vertex([-0.5, -0.5, 0.0], [0, 255, 0, 255]),
                    Vertex([ 0.5, -0.5, 0.0], [0, 0, 255, 255]),
                ];
                vao.loadVertices(vertices);
                vao.loadIndices([0, 1, 2]);
                vao.vertexAttributePointers();

                scope mainLoop = new MainLoop();
                mainLoop.onDraw(() => draw(shaderProgram, vao)).run(window);
            });
        });
    });
}

void draw(
    scope ref ShaderProgram!Vertex program,
    scope ref VertexArrayObject!Vertex vao)
{
    glClearColor(0.0f, 0.0f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    scope(exit) glFlush();

    program.duringUse(()
    {
        vao.duringBind(()
        {
            vao.drawElements();
        });
    });
}

