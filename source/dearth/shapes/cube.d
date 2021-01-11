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
Cube side.
*/
enum CubeSide
{
    front,
    left,
    right,
    back,
    top,
    bottom,
}

/**
Cube point.
*/
struct CubePoint
{
    size_t x;
    size_t y;
    size_t z;
    CubeSide side;
}

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

    auto front = PlanePointPaths(splitH, splitV)
        .map!((p) => CubePoint(p.x, p.y, 0, CubeSide.front));
    auto back = PlanePointPaths(splitH, splitV)
        .map!((p) => CubePoint(splitH - p.x, p.y, splitD, CubeSide.back));

    auto left = PlanePointPaths(splitD, splitV)
        .map!((p) => CubePoint(splitH, p.y, p.x, CubeSide.left));
    auto right = PlanePointPaths(splitD, splitV)
        .map!((p) => CubePoint(0, p.y, splitD - p.x, CubeSide.right));

    auto top = PlanePointPaths(splitH, splitD)
        .map!((p) => CubePoint(p.x, 0, splitD - p.y, CubeSide.top));
    auto bottom = PlanePointPaths(splitH, splitD)
        .map!((p) => CubePoint(splitH - p.x, splitV, p.y, CubeSide.bottom));

    scope builder = VAOBuilder!(T, CubePoint)();
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

