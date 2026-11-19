# Known limitations

- The full case file, including the solution, ships inside the APK. Technically skilled people can extract it. The host only sends each player their own evidence; the solution is sent to clients only at the result phase.
- No payload encryption. Messages are signed (HMAC-SHA256, key derived from the room code) which blocks injection and replay on a LAN, but traffic is readable on the network.
- No host migration. If the host closes the app, the session ends for everyone.
- The host app must stay in the foreground; Android may suspend the server in the background. Clients reconnect for 90 seconds after a drop.
- A player who disconnects for more than 90 seconds is marked as left; the game continues without them.
- Late joiners are rejected after the game starts.
- Persian only. No audio files are bundled. Pass-and-play on one device is not included.
- Icons are Material icons; fonts are system fonts unless bundled.
- No game timers: phases advance by player actions and host control.
