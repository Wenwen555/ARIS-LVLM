---
name: read-docx
description: "Read and analyze Word documents for ARIS workflows. Use when the user wants to summarize, inspect, extract, compare, or reorganize a .docx file, including drafts, reports, proposals, review responses, meeting notes, or manuscripts with comments and tracked changes. Prefer Anthropic's official `docx` skill when installed."
argument-hint: [docx-file-or-directory]
allowed-tools: Bash(*), Read, Write, Edit, Grep, Glob, Skill
---

# Read DOCX

Analyze: **$ARGUMENTS**

## Upstream

Primary upstream skill: Anthropic official `docx`

Use the upstream `docx` skill as the implementation baseline when available. This ARIS wrapper emphasizes research-specific reading:

- manuscript draft review
- proposal extraction
- comments and tracked changes
- section-by-section outline capture

## Defaults

- `MODE = summary`
- `COMMENTS = true`
- `TRACK_CHANGES = auto`
- `SAVE = false`

## Workflow

### Step 1: Identify Document Type

Classify the file as one of:

- paper draft
- proposal
- memo or report
- meeting notes
- response letter
- template or form document

### Step 2: Prefer Upstream DOCX Tooling

If Anthropic's official `docx` skill is available, follow it first for:

- content extraction
- comments
- tracked changes
- raw XML access when needed

If upstream guidance is unavailable, fall back to tools like `pandoc` or unpacked XML inspection.

### Step 3: Extract Structure and Review Signals

Capture:

- heading hierarchy
- executive summary or abstract
- tables and embedded captions
- reviewer comments or author comments
- tracked changes or unresolved edits

### Step 4: Report in ARIS Format

Always include:

- section outline
- key claims, decisions, or action items
- comments or edits that materially change meaning
- risks from formatting loss or unaccepted tracked changes

### Step 5: Save Only When Useful

If requested, write:

```text
document-reading/<basename>/SUMMARY.md
```

## Good Use Cases

- summarize a proposal draft
- inspect comments on a manuscript
- compare clean and tracked-changes versions
- extract a structured outline from a long DOCX report
