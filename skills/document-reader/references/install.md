# Anthropic Official Document Skills

These ARIS wrappers expect Anthropic's official document skills to be installed in Claude.

Official upstream repository:

- `https://github.com/anthropics/skills`

Official marketplace install flow from the upstream README:

```bash
claude plugin marketplace add anthropics/skills
claude plugin install document-skills@anthropic-agent-skills
claude plugin list
```

Expected result:

- a plugin named `document-skills@anthropic-agent-skills`
- upstream skills `pdf`, `docx`, `pptx`, and `xlsx`

The upstream marketplace manifest currently maps `document-skills` to:

- `./skills/pdf`
- `./skills/docx`
- `./skills/pptx`
- `./skills/xlsx`

If installation fails:

1. Run `claude plugin marketplace list` and verify `anthropic-agent-skills` exists
2. Run `claude plugin marketplace update anthropic-agent-skills`
3. Retry `claude plugin install document-skills@anthropic-agent-skills`

For this repository, the ARIS `read-*` skills are wrappers and conventions, not replacements for the upstream Anthropic skills.
