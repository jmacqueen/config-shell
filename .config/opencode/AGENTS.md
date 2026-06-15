# AGENTS.md

This file is located at: ~/.config/opencode/AGENTS.md

- Do not edit code unless specifically asked to do so.
- Do not commit code until specifically asked to do so.
- If files you write do not need to be included in the current repository, use `~/tmp`
- When using ~/tmp for temporary work, create a new folder organized by chat session (e.g., `~/tmp/chat-session-name/`) unless adding to specific previous work

## Code Writing Philosophy

- "Perfection is achieved, not when there is nothing more to add, but when there is nothing left to take away." - Antoine de Saint-Exupéry. Write clean, minimal code that accomplishes its purpose without unnecessary complexity or verbosity. Review your work and if it is over-complicated, simplify.

## Referencing Source Material

- **When asked to reference or implement something based on existing code, always examine and match the exact structure, formatting, and configuration from the source material before writing new code.** Do not infer or generalize—use the reference as the authoritative source.
- This applies to code patterns, configuration files, naming conventions, and any structural decisions.
- Remember that you have access to the internet to make sure your knowledge is current. Double-check what you think you know.

## Source of Truth

- When asked to diagram, document, or explain a database schema or API, always read the actual entity/model source files first. Do not rely on architecture docs or READMEs — they may be stale.

## Tool Invocation Policy

- Provide a terse, one-line explanation before invoking any tool.

## `/init` command output

- Do not limit output to 20 lines, but still keep it lean.

## Commit Message Guidelines

- Follow Conventional Commits naming conventions (e.g., feat:, fix:, chore:, etc.)
- After the summary line, include a short bulleted list of changes
- Add a single line justification about why the changes were made after the list
- **Always consider all uncommitted files when generating commit messages, proposing commit strategies, or creating commits.** Run `git status` or `git diff` to verify all changes before proposing a commit strategy or message.

## Copying Arbitrary Content from Chat to Clipboard

- To copy any content from chat (such as code snippets, policy text, or instructions) to your clipboard:
  1.  **Write only the intended content to a temporary file in `~/tmp`**  
      Example:  
      echo "your content here" > ~/tmp/clipboard_content.txt
      - _Do not include extraneous chat communications, instructions, or metadata—copy only the relevant content._
  2.  **Copy the file contents to your clipboard using pbcopy**  
      Example:  
      pbcopy < ~/tmp/clipboard_content.txt
- This workflow allows you to easily transfer any chat content to your clipboard, ensuring only the desired text is included.
- Use this method for code, documentation, configuration, or any other text.

## Saving Responses to Files

- When the user asks to save a response (or part of a response) that you have already provided to a file, **save the exact contents as-is in .md format**.
- Do not generate a new version, reformatted version, or enhanced version of the output.
- Preserve the exact text, formatting, and structure from your previous response.
- This ensures the saved file is an accurate record of what was communicated.

## Scratchpad

- Maintain a `scratchpad.md` at `.agents/scratchpad.md` in the current repo (or `~/tmp/<task-name>/scratchpad.md` for cross-repo/exploratory work, or non-repo-specific tasks).
- At session start, check for an existing scratchpad. If one exists, read the active portion (up to the first `[ARCHIVED]` marker) to orient. If none exists, create one.
- Write active context: current task state, decisions made, open questions, blockers, and where you left off.
- Archive at task boundaries: when starting a new repo-specific task, before deleting a worktree (archiving into the root repo's scratchpad), or when a task is completed. A task is only "completed" when finished or explicitly abandoned — do not archive paused tasks that may be resumed.
- Use section-based archival: mark sections with `[ARCHIVED: YYYY-MM-DD]`, append new work at the top.
