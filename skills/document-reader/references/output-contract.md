# Output Contract

Use this structure whenever `document-reader` or any `read-*` wrapper reports results.

## Required Sections

### 1. File Identity

- absolute or project-relative path
- format
- short description of what the file appears to be

### 2. Structure

Report the natural structure for the file type:

- PDF: pages, sections, appendices, figures, tables, form fields
- DOCX: headings, tables, comments, tracked changes, appendices
- XLSX: sheets, named ranges, formulas, charts, hidden sheets
- PPTX: slides, slide titles, notes, appendix slides

### 3. Key Content

Extract the most important information only:

- main claims
- methods or procedures
- results
- deadlines, action items, or decisions
- formulas, tables, or notes that materially change interpretation

### 4. Research Takeaways

Translate the extraction into ARIS-relevant value:

- what is reusable for a paper, experiment, or review
- what should be cited or verified
- what looks incomplete or weak

### 5. Extraction Risk

Always flag uncertainty:

- OCR risk
- formatting loss
- missing speaker notes
- tracked changes not accepted
- hidden sheets or formulas not evaluated
- images or tables that need manual inspection

### 6. Next Action

Recommend the next best move:

- inspect a specific page, slide, or sheet
- save a structured note
- run a deeper extraction
- compare against another file
