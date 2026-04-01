---
name: read-pptx
description: "Read and analyze PowerPoint files for ARIS workflows. Use when the user wants to summarize, inspect, extract, compare, or repurpose a .pptx file, including paper talks, internal decks, poster talks, reviewer presentations, and appendix slides. Prefer Anthropic's official `pptx` skill when installed."
argument-hint: [pptx-file-or-directory]
allowed-tools: Bash(*), Read, Write, Edit, Grep, Glob, Skill
---

# Read PPTX

Analyze: **$ARGUMENTS**

## Upstream

Primary upstream skill: Anthropic official `pptx`

Use the upstream `pptx` skill as the implementation baseline when available. This ARIS wrapper emphasizes:

- slide-by-slide research narrative extraction
- speaker notes
- appendix and backup slide inspection
- presentation-to-paper alignment

## Defaults

- `MODE = summary`
- `NOTES = true`
- `THUMBNAILS = auto`
- `SAVE = false`

## Workflow

### Step 1: Classify the Deck

Identify whether the deck is mainly:

- conference talk
- internal project update
- poster talk
- sales or funding deck
- tutorial or class deck

### Step 2: Prefer Upstream PPTX Tooling

If Anthropic's official `pptx` skill is available, follow it first for:

- text extraction
- slide structure
- notes
- raw XML or thumbnail-based inspection

If upstream guidance is unavailable, use tools such as `markitdown` or XML unpacking fallbacks.

### Step 3: Extract the Story

Capture:

- slide titles and their order
- the main narrative arc
- speaker notes or hidden appendix details
- which slides contain results, figures, or claims worth reusing

### Step 4: Report in ARIS Format

Always include:

- slide count and major slide groups
- key takeaways per section
- notes or appendix content that materially changes interpretation
- risks such as missing notes, placeholder text, or visually dense slides that need manual review

### Step 5: Save Only When Useful

If requested, write:

```text
document-reading/<basename>/SUMMARY.md
```

## Good Use Cases

- summarize a talk deck before writing a paper
- extract speaker notes from a collaborator's presentation
- compare talk slides against the submitted paper
- inspect backup slides for missing experimental details
