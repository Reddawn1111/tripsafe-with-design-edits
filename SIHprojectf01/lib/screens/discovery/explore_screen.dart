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
import '../../widgets/buttons.dart';
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
      appBar: AppBar(
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'TripSafe Explore',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Row(
              children: [
                const Icon(Icons.location_on, size: 12, color: Colors.white70),
                const SizedBox(width: 3),
                Flexible(
                  child: Text(
                    _currentAddress?.areaLabel ?? 'Current GPS Area',
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                    overflow: TextOverflow.ellipsis,
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
              color: _isDemoMode ? Colors.amberAccent : null,
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
                  color: Colors.amber.shade800,
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.white, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'DEMO DATA — simulated consenting travellers',
                          style: AppTypography.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => _toggleDemoMode(false),
                        child: Text(
                          'Exit Demo',
                          style: AppTypography.caption.copyWith(
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
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
                      decoration: InputDecoration(
                        hintText: 'Search places, cafes, sunsets...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      "What's your vibe?",
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.bold,
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
                  // 1. Recommended Around You (Multi-Factor Scored)
                  _buildSectionHeader(
                    '⭐ Recommended Around You',
                    'Ranked by match, rating, proximity & dwell patterns',
                  ),
                  _buildRecommendedCarousel(),

                  const SizedBox(height: AppSpacing.md),

                  // 2. Popular with TripSafe Travellers (Step 5)
                  if (popularWithTravellers.isNotEmpty) ...[
                    _buildSectionHeader(
                      '🔥 Popular with TripSafe Travellers',
                      'Aggregated from verified dwell visits · k-anonymous',
                    ),
                    ...popularWithTravellers.map((p) => _buildPopularCard(p)),
                    const SizedBox(height: AppSpacing.md),
                  ],

                  // 3. Best Time to Visit (Step 6)
                  if (bestTimePlaces.isNotEmpty) ...[
                    _buildSectionHeader(
                      '🌅 Best Time to Visit',
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
                    '📍 All Nearby Spots (${_rankedPlaces.length})',
                    'Within 6 km search radius',
                  ),
                  ..._rankedPlaces.map((p) => _buildStandardPlaceTile(p)),

                  const SizedBox(height: AppSpacing.xxl),
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
            child: ChoiceChip(
              label: Text(intent.chipText),
              selected: isSelected,
              onSelected: (_) => _onIntentChanged(intent),
              selectedColor: AppTheme.primary,
              backgroundColor: Theme.of(context).colorScheme.surface,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppTheme.primary : Colors.grey.shade300,
                ),
              ),
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
            title,
            style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            subtitle,
            style: AppTypography.caption.copyWith(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedCarousel() {
    final topRecommendations = _rankedPlaces.take(6).toList();

    return SizedBox(
      height: 230,
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
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(place.category.iconEmoji, style: const TextStyle(fontSize: 18)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              place.name,
                              style: AppTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${place.category.displayName} · 📍 ${place.distanceKm.toStringAsFixed(1)} km',
                              style: AppTypography.caption.copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.secondary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$matchPercent% match',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Explainable Reason Pill
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      place.recommendationReason.isNotEmpty
                          ? place.recommendationReason
                          : '⭐ Recommended based on proximity & ratings',
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
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
                          const Icon(Icons.timer_outlined, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            '${place.typicalDwellMinutes}m stay',
                            style: AppTypography.caption.copyWith(color: Colors.grey),
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
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        visualDensity: VisualDensity.compact,
                      ),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add to Trip', style: TextStyle(fontSize: 12)),
                      onPressed: () {
                        ItineraryService.instance.addPlaceToItinerary(place);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${place.name} added to your plan!'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
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
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('🔥', style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    place.visitCount > 0
                        ? '${place.visitCount} TripSafe visits · Typical stay: ${place.typicalDwellMinutes} min'
                        : '${place.reviewCount} public reviews · Popular nearby',
                    style: AppTypography.caption.copyWith(color: Colors.grey.shade700),
                  ),
                  if (place.busyHours != null)
                    Text(
                      '🕐 Usually busiest: ${place.busyHours}',
                      style: AppTypography.caption.copyWith(color: Colors.deepOrange, fontSize: 11),
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
                    style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Best for: ${guide['bestFor']}',
                    style: AppTypography.caption.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Recommended: ${guide['recommended']}',
                    style: AppTypography.caption.copyWith(fontSize: 11),
                  ),
                  const Spacer(),
                  Text(
                    'Typical stay: ${guide['typicalStay']}',
                    style: AppTypography.caption.copyWith(color: Colors.grey, fontSize: 10),
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
        gradient: LinearGradient(
          colors: [
            AppTheme.secondary,
            AppTheme.secondary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Build a Trip Plan & Budget',
                  style: AppTypography.titleSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Sequenced itinerary with real nearby places & cost tracker',
                  style: AppTypography.caption.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.secondary,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.plan),
            child: const Text('Start', style: TextStyle(fontWeight: FontWeight.bold)),
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
            CircleAvatar(
              backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
              child: Text(place.category.iconEmoji),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${place.category.displayName} · 📍 ${place.distanceKm.toStringAsFixed(1)} km away',
                    style: AppTypography.caption.copyWith(color: Colors.grey),
                  ),
                  if (place.address.isNotEmpty)
                    Text(
                      place.address,
                      style: AppTypography.caption.copyWith(color: Colors.grey.shade600, fontSize: 11),
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
