import std.stdio : writefln;

import dearth.sdl : duringSDL, duringWindow;

void main()
{
    duringSDL((support)
    {
        writefln("%s", support);
        duringWindow("", 0, 0, 640, 480, (w) {});
    });
}

