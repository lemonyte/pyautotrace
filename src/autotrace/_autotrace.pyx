# 'at' is short for 'autotrace' and refers to the C types, structs, and functions.

cimport libc.stdlib
cimport libc.stdio

import os
import tempfile
import warnings

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
# AutoTrace only supports 1 (grayscale) or 3 (RGB) planes, so the alpha channel of RGBA data
# is composited onto the background color, or onto white if no background color is given.
cdef at_bitmap *array_to_at_bitmap(data, background_color = None):
    cdef unsigned int height = len(data)
    cdef unsigned int width = len(data[0])
    cdef unsigned int np = len(data[0][0])

    if np != 1 and np != 3 and np != 4:
        raise ValueError(f"bitmap must have 1, 3, or 4 channels, got {np}")

    cdef bint has_alpha = np == 4
    cdef unsigned int background[3]
    background[0] = background[1] = background[2] = 255
    if has_alpha:
        np = 3
        if background_color is not None:
            background[0] = background_color.r
            background[1] = background_color.g
            background[2] = background_color.b

    cdef at_bitmap *bitmap = at_bitmap_new(width, height, np)

    cdef unsigned int x, y, p, value, alpha, i = 0
    try:
        for y in range(height):
            for x in range(width):
                pixel = data[y][x]

                if has_alpha:
                    alpha = pixel[3]
                    for p in range(np):
                        value = pixel[p]
                        bitmap.bitmap[i] = (value * alpha + background[p] * (255 - alpha) + 127) // 255
                        i += 1
                else:
                    for p in range(np):
                        bitmap.bitmap[i] = pixel[p]
                        i += 1
    except:
        at_bitmap_free(bitmap)
        raise

    return bitmap


# Convert a TraceOptions object to an at_fitting_opts struct.
cdef at_fitting_opts_type *trace_options_to_at_fitting_opts(options):
    cdef at_fitting_opts_type *opts = at_fitting_opts_new()

    try:
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
    except:
        at_fitting_opts_free(opts)
        raise

    return opts


# Convert a Vector object to an at_spline_list_array struct.
cdef at_spline_list_array_type *vector_to_at_splines(vector):
    at_spline_list_array = <at_spline_list_array_type *>alloc(sizeof(at_spline_list_array_type))

    cdef unsigned int i, j, k = 0
    try:
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
        at_spline_list_array.data = <at_spline_list_type *>alloc(sizeof(at_spline_list_type) * len(vector))
        at_spline_list_array.length = len(vector)

        for i in range(len(vector)):
            path = vector.paths[i]

            at_spline_list = &at_spline_list_array.data[i]
            at_spline_list.color.r = path.color.r
            at_spline_list.color.g = path.color.g
            at_spline_list.color.b = path.color.b
            at_spline_list.clockwise = path.clockwise
            at_spline_list.open = path.open
            at_spline_list.data = <at_spline_type *>alloc(sizeof(at_spline_type) * len(path))
            at_spline_list.length = len(path)

            for j in range(len(path)):
                spline = path.splines[j]

                at_spline = &at_spline_list.data[j]
                at_spline.degree = spline.degree
                at_spline.linearity = spline.linearity

                for k in range(4):
                    at_spline.v[k].x = spline.points[k].x
                    at_spline.v[k].y = spline.points[k].y
                    at_spline.v[k].z = spline.points[k].z
    except:
        at_splines_free(at_spline_list_array)
        raise

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


# Collect fatal error and warning messages reported by AutoTrace.
# 'client_data' is a borrowed reference to a tuple of two Python lists, (errors, warnings).
cdef void on_trace_message(const gchar *msg, at_msg_type msg_type, gpointer client_data) noexcept:
    errors, warning_messages = <tuple>client_data
    if msg_type == AT_MSG_FATAL:
        errors.append(msg.decode("utf-8", "replace"))
    elif msg_type == AT_MSG_WARNING:
        warning_messages.append(msg.decode("utf-8", "replace"))


# Trace a bitmap image.
def trace(data, options = None):
    cdef at_bitmap *bitmap = NULL
    cdef at_fitting_opts_type *opts = NULL
    cdef at_spline_list_array_type *at_spline_list_array = NULL

    errors = []
    warning_messages = []
    messages = (errors, warning_messages)
    try:
        bitmap = array_to_at_bitmap(
            data,
            options.background_color if options is not None else None,
        )

        if options is not None:
            opts = trace_options_to_at_fitting_opts(options)
        else:
            opts = at_fitting_opts_new()

        at_spline_list_array = at_splines_new(bitmap, opts, on_trace_message, <gpointer>messages)
    finally:
        if bitmap != NULL:
            at_bitmap_free(bitmap)
        if opts != NULL:
            at_fitting_opts_free(opts)

    try:
        for message in warning_messages:
            warnings.warn(f"AutoTrace: {message}", RuntimeWarning, stacklevel=2)

        if errors:
            raise RuntimeError(f"AutoTrace failed: {errors[0]}")

        vector = at_splines_to_vector(at_spline_list_array)
    finally:
        if errors:
            # On a fatal error AutoTrace returns either NULL or an uninitialized struct,
            # so the struct itself is freed without touching its contents.
            libc.stdlib.free(at_spline_list_array)
        else:
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

    cdef at_spline_list_array_type *at_spline_list_array = vector_to_at_splines(vector)

    cdef FILE *fd = libc.stdio.fopen(filename_bytes, "wb")
    if fd is NULL:
        at_splines_free(at_spline_list_array)
        raise IOError(f"could not open file '{filename}' for writing")

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
