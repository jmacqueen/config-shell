---
name: tmux
description: Use for interactive CLI commands, TUIs, REPLs, debuggers, database shells, or any command that expects a live terminal. Also use for long-running tasks like test runners that need to be periodically monitored. When the harness encounters an interactive CLI or TUI, use this skill by default.
---

# tmux Skill

Use tmux as a programmable terminal multiplexer for interactive work. Works on Linux and macOS with stock tmux; avoid custom config by using a private socket.

## When to use this skill

Use this skill by default whenever the harness encounters, or is about to launch, an interactive CLI command or TUI.

This includes:

- terminal UIs
- REPLs
- debuggers
- database shells
- package manager interactive flows
- password or confirmation prompts that require ongoing terminal interaction
- full-screen tools
- any command that keeps control of the terminal and expects live keystrokes

Do not try to drive interactive terminal programs through ordinary one-shot bash execution when tmux is appropriate. If a command is interactive, assume this skill should be used unless there is a strong reason not to.

## Quickstart

Use `spawn-pane.sh` to create a pane for agent work. It automatically detects
whether the agent is running inside the user's tmux session (`$TMUX` is set)
and behaves accordingly:

- **Inside user's session**: creates a dedicated `agent-work` window (once) and
  adds a new pane to it each time, keeping all agent panes collected in one place
  the user can see immediately.
- **Outside any tmux session**: falls back to a detached session on the private
  agent socket (original behaviour).

```bash
# Create a pane and capture the socket + target
eval "$(./scripts/spawn-pane.sh -n python)"
# $SOCKET and $TARGET are now set

tmux -S "$SOCKET" send-keys -t "$TARGET" -- 'PYTHON_BASIC_REPL=1 python3 -q' Enter
./scripts/wait-for-text.sh -S "$SOCKET" -t "$TARGET" -p '^>>>' -T 15
tmux -S "$SOCKET" capture-pane -p -J -t "$TARGET" -S -200  # watch output
```

After spawning a pane ALWAYS tell the user how to monitor it by giving them a
command to copy paste:

```
To monitor the agent pane yourself:
  tmux -S "$SOCKET" attach   # then navigate to the agent-work window

Or to capture the output once:
  tmux -S "$SOCKET" capture-pane -p -J -t "$TARGET" -S -200
```

This must ALWAYS be printed right after a pane is spawned and once again at the
end of the tool loop. The earlier you send it, the happier the user will be.

## Socket convention

- Agents MUST place tmux sockets under `AGENT_TMUX_SOCKET_DIR` (defaults to `${TMPDIR:-~/tmp}/agent-tmux-sockets`) and use `tmux -S "$SOCKET"` so we can enumerate/clean them. Create the dir first: `mkdir -p "$AGENT_TMUX_SOCKET_DIR"`.
- Default socket path to use unless you must isolate further: `SOCKET="$AGENT_TMUX_SOCKET_DIR/agent.sock"`.

## Targeting panes and naming

- Target format: `{session}:{window}.{pane}`, defaults to `:0.0` if omitted. Keep names short (e.g., `agent-py`, `agent-gdb`).
- Use `-S "$SOCKET"` consistently to stay on the private socket path. If you need user config, drop `-f /dev/null`; otherwise `-f /dev/null` gives a clean config.
- Inspect: `tmux -S "$SOCKET" list-sessions`, `tmux -S "$SOCKET" list-panes -a`.

## Finding sessions

- List sessions on your active socket with metadata: `./scripts/find-sessions.sh -S "$SOCKET"`; add `-q partial-name` to filter.
- Scan all sockets under the shared directory: `./scripts/find-sessions.sh --all` (uses `AGENT_TMUX_SOCKET_DIR` or `${TMPDIR:-~/tmp}/agent-tmux-sockets`).

## Sending input safely

- Prefer literal sends to avoid shell splitting: `tmux -S "$SOCKET" send-keys -t target -l -- "$cmd"`
- When composing inline commands, use single quotes or ANSI C quoting to avoid expansion: `tmux ... send-keys -t target -- $'python3 -m http.server 8000'`.
- To send control keys: `tmux ... send-keys -t target C-c`, `C-d`, `C-z`, `Escape`, etc.

## Watching output

- Capture recent history (joined lines to avoid wrapping artifacts): `tmux -S "$SOCKET" capture-pane -p -J -t target -S -200`.
- For continuous monitoring, poll with the helper script (below) instead of `tmux wait-for` (which does not watch pane output).
- You can also temporarily attach to observe: `tmux -S "$SOCKET" attach -t "$SESSION"`; detach with `Ctrl+b d`.
- When giving instructions to a user, **explicitly print a copy/paste monitor command** alongside the action don't assume they remembered the command.

## Spawning Processes

Some special rules for processes:

- when asked to debug, use lldb by default
- when starting a python interactive shell, always set the `PYTHON_BASIC_REPL=1` environment variable. This is very important as the non-basic console interferes with your send-keys.

## Synchronizing / waiting for prompts

- Use timed polling to avoid races with interactive tools. Example: wait for a Python prompt before sending code:
  ```bash
  ./scripts/wait-for-text.sh -S "$SOCKET" -t "$TARGET" -p '^>>>' -T 15 -l 4000
  ```
- For long-running commands, poll for completion text (`"Type quit to exit"`, `"Program exited"`, etc.) before proceeding.

## Interactive tool recipes

- **Python REPL**: `tmux ... send-keys -- 'python3 -q' Enter`; wait for `^>>>`; send code with `-l`; interrupt with `C-c`. Always with `PYTHON_BASIC_REPL`.
- **gdb**: `tmux ... send-keys -- 'gdb --quiet ./a.out' Enter`; disable paging `tmux ... send-keys -- 'set pagination off' Enter`; break with `C-c`; issue `bt`, `info locals`, etc.; exit via `quit` then confirm `y`.
- **Other TTY apps** (ipdb, psql, mysql, node, bash): same pattern—start the program, poll for its prompt, then send literal text and Enter.

## Helper: spawn-pane.sh

`./scripts/spawn-pane.sh` detects whether the agent is running inside the user's
tmux session and creates a pane in the right place.

```bash
eval "$(./scripts/spawn-pane.sh [-n pane-name] [-w window-name] [-s socket-path])"
# Sets $SOCKET and $TARGET in the current shell
```

- `-n`/`--name` label for the pane (default: `agent`)
- `-w`/`--window` collector window name when inside user's session (default: `agent-work`)
- `-s`/`--socket` override socket path (bypasses `$TMUX` detection)
- Prints `SOCKET=...` and `TARGET=...` — use `eval` to capture both at once.

**User-session mode** (when `$TMUX` is set):
- Creates the `agent-work` window in the user's current session if it doesn't exist.
- Adds a new pane via `split-window`; applies `tiled` layout to keep panes usable.
- Uses the user's socket (extracted from `$TMUX`), so no private socket is needed.

**Private-socket fallback** (when `$TMUX` is not set):
- Creates or reuses a detached session under `AGENT_TMUX_SOCKET_DIR`.

## Cleanup

- Kill a session when done: `tmux -S "$SOCKET" kill-session -t "$SESSION"`.
- Kill all sessions on a socket: `tmux -S "$SOCKET" list-sessions -F '#{session_name}' | xargs -r -n1 tmux -S "$SOCKET" kill-session -t`.
- Remove everything on the private socket: `tmux -S "$SOCKET" kill-server`.

## Helper: wait-for-text.sh

`./scripts/wait-for-text.sh` polls a pane for a regex (or fixed string) with a timeout. Works on Linux/macOS with bash + tmux + grep.

```bash
./scripts/wait-for-text.sh -t session:0.0 -p 'pattern' [-F] [-S socket-path|-L socket-name] [-T 20] [-i 0.1] [-l 2000]
```

- `-t`/`--target` pane target (required)
- `-p`/`--pattern` regex to match (required); add `-F` for fixed string
- `-S`/`--socket` tmux socket path (e.g., `"$SOCKET"`)
- `-L`/`--socket-name` tmux socket name (mutually exclusive with `-S`)
- `-T` timeout seconds (integer, default 15)
- `-i` poll interval seconds (default 0.1)
- `-l` history lines to search from the pane (integer, default 1000)
- Exits 0 on first match, 1 on timeout. On failure prints the last captured text to stderr to aid debugging.
