import 'package:flutter/material.dart';

import '../core/store.dart';
import '../core/support.dart';
import '../core/theme.dart';
import '../core/util.dart';
import '../game/case_model.dart';
import '../widgets/brand.dart';
import '../widgets/ui.dart';
import 'login.dart';

class CasesScreen extends StatelessWidget {
  const CasesScreen({super.key});

  @override
  Widget build(BuildContext context) => Stage(
        title: 'پرونده‌ها',
        child: FutureBuilder<List<CaseData>>(
          future: CaseLoader.loadAll(),
          builder: (context, snap) {
            if (!snap.hasData) return const LoadingScreen(label: 'بارگذاری پرونده‌ها…');
            final s = Store.i;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final c in snap.data!)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: CaseFileCard(
                      stamp: c.stamp,
                      title: c.title,
                      meta: [c.diffLabel, c.catLabel, '${fa(c.minPlayers)} تا ${fa(c.maxPlayers)} نفر'],
                      locked: s.xp < c.unlockXp,
                      lockText: 'نیازمند ${fa(c.unlockXp)} امتیاز',
                      solved: s.solved.contains(c.id),
                      onTap: () => showDialog<void>(
                        context: context,
                        builder: (d) => AlertDialog(
                          backgroundColor: C.panel,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: const BorderSide(color: C.line2),
                          ),
                          title: Text(c.title, style: ts(17, w: FontWeight.w700)),
                          content: Text(c.brief, style: ts(13, color: C.muted, h: 1.8)),
                          actions: [TextButton(onPressed: () => Navigator.pop(d), child: const Text('بستن'))],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      );
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) => Stage(
        title: 'پروفایل',
        child: ListenableBuilder(
          listenable: Store.i,
          builder: (context, _) {
            final s = Store.i;
            Widget stat(String l, String v, IconData i) => Expanded(
                  child: Panel(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                    child: Column(children: [
                      Icon(i, color: C.blue, size: 20),
                      const SizedBox(height: 6),
                      Text(v, style: ts(20, w: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text(l, style: ts(11, color: C.muted)),
                    ]),
                  ),
                );
            return ListView(padding: const EdgeInsets.all(16), children: [
              AgentIdCard(name: s.codename, code: s.agent, rankIdx: s.rank.idx),
              const SizedBox(height: 12),
              Row(children: [
                stat('امتیاز', fa(s.xp), Icons.bolt),
                const SizedBox(width: 8),
                stat('برد', fa(s.wins), Icons.emoji_events_outlined),
                const SizedBox(width: 8),
                stat('بازی', fa(s.played), Icons.sports_esports_outlined),
                const SizedBox(width: 8),
                stat('حل‌شده', fa(s.solved.length), Icons.task_alt),
              ]),
              const SecTitle('رتبه‌ها'),
              for (final r in ranks)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Panel(
                    accent: s.rank.idx == r.idx ? C.green : null,
                    child: Row(children: [
                      RankBadge(r.idx, size: 34),
                      const SizedBox(width: 12),
                      Expanded(child: Text(r.name, style: ts(15, w: FontWeight.w700))),
                      Text('${fa(r.min)}+', style: ts(12, color: C.muted)),
                    ]),
                  ),
                ),
            ]);
          },
        ),
      );
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => Stage(
        title: 'تنظیمات',
        child: ListenableBuilder(
          listenable: Store.i,
          builder: (context, _) {
            final s = Store.i;
            Widget sw(String t, String sub, bool v, String key) => SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeColor: C.blue,
                  title: Text(t, style: ts(14, w: FontWeight.w600)),
                  subtitle: Text(sub, style: ts(11, color: C.muted)),
                  value: v,
                  onChanged: (x) => s.put(key, x),
                );
            return ListView(padding: const EdgeInsets.all(16), children: [
              Panel(
                child: Column(children: [
                  const SecTitle('جلوه‌های بصری'),
                  sw('ذرات شناور', 'ذرات پس‌زمینه', s.particles, 'particles'),
                  sw('خطوط اسکن', 'اسکن‌لاین روی صفحه', s.scanline, 'scanline'),
                  sw('افکت گلیچ', 'لرزش لحظه‌ای عنوان‌ها', s.glitch, 'glitch'),
                  sw('حالت کم‌مصرف', 'کاهش انیمیشن و ذرات', s.saver, 'saver'),
                ]),
              ),
              const SizedBox(height: 12),
              Panel(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const SecTitle('کیفیت و نمایش'),
                  Text('کیفیت گرافیکی', style: ts(13, color: C.muted)),
                  const SizedBox(height: 8),
                  SegmentedButton<int>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(value: 0, label: Text('کم')),
                      ButtonSegment(value: 1, label: Text('متوسط')),
                      ButtonSegment(value: 2, label: Text('زیاد')),
                    ],
                    selected: {s.quality},
                    onSelectionChanged: (v) => s.put('quality', v.first),
                  ),
                  const SizedBox(height: 8),
                  sw('اندازه بزرگ متن', 'افزایش اندازه فونت', s.largeFont, 'largeFont'),
                ]),
              ),
              const SizedBox(height: 12),
              const SupportButton(),
              const SizedBox(height: 10),
              AppBtn('پاک‌کردن همه داده‌ها', icon: Icons.delete_outline, kind: BtnKind.danger, onTap: () async {
                final ok = await confirm(context, 'پاک‌کردن داده‌ها',
                    'پروفایل، امتیازها و تنظیمات این گوشی حذف می‌شود. ادامه می‌دهید؟');
                if (!ok) return;
                await Store.i.wipe();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(fxRoute(const LoginScreen()), (r) => false);
                }
              }),
            ]);
          },
        ),
      );
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) => Stage(
        title: 'درباره',
        child: ListView(padding: const EdgeInsets.all(24), children: [
          const Center(child: CaseLogo(size: 110)),
          const SizedBox(height: 24),
          Panel(
            child: Column(children: [
              Text('پرونده ۰۰۷', style: ts(20, w: FontWeight.w800)),
              const SizedBox(height: 6),
              Text('بازی کارآگاهی چندنفره آفلاین', style: ts(13, color: C.muted)),
              const SizedBox(height: 14),
              Text('نسخه ${fa(appVersion)}', style: ts(12, color: C.dim)),
              const SizedBox(height: 14),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text('Created by $creditName', style: ts(15, color: C.blue, w: FontWeight.w700, ls: 1)),
              ),
            ]),
          ),
          const SizedBox(height: 14),
          const SupportButton(),
          const SizedBox(height: 10),
          AppBtn('مجوزها', icon: Icons.description_outlined, kind: BtnKind.ghost, onTap: () => showLicensePage(
                context: context,
                applicationName: 'CASE 007',
                applicationVersion: appVersion,
              )),
        ]),
      );
}
