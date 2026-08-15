import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../models/place.dart';
import '../../models/place_category.dart';
import '../../services/trip_planning_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common_widgets.dart';

/// AdaptTripScreen — Replaces high-risk or affected stops with safe alternatives (Step 17)
class AdaptTripScreen extends StatelessWidget {
  final String tripId;
  final String alertId;

  const AdaptTripScreen({
    super.key,
    this.tripId = '',
    this.alertId = '',
  });

  @override
  Widget build(BuildContext context) {
    final planningService = TripPlanningService.instance;

    final safeAlternatives = [
      Place(
        id: 'alt_1',
        name: 'Regional Maritime & Art Museum',
        latitude: 11.2590,
        longitude: 75.7790,
        address: '88 Station Road, Cultural District',
        category: PlaceCategory.museum,
        rating: 4.6,
        reviewCount: 840,
        typicalDwellMinutes: 75,
        estimatedCost: 100.0,
        dataSource: 'Safe Inland Verification',
      ),
      Place(
        id: 'alt_2',
        name: 'Central Botanical Gardens (Inland Walk)',
        latitude: 11.2520,
        longitude: 75.7830,
        address: 'Park Avenue, City Green Zone',
        category: PlaceCategory.park,
        rating: 4.8,
        reviewCount: 2450,
        typicalDwellMinutes: 60,
        estimatedCost: 30.0,
        dataSource: 'Safe Inland Verification',
      ),
      Place(
        id: 'alt_3',
        name: 'Old Town Heritage Crafts Market',
        latitude: 11.2640,
        longitude: 75.7860,
        address: 'Clocktower Square, Bazaar St',
        category: PlaceCategory.shopping,
        rating: 4.5,
        reviewCount: 3100,
        typicalDwellMinutes: 65,
        estimatedCost: 300.0,
        dataSource: 'Safe Inland Verification',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Adapt Trip Plan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppTheme.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: AppTheme.secondary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.alt_route, color: AppTheme.secondary, size: 28),
                  const SizedBox(width: AppSpacing.md),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Smart Route Adaptation', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          'Select safe alternative stops below to replace high-risk coastal stops and automatically re-sequence your route.',
                          style: TextStyle(fontSize: 12, color: AppTheme.mutedDark),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Recommended Safe Replacements:', style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: safeAlternatives.length,
                itemBuilder: (context, index) {
                  final alt = safeAlternatives[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: AppCard(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                            child: Text(alt.category.iconEmoji),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(alt.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text(
                                  '${alt.category.displayName} · ⭐ ${alt.rating}',
                                  style: const TextStyle(fontSize: 12, color: AppTheme.mutedDark),
                                ),
                                Text(
                                  'Safe inland conditions · ~₹${alt.estimatedCost.round()}',
                                  style: const TextStyle(fontSize: 11, color: AppTheme.success, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.secondary,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            onPressed: () {
                              planningService.addPlaceToTrip(alt);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: AppTheme.success,
                                  content: Text('Replaced with ${alt.name}! Itinerary updated.'),
                                ),
                              );
                              Navigator.pushReplacementNamed(context, AppRoutes.itinerary);
                            },
                            child: const Text('Swap Stop', style: TextStyle(color: Colors.white, fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            PrimaryButton(
              label: 'Browse All Alternative Destinations',
              icon: Icons.travel_explore,
              onPressed: () => Navigator.pushNamed(context, AppRoutes.alternatives),
            ),
          ],
        ),
      ),
    );
  }
}
