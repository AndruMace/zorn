# Adventure Log Plan

## Goals

- Show a scrollable stream of adventure events with narrative text
- Append new events during an ongoing adventure
- Allow user to end the adventure, stopping new events

## Steps

1. **UI Layout**

- Update [`lib/zorn_web/live/adventure_live.ex`](lib/zorn_web/live/adventure_live.ex) to include a scrollable event log panel (e.g., `div` with fixed height and `overflow-y-auto`).
- Display events using LiveView stream (`stream(:events, ...)`).

2. **LiveView State & Event Handling**

- Introduce assigns for `adventure_active?`, `events_stream`, `event_timer_ref`.
- On "Go on Adventure" click: set adventure active, start timer (Process.send_after) or handle periodic events using `handle_info` for `:tick` messages.
- Generate narrative events combining gold/item rewards via `Zorn.Game.Adventures` logic, append to stream, update gold/inventory as needed.
- Provide "End Adventure" button/event: cancel timer, finalize rewards, maybe show summary.

3. **Narrative Event Generation**

- Extend [`lib/zorn/game/adventures.ex`](lib/zorn/game/adventures.ex) with helper to return event text + optional rewards (gold/items). Could define templates like `{:gold, amount, text}` etc.
- Ensure rewards update via existing Game context functions when events occur.

4. **Persistence & UX**

- Since events are transient, keep them in LiveView session (streams) only.
- Add empty-state text when no events yet. Ensure scroll stays at bottom via `phx-hook` or minimal JS if necessary (optional).

5. **Tests & Docs**

- Update relevant tests (if any) or add LiveView test verifying events appear and end button disables stream.
- Document new behavior in code comments if helpful.