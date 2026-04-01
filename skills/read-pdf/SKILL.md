---
name: read-pdf
description: "Read and analyze PDF files for ARIS research workflows. Use when the user wants to summarize, inspect, extract text or tables from, compare, or sanity-check a .pdf file, especially a paper, appendix, supplement, review form, scanned document, or exported report. Prefer Anthropic's official `pdf` skill when installed."
argument-hint: [pdf-file-or-directory]
allowed-tools: Bash(*), Read, Write, Edit, Grep, Glob, Skill
---

# Read PDF

Analyze: **$ARGUMENTS**

## Upstream

Primary upstream skill: Anthropic official `pdf`

Use the upstream `pdf` skill as the implementation baseline when available. This ARIS wrapper narrows the output toward research use:

- paper and appendix reading
- table and figure extraction
- review-form inspection
- scanned-PDF risk reporting

## Defaults

- `MODE = summary`
- `OCR = auto`
- `TABLES = auto`
- `SAVE = false`

## Workflow

### Step 1: Classify the PDF

Identify whether the file is mainly:

- research paper
- supplement or appendix
- review form or checklist
- slide export or poster export
- scanned document
- general report

### Step 2: Prefer Upstream PDF Tooling

If Anthropic's official `pdf` skill is available, follow its guidance first for:

- text extraction
- tables
- forms
- images
- OCR

If upstream skill support is unavailable, use local fallbacks such as `pdftotext`, `pypdf`, or `pdfplumber`.

### Step 3: Extract What Matters

Focus on:

- title, authors, venue, and date if present
- abstract or executive summary
- method, experiment, and result sections
- tables, figure captions, and quantitative claims
- limitations, appendix details, and reproducibility notes

### Step 4: Report in ARIS Format

Always include:

- page count and major section inventory
- key claims and supporting evidence
- important numeric results or tables
- extraction risks such as OCR errors, broken layout, or missing text

### Step 5: Save Only When Useful

If the user asks to save notes, write:

```text
document-reading/<basename>/SUMMARY.md
```

## Good Use Cases

- summarize a paper PDF
- inspect supplementary material before running experiments
- extract tables from a benchmark appendix
- compare two PDF reviews or rebuttal drafts
