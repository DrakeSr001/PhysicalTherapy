import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../services/api_client.dart';

class KioskScreen extends StatefulWidget {
  const KioskScreen({super.key});

  @override
  State<KioskScreen> createState() => _KioskScreenState();
}

class _KioskScreenState extends State<KioskScreen> {
  final _api = ApiClient();

  String? _code;
  DateTime? _expiresAt;
  Timer? _refreshTimer;
  Timer? _ticker;
  String? _error;

  @override
  void initState() {
    super.initState();
    // keep the device awake while kiosk is open
    WakelockPlus.enable();
    _loadCode();
    // 1-second ticker for the countdown text
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _ticker?.cancel();
    WakelockPlus.disable();
    super.dispose();
  }

  Future<void> _loadCode() async {
    _refreshTimer?.cancel();
    setState(() {
      _error = null;
      _code = null;
      _expiresAt = null;
    });

    try {
      final res = await _api.fetchKioskCode();
      setState(() {
        _code = res.code;
        _expiresAt = res.expiresAt;
      });
      _scheduleRefresh();
    } catch (e) {
      setState(() => _error = 'Couldn\'t get code. Retrying…');
      // retry after a short delay
      _refreshTimer = Timer(const Duration(seconds: 5), _loadCode);
    }
  }

  void _scheduleRefresh() {
    if (_expiresAt == null) return;
    final now = DateTime.now();
    final remaining = _expiresAt!.difference(now);
    // refresh a few seconds *before* expiry (min 3s, max 25s safety window)
    final refreshIn = Duration(
      seconds: (remaining.inSeconds - 3).clamp(3, 25),
    );
    _refreshTimer = Timer(refreshIn, _loadCode);
  }

  String _countdownText() {
    if (_expiresAt == null) return '—';
    final s = _expiresAt!.difference(DateTime.now()).inSeconds;
    final left = s < 0 ? 0 : s;
    return '$left s';
  }

  @override
  Widget build(BuildContext context) {
    final qr = _code;

    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text('مركز العلاج الطبيعي - الوفاء و الأمل', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), )),
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Attendance Check-in / Out',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 24),

                  // status / error
                  if (_error != null) ...[
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 16),
                  ],

                  // QR or loader
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 10,
                          color: Color(0x22000000),
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: 300,
                      height: 300,
                      child: qr == null
                          ? const Center(child: CircularProgressIndicator())
                          : QrImageView(
                              data: qr,
                              size: 300,
                              version: QrVersions.auto,
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.timer_outlined, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Code refresh in: ${_countdownText()}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  // manual refresh (useful during dev)
                  ElevatedButton.icon(
                    onPressed: _loadCode,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh code'),
                  ),

                  const SizedBox(height: 24),
                  // small footer
                  Text(
                    _expiresAt == null
                        ? 'Waiting for code…'
                        : 'Expires at: ${_expiresAt!.toLocal()}',
                    style: const TextStyle(color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
