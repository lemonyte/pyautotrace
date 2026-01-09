---
title: Evaluate points
---

# Evaluating real points on a spline

[`Vector`](../reference.md#autotrace.Vector) objects are made up of [`Path`](../reference.md#autotrace.Path) objects, which are made up of [`Spline`](../reference.md#autotrace.Spline) objects, which in turn are defined by four [`Point`](../reference.md#autotrace.Point)s.
These points represent the control points of a cubic Bézier curve.

To get a real coordinate somewhere along a spline, it must be calculated from the control points.

You can use the [`evaluate`](../reference.md#autotrace.Spline.evaluate) method on a [`Spline`](../reference.md#autotrace.Spline) to get a [`Point`](../reference.md#autotrace.Point) at a specific distance along the spline.
The distance is represented by a float in the range `0.0..1.0`, where `0.0` corresponds to the start of the spline and `1.0` corresponds to the end.

```python hl_lines="5 7"
# Get the first spline of the first path.
spline = vector.paths[0].splines[0]

# Get the middle point of the spline.
midpoint = spline.evaluate(0.5)
# Get the point at 78% along the spline.
other_point = spline.evaluate(0.78)
```

!!! note
    Calling `spline.evaluate(0)` and `spline.evaluate(1)` is useless, as they will calculate the start and end points of the spline, which are already available as `spline.points[0]` and `spline.points[-1]` respectively.
