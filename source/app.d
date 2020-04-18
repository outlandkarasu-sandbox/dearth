import std.stdio : writefln;

import bindbc.sdl : SDL_QuitEvent;

import dearth.sdl : duringSDL, duringWindow, mainLoopBuilder;

void main()
{
    duringSDL((support)
    {
        writefln("%s", support);
        duringWindow("", 0, 0, 640, 480, (w)
        {
            mainLoopBuilder.run();
        });
    });
}

