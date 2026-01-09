---
title: Convert bitmaps to vectors
---

# Converting a bitmap image to a vector graphic

To convert a bitmap image (like PNG or JPEG) to a vector graphic (like SVG or EPS), we need to first read the bitmap pixel data and store it in an array. The easiest way to do this is by using the Pillow library to load the image and convert it to a NumPy array.

```python hl_lines="5 8"
import numpy as np
from PIL import Image

# Load the bitmap image using Pillow.
image = Image.open("input_image.png").convert("RGB") # (1)!

# Convert the image to a NumPy array.
bitmap_data = np.array(image)
```

1. We ignore the alpha channel by converting the image to RGB format.
   If you want to preserve transparency, you can use `"RGBA"` instead, but this is currently known to cause bugs.

Next, we can create a [`Bitmap`](../reference.md#autotrace.Bitmap) object from the pixel data.

```python hl_lines="4"
from pyautotrace import Bitmap

# Create a Bitmap object from the NumPy array.
bitmap = Bitmap(bitmap_data)
```

The actual tracing process is done using the [`trace`](../reference.md#autotrace.Bitmap.trace) method, which returns a [`Vector`](../reference.md#autotrace.Vector) object.

```python
vector = bitmap.trace()
```

At this point you might want to save the vector graphic to a file or encode it in a specific format.
See the [Saving vectors](save-vector.md) and [Encoding vectors](encode-vector.md) guides for more details.

## Tracing options

The [`trace`](../reference.md#autotrace.Bitmap.trace) method accepts various options to customize the tracing process. You can either pass a [`TraceOptions`](../reference.md#autotrace.TraceOptions) object or provide individual parameters as keyword arguments.

See the [`TraceOptions`](../reference.md#autotrace.TraceOptions) reference for a list of available options and their descriptions.
