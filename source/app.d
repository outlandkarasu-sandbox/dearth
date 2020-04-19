import std.stdio : writefln;

import bindbc.sdl : SDL_QuitEvent;

import dearth :
    createFragmentShader,
    createProgram,
    createVertexShader,
    duringOpenGL,
    duringSDL,
    duringWindow,
    MainLoop,
    createVAO,
    VertexAttribute;

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
                auto vertexShader = createVertexShader(import("earth.vert"));
                auto fragmentShader = createFragmentShader(import("earth.frag"));
                auto shaderProgram = createProgram!Vertex(vertexShader, fragmentShader);
                auto vao = createVAO!Vertex();
                scope mainLoop = new MainLoop();
                mainLoop.run(window);
            });
        });
    });
}

