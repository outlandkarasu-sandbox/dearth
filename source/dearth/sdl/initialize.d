/**
SDL2 initialize module.
*/
module dearth.sdl.initialize;

import std.exception : enforce;

import bindbc.sdl :
    loadSDL,
    SDL_Init,
    SDL_INIT_VIDEO,
    SDL_Quit,
    sdlSupport,
    SDLSupport,
    unloadSDL;

import dearth.sdl.exception : enforceSDL, SDLException;

/**
During SDL2 library.

Params:
    dg = application delegate.
Throws:
    SDLException if failed.
*/
void duringSDL(scope void delegate(SDLSupport) dg)
{
    immutable support = loadSDL();
    if (support != sdlSupport)
    {
        enforce!SDLException(support != SDLSupport.noLibrary, "No library");
        enforce!SDLException(support != SDLSupport.badLibrary, "Bad library");
    }

    scope(exit) unloadSDL();

    // initialize SDL subsystem.
    enforceSDL(SDL_Init(SDL_INIT_VIDEO));
    scope(exit) SDL_Quit();

    dg(support);
}

