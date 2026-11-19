import 'dart:convert';

import 'package:flutter/services.dart';

import '../core/util.dart';

class CaseData {
  CaseData(this.j);
  final J j;

  String get id => j['id'] as String;
  String get title => j['title'] as String;
  String get difficulty => j['difficulty'] as String;
  String get category => j['category'] as String;
  String get brief => j['brief'] as String;
  int get minPlayers => (j['minPlayers'] as num).toInt();
  int get maxPlayers => (j['maxPlayers'] as num).toInt();
  int get unlockXp => (j['unlockXp'] as num?)?.toInt() ?? 0;
  List<J> get roles => asList(j['roles']);
  List<J> get suspects => asList(j['suspects']);
  List<J> get motives => asList(j['motives']);
  List<J> get evidence => asList(j['evidence']);
  J get solution => Map<String, dynamic>.from(j['solution'] as Map);
  Set<String> get suspectIds => suspects.map((e) => e['id'] as String).toSet();
  Set<String> get motiveIds => motives.map((e) => e['id'] as String).toSet();
  String get stamp => 'CASE ${id.split('_').last}';

  J? evidenceById(String id) {
    for (final e in evidence) {
      if (e['id'] == id) return e;
    }
    return null;
  }

  J view(J e) => {
        'id': e['id'],
        'type': e['type'],
        'title': e['title'],
        'content': e['content'],
        'scene': e['scene'] ?? '',
        'caption': e['caption'] ?? '',
      };

  String get diffLabel => const {
        'easy': 'آسان',
        'standard': 'استاندارد',
        'hard': 'سخت',
      }[difficulty]!;

  String get catLabel => const {
        'theft': 'سرقت',
        'murder': 'قتل',
        'espionage': 'جاسوسی',
      }[category] ?? category;
}

class CaseLoader {
  static List<CaseData>? _cache;

  static Future<List<CaseData>> loadAll() async {
    if (_cache != null) return _cache!;
    final out = <CaseData>[];
    for (final id in ['case_003', 'case_001', 'case_002']) {
      final s = await rootBundle.loadString('assets/cases/$id.json');
      out.add(CaseData(jsonDecode(s) as Map<String, dynamic>));
    }
    _cache = out;
    return out;
  }
}
