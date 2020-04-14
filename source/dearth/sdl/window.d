/**
SDL2 window module.
*/
module dearth.sdl.window;

import std.string : toStringz;

import bindbc.sdl :
    SDL_CreateWindow,
    SDL_DestroyWindow,
    SDL_Window,
    SDL_WINDOW_OPENGL;

/**
During show window.

Params:
    title = window title.
    x = window x position.
    y = window y position.
    w = window width.
    h = window height.
    dg = delegate.
*/
void duringWindow(
    scope string title,
    int x,
    int y,
    uint w,
    uint h,
    scope void delegate(scope SDL_Window*) dg)
in (dg)
{
    scope window = SDL_CreateWindow(
        toStringz(title),
        x,
        y,
        w,
        h,
        SDL_WINDOW_OPENGL);
    scope(exit) SDL_DestroyWindow(window);

    dg(window);
}

