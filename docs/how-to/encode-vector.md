---
title: Encode vectors
---

# Encoding a vector graphic in a specific format

To encode a vector graphic (like SVG or EPS) in a specific format and obtain the encoded data as bytes, you can use the [`encode`](../reference.md#autotrace.Vector.encode) method of the [`Vector`](../reference.md#autotrace.Vector) class. It accepts a format parameter that specifies the desired output format.

See the [`VectorFormat`](../reference.md#autotrace.VectorFormat) enum for a list of supported formats.

```python
from pyautotrace import VectorFormat

# Encode in SVG format.
encoded = vector.encode(VectorFormat.SVG)
print(encoded)  # b"<svg>...</svg>"
```
