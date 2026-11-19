import 'package:flutter/material.dart';

import '../core/store.dart';
import '../core/theme.dart';
import '../core/util.dart';
import '../game/case_model.dart';
import '../network/client.dart';
import '../widgets/brand.dart';
import '../widgets/ui.dart';
import 'create_room.dart';
import 'info_screens.dart';
import 'join_room.dart';
import 'room/room_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  Future<void> _resume(BuildContext context) async {
    final s = Store.i.session;
    if (s == null) return;
    final err = await GameClient.i.join(
      ip: '${s['ip']}',
      port: (s['port'] as num).toInt(),
      code: '${s['code']}',
      savedToken: '${s['token']}',
    );
    if (!context.mounted) return;
    if (err != null) {
      await Store.i.clearSession();
      if (context.mounted) snack(context, err);
      return;
    }
    Navigator.of(context).push(fxRoute(const RoomScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Stage(
      back: false,
      child: ListenableBuilder(
        listenable: Store.i,
        builder: (context, _) {
          final s = Store.i;
          final next = s.nextRank;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              Row(children: [
                const CaseLogo(size: 38, showText: false),
                const SizedBox(width: 10),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text('CASE 007', style: ts(18, w: FontWeight.w900, ls: 3)),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'تنظیمات',
                  icon: const Icon(Icons.settings_outlined, color: C.muted),
                  onPressed: () => Navigator.of(context).push(fxRoute(const SettingsScreen())),
                ),
              ]),
              const SizedBox(height: 8),
              const SystemNotice('همه سامانه‌ها آماده‌اند. بازی بدون اینترنت و روی شبکه محلی اجرا می‌شود.'),
              const SizedBox(height: 14),
              AgentIdCard(name: s.codename, code: s.agent, rankIdx: s.rank.idx),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: next == null ? 1 : (s.xp - s.rank.min) / (next.min - s.rank.min),
                  minHeight: 5,
                  color: C.blue,
                  backgroundColor: C.line,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                next == null ? 'بالاترین رتبه · ${fa(s.xp)} امتیاز' : '${fa(s.xp)} / ${fa(next.min)} امتیاز تا ${next.name}',
                style: ts(11, color: C.muted),
              ),
              if (s.session != null) ...[
                const SizedBox(height: 14),
                AppBtn('بازگشت به اتاق قبلی', icon: Icons.replay, kind: BtnKind.ghost, onTap: () => _resume(context)),
              ],
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.25,
                children: [
                  _Tile(Icons.add_moderator_outlined, 'ساخت اتاق', 'میزبان بازی شوید', C.red,
                      () => Navigator.of(context).push(fxRoute(const CreateRoomScreen()))),
                  _Tile(Icons.qr_code_scanner, 'ورود به اتاق', 'با کد یا QR', C.blue,
                      () => Navigator.of(context).push(fxRoute(const JoinRoomScreen()))),
                  _Tile(Icons.folder_copy_outlined, 'پرونده‌ها', 'فهرست پرونده‌ها', C.amber,
                      () => Navigator.of(context).push(fxRoute(const CasesScreen()))),
                  _Tile(Icons.badge_outlined, 'پروفایل', 'آمار و رتبه', C.green,
                      () => Navigator.of(context).push(fxRoute(const ProfileScreen()))),
                ],
              ),
              const SizedBox(height: 16),
              Row(children: [
                const Expanded(child: SupportButton()),
                const SizedBox(width: 10),
                Expanded(
                  child: AppBtn('درباره', icon: Icons.info_outline, kind: BtnKind.ghost,
                      onTap: () => Navigator.of(context).push(fxRoute(const AboutScreen()))),
                ),
              ]),
            ],
          );
        },
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile(this.icon, this.title, this.sub, this.color, this.onTap);
  final IconData icon;
  final String title;
  final String sub;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Panel(
        accent: color,
        onTap: onTap,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Icon(icon, color: color, size: 30),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: ts(16, w: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(sub, style: ts(11, color: C.muted)),
          ]),
        ]),
      );
}

Future<List<CaseData>> loadCases() => CaseLoader.loadAll();
