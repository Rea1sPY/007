import 'package:flutter/material.dart';

import '../../core/store.dart';
import '../../core/theme.dart';
import '../../core/util.dart';
import '../../network/client.dart';
import '../../widgets/brand.dart';
import '../../widgets/ui.dart';

class ResultView extends StatelessWidget {
  const ResultView({super.key});

  @override
  Widget build(BuildContext context) {
    final cl = GameClient.i;
    final r = cl.result;
    if (r == null) return const LoadingScreen(label: 'اعلام نتیجه…');
    final sol = Map<String, dynamic>.from(r['solution'] as Map);
    final rows = asList(r['rows']);
    return ListView(padding: const EdgeInsets.all(16), children: [
      Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 2.4, end: 1),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
          builder: (context, t, child) => Opacity(opacity: (2.4 - t).clamp(0, 1).toDouble(), child: Transform.scale(scale: t, child: child)),
          child: const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: TopSecretStamp(text: 'CASE CLOSED', size: 26, color: C.green)),
        ),
      ),
      const SecTitle('حقیقت پرونده'),
      Panel(
        accent: C.red,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.person_search, color: C.red),
            const SizedBox(width: 8),
            Text('متهم واقعی: ${cl.suspectName('${sol['culprit']}')}', style: ts(17, w: FontWeight.w800, color: C.red)),
          ]),
          const SizedBox(height: 8),
          Text('انگیزه: ${cl.motiveText('${sol['motive']}')}', style: ts(14, w: FontWeight.w600)),
          const SizedBox(height: 10),
          Text('${sol['explanation']}', style: ts(13, color: C.muted, h: 1.9)),
          const SizedBox(height: 10),
          Text('مدارک کلیدی', style: ts(12, color: C.muted)),
          const SizedBox(height: 6),
          Wrap(spacing: 6, runSpacing: 6, children: [
            for (final e in asList(sol['keyEvidence'])) Tag('${e['title']}', color: C.amber),
          ]),
        ]),
      ),
      const SecTitle('جدول امتیازها'),
      for (var i = 0; i < rows.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Panel(
            accent: rows[i]['pid'] == r['winner'] ? C.green : null,
            child: Row(children: [
              Text(fa(i + 1), style: ts(18, w: FontWeight.w900, color: C.muted)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text('${rows[i]['name']}', style: ts(15, w: FontWeight.w700)),
                    if (rows[i]['pid'] == r['winner']) ...[const SizedBox(width: 8), const Tag('برنده', color: C.green)],
                  ]),
                  const SizedBox(height: 4),
                  Text(
                    rows[i]['submitted'] == true
                        ? 'متهم ${fa((rows[i]['break'] as Map)['culprit'])} · انگیزه ${fa((rows[i]['break'] as Map)['motive'])} · مدارک ${fa((rows[i]['break'] as Map)['evidence'])} · رأی ${fa(rows[i]['votes'])}'
                        : 'نظریه ثبت نکرد',
                    style: ts(11, color: C.muted),
                  ),
                ]),
              ),
              Text(fa(rows[i]['score']), style: ts(20, w: FontWeight.w900, color: C.blue)),
            ]),
          ),
        ),
      const SizedBox(height: 8),
      Panel(
        accent: C.blue,
        child: Row(children: [
          const Icon(Icons.bolt, color: C.blue),
          const SizedBox(width: 10),
          Expanded(child: Text('امتیاز کسب‌شده شما: ${fa(cl.gained)}', style: ts(14, w: FontWeight.w700))),
          ListenableBuilder(
            listenable: Store.i,
            builder: (context, _) => Tag(Store.i.rank.name, color: C.green),
          ),
        ]),
      ),
      if (cl.rankedUp) ...[
        const SizedBox(height: 10),
        const SystemNotice('ارتقای رتبه! رتبه جدید شما ثبت شد.', icon: Icons.military_tech_outlined, color: C.amber),
      ],
      const SizedBox(height: 16),
      if (cl.isHost)
        AppBtn('بازگشت به لابی', icon: Icons.replay, onTap: cl.hostToLobby)
      else
        Panel(child: Text('منتظر بازگشت میزبان به لابی…', textAlign: TextAlign.center, style: ts(13, color: C.muted))),
      const SizedBox(height: 10),
      AppBtn('خروج', icon: Icons.logout, kind: BtnKind.ghost, onTap: () async {
        await cl.leave();
        if (context.mounted) Navigator.of(context).popUntil((r) => r.isFirst);
      }),
    ]);
  }
}
