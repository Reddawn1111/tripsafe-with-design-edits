import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../models/safety_risk.dart';
import '../../models/trip_plan.dart';
import '../../services/location_service.dart';
import '../../services/safety_service.dart';
import '../../services/trip_planning_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/common_widgets.dart';

/// HomeScreen — Functional, modern travel hub (Step 20)
/// Immediate actions, compact location pill, active trip overview, and mobility hubs.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocationService _locationService = LocationService();
  final TripPlanningService _planningService = TripPlanningService.instance;
  final SafetyService _safetyService = SafetyService.instance;

  LocationAddress? _address;
  bool _isLoadingLocation = false;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });

    try {
      final address = await _locationService.getCurrentLocationAddress();
      if (mounted) {
        setState(() {
          _address = address;
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationError = e.toString().replaceFirst('Exception: ', '');
          _isLoadingLocation = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeTrip = _planningService.activeTrip;
    final safetyEval = _safetyService.evaluateSafety(
      activeTrip?.destinationName ?? _address?.areaLabel ?? 'Local Area',
    );

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Top App Bar with brand and location pill
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    // Brand
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppTheme.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.shield_outlined,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'TRIPSAFE',
                              style: AppTypography.titleLarge.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Consent-Based Mobility & Travel Intelligence',
                          style: AppTypography.caption.copyWith(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Privacy & Settings shortcut
                    IconButton(
                      icon: const Icon(Icons.privacy_tip_outlined),
                      tooltip: 'Privacy & Consent Controls',
                      onPressed: () => Navigator.pushNamed(context, '/privacy'),
                    ),
                  ],
                ),
              ),
            ),

            // Location Bar Pill
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: _buildLocationPill(),
              ),
            ),

            // Main Action Cards: "What's the plan today?"
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "What's the plan today?",
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _buildPrimaryActionCards(context),
                  ],
                ),
              ),
            ),

            // Active Trip & Budget Snapshot
            if (activeTrip != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Active Trip',
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              AppRoutes.itinerary,
                              arguments: {RouteArgs.tripId: activeTrip.id},
                            ),
                            child: const Text('View Plan'),
                          ),
                        ],
                      ),
                      _buildActiveTripCard(context, activeTrip),
                    ],
                  ),
                ),
              ),

            // Safety Radar Ticker
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: _buildSafetyTicker(context, safetyEval),
              ),
            ),

            // Quick Hub: Multi-feature Modules
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Explore TRIPSAFE Intelligence',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _buildHubGrid(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.near_me, color: AppTheme.primary, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: _isLoadingLocation
                ? const Text(
                    'Detecting GPS location...',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  )
                : _locationError != null
                    ? Text(
                        'Location unavailable · Tap to retry',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      )
                    : Text(
                        '📍 ${_address?.areaLabel ?? 'Current Area'} · ${_address?.shortLine ?? 'Ready'}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
          ),
          InkWell(
            onTap: _fetchCurrentLocation,
            child: const Icon(Icons.refresh, size: 16, color: AppTheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryActionCards(BuildContext context) {
    return Column(
      children: [
        // 1. Explore Nearby
        _ActionCard(
          title: 'Explore Nearby',
          subtitle: 'Discover real attractions, scenic viewpoints, dining & vibes',
          icon: Icons.travel_explore,
          accentColor: AppTheme.primary,
          badgeText: 'Live Geoapify',
          onTap: () => Navigator.pushNamed(context, AppRoutes.discover),
        ),
        const SizedBox(height: AppSpacing.sm),
        // 2. Budget & Route Planner
        _ActionCard(
          title: 'Plan a Trip & Budget',
          subtitle: 'Generate sequenced itinerary with travel times & cost tracking',
          icon: Icons.route,
          accentColor: AppTheme.secondary,
          badgeText: 'Smart Sequence',
          onTap: () => Navigator.pushNamed(context, AppRoutes.plan),
        ),
        const SizedBox(height: AppSpacing.sm),
        // 3. Live Journey Tracker
        _ActionCard(
          title: 'Active Journey & Dwell Tracker',
          subtitle: 'Track route progress, verify stops & log consented travel visits',
          icon: Icons.navigation_outlined,
          accentColor: const Color(0xFFE65100),
          badgeText: 'Live Tracking',
          onTap: () => Navigator.pushNamed(context, AppRoutes.journey),
        ),
      ],
    );
  }

  Widget _buildActiveTripCard(BuildContext context, TripPlan trip) {
    final firstDay = trip.days.isNotEmpty ? trip.days.first : null;
    final nextStop = firstDay != null && firstDay.stops.isNotEmpty
        ? firstDay.stops.firstWhere((s) => !s.isVisited, orElse: () => firstDay.stops.first)
        : null;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.itinerary,
        arguments: {RouteArgs.tripId: trip.id},
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.primary.withValues(alpha: 0.12),
                child: const Icon(Icons.luggage, color: AppTheme.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.title,
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${trip.days.length} Day Plan · ${trip.members.length} Travellers',
                      style: AppTypography.caption.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Code: ${trip.inviteCode}',
                  style: AppTypography.caption.copyWith(
                    color: AppTheme.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Budget Health Meter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Budget: ₹${trip.totalBudget.round()}',
                style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                'Planned: ₹${trip.totalSpentOrPlanned.round()} · Left: ₹${trip.remainingBudget.round()}',
                style: AppTypography.caption.copyWith(
                  color: trip.remainingBudget >= 0 ? AppTheme.success : AppTheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (trip.totalSpentOrPlanned / (trip.totalBudget > 0 ? trip.totalBudget : 1.0)).clamp(0.0, 1.0),
              backgroundColor: Colors.grey.shade200,
              color: trip.remainingBudget >= 0 ? AppTheme.secondary : AppTheme.error,
              minHeight: 6,
            ),
          ),

          if (nextStop != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Divider(color: Colors.grey.shade200),
            Row(
              children: [
                const Icon(Icons.pin_drop, size: 16, color: AppTheme.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Next Stop: ${nextStop.place.name} (${nextStop.startTime})',
                    style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${nextStop.estimatedDurationMinutes} min',
                  style: AppTypography.caption.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSafetyTicker(BuildContext context, SafetyEvaluation eval) {
    final hasAlert = eval.activeAlerts.isNotEmpty;
    return InkWell(
      onTap: () => Navigator.pushNamed(context, AppRoutes.safety),
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: hasAlert
              ? AppTheme.warning.withValues(alpha: 0.12)
              : AppTheme.success.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: hasAlert
                ? AppTheme.warning.withValues(alpha: 0.4)
                : AppTheme.success.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              hasAlert ? Icons.warning_amber_rounded : Icons.verified_user_outlined,
              color: hasAlert ? AppTheme.warning : AppTheme.success,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasAlert ? 'Safety Advisory: ${eval.activeAlerts.first.title}' : 'Safety Radar: All Clear',
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: hasAlert ? Colors.amber.shade900 : Colors.green.shade800,
                    ),
                  ),
                  Text(
                    hasAlert
                        ? eval.activeAlerts.first.description
                        : 'Weather & road conditions favorable. Good travel window.',
                    style: AppTypography.caption.copyWith(
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildHubGrid(BuildContext context) {
    final hubs = [
      _HubTile(
        title: 'Safety Radar',
        subtitle: 'Advisories & safe alternatives',
        icon: Icons.shield_outlined,
        color: AppTheme.warning,
        onTap: () => Navigator.pushNamed(context, AppRoutes.safety),
      ),
      _HubTile(
        title: 'Group & Split',
        subtitle: 'Shared expenses & settlement',
        icon: Icons.group_outlined,
        color: Colors.teal,
        onTap: () => Navigator.pushNamed(context, AppRoutes.expenses),
      ),
      _HubTile(
        title: 'Trip Timeline',
        subtitle: 'Logged stops & memories',
        icon: Icons.timeline,
        color: Colors.purple,
        onTap: () => Navigator.pushNamed(context, AppRoutes.timeline),
      ),
      _HubTile(
        title: 'Authority Insights',
        subtitle: 'Mobility & pressure portal',
        icon: Icons.analytics_outlined,
        color: AppTheme.primary,
        onTap: () => Navigator.pushNamed(context, '/authority'),
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.sm,
      childAspectRatio: 1.5,
      children: hubs.map((h) => _buildHubCard(h)).toList(),
    );
  }

  Widget _buildHubCard(_HubTile tile) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      onTap: tile.onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(tile.icon, color: tile.color, size: 22),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            tile.title,
            style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            tile.subtitle,
            style: AppTypography.caption.copyWith(color: Colors.grey, fontSize: 10),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final String badgeText;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.badgeText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accentColor, size: 28),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: accentColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTypography.caption.copyWith(color: Colors.grey.shade600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HubTile {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _HubTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
