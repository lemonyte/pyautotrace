/* Overrides for GLib and AutoTrace to remove dependencies.
 *
 * Some of the implementations were taken directly from,
 * or are based on, the source code of their respective libraries.
 *
 * GLib & GObject repository: https://gitlab.gnome.org/GNOME/glib
 * AutoTrace repository: https://github.com/autotrace/autotrace
 */

#include <stdlib.h>
#include <string.h>

#include <map>
#include <string>

#include <glib.h>
#include <glib-object.h>

#include <autotrace.h>
#include <input.h>
#include <output.h>

extern "C"
{
    /* GLib overrides. */

    /* gmem.c */

    gpointer g_malloc(gsize n_bytes)
    {
        return malloc(n_bytes);
    }

    gpointer g_malloc_n(gsize n_blocks, gsize n_block_bytes)
    {
        return g_malloc(n_blocks * n_block_bytes);
    }

    gpointer g_malloc0(gsize n_bytes)
    {
        return calloc(1, n_bytes);
    }

    gpointer g_realloc(gpointer mem, gsize n_bytes)
    {
        return realloc(mem, n_bytes);
    }

    void g_free(gpointer mem)
    {
        free(mem);
    }

    /* gerror.c */

    void g_set_error(GError **err, GQuark domain, gint code, const gchar *format, ...)
    {
        va_list args;
        va_start(args, format);
        vprintf(format, args);
        va_end(args);
    }

    void g_propagate_error(GError **dest, GError *src)
    {
        *dest = src;
    }

    /* gstrfuncs.c */

#ifndef g_strdup
    gchar *g_strdup(const gchar *str)
    {
        return strdup(str);
    }
#endif

    gchar *g_strndup(const gchar *str, gsize n)
    {
        gchar *new_str;

        if (str)
        {
            new_str = g_new(gchar, n + 1);
            strncpy(new_str, str, n);
            new_str[n] = '\0';
        }
        else
        {
            new_str = NULL;
        }

        return new_str;
    }

    gchar g_ascii_toupper(gchar c)
    {
        return c >= 'a' && c <= 'z' ? c - 'a' + 'A' : c;
    }

    gchar *g_ascii_strup(const gchar *str, gssize len)
    {
        gchar *result, *s;

        if (len < 0)
        {
            len = (gssize)strlen(str);
        }

        result = g_strndup(str, (gsize)len);

        for (s = result; *s; s++)
        {
            *s = g_ascii_toupper(*s);
        }

        return result;
    }

    /* ghash.c */

#ifndef g_str_equal
    gboolean g_str_equal(gconstpointer v1, gconstpointer v2)
    {
        const gchar *string1 = reinterpret_cast<const gchar *>(v1);
        const gchar *string2 = reinterpret_cast<const gchar *>(v2);

        return strcmp(string1, string2) == 0;
    }
#endif

    /* gmessages.c */

    void g_log(const gchar *log_domain, GLogLevelFlags log_level, const gchar *format, ...)
    {
        va_list args;
        va_start(args, format);
        vprintf(format, args);
        va_end(args);
    }

    void g_return_if_fail_warning(const char *log_domain, const char *pretty_function, const char *expression)
    {
        printf("Warning: Assertion failed: %s\n", expression);
    }

    /* gtestutils.c */

    void g_assertion_message(const char *domain, const char *file, int line, const char *func, const char *message)
    {
        printf("Assertion failed: %s\n", message == NULL ? "" : message);
    }

    /* gquark.c */

    GQuark g_quark_from_static_string(const gchar *string)
    {
        return 0;
    }

    /* GObject overrides. */

    /* gboxed.c */

    GType g_boxed_type_register_static(const gchar *name, GBoxedCopyFunc boxed_copy, GBoxedFreeFunc boxed_free)
    {
        return 0;
    }

    /* AutoTrace overrides. */

    /* datetime.c */

    char *at_time_string(void)
    {
        char *time_string = reinterpret_cast<char *>(calloc(sizeof(char), 50));
        time_t t = time(NULL);
        strftime(time_string, 50, "%c", localtime(&t));
        return time_string;
    }

    /* Inputs are not used in the bindings. */
    /* input.c */

    int at_input_init(void)
    {
        return 1;
    }

    int at_input_add_handler(const gchar *suffix, const gchar *description, at_input_func reader)
    {
        return 1;
    }

    /* input-gf.c */

    at_bitmap input_gf_reader(gchar *filename, at_input_opts_type *opts, at_msg_func msg_func, gpointer msg_data, gpointer user_data)
    {
        return {0};
    }

    /* output.c */

#include <filename.h>
#include <private.h>

    std::map<std::string, at_spline_writer> *at_output_formats = nullptr;

    int at_output_init(void)
    {
        if (at_output_formats)
        {
            return 1;
        }

        at_output_formats = new std::map<std::string, at_spline_writer>();

        if (!at_output_formats)
        {
            return 0;
        }

        return 1;
    }

    int at_output_add_handler(const gchar *suffix, const gchar *description, at_output_func writer)
    {
        at_spline_writer spline_writer = {writer, NULL};
        at_output_formats->insert(std::make_pair(suffix, spline_writer));
        return 1;
    }

    at_spline_writer *at_output_get_handler(gchar *filename)
    {
        return at_output_get_handler_by_suffix(find_suffix(filename));
    }

    at_spline_writer *at_output_get_handler_by_suffix(gchar *suffix)
    {
        if (!suffix || suffix[0] == '\0')
        {
            return NULL;
        }

        gchar *gsuffix = g_ascii_strup(suffix, strlen(suffix));
        auto it = at_output_formats->find(gsuffix);
        g_free(gsuffix);

        if (it == at_output_formats->end())
        {
            return NULL;
        }

        return &(it->second);
    }
} /* extern "C" */
