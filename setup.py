import os
import platform
import subprocess
from pathlib import Path

from Cython.Build import cythonize
from setuptools import Extension, setup

AUTOTRACE_SRC_DIR = "./third-party/autotrace/src"
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
autotrace_sources = [str(Path(AUTOTRACE_SRC_DIR) / source) for source in autotrace_sources]
include_dirs = [AUTOTRACE_SRC_DIR]

if os.environ.get("PYAUTOTRACE_EXTRA_INCLUDES"):
    # Sometimes needed for Python.h.
    include_dirs.extend(os.environ.get("PYAUTOTRACE_EXTRA_INCLUDES", "").split(":"))

if platform.system() == "Windows":
    include_dirs.extend(
        [
            "./third-party/glib/include/glib-2.0/",
            "./third-party/glib/lib/glib-2.0/include/",
        ],
    )
elif platform.system() in ("Linux", "Darwin"):
    cflags = subprocess.run(
        ("pkg-config", "--cflags", "glib-2.0"),
        capture_output=True,
        check=True,
        text=True,
    ).stdout
    include_dirs.extend(cflags.replace("-I", "").split())
else:
    msg = f"Unsupported platform: {platform.system()}"
    raise RuntimeError(msg)

extensions = [
    Extension(
        "autotrace._autotrace",
        sources=[
            "./src/autotrace/_autotrace.pyx",
            "./src/autotrace/overrides.cpp",
            *autotrace_sources,
        ],
        include_dirs=include_dirs,
        define_macros=[
            ("AUTOTRACE_VERSION", '"0.40.0"'),
            ("AUTOTRACE_WEB", '"https://github.com/autotrace/autotrace"'),
            ("HAVE_MAGICK_READERS", "1"),
            ("GLIB_STATIC_COMPILATION", "1"),
        ],
    ),
]

setup(ext_modules=cythonize(extensions))
