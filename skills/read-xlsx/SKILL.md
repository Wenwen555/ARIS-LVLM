---
name: read-xlsx
description: "Read and analyze spreadsheet files for ARIS workflows. Use when the user wants to summarize, inspect, extract, compare, or sanity-check an .xlsx, .xlsm, .csv, or .tsv file, especially experiment logs, benchmark tables, result summaries, ablations, or reviewer-facing data sheets. Prefer Anthropic's official `xlsx` skill when installed."
argument-hint: [spreadsheet-file-or-directory]
allowed-tools: Bash(*), Read, Write, Edit, Grep, Glob, Skill
---

# Read XLSX

Analyze: **$ARGUMENTS**

## Upstream

Primary upstream skill: Anthropic official `xlsx`

Use the upstream `xlsx` skill as the implementation baseline when available. This ARIS wrapper focuses on research spreadsheets:

- result tables
- ablation logs
- benchmark sheets
- hidden-sheet and formula sanity checks

## Defaults

- `MODE = summary`
- `FORMULAS = true`
- `HIDDEN_SHEETS = true`
- `SAVE = false`

## Workflow

### Step 1: Inventory the Workbook

Capture:

- sheet names
- visible vs hidden sheets
- key tables
- charts if present
- named ranges if relevant

### Step 2: Prefer Upstream XLSX Tooling

If Anthropic's official `xlsx` skill is available, follow it first for:

- sheet inspection
- formulas
- formatting-sensitive workbook analysis
- recalculation-aware review

If upstream guidance is unavailable, use `pandas` for data inspection and `openpyxl` for workbook structure.

### Step 3: Extract Research-Relevant Content

Focus on:

- benchmark metrics
- best-performing settings
- ablation patterns
- suspicious formulas or broken references
- mismatch between visible summary sheets and raw data sheets

### Step 4: Report in ARIS Format

Always include:

- workbook structure
- which sheets matter most
- headline metrics or trends
- formula or data-integrity risks

### Step 5: Save Only When Useful

If requested, write:

```text
document-reading/<basename>/SUMMARY.md
```

## Good Use Cases

- inspect experiment result workbooks
- extract leaderboard tables
- verify whether a summary sheet matches raw outputs
- compare two benchmark spreadsheets
