import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../models/place.dart';
import '../../models/trip_plan.dart';
import '../../services/location_service.dart';
import '../../services/nearby_discovery_service.dart';
import '../../services/trip_planning_service.dart';
import '../../repositories/local_demo_travel_repository.dart';
import '../../utils/app_theme.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common_widgets.dart';

/// PlanningScreen — Budget & Route Planner, dark "accent panel" theme.
/// Layout order unchanged: preferences panel, budget summary, day plans,
/// start-journey action.
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
      text: widget.destinationId.isNotEmpty
          ? widget.destinationId
          : 'Coastal Trail & City',
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

      // Backend-ready repository round-trip (Stage 1: local/demo repository).
      await LocalDemoTravelRepository().saveTrip(plan);

      setState(() => _isGenerating = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Generated ${plan.days.length}-day plan with ${plan.totalStopsCount} stops',
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isGenerating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating plan: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeTrip = _planningService.activeTrip;

    return Scaffold(
      appBar: TripSafeAppBar(
        title: 'Plan & budget',
        actions: [
          if (activeTrip != null)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: Center(
                child: GestureDetector(
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.itinerary),
                  child: Text(
                    'Itinerary',
                    style: AppTypography.chipLabel.copyWith(
                      color: AppTheme.secondary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _planningService,
        builder: (context, _) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.xxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPreferencesPanel(),
                if (activeTrip != null) ...[
                  const SizedBox(height: 20),
                  _buildBudgetSummary(activeTrip),
                  const SizedBox(height: 20),
                  const SectionLabel('Day plans'),
                  const SizedBox(height: 11),
                  _buildDayPlansList(activeTrip),
                  const SizedBox(height: 8),
                  PrimaryButton(
                    label: 'Start active journey',
                    icon: Icons.navigation_outlined,
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.journey),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Preferences — the saffron accent panel ─────────────────────────────
  Widget _buildPreferencesPanel() {
    const ink = AppTheme.onSecondary;

    return AccentPanel(
      color: AppTheme.secondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TRIP PREFERENCES',
            style: AppTypography.sectionLabel.copyWith(
              fontSize: 10.5,
              letterSpacing: 1.8,
              color: ink.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 18),

          _panelLabel('Destination / area'),
          const SizedBox(height: 7),
          TextField(
            controller: _destinationController,
            style: AppTypography.titleSmall.copyWith(color: ink),
            cursorColor: ink,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFFFFDF6),
              hintText: 'Where to?',
              hintStyle: AppTypography.bodyMedium.copyWith(
                color: ink.withValues(alpha: 0.45),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: _panelFieldBorder,
              enabledBorder: _panelFieldBorder,
              focusedBorder: _panelFieldBorder,
            ),
          ),
          const SizedBox(height: 18),

          _panelSlider(
            label: 'Duration',
            value: '$_durationDays days',
            slider: Slider(
              value: _durationDays.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              label: '$_durationDays Days',
              onChanged: (val) => setState(() => _durationDays = val.round()),
            ),
          ),
          _panelSlider(
            label: 'Group size',
            value: '$_groupSize people',
            slider: Slider(
              value: _groupSize.toDouble(),
              min: 1,
              max: 8,
              divisions: 7,
              label: '$_groupSize People',
              onChanged: (val) => setState(() => _groupSize = val.round()),
            ),
          ),
          _panelSlider(
            label: 'Budget per person',
            value: '₹${_budgetPerPerson.round()}',
            hint: 'Total ₹${(_budgetPerPerson * _groupSize).round()}',
            slider: Slider(
              value: _budgetPerPerson,
              min: 500,
              max: 10000,
              divisions: 19,
              label: '₹${_budgetPerPerson.round()}',
              onChanged: (val) => setState(() => _budgetPerPerson = val),
            ),
          ),

          const SizedBox(height: 8),
          _panelLabel('Vibes & interests'),
          const SizedBox(height: 9),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: _availableInterests.map((interest) {
              final isSelected = _selectedInterests.contains(interest);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (!isSelected) {
                      _selectedInterests.add(interest);
                    } else if (_selectedInterests.length > 1) {
                      _selectedInterests.remove(interest);
                    }
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSelected ? ink : Colors.transparent,
                    borderRadius: AppSpacing.pill,
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : ink.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    interest,
                    style: AppTypography.chipLabel.copyWith(
                      color: isSelected ? AppTheme.secondary : ink,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isGenerating ? null : _generateSmartPlan,
              style: ElevatedButton.styleFrom(
                backgroundColor: ink,
                foregroundColor: AppTheme.secondary,
                disabledBackgroundColor: ink.withValues(alpha: 0.4),
                disabledForegroundColor:
                    AppTheme.secondary.withValues(alpha: 0.6),
              ),
              child: _isGenerating
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: AppTheme.secondary,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_awesome, size: 17),
                        const SizedBox(width: AppSpacing.sm),
                        Text('Generate plan'),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  static final OutlineInputBorder _panelFieldBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide.none,
  );

  Widget _panelLabel(String text) => Text(
        text.toUpperCase(),
        style: AppTypography.sectionLabel.copyWith(
          fontSize: 10.5,
          letterSpacing: 1.2,
          color: AppTheme.onSecondary.withValues(alpha: 0.65),
        ),
      );

  Widget _panelSlider({
    required String label,
    required String value,
    required Widget slider,
    String? hint,
  }) {
    const ink = AppTheme.onSecondary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.chipLabel
                      .copyWith(color: ink, fontSize: 12.5),
                ),
              ),
              if (hint != null) ...[
                Text(
                  hint,
                  style: AppTypography.caption
                      .copyWith(color: ink.withValues(alpha: 0.7)),
                ),
                const SizedBox(width: 10),
              ],
              Text(
                value,
                style: AppTypography.titleMedium.copyWith(color: ink),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: ink,
              inactiveTrackColor: ink.withValues(alpha: 0.2),
              thumbColor: ink,
              overlayColor: ink.withValues(alpha: 0.12),
              valueIndicatorColor: ink,
              valueIndicatorTextStyle:
                  AppTypography.chipLabel.copyWith(color: AppTheme.secondary),
              trackHeight: 6,
            ),
            child: slider,
          ),
        ],
      ),
    );
  }

  // ── Budget summary ─────────────────────────────────────────────────────
  Widget _buildBudgetSummary(TripPlan trip) {
    final within = trip.remainingBudget >= 0;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  trip.title.toUpperCase(),
                  style: AppTypography.titleLarge.copyWith(height: 1.1),
                ),
              ),
              const SizedBox(width: 10),
              StatusPill(
                label: within ? 'Within budget' : 'Over budget',
                color: within ? AppTheme.success : AppTheme.danger,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: StatBlock(
                  label: 'Total budget',
                  value: '₹${trip.totalBudget.round()}',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatBlock(
                  label: 'Planned',
                  value: '₹${trip.totalSpentOrPlanned.round()}',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatBlock(
                  label: 'Remaining',
                  value: '₹${trip.remainingBudget.round()}',
                  color: within ? AppTheme.success : AppTheme.danger,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          AppProgressBar(
            value: trip.totalBudget > 0
                ? trip.totalSpentOrPlanned / trip.totalBudget
                : 0,
            color: within ? AppTheme.secondary : AppTheme.danger,
          ),
        ],
      ),
    );
  }

  // ── Day plans ──────────────────────────────────────────────────────────
  Widget _buildDayPlansList(TripPlan trip) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: trip.days.length,
      itemBuilder: (context, dIdx) {
        final day = trip.days[dIdx];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AppCard(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${dIdx + 1}',
                        style: AppTypography.chipLabel.copyWith(
                          color: AppTheme.onPrimary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Text(
                        day.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.titleSmall,
                      ),
                    ),
                    const SizedBox(width: 8),
                    PillButton(
                      label: 'Optimize',
                      icon: Icons.route,
                      dense: true,
                      color: AppTheme.secondary,
                      onPressed: () => _planningService.optimizeDayRoute(dIdx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  buildDefaultDragHandles: true,
                  itemCount: day.stops.length,
                  onReorder: (oldIdx, newIdx) =>
                      _planningService.reorderStops(dIdx, oldIdx, newIdx),
                  itemBuilder: (context, sIdx) {
                    final stop = day.stops[sIdx];
                    final isFirst = sIdx == 0;

                    return Padding(
                      key: ValueKey(stop.id),
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isFirst)
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 6, bottom: 8),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.arrow_downward,
                                    size: 13,
                                    color: AppTheme.muted(context),
                                  ),
                                  const SizedBox(width: 7),
                                  Expanded(
                                    child: Text(
                                      '${stop.distanceFromPreviousKm.toStringAsFixed(1)} km · ~${stop.travelTimeFromPreviousMinutes} min transit',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTypography.caption.copyWith(
                                        fontSize: 11,
                                        color: AppTheme.muted(context),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppTheme.tint(AppTheme.primary, 0.14),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${sIdx + 1}',
                                  style: AppTypography.chipLabel.copyWith(
                                    color: AppTheme.primary,
                                    fontSize: 11.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      stop.place.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTypography.titleSmall
                                          .copyWith(fontSize: 13.5),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${stop.startTime} – ${stop.endTime} · ${stop.estimatedDurationMinutes}m',
                                      style: AppTypography.caption.copyWith(
                                        color: AppTheme.muted(context),
                                      ),
                                    ),
                                    if (stop.optimizationHint != null)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 2),
                                        child: Text(
                                          stop.optimizationHint!,
                                          style:
                                              AppTypography.caption.copyWith(
                                            fontSize: 11,
                                            color: AppTheme.warning,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                stop.estimatedCost > 0
                                    ? '₹${stop.estimatedCost.round()}'
                                    : 'Free',
                                style: AppTypography.chipLabel.copyWith(
                                  fontSize: 11.5,
                                  color: stop.estimatedCost > 0
                                      ? AppTheme.onDark
                                      : AppTheme.success,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 17),
                                color: AppTheme.muted(context),
                                visualDensity: VisualDensity.compact,
                                onPressed: () =>
                                    _planningService.removeStop(dIdx, stop.id),
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
          ),
        );
      },
    );
  }
}
