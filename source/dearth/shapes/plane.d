/**
Plane shape.
*/
module dearth.shapes.plane;

import std.algorithm : each;
import std.array : array;

import dearth.opengl :
    createVAO,
    isVertexStruct,
    VertexArrayObject;

import dearth.shapes.utils :
    PlanePoints,
    PlanePointPaths,
    PointAppender;

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
    scope appender = PointAppender!T();
    PlanePointPaths(splitH, splitV).each!((p) => appender.add(p, dg));
    auto vao = createVAO!T();
    vao.loadVertices(appender.vertices);
    vao.loadIndices(appender.indices);
    return vao;
}

