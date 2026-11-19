# Case format

Add `assets/cases/case_XXX.json` and its id to `CaseLoader` in `lib/game/case_model.dart`.

Fields: id, title, category (theft, murder, espionage), difficulty (easy, standard, hard), unlockXp, minPlayers, maxPlayers, brief, roles[{name, desc}], suspects[{id, name, role, bio, responses{pressure, empathy, accuse}}], motives[{id, text}], evidence[{id, type: document|note|photo, title, content, public, scene, caption}], solution{culprit, motive, keyEvidence[], explanation}.

Public evidence goes to everyone; the rest is dealt round-robin so each piece has exactly one holder. Photos use `scene`: corridor, tower, desk, or room.
