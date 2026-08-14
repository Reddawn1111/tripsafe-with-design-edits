import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../models/place.dart';
import '../../models/trip_plan.dart';
import '../../services/location_service.dart';
import '../../services/nearby_discovery_service.dart';
import '../../services/trip_planning_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common_widgets.dart';

/// PlanningScreen — Wanderlog & Roadtrippers inspired Budget & Route Planner (Steps 7 & 8)
class PlanningScreen extends StatefulWidget {
  final String destinationId;
  const PlanningScreen({super.key, this.destinationId = ''});

  @override
  State<PlanningScreen> createState() => _PlanningScreenState();
}

class _PlanningScreenState extends State<PlanningScreen> {
  final _planningService = TripPlanningService.instance;
  final _locationService = LocationService();
  final _discoveryService = GeoapifyPlacesNearbyService();
  final _demoDiscoveryService = MockNearbyDiscoveryService();

  // Form State
  late TextEditingController _destinationController;
  int _durationDays = 2;
  double _budgetPerPerson = 2500.0;
  int _groupSize = 3;
  final int _availableHours = 8;
  final Set<String> _selectedInterests = {'Explore', 'Eat', 'Photos'};
  bool _isGenerating = false;

  final List<String> _availableInterests = [
    'Explore',
    'Eat',
    'Relax',
    'Photos',
    'Fun',
    'Shopping',
    'Activities',
  ];

  @override
  void initState() {
    super.initState();
    _destinationController = TextEditingController(
      text: widget.destinationId.isNotEmpty ? widget.destinationId : 'Coastal Trail & City',
    );
  }

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _generateSmartPlan() async {
    setState(() => _isGenerating = true);

    try {
      // 1. Get GPS coordinates
      double lat = 11.2588;
      double lon = 75.7804;
      try {
        final pos = await _locationService.getCurrentPosition();
        lat = pos.latitude;
        lon = pos.longitude;
      } catch (_) {}

      // 2. Fetch nearby places from Geoapify (fallback to demo if key unconfigured)
      List<Place> places = [];
      try {
        places = await _discoveryService.getNearbyPlaces(
          latitude: lat,
          longitude: lon,
          radiusMeters: 8000,
        );
      } catch (_) {
        places = await _demoDiscoveryService.getNearbyPlaces(
          latitude: lat,
          longitude: lon,
          radiusMeters: 8000,
        );
      }

      final prefs = TripPreferences(
        destinationName: _destinationController.text.trim().isNotEmpty
            ? _destinationController.text.trim()
            : 'City & Beach Getaway',
        destinationLat: lat,
        destinationLng: lon,
        durationDays: _durationDays,
        budgetPerPerson: _budgetPerPerson,
        groupSize: _groupSize,
        interests: _selectedInterests.toList(),
        availableHoursPerDay: _availableHours,
      );

      final plan = _planningService.generatePlanFromPlaces(
        preferences: prefs,
        availablePlaces: places,
        userLat: lat,
        userLon: lon,
      );

      setState(() => _isGenerating = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.success,
            content: Text('✨ Generated ${plan.days.length}-Day Plan with ${plan.totalStopsCount} stops!'),
          ),
        );
      }
    } catch (e) {
      setState(() => _isGenerating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.error,
            content: Text('Error generating plan: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeTrip = _planningService.activeTrip;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget & Route Planner'),
        actions: [
          if (activeTrip != null)
            TextButton.icon(
              icon: const Icon(Icons.map, color: Colors.white, size: 18),
              label: const Text('Itinerary', style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.pushNamed(context, AppRoutes.itinerary),
            ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _planningService,
        builder: (context, _) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Preferences Configuration Box
                _buildPreferencesCard(),

                const SizedBox(height: AppSpacing.lg),

                // Generated Trip Plan View
                if (activeTrip != null) ...[
                  _buildBudgetSummaryHeader(activeTrip),
                  const SizedBox(height: AppSpacing.md),
                  _buildDayPlansList(activeTrip),
                  const SizedBox(height: AppSpacing.lg),
                  PrimaryButton(
                    label: 'Start Active Journey',
                    icon: Icons.navigation_outlined,
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.journey),
                  ),
                ],

                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPreferencesCard() {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune, color: AppTheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Trip Parameters & Budget',
                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Destination
          TextField(
            controller: _destinationController,
            decoration: const InputDecoration(
              labelText: 'Destination / Area',
              prefixIcon: Icon(Icons.place_outlined),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Duration & Group Size
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Duration: $_durationDays Days', style: AppTypography.bodySmall),
                    Slider(
                      value: _durationDays.toDouble(),
                      min: 1,
                      max: 5,
                      divisions: 4,
                      label: '$_durationDays Days',
                      onChanged: (val) => setState(() => _durationDays = val.round()),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Group: $_groupSize Friends', style: AppTypography.bodySmall),
                    Slider(
                      value: _groupSize.toDouble(),
                      min: 1,
                      max: 8,
                      divisions: 7,
                      label: '$_groupSize People',
                      onChanged: (val) => setState(() => _groupSize = val.round()),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Budget Per Person
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Budget per person: ₹${_budgetPerPerson.round()}', style: AppTypography.bodySmall),
                  Text(
                    'Total: ₹${(_budgetPerPerson * _groupSize).round()}',
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondary,
                    ),
                  ),
                ],
              ),
              Slider(
                value: _budgetPerPerson,
                min: 500,
                max: 10000,
                divisions: 19,
                label: '₹${_budgetPerPerson.round()}',
                onChanged: (val) => setState(() => _budgetPerPerson = val),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Interests Vibes Chips
          Text('Vibes & Interests', style: AppTypography.bodySmall),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _availableInterests.map((interest) {
              final isSelected = _selectedInterests.contains(interest);
              return FilterChip(
                label: Text(interest),
                selected: isSelected,
                selectedColor: AppTheme.primary.withValues(alpha: 0.2),
                labelStyle: TextStyle(
                  fontSize: 12,
                  color: isSelected ? AppTheme.primary : Colors.grey.shade800,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedInterests.add(interest);
                    } else if (_selectedInterests.length > 1) {
                      _selectedInterests.remove(interest);
                    }
                  });
                },
              );
            }).toList(),
          ),

          const SizedBox(height: AppSpacing.md),

          // Generate Button
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              label: _isGenerating ? 'Generating Itinerary...' : 'Generate Plan & Route',
              icon: Icons.auto_awesome,
              onPressed: _isGenerating ? null : _generateSmartPlan,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetSummaryHeader(TripPlan trip) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Trip Budget Tracker',
                style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: trip.remainingBudget >= 0
                      ? AppTheme.success.withValues(alpha: 0.15)
                      : AppTheme.error.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  trip.remainingBudget >= 0 ? 'Within Budget' : 'Exceeds Budget',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: trip.remainingBudget >= 0 ? AppTheme.success : AppTheme.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBudgetStat('Total Budget', '₹${trip.totalBudget.round()}'),
              _buildBudgetStat('Planned Cost', '₹${trip.totalSpentOrPlanned.round()}'),
              _buildBudgetStat(
                'Remaining',
                '₹${trip.remainingBudget.round()}',
                color: trip.remainingBudget >= 0 ? AppTheme.success : AppTheme.error,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetStat(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.caption.copyWith(color: Colors.grey.shade600)),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: color ?? Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildDayPlansList(TripPlan trip) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: trip.days.length,
      itemBuilder: (context, dIdx) {
        final day = trip.days[dIdx];

        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusMd)),
                ),
                child: Row(
                  children: [
                    Text(
                      day.title,
                      style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.route, size: 20, color: AppTheme.secondary),
                      tooltip: 'Auto-optimize stop order',
                      onPressed: () => _planningService.optimizeDayRoute(dIdx),
                    ),
                  ],
                ),
              ),

              // Stops Sequence
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: day.stops.length,
                onReorder: (oldIdx, newIdx) => _planningService.reorderStops(dIdx, oldIdx, newIdx),
                itemBuilder: (context, sIdx) {
                  final stop = day.stops[sIdx];
                  final isFirst = sIdx == 0;

                  return Container(
                    key: ValueKey(stop.id),
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Transit Indicator from previous stop
                        if (!isFirst)
                          Padding(
                            padding: const EdgeInsets.only(left: 12, bottom: 6),
                            child: Row(
                              children: [
                                const Icon(Icons.arrow_downward, size: 14, color: Colors.grey),
                                const SizedBox(width: 6),
                                Text(
                                  '🚗 ${stop.distanceFromPreviousKm.toStringAsFixed(1)} km · ~${stop.travelTimeFromPreviousMinutes} min transit',
                                  style: AppTypography.caption.copyWith(
                                    color: Colors.grey.shade600,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Stop Card
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: AppTheme.primary.withValues(alpha: 0.12),
                              child: Text(
                                '${sIdx + 1}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    stop.place.name,
                                    style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${stop.startTime} – ${stop.endTime} · (${stop.estimatedDurationMinutes}m stay)',
                                    style: AppTypography.caption.copyWith(color: Colors.grey.shade700),
                                  ),
                                  if (stop.optimizationHint != null)
                                    Text(
                                      stop.optimizationHint!,
                                      style: AppTypography.caption.copyWith(
                                        color: Colors.orange.shade800,
                                        fontSize: 11,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Text(
                              stop.estimatedCost > 0 ? '₹${stop.estimatedCost.round()}' : 'Free',
                              style: AppTypography.caption.copyWith(
                                fontWeight: FontWeight.bold,
                                color: stop.estimatedCost > 0 ? AppTheme.primary : AppTheme.success,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                              onPressed: () => _planningService.removeStop(dIdx, stop.id),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
