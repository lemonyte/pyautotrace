---
icon: lucide/square-terminal
---

# Command-line interface

If installed with the `[standard]` extra, PyAutoTrace provides a command-line interface for easily converting bitmap images to vectors.

To install the command globally, it is recommended to use uv:

```shell
uv tool install pyautotrace[standard]
```

You can then use the `pyautotrace` command in your terminal:

```text
pyautotrace in.png out.svg
```

The options available for the command correspond to the attributes of the [`TraceOptions`](reference.md#autotrace.TraceOptions) class, with the addition of `--input-mode` to specify the input image mode for Pillow, and `--output-format` to specify the [output vector format](reference.md#autotrace.VectorFormat).

See [Pillow's documentation](https://pillow.readthedocs.io/en/stable/handbook/concepts.html#modes) for more information on image modes.

The `--background-color` option expects a color in hex format, e.g. `--background-color #C0FFEE`.
