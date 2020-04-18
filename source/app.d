import std.stdio : writefln;

import bindbc.sdl : SDL_QuitEvent;

import dearth :
    duringOpenGL,
    duringSDL,
    duringWindow,
    mainLoopBuilder;

void main()
{
    duringSDL((sdlSupport)
    {
        duringWindow("", 0, 0, 640, 480, (w)
        {
            duringOpenGL((glSupport)
            {
                writefln("%s,%s", sdlSupport, glSupport);
                mainLoopBuilder.run();
            });
        });
    });
}

