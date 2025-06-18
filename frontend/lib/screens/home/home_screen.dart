// lib/screens/home/home_screen.dart

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/calendar_provider.dart';
import 'package:frontend/providers/home_provider.dart';
import 'package:frontend/utils/app_theme.dart';
import 'package:frontend/widgets/tips_carousel_widget.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:frontend/widgets/ad_banner_widget.dart';
import 'package:frontend/widgets/adsense_widget_stub.dart'
    if (dart.library.html) 'package:frontend/widgets/adsense_widget_web.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Timer? _countdownTimer;
  int _secondsRemaining = 0;

  @override
  void initState() {
    super.initState();
    ref.listenManual(peakStatusProvider, (previous, next) {
      if (next.hasValue) {
        final int timeToNextChange =
            next.value?['timeToNextChange'] as int? ?? 0;
        _startUiTimer(timeToNextChange);
      }
    }, fireImmediately: true);
  }

  void _startUiTimer(int initialSeconds) {
    _countdownTimer?.cancel();
    if (mounted) {
      setState(() {
        _secondsRemaining = initialSeconds > 0 ? initialSeconds : 0;
      });
    }

    if (initialSeconds <= 0) return;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        if (mounted) {
          setState(() {
            _secondsRemaining--;
          });
        }
      } else {
        timer.cancel();
        if (mounted) {
          ref.invalidate(peakStatusProvider);
        }
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  String _formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final peakStatusAsync = ref.watch(peakStatusProvider);
    final user = authState.user;

    // By watching this provider here, we trigger the automatic scheduling
    // of peak hour notifications as soon as the user reaches the home screen.
    ref.watch(schedulesProvider);

    ImageProvider displayImage;
    if (authState.localAvatarPath != null) {
      displayImage = FileImage(File(authState.localAvatarPath!));
    } else if (user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty) {
      displayImage = NetworkImage(user.avatarUrl!);
    } else {
      displayImage = const AssetImage('assets/images/avatar.png');
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          // Allow pull-to-refresh to refetch all data.
          ref.invalidate(peakStatusProvider);
          ref.invalidate(homeProvider);
          ref.invalidate(schedulesProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            children: [
              // --- Greeting Header ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    CircleAvatar(radius: 38, backgroundImage: displayImage),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_getGreeting(),
                              style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                  color: AppTheme.primaryGreen),
                              overflow: TextOverflow.ellipsis),
                          Text(user?.name ?? 'User',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Inter',
                                  color: AppTheme.textGrey),
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // --- Peak Status and Countdown Section ---
              peakStatusAsync.when(
                data: (status) {
                  final isPeak = status['isPeak'] as bool? ?? false;
                  return Column(
                    children: [
                      _buildStatusCard(isPeak),
                      const SizedBox(height: 30),
                      _buildCountdown(isPeak),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Container(
                  padding: const EdgeInsets.all(16.0),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                      color: AppTheme.peakRed.withAlpha(26),
                      borderRadius: BorderRadius.circular(12)),
                  child: Text('Error: ${err.toString()}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppTheme.peakRed)),
                ),
              ),

              const SizedBox(height: 24),
              const TipsCarouselWidget(),
              const SizedBox(height: 40),

              // --- Ad Banner ---
              kIsWeb ? const AdsenseWidget() : const AdBannerWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(bool isPeak) {
    return Container(
      height: 273,
      width: 319,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isPeak ? AppTheme.peakRed : AppTheme.offPeakGreen,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 4))
        ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("YOU ARE IN",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 32, color: Colors.white)),
            Text(isPeak ? "PEAK HOURS" : "OFF-PEAK HOURS",
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildCountdown(bool isPeak) {
    final countdownText = _formatDuration(_secondsRemaining);
    final label = _secondsRemaining > 0
        ? (isPeak ? "Countdown until Off-Peak" : "Countdown until On-Peak")
        : "All Off-Peak Today";

    return Column(
      children: [
        Text(countdownText,
            style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter')),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black)),
      ],
    );
  }
}
