import 'package:flutter/material.dart';

import '../models/city_pulse_summary.dart';
import '../utils/app_theme.dart';
import 'common_widgets.dart';

/// Compact traveller-facing "City Pulse" card — a friendly consumer summary
/// of aggregated TripSafe visit data, at city/area level rather than the
/// per-place Travel Pulse shown in the place detail sheet. Intentionally
/// not a dense dashboard — this is not the authority-facing view.
class CityPulseCard extends StatelessWidget {
  final CityPulseSummary? summary;

  const CityPulseCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final data = summary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.bolt, color: AppTheme.secondary, size: 18),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          "What's happening around you",
                          style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (data?.isDemoData == true) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'DEMO DATA',
                            style: AppTypography.caption.copyWith(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data == null
                        ? 'Not enough traveller data yet.'
                        : '${data.busiestCategoryEmoji} Busiest right now: ${data.busiestCategoryLabel} '
                            '· 📈 Trending: ${data.trendingPlaceName}',
                    style: AppTypography.caption.copyWith(color: Colors.grey.shade700),
                  ),
                  if (data != null)
                    Text(
                      'Based on recent TripSafe traveller activity',
                      style: AppTypography.caption.copyWith(color: Colors.grey.shade500, fontSize: 10),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
