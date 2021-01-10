/**
Plane shape.
*/
module dearth.shapes.plane;

import std.algorithm : each;

import dearth.opengl :
    isVertexStruct,
    VertexArrayObject;

import dearth.shapes.utils :
    PlanePointPaths,
    VAOBuilder;

/**
Params:
    T = vertex type.
    Dg = vertex generator delegate.
    splitH = horizontal polygon split count.
    splitV = vertical polygon split count.
Returns:
    Plane shape object.
*/
VertexArrayObject!T createPlane(T, Dg)(size_t splitH, size_t splitV, scope Dg dg)
in (splitH > 0)
in (splitV > 0)
{
    static assert(isVertexStruct!T);

    immutable pointsH = splitH + 1;
    immutable pointsV = splitV + 1;
    scope builder = VAOBuilder!T();
    PlanePointPaths(splitH, splitV).each!((p) => builder.add(p, dg));
    return builder.build();
}

