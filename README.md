# PyAutoTrace

Python bindings for [AutoTrace](https://github.com/autotrace/autotrace).

## Installation

Install PyAutoTrace using your package manager of choice.

```shell
uv add pyautotrace[standard]
```

```shell
python -m pip install pyautotrace[standard]
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

See the [contribution guide](https://pyautotrace.lemonyte.com/contributing/#building-from-source) for instructions to build PyAutoTrace from source.

## TODO

- Tests

## License

This project is licensed under the [LGPLv2.1](LICENSE.txt) license.

See the [documentation](https://pyautotrace.lemonyte.com/#license) for details about the licenses of upstream and included code.
