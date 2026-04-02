# AGENTS-local.md

This file is located at: ~/.config/opencode/AGENTS-local.md

## Global Jira and Confluence URLs

- Jira: https://bitsight.atlassian.net
- Confluence: https://bitsight.atlassian.net/wiki
- Confluence Personal Space Key (Jonathan Macqueen): ~6279cc1b0e2c49006902ec5d

## Minimum Confluence and Jira API Info for Shell Commands

- **Jira API Base URL:** `https://bitsight.atlassian.net/rest/api/3/`
- **Confluence API Base URL:** `https://bitsight.atlassian.net/wiki/rest/api/`
- **Authentication:** Use Basic Auth with your Atlassian email and a single API token (set as environment variables, e.g., `ATLASSIAN_API_TOKEN`)
- **Example curl usage:**
  - Jira:  
    `curl -u "$EMAIL:$ATLASSIAN_API_TOKEN" "https://bitsight.atlassian.net/rest/api/3/issue/KEY"`
  - Confluence:  
    `curl -u "$EMAIL:$ATLASSIAN_API_TOKEN" "https://bitsight.atlassian.net/wiki/rest/api/content/PAGE_ID"`

## Web fetch policy

- A certificate error when fetching a web page means the page does not exist. Search for the correct page.

## Directory and File Presence Verification Policy

- When verifying the presence of a directory or file, always use a case-insensitive, recursive search (e.g., find . -iname or an equivalent method).
- If a user claims a file or directory exists but previous searches did not find it, immediately perform a case-insensitive, recursive search to confirm.
- Do not rely solely on glob, list, or other tools that may miss top-level or hidden directories/files.
- Always report the exact path(s) found and clarify the search method used.
