# 'at' is short for 'autotrace' and refers to the C types, structs, and functions.

cimport libc.stdlib
cimport libc.stdio

import os
import tempfile

from ._autotrace cimport *
from .autotrace import Color, Path, Point, PolynomialDegree, Spline, Vector, VectorFormat


# Allocate memory and initialize it to zero.
cdef void *alloc(size_t size):
    cdef void *ptr = libc.stdlib.calloc(1, size)
    if ptr == NULL:
        raise MemoryError()

    return ptr


# Fixes a bug in AutoTrace's at_fitting_opts_free function.
cdef void at_fitting_opts_free(at_fitting_opts_type *opts):
    if opts.background_color != NULL:
        at_color_free(opts.background_color)

    libc.stdlib.free(opts)


# Convert an array object to an at_bitmap struct.
cdef at_bitmap *array_to_at_bitmap(data):
    cdef unsigned int height = len(data)
    cdef unsigned int width = len(data[0])
    cdef unsigned int np = len(data[0][0])

    cdef at_bitmap *bitmap = at_bitmap_new(width, height, np)

    cdef unsigned int x, y, p, i = 0
    for y in range(height):
        for x in range(width):
            for p in range(np):
                bitmap.bitmap[i] = data[y][x][p]
                i += 1

    return bitmap


# Convert a TraceOptions object to an at_fitting_opts struct.
cdef at_fitting_opts_type *trace_options_to_at_fitting_opts(options):
    cdef at_fitting_opts_type *opts = at_fitting_opts_new()

    if options.background_color is not None:
        opts.background_color = at_color_new(
            options.background_color.r,
            options.background_color.g,
            options.background_color.b,
        )

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


# Convert a Vector object to an at_spline_list_array struct.
cdef at_spline_list_array_type *vector_to_at_splines(vector):
    at_spline_list_array = <at_spline_list_array_type *>alloc(sizeof(at_spline_list_array_type))

    if vector.background_color is not None:
        at_spline_list_array.background_color = at_color_new(
            vector.background_color.r,
            vector.background_color.g,
            vector.background_color.b,
        )

    at_spline_list_array.width = vector.width
    at_spline_list_array.height = vector.height
    at_spline_list_array.centerline = vector.centerline
    at_spline_list_array.preserve_width = vector.preserve_width
    at_spline_list_array.width_weight_factor = vector.width_weight_factor
    at_spline_list_array.length = len(vector)
    at_spline_list_array.data = <at_spline_list_type *>alloc(sizeof(at_spline_list_type) * at_spline_list_array.length)

    cdef unsigned int i, j, k = 0
    for i in range(len(vector)):
        path = vector.paths[i]

        at_spline_list = &at_spline_list_array.data[i]
        at_spline_list.color.r = path.color.r
        at_spline_list.color.g = path.color.g
        at_spline_list.color.b = path.color.b
        at_spline_list.clockwise = path.clockwise
        at_spline_list.open = path.open
        at_spline_list.length = len(path)
        at_spline_list.data = <at_spline_type *>alloc(sizeof(at_spline_type) * at_spline_list.length)

        for j in range(len(path)):
            spline = path.splines[j]

            at_spline = &at_spline_list.data[j]
            at_spline.degree = spline.degree
            at_spline.linearity = spline.linearity

            for k in range(4):
                at_spline.v[k].x = spline.points[k].x
                at_spline.v[k].y = spline.points[k].y
                at_spline.v[k].z = spline.points[k].z

    return at_spline_list_array


# Convert an at_spline_list_array struct to a Vector object.
cdef at_splines_to_vector(at_spline_list_array_type *at_spline_list_array):
    if at_spline_list_array.background_color != NULL:
        background_color = Color(
            r=at_spline_list_array.background_color.r,
            g=at_spline_list_array.background_color.g,
            b=at_spline_list_array.background_color.b,
        )
    else:
        background_color = None

    vector = Vector(
        paths=[],
        width=at_spline_list_array.width,
        height=at_spline_list_array.height,
        background_color=background_color,
        centerline=at_spline_list_array.centerline,
        preserve_width=at_spline_list_array.preserve_width,
        width_weight_factor=at_spline_list_array.width_weight_factor,
    )

    cdef unsigned int i, j, k = 0
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
                degree=PolynomialDegree(at_spline.degree),
                linearity=at_spline.linearity,
                _raw_spline=at_spline,
            )

            for k in range(4):
                point = Point(
                    x=at_spline.v[k].x,
                    y=at_spline.v[k].y,
                    z=at_spline.v[k].z,
                )

                spline.points.append(point)

            path.splines.append(spline)

        vector.paths.append(path)

    return vector


# Trace a bitmap image.
def trace(data, options = None):
    cdef at_bitmap *bitmap = array_to_at_bitmap(data)
    cdef at_fitting_opts_type *opts

    if options is not None:
        opts = trace_options_to_at_fitting_opts(options)
    else:
        opts = at_fitting_opts_new()

    cdef at_spline_list_array_type *at_spline_list_array = at_splines_new(bitmap, opts, NULL, NULL)
    vector = at_splines_to_vector(at_spline_list_array)

    at_bitmap_free(bitmap)
    at_fitting_opts_free(opts)
    at_splines_free(at_spline_list_array)

    return vector


# Encode a Vector object and return the data as bytes.
def encode(vector, format) -> bytes:
    file = tempfile.NamedTemporaryFile(delete=False)
    filename = file.name
    file.close()

    try:
        save(vector, filename, format)
        with open(filename, "rb") as file:
            data = file.read()
    finally:
        os.remove(filename)

    return data


# Save a Vector object to a file.
def save(vector, filename, format = None):
    if isinstance(filename, bytes):
        filename_bytes = filename
    else:
        filename_bytes = filename.encode("utf-8")

    if isinstance(format, VectorFormat):
        format = format.value

    cdef at_spline_writer *writer = NULL

    if format is None:
        writer = at_output_get_handler(filename_bytes)
        if writer is NULL:
            raise ValueError(f"could not find output format for filename '{filename}'")
    else:
        writer = at_output_get_handler_by_suffix(format.encode("utf-8"))
        if writer is NULL:
            raise ValueError(f"unknown output format '{format}'")

    cdef FILE *fd = libc.stdio.fopen(filename_bytes, "wb")
    if fd is NULL:
        raise IOError(f"could not open file '{filename}' for writing")

    cdef at_spline_list_array_type *at_spline_list_array = vector_to_at_splines(vector)

    at_splines_write(writer, fd, filename_bytes, NULL, at_spline_list_array, NULL, NULL)

    libc.stdio.fclose(fd)
    at_splines_free(at_spline_list_array)


# Evaluate a spline at a given T value in the range [0.0, 1.0].
def eval_spline(spline, t: float):
    cdef at_real_coord coord = evaluate_spline(spline, t)
    return Point(
        x=coord.x,
        y=coord.y,
        z=coord.z,
    )

# Initialize AutoTrace.
autotrace_init()
