import 'dart:math';

import 'package:case007/core/util.dart';
import 'package:case007/game/case_model.dart';
import 'package:case007/game/distribute.dart';
import 'package:case007/game/scoring.dart';
import 'package:case007/network/protocol.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('protocol signs and verifies', () {
    final raw = const Msg('chat', 'p1', 5, {'text': 'hi'}).encode('KEY123');
    expect(Msg.decode(raw, 'KEY123')?.data['text'], 'hi');
    expect(Msg.decode(raw, 'WRONG1'), isNull);
    expect(Msg.decode(raw.replaceFirst('hi', 'ho'), 'KEY123'), isNull);
  });

  test('scoring', () {
    final sol = {'culprit': 'a', 'motive': 'm1', 'keyEvidence': ['e1', 'e2']};
    expect(scoreHypothesis({'suspect': 'a', 'motive': 'm1', 'evidence': ['e1', 'e2']}, sol)['total'], 100);
    expect(scoreHypothesis({'suspect': 'b', 'motive': 'm2', 'evidence': ['e9']}, sol)['total'], 0);
    expect(scoreHypothesis({'suspect': 'a', 'motive': 'm2', 'evidence': ['e1']}, sol)['total'], 65);
  });

  test('cases load and are consistent', () async {
    final cases = await CaseLoader.loadAll();
    expect(cases.length, 3);
    for (final c in cases) {
      final ids = c.evidence.map((e) => e['id']).toSet();
      expect(ids.containsAll(c.solution['keyEvidence'] as List), isTrue);
      expect(c.suspectIds.contains(c.solution['culprit']), isTrue);
      expect(c.motiveIds.contains(c.solution['motive']), isTrue);
      for (var n = 2; n <= 6; n++) {
        if (n < c.minPlayers || n > c.maxPlayers) continue;
        final pids = List.generate(n, (i) => 'p$i');
        final d = distributeEvidence(pids, c.evidence, Random(n));
        final priv = c.evidence.where((e) => e['public'] != true).map((e) => e['id']).toList();
        for (final id in priv) {
          expect(pids.where((p) => d[p]!.contains(id)).length, 1);
        }
        for (final p in pids) {
          expect(d[p]!.length, greaterThan(1));
        }
      }
    }
  });
}
