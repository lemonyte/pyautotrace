from libc.stdio cimport FILE

# https://github.com/GNOME/glib/blob/main/glib/gtypes.h
cdef extern from "glib.h":
    ctypedef bint gboolean
    ctypedef char gchar
    ctypedef float gfloat
    ctypedef void* gpointer
    ctypedef unsigned char guint8

# https://github.com/autotrace/autotrace/blob/master/src/color.h
cdef extern from "color.h":
    ctypedef _at_color at_color
    struct _at_color:
        unsigned char r
        unsigned char g
        unsigned char b

    at_color* at_color_new(guint8 r, guint8 g, guint8 b)
    void at_color_free(at_color* color)

# https://github.com/autotrace/autotrace/blob/master/src/types.h
cdef extern from "types.h":
    ctypedef _at_real_coord at_real_coord
    struct _at_real_coord:
        float x
        float y
        float z

# https://github.com/autotrace/autotrace/blob/master/src/autotrace.h
cdef extern from "autotrace.h":
    ctypedef _at_polynomial_degree at_polynomial_degree
    enum _at_polynomial_degree:
        AT_LINEARTYPE = 1,
        AT_QUADRATICTYPE = 2,
        AT_CUBICTYPE = 3,
        AT_PARALLELELLIPSETYPE = 4,
        AT_ELLIPSETYPE = 5,
        AT_CIRCLETYPE = 6,

    ctypedef _at_msg_type at_msg_type
    enum _at_msg_type:
        AT_MSG_NOT_SET = 0,
        AT_MSG_FATAL = 1,
        AT_MSG_WARNING,

    ctypedef _at_spline_type at_spline_type
    struct _at_spline_type:
        at_real_coord v[4]
        at_polynomial_degree degree
        gfloat linearity

    ctypedef _at_spline_list_type at_spline_list_type
    struct _at_spline_list_type:
        at_spline_type* data
        unsigned length
        gboolean clockwise
        at_color color
        gboolean open

    ctypedef _at_spline_list_array_type at_spline_list_array_type
    ctypedef at_spline_list_array_type at_splines_type
    struct _at_spline_list_array_type:
        at_spline_list_type* data
        unsigned length
        unsigned short width
        unsigned short height

        at_color* background_color
        gboolean centerline
        gboolean preserve_width
        gfloat width_weight_factor

    ctypedef _at_fitting_opts_type at_fitting_opts_type
    struct _at_fitting_opts_type:
        at_color* background_color
        unsigned charcode
        unsigned color_count
        gfloat corner_always_threshold
        unsigned corner_surround
        gfloat corner_threshold
        gfloat error_threshold
        unsigned filter_iterations
        gfloat line_reversion_threshold
        gfloat line_threshold
        gboolean remove_adjacent_corners
        unsigned tangent_surround
        unsigned despeckle_level
        gfloat despeckle_tightness
        gfloat noise_removal
        gboolean centerline
        gboolean preserve_width
        gfloat width_weight_factor

    ctypedef _at_input_opts_type at_input_opts_type
    struct _at_input_opts_type:
        at_color* background_color
        unsigned charcode

    ctypedef _at_output_opts_type at_output_opts_type
    struct _at_output_opts_type:
        int dpi

    ctypedef _at_bitmap at_bitmap
    struct _at_bitmap:
        unsigned short height
        unsigned short width
        unsigned char* bitmap
        unsigned int np

    ctypedef _at_bitmap_reader at_bitmap_reader
    struct _at_bitmap_reader:
        pass

    ctypedef _at_spline_writer at_spline_writer
    struct _at_spline_writer:
        pass

    ctypedef void (*at_progress_func)(gfloat percentage, gpointer client_data)

    ctypedef gboolean (*at_testcancel_func)(gpointer client_data)

    ctypedef void (*at_msg_func)(const gchar* msg, at_msg_type msg_type, gpointer client_data)

    at_fitting_opts_type* at_fitting_opts_new()
    at_fitting_opts_type* at_fitting_opts_copy(at_fitting_opts_type* original)
    # Defined in _autotrace.pyx.
    # void at_fitting_opts_free(at_fitting_opts_type* opts)
    const char* at_fitting_opts_doc_func(char* string)

    at_input_opts_type* at_input_opts_new()
    at_input_opts_type* at_input_opts_copy(at_input_opts_type* original)
    void at_input_opts_free(at_input_opts_type* opts)

    at_output_opts_type* at_output_opts_new()
    at_output_opts_type* at_output_opts_copy(at_output_opts_type* original)
    void at_output_opts_free(at_output_opts_type* opts)

    at_bitmap* at_bitmap_read(at_bitmap_reader* reader, gchar* filename, at_input_opts_type* opts, at_msg_func msg_func, gpointer msg_data)
    at_bitmap* at_bitmap_new(unsigned short width, unsigned short height, unsigned int planes)
    at_bitmap* at_bitmap_copy(const at_bitmap* src)

    unsigned short at_bitmap_get_width(const at_bitmap* bitmap)
    unsigned short at_bitmap_get_height(const at_bitmap* bitmap)
    unsigned short at_bitmap_get_planes(const at_bitmap* bitmap)
    void at_bitmap_get_color(const at_bitmap* bitmap, unsigned int row, unsigned int col, at_color* color)
    gboolean at_bitmap_equal_color(const at_bitmap*  bitmap, unsigned int row, unsigned int col, at_color*  color)
    void at_bitmap_free(at_bitmap* bitmap)

    at_splines_type* at_splines_new(at_bitmap* bitmap, at_fitting_opts_type* opts, at_msg_func msg_func, gpointer msg_data)
    at_splines_type* at_splines_new_full(at_bitmap* bitmap, at_fitting_opts_type* opts, at_msg_func msg_func, gpointer msg_data, at_progress_func notify_progress, gpointer progress_data, at_testcancel_func test_cancel, gpointer testcancel_data)
    void at_splines_write(at_spline_writer* writer, FILE* writeto, gchar* file_name, at_output_opts_type* opts, at_splines_type* splines, at_msg_func msg_func, gpointer msg_data)
    void at_splines_free(at_splines_type* splines)

    at_bitmap_reader* at_input_get_handler(gchar* filename)
    at_bitmap_reader* at_input_get_handler_by_suffix(gchar* suffix)
    const char** at_input_list_new()
    void at_input_list_free(const char** list)
    char* at_input_shortlist()

    at_spline_writer* at_output_get_handler(gchar* filename)
    at_spline_writer* at_output_get_handler_by_suffix(gchar* suffix)
    const char** at_output_list_new()
    void at_output_list_free(const char** list)
    char* at_output_shortlist()

    void autotrace_init()
    const char* at_version(gboolean long_format)
    const char* at_home_site()

# https://github.com/autotrace/autotrace/blob/master/src/spline.h
cdef extern from "spline.h":
    at_real_coord evaluate_spline(at_spline_type spline, gfloat t)
