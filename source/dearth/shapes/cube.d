/**
Cube shape.
*/
module dearth.shapes.cube;

import std.algorithm : each, map;
import std.range : chain;

import dearth.opengl :
    createVAO,
    isVertexStruct,
    VertexArrayObject;

import dearth.shapes.point : Point;
import dearth.shapes.utils :
   PlanePointPaths,
   VAOBuilder;

/**
Params:
    T = vertex type.
    Dg = vertex generator delegate type.
    splitH = horizontal polygon split count.
    splitV = vertical polygon split count.
    splitD = depth polygon split count.
    dg = vertex generator delegate.
Returns:
    Cube shape object.
*/
VertexArrayObject!T createCube(T, Dg)(size_t splitH, size_t splitV, size_t splitD, scope Dg dg)
in (splitH > 0)
in (splitV > 0)
in (splitD > 0)
{
    static assert(isVertexStruct!T);

    auto front = PlanePointPaths(splitH, splitV);
    auto left = PlanePointPaths(splitD, splitV).map!((p) => Point(splitH, p.y, p.x));
    auto back = PlanePointPaths(splitH, splitV).map!((p) => Point(splitH - p.x, p.y, splitD));
    auto right = PlanePointPaths(splitD, splitV).map!((p) => Point(0, p.y, splitD - p.x));
    auto top = PlanePointPaths(splitH, splitD).map!((p) => Point(p.x, 0, splitD - p.y));
    auto bottom = PlanePointPaths(splitH, splitD).map!((p) => Point(p.x, splitV, p.y));

    scope builder = VAOBuilder!T();
    chain(
        front,
        left,
        back,
        right,
        top,
        bottom
    ).each!((p) => builder.add(p, dg));
    return builder.build();
}

