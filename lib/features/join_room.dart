import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../core/theme.dart';
import '../network/client.dart';
import '../widgets/brand.dart';
import '../widgets/ui.dart';
import 'room/room_screen.dart';

class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final _code = TextEditingController();
  final _ip = TextEditingController();
  int _port = 8765;
  bool _busy = false;
  String? _err;

  @override
  void dispose() {
    _code.dispose();
    _ip.dispose();
    super.dispose();
  }

  Future<void> _scan() async {
    final v = await Navigator.of(context).push<String>(fxRoute(const _ScanScreen()));
    if (v == null) return;
    try {
      final o = jsonDecode(v) as Map<String, dynamic>;
      setState(() {
        _ip.text = '${o['ip']}';
        _code.text = '${o['code']}';
        _port = (o['port'] as num).toInt();
        _err = null;
      });
      await _join();
    } catch (_) {
      setState(() => _err = 'این QR مربوط به CASE 007 نیست.');
    }
  }

  Future<void> _join() async {
    final code = _code.text.trim().toUpperCase();
    final ip = _ip.text.trim();
    if (code.length != 6 || !RegExp(r'^\d{1,3}(\.\d{1,3}){3}$').hasMatch(ip)) {
      setState(() => _err = 'کد ۶ نویسه‌ای و آدرس IP معتبر را وارد کنید.');
      return;
    }
    setState(() {
      _busy = true;
      _err = null;
    });
    final err = await GameClient.i.join(ip: ip, port: _port, code: code);
    if (!mounted) return;
    if (err != null) {
      setState(() {
        _busy = false;
        _err = err;
      });
      return;
    }
    Navigator.of(context).pushReplacement(fxRoute(const RoomScreen()));
  }

  @override
  Widget build(BuildContext context) => Stage(
        title: 'ورود به اتاق',
        child: _busy
            ? const LoadingScreen(label: 'در حال اتصال به میزبان…')
            : ListView(padding: const EdgeInsets.all(16), children: [
                AppBtn('اسکن QR میزبان', icon: Icons.qr_code_scanner, onTap: _scan),
                const SizedBox(height: 16),
                Row(children: [
                  const Expanded(child: Divider()),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text('یا ورود دستی', style: ts(12, color: C.muted))),
                  const Expanded(child: Divider()),
                ]),
                const SizedBox(height: 16),
                Panel(
                  child: Column(children: [
                    TextField(
                      controller: _code,
                      maxLength: 6,
                      textCapitalization: TextCapitalization.characters,
                      textDirection: TextDirection.ltr,
                      style: ts(18, w: FontWeight.w800, ls: 6),
                      decoration: const InputDecoration(labelText: 'کد اتاق', counterText: ''),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _ip,
                      keyboardType: TextInputType.number,
                      textDirection: TextDirection.ltr,
                      decoration: const InputDecoration(labelText: 'آدرس IP میزبان', hintText: '192.168.43.1'),
                    ),
                    if (_err != null) ...[
                      const SizedBox(height: 12),
                      SystemNotice(_err!, icon: Icons.error_outline, color: C.red),
                    ],
                  ]),
                ),
                const SizedBox(height: 16),
                AppBtn('اتصال', icon: Icons.link, kind: BtnKind.ghost, onTap: _join),
              ]),
      );
}

class _ScanScreen extends StatefulWidget {
  const _ScanScreen();

  @override
  State<_ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<_ScanScreen> {
  bool _done = false;

  @override
  Widget build(BuildContext context) => Stage(
        title: 'اسکن QR',
        child: Stack(children: [
          MobileScanner(
            onDetect: (cap) {
              if (_done) return;
              for (final b in cap.barcodes) {
                final v = b.rawValue;
                if (v != null) {
                  _done = true;
                  Navigator.of(context).pop(v);
                  return;
                }
              }
            },
            errorBuilder: (context, error, child) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('دسترسی به دوربین ممکن نیست. اجازه دوربین را بدهید یا کد را دستی وارد کنید.',
                    textAlign: TextAlign.center, style: ts(14, color: C.muted, h: 1.8)),
              ),
            ),
          ),
          Center(
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                border: Border.all(color: C.blue, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ]),
      );
}
