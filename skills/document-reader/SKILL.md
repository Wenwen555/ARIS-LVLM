---
name: document-reader
description: "Unified document intake for ARIS research workflows. Use when the user wants to read, summarize, extract, compare, or inspect one or more .pdf, .docx, .xlsx, or .pptx files, or a mixed folder of such files. Routes to /read-pdf, /read-docx, /read-xlsx, or /read-pptx, and standardizes the output for research use."
argument-hint: [file-path-or-directory]
allowed-tools: Bash(*), Read, Write, Edit, Grep, Glob, Skill
---

# Document Reader

Read and structure information from: **$ARGUMENTS**

## Purpose

This skill is the ARIS entry point for document ingestion.

Use it when the input is:

- a single `.pdf`, `.docx`, `.xlsx`, or `.pptx`
- a directory containing mixed document types
- a bundle of supplementary materials for a paper or project
- a document set the user wants summarized, compared, or turned into research notes

This skill is intentionally thin. It does two things:

1. Route each file to the correct ARIS wrapper skill:
   - `/read-pdf`
   - `/read-docx`
   - `/read-xlsx`
   - `/read-pptx`
2. Normalize outputs into a research-friendly structure.

## Upstream Dependency

These ARIS wrappers are designed to sit on top of Anthropic's official `document-skills` plugin from `anthropics/skills`.

Before first use:

- Read [references/install.md](references/install.md)
- Confirm the official upstream skills `pdf`, `docx`, `xlsx`, and `pptx` are available in Claude

If the official skills are installed, prefer their workflow details and scripts as the primary implementation guide.

## Directory Structure

This skill family is organized as:

```text
skills/
  document-reader/
    SKILL.md
    references/
      install.md
      output-contract.md
  read-pdf/
    SKILL.md
  read-docx/
    SKILL.md
  read-xlsx/
    SKILL.md
  read-pptx/
    SKILL.md
```

## Routing Rules

Map files by extension:

- `.pdf` -> `/read-pdf`
- `.docx` -> `/read-docx`
- `.xlsx`, `.xlsm`, `.csv`, `.tsv` -> `/read-xlsx`
- `.pptx` -> `/read-pptx`

If the user passes a directory:

1. Find all supported files under that directory
2. Group them by type
3. Process each file with the matching wrapper
4. Produce a combined synthesis at the end

If the directory contains no supported files, say so clearly and stop.

## Standard Output Contract

For every file processed, follow [references/output-contract.md](references/output-contract.md).

At minimum, produce:

- `File identity`: path, format, and a one-line description
- `Structure`: pages, sections, sheets, or slides
- `Key extracted content`: the most important text, tables, formulas, or notes
- `Research takeaways`: what matters for ARIS-style research work
- `Extraction risk`: OCR issues, missing notes, broken tables, tracked changes, hidden sheets, or conversion loss
- `Next action`: what to inspect or ask for next

## Workflow

### Step 1: Resolve Inputs

- Accept a single file, multiple files, or a directory
- Expand relative paths
- Ignore unsupported file types

### Step 2: Infer User Intent

Infer one of these modes from the prompt:

- `summary` -> concise overview
- `extract` -> detailed text/data extraction
- `structure` -> outline, sections, sheets, slides, comments, notes
- `compare` -> compare multiple files

If the user does not specify, default to `summary`.

### Step 3: Dispatch

- For each file, invoke the matching `read-*` wrapper
- Prefer Anthropic's upstream official document skill behavior when available
- Keep file-type-specific logic out of this orchestration skill

### Step 4: Synthesize

If multiple files were processed, add:

- cross-file overlaps or contradictions
- which file appears authoritative
- what should be cited, quoted, or checked manually

### Step 5: Save Notes When Helpful

When the user is processing a research packet or supplementary materials, offer to save a structured summary under:

```text
document-reading/<basename>/SUMMARY.md
```

Do not create files unless the user asks, or the surrounding workflow clearly expects saved artifacts.

## Notes

- Prefer reading the original file rather than converting it unless conversion is required
- Be explicit when extraction quality is uncertain
- For mixed research artifacts, focus on claims, methods, results, limitations, and reproducibility details
