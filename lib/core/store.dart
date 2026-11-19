import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'util.dart';

class Rank {
  const Rank(this.idx, this.name, this.min);
  final int idx;
  final String name;
  final int min;
}

const ranks = [
  Rank(0, 'مأمور تازه‌کار', 0),
  Rank(1, 'مأمور میدانی', 100),
  Rank(2, 'کارآگاه ارشد', 300),
  Rank(3, 'رئیس واحد', 700),
];

class Store extends ChangeNotifier {
  Store._();
  static final Store i = Store._();

  late SharedPreferences _p;

  Future<void> init() async {
    _p = await SharedPreferences.getInstance();
    await _ensureIds();
  }

  Future<void> _ensureIds() async {
    if (_p.getString('pid') == null) await _p.setString('pid', randId(12));
    if (_p.getString('agent') == null) await _p.setString('agent', newAgentCode());
  }

  String get pid => _p.getString('pid')!;
  String get agent => _p.getString('agent')!;
  String get codename => _p.getString('codename') ?? '';
  int get xp => _p.getInt('xp') ?? 0;
  int get wins => _p.getInt('wins') ?? 0;
  int get played => _p.getInt('played') ?? 0;
  List<String> get solved => _p.getStringList('solved') ?? [];
  bool get particles => _p.getBool('particles') ?? true;
  bool get scanline => _p.getBool('scanline') ?? true;
  bool get glitch => _p.getBool('glitch') ?? true;
  bool get largeFont => _p.getBool('largeFont') ?? false;
  bool get saver => _p.getBool('saver') ?? false;
  int get quality => _p.getInt('quality') ?? 1;

  Rank get rank => ranks.lastWhere((r) => xp >= r.min);
  Rank? get nextRank {
    for (final r in ranks) {
      if (r.min > xp) return r;
    }
    return null;
  }

  int get particleCount {
    final base = [20, 40, 60][quality.clamp(0, 2)];
    return saver ? base ~/ 2 : base;
  }

  Future<void> put(String k, Object v) async {
    if (v is bool) {
      await _p.setBool(k, v);
    } else if (v is int) {
      await _p.setInt(k, v);
    } else if (v is String) {
      await _p.setString(k, v);
    } else if (v is List<String>) {
      await _p.setStringList(k, v);
    }
    notifyListeners();
  }

  Future<bool> addResult({
    required int gained,
    required bool won,
    required String caseId,
    required bool solvedIt,
  }) async {
    final before = rank.idx;
    await _p.setInt('xp', xp + gained);
    await _p.setInt('played', played + 1);
    if (won) await _p.setInt('wins', wins + 1);
    if (solvedIt && !solved.contains(caseId)) {
      await _p.setStringList('solved', [...solved, caseId]);
    }
    notifyListeners();
    return rank.idx > before;
  }

  Map<String, dynamic>? get session {
    final s = _p.getString('session');
    if (s == null) return null;
    try {
      return jsonDecode(s) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveSession(Map<String, dynamic> s) async {
    await _p.setString('session', jsonEncode(s));
    notifyListeners();
  }

  Future<void> clearSession() async {
    await _p.remove('session');
    notifyListeners();
  }

  Future<void> wipe() async {
    await _p.clear();
    await _ensureIds();
    notifyListeners();
  }
}
