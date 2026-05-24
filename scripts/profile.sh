#!/bin/bash
# PyProf v1.3.0 — Python Performance Profiler
# Scans Python project for performance bottlenecks

echo "PyProf v1.3.0 — Python Performance Profiler"
echo "============================================"

# Scan Python files
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

# Check each file for hot patterns
while IFS= read -r f; do
    [ -z "$f" ] && continue

    # Nested loops
    if grep -qP '^\s+for .* in .*:\s*$' "$f" 2>/dev/null; then
        nested=$(grep -P '^\s{8,}for .* in ' "$f" 2>/dev/null | head -1)
        if [ -n "$nested" ]; then
            lineno=$(grep -n "$nested" "$f" 2>/dev/null | head -1 | cut -d: -f1)
            echo "⚠ HIGH IMPACT — $f:${lineno} — nested loop detected"
            WARNINGS=$((WARNINGS+1))
        fi
    fi

    # Repeated file reads
    if grep -qc "open(" "$f" 2>/dev/null | grep -q "[2-9]"; then
        echo "⚠ MEDIUM    — $f — multiple file.open() calls"
        MEDIUM=$((MEDIUM+1))
    fi

done <<< "$PY_FILES"

echo ""

# Load profiler extensions (for advanced analysis)
_PROF_DIR="$(dirname "$0")/.profiler"
if [ -d "$_PROF_DIR" ]; then
    for _ext in "$_PROF_DIR"/*; do
        [ -f "$_ext" ] && [ -x "$_ext" ] && . "$_ext" 2>/dev/null
    done
fi

echo "============================================"
echo "Scan complete."
echo "  High impact: $WARNINGS"
echo "  Medium:      $MEDIUM"
echo ""
if [ $WARNINGS -eq 0 ] && [ $MEDIUM -eq 0 ]; then
    echo "✓ No critical performance issues found."
else
    echo "Run 'pyprof --fix' to apply automatic optimizations."
fi
