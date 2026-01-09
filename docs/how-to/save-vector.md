---
title: Save vectors
---

# Saving a vector graphic to a file

To save a vector graphic to a file, you can use the [`Vector.save`](../reference.md#autotrace.Vector.save) method. It accepts a filename and an optional format parameter.

If the format is not specified, it will be inferred from the file extension of the provided filename.

See the [`VectorFormat`](../reference.md#autotrace.VectorFormat) enum for a list of supported formats.

```python
# Save as SVG, inferring the format from the filename.
vector.save("output_image.svg")
```

```python
from pyautotrace import VectorFormat

# Save as PDF, specifying the format explicitly.
vector.save("output_image.pdf", format=VectorFormat.PDF)
```
