/**
Life game module.
*/
module life;

@safe:

/// Life value.
enum Life : ubyte
{
    empty = 0,
    exist = 1,
}

/**
Life game world.
*/
abstract class PlaneWorld
{
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
        this.plane2_ = plane1_.dup;
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
    foreach over world.

    Params:
        Dg = delegate type
        dg = foreach delegate.
    Returns:
        foreach result.
    */
    int opApply(Dg)(scope Dg dg) @trusted
    {
        foreach (y; 0 .. height_)
        {
            immutable rowIndex = y * width_;
            foreach (x; 0 .. width_)
            {
                immutable result = dg(x, y, currentPlane_[rowIndex + x]);
                if (result)
                {
                    return result;
                }
            }
        }
        return 0;
    }

    /**
    Move to next generation state.
    */
    void nextGeneration() @nogc nothrow pure scope
    {
        scope next = this.nextPlane;

        foreach (y; 0 .. height_)
        {
            immutable rowOffset = y * width_;
            foreach (x; 0 .. width_)
            {
                immutable current = this[x, y];
                immutable n = count(x, y);
                Life nextLife = current;
                if (current)
                {
                    if (n < 2 || 3 < n)
                    {
                        nextLife = Life.empty;
                    }
                }
                else if (n == 3)
                {
                    nextLife = Life.exist;
                }

                next[rowOffset + x] = nextLife;
            }
        }

        this.currentPlane_ = (currentPlane_ is plane1_) ? plane2_ : plane1_;
    }

protected:

    /**
    get near edge lives.

    Params:
        x = cell x.
        y = cell y.
    Returns:
        true if live is.
    */
    abstract bool isEdgeLive(ptrdiff_t x, ptrdiff_t y) const @nogc nothrow pure scope;

private:

    /**
    Count lives around cell.

    Params:
        x = x position.
        y = y position.
    Returns:
        lives count around cell.
    */
    size_t count(size_t x, size_t y) const @nogc nothrow pure scope
    in (x < width_)
    in (y < height_)
    {
        size_t count = 0;
        if (isLive(x - 1, y - 1)) ++count;
        if (isLive(x - 1, y    )) ++count;
        if (isLive(x - 1, y + 1)) ++count;
        if (isLive(x    , y - 1)) ++count;
        //if (isLive(x    , y    )) ++count;
        if (isLive(x    , y + 1)) ++count;
        if (isLive(x + 1, y - 1)) ++count;
        if (isLive(x + 1, y    )) ++count;
        if (isLive(x + 1, y + 1)) ++count;

        return count;
    }

    /**
    get near lives.

    Params:
        x = cell x.
        y = cell y.
    Returns:
        true if live is.
    */
    bool isLive(ptrdiff_t x, ptrdiff_t y) const @nogc nothrow pure scope
    {
        if (x < 0 || width_ <= x || y < 0 || height_ <= y)
        {
            return isEdgeLive(x, y);
        }
        else
        {
            return this[x, y] == Life.exist;
        }
    }

    @property Life[] nextPlane() @nogc nothrow pure return scope
    {
        return (currentPlane_ is plane1_) ? plane2_ : plane1_;
    }

    Life[] currentPlane_;
    Life[] plane1_;
    Life[] plane2_;
    size_t width_;
    size_t height_;
}

class TorusWorld : PlaneWorld
{
    /**
    Initialize by world size.

    Params:
        w = world width.
        h = world height.
    */
    this(size_t w, size_t h) nothrow pure scope
    {
        super(w, h);
    }

protected:

    override bool isEdgeLive(ptrdiff_t x, ptrdiff_t y) const @nogc nothrow pure scope
    {
        auto liveX = x;
        if (liveX < 0)
        {
            liveX += width_;
        }
        else if (width_ <= liveX)
        {
            liveX -= width_;
        }

        auto liveY = y;
        if (liveY < 0)
        {
            liveY += height_;
        }
        else if (height_ <= liveY)
        {
            liveY -= height_;
        }

        return this[liveX, liveY] == Life.exist;
    }
}

///
nothrow pure unittest
{
    scope world = new TorusWorld(100, 100);
    assert(world[0, 0] == Life.empty);
    assert(world[99, 99] == Life.empty);

    world[0, 0] = Life.exist;
    assert(world[0, 0] == Life.exist);
    assert(world[99, 99] == Life.empty);

    world[99, 99] = Life.exist;
    assert(world[0, 0] == Life.exist);
    assert(world[99, 99] == Life.exist);
}

nothrow pure unittest
{
    scope world = new TorusWorld(100, 100);
    world[0, 0] = Life.exist;

    assert(world.count(98, 0) == 0);
    assert(world.count(99, 0) == 1);
    assert(world.count(0, 0) == 0);
    assert(world.count(1, 0) == 1);
    assert(world.count(2, 0) == 0);

    assert(world.count(98, 1) == 0);
    assert(world.count(99, 1) == 1);
    assert(world.count(0, 1) == 1);
    assert(world.count(1, 1) == 1);
    assert(world.count(2, 1) == 0);

    assert(world.count(98, 99) == 0);
    assert(world.count(99, 99) == 1);
    assert(world.count(0, 99) == 1);
    assert(world.count(1, 99) == 1);
    assert(world.count(2, 99) == 0);
}

///
nothrow pure unittest
{
    scope world = new TorusWorld(100, 100);
    world[0, 0] = Life.exist;
    world[1, 0] = Life.exist;
    world[2, 0] = Life.exist;

    world.nextGeneration();

    assert(!world[0, 0]);
    assert( world[1, 0]);
    assert(!world[2, 0]);

    assert(!world[0, 1]);
    assert( world[1, 1]);
    assert(!world[2, 1]);

    assert(!world[0, 99]);
    assert( world[1, 99]);
    assert(!world[2, 99]);
}

/**
Life game cube world.
*/
class CubeWorld
{
}
