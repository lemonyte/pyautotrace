# PyAutoTrace

Python bindings for [AutoTrace](https://github.com/autotrace/autotrace).

## Requirements

- [Python 3.9](https://www.python.org/downloads/) or higher

## Installation

```shell
python -m pip install pyautotrace
```

## Usage

```python
import numpy as np
from autotrace import Bitmap, VectorFormat
from PIL import Image

# Load an image.
image = np.asarray(Image.open("image.jpeg").convert("RGB"))

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

If you wish to build the package from source, clone the repository and follow the instructions for your platform below.

### Linux and MacOS

```shell
sh ./scripts/build_unix.sh
```

A virtual environment will be created using your default Python installation.
Compilation requires GLib, pkg-config, and unzip to be installed on your system, which most Linux distributions include by default.
On MacOS you can install GLib with `brew install glib`.

### Windows

```shell
.\scripts\build_windows.ps1
```

A virtual environment will be created using your default Python installation.
In order to compile the generated C code, you will need to have
[Visual C++ Build Tools](https://visualstudio.microsoft.com/visual-cpp-build-tools/) or another C/C++ compiler installed.

## TODO

- Tests
- Documentation

## License

This project is licensed under the [LGPLv2.1](LICENSE.txt) license.

This project depends on the AutoTrace project, which is licensed under the [LGPLv2.1](https://github.com/autotrace/autotrace/blob/master/COPYING.LIB) license.
AutoTrace, and by extension this project, requires the presence of GLib to compile, which is licensed under the [LGPLv2.1](https://github.com/GNOME/glib/blob/main/COPYING) license, but this project does not depend on GLib to run.

This project contains code that replaces portions of [AutoTrace](https://github.com/autotrace/autotrace) and [GLib](https://github.com/GNOME/glib), defined in [`overrides.cpp`](autotrace/overrides.cpp). Some of the implementations were taken directly from, or are based on, the source code of their respective libraries.
