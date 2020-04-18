/**
SDL2 window module.
*/
module dearth.sdl.window;

import std.string : toStringz;

import bindbc.sdl :
    SDL_CreateWindow,
    SDL_DestroyWindow,
    SDL_GL_CreateContext,
    SDL_GL_DeleteContext,
    SDL_Window,
    SDL_WINDOW_OPENGL;

import dearth.sdl.exception : enforceSDL;

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
    scope window = enforceSDL(SDL_CreateWindow(
        toStringz(title),
        x,
        y,
        w,
        h,
        SDL_WINDOW_OPENGL));
    scope(exit) SDL_DestroyWindow(window);

    auto context = SDL_GL_CreateContext(window);
    scope(exit) SDL_GL_DeleteContext(context);

    dg(window);
}

