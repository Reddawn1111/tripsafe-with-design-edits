import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../utils/app_theme.dart';
import '../../widgets/buttons.dart';

/// UpdatedItineraryScreen — Displays the newly adapted itinerary after route adjustment (Step 17)
class UpdatedItineraryScreen extends StatelessWidget {
  final String tripId;
  const UpdatedItineraryScreen({super.key, this.tripId = ''});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adapted Itinerary'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppTheme.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: AppTheme.success.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: AppTheme.success, size: 28),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Itinerary Successfully Adapted!', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          'Risky coastal stops were replaced with safe inland cultural destinations and sequence re-optimized.',
                          style: TextStyle(fontSize: 12, color: AppTheme.mutedDark),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: 'View Full Itinerary',
              icon: Icons.map,
              onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.itinerary),
            ),
          ],
        ),
      ),
    );
  }
}
