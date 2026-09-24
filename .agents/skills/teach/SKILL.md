---
name: teach
description: Teach the user a new skill or concept through a stateful, mission-driven learning workspace.
disable-model-invocation: true
argument-hint: "What would you like to learn about?"
---

## What I do

I create short, interactive lessons in a persistent workspace and adapt each lesson to the learner's mission and demonstrated knowledge.

- Ground lessons in trusted sources and concrete learner goals.
- Build durable skills with retrieval practice, spacing, interleaving, and immediate feedback.
- Maintain concise records, reference material, and reusable lesson components.

## When to use me

Use this skill when the user wants to learn a topic across one or more sessions, practise a specific skill, or build a structured learning workspace.

## How to use me

First establish the learner's concrete mission. Then use the [teaching guide](references/TEACHING-GUIDE.md) to design the next lesson and maintain the workspace.

Use these workspace templates as needed:

- [Mission template](assets/templates/MISSION-FORMAT.md)
- [Resources template](assets/templates/RESOURCES-FORMAT.md)
- [Learning record template](assets/templates/LEARNING-RECORD-FORMAT.md)
- [Glossary template](assets/templates/GLOSSARY-FORMAT.md)

Initialize a new teaching workspace with `node scripts/initialize-workspace.mjs <workspace-directory>`.

The optional OpenAI interface metadata is preserved at [assets/openai-interface.yaml](assets/openai-interface.yaml).
