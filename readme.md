# PyAutoTrace
Created by [LemonPi314](https://github.com/LemonPi314)

Python bindings for [AutoTrace](https://github.com/autotrace/autotrace).

## Requirements
- Any operating system with Python
- [Python 3.7](https://www.python.org/downloads/) or higher

## Usage
Usage instructions.

## Building
### Windows
A build script is provided for Windows.
In order to compile the generated C code, you will need to have
[Visual C++ Build Tools](https://visualstudio.microsoft.com/visual-cpp-build-tools/) or another C/C++ compiler installed.
The script will clone the AutoTrace repository,
which provides the required header files for both AutoTrace and GLib.
The Python build requirements are listed in [`requirements-dev.txt`](requirements-dev.txt).
A virtual environment will be created using your default Python installation.

To run the build script, run the following command in the root directory of the repository:

```shell
.\scripts\build_windows.cmd
```

## TODO
- proper build script
- workflow to build and upload to PyPI
- documentation

## License
[MIT License](license.txt)
