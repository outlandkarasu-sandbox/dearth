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
    SDL_GL_SetAttribute,
    SDL_GL_CONTEXT_MAJOR_VERSION,
    SDL_GL_CONTEXT_MINOR_VERSION,
    SDL_GL_CONTEXT_PROFILE_ES,
    SDL_GL_CONTEXT_PROFILE_CORE,
    SDL_GL_CONTEXT_PROFILE_MASK,
    SDL_GL_DOUBLEBUFFER,
    SDL_Window,
    SDL_WINDOW_OPENGL;

import dearth.sdl.exception : enforceSDL;

private immutable OPEN_GL_MAJOR_VERSION = 4;
private immutable OPEN_GL_MINOR_VERSION = 1;

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
    scope const(char)[] title,
    int x,
    int y,
    uint w,
    uint h,
    scope void delegate(scope SDL_Window*) dg)
in (dg)
{
    // Set OpenGL attributes.
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, OPEN_GL_MAJOR_VERSION);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, OPEN_GL_MINOR_VERSION);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);
    SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);

    scope window = enforceSDL(SDL_CreateWindow(
        toStringz(title),
        x,
        y,
        w,
        h,
        SDL_WINDOW_OPENGL));
    scope(exit) SDL_DestroyWindow(window);

    // initialize OpenGL context
    auto context = SDL_GL_CreateContext(window);
    scope(exit) SDL_GL_DeleteContext(context);

    dg(window);
}

