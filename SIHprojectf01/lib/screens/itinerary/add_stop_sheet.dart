import 'package:flutter/material.dart';

import '../../models/place.dart';
import '../../services/nearby_discovery_service.dart';
import '../../utils/app_theme.dart';

/// Modal bottom sheet for picking a place to add to (or swap into) the
/// itinerary. Sources candidates from [MockNearbyDiscoveryService] — already
/// available, no network/GPS dependency — rather than a new live-search
/// picker, so this works offline and in tests.
class AddStopSheet extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String title;

  const AddStopSheet({
    super.key,
    required this.latitude,
    required this.longitude,
    this.title = 'Add a Stop',
  });

  static Future<Place?> show(
    BuildContext context, {
    required double latitude,
    required double longitude,
    String title = 'Add a Stop',
  }) {
    return showModalBottomSheet<Place>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddStopSheet(
        latitude: latitude,
        longitude: longitude,
        title: title,
      ),
    );
  }

  @override
  State<AddStopSheet> createState() => _AddStopSheetState();
}

class _AddStopSheetState extends State<AddStopSheet> {
  final _discoveryService = MockNearbyDiscoveryService();
  List<Place> _candidates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCandidates();
  }

  Future<void> _loadCandidates() async {
    final places = await _discoveryService.getNearbyPlaces(
      latitude: widget.latitude,
      longitude: widget.longitude,
    );
    if (mounted) {
      setState(() {
        _candidates = places;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusLg),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.sm),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.title,
                  style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.separated(
                        controller: scrollController,
                        itemCount: _candidates.length,
                        separatorBuilder: (_, _) => Divider(color: Colors.grey.shade200),
                        itemBuilder: (context, index) {
                          final place = _candidates[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: AppTheme.primary.withValues(alpha: 0.12),
                              child: Icon(place.category.iconData, color: AppTheme.primary, size: 20),
                            ),
                            title: Text(place.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text(
                              '${place.category.displayName} · ${place.typicalDwellMinutes} min visit',
                            ),
                            onTap: () => Navigator.of(context).pop(place),
                          );
                        },
                      ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        );
      },
    );
  }
}
