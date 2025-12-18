"""Python bindings for AutoTrace.

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
"""

from autotrace.autotrace import (
    Bitmap,
    Color,
    Path,
    Point,
    PolynomialDegree,
    Spline,
    TraceOptions,
    Vector,
    VectorFormat,
)

__all__ = (
    "Bitmap",
    "Color",
    "Path",
    "Point",
    "PolynomialDegree",
    "Spline",
    "TraceOptions",
    "Vector",
    "VectorFormat",
    "__version__",
)
__version__ = "0.0.6"
