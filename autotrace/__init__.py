"""Python bindings for AutoTrace."""

from autotrace.autotrace import (
    Bitmap,
    Color,
    Path,
    Point,
    PolynomialDegree,
    Spline,
    TraceOptions,
    Vector,
    VectorFormat,
    trace,
)

__all__ = [
    "Bitmap",
    "Color",
    "Path",
    "Point",
    "PolynomialDegree",
    "Spline",
    "TraceOptions",
    "Vector",
    "VectorFormat",
    "trace",
    "__version__",
]
__version__ = "0.0.4"
