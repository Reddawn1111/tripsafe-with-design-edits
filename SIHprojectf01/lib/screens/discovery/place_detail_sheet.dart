import 'package:flutter/material.dart';

import '../../models/place.dart';
import '../../services/itinerary_service.dart';
import '../../services/travel_insights_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common_widgets.dart';

/// Bottom Sheet modal showing detailed information, dwell intelligence,
/// best visit windows, and itinerary actions for a selected Place.
class PlaceDetailSheet extends StatefulWidget {
  final Place place;

  const PlaceDetailSheet({super.key, required this.place});

  static Future<void> show(BuildContext context, Place place) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PlaceDetailSheet(place: place),
    );
  }

  @override
  State<PlaceDetailSheet> createState() => _PlaceDetailSheetState();
}

class _PlaceDetailSheetState extends State<PlaceDetailSheet> {
  final _itineraryService = ItineraryService.instance;
  final _insightsService = TravelInsightsService.instance;
  late bool _isAdded;

  @override
  void initState() {
    super.initState();
    _isAdded = _itineraryService.isPlaceInItinerary(widget.place.id);
  }

  void _toggleItinerary() {
    if (_isAdded) {
      _itineraryService.removePlaceFromItinerary(widget.place.id);
      setState(() => _isAdded = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.place.name} removed from your itinerary.'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      final success = _itineraryService.addPlaceToItinerary(widget.place);
      if (success) {
        setState(() => _isAdded = true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppTheme.success,
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('${widget.place.name} added to itinerary!'),
                  ),
                ],
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final place = widget.place;
    final theme = Theme.of(context);
    final guide = _insightsService.getBestTimeToVisitGuide(place);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      padding: EdgeInsets.only(
        top: AppSpacing.sm,
        left: AppSpacing.md,
        right: AppSpacing.md,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.md,
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header Banner
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              child: Container(
                height: 140,
                width: double.infinity,
                color: AppTheme.primary.withValues(alpha: 0.1),
                child: place.photoUrl != null
                    ? Image.network(
                        place.photoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildPlaceholderBanner(place),
                      )
                    : _buildPlaceholderBanner(place),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Name and Category Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    place.name,
                    style: AppTypography.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Text(
                    '${place.category.iconEmoji} ${place.category.displayName}',
                    style: AppTypography.caption.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xs),

            // Rating, Review Count, Distance & Estimated Cost
            Wrap(
              spacing: 12,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (place.hasRating)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        place.ratingLabel,
                        style: AppTypography.labelLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${place.reviewCountLabel})',
                        style: AppTypography.caption.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on, color: AppTheme.secondary, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '${place.distanceKm.toStringAsFixed(1)} km away',
                      style: AppTypography.bodyMedium,
                    ),
                  ],
                ),
                if (place.priceDisplay.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      place.priceDisplay,
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // Travel Pulse: aggregated popularity (gated through
            // TravelInsightsService's k-anonymity/demo-data rules) + best
            // time to visit guidance, merged into one calmer section.
            _buildTravelPulseCard(place, guide),

            const SizedBox(height: AppSpacing.md),

            // Recommendation Reason Box
            if (place.recommendationReason.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: Color(0xFF00BFA6), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        place.recommendationReason,
                        style: AppTypography.caption.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],

            // Address & Data Provenance Label
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.place_outlined, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    place.address,
                    style: AppTypography.bodySmall.copyWith(color: Colors.grey.shade700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.verified_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  'Source: ${place.dataSource}',
                  style: AppTypography.caption.copyWith(color: Colors.grey, fontSize: 10),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // Action Buttons: Add to Itinerary & Open in Maps
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: PrimaryButton(
                    label: _isAdded ? 'In Itinerary' : 'Add to Day Plan',
                    icon: _isAdded ? Icons.bookmark_added : Icons.bookmark_add_outlined,
                    onPressed: _toggleItinerary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  flex: 1,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Opening maps coordinates: ${place.latitude.toStringAsFixed(4)}, ${place.longitude.toStringAsFixed(4)}'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.directions, size: 18),
                    label: const Text('Directions'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTravelPulseCard(Place place, Map<String, String> guide) {
    // Route through TravelInsightsService rather than reading place.visitCount
    // /busyHours directly — this is what applies the k-anonymity threshold
    // and demo-data gating, instead of showing unconditional numbers for a
    // real (non-demo) place with too few logged visits.
    final stats = _insightsService.getAggregateStats(place);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  '📊 Travel Pulse',
                  style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (stats?.isDemoData == true) ...[
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
          const SizedBox(height: 6),
          if (stats == null)
            Text(
              'Not enough traveller data yet — be the first to log a consented visit here.',
              style: AppTypography.caption.copyWith(color: Colors.grey.shade600),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '🔥 ${stats.totalVisits} visits · Avg stay ${stats.averageDwellMinutes} min',
                    style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  '🕐 ${stats.busiestTimeWindow}',
                  style: AppTypography.caption.copyWith(color: Colors.grey.shade600),
                ),
              ],
            ),
          const SizedBox(height: 6),
          Divider(height: 1, color: Colors.grey.shade200),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.wb_sunny_outlined, color: AppTheme.secondary, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Best time: ${guide['bestFor']} · ${guide['recommended']}',
                  style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderBanner(Place place) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            place.category.iconData,
            size: 48,
            color: AppTheme.primary,
          ),
          const SizedBox(height: 6),
          Text(
            place.category.displayName,
            style: AppTypography.labelLarge.copyWith(
              color: AppTheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
