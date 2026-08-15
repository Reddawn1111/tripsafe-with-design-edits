import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../app/routes.dart';
import '../../models/place.dart';
import '../../models/place_category.dart';
import '../../services/itinerary_service.dart';
import '../../services/location_service.dart';
import '../../services/nearby_discovery_service.dart';
import '../../services/recommendation_service.dart';
import '../../services/travel_insights_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/floating_nav_bar.dart';
import '../../widgets/buttons.dart';
import '../../widgets/city_pulse_card.dart';
import '../../widgets/common_widgets.dart';
import 'place_detail_sheet.dart';

/// "Explore Around Me" — Mobile-first travel discovery screen (Steps 2, 3, 4, 5, 6).
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final LocationService _locationService = LocationService();
  final NearbyDiscoveryService _liveDiscoveryService = GeoapifyPlacesNearbyService();
  final NearbyDiscoveryService _demoDiscoveryService = MockNearbyDiscoveryService();
  final RecommendationService _recommendationService = RecommendationService();
  final TravelInsightsService _insightsService = TravelInsightsService();

  LocationAddress? _currentAddress;
  Position? _currentPosition;
  List<Place> _allNearbyPlaces = [];
  List<Place> _rankedPlaces = [];

  UserIntent _selectedIntent = UserIntent.all;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isApiNotConfigured = false;
  bool _isDemoMode = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadLocationAndPlaces();
  }

  Future<void> _loadLocationAndPlaces() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isApiNotConfigured = false;
    });

    try {
      // 1. Obtain GPS position via existing LocationService
      Position? position;
      try {
        position = await _locationService.getCurrentPosition();
        _currentPosition = position;
      } catch (gpsError) {
        // Fallback default coordinates if GPS unavailable (e.g. Bangalore / Kozhikode for demo)
        _currentPosition = Position(
          longitude: 77.5946,
          latitude: 12.9716,
          timestamp: DateTime.now(),
          accuracy: 10,
          altitude: 900,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
        position = _currentPosition;
      }

      // 2. Reverse-geocode for location label
      try {
        final address = await _locationService.getAddressForCoordinates(
          position!.latitude,
          position.longitude,
        );
        _currentAddress = address;
      } catch (_) {}

      // 3. Select active service provider (Live vs Demo Mode)
      List<Place> rawPlaces = [];
      if (_isDemoMode) {
        rawPlaces = await _demoDiscoveryService.getNearbyPlaces(
          latitude: position!.latitude,
          longitude: position.longitude,
          radiusMeters: 5000,
        );
      } else {
        rawPlaces = await _liveDiscoveryService.getNearbyPlaces(
          latitude: position!.latitude,
          longitude: position.longitude,
          radiusMeters: 5000,
        );
      }

      _allNearbyPlaces = rawPlaces;
      _applyRecommendationFilter();
    } on PlacesApiException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (e.code == 'API_NOT_CONFIGURED') {
            _isApiNotConfigured = true;
          } else {
            _errorMessage = e.message;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  void _applyRecommendationFilter() {
    if (_currentPosition == null) {
      setState(() => _isLoading = false);
      return;
    }

    var placesToFilter = List<Place>.from(_allNearbyPlaces);

    // Apply text search if query typed
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      placesToFilter = placesToFilter
          .where((p) =>
              p.name.toLowerCase().contains(q) ||
              p.category.displayName.toLowerCase().contains(q) ||
              p.types.any((t) => t.toLowerCase().contains(q)))
          .toList();
    }

    final ranked = _recommendationService.rankPlaces(
      places: placesToFilter,
      userLatitude: _currentPosition!.latitude,
      userLongitude: _currentPosition!.longitude,
      selectedIntent: _selectedIntent,
      searchRadiusKm: 6.0,
    );

    setState(() {
      _rankedPlaces = ranked;
      _isLoading = false;
    });
  }

  void _onIntentChanged(UserIntent intent) {
    if (_selectedIntent == intent) return;
    setState(() {
      _selectedIntent = intent;
    });
    _applyRecommendationFilter();
  }

  void _toggleDemoMode(bool enabled) {
    setState(() {
      _isDemoMode = enabled;
    });
    _loadLocationAndPlaces();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Segment places for specialized discovery sections
    final popularWithTravellers = _rankedPlaces
        .where((p) => p.visitCount > 0 || p.reviewCount > 500)
        .take(5)
        .toList();

    final bestTimePlaces = _rankedPlaces
        .where((p) =>
            p.category == PlaceCategory.viewpoint ||
            p.category == PlaceCategory.beach ||
            p.category == PlaceCategory.nature ||
            p.bestVisitWindow != null)
        .take(4)
        .toList();

    return Scaffold(
      extendBody: true,
      bottomNavigationBar: const FloatingNavBar(current: NavDestination.explore),
      appBar: AppBar(
        titleSpacing: AppSpacing.md,
        toolbarHeight: 76,
        backgroundColor: AppTheme.secondary,
        foregroundColor: AppTheme.onSecondary,
        iconTheme: const IconThemeData(color: AppTheme.onSecondary),
        actionsIconTheme: const IconThemeData(color: AppTheme.onSecondary),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'EXPLORE',
              style: AppTypography.displayMedium.copyWith(
                color: AppTheme.onSecondary,
                fontSize: 26,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 12,
                  color: AppTheme.onSecondary.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    _currentAddress?.areaLabel ?? 'Current GPS Area',
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.chipLabel.copyWith(
                      fontSize: 11.5,
                      color: AppTheme.onSecondary.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _loadLocationAndPlaces,
            tooltip: 'Refresh GPS places',
          ),
          IconButton(
            icon: Icon(
              _isDemoMode ? Icons.science : Icons.science_outlined,
              color: _isDemoMode ? AppTheme.secondary : null,
            ),
            onPressed: () => _toggleDemoMode(!_isDemoMode),
            tooltip: _isDemoMode ? 'Exit Demo Mode' : 'Toggle Demo Mode',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadLocationAndPlaces,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // Demo Mode Banner
            if (_isDemoMode)
              SliverToBoxAdapter(
                child: Container(
                  color: AppTheme.secondary,
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppTheme.onSecondary, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'DEMO DATA — simulated consenting travellers',
                          style: AppTypography.chipLabel.copyWith(
                            color: AppTheme.onSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => _toggleDemoMode(false),
                        child: Text(
                          'Exit Demo',
                          style: AppTypography.chipLabel.copyWith(
                            color: AppTheme.onSecondary,
                            fontSize: 11,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Search Bar & Vibe Title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.xs,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search box
                    TextField(
                      onChanged: (val) {
                        _searchQuery = val;
                        _applyRecommendationFilter();
                      },
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppTheme.onDark,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Search places, cafes, sunsets…',
                        prefixIcon: Icon(Icons.search, size: 19),
                        filled: true,
                        fillColor: AppTheme.cardDark,
                        contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: AppSpacing.pill,
                          borderSide: BorderSide(color: AppTheme.borderDark),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: AppSpacing.pill,
                          borderSide: BorderSide(color: AppTheme.borderDark),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: AppSpacing.pill,
                          borderSide: BorderSide(color: AppTheme.secondary, width: 1.6),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      "WHAT'S YOUR VIBE?",
                      style: AppTypography.sectionLabel.copyWith(
                        color: AppTheme.mutedDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Vibe Chips Filter Bar
            SliverToBoxAdapter(
              child: _buildVibeChipsBar(),
            ),

            // Main Content States
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: AppSpacing.md),
                      Text('Discovering real nearby places...'),
                    ],
                  ),
                ),
              )
            else if (_isApiNotConfigured)
              SliverFillRemaining(
                child: _buildUnconfiguredState(),
              )
            else if (_errorMessage != null)
              SliverFillRemaining(
                child: _buildErrorState(),
              )
            else if (_rankedPlaces.isEmpty)
              SliverFillRemaining(
                child: EmptyState(
                  message:
                      'No places found matching "${_selectedIntent.label}".\nTry another category or clear search.',
                  icon: Icons.explore_off_outlined,
                  actionLabel: 'Show All Places',
                  action: () {
                    _searchQuery = '';
                    _onIntentChanged(UserIntent.all);
                  },
                ),
              )
            else
              SliverList(
                delegate: SliverChildListDelegate([
                  // City Pulse: friendly, city-level summary of the same
                  // aggregated data behind Travel Pulse (no new network calls,
                  // computed over places already loaded for this screen).
                  CityPulseCard(summary: _insightsService.computeCityPulse(_allNearbyPlaces)),

                  // 1. Recommended Around You (Multi-Factor Scored)
                  _buildSectionHeader(
                    'Recommended around you',
                    'Ranked by match, rating, proximity & dwell patterns',
                  ),
                  _buildRecommendedCarousel(),

                  const SizedBox(height: AppSpacing.md),

                  // 2. Popular with TripSafe Travellers (Step 5)
                  if (popularWithTravellers.isNotEmpty) ...[
                    _buildSectionHeader(
                      'Popular with TripSafe travellers',
                      'Aggregated from verified dwell visits · k-anonymous',
                    ),
                    ...popularWithTravellers.map((p) => _buildPopularCard(p)),
                    const SizedBox(height: AppSpacing.md),
                  ],

                  // 3. Best Time to Visit (Step 6)
                  if (bestTimePlaces.isNotEmpty) ...[
                    _buildSectionHeader(
                      'Best time to visit',
                      'Golden hour windows & quieter visitor hours',
                    ),
                    _buildBestTimeCarousel(bestTimePlaces),
                    const SizedBox(height: AppSpacing.md),
                  ],

                  // 4. Quick Itinerary Generator Action Banner (Step 7)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: _buildPlanTriggerCard(),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // 5. Full Places Stream
                  _buildSectionHeader(
                    'All nearby spots · ${_rankedPlaces.length}',
                    'Within 6 km search radius',
                  ),
                  ..._rankedPlaces.map((p) => _buildStandardPlaceTile(p)),

                  // Clearance for the floating nav pill.
                  const SizedBox(height: 104),
                ]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVibeChipsBar() {
    return Container(
      height: 46,
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: UserIntent.values.length,
        itemBuilder: (context, index) {
          final intent = UserIntent.values[index];
          final isSelected = _selectedIntent == intent;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: VibeChip(
              label: intent.chipText,
              selected: isSelected,
              onTap: () => _onIntentChanged(intent),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: AppTypography.sectionLabel.copyWith(
              color: AppTheme.mutedDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTypography.caption.copyWith(color: AppTheme.mutedDark),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedCarousel() {
    final topRecommendations = _rankedPlaces.take(6).toList();

    return SizedBox(
      height: 252,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: topRecommendations.length,
        itemBuilder: (context, index) {
          final place = topRecommendations[index];
          final matchPercent = (place.recommendationScore * 100).round();

          return Container(
            width: 270,
            margin: const EdgeInsets.only(right: AppSpacing.sm, top: 4, bottom: 4),
            child: AppCard(
              padding: const EdgeInsets.all(AppSpacing.sm),
              onTap: () => PlaceDetailSheet.show(context, place),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppTheme.tint(AppTheme.primary, 0.12),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Text(place.category.iconEmoji, style: const TextStyle(fontSize: 18)),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              place.name,
                              style: AppTypography.titleSmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${place.category.displayName} · ${place.distanceKm.toStringAsFixed(1)} km',
                              style: AppTypography.caption.copyWith(color: AppTheme.mutedDark),
                            ),
                          ],
                        ),
                      ),
                      StatusPill(
                        label: '$matchPercent% match',
                        color: AppTheme.success,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Explainable Reason Pill
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0x0FFFFFFF),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      place.recommendationReason.isNotEmpty
                          ? place.recommendationReason
                          : '⭐ Recommended based on proximity & ratings',
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.subtleDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const Spacer(),

                  // Dwell & Best Window info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined, size: 14, color: AppTheme.mutedDark),
                          const SizedBox(width: 4),
                          Text(
                            '${place.typicalDwellMinutes}m stay',
                            style: AppTypography.caption.copyWith(color: AppTheme.mutedDark),
                          ),
                        ],
                      ),
                      if (place.estimatedCost > 0)
                        Text(
                          '~₹${place.estimatedCost.round()}',
                          style: AppTypography.caption.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                          ),
                        )
                      else
                        Text(
                          'Free Entry',
                          style: AppTypography.caption.copyWith(
                            color: AppTheme.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Add to Itinerary button
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            ItineraryService.instance.addPlaceToItinerary(place);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${place.name} added to your plan'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: AppTheme.onDark,
                              borderRadius: AppSpacing.pill,
                            ),
                            child: Text(
                              'Add to Trip',
                              style: AppTypography.chipLabel.copyWith(
                                color: AppTheme.surfaceDark,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 9),
                      CircleIconButton(
                        icon: Icons.arrow_outward,
                        size: 32,
                        onPressed: () => PlaceDetailSheet.show(context, place),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPopularCard(Place place) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.sm),
        onTap: () => PlaceDetailSheet.show(context, place),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.tint(AppTheme.secondary, 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(place.category.iconEmoji, style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.titleSmall,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    place.visitCount > 0
                        ? '${place.visitCount} TripSafe visits · Typical stay: ${place.typicalDwellMinutes} min'
                        : '${place.reviewCount} public reviews · Popular nearby',
                    style: AppTypography.caption.copyWith(color: AppTheme.mutedDark),
                  ),
                  if (place.busyHours != null)
                    Text(
                      'Usually busiest: ${place.busyHours}',
                      style: AppTypography.caption.copyWith(color: AppTheme.warning, fontSize: 11),
                    ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.bookmark_add_outlined, color: AppTheme.primary),
              onPressed: () {
                ItineraryService.instance.addPlaceToItinerary(place);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Added ${place.name}')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBestTimeCarousel(List<Place> places) {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: places.length,
        itemBuilder: (context, index) {
          final place = places[index];
          final guide = _insightsService.getBestTimeToVisitGuide(place);

          return Container(
            width: 240,
            margin: const EdgeInsets.only(right: AppSpacing.sm),
            child: AppCard(
              padding: const EdgeInsets.all(AppSpacing.sm),
              onTap: () => PlaceDetailSheet.show(context, place),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: AppTypography.titleSmall.copyWith(fontSize: 13.5),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Best for: ${guide['bestFor']}',
                    style: AppTypography.chipLabel.copyWith(
                      color: AppTheme.secondary,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    'Recommended: ${guide['recommended']}',
                    style: AppTypography.caption.copyWith(fontSize: 11),
                  ),
                  const Spacer(),
                  Text(
                    'Typical stay: ${guide['typicalStay']}',
                    style: AppTypography.caption.copyWith(color: AppTheme.mutedDark, fontSize: 10),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlanTriggerCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: AppTheme.onPrimary, size: 26),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BUILD A PLAN FROM THESE',
                  style: AppTypography.titleSmall.copyWith(
                    color: AppTheme.onPrimary,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Sequenced itinerary with real nearby places & cost tracker',
                  style: AppTypography.caption.copyWith(
                    color: AppTheme.onPrimary.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
          PillButton(
            label: 'Start',
            color: AppTheme.onPrimary,
            onPressed: () => Navigator.pushNamed(context, AppRoutes.plan),
          ),
        ],
      ),
    );
  }

  Widget _buildStandardPlaceTile(Place place) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.sm),
        onTap: () => PlaceDetailSheet.show(context, place),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.tint(AppTheme.primary, 0.12),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Text(place.category.iconEmoji, style: const TextStyle(fontSize: 17)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.titleSmall,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${place.category.displayName} · ${place.distanceKm.toStringAsFixed(1)} km away',
                    style: AppTypography.caption.copyWith(color: AppTheme.mutedDark),
                  ),
                  if (place.address.isNotEmpty)
                    Text(
                      place.address,
                      style: AppTypography.caption.copyWith(color: AppTheme.mutedDark, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: AppTheme.primary),
              onPressed: () {
                ItineraryService.instance.addPlaceToItinerary(place);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Added ${place.name}')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnconfiguredState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.key_off, size: 64, color: AppTheme.warning),
            const SizedBox(height: AppSpacing.md),
            Text('Geoapify Key Required', style: AppTypography.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'To fetch live places, configure your Geoapify key in places_config.dart, or test instantly in Demo Mode.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: 'Launch Demo Mode',
              icon: Icons.science,
              onPressed: () => _toggleDemoMode(true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppTheme.error),
            const SizedBox(height: AppSpacing.md),
            Text('Discovery Error', style: AppTypography.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _errorMessage ?? 'An error occurred while discovering places.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: _loadLocationAndPlaces,
                  child: const Text('Retry'),
                ),
                const SizedBox(width: 12),
                PrimaryButton(
                  label: 'Switch to Demo Mode',
                  onPressed: () => _toggleDemoMode(true),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
