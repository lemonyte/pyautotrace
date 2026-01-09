---
icon: lucide/rocket
---

# Get started

PyAutoTrace provides Python bindings for the [AutoTrace](https://github.com/autotrace/autotrace) bitmap-to-vector tracing library.

## Installation

=== "uv"

    ```bash
    uv add pyautotrace[standard]
    ```

=== "pip"

    ```bash
    python -m pip install pyautotrace[standard]
    ```

!!! tip
    The `[standard]` extra is optional, but makes it easy to load images in the correct array format.

Now check out the [How-to guides](how-to/) for usage examples!

## License

This project is licensed under the **LGPLv2.1** license.

This project depends on the AutoTrace project, which is licensed under the [LGPLv2.1](https://github.com/autotrace/autotrace/blob/master/COPYING.LIB) license.

AutoTrace, and by extension this project, requires the presence of GLib to compile, which is licensed under the [LGPLv2.1](https://github.com/GNOME/glib/blob/main/COPYING) license, but this project does not depend on GLib to run.

This project contains code that replaces portions of [AutoTrace](https://github.com/autotrace/autotrace) and [GLib](https://github.com/GNOME/glib), defined in [`overrides.cpp`](https://github.com/lemonyte/pyautotrace/blob/main/src/autotrace/overrides.cpp). Some of the implementations were taken directly from, or are based on, the source code of their respective libraries.
