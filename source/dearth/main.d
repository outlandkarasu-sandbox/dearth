/**
D earth main function.
*/
module dearth.main;

import bindbc.sdl : SDL_Window, SDLSupport;
import bindbc.opengl : GLSupport;

import dearth.sdl :
    duringSDL,
    duringWindow,
    MainLoop;

import dearth.opengl : duringOpenGL;

/**
main loop informations.
*/
struct MainInfo
{
    void run(void delegate() draw)
    {
        mainLoop_.onDraw(draw).run(window_);
    }

    @property @nogc nothrow pure @safe scope const
    {
        SDLSupport sdlSupport() { return sdlSupport_; }
        GLSupport glSupport() { return glSupport_; }
        float actualFPS() { return mainLoop_.actualFPS; }
    }

private:
    SDLSupport sdlSupport_;
    GLSupport glSupport_;
    MainLoop mainLoop_;
    SDL_Window* window_;
}

/**
D earth main function.

Params:
    title = window title.
    x = window x position.
    y = window y position.
    width = window width.
    height = window height.
*/
void dearthMain(
    scope const(char)[] title,
    uint x,
    uint y,
    uint width,
    uint height,
    scope void delegate(scope MainInfo) dg)
{
    duringSDL((sdlSupport)
    {
        duringWindow(title, x, y, width, height, (window)
        {
            duringOpenGL((glSupport)
            {
                scope mainLoop = new MainLoop();
                dg(MainInfo(sdlSupport, glSupport, mainLoop, window));
            });
        });
    });
}

