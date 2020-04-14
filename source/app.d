import std.stdio : writefln;

import dearth.sdl : initializeSDL, duringWindow;

void main()
{
    writefln("%s", initializeSDL());

    duringWindow("", 0, 0, 640, 480, delegate(w) {});
}
