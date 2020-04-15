/**
SDL2 event module.
*/
module dearth.sdl.event;

import bindbc.sdl :
    SDL_Event,
    SDL_QUIT,
    SDL_PollEvent;

/**
Handle SDL events.

Params:
    H = event handler type.
    Dg = frame draw delegate type.
    handler = event handler.
    dg = frame draw delegate.
*/
void handleEvents(H, Dg)(scope H handler, scope Dg dg)
{
    for (SDL_Event event; ;)
    {
        // processing pushed events.
        while (SDL_PollEvent(&event))
        {
            switch (event.type) {
                case SDL_QUIT:
                    handler(event.quit);
                    return;
                default:
                    handler(event);
                    break;
            }
        }

        // draw a frame.
        dg();
    }
}

