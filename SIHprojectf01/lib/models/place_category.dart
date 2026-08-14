import 'package:flutter/material.dart';

/// Categories supported by TRIPSAFE Explore feature.
enum PlaceCategory {
  food,
  cafe,
  beach,
  nature,
  park,
  attraction,
  museum,
  viewpoint,
  photography,
  entertainment,
  shopping,
  activity,
  hotel,
  religious,
  other;

  String get displayName {
    switch (this) {
      case PlaceCategory.food:
        return 'Food & Dining';
      case PlaceCategory.cafe:
        return 'Cafe & Bakery';
      case PlaceCategory.beach:
        return 'Beach & Coastal';
      case PlaceCategory.nature:
        return 'Nature & Outdoors';
      case PlaceCategory.park:
        return 'Park & Garden';
      case PlaceCategory.attraction:
        return 'Tourist Attraction';
      case PlaceCategory.museum:
        return 'Museum & Culture';
      case PlaceCategory.viewpoint:
        return 'Viewpoint & Sunset';
      case PlaceCategory.photography:
        return 'Photo Location';
      case PlaceCategory.entertainment:
        return 'Entertainment & Fun';
      case PlaceCategory.shopping:
        return 'Shopping & Markets';
      case PlaceCategory.activity:
        return 'Activities & Sports';
      case PlaceCategory.hotel:
        return 'Hotel & Stays';
      case PlaceCategory.religious:
        return 'Historic & Sacred';
      case PlaceCategory.other:
        return 'Point of Interest';
    }
  }

  String get iconEmoji {
    switch (this) {
      case PlaceCategory.food:
        return '🍴';
      case PlaceCategory.cafe:
        return '☕';
      case PlaceCategory.beach:
        return '🏖️';
      case PlaceCategory.nature:
        return '🌲';
      case PlaceCategory.park:
        return '🌳';
      case PlaceCategory.attraction:
        return '🏛️';
      case PlaceCategory.museum:
        return '🎨';
      case PlaceCategory.viewpoint:
        return '🌅';
      case PlaceCategory.photography:
        return '📸';
      case PlaceCategory.entertainment:
        return '🎮';
      case PlaceCategory.shopping:
        return '🛍️';
      case PlaceCategory.activity:
        return '🎯';
      case PlaceCategory.hotel:
        return '🏨';
      case PlaceCategory.religious:
        return '🛕';
      case PlaceCategory.other:
        return '📍';
    }
  }

  IconData get iconData {
    switch (this) {
      case PlaceCategory.food:
        return Icons.restaurant;
      case PlaceCategory.cafe:
        return Icons.local_cafe;
      case PlaceCategory.beach:
        return Icons.beach_access;
      case PlaceCategory.nature:
        return Icons.park;
      case PlaceCategory.park:
        return Icons.forest;
      case PlaceCategory.attraction:
        return Icons.account_balance;
      case PlaceCategory.museum:
        return Icons.museum;
      case PlaceCategory.viewpoint:
        return Icons.landscape;
      case PlaceCategory.photography:
        return Icons.camera_alt;
      case PlaceCategory.entertainment:
        return Icons.sports_esports;
      case PlaceCategory.shopping:
        return Icons.shopping_bag;
      case PlaceCategory.activity:
        return Icons.directions_run;
      case PlaceCategory.hotel:
        return Icons.hotel;
      case PlaceCategory.religious:
        return Icons.church;
      case PlaceCategory.other:
        return Icons.place;
    }
  }

  /// Maps Geoapify hierarchical categories to our generic PlaceCategory.
  static PlaceCategory fromGeoapifyCategory(String category) {
    final lower = category.toLowerCase();
    if (lower.startsWith('catering.restaurant') ||
        lower.startsWith('catering.fast_food') ||
        lower.startsWith('catering.food_court')) {
      return PlaceCategory.food;
    }
    if (lower.startsWith('catering.cafe') ||
        lower.startsWith('catering.bakery') ||
        lower.startsWith('catering.ice_cream') ||
        lower.startsWith('catering.pub') ||
        lower.startsWith('catering.bar')) {
      return PlaceCategory.cafe;
    }
    if (lower.contains('beach') || lower.startsWith('natural.water')) {
      return PlaceCategory.beach;
    }
    if (lower.startsWith('leisure.park') || lower.startsWith('leisure.garden')) {
      return PlaceCategory.park;
    }
    if (lower.startsWith('natural.forest') ||
        lower.startsWith('natural.nature_reserve') ||
        lower.startsWith('natural.waterfall') ||
        lower.startsWith('natural.peak')) {
      return PlaceCategory.nature;
    }
    if (lower.startsWith('entertainment.museum') ||
        lower.startsWith('entertainment.gallery') ||
        lower.startsWith('entertainment.culture')) {
      return PlaceCategory.museum;
    }
    if (lower.startsWith('tourism.attraction') ||
        lower.startsWith('tourism.sights') ||
        lower.startsWith('heritage')) {
      return PlaceCategory.attraction;
    }
    if (lower.startsWith('tourism.viewpoint') || lower.contains('viewpoint')) {
      return PlaceCategory.viewpoint;
    }
    if (lower.startsWith('tourism.picnic_site') || lower.contains('scenic')) {
      return PlaceCategory.photography;
    }
    if (lower.startsWith('commercial.shopping') ||
        lower.startsWith('commercial.marketplace') ||
        lower.startsWith('commercial.department_store')) {
      return PlaceCategory.shopping;
    }
    if (lower.startsWith('entertainment.')) {
      return PlaceCategory.entertainment;
    }
    if (lower.startsWith('sport.') ||
        lower.startsWith('leisure.sports') ||
        lower.startsWith('leisure.playground')) {
      return PlaceCategory.activity;
    }
    if (lower.startsWith('religion.') || lower.contains('place_of_worship')) {
      return PlaceCategory.religious;
    }
    if (lower.startsWith('accommodation.hotel') ||
        lower.startsWith('accommodation.hostel')) {
      return PlaceCategory.hotel;
    }
    return PlaceCategory.other;
  }

  /// Picks the best matching category from a Geoapify category list.
  static PlaceCategory primaryFromGeoapifyCategories(List<String> categories) {
    for (final category in categories) {
      final mapped = fromGeoapifyCategory(category);
      if (mapped != PlaceCategory.other) return mapped;
    }
    return PlaceCategory.other;
  }

  /// Maps legacy/generic place type strings to our generic PlaceCategory.
  static PlaceCategory fromGoogleType(String type) {
    final lower = type.toLowerCase();
    if (lower.contains('restaurant') ||
        lower.contains('diner') ||
        lower.contains('food') ||
        lower.contains('meal')) {
      return PlaceCategory.food;
    }
    if (lower.contains('cafe') || lower.contains('bakery') || lower.contains('coffee')) {
      return PlaceCategory.cafe;
    }
    if (lower.contains('beach')) {
      return PlaceCategory.beach;
    }
    if (lower.contains('park') || lower.contains('garden')) {
      return PlaceCategory.park;
    }
    if (lower.contains('museum') || lower.contains('art_gallery')) {
      return PlaceCategory.museum;
    }
    if (lower.contains('tourist_attraction') ||
        lower.contains('monument') ||
        lower.contains('historical')) {
      return PlaceCategory.attraction;
    }
    if (lower.contains('viewpoint') || lower.contains('scenic')) {
      return PlaceCategory.viewpoint;
    }
    if (lower.contains('shopping') || lower.contains('store') || lower.contains('mall') || lower.contains('market')) {
      return PlaceCategory.shopping;
    }
    if (lower.contains('amusement') || lower.contains('bowling') || lower.contains('movie_theater') || lower.contains('night_club')) {
      return PlaceCategory.entertainment;
    }
    if (lower.contains('hiking') || lower.contains('campground') || lower.contains('natural_feature')) {
      return PlaceCategory.nature;
    }
    if (lower.contains('place_of_worship') || lower.contains('church') || lower.contains('temple') || lower.contains('mosque')) {
      return PlaceCategory.religious;
    }
    if (lower.contains('lodging') || lower.contains('hotel')) {
      return PlaceCategory.hotel;
    }
    return PlaceCategory.other;
  }
}

/// User Intent Chips for Explore UI filtering ("What's your vibe?").
enum UserIntent {
  all('✨', 'All'),
  eat('🍴', 'Eat'),
  explore('🏖️', 'Explore'),
  nature('🌲', 'Nature'),
  relax('🚶', 'Relax'),
  fun('🎮', 'Fun'),
  photos('📸', 'Photos'),
  shop('🛍️', 'Shopping'),
  activities('🎯', 'Activities'),
  stays('🏨', 'Stays');

  final String emoji;
  final String label;

  const UserIntent(this.emoji, this.label);

  String get chipText => '$emoji $label';

  /// Check if a place category matches this intent.
  /// Note: "Stays" do not dominate 'All' results unless explicitly requested.
  bool matches(PlaceCategory category, List<String> types) {
    final typeLower = types.map((t) => t.toLowerCase()).toList();

    switch (this) {
      case UserIntent.all:
        // Hide hotels/stays from general explore stream
        return category != PlaceCategory.hotel;
      case UserIntent.eat:
        return category == PlaceCategory.food ||
            category == PlaceCategory.cafe ||
            typeLower.any((t) => t.contains('restaurant') || t.contains('cafe') || t.contains('food'));
      case UserIntent.explore:
        return category == PlaceCategory.attraction ||
            category == PlaceCategory.viewpoint ||
            category == PlaceCategory.museum ||
            category == PlaceCategory.religious ||
            typeLower.any((t) => t.contains('tourist'));
      case UserIntent.nature:
        return category == PlaceCategory.nature ||
            category == PlaceCategory.park ||
            category == PlaceCategory.beach ||
            typeLower.any((t) => t.contains('natural') || t.contains('park'));
      case UserIntent.relax:
        return category == PlaceCategory.park ||
            category == PlaceCategory.beach ||
            category == PlaceCategory.viewpoint ||
            category == PlaceCategory.cafe;
      case UserIntent.fun:
        return category == PlaceCategory.entertainment ||
            category == PlaceCategory.activity ||
            category == PlaceCategory.shopping;
      case UserIntent.photos:
        return category == PlaceCategory.viewpoint ||
            category == PlaceCategory.photography ||
            category == PlaceCategory.beach ||
            category == PlaceCategory.attraction ||
            category == PlaceCategory.nature;
      case UserIntent.shop:
        return category == PlaceCategory.shopping ||
            typeLower.any((t) => t.contains('store') || t.contains('market') || t.contains('mall'));
      case UserIntent.activities:
        return category == PlaceCategory.activity ||
            category == PlaceCategory.entertainment ||
            typeLower.any((t) => t.contains('sport') || t.contains('activity') || t.contains('gym'));
      case UserIntent.stays:
        return category == PlaceCategory.hotel ||
            typeLower.any((t) => t.contains('hotel') || t.contains('hostel') || t.contains('accommodation') || t.contains('lodging'));
    }
  }
}
