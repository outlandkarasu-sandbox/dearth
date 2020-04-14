/**
SDL exception module.
*/
module dearth.sdl.exception;

import std.exception : basicExceptionCtors;
import std.string : fromStringz;

import bindbc.sdl : SDL_GetError;

/**
Exception for SDL2 errors.
*/
@safe
class SDLException : Exception
{
    ///
    mixin basicExceptionCtors;
}

/**
Enforce SDL result.

Params:
    result = result code.
Returns:
    result code.
Throws:
    SDLException if result is nonzero.
*/
int enforceSDL(int result)
{
    if (result != 0)
    {
        throw new SDLException(fromStringz(SDL_GetError()).idup);
    }

    return result;
}

