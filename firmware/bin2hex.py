#!/usr/bin/env python3

import argparse
from pathlib import Path


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Convert a little-endian RV32 binary to $readmemh words."
    )
    parser.add_argument("input", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()

    data = args.input.read_bytes()
    padding = (-len(data)) % 4
    data += b"\x00" * padding

    with args.output.open("w", encoding="ascii") as output_file:
        for offset in range(0, len(data), 4):
            word = int.from_bytes(data[offset : offset + 4], byteorder="little")
            output_file.write(f"{word:08x}\n")


if __name__ == "__main__":
    main()

