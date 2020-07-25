/**
Life game module.
*/
module life;

@safe:

/**
Life game world.
*/
class World
{
    enum Life : ubyte
    {
        empty = 0,
        exist = 1,
    }

    /**
    Initialize by world size.

    Params:
        w = world width.
        h = world height.
    */
    this(size_t w, size_t h) nothrow pure scope
    {
        this.plane1_ = new Life[w * h];
        this.plane1_[] = Life.empty;
        this.plane2_ = plane2_.dup;
        this.currentPlane_ = this.plane1_;
        this.width_ = w;
        this.height_ = h;
    }

    /**
    Set life.

    Params:
        life = live value.
        x = x position.
        y = y position.
    Returns:
        a life.
    */
    Life opIndexAssign(Life life, size_t x, size_t y) @nogc nothrow pure scope
    in (x < width_)
    in (y < height_)
    {
        currentPlane_[y * width_ + x] = life;
        return life;
    }
    /**
    Get life.

    Params:
        x = x position.
        y = y position.
    Returns:
        a life.
    */
    Life opIndex(size_t x, size_t y) const @nogc nothrow pure scope
    in (x < width_)
    in (y < height_)
    {
        return currentPlane_[y * width_ + x];
    }

    /**
    Move to next generation state.
    */
    void next() @nogc nothrow pure scope
    {
    }

private:

    Life[] currentPlane_;
    Life[] plane1_;
    Life[] plane2_;
    size_t width_;
    size_t height_;
}

///
unittest
{
    scope world = new World(100, 100);
    assert(world[0, 0] == World.Life.empty);
    assert(world[99, 99] == World.Life.empty);

    world[0, 0] = World.Life.exist;
    assert(world[0, 0] == World.Life.exist);
    assert(world[99, 99] == World.Life.empty);

    world[99, 99] = World.Life.exist;
    assert(world[0, 0] == World.Life.exist);
    assert(world[99, 99] == World.Life.exist);
}

