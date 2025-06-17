// lib/widgets/tips_carousel_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/home_provider.dart';
import 'package:frontend/utils/app_theme.dart';

class TipsCarouselWidget extends ConsumerWidget {
  const TipsCarouselWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the notes from the simple homeProvider
    final homeState = ref.watch(homeProvider);
    // Get the peak status from the peakStatusProvider
    final peakStatusAsync = ref.watch(peakStatusProvider);

    // Use .when to safely handle the loading/error/data states of the peak status
    return peakStatusAsync.when(
      data: (status) {
        final isPeak = status['isPeak'] as bool? ?? false;
        final currentPeakStatus = isPeak ? 'ON_PEAK' : 'OFF_PEAK';

        // Filter the notes to only show tips relevant to the current period
        final relevantNotes = homeState.notes
            .where((note) => note.peakPeriod == currentPeakStatus)
            .toList();

        if (relevantNotes.isEmpty) {
          return Container(
            height: 59,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            alignment: Alignment.center,
            child:
                Text('No ${isPeak ? "On-Peak" : "Off-Peak"} tips available.'),
          );
        }

        return SizedBox(
          height: 59,
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.9),
            itemCount: relevantNotes.length,
            itemBuilder: (context, index) {
              final note = relevantNotes[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0x0F545454), // ~5% dark grey
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: isPeak ? AppTheme.peakRed : AppTheme.offPeakGreen,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child:
                          Text(note.content, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
      // While the peak status is loading, show an empty container.
      loading: () => const SizedBox(height: 59),
      error: (e, s) => const SizedBox(height: 59),
    );
  }
}
