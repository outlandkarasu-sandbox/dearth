/**
SDL exception module.
*/
module dearth.sdl.exception;

import std.exception : basicExceptionCtors;
@safe:

/**
Exception for SDL2 errors.
*/
class SDLException : Exception
{
    ///
    mixin basicExceptionCtors;
}

