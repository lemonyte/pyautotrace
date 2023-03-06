"""TODO: module docstring"""

from dataclasses import dataclass
from enum import IntEnum
from typing import Optional, Sequence, Tuple


class PolynomialDegree(IntEnum):
    """TODO: class docstring"""

    AT_LINEARTYPE = 1
    AT_QUADRATICTYPE = 2
    AT_CUBICTYPE = 3
    AT_PARALLELELLIPSETYPE = 4
    AT_ELLIPSETYPE = 5
    AT_CIRCLETYPE = 6


@dataclass
class Point:
    """Represents a point.

    Attributes:
        x: The x coordinate.
        y: The y coordinate.
        z: The z coordinate.
    """

    x: float
    y: float
    z: float


@dataclass
class Color:
    """Represents a color.

    Attributes:
        r: The red component.
        g: The green component.
        b: The blue component.
    """

    r: int
    g: int
    b: int


@dataclass
class TraceOptions:
    """Options for tracing an image.

    Attributes:
        background_color: The background color.
        TODO: rest of the options
    """

    # pylint: disable=too-many-instance-attributes
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
    """Represents a sequence of points.

    Attributes:
        points: A sequence points.
        degree: The degree of the spline.
        linearity: TODO: ???
    """

    points: Tuple[Point, Point, Point, Point]
    degree: PolynomialDegree
    linearity: float


@dataclass
class Path:
    """Represents a sequence of splines.

    Attributes:
        splines: A sequence of splines.
        color: The color of the path.
        clockwise: TODO: ???
        open: TODO: ???
    """

    splines: Sequence[Spline]
    color: Color
    clockwise: bool
    open: bool

    def __len__(self):
        return len(self.splines)


@dataclass
class Vector:
    """Represents a vector image.

    Attributes:
        paths: A sequence of paths.
        width: The width of the image.
        height: The height of the image.
        background_color: The background color.
        centerline: TODO: ???
        preserve_width: TODO: ???
        width_weight_factor: TODO: ???
    """

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
        """Save the image to a file.

        Args:
            filename: The name of the file to save to.
            format: The format to save the image as. If not specified, the
                format will be inferred from the filename.
        """

        _save(self, filename, format)


@dataclass
class Bitmap:
    """Represents a bitmap image.

    Attributes:
        data: The bitmap data.
    """

    data: Sequence[Sequence[Sequence[int]]]

    def __len__(self):
        return len(self.data)

    def trace(self, options: Optional[TraceOptions] = None) -> Vector:
        """Trace a vector from the bitmap.

        Args:
            options: Options to use when tracing the image.

        Returns:
            Vector: The traced vector image.
        """

        return _trace(self.data, options)


def trace(image: Sequence[Sequence[Sequence[int]]], options: Optional[TraceOptions] = None) -> Vector:
    """Trace a vector from a bitmap. Convenience function for `Bitmap.trace()`.

    Args:
        image: The bitmap image.
        options: Options to use when tracing the image.

    Returns:
        Vector: The traced vector image.
    """

    return Bitmap(image).trace(options)


# pyright: reportMissingImports=false
# pylint: disable=import-error, wrong-import-position
from ._autotrace import save as _save  # noqa: E402
from ._autotrace import trace as _trace  # noqa: E402
