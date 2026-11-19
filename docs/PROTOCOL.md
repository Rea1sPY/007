# Protocol

Transport: WebSocket on port 8765 (falls back up to 8785). Every frame is JSON `{b, g}` where `b` is the JSON body `{t, f, s, d}` (type, sender id, sequence, data) and `g` is HMAC-SHA256(roomCode, b).

Client to host: join, ready, chat, share, hyp, vote, ping, leave. Host only: selectCase, start, advance, toLobby.
Host to client: welcome, lobby, intel, phase, shared, chat, progress, error, closed, pong.

Phases: lobby, briefing, investigation, hypothesis, voting, result. The host validates every transition and message; sequence numbers must increase; 10 messages per second per client; duplicate chat ids are dropped; one hypothesis and one vote per player.
