"""Python bindings for AutoTrace."""

from .autotrace import (
    Bitmap,
    Color,
    Path,
    Point,
    PolynomialDegree,
    Spline,
    TraceOptions,
    Vector,
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
    "trace",
    "__version__",
]
__version__ = "0.0.3"
