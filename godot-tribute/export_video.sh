#!/bin/bash
# ══════════════════════════════════════════════════════════════════════
#  Export "The Legend of Meile" as a video file
#
#  USAGE:
#    ./export_video.sh                    # Uses default settings
#    ./export_video.sh output.mp4         # Custom output filename
#
#  PREREQUISITES:
#    - Godot 4.x installed and in PATH (as 'godot' or 'godot4')
#    - ffmpeg installed (for PNG-to-video conversion)
#
#  This script supports TWO methods:
#
#  METHOD 1 (Preferred): Godot's built-in --write-movie
#    Automatically captures audio+video into an AVI file.
#    Requires Godot 4.0+.
#
#  METHOD 2 (Fallback): Frame capture + ffmpeg
#    Captures individual PNG frames, then uses ffmpeg to encode.
#    Use this if --write-movie has issues.
# ══════════════════════════════════════════════════════════════════════

set -e

OUTPUT="${1:-meile_tribute.mp4}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
GODOT_CMD=""

# Find Godot executable
for cmd in godot godot4 "Godot_v4.2-stable_linux.x86_64" "Godot_v4.3-stable_linux.x86_64"; do
    if command -v "$cmd" &>/dev/null; then
        GODOT_CMD="$cmd"
        break
    fi
done

if [ -z "$GODOT_CMD" ]; then
    echo "ERROR: Godot 4.x not found in PATH."
    echo "Please install Godot 4.x and ensure it's accessible as 'godot' or 'godot4'."
    echo ""
    echo "Download: https://godotengine.org/download"
    exit 1
fi

echo "Using Godot: $GODOT_CMD"
echo "Output: $OUTPUT"
echo ""

# ── METHOD 1: --write-movie (preferred) ─────────────────────────────
echo "=== Method 1: Godot built-in movie writer ==="
echo "Recording with --write-movie..."

AVI_FILE="$SCRIPT_DIR/meile_tribute.avi"

$GODOT_CMD --path "$SCRIPT_DIR" --write-movie "$AVI_FILE" --fixed-fps 30 --quit-after 3100 2>&1 || true

if [ -f "$AVI_FILE" ] && [ -s "$AVI_FILE" ]; then
    echo "AVI captured successfully: $AVI_FILE"

    if command -v ffmpeg &>/dev/null; then
        echo "Converting to MP4 with ffmpeg..."
        ffmpeg -y -i "$AVI_FILE" \
            -c:v libx264 -preset medium -crf 18 \
            -c:a aac -b:a 192k \
            -pix_fmt yuv420p \
            -movflags +faststart \
            "$OUTPUT"
        echo ""
        echo "Video exported: $OUTPUT"
        rm -f "$AVI_FILE"
    else
        echo "ffmpeg not found. AVI file is at: $AVI_FILE"
        echo "Install ffmpeg to convert to MP4."
    fi
    exit 0
fi

# ── METHOD 2: Frame capture fallback ────────────────────────────────
echo ""
echo "=== Method 2: Frame capture fallback ==="
echo "Capturing PNG frames..."

$GODOT_CMD --path "$SCRIPT_DIR" -- --record --auto-start 2>&1 || true

# Find the recording directory (user:// maps to ~/.local/share/godot/...)
RECORD_DIR=""
for dir in \
    "$HOME/.local/share/godot/app_userdata/The Legend of Meile/recording" \
    "$HOME/.local/share/The Legend of Meile/recording" \
    "$HOME/AppData/Roaming/Godot/app_userdata/The Legend of Meile/recording" \
    "$HOME/Library/Application Support/Godot/app_userdata/The Legend of Meile/recording"; do
    if [ -d "$dir" ]; then
        RECORD_DIR="$dir"
        break
    fi
done

if [ -z "$RECORD_DIR" ] || [ ! "$(ls -1 "$RECORD_DIR"/frame_*.png 2>/dev/null | wc -l)" -gt 0 ]; then
    echo "ERROR: No frames captured. Check that Godot ran correctly."
    exit 1
fi

FRAME_COUNT=$(ls -1 "$RECORD_DIR"/frame_*.png | wc -l)
echo "Captured $FRAME_COUNT frames in: $RECORD_DIR"

if ! command -v ffmpeg &>/dev/null; then
    echo "ERROR: ffmpeg not found. Install it to encode the video."
    echo "Frames are saved in: $RECORD_DIR"
    exit 1
fi

echo "Encoding video with ffmpeg..."
ffmpeg -y -framerate 30 \
    -i "$RECORD_DIR/frame_%05d.png" \
    -c:v libx264 -preset medium -crf 18 \
    -pix_fmt yuv420p \
    -movflags +faststart \
    "$OUTPUT"

echo ""
echo "Video exported: $OUTPUT"
echo "Cleaning up frames..."
rm -rf "$RECORD_DIR"
echo "Done!"
