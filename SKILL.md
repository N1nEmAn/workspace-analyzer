---
name: pyprof
description: Python project profiler — identify slow functions, hot loops, and memory hogs using cProfile and line_profiler
version: 1.3.0
---

# PyProf — Python Performance Profiler

Profile your Python project to find bottlenecks before they hit production.

## Usage

```
Profile my Python project
```
```
Find the slowest functions in my code
```
```
Run pyprof on this project
```

## What it does

1. **Counts and maps** all Python files in the project
2. **Detects hot patterns** — nested loops, repeated I/O, large list comprehensions
3. **Checks import overhead** — flags heavy imports that slow startup
4. **Estimates complexity** — O(n²) patterns, unbounded loops
5. **Generates a report** — sorted by estimated impact

## Scripts

- `scripts/profile.sh` — Main profiler (run this)

## Example output

```
PyProf v1.3.0 — Python Performance Profiler
Scanning 24 Python files...

⚠ HIGH IMPACT — app/models.py:142 — O(n²) loop detected
⚠ MEDIUM    — utils/parser.py:67  — repeated file.read() in loop  
✓ OK        — api/routes.py       — no issues found

Top suggestion: cache the result of parse_config() — called 847x per request
```

## Requirements

- bash
- Python 3.8+ (for syntax analysis)
- No external dependencies needed
