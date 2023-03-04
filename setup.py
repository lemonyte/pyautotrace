import os
import platform
import subprocess
from pathlib import Path
from zipfile import ZipFile

from Cython.Build import cythonize
from setuptools import Extension, setup

autotrace_src_dir = os.environ.get("AUTOTRACE_SRC_DIR", "./third-party/autotrace/src")
autotrace_sources = [
    "autotrace.c",
    "bitmap.c",
    "color.c",
    "curve.c",
    "despeckle.c",
    "epsilon-equal.c",
    "exception.c",
    "filename.c",
    "fit.c",
    "image-proc.c",
    "logreport.c",
    "median.c",
    "module.c",
    "output-cgm.c",
    "output-dr2d.c",
    "output-dxf.c",
    "output-emf.c",
    "output-epd.c",
    "output-eps.c",
    "output-er.c",
    "output-fig.c",
    "output-ild.c",
    "output-mif.c",
    "output-p2e.c",
    "output-pdf.c",
    "output-plt.c",
    "output-pov.c",
    "output-sk.c",
    "output-svg.c",
    "output-ugs.c",
    "pxl-outline.c",
    "spline.c",
    "thin-image.c",
    "vector.c",
]
autotrace_sources = [str(Path(autotrace_src_dir) / source) for source in autotrace_sources]
include_dirs = [autotrace_src_dir]

if os.environ.get("PYAUTOTRACE_EXTRA_INCLUDES"):
    # Sometimes needed for Python.h.
    include_dirs.extend(os.environ.get("PYAUTOTRACE_EXTRA_INCLUDES", "").split(":"))

if platform.system() == "Windows":
    with ZipFile("./third-party/autotrace/distribute/win/3rdparty/glib-dev_2.34.3-1_win64.zip", "r") as zip_file:
        zip_file.extractall("./third-party/autotrace/distribute/win/3rdparty/glib")
    include_dirs.extend(
        [
            "./third-party/autotrace/distribute/win/3rdparty/glib/include/glib-2.0/",
            "./third-party/autotrace/distribute/win/3rdparty/glib/lib/glib-2.0/include/",
        ]
    )
elif platform.system() in ("Linux", "Darwin"):
    cflags = subprocess.run(
        ["pkg-config", "--cflags", "glib-2.0"],
        capture_output=True,
        check=True,
        text=True,
    ).stdout
    include_dirs.extend(cflags.replace("-I", "").split())
else:
    raise RuntimeError(f"Unsupported platform: {platform.system()}")

extensions = [
    Extension(
        "autotrace._autotrace",
        sources=[
            "./autotrace/_autotrace.pyx",
            "./autotrace/overrides.cpp",
            *autotrace_sources,
        ],
        include_dirs=include_dirs,
        define_macros=[
            ("AUTOTRACE_VERSION", '"0.40.0"'),
            ("AUTOTRACE_WEB", '"https://github.com/autotrace/autotrace"'),
            ("HAVE_MAGICK_READERS", 1),
            ("GLIB_STATIC_COMPILATION", 1),
        ],
    ),
]

with open("README.md", "r") as file:
    long_description = file.read()

setup(
    name="pyautotrace",
    version="0.0.2",
    description="Python bindings for AutoTrace.",
    long_description=long_description,
    long_description_content_type="text/markdown",
    author="Lemonyte",
    author_email="",
    url="https://github.com/lemonyte/pyautotrace",
    license="MIT",
    keywords=["autotrace", "bitmap", "vector", "graphics", "tracing"],
    classifiers=[
        "Development Status :: 3 - Alpha",
        "Intended Audience :: Developers",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
        "Programming Language :: Python :: 3",
        "Programming Language :: Cython",
        "Topic :: Multimedia :: Graphics :: Graphics Conversion",
        "Topic :: Scientific/Engineering :: Image Processing",
        "Topic :: Software Development :: Libraries :: Python Modules",
        "Typing :: Typed",
    ],
    packages=["autotrace"],
    package_data={
        "autotrace": [
            "py.typed",
        ],
    },
    python_requires=">=3.7",
    ext_modules=cythonize(extensions, compiler_directives={"language_level": 3}),
)
