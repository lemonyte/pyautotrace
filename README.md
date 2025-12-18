# PyAutoTrace

Python bindings for [AutoTrace](https://github.com/autotrace/autotrace).

## Installation

Install PyAutoTrace using your package manager of choice.

```shell
python -m pip install pyautotrace
```

```shell
uv add pyautotrace
```

## Usage

```python
import numpy as np
from autotrace import Bitmap, VectorFormat
from PIL import Image

# Load an image.
image = np.array(Image.open("image.jpeg").convert("RGB"))

# Create a bitmap.
bitmap = Bitmap(image)

# Trace the bitmap.
vector = bitmap.trace()

# Save the vector as an SVG.
vector.save("image.svg")

# Get an SVG as a byte string.
svg = vector.encode(VectorFormat.SVG)
```

## Building

If you wish to build the package from source, the easiest way to do so is with [uv](https://docs.astral.sh/uv/).
Clone the repository and run the following commands inside the project directory.

```shell
# Clone the AutoTrace submodule.
git submodule update --init

# If you're on Windows, extract the GLib headers archive.
Expand-Archive "third-party\autotrace\distribute\win\3rdparty\glib-dev_2.34.3-1_win64.zip" -DestinationPath "third-party\glib"

# If you're on macOS, install GLib with Homebrew.
brew install glib

# Build the package with uv.
uv build
```

On Linux and macOS compilation requires GLib, pkg-config, and unzip to be installed on your system, which most Linux distributions include by default.
You can install GLib on macOS with `brew install glib`.

On Windows, in order to compile the generated C code, you will need to have
[Visual C++ Build Tools](https://visualstudio.microsoft.com/visual-cpp-build-tools/) or another C/C++ compiler installed.

## TODO

- Tests
- Documentation

## License

This project is licensed under the [LGPLv2.1](LICENSE.txt) license.

This project depends on the AutoTrace project, which is licensed under the [LGPLv2.1](https://github.com/autotrace/autotrace/blob/master/COPYING.LIB) license.
AutoTrace, and by extension this project, requires the presence of GLib to compile, which is licensed under the [LGPLv2.1](https://github.com/GNOME/glib/blob/main/COPYING) license, but this project does not depend on GLib to run.

This project contains code that replaces portions of [AutoTrace](https://github.com/autotrace/autotrace) and [GLib](https://github.com/GNOME/glib), defined in [`overrides.cpp`](autotrace/overrides.cpp). Some of the implementations were taken directly from, or are based on, the source code of their respective libraries.
