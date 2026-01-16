---
title: Contributing
icon: lucide/heart
---

# How to contribute

Contributions of any kind are welcome!
Whether it's a bug report, feature request, typo fix, new implementation, or documentation improvement, it goes a long way to help a solo dev.

Any contributions you make will be merged under the project's [license](index.md#license).

## Building from source

The easiest way to build PyAutoTrace is with [uv](https://docs.astral.sh/uv/).
Clone the repository and run the following commands inside the project directory.

=== "Linux"

    ```shell
    # Clone the AutoTrace submodule.
    git submodule update --init

    # Build the package with uv.
    uv build
    ```

=== "macOS"

    ```shell
    # Clone the AutoTrace submodule.
    git submodule update --init

    # Install GLib with Homebrew.
    brew install glib

    # Build the package with uv.
    uv build
    ```

=== "Windows"

    ```shell
    # Clone the AutoTrace submodule.
    git submodule update --init

    # Extract the GLib headers archive.
    Expand-Archive "third-party\autotrace\distribute\win\3rdparty\glib-dev_2.34.3-1_win64.zip" -DestinationPath "third-party\glib"

    # Build the package with uv.
    uv build
    ```

On Linux and macOS compilation requires GLib, pkg-config, and unzip to be installed on your system, which most Linux distributions include by default.
You can install GLib on macOS with `brew install glib`.

On Windows, in order to compile the generated C code, you will need to have
[Visual C++ Build Tools](https://visualstudio.microsoft.com/visual-cpp-build-tools/) or another C/C++ compiler installed.
