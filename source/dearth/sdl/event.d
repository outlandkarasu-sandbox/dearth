/**
SDL2 event module.
*/
module dearth.sdl.event;

import bindbc.sdl :
    SDL_Event,
    SDL_QUIT,
    SDL_QuitEvent,
    SDL_PollEvent;

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
Main loop builder.
*/
class MainLoopBuilder
{
    nothrow pure scope @safe
    {
        /**
        Set onQuit event handler.

        Params:
            handler = quit event handler. return true if exit.
        Returns:
            this reference.
        */
        ref typeof(this) onQuit(Dg)(Dg handler) return
        in (handler)
        {
            eventHandlers_[SDL_QUIT] = (scope ref e) => handler();
            return this;
        }
    }

    void run()
    {
        for (SDL_Event event; ;)
        {
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
        }
    }

private:

    alias EventHandler = EventHandlerResult delegate(scope ref const(SDL_Event));

    float fps_ = 60.0f;
    this() nothrow pure scope @safe
    {
        // add default quit handler.
        this.eventHandlers_[SDL_QUIT]
            = (ref scope e) => EventHandlerResult.quitMainLoop;

        // set up default draw function.
        this.draw_ = () {};
    }

    EventHandler[int] eventHandlers_;
    void delegate() draw_;
}

/**
Returns:
    main loop builder.
*/
MainLoopBuilder mainLoopBuilder() pure @safe
{
    return new MainLoopBuilder();
}

