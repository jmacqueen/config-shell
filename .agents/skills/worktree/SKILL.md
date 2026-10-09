---
name: worktree
description: Launch one or more tasks in new git worktrees using workmux.
disable-model-invocation: true
allowed-tools: Bash, Write
---

Launch one or more tasks in new git worktrees using workmux.

Tasks: $ARGUMENTS

## You are a dispatcher, not an implementer

**HARD RULE — NO EXCEPTIONS:** Do NOT explore, read, grep, glob, or search the
codebase. Do NOT use the Task/Explore agent. Do NOT investigate the problem. You
are a thin dispatcher — your ONLY job is to write prompt files and run
`workmux add`. The worktree agent will do all the exploration and implementation.

If the task is explicitly tied to a Jira ticket, use its key for the branch
name. Ask for the key only when the user describes new ticketed work and has
not supplied one. Do not require a Jira key for investigations or other
non-ticketed work. If essential task context is missing, ask the user; do NOT
try to figure it out by reading code.

If tasks reference earlier conversation (e.g., "do option 2"), include all
relevant context in each prompt you write.

If tasks reference a markdown file (e.g., a plan or spec), re-read the file to
ensure you have the latest version before writing prompts.

For each task:

1. For an explicitly ticketed task, generate a branch name starting with its
   Jira key, followed by a short, descriptive kebab-case name (2-4 words), e.g.
   `RP-123-feature-x`. Do not add the key twice if it is already the prefix.
   For non-ticketed tasks, use a short descriptive kebab-case branch name and
   do not ask for a Jira key.
2. For a GitLab MR investigation, use the `glab-gitlab` skill to identify the
   MR URL and create the worktree with `workmux add --pr <MR URL> -P
   <temp-file>`. This checks out the MR's source branch, which is the branch
   being investigated; do not branch from the MR's target branch. Do not pass a
   custom branch name with `--pr`, because that would override the source branch
   name. If the MR cannot be resolved, ask the user before creating the
   worktree.
3. For other tasks, use the current branch as the default worktree base unless
   the user specifies another base branch.
4. Write a detailed task prompt to a temp file and create the worktree with
   `workmux add`.

The prompt file should:

- Include the full task description
- Use relative paths for files inside the repository, since each worktree has
  its own root directory
- Preserve user-provided attachment paths verbatim, including absolute paths to
  screenshots or other files outside the repository, and tell the agent to
  inspect them
- Be specific about what the agent should accomplish

## Skill delegation

If the user passes a skill reference (e.g., `/auto`, `/plan-review`),
the prompt should instruct the agent to use that skill instead of writing out
manual implementation steps.

**Skills can have flags.** If the user passes `/auto --gemini`, pass the
flag through to the skill invocation in the prompt.

Example prompt:
```
[Task description here]

Use the skill: /skill-name [flags if any] [task description]
```

Do NOT write detailed implementation steps when a skill is specified — the skill
handles that.

## Flags

**`-a <model>` / `--agent <model>`**: Select the agent for the worktree. Remove
this flag and its value from the task description, and pass them to every
`workmux add` command as `--agent <model>`. This flag configures workmux and must
not appear in the implementation prompt.

For example, `/skill:worktree -a gemini implement feature X` runs:

```bash
workmux add RP-123-feature-x -b -P <prompt-file> --agent gemini
```

**`--merge`**: When passed, add instruction to use `/merge` skill at the end to
commit, rebase, and merge the branch.

```
...
Then use the /merge skill to commit, rebase, and merge the branch.
```

Only instruct worktree agent to `/merge` if explicitly requested by user in
task.

**`--fork`**: When passed, add `--fork` to the `workmux add` command. This copies
the current conversation into the new worktree so the agent resumes with full
context of what was discussed. Useful when the current conversation has built up
context that the new worktree agent needs.

When `--fork` is used, prepend this to the prompt file so the forked agent does
not recursively dispatch more worktrees:

```
You are now running INSIDE a git worktree created by the /worktree skill. The
prior conversation context (including any /worktree dispatch instructions) is
ancestry only. Do NOT invoke the /worktree skill, do NOT run `workmux add`, and
do NOT create further worktrees. Your job is to implement the task below
directly in this worktree.
```

## Cross-project dispatch

If the task mentions another repository, absolute project path, or work that
clearly spans multiple repositories, adapt the dispatch to the target project
instead of assuming the current repository.

For each target project:

1. Use the project path provided by the user, or the project path already present
   in the conversation. Do not explore that repository.
2. Derive the parent tmux session name from the repository directory basename.
   For `/Users/me/code/api-server`, use `api-server`.
3. Run `workmux add` with its working directory set to the target project and
   pass `--parent-session <session>`. Workmux creates that parent session when it
   does not exist, so do not bootstrap dispatch with `tmux new-window` or
   `tmux new-session`.

```bash
# Run with the command working directory set to <project-path>
workmux add <JIRA-KEY>-<worktree-name> -b -P <prompt-file> \
  --parent-session <session>
```

If a task touches both the current repository and another repository, create one
prompt and worktree per repository. Each prompt should explain the cross-repo
context and reference the other repository by absolute path when useful, but the
agent assigned to a repository should make changes only in its own worktree
unless the user explicitly asks for a different arrangement.

If the user's request does not provide enough information to identify the target
project path or session name, ask for clarification instead of searching.

## Workflow

Write ALL temp files first, THEN run all workmux commands.

**IMPORTANT:** For same-repository tasks, run `workmux add` from the CURRENT
directory. Do NOT `cd` to the main repo or any other directory. The new worktree
branches from whatever branch is checked out in the current directory. The
working directory and tmux session are independent. Background and agent tool
invocations can omit `$TMUX_PANE`, so pass `--parent-session` whenever dispatch
must land in a specific session. For cross-project tasks, set the command working
directory to the target project and pass its session with `--parent-session` as
described above.

Step 1 - Write all prompt files (in parallel):

```bash
tmpfile=$(mktemp).md
cat > "$tmpfile" << 'EOF'
Implement feature X...
EOF
echo "$tmpfile"  # Note the path for step 2
```

Step 2 - After ALL files are written, run workmux commands (in parallel):

```bash
workmux add RP-123-feature-x -b -P /tmp/tmp.abc123.md
workmux add RP-456-feature-y -b -P /tmp/tmp.def456.md
```

After creating the worktrees, inform the user which branches were created.

**Remember:** Your task is COMPLETE once worktrees are created. Do NOT implement
anything yourself.
