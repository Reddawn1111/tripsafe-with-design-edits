import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../models/safety_risk.dart';
import '../../models/trip_plan.dart';
import '../../services/location_service.dart';
import '../../services/safety_service.dart';
import '../../services/trip_planning_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/floating_nav_bar.dart';
import '../../widgets/buttons.dart';
import '../../widgets/common_widgets.dart';

/// HomeScreen — travel hub, dark "accent panel" theme (design 1a).
/// Layout order is unchanged: brand row, location pill, primary actions,
/// active trip, safety ticker, city-pulse link, intelligence hub grid.
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
      extendBody: true,
      bottomNavigationBar: const FloatingNavBar(current: NavDestination.home),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildBrandRow(context)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  0,
                ),
                child: _buildLocationPill(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  22,
                  AppSpacing.md,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionLabel("What's the plan today?"),
                    const SizedBox(height: 12),
                    _buildPrimaryActions(context),
                  ],
                ),
              ),
            ),
            if (activeTrip != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    24,
                    AppSpacing.md,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionLabel(
                        'Active trip',
                        trailing: GestureDetector(
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.itinerary,
                            arguments: {RouteArgs.tripId: activeTrip.id},
                          ),
                          child: Text(
                            'View plan',
                            style: AppTypography.chipLabel.copyWith(
                              color: AppTheme.primary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 11),
                      _buildActiveTripCard(context, activeTrip),
                    ],
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  22,
                  AppSpacing.md,
                  0,
                ),
                child: _buildSafetyTicker(context, safetyEval),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  14,
                  AppSpacing.md,
                  0,
                ),
                child: _buildCityPulseTeaser(context),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  24,
                  AppSpacing.md,
                  104,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionLabel('TripSafe intelligence'),
                    const SizedBox(height: 11),
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

  // ── Brand row ──────────────────────────────────────────────────────────
  Widget _buildBrandRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: AppTheme.onPrimary,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TRIPSAFE', style: AppTypography.screenTitle),
                const SizedBox(height: 2),
                Text(
                  'Consent-Based Mobility & Travel Intelligence',
                  style: AppTypography.caption.copyWith(
                    fontSize: 10.5,
                    color: AppTheme.muted(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          CircleIconButton(
            icon: Icons.privacy_tip_outlined,
            tooltip: 'Privacy & Consent Controls',
            onPressed: () => Navigator.pushNamed(context, '/privacy'),
          ),
        ],
      ),
    );
  }

  // ── Location pill — solid off-white bar ────────────────────────────────
  Widget _buildLocationPill() {
    final label = _isLoadingLocation
        ? 'Detecting GPS location…'
        : _locationError != null
            ? 'Location unavailable · tap to retry'
            : '${_address?.areaLabel ?? 'Current Area'} · ${_address?.shortLine ?? 'Ready'}';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      decoration: const BoxDecoration(
        color: AppTheme.onDark,
        borderRadius: AppSpacing.pill,
      ),
      child: Row(
        children: [
          const Icon(Icons.near_me, color: AppTheme.surfaceDark, size: 15),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.chipLabel.copyWith(
                color: AppTheme.surfaceDark,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleIconButton(
            icon: Icons.refresh,
            size: 28,
            background: AppTheme.surfaceDark,
            foreground: AppTheme.onDark,
            onPressed: _fetchCurrentLocation,
          ),
        ],
      ),
    );
  }

  // ── Primary actions: one accent panel + two quiet rows ─────────────────
  Widget _buildPrimaryActions(BuildContext context) {
    return Column(
      children: [
        AccentPanel(
          color: AppTheme.primary,
          onTap: () => Navigator.pushNamed(context, AppRoutes.discover),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      'EXPLORE\nNEARBY',
                      style: AppTypography.displayMedium.copyWith(
                        color: AppTheme.onPrimary,
                        height: 1.02,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  CircleIconButton(
                    icon: Icons.arrow_outward,
                    size: 34,
                    background: AppTheme.onPrimary,
                    foreground: AppTheme.primary,
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.discover),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Real attractions, scenic viewpoints, dining & vibes around you.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppTheme.onPrimary.withValues(alpha: 0.78),
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                    decoration: const BoxDecoration(
                      color: AppTheme.onDark,
                      borderRadius: AppSpacing.pill,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppTheme.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'LIVE GEOAPIFY',
                          style: AppTypography.chipLabel.copyWith(
                            color: AppTheme.surfaceDark,
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _ActionRow(
          title: 'Plan a Trip & Budget',
          subtitle: 'Sequenced itinerary with travel times & cost tracking',
          icon: Icons.route,
          accentColor: AppTheme.secondary,
          badgeText: 'Smart',
          onTap: () => Navigator.pushNamed(context, AppRoutes.plan),
        ),
        const SizedBox(height: 12),
        _ActionRow(
          title: 'Active Journey & Dwell Tracker',
          subtitle: 'Route progress, stop verification & dwell logging',
          icon: Icons.navigation_outlined,
          accentColor: AppTheme.info,
          badgeText: 'Live',
          badgeColor: AppTheme.success,
          badgeDot: true,
          onTap: () => Navigator.pushNamed(context, AppRoutes.journey),
        ),
      ],
    );
  }

  // ── Active trip ────────────────────────────────────────────────────────
  Widget _buildActiveTripCard(BuildContext context, TripPlan trip) {
    final firstDay = trip.days.isNotEmpty ? trip.days.first : null;
    final nextStop = firstDay != null && firstDay.stops.isNotEmpty
        ? firstDay.stops.firstWhere(
            (s) => !s.isVisited,
            orElse: () => firstDay.stops.first,
          )
        : null;
    final withinBudget = trip.remainingBudget >= 0;

    return AppCard(
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
              const IconChip(icon: Icons.luggage, size: 36),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${trip.days.length} day plan · ${trip.members.length} travellers',
                      style: AppTypography.caption.copyWith(
                        color: AppTheme.muted(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusPill(label: trip.inviteCode, color: AppTheme.success),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  'Budget ₹${trip.totalBudget.round()}',
                  style: AppTypography.chipLabel.copyWith(fontSize: 12.5),
                ),
              ),
              Text(
                withinBudget
                    ? 'Left ₹${trip.remainingBudget.round()}'
                    : 'Over ₹${trip.remainingBudget.abs().round()}',
                style: AppTypography.chipLabel.copyWith(
                  color: withinBudget ? AppTheme.success : AppTheme.danger,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          AppProgressBar(
            value: trip.totalBudget > 0
                ? trip.totalSpentOrPlanned / trip.totalBudget
                : 0,
            color: withinBudget ? AppTheme.secondary : AppTheme.danger,
          ),
          if (nextStop != null) ...[
            const SizedBox(height: 14),
            const Divider(height: 1, color: AppTheme.borderDark),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.pin_drop, size: 14, color: AppTheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Next: ${nextStop.place.name} · ${nextStop.startTime}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.chipLabel.copyWith(fontSize: 11.5),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${nextStop.estimatedDurationMinutes} min',
                  style: AppTypography.caption.copyWith(
                    color: AppTheme.muted(context),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ── Safety ticker ──────────────────────────────────────────────────────
  Widget _buildSafetyTicker(BuildContext context, SafetyEvaluation eval) {
    final hasAlert = eval.activeAlerts.isNotEmpty;
    final accent = hasAlert ? AppTheme.warning : AppTheme.success;

    return AppCard(
      accentBorder: accent,
      background: AppTheme.tint(accent, 0.10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      onTap: () => Navigator.pushNamed(context, AppRoutes.safety),
      child: Row(
        children: [
          Icon(
            hasAlert ? Icons.warning_amber_rounded : Icons.verified_user_outlined,
            color: accent,
            size: 20,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasAlert
                      ? 'Safety advisory: ${eval.activeAlerts.first.title}'
                      : 'Safety Radar: all clear',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.chipLabel.copyWith(
                    color: accent,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hasAlert
                      ? eval.activeAlerts.first.description
                      : 'Weather & road conditions favorable',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(
                    color: AppTheme.muted(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Icon(Icons.chevron_right, size: 16, color: AppTheme.muted(context)),
        ],
      ),
    );
  }

  Widget _buildCityPulseTeaser(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, AppRoutes.discover),
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            const Icon(Icons.bolt, size: 15, color: AppTheme.secondary),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                "See what's trending nearby",
                style: AppTypography.chipLabel.copyWith(fontSize: 12.5),
              ),
            ),
            Icon(Icons.chevron_right, size: 15, color: AppTheme.muted(context)),
          ],
        ),
      ),
    );
  }

  // ── Intelligence hub grid ──────────────────────────────────────────────
  Widget _buildHubGrid(BuildContext context) {
    final hubs = [
      _HubTile(
        title: 'Safety Radar',
        subtitle: 'Advisories & alternatives',
        icon: Icons.shield_outlined,
        color: AppTheme.secondary,
        onTap: () => Navigator.pushNamed(context, AppRoutes.safety),
      ),
      _HubTile(
        title: 'Trip Group',
        subtitle: 'Members & invite code',
        icon: Icons.group_outlined,
        color: const Color(0xFF00BFA6),
        onTap: () => Navigator.pushNamed(context, AppRoutes.group),
      ),
      _HubTile(
        title: 'Trip Timeline',
        subtitle: 'Logged stops & memories',
        icon: Icons.timeline,
        color: const Color(0xFFA78BFA),
        onTap: () => Navigator.pushNamed(context, AppRoutes.timeline),
      ),
      _HubTile(
        title: 'Authority',
        subtitle: 'Mobility pressure portal',
        icon: Icons.analytics_outlined,
        color: AppTheme.info,
        onTap: () => Navigator.pushNamed(context, '/authority'),
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.55,
      children: hubs
          .map(
            (h) => AppCard(
              padding: const EdgeInsets.all(13),
              onTap: h.onTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(h.icon, color: h.color, size: 18),
                      const Spacer(),
                      Icon(
                        Icons.chevron_right,
                        size: 14,
                        color: AppTheme.muted(context),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    h.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.titleSmall.copyWith(fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    h.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption.copyWith(
                      fontSize: 10,
                      color: AppTheme.muted(context),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

/// Quiet secondary action row — icon chip, title + badge, one line of detail.
class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.badgeText,
    required this.onTap,
    this.badgeColor,
    this.badgeDot = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final String badgeText;
  final VoidCallback onTap;
  final Color? badgeColor;
  final bool badgeDot;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Row(
        children: [
          IconChip(icon: icon, color: accentColor),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Wrap, not Row: long titles push the badge to the next line
                // instead of overflowing.
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    Text(title, style: AppTypography.titleSmall),
                    StatusPill(
                      label: badgeText,
                      color: badgeColor ?? accentColor,
                      dot: badgeDot,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(
                    fontSize: 11.5,
                    color: AppTheme.muted(context),
                  ),
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
