# ruff: noqa: ANN101
"""TODO: module docstring"""

from __future__ import annotations

import os
from dataclasses import dataclass
from enum import Enum, IntEnum
from typing import TYPE_CHECKING, Sequence, overload

if TYPE_CHECKING:
    from os import PathLike

    import numpy as np
    from numpy.typing import NDArray


class VectorFormat(Enum):
    """Vector output formats."""

    AI = "ai"
    CGM = "cgm"
    DR2D = "dr2d"
    DXF = "dxf"
    EMF = "emf"
    EPD = "epd"
    EPS = "eps"
    ER = "er"
    FIG = "fig"
    ILD = "ild"
    MIF = "mif"
    P2E = "p2e"
    PDF = "pdf"
    PLT = "plt"
    POV = "pov"
    SK = "sk"
    SVG = "svg"
    UGS = "ugs"


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
    background_color: Color | None = None
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
    """Represents a sequence four of points.

    Attributes:
        points: A sequence four points.
        degree: The degree of the spline.
        linearity: TODO: ???
    """

    points: tuple[Point, Point, Point, Point]
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

    def __len__(self) -> int:
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

    def __len__(self) -> int:
        return len(self.paths)

    def save(
        self,
        filename: PathLike | str | bytes,
        /,
        *,
        format: VectorFormat | str | None = None,
    ) -> None:
        """Save the vector to a file.

        Args:
            filename: The name of the file to save to.
            format: The format to save the vector as. If not specified, the
                format will be inferred from the filename.
        """

        _save(self, os.fspath(filename), format)

    def encode(self, format: VectorFormat | str) -> bytes:
        """Encode the vector using the specified format and return the bytes.

        Args:
            format: The format to encode the vector as.

        Returns:
            bytes: The encoded vector data.
        """

        return _encode(self, format)


class Bitmap:
    """Represents a bitmap image.

    Attributes:
        data: The bitmap data.
    """

    def __init__(
        self,
        data: Sequence[Sequence[Sequence[int]]] | NDArray[np.uint8],
        /,
    ) -> None:
        self.data = data

    def __len__(self) -> int:
        return len(self.data)

    @overload
    # pylint: disable=too-many-arguments, too-many-locals
    def trace(  # noqa: PLR0913
        self,
        *,
        background_color: Color | None = None,
        charcode: int = 0,
        color_count: int = 0,
        corner_always_threshold: float = 60.0,
        corner_surround: int = 4,
        corner_threshold: float = 100.0,
        error_threshold: float = 2.0,
        filter_iterations: int = 4,
        line_reversion_threshold: float = 0.01,
        line_threshold: float = 1.0,
        remove_adjacent_corners: bool = False,
        tangent_surround: int = 3,
        despeckle_level: int = 0,
        despeckle_tightness: float = 2.0,
        noise_removal: float = 0.99,
        centerline: bool = False,
        preserve_width: bool = False,
        width_weight_factor: float = 6.0,
    ) -> Vector:
        ...

    @overload
    def trace(
        self,
        *,
        options: TraceOptions,
    ) -> Vector:
        ...

    # pylint: disable=too-many-arguments, too-many-locals
    def trace(  # noqa: PLR0913
        self,
        *,
        background_color: Color | None = None,
        charcode: int = 0,
        color_count: int = 0,
        corner_always_threshold: float = 60.0,
        corner_surround: int = 4,
        corner_threshold: float = 100.0,
        error_threshold: float = 2.0,
        filter_iterations: int = 4,
        line_reversion_threshold: float = 0.01,
        line_threshold: float = 1.0,
        remove_adjacent_corners: bool = False,
        tangent_surround: int = 3,
        despeckle_level: int = 0,
        despeckle_tightness: float = 2.0,
        noise_removal: float = 0.99,
        centerline: bool = False,
        preserve_width: bool = False,
        width_weight_factor: float = 6.0,
        options: TraceOptions | None = None,
    ) -> Vector:
        """Trace a vector from the bitmap.

        Args:
            options: Options to use when tracing the image.

        Returns:
            Vector: The traced vector image.
        """

        if options is None:
            options = TraceOptions(
                background_color=background_color,
                charcode=charcode,
                color_count=color_count,
                corner_always_threshold=corner_always_threshold,
                corner_surround=corner_surround,
                corner_threshold=corner_threshold,
                error_threshold=error_threshold,
                filter_iterations=filter_iterations,
                line_reversion_threshold=line_reversion_threshold,
                line_threshold=line_threshold,
                remove_adjacent_corners=remove_adjacent_corners,
                tangent_surround=tangent_surround,
                despeckle_level=despeckle_level,
                despeckle_tightness=despeckle_tightness,
                noise_removal=noise_removal,
                centerline=centerline,
                preserve_width=preserve_width,
                width_weight_factor=width_weight_factor,
            )

        return _trace(self.data, options)


# pyright: reportMissingImports=false
# pylint: disable=import-error, wrong-import-position
from ._autotrace import encode as _encode  # noqa: E402
from ._autotrace import save as _save  # noqa: E402
from ._autotrace import trace as _trace  # noqa: E402
