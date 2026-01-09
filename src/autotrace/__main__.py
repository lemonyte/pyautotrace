# ruff: noqa: T201
import argparse
import ast
import inspect
import sys
from enum import Enum

try:
    import numpy as np
    from PIL import Image
except ImportError:
    np: None = None
    Image: None = None

from . import Bitmap, Color, TraceOptions, VectorFormat, __version__


# Attribute docstring helpers based on code from https://steinm.net/blog/runtime_accessible_class_attribute_docstrings/
class AttributeDocstringVisitor(ast.NodeVisitor):
    def __init__(self) -> None:
        self.docs: dict[str, str] = {}
        self.last_attr_name: str | None = None

    def visit_AnnAssign(self, node: ast.AnnAssign) -> None:
        if isinstance(node.target, ast.Name):
            self.last_attr_name = node.target.id
        else:
            self.last_attr_name = None

    def visit_Expr(self, node: ast.Expr) -> None:
        if isinstance(node.value, ast.Constant) and isinstance(node.value.value, str) and self.last_attr_name:
            docstring = inspect.cleandoc(node.value.value)
            self.docs[self.last_attr_name] = docstring
        self.last_attr_name = None


def get_attribute_docstrings(cls: type) -> dict[str, str]:
    """Get attribute docstrings from a class."""
    source = inspect.getsource(cls)
    tree = ast.parse(source)
    visitor = AttributeDocstringVisitor()
    visitor.visit(tree)
    return visitor.docs


def hex_to_color(hex_str: str) -> Color:
    """Convert a hex color string to a Color object."""
    required_len = 6
    hex_str = hex_str.lstrip("#")
    if len(hex_str) != required_len:
        msg = "Hex color must be in the format #RRGGBB."
        raise ValueError(msg)
    return Color(
        r=int(hex_str[0:2], 16),
        g=int(hex_str[2:4], 16),
        b=int(hex_str[4:6], 16),
    )


def main() -> None:
    if np is None or Image is None:
        print("Error: Required dependencies numpy and Pillow are not installed.", file=sys.stderr)
        print("Please reinstall pyautotrace with the 'standard' extra, for example:", file=sys.stderr)
        print("\tpip install pyautotrace[standard]", file=sys.stderr)
        raise SystemExit(1)

    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument("input_file", type=str, help="Path to the bitmap image to trace.")
    parser.add_argument("output_file", type=str, help="Path to save the traced vector image.")
    parser.add_argument(
        "--input-mode",
        type=str,
        default="RGB",
        help="Input image mode, passed to PIL.Image.convert().",
    )
    parser.add_argument(
        "--output-format",
        type=VectorFormat,
        default=None,
        help="Output vector format, by default inferred from file extension.",
    )

    docs = get_attribute_docstrings(TraceOptions)
    for attr, annotation in TraceOptions.__annotations__.items():
        arg_name = f"--{attr.replace('_', '-')}"
        arg_type = annotation
        default = getattr(TraceOptions, attr)
        doc = docs.get(attr, "")

        # Convert `T | None` to `T`.
        if hasattr(annotation, "__args__"):
            arg_type = annotation.__args__[0]
        # Accept hex color strings for Color arguments.
        if arg_type is Color:
            arg_type = hex_to_color
            doc += " Must be in the format #RRGGBB."

        if arg_type is bool:
            parser.add_argument(arg_name, default=default, help=doc, action="store_true")
        elif isinstance(arg_type, type) and issubclass(arg_type, Enum):
            parser.add_argument(arg_name, default=default, help=doc, choices=list(arg_type))
        else:
            parser.add_argument(arg_name, default=default, help=doc, type=arg_type)

    parser.add_argument("--version", action="version", version=f"%(prog)s {__version__}")
    args = parser.parse_args()

    image = np.array(Image.open(args.input_file).convert("RGB"))
    bitmap = Bitmap(image)
    vector = bitmap.trace(
        options=TraceOptions(
            **{k: v for k, v in vars(args).items() if k in TraceOptions.__annotations__},
        ),
    )
    vector.save(args.output_file, format=args.output_format)


if __name__ == "__main__":
    main()
