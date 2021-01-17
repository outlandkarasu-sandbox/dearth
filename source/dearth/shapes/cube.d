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
    size_t sideX;
    size_t sideY;
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
        .map!((p) => CubePoint(p.x, p.y, splitD, CubeSide.front, splitH - p.x, p.y));
    auto left = PlanePointPaths(splitD, splitV)
        .map!((p) => CubePoint(0, p.y, p.x, CubeSide.left, splitD - p.x, p.y));
    auto right = PlanePointPaths(splitD, splitV)
        .map!((p) => CubePoint(splitH, p.y, splitD - p.x, CubeSide.right, p.x, p.y));

    auto back = PlanePointPaths(splitH, splitV)
        .map!((p) => CubePoint(splitH - p.x, p.y, 0, CubeSide.back, p.x, p.y));

    auto top = PlanePointPaths(splitH, splitD)
        .map!((p) => CubePoint(p.x, splitV, splitD - p.y, CubeSide.top, splitH - p.x, p.y));
    auto bottom = PlanePointPaths(splitH, splitD)
        .map!((p) => CubePoint(p.x, 0, p.y, CubeSide.bottom, splitH - p.x, splitD - p.y));

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

