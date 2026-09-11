---
description: Run the verified multi-agent Claude Security vulnerability scanner
agent: security
---
Call the `skill` tool with name `claude-security`, then act as its front desk.

Follow the selected recipe end-to-end. Do not replace its component-category
research matrix or three-lens verification panel with one broad researcher or
one verifier. Do not deduplicate findings solely by location, sink, CWE, title,
or vulnerability class.

Verification is per candidate. The deterministic helper scripts, not a model,
must validate coverage, tally votes, enforce quorum, and verify that the source
tree did not change during the scan. Never work around a helper refusal.

Use the common structured pipeline and its single `finalize_scan.py` command;
do not manually reproduce validation, tallying, rendering, or summary arithmetic.

If the arguments below are non-empty, treat them as the requested job and skip
the menu; otherwise open the three-option menu using the `question` tool.

Arguments: $ARGUMENTS
