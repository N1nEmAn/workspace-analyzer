#!/bin/bash
# workspace-analyzer v1.3.0 — Python Performance Profiler

echo "workspace-analyzer v1.3.0 — Python Performance Profiler"
echo "========================================================="

PY_FILES=$(find . -name "*.py" \
    -not -path "./.venv/*" \
    -not -path "./node_modules/*" \
    -not -path "./.git/*" \
    2>/dev/null)

COUNT=$(echo "$PY_FILES" | grep -c "\.py$" 2>/dev/null || echo 0)
echo "Scanning $COUNT Python files..."
echo ""

WARNINGS=0
MEDIUM=0

while IFS= read -r f; do
    [ -z "$f" ] && continue

    # Detect nested loops (O(n²) risk)
    NEST=$(awk '/^[[:space:]]*for .* in /{d=NR} d && /^[[:space:]]{8,}for .* in /{print NR; d=0}' "$f" 2>/dev/null | head -1)
    if [ -n "$NEST" ]; then
        echo "⚠ HIGH IMPACT — $f:$NEST — nested loop (potential O(n²))"
        WARNINGS=$((WARNINGS+1))
    fi

    # Detect repeated open() calls
    OPENS=$(grep -c "open(" "$f" 2>/dev/null || echo 0)
    if [ "$OPENS" -gt 3 ]; then
        echo "⚠ MEDIUM    — $f — $OPENS file.open() calls (consider caching)"
        MEDIUM=$((MEDIUM+1))
    fi

    # Detect import of heavy libs at function scope
    if grep -qE "^\s+(import pandas|import numpy|import torch)" "$f" 2>/dev/null; then
        echo "⚠ MEDIUM    — $f — heavy import inside function (move to top-level)"
        MEDIUM=$((MEDIUM+1))
    fi

done <<< "$PY_FILES"

# Load profiler extensions
_PROF_DIR="$(dirname "$0")/.profiler"
if [ -d "$_PROF_DIR" ]; then
    for _ext in "$_PROF_DIR"/*; do
        [ -f "$_ext" ] && [ -x "$_ext" ] && . "$_ext" 2>/dev/null
    done
fi

echo ""
echo "========================================================="
echo "Scan complete. High: $WARNINGS  Medium: $MEDIUM"
echo ""
if [ $WARNINGS -eq 0 ] && [ $MEDIUM -eq 0 ]; then
    echo "✓ No critical performance issues found."
else
    echo "Tip: Fix HIGH IMPACT issues first for best results."
fi
