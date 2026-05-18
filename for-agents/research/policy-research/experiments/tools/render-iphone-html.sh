#!/usr/bin/env bash
set -eu

usage() {
    printf 'usage: %s INPUT OUTPUT.png\n' "$0" >&2
}

if [ "$#" -ne 2 ]; then
    usage
    exit 2
fi

input="$1"
output="$2"

case "$output" in
    *.png) ;;
    *)
        usage
        exit 2
        ;;
esac

base="${output%.png}"
full_output="${base}-full.png"
tall_output="${base}-tall.png"
manifest="${base}-scroll.txt"
slice_prefix="${base}-slice"
scroll_max_height="${SCROLL_MAX_HEIGHT:-12000}"

case "$input" in
    /*) url="file://$input" ;;
    *) url="file://$(pwd)/$input" ;;
esac

# First viewport. This preserves the original script contract.
google-chrome \
    --headless \
    --disable-gpu \
    --no-sandbox \
    --hide-scrollbars \
    --window-size=320,480 \
    --virtual-time-budget=1000 \
    "--screenshot=$output" \
    "$url"

file "$output" | grep -q 'PNG image data, 320 x 480'

# Tall render for a more complete scroll review. This is still rendered at
# 320 CSS pixels wide, but with a large viewport height so later code can crop
# and slice the visible document.
google-chrome \
    --headless \
    --disable-gpu \
    --no-sandbox \
    --hide-scrollbars \
    "--window-size=320,$scroll_max_height" \
    --virtual-time-budget=1000 \
    "--screenshot=$tall_output" \
    "$url"

python3 - "$output" "$tall_output" "$full_output" "$slice_prefix" \
    "$manifest" "$scroll_max_height" <<'PY'
import math
import sys
from pathlib import Path

from PIL import Image, ImageChops

viewport_path = Path(sys.argv[1])
tall_path = Path(sys.argv[2])
full_path = Path(sys.argv[3])
slice_prefix = Path(sys.argv[4])
manifest_path = Path(sys.argv[5])
scroll_max_height = int(sys.argv[6])

slice_height = 480
target_width = 320

tall = Image.open(tall_path).convert("RGB")
if tall.width != target_width:
    raise SystemExit(f"expected {target_width}px width, got {tall.width}px")

background = tall.getpixel((0, 0))
background_image = Image.new("RGB", tall.size, background)
diff = ImageChops.difference(tall, background_image)
bounds = diff.getbbox()

if bounds is None:
    content_bottom = slice_height
else:
    content_bottom = min(tall.height, bounds[3] + 8)

content_bottom = max(slice_height, content_bottom)
full = tall.crop((0, 0, target_width, content_bottom))
full.save(full_path)

slice_count = int(math.ceil(content_bottom / slice_height))
slice_paths = []

for old_slice in slice_prefix.parent.glob(f"{slice_prefix.name}-*.png"):
    old_slice.unlink()

for index in range(slice_count):
    y = index * slice_height
    page = Image.new("RGB", (target_width, slice_height), background)
    crop_bottom = min(y + slice_height, content_bottom)
    crop = full.crop((0, y, target_width, crop_bottom))
    page.paste(crop, (0, 0))
    slice_name = f"{slice_prefix.name}-{index + 1:03d}.png"
    slice_path = slice_prefix.with_name(slice_name)
    page.save(slice_path)
    slice_paths.append(slice_path)

warning = ""
if content_bottom >= scroll_max_height - 8:
    warning = (
        "warning: content reaches the tall render limit; increase "
        "SCROLL_MAX_HEIGHT and rerun for a deeper review"
    )

lines = [
    f"viewport: {viewport_path}",
    f"full: {full_path}",
    f"tall_raw: {tall_path}",
    f"width_px: {target_width}",
    f"viewport_height_px: {slice_height}",
    f"content_height_px: {content_bottom}",
    f"slice_count: {slice_count}",
]
if warning:
    lines.append(warning)
lines.append("slices:")
lines.extend(f"- {path}" for path in slice_paths)
manifest_path.write_text("\n".join(lines) + "\n", encoding="utf-8")
print(manifest_path)
PY

echo "$output"
