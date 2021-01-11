/**
Shape utilities.
*/
module dearth.shapes.utils;

import std.array : Appender;
import std.exception : assumeWontThrow;

import dearth.opengl :
    VertexArrayObject,
    createVAO,
    isVertexStruct;
import dearth.shapes.point : Point;

/**
Plane points generator range.
*/
struct PlanePoints
{
@nogc nothrow pure @safe:

    this(size_t width, size_t height) scope
    {
        this.width_ = width;
        this.height_ = height;
    }

    Point front() const scope
    in (!empty)
    {
        return Point(x_, y_);
    }

    void popFront() scope
    in (!empty)
    {
        ++x_;

        if (x_ >= width_)
        {
            x_ = 0;
            ++y_;
        }
    }

    bool empty() const scope
    {
        return y_ == height_;
    }

private:
    size_t width_;
    size_t height_;
    size_t x_;
    size_t y_;
}

///
@nogc nothrow pure @safe unittest
{
    import std.algorithm : equal;

    assert(PlanePoints().empty);
    assert(PlanePoints(1, 1).equal([Point(0, 0)]));
    assert(PlanePoints(2, 1).equal([Point(0, 0), Point(1, 0)]));
    assert(PlanePoints(1, 2).equal([Point(0, 0), Point(0, 1)]));
    assert(PlanePoints(2, 2).equal([
        Point(0, 0),
        Point(1, 0),
        Point(0, 1),
        Point(1, 1),
    ]));
}

/**
Plane point paths generator range.
*/
struct PlanePointPaths
{
@nogc nothrow pure @safe:

    this(size_t width, size_t height) scope
    {
        this.points_ = PlanePoints(width, height);
    }

    Point front() const scope
    in (!empty)
    {
        immutable offset = points_.front;
        immutable p = triangles_.front;
        return Point(p.x + offset.x, p.y + offset.y);
    }

    void popFront() scope
    in (!empty)
    {
        triangles_.popFront();
        if (triangles_.empty)
        {
            triangles_ = PlaneTrianglePoints.init;
            points_.popFront();
        }
    }

    bool empty() const scope
    {
        return points_.empty;
    }

private:
    PlanePoints points_;
    PlaneTrianglePoints triangles_;
}

///
@nogc nothrow pure @safe unittest
{
    import std.algorithm : equal;

    assert(PlanePointPaths().empty);
    assert(PlanePointPaths(1, 1).equal([
        Point(0, 0), Point(1, 0), Point(0, 1), Point(1, 0), Point(1, 1), Point(0, 1),
    ]));

    assert(PlanePointPaths(2, 1).equal([
        Point(0, 0), Point(1, 0), Point(0, 1), Point(1, 0), Point(1, 1), Point(0, 1),
        Point(1, 0), Point(2, 0), Point(1, 1), Point(2, 0), Point(2, 1), Point(1, 1),
    ]));

    assert(PlanePointPaths(1, 2).equal([
        Point(0, 0), Point(1, 0), Point(0, 1), Point(1, 0), Point(1, 1), Point(0, 1),
        Point(0, 1), Point(1, 1), Point(0, 2), Point(1, 1), Point(1, 2), Point(0, 2),
    ]));

    assert(PlanePointPaths(2, 2).equal([
        Point(0, 0), Point(1, 0), Point(0, 1), Point(1, 0), Point(1, 1), Point(0, 1),
        Point(1, 0), Point(2, 0), Point(1, 1), Point(2, 0), Point(2, 1), Point(1, 1),
        Point(0, 1), Point(1, 1), Point(0, 2), Point(1, 1), Point(1, 2), Point(0, 2),
        Point(1, 1), Point(2, 1), Point(1, 2), Point(2, 1), Point(2, 2), Point(1, 2),
    ]));
}

/**
VAO builder.

Params:
    V = vertex type.
    P = point type.
*/
struct VAOBuilder(V, P = Point)
{
    static assert(isVertexStruct!V);

    /**
    Add a point.

    Params:
        point = required point.
        generator = vertex generator.
    */
    void add(Dg)(auto scope ref const(P) point, scope Dg generator) nothrow pure @safe scope
    {
        const p = point in indexMap_;
        if (!p)
        {
            vertices_.put(generator(point));
            immutable index = cast(ushort)(vertices_[].length - 1);
            indexMap_[point] = index;
            indices_ ~= index;
        }
        else
        {
            indices_ ~= *p;
        }
    }

    @property const @nogc nothrow pure @safe
    {
        immutable(V)[] vertices() scope return
        {
            return vertices_[];
        }

        immutable(ushort)[] indices() scope return
        {
            return indices_[];
        }
    }

    /**
    Build VAO.

    Returns:
        VAO instance.
    */
    VertexArrayObject!V build() const @nogc scope
    {
        auto vao = createVAO!V();
        vao.loadVertices(vertices);
        vao.loadIndices(indices);
        return vao;
    }

private:
    Appender!(immutable(V)[]) vertices_;
    Appender!(immutable(ushort)[]) indices_;
    ushort[P] indexMap_;
}

///
nothrow pure @safe unittest
{
    struct Vertex
    {
        float x;
        float y;
        float z;
    }

    scope builder = VAOBuilder!Vertex();
    builder.add(Point(1, 2, 3), (Point p) => Vertex(p.x, p.y, p.z));
    assert(builder.vertices == [Vertex(1.0, 2.0, 3.0)]);
    assert(builder.indices == [0]);

    builder.add(Point(1, 2, 3), (Point p) => Vertex(p.x, p.y, p.z));
    assert(builder.vertices == [Vertex(1.0, 2.0, 3.0)]);
    assert(builder.indices == [0, 0]);

    builder.add(Point(3, 2, 1), (Point p) => Vertex(p.x, p.y, p.z));
    assert(builder.vertices == [Vertex(1.0, 2.0, 3.0), Vertex(3.0, 2.0, 1.0)]);
    assert(builder.indices == [0, 0, 1]);
}

private:

struct PlaneTrianglePoints
{
@nogc nothrow pure @safe:

    Point front() const scope
    in (!empty)
    {
        switch (current_)
        {
            default: case 0: return Point(0, 0);
            case 1: return Point(1, 0);
            case 2: return Point(0, 1);
            case 3: return Point(1, 0);
            case 4: return Point(1, 1);
            case 5: return Point(0, 1);
        }
    }

    void popFront() scope
    in (!empty)
    {
        ++current_;
    }

    bool empty() const scope
    {
        return current_ >= LENGTH;
    }

private:
    enum LENGTH = 6;
    uint current_;
}

///
@nogc nothrow pure @safe unittest
{
    import std.algorithm : equal;

    assert(PlaneTrianglePoints().equal([
        Point(0, 0),
        Point(1, 0),
        Point(0, 1),
        Point(1, 0),
        Point(1, 1),
        Point(0, 1),
    ]));
}

