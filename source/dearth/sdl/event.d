/**
SDL2 event module.
*/
module dearth.sdl.event;

import bindbc.sdl :
    SDL_Delay,
    SDL_Event,
    SDL_GetPerformanceCounter,
    SDL_GetPerformanceFrequency,
    SDL_GL_SwapWindow,
    SDL_QUIT,
    SDL_QuitEvent,
    SDL_PollEvent,
    SDL_Window;

/**
Event handler result.
*/
enum EventHandlerResult
{
    /**
    Continue main loop.
    */
    continueMainLoop,

    /**
    Quit main loop.
    */
    quitMainLoop,
}

/**
Main loop.
*/
class MainLoop
{
    /**
    Default consturctor.
    */
    this() nothrow pure scope @safe
    {
        // add default quit handler.
        this.eventHandlers_[SDL_QUIT]
            = (ref scope e) => EventHandlerResult.quitMainLoop;

        // set up default draw function.
        this.draw_ = () {};
    }

    nothrow pure scope @safe
    {
        /**
        Set onQuit event handler.

        Params:
            handler = quit event handler. return true if exit.
        Returns:
            this reference.
        */
        typeof(this) onQuit(Dg)(Dg handler) return
        in (handler)
        {
            eventHandlers_[SDL_QUIT] = (scope ref e) => handler();
            return this;
        }

        /**
        Set frames per a second.

        Params:
            fps = FPS.
        Returns:
            this reference.
        */
        typeof(this) fps(float fps) return
        in (fps >= 0.0f)
        {
            fps_ = fps;
            return this;
        }

        /**
        Set draw function.

        Params:
            draw = draw function.
        Returns:
            this reference.
        */
        typeof(this) onDraw(void delegate() draw) return
        in (draw)
        {
            draw_ = draw;
            return this;
        }
    }

    /**
    Start main loop.

    Params:
        window = main window.
    */
    void run(scope SDL_Window* window)
    in (window)
    {
        immutable performanceFrequency = SDL_GetPerformanceFrequency();
        immutable countPerFrame = performanceFrequency / fps_;

        for (SDL_Event event; ;)
        {
            immutable frameStart = SDL_GetPerformanceCounter();

            // processing pushed events.
            while (SDL_PollEvent(&event))
            {
                auto handler = event.type in eventHandlers_;
                if (handler && (*handler)(event) == EventHandlerResult.quitMainLoop)
                {
                    return;
                }
            }

            // draw a frame.
            draw_();
            SDL_GL_SwapWindow(window);

            // wait next frame timing.
            immutable drawDelay = SDL_GetPerformanceCounter() - frameStart;
            immutable waitDelay = (countPerFrame < drawDelay)
                ? 0 : cast(uint)((countPerFrame - drawDelay) * 1000.0 / performanceFrequency);
            SDL_Delay(waitDelay);
        }
    }

private:

    alias EventHandler = EventHandlerResult delegate(scope ref const(SDL_Event));

    float fps_ = 60.0f;

    EventHandler[int] eventHandlers_;
    void delegate() draw_;
}

