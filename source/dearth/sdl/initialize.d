/**
SDL2 initialize module.
*/
module dearth.sdl.initialize;

import std.exception : enforce;

import bindbc.sdl : loadSDL, sdlSupport, SDLSupport;

import dearth.sdl.exception : SDLException;

/**
Initialize SDL2 library.

Returns:
    SDL2 support version.
*/
SDLSupport initializeSDL()
out (r; r != SDLSupport.noLibrary)
out (r; r != SDLSupport.badLibrary)
{
    immutable support = loadSDL();
    if (support != sdlSupport)
    {
        enforce!SDLException(support != SDLSupport.noLibrary, "No library");
        enforce!SDLException(support != SDLSupport.badLibrary, "Bad library");
    }
    return support;
}

