import 'dart:math';

import '../core/util.dart';

J scoreHypothesis(J hyp, J solution) {
  final culprit = hyp['suspect'] == solution['culprit'] ? 50 : 0;
  final motive = hyp['motive'] == solution['motive'] ? 20 : 0;
  final key = (solution['keyEvidence'] as List).map((e) => '$e').toSet();
  final sel = ((hyp['evidence'] as List?) ?? const []).map((e) => '$e').toSet();
  final inter = key.intersection(sel).length;
  final denom = max(key.length, sel.length);
  final ev = denom == 0 ? 0 : (30 * inter / denom).round();
  return {'culprit': culprit, 'motive': motive, 'evidence': ev, 'total': culprit + motive + ev};
}
