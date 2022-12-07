# PyAutoTrace
Python bindings for [AutoTrace](https://github.com/autotrace/autotrace).

## Requirements
- [Python 3.7](https://www.python.org/downloads/) or higher

## Usage
```python
import numpy as np
from autotrace import Bitmap
from PIL import Image

# Load an image.
image = np.asarray(Image.open('image.jpeg').convert('RGB'))

# Create a bitmap.
bitmap = Bitmap(image)

# Trace the bitmap.
vector = bitmap.trace()

# Save the vector.
vector.save('image.svg')
```

## Building
If you wish to build the package from source,
clone the repository and follow the instructions for your platform below.
The Python build requirements are listed in [`requirements-dev.txt`](requirements-dev.txt).

### Linux and MacOS
```shell
sh ./scripts/build_unix.sh
```

A virtual environment will be created using your default Python installation.
Compilation requires GLib to be installed on your system, which most Linux distributions include by default.
On MacOS you will need to install GLib with `brew install glib`.
The script will clone the AutoTrace repository,
which provides the required header files for AutoTrace.

### Windows
```shell
.\scripts\build_windows.ps1
```

A virtual environment will be created using your default Python installation.
In order to compile the generated C code, you will need to have
[Visual C++ Build Tools](https://visualstudio.microsoft.com/visual-cpp-build-tools/) or another C/C++ compiler installed.
The script will clone the AutoTrace repository,
which provides the required header files for both AutoTrace and GLib.

## TODO
- Workflow to build and upload to PyPI
- Documentation
- Git submodules?

## License
[MIT License](license.txt)
