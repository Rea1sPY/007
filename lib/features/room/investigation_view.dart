import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../core/util.dart';
import '../../network/client.dart';
import '../../widgets/effects.dart';
import '../../widgets/evidence_art.dart';
import '../../widgets/ui.dart';
import 'evidence_viewers.dart';

class InvestigationView extends StatefulWidget {
  const InvestigationView({super.key});

  @override
  State<InvestigationView> createState() => _InvestigationViewState();
}

class _InvestigationViewState extends State<InvestigationView> {
  final cl = GameClient.i;
  int _tab = 0;

  static const _tabs = [
    (Icons.dashboard_customize_outlined, 'میز تحقیقات'),
    (Icons.description_outlined, 'اسناد'),
    (Icons.photo_library_outlined, 'تصاویر'),
    (Icons.record_voice_over_outlined, 'بازجویی'),
    (Icons.forum_outlined, 'گفتگو'),
  ];

  Widget _body() {
    switch (_tab) {
      case 0:
        return const BoardTab();
      case 1:
        return const DocsTab();
      case 2:
        return const GalleryTab();
      case 3:
        return const InterrogationTab();
      default:
        return const ChatTab();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_tab == 4) cl.chatSeen = cl.chat.length;
    final unread = _tab != 4 && cl.chat.length > cl.chatSeen;
    return Column(children: [
      Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: C.line))),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(cl.caseTitle, style: ts(16, w: FontWeight.w800)),
              Text('مرحله بررسی · مدارک را بررسی و با دیگران تبادل کنید', style: ts(10, color: C.muted)),
            ]),
          ),
          if (cl.isHost)
            AppBtn('ثبت نظریه', expand: false, height: 38, icon: Icons.gavel, onTap: () async {
              final ok = await confirm(context, 'پایان بررسی', 'همه بازیکنان به مرحله ثبت نظریه می‌روند. ادامه می‌دهید؟');
              if (ok) cl.hostAdvance();
            }),
        ]),
      ),
      Expanded(child: _body()),
      Container(
        height: 58,
        decoration: const BoxDecoration(color: C.bg2, border: Border(top: BorderSide(color: C.line))),
        child: Row(children: [
          for (var i = 0; i < _tabs.length; i++)
            Expanded(
              child: InkWell(
                onTap: () => setState(() => _tab = i),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Stack(clipBehavior: Clip.none, children: [
                    Icon(_tabs[i].$1, size: 22, color: _tab == i ? C.blue : C.dim),
                    if (i == 4 && unread)
                      Positioned(top: -2, right: -4, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: C.red, shape: BoxShape.circle))),
                  ]),
                  const SizedBox(height: 3),
                  Text(_tabs[i].$2, style: ts(10, color: _tab == i ? C.blue : C.dim, w: FontWeight.w600)),
                ]),
              ),
            ),
        ]),
      ),
    ]);
  }
}

IconData _icon(String t) => t == 'photo' ? Icons.photo_camera_outlined : t == 'note' ? Icons.sticky_note_2_outlined : Icons.description_outlined;

class BoardTab extends StatefulWidget {
  const BoardTab({super.key});

  @override
  State<BoardTab> createState() => _BoardTabState();
}

class _BoardTabState extends State<BoardTab> {
  final cl = GameClient.i;
  bool _link = false;
  String? _from;
  static const cw = 150.0;
  static const ch = 92.0;

  void _layout() {
    var n = 0;
    for (final e in cl.evidence) {
      final id = '${e['id']}';
      if (!cl.pos.containsKey(id)) {
        final k = cl.pos.length;
        cl.pos[id] = Offset(14.0 + (k % 2) * 170, 14.0 + (k ~/ 2) * 112);
      }
      n++;
    }
    if (n == 0) return;
  }

  String _key(String a, String b) => a.compareTo(b) < 0 ? '$a|$b' : '$b|$a';

  void _tapCard(String id) {
    if (!_link) {
      openEvidence(context, id);
      return;
    }
    if (_from == null) {
      setState(() => _from = id);
    } else if (_from == id) {
      setState(() => _from = null);
    } else {
      final k = _key(_from!, id);
      setState(() {
        if (!cl.links.remove(k)) cl.links.add(k);
        _from = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _layout();
    if (cl.evidence.isEmpty) {
      return Center(child: Text('مدرکی در اختیار شما نیست.', style: ts(13, color: C.muted)));
    }
    final s = cl.boardScale;
    final o = cl.boardOff;
    return ClipRect(
      child: Stack(children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onPanUpdate: (d) => setState(() => cl.boardOff += d.delta),
            child: const SizedBox.expand(),
          ),
        ),
        Transform(
          transform: Matrix4(s, 0, 0, 0, 0, s, 0, 0, 0, 0, 1, 0, o.dx, o.dy, 0, 1),
          child: SizedBox(
            width: 1400,
            height: 1800,
            child: Stack(children: [
              IgnorePointer(child: CustomPaint(size: const Size(1400, 1800), painter: _LinkPainter(cl.links, cl.pos))),
              for (final e in cl.evidence) _card(e),
            ]),
          ),
        ),
        Positioned(
          top: 8,
          left: 8,
          child: Column(children: [
            _tool(Icons.link, _link, () => setState(() {
                  _link = !_link;
                  _from = null;
                })),
            _tool(Icons.add, false, () => setState(() => cl.boardScale = min(1.6, cl.boardScale + 0.15))),
            _tool(Icons.remove, false, () => setState(() => cl.boardScale = max(0.4, cl.boardScale - 0.15))),
            _tool(Icons.grid_view, false, () => setState(() {
                  cl.pos.clear();
                  cl.boardOff = Offset.zero;
                  cl.boardScale = 0.9;
                })),
          ]),
        ),
        if (_link)
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Center(
              child: Tag(_from == null ? 'حالت اتصال: مدرک اول را انتخاب کنید' : 'مدرک دوم را انتخاب کنید', color: C.red, icon: Icons.link),
            ),
          ),
      ]),
    );
  }

  Widget _tool(IconData i, bool on, VoidCallback f) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Material(
          color: on ? C.red : C.panel2,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: f,
            child: SizedBox(width: 44, height: 44, child: Icon(i, color: on ? Colors.white : C.text, size: 22)),
          ),
        ),
      );

  Widget _card(J e) {
    final id = '${e['id']}';
    final p = cl.pos[id]!;
    final shared = cl.sharedIds.contains(id);
    final sel = _from == id;
    return Positioned(
      left: p.dx,
      top: p.dy,
      width: cw,
      height: ch,
      child: GestureDetector(
        onTap: () => _tapCard(id),
        onPanUpdate: (d) => setState(() => cl.pos[id] = p + d.delta / cl.boardScale),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: C.panel2,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: sel ? C.red : C.line2, width: sel ? 2 : 1),
            boxShadow: const [BoxShadow(color: Color(0x99000000), blurRadius: 8, offset: Offset(0, 3))],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(_icon('${e['type']}'), size: 16, color: C.blue),
              const Spacer(),
              if (shared) const Icon(Icons.groups, size: 14, color: C.green),
            ]),
            const SizedBox(height: 6),
            Expanded(child: Text('${e['title']}', maxLines: 3, overflow: TextOverflow.ellipsis, style: ts(12, w: FontWeight.w700, h: 1.4))),
          ]),
        ),
      ),
    );
  }
}

class _LinkPainter extends CustomPainter {
  _LinkPainter(this.links, this.pos);
  final Set<String> links;
  final Map<String, Offset> pos;

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = C.red
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final pin = Paint()..color = C.red;
    for (final k in links) {
      final ids = k.split('|');
      final a = pos[ids[0]];
      final b = pos[ids[1]];
      if (a == null || b == null) continue;
      final pa = a + const Offset(_BoardTabState.cw / 2, 10);
      final pb = b + const Offset(_BoardTabState.cw / 2, 10);
      final mid = Offset((pa.dx + pb.dx) / 2, (pa.dy + pb.dy) / 2 + 22);
      canvas.drawPath(Path()..moveTo(pa.dx, pa.dy)..quadraticBezierTo(mid.dx, mid.dy, pb.dx, pb.dy), line);
      canvas.drawCircle(pa, 5, pin);
      canvas.drawCircle(pb, 5, pin);
    }
  }

  @override
  bool shouldRepaint(covariant _LinkPainter old) => true;
}

class DocsTab extends StatefulWidget {
  const DocsTab({super.key});

  @override
  State<DocsTab> createState() => _DocsTabState();
}

class _DocsTabState extends State<DocsTab> {
  final cl = GameClient.i;
  String _q = '';
  String _f = 'all';

  @override
  Widget build(BuildContext context) {
    final list = cl.evidence.where((e) {
      if (_f == 'shared' && !cl.sharedIds.contains(e['id'])) return false;
      if (_f != 'all' && _f != 'shared' && e['type'] != _f) return false;
      if (_q.isEmpty) return true;
      return '${e['title']} ${e['content']}'.contains(_q);
    }).toList();
    const filters = {'all': 'همه', 'document': 'اسناد', 'note': 'یادداشت‌ها', 'photo': 'تصاویر', 'shared': 'مشترک'};
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
        child: TextField(
          onChanged: (v) => setState(() => _q = v.trim()),
          decoration: const InputDecoration(hintText: 'جستجو در مدارک', prefixIcon: Icon(Icons.search, color: C.muted)),
        ),
      ),
      SizedBox(
        height: 44,
        child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 12), children: [
          for (final f in filters.entries)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: ChoiceChip(
                label: Text(f.value),
                selected: _f == f.key,
                onSelected: (_) => setState(() => _f = f.key),
                selectedColor: C.blue.withAlpha(50),
                backgroundColor: C.panel2,
                side: BorderSide(color: _f == f.key ? C.blue : C.line2),
              ),
            ),
        ]),
      ),
      Expanded(
        child: list.isEmpty
            ? Center(child: Text('مدرکی پیدا نشد.', style: ts(13, color: C.muted)))
            : ListView(padding: const EdgeInsets.all(16), children: [
                for (final e in list)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Panel(
                      onTap: () => openEvidence(context, '${e['id']}'),
                      padding: const EdgeInsets.all(12),
                      child: Row(children: [
                        Icon(_icon('${e['type']}'), color: C.blue),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('${e['title']}', style: ts(14, w: FontWeight.w700)),
                            const SizedBox(height: 3),
                            Text('${e['content']}', maxLines: 1, overflow: TextOverflow.ellipsis, style: ts(12, color: C.muted)),
                          ]),
                        ),
                        if (cl.sharedIds.contains(e['id'])) const Icon(Icons.groups, color: C.green, size: 18),
                      ]),
                    ),
                  ),
              ]),
      ),
    ]);
  }
}

class GalleryTab extends StatelessWidget {
  const GalleryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final photos = GameClient.i.evidence.where((e) => e['type'] == 'photo').toList();
    if (photos.isEmpty) {
      return Center(child: Text('تصویری در اختیار شما نیست.', style: ts(13, color: C.muted)));
    }
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(16),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.85,
      children: [
        for (final e in photos)
          GestureDetector(
            onTap: () => openEvidence(context, '${e['id']}'),
            child: Column(children: [
              Expanded(child: EvidenceArt(scene: '${e['scene']}', caption: '${e['caption']}')),
              const SizedBox(height: 6),
              Text('${e['title']}', style: ts(12, w: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
            ]),
          ),
      ],
    );
  }
}

class InterrogationTab extends StatefulWidget {
  const InterrogationTab({super.key});

  @override
  State<InterrogationTab> createState() => _InterrogationTabState();
}

class _InterrogationTabState extends State<InterrogationTab> {
  final cl = GameClient.i;
  String? _sid;
  bool _typing = false;

  static const _lines = {
    'pressure': 'راستش را بگو؛ آن شب دقیقاً کجا بودی؟',
    'empathy': 'می‌دانم برایت سخت است؛ آرام توضیح بده.',
    'accuse': 'مدرک داریم که تو در این ماجرا نقش داشتی.',
  };
  static const _pre = ['', 'دوباره می‌گویم: ', 'از تکرار خسته شدم؛ ', 'باشه، یک بار دیگر: '];

  void _ask(J s, String kind) {
    final id = '${s['id']}';
    final k = '$id|$kind';
    final n = cl.interroCount[k] ?? 0;
    cl.interroCount[k] = n + 1;
    final base = '${(s['responses'] as Map)[kind]}';
    final list = cl.interro.putIfAbsent(id, () => []);
    list.add({'who': 'me', 'text': _lines[kind]});
    list.add({'who': 'sus', 'text': '${_pre[n % _pre.length]}$base'});
    setState(() => _typing = true);
  }

  @override
  Widget build(BuildContext context) {
    final sus = cl.suspects;
    if (sus.isEmpty) return const SizedBox.shrink();
    _sid ??= '${sus.first['id']}';
    final s = sus.firstWhere((x) => x['id'] == _sid);
    final log = cl.interro[_sid] ?? [];
    return Column(children: [
      SizedBox(
        height: 52,
        child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.all(8), children: [
          for (final x in sus)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                label: Text('${x['name']}'),
                selected: _sid == x['id'],
                onSelected: (_) => setState(() {
                  _sid = '${x['id']}';
                  _typing = false;
                }),
                selectedColor: C.red.withAlpha(50),
                backgroundColor: C.panel2,
                side: BorderSide(color: _sid == x['id'] ? C.red : C.line2),
              ),
            ),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Panel(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${s['name']} · ${s['role']}', style: ts(14, w: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('${s['bio']}', style: ts(12, color: C.muted, h: 1.7)),
          ]),
        ),
      ),
      Expanded(
        child: log.isEmpty
            ? Center(child: Text('بازجویی را آغاز کنید.', style: ts(13, color: C.muted)))
            : ListView(padding: const EdgeInsets.all(16), children: [
                for (var i = 0; i < log.length; i++) _bubble(log[i], i == log.length - 1 && _typing),
              ]),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        child: Row(children: [
          Expanded(child: AppBtn('فشار', height: 46, onTap: () => _ask(s, 'pressure'))),
          const SizedBox(width: 8),
          Expanded(child: AppBtn('همدلی', height: 46, kind: BtnKind.ghost, onTap: () => _ask(s, 'empathy'))),
          const SizedBox(width: 8),
          Expanded(child: AppBtn('اتهام', height: 46, kind: BtnKind.danger, onTap: () => _ask(s, 'accuse'))),
        ]),
      ),
    ]);
  }

  Widget _bubble(J m, bool typeIt) {
    final me = m['who'] == 'me';
    final st = ts(13, h: 1.7);
    return Align(
      alignment: me ? AlignmentDirectional.centerStart : AlignmentDirectional.centerEnd,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 290),
        decoration: BoxDecoration(
          color: me ? C.blue.withAlpha(28) : C.panel2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: me ? C.blue.withAlpha(110) : C.line2),
        ),
        child: typeIt && !me ? TypewriterText('${m['text']}', style: st) : Text('${m['text']}', style: st),
      ),
    );
  }
}

class ChatTab extends StatefulWidget {
  const ChatTab({super.key});

  @override
  State<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
  final cl = GameClient.i;
  final _ctl = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _ctl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send() {
    final t = _ctl.text.trim();
    if (t.isEmpty) return;
    cl.sendChat(t);
    _ctl.clear();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });
    return Column(children: [
      Expanded(
        child: cl.chat.isEmpty
            ? Center(child: Text('هنوز پیامی ارسال نشده است.', style: ts(13, color: C.muted)))
            : ListView(controller: _scroll, padding: const EdgeInsets.all(16), children: [
                for (final m in cl.chat)
                  if (m.system)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Center(child: Tag(m.text, color: C.green, icon: Icons.share_outlined)),
                    )
                  else
                    _msg(m),
              ]),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
        child: Row(children: [
          Expanded(
            child: TextField(
              controller: _ctl,
              maxLength: 400,
              onSubmitted: (_) => _send(),
              decoration: const InputDecoration(hintText: 'پیام…', counterText: ''),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            tooltip: 'ارسال',
            style: IconButton.styleFrom(backgroundColor: C.red, minimumSize: const Size(48, 48)),
            onPressed: _send,
            icon: const Icon(Icons.send),
          ),
        ]),
      ),
    ]);
  }

  Widget _msg(ChatLine m) {
    final mine = m.pid == cl.myPid;
    return Align(
      alignment: mine ? AlignmentDirectional.centerStart : AlignmentDirectional.centerEnd,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        constraints: const BoxConstraints(maxWidth: 290),
        decoration: BoxDecoration(
          color: mine ? C.blue.withAlpha(28) : C.panel2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: mine ? C.blue.withAlpha(110) : C.line2),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (!mine) Text(m.name, style: ts(11, color: C.blue, w: FontWeight.w700)),
          Text(m.text, style: ts(13, h: 1.6)),
        ]),
      ),
    );
  }
}

