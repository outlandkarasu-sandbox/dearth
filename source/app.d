import std.stdio : writefln;

import bindbc.sdl : SDL_QuitEvent;

import dearth.sdl : duringSDL, duringWindow, handleEvents;

struct EventHandler
{
    void opCall(scope ref const(SDL_QuitEvent) event)
    {
        writefln("quit");
    }

    void opCall(E)(scope ref const(E) event)
    {
    }
}

void main()
{
    duringSDL((support)
    {
        writefln("%s", support);
        duringWindow("", 0, 0, 640, 480, (w)
        {
            EventHandler handler;
            handleEvents(handler, () {});
        });
    });
}

