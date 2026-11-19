import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../core/util.dart';
import '../../network/client.dart';
import '../../widgets/ui.dart';

class HypothesisView extends StatefulWidget {
  const HypothesisView({super.key});

  @override
  State<HypothesisView> createState() => _HypothesisViewState();
}

class _HypothesisViewState extends State<HypothesisView> {
  final cl = GameClient.i;
  String? _su;
  String? _mo;
  final Set<String> _ev = {};
  final _why = TextEditingController();

  @override
  void dispose() {
    _why.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_su == null || _mo == null || _ev.isEmpty) {
      snack(context, 'متهم، انگیزه و حداقل یک مدرک را انتخاب کنید.');
      return;
    }
    final ok = await confirm(context, 'ثبت نظریه', 'پس از ثبت، امکان تغییر نظریه وجود ندارد.', yes: 'ثبت');
    if (!ok) return;
    cl.submitHypothesis(_su!, _mo!, _ev.toList(), _why.text);
  }

  @override
  Widget build(BuildContext context) {
    if (cl.submitted) {
      return ListView(padding: const EdgeInsets.all(16), children: [
        const SecTitle('نظریه ثبت شد'),
        Panel(
          accent: C.green,
          child: Column(children: [
            const Icon(Icons.task_alt, color: C.green, size: 40),
            const SizedBox(height: 10),
            Text('منتظر ثبت نظریه بقیه ${fa(cl.done)} / ${fa(cl.total)}', style: ts(14, color: C.muted)),
          ]),
        ),
        const SizedBox(height: 16),
        if (cl.isHost)
          AppBtn('انتقال به رأی‌گیری', icon: Icons.how_to_vote_outlined, kind: BtnKind.ghost, onTap: () async {
            if (cl.done < cl.total) {
              final ok = await confirm(context, 'انتقال به رأی‌گیری', 'همه نظریه‌ها ثبت نشده است. ادامه می‌دهید؟');
              if (!ok) return;
            }
            cl.hostAdvance();
          }),
      ]);
    }
    return ListView(padding: const EdgeInsets.all(16), children: [
      const SecTitle('ثبت نظریه نهایی'),
      Text('بر اساس مدارک و گفتگوها، حقیقت پرونده را مشخص کنید.', style: ts(13, color: C.muted, h: 1.7)),
      const SecTitle('متهم'),
      for (final s in cl.suspects)
        _Choice(
          title: '${s['name']}',
          sub: '${s['role']}',
          selected: _su == s['id'],
          onTap: () => setState(() => _su = '${s['id']}'),
        ),
      const SecTitle('انگیزه'),
      for (final m in cl.motives)
        _Choice(title: '${m['text']}', selected: _mo == m['id'], onTap: () => setState(() => _mo = '${m['id']}')),
      const SecTitle('مدارک کلیدی'),
      for (final e in cl.evidence)
        CheckboxListTile(
          value: _ev.contains(e['id']),
          activeColor: C.red,
          checkColor: Colors.white,
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: Text('${e['title']}', style: ts(14)),
          subtitle: cl.sharedIds.contains(e['id']) ? Text('مشترک', style: ts(11, color: C.green)) : null,
          onChanged: (v) => setState(() {
            if (v == true) {
              _ev.add('${e['id']}');
            } else {
              _ev.remove('${e['id']}');
            }
          }),
        ),
      const SecTitle('استدلال شما'),
      TextField(
        controller: _why,
        maxLines: 5,
        maxLength: 600,
        decoration: const InputDecoration(hintText: 'چرا این نتیجه را درست می‌دانید؟'),
      ),
      const SizedBox(height: 10),
      AppBtn('ثبت نظریه', icon: Icons.gavel, onTap: _submit),
    ]);
  }
}

class _Choice extends StatelessWidget {
  const _Choice({required this.title, this.sub, required this.selected, required this.onTap});
  final String title;
  final String? sub;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Panel(
          accent: selected ? C.red : null,
          onTap: onTap,
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, color: selected ? C.red : C.dim, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: ts(14, w: FontWeight.w700)),
                if (sub != null) Text(sub!, style: ts(11, color: C.muted)),
              ]),
            ),
          ]),
        ),
      );
}
