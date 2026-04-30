#!/usr/bin/env bash
# spawn-pane.sh — create a pane for agent work, collecting all panes in one window.
#
# When running inside the user's tmux session ($TMUX is set), panes are created
# in a dedicated window in that session so the user can see them immediately.
# Otherwise, a detached session on the private agent socket is used.
#
# Prints the tmux target (session:window.pane) of the new pane to stdout so the
# caller can use it for send-keys / capture-pane.
#
# Usage:
#   target=$(./scripts/spawn-pane.sh [-n pane-name] [-w window-name] [-s socket-path])
#
# Options:
#   -n, --name      short label for the pane (default: agent)
#   -w, --window    window name to collect panes in (default: agent-work)
#   -s, --socket    override socket path (default: from $TMUX or AGENT_TMUX_SOCKET_DIR)
#   -h, --help      show this help

set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: spawn-pane.sh [-n pane-name] [-w window-name] [-s socket-path]

Create a new tmux pane for agent work and print its target to stdout.

Options:
  -n, --name      short label for the pane (default: agent)
  -w, --window    window name to collect panes in (default: agent-work)
  -s, --socket    override socket path
  -h, --help      show this help
USAGE
}

pane_name="agent"
window_name="agent-work"
socket_override=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -n|--name)    pane_name="${2-}"; shift 2 ;;
    -w|--window)  window_name="${2-}"; shift 2 ;;
    -s|--socket)  socket_override="${2-}"; shift 2 ;;
    -h|--help)    usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage; exit 1 ;;
  esac
done

if ! command -v tmux >/dev/null 2>&1; then
  echo "tmux not found in PATH" >&2
  exit 1
fi

# ── Determine mode ────────────────────────────────────────────────────────────
#
# If $TMUX is set, extract the socket path from it (first comma-delimited field)
# and create a pane inside the user's current session.
# Otherwise, fall back to the private agent socket.

if [[ -n "${TMUX:-}" && -z "$socket_override" ]]; then
  # $TMUX is: /path/to/socket,server-pid,session-id
  user_socket="${TMUX%%,*}"
  tmux_cmd=(tmux -S "$user_socket")
  user_session="$("${tmux_cmd[@]}" display-message -p '#{session_name}')"
  use_user_session=true
else
  use_user_session=false
  socket_dir="${AGENT_TMUX_SOCKET_DIR:-${TMPDIR:-~/tmp}/agent-tmux-sockets}"
  mkdir -p "$socket_dir"
  socket="${socket_override:-$socket_dir/agent.sock}"
  tmux_cmd=(tmux -S "$socket")
fi

# ── Create window (user-session mode) or session (private-socket mode) ────────

if [[ "$use_user_session" == true ]]; then
  # Create the collector window if it doesn't already exist; reuse its first
  # pane rather than splitting so we don't leave an orphan pane behind.
  window_exists=false
  if "${tmux_cmd[@]}" list-windows -t "$user_session" -F '#{window_name}' 2>/dev/null \
      | grep -qx "$window_name"; then
    window_exists=true
  fi

  if [[ "$window_exists" == false ]]; then
    # new-window starts with exactly one pane — grab its id directly
    new_pane_id="$("${tmux_cmd[@]}" new-window -d \
      -t "${user_session}:" -n "$window_name" \
      -P -F '#{pane_id}' \
      -- "${SHELL:-zsh}" 2>/dev/null)"
  else
    # Window already exists — split to add another pane
    new_pane_id="$("${tmux_cmd[@]}" split-window -d \
      -t "${user_session}:${window_name}" \
      -P -F '#{pane_id}' \
      -- "${SHELL:-zsh}" 2>/dev/null)"
  fi

  # Build a stable target string
  target="${user_session}:${window_name}.${new_pane_id}"

  # Select the layout to keep panes usable
  "${tmux_cmd[@]}" select-layout -t "${user_session}:${window_name}" tiled >/dev/null 2>&1 || true
else
  # Private-socket fallback: create a new session or a new window in an existing one
  session_name="$pane_name"
  if "${tmux_cmd[@]}" has-session -t "$session_name" 2>/dev/null; then
    # Session exists — add a new window
    new_pane_id="$("${tmux_cmd[@]}" new-window -d \
      -t "$session_name" \
      -P -F '#{window_index}' 2>/dev/null)"
    target="${session_name}:${new_pane_id}.0"
  else
    "${tmux_cmd[@]}" new-session -d -s "$session_name" -n shell -- "${SHELL:-zsh}"
    target="${session_name}:0.0"
  fi
fi

# ── Emit the socket path and target for the caller ───────────────────────────
# The caller needs the socket to run subsequent tmux -S ... commands.
# We print two lines:
#   SOCKET=<path>
#   TARGET=<session:window.pane>
# Callers can eval this or parse it with read.

if [[ "$use_user_session" == true ]]; then
  printf 'SOCKET=%s\n' "$user_socket"
else
  printf 'SOCKET=%s\n' "$socket"
fi
printf 'TARGET=%s\n' "$target"
