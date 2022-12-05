from dataclasses import dataclass
from enum import IntEnum
from typing import Optional, Sequence, Tuple


class PolynomialDegree(IntEnum):
    AT_LINEARTYPE = 1
    AT_QUADRATICTYPE = 2
    AT_CUBICTYPE = 3
    AT_PARALLELELLIPSETYPE = 4
    AT_ELLIPSETYPE = 5
    AT_CIRCLETYPE = 6


@dataclass
class Point:
    x: float
    y: float
    z: float


@dataclass
class Color:
    r: int
    g: int
    b: int


@dataclass
class TraceOptions:
    background_color: Optional[Color] = None
    charcode: int = 0
    color_count: int = 0
    corner_always_threshold: float = 60.0
    corner_surround: int = 4
    corner_threshold: float = 100.0
    error_threshold: float = 2.0
    filter_iterations: int = 4
    line_reversion_threshold: float = 0.01
    line_threshold: float = 1.0
    remove_adjacent_corners: bool = False
    tangent_surround: int = 3
    despeckle_level: int = 0
    despeckle_tightness: float = 2.0
    noise_removal: float = 0.99
    centerline: bool = False
    preserve_width: bool = False
    width_weight_factor: float = 6.0


@dataclass
class Spline:
    points: Tuple[Point, Point, Point, Point]
    degree: PolynomialDegree
    linearity: float


@dataclass
class Path:
    splines: Sequence[Spline]
    color: Color
    clockwise: bool
    open: bool

    def __len__(self):
        return len(self.splines)


@dataclass
class Vector:
    paths: Sequence[Path]
    width: int
    height: int
    background_color: Color
    centerline: bool
    preserve_width: bool
    width_weight_factor: float

    def __len__(self):
        return len(self.paths)

    def save(self, filename: str, format: Optional[str] = None):
        _save(self, filename, format)


@dataclass
class Bitmap:
    data: Sequence[Sequence[Sequence[int]]]

    def __len__(self):
        return len(self.data)

    def trace(self, options: Optional[TraceOptions] = None) -> Vector:
        return _trace(self.data, options)


from ._autotrace import (  # noqa: E402
    save as _save,
    trace as _trace,
)
