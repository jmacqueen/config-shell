# Learning Record Format

Learning records live in `learning-records/` and use sequential numbering: `0001-slug.md`, `0002-slug.md`, and so on. Create the directory lazily: only when the first record is written.

They are the teaching equivalent of ADRs: they capture non-obvious lessons, key insights, and stated prior knowledge that will steer future sessions. Use them to calculate the zone of proximal development.

## Template

```md
# {Short title of what was learned or established}

{1-3 sentences: what was learned (or what prior knowledge was established), and why it matters for future sessions.}
```

That is the whole format. A learning record can be a single paragraph. The value is recording what is now known and why it changes what to teach next, not filling out sections.

## Optional Sections

Only include these when they add genuine value. Most records will not need them.

- **Status** frontmatter (`active | superseded by LR-NNNN`): Useful when an earlier understanding is replaced.
- **Evidence**: How the user demonstrated understanding, such as a question answered, an exercise completed, or prior experience cited.
- **Implications**: What this unlocks or rules out for future sessions.

## Numbering

Scan `learning-records/` for the highest existing number and increment it by one.

## When to Write a Learning Record

Write one when any of these is true:

1. The user demonstrated genuine understanding of something non-trivial.
2. The user disclosed prior knowledge and its depth.
3. A misconception was corrected.
4. The mission shifted in response to learning. Update `MISSION.md` as well.

Do not write one for material merely covered, entries already captured in `GLOSSARY.md`, or session-by-session activity logs.

## Supersession

When a later record contradicts an earlier one, mark the old record `Status: superseded by LR-NNNN` rather than deleting it. The history of how understanding evolved is useful signal.
