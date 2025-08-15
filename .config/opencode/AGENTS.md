# AGENTS.md

This file is located at: ~/.config/opencode/AGENTS.md

## Context7 Usage Policy

opencode must always use the context7 tool when the user requests code examples, setup or configuration steps, or library/API documentation. context7 should also be referenced before writing code.

## Tool Invocation Policy

- Provide a terse, one-line explanation before invoking any tool.

## Commit Message Guidelines

- Follow Conventional Commits naming conventions (e.g., feat:, fix:, chore:, etc.)
- After the summary line, include a short bulleted list of changes
- Add a single line justification about why the changes were made after the list

## Copying Arbitrary Content from Chat to Clipboard

- To copy any content from chat (such as code snippets, policy text, or instructions) to your clipboard:
  1. **Write only the intended content to a temporary file in `~/tmp`**  
     Example:  
     echo "your content here" > ~/tmp/clipboard_content.txt
     - _Do not include extraneous chat communications, instructions, or metadata—copy only the relevant content._
  2. **Copy the file contents to your clipboard using pbcopy**  
     Example:  
     pbcopy < ~/tmp/clipboard_content.txt
- This workflow allows you to easily transfer any chat content to your clipboard, ensuring only the desired text is included.
- Use this method for code, documentation, configuration, or any other text.
