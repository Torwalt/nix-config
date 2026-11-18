# What a coding agent's hook payload says about whether the user is needed.
# Claude Code sends these fields; Codex sends none of them, so its payloads
# keep the defaults: the main thread, nothing in the background.

# The hook fired inside a subagent. The main thread never carries agent_id.
def from_subagent: has("agent_id");

# The main thread ended its turn while background work (subagents, shells,
# monitors, workflows) is still in flight. That work wakes the session again,
# and the turn after it notifies, so this turn does not need the user.
def paused_for_background:
  .hook_event_name == "Stop" and ((.background_tasks // []) | length > 0);
