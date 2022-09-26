# 'at' is short for 'autotrace' and refers to the C types and functions

from dataclasses import dataclass
from enum import IntEnum
from typing import List, Optional, Tuple

cimport libc.stdlib
cimport libc.stdio

from autotrace._autotrace cimport *


# class Bitmap:
#     def __init__(self, data):
#         self.data = data


@dataclass
class FittingOptions:
    background_color: Color
    charcode: int
    color_count: int
    corner_always_threshold: float
    corner_surround: int
    corner_threshold: float
    error_threshold: float
    filter_iterations: int
    line_reversion_threshold: float
    line_threshold: float
    remove_adjacent_corners: bool
    tangent_surround: int
    despeckle_level: int
    despeckle_tightness: float
    noise_removal: float
    centerline: bool
    preserve_width: bool
    width_weight_factor: float


class PolynomialDegree(IntEnum):
    AT_LINEARTYPE = 1
    AT_QUADRATICTYPE = 2
    AT_CUBICTYPE = 3
    AT_PARALLELELLIPSETYPE = 4
    AT_ELLIPSETYPE = 5
    AT_CIRCLETYPE = 6


class Point:
    def __init__(self, x: float, y: float, z: float):
        self.x = x
        self.y = y
        self.z = z


class Color:
    def __init__(self, r: int, g: int, b: int):
        self.r = r
        self.g = g
        self.b = b


class Spline:
    def __init__(
        self,
        points: Tuple[Point, Point, Point, Point],
        degree: PolynomialDegree,
        linearity: float,
    ):
        self.points = points
        self.degree = degree
        self.linearity = linearity


class Path:
    def __init__(self, splines: List[Spline], color: Color, clockwise: bool, open: bool):
        self.splines = splines
        self.color = color
        self.clockwise = clockwise
        self.open = open

    def __len__(self):
        return len(self.splines)


class VectorImage:
    def __init__(
        self,
        paths: List[Path],
        width: int,
        height: int,
        background_color: Color,
        centerline: bool,
        preserve_width: bool,
        width_weight_factor: float,
    ):
        self.paths = paths
        self.width = width
        self.height = height
        self.background_color = background_color
        self.centerline = centerline
        self.preserve_width = preserve_width
        self.width_weight_factor = width_weight_factor

    def __len__(self):
        return len(self.paths)


cdef at_bitmap* array_to_at_bitmap(data):
    cdef int height = len(data)
    cdef int width = len(data[0])
    cdef int np = len(data[0][0])
    cdef int size = width * height * np

    cdef at_bitmap* bitmap = <at_bitmap*>libc.stdlib.malloc(sizeof(at_bitmap))
    bitmap.width = width
    bitmap.height = height
    bitmap.np = np
    bitmap.bitmap = <unsigned char*>libc.stdlib.malloc(size)

    cdef int x, y, p, i = 0
    for y in range(height):
        for x in range(width):
            for p in range(np):
                bitmap.bitmap[i] = data[y][x][p]
                i += 1

    return bitmap


cdef at_fitting_opts_type* fitting_options_to_at_fitting_opts(options: FittingOptions):
    cdef at_fitting_opts_type* opts = at_fitting_opts_new()
    if options.background_color is not None:
        opts.background_color = <at_color*>libc.stdlib.malloc(sizeof(at_color))
        opts.background_color.r = options.background_color.r
        opts.background_color.g = options.background_color.g
        opts.background_color.b = options.background_color.b
    opts.charcode = options.charcode
    opts.color_count = options.color_count
    opts.corner_always_threshold = options.corner_always_threshold
    opts.corner_surround = options.corner_surround
    opts.corner_threshold = options.corner_threshold
    opts.error_threshold = options.error_threshold
    opts.filter_iterations = options.filter_iterations
    opts.line_reversion_threshold = options.line_reversion_threshold
    opts.line_threshold = options.line_threshold
    opts.remove_adjacent_corners = options.remove_adjacent_corners
    opts.tangent_surround = options.tangent_surround
    opts.despeckle_level = options.despeckle_level
    opts.despeckle_tightness = options.despeckle_tightness
    opts.noise_removal = options.noise_removal
    opts.centerline = options.centerline
    opts.preserve_width = options.preserve_width
    opts.width_weight_factor = options.width_weight_factor
    return opts


cdef at_spline_list_array_type* vector_image_to_at_splines(vector_image: VectorImage):
    at_spline_list_array = <at_spline_list_array_type*>libc.stdlib.malloc(sizeof(at_spline_list_array_type))
    at_spline_list_array.width = vector_image.width
    at_spline_list_array.height = vector_image.height
    at_spline_list_array.centerline = vector_image.centerline
    at_spline_list_array.preserve_width = vector_image.preserve_width
    at_spline_list_array.width_weight_factor = vector_image.width_weight_factor

    if vector_image.background_color is not None:
        at_spline_list_array.background_color = <at_color*>libc.stdlib.malloc(sizeof(at_color))
        at_spline_list_array.background_color.r = vector_image.background_color.r
        at_spline_list_array.background_color.g = vector_image.background_color.g
        at_spline_list_array.background_color.b = vector_image.background_color.b

    at_spline_list_array.length = len(vector_image)
    # at_spline_list_array.data = <at_spline_list_type**>libc.stdlib.malloc(sizeof(at_spline_list_type*) * at_spline_list_array.length)
    at_spline_list_array.data = <at_spline_list_type*>libc.stdlib.malloc(sizeof(at_spline_list_type) * at_spline_list_array.length)

    cdef int i, j, k
    for i in range(len(vector_image)):
        path = vector_image.paths[i]

        # at_spline_list = <at_spline_list_type*>libc.stdlib.malloc(sizeof(at_spline_list_type))
        at_spline_list = &at_spline_list_array.data[i]
        # at_spline_list.color = <at_color*>libc.stdlib.malloc(sizeof(at_color))
        at_spline_list.color.r = path.color.r
        at_spline_list.color.g = path.color.g
        at_spline_list.color.b = path.color.b
        at_spline_list.clockwise = path.clockwise
        at_spline_list.open = path.open
        at_spline_list.length = len(path)
        # at_spline_list.data = <at_spline_type**>libc.stdlib.malloc(sizeof(at_spline_type*) * at_spline_list.length)
        at_spline_list.data = <at_spline_type*>libc.stdlib.malloc(sizeof(at_spline_type) * at_spline_list.length)

        for j in range(len(path)):
            spline = path.splines[j]

            # at_spline = <at_spline_type*>libc.stdlib.malloc(sizeof(at_spline_type))
            at_spline = &at_spline_list.data[j]
            at_spline.degree = spline.degree
            at_spline.linearity = spline.linearity
            # at_spline.v = <at_point_type*>libc.stdlib.malloc(sizeof(at_point_type) * 4)

            for k in range(4):
                at_spline.v[k].x = spline.points[k].x
                at_spline.v[k].y = spline.points[k].y
                at_spline.v[k].z = spline.points[k].z

    return at_spline_list_array


cdef at_splines_to_vector_image(at_spline_list_array_type* at_spline_list_array):
    if at_spline_list_array.background_color != NULL:
        background_color = Color(
            r=at_spline_list_array.background_color.r,
            g=at_spline_list_array.background_color.g,
            b=at_spline_list_array.background_color.b,
        )
    else:
        background_color = None

    vector_image = VectorImage(
        paths=[],
        width=at_spline_list_array.width,
        height=at_spline_list_array.height,
        background_color=background_color,
        centerline=at_spline_list_array.centerline,
        preserve_width=at_spline_list_array.preserve_width,
        width_weight_factor=at_spline_list_array.width_weight_factor,
    )

    for i in range(at_spline_list_array.length):
        at_spline_list = at_spline_list_array.data[i]

        color = Color(
            r=at_spline_list.color.r,
            g=at_spline_list.color.g,
            b=at_spline_list.color.b,
        )

        path = Path(
            splines=[],
            color=color,
            clockwise=at_spline_list.clockwise,
            open=at_spline_list.open,
        )

        for j in range(at_spline_list.length):
            at_spline = at_spline_list.data[j]

            spline = Spline(
                points=[],
                degree=at_spline.degree,
                linearity=at_spline.linearity,
            )

            for k in range(4):
                point = Point(
                    x=at_spline.v[k].x,
                    y=at_spline.v[k].y,
                    z=at_spline.v[k].z,
                )
                spline.points.append(point)

            path.splines.append(spline)

        vector_image.paths.append(path)

    return vector_image


cpdef trace(data, options: Optional[FittingOptions] = None):
    cdef at_bitmap* bitmap = array_to_at_bitmap(data)
    cdef at_fitting_opts_type* opts
    if options is not None:
        opts = fitting_options_to_at_fitting_opts(options)
    else:
        opts = at_fitting_opts_new()
    cdef at_spline_list_array_type* at_spline_list_array = at_splines_new(bitmap, opts, NULL, NULL)
    vector_image = at_splines_to_vector_image(at_spline_list_array)
    at_bitmap_free(bitmap)
    at_fitting_opts_free(opts)
    at_splines_free(at_spline_list_array)
    return vector_image


cpdef save_image(vector_image: VectorImage, filename: str, format: Optional[str] = None):
    if not isinstance(vector_image, VectorImage):
        raise TypeError("vector_image must be of type VectorImage")
    filename_bytes = filename.encode("utf-8")
    cdef at_spline_list_array_type* at_spline_list_array = vector_image_to_at_splines(vector_image)
    cdef at_spline_writer* writer = NULL
    if format is None:
        writer = at_output_get_handler(filename_bytes)
        if writer is NULL:
            raise ValueError(f"could not find output format for filename '{filename}'")
    else:
        writer = at_output_get_handler_by_suffix(format.encode("utf-8"))
        if writer is NULL:
            raise ValueError(f"unknown output format '{format}'")
    cdef FILE* fd = libc.stdio.fopen(filename_bytes, "wb")
    if fd is NULL:
        raise IOError(f"could not open file '{filename}' for writing")
    at_splines_write(writer, fd, filename_bytes, NULL, at_spline_list_array, NULL, NULL)
    libc.stdio.fclose(fd)
    at_splines_free(at_spline_list_array)


autotrace_init()
