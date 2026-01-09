"""Python bindings for AutoTrace."""

import os
from collections.abc import Iterator, Sequence
from dataclasses import dataclass
from enum import Enum, IntEnum
from typing import TYPE_CHECKING, overload

if TYPE_CHECKING:
    from numpy import uint8
    from numpy.typing import NDArray


class VectorFormat(Enum):
    """Vector output formats."""

    AI = "ai"
    """Adobe Illustrator"""
    CGM = "cgm"
    """Computer Graphics Metafile"""
    DR2D = "dr2d"
    """IFF 2-D Object"""
    DXF = "dxf"
    """AutoCAD Drawing Exchange Format"""
    EMF = "emf"
    """Enhanced Metafile Format"""
    EPD = "epd"
    """Encapsulated Vectorial Graphic Format"""
    EPS = "eps"
    """Encapsulated PostScript"""
    ER = "er"
    """Elastic Reality Shape Format"""
    FIG = "fig"
    """Xfig 3.2 Drawing"""
    ILD = "ild"
    """International Laser Display Association Data Transfer Format"""
    MIF = "mif"
    """FrameMaker MapInfo Interchange Format"""
    P2E = "p2e"
    """`pstoedit` Frontend Format"""
    PDF = "pdf"
    """Portable Document Format"""
    PLT = "plt"
    """HPGL Plot File"""
    POV = "pov"
    """POV-Ray Scene Description"""
    SK = "sk"
    """Sketch/Skencil Drawing"""
    SVG = "svg"
    """Scalable Vector Graphic"""
    UGS = "ugs"
    """Unicode Glyph Source"""


class PolynomialDegree(IntEnum):
    """Represents the degree of a spline."""

    LINEAR = 1
    QUADRATIC = 2
    CUBIC = 3
    PARALLEL_ELLIPSE = 4
    ELLIPSE = 5
    CIRCLE = 6


@dataclass
class Point:
    """Represents a real coordinate point."""

    x: float
    """The x coordinate."""
    y: float
    """The y coordinate."""
    z: float
    """The z coordinate."""

    def __iter__(self) -> Iterator[float]:
        yield self.x
        yield self.y
        yield self.z


@dataclass
class Color:
    """Represents a color. All components are in the range `0..255`."""

    r: int
    """The red component."""
    g: int
    """The green component."""
    b: int
    """The blue component."""

    def __iter__(self) -> Iterator[int]:
        yield self.r
        yield self.g
        yield self.b


@dataclass
class TraceOptions:
    """Options for tracing an image."""

    background_color: Color | None = None
    """The color of the background that should be ignored."""
    charcode: int = 0
    """Code of character to load from GF file, allowed are 0..255; default is the first character in font."""
    color_count: int = 0
    """Number of colors a color bitmap is reduced to, it does not work on grayscale, allowed are 1..256;
    0 means no color reduction is done."""
    corner_always_threshold: float = 60.0
    """If the angle at a pixel is less than this, it is considered a corner,
    even if it is within `corner_surround` pixels of another corner.
    """
    corner_surround: int = 4
    """Number of pixels on either side of a point to consider when determining if that point is a corner."""
    corner_threshold: float = 100.0
    """If a pixel, its predecessor(s), and its successor(s) meet at an angle smaller than this, it's a corner."""
    error_threshold: float = 2.0
    """Subdivide fitted curves that are off by more pixels than this"""
    filter_iterations: int = 4
    """Smooth the curve this many times before fitting."""
    line_reversion_threshold: float = 0.01
    """If a spline is closer to a straight line than this,
    weighted by the square of the curve length, keep it a straight line even if it is a list with curves.
    """
    line_threshold: float = 1.0
    """If the spline is not more than this far away
    from the straight line defined by its endpoints, then output a straight line."""
    remove_adjacent_corners: bool = False
    """Remove corners that are adjacent."""
    tangent_surround: int = 3
    """Number of points on either side of a point to consider when computing the tangent at that point."""
    despeckle_level: int = 0
    """Level of despeckling to perform in the range `0..20`."""
    despeckle_tightness: float = 2.0
    """Tightness of despeckling in the range `0.0..8.0`."""
    noise_removal: float = 0.99
    """Amount of noise to remove in the range `0.0..1.0`."""
    centerline: bool = False
    """Trace a character's centerline, rather than its outline."""
    preserve_width: bool = False
    """Whether to preserve linewidth with centerline fitting."""
    width_weight_factor: float = 6.0
    """Weight factor for fitting the linewidth."""


@dataclass
class Spline:
    """Represents a sequence four of points."""

    points: tuple[Point, Point, Point, Point]
    """A sequence of four points defining the spline."""
    degree: PolynomialDegree
    """The degree of the spline."""
    linearity: float
    """The divergence of the spline from the straight line between its endpoints."""
    _raw_spline: object
    """Raw `at_spline_type` object for re-using in evaluations."""

    def evaluate(self, t: float, /) -> Point:
        """Evaluate the spline at a given T value.

        Args:
            t: T value in the range `0.0..1.0`.

        Returns:
            The sampled point on the spline at the given T value.
        """
        return _eval_spline(self._raw_spline, t)


@dataclass
class Path:
    """Represents a sequence of splines."""

    splines: Sequence[Spline]
    """A sequence of splines."""
    color: Color
    """The color of the path."""
    clockwise: bool
    """Whether the outline that this path represents moves clockwise or counterclockwise."""
    open: bool
    """Whether the outline is open (i.e., doesn't return to the starting coordinate)."""

    def __len__(self) -> int:
        return len(self.splines)


@dataclass
class Vector:
    """Represents a vector image."""

    paths: Sequence[Path]
    """A sequence of paths."""
    width: int
    """The width of the image."""
    height: int
    """The height of the image."""
    background_color: Color
    """The background color."""
    centerline: bool
    """See `TraceOptions.centerline`."""
    preserve_width: bool
    """See `TraceOptions.preserve_width`."""
    width_weight_factor: float
    """See `TraceOptions.width_weight_factor`."""

    def __len__(self) -> int:
        return len(self.paths)

    def save(
        self,
        filename: os.PathLike | str | bytes,
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

    def encode(self, format: VectorFormat | str, /) -> bytes:
        """Encode the vector using the specified format and return the bytes.

        Args:
            format: The format to encode the vector as.

        Returns:
            The encoded vector data.
        """

        return _encode(self, format)


@dataclass
class Bitmap:
    """Represents a bitmap image."""

    data: "Sequence[Sequence[Sequence[int]]] | NDArray[uint8]"
    """The bitmap data as a 3D sequence of pixel values or a NumPy array of shape (height, width, 3)."""

    def __len__(self) -> int:
        return len(self.data)

    @overload
    def trace(
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
    ) -> Vector: ...

    @overload
    def trace(
        self,
        *,
        options: TraceOptions,
    ) -> Vector: ...

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

        Options can either be provided as individual parameters or as a `TraceOptions` instance.
        See `TraceOptions` for documentation of each option.

        Returns:
            The traced vector image.
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


from ._autotrace import encode as _encode  # noqa: E402 # ty: ignore[unresolved-import]
from ._autotrace import eval_spline as _eval_spline  # noqa: E402 # ty: ignore[unresolved-import]
from ._autotrace import save as _save  # noqa: E402 # ty: ignore[unresolved-import]
from ._autotrace import trace as _trace  # noqa: E402 # ty: ignore[unresolved-import]
