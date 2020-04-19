import std.stdio : writefln;

import bindbc.sdl : SDL_QuitEvent;

import dearth :
    duringOpenGL,
    duringSDL,
    duringWindow,
    MainLoop;

void main()
{
    duringSDL((sdlSupport)
    {
        duringWindow("", 0, 0, 640, 480, (window)
        {
            duringOpenGL((glSupport)
            {
                writefln("%s,%s", sdlSupport, glSupport);
                scope mainLoop = new MainLoop();
                mainLoop.run(window);
            });
        });
    });
}

