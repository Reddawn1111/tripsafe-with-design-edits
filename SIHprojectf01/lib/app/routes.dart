import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';
import '../screens/discovery/discovery_screen.dart';
import '../screens/discovery/destination_detail_screen.dart';
import '../screens/planning/planning_screen.dart';
import '../screens/itinerary/itinerary_screen.dart';
import '../screens/itinerary/updated_itinerary_screen.dart';
import '../screens/safety/safety_check_screen.dart';
import '../screens/journey/active_journey_screen.dart';
import '../screens/risk_alert/risk_alert_screen.dart';
import '../screens/adapt_trip/adapt_trip_screen.dart';
import '../screens/alternative_destination/alternative_destination_screen.dart';
import '../screens/timeline/timeline_screen.dart';
import '../screens/expenses/expenses_screen.dart';
import '../screens/expenses/settlement_screen.dart';
import '../screens/group/group_screen.dart';
import '../screens/memories/memories_screen.dart';
import '../screens/trip_summary/trip_summary_screen.dart';
import '../screens/authority/authority_dashboard_screen.dart';
import '../screens/privacy/privacy_settings_screen.dart';
import '../screens/shared/placeholder_screen.dart';

/// Centralized route name constants.
abstract class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String discover = '/discover';
  static const String destinationDetail = '/discover/detail';
  static const String plan = '/plan';
  static const String itinerary = '/itinerary';
  static const String itineraryUpdated = '/itinerary/updated';
  static const String safety = '/safety';
  static const String journey = '/journey';
  static const String alert = '/alert';
  static const String adapt = '/adapt';
  static const String alternatives = '/alternatives';
  static const String timeline = '/timeline';
  static const String expenses = '/expenses';
  static const String settlement = '/settlement';
  static const String group = '/group';
  static const String memories = '/memories';
  static const String summary = '/summary';
  static const String authority = '/authority';
  static const String privacy = '/privacy';
}

/// Route argument key constants — avoids scattered string literals.
abstract class RouteArgs {
  RouteArgs._();

  static const String tripId = 'tripId';
  static const String alertId = 'alertId';
  static const String destinationId = 'destinationId';
}

/// Central router — all route resolution lives here.
abstract class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments is Map<String, dynamic>
        ? settings.arguments as Map<String, dynamic>
        : <String, dynamic>{};

    switch (settings.name) {
      case AppRoutes.home:
        return _slide(const HomeScreen(), settings);

      case AppRoutes.discover:
        return _slide(const DiscoveryScreen(), settings);

      case AppRoutes.destinationDetail:
        return _slide(
          DestinationDetailScreen(
            destinationId: args[RouteArgs.destinationId] as String? ?? '',
          ),
          settings,
        );

      case AppRoutes.plan:
        return _slide(
          PlanningScreen(
            destinationId: args[RouteArgs.destinationId] as String? ?? '',
          ),
          settings,
        );

      case AppRoutes.itinerary:
        return _slide(
          ItineraryScreen(tripId: args[RouteArgs.tripId] as String? ?? ''),
          settings,
        );

      case AppRoutes.itineraryUpdated:
        return _slide(
          UpdatedItineraryScreen(
            tripId: args[RouteArgs.tripId] as String? ?? '',
          ),
          settings,
        );

      case AppRoutes.safety:
        return _slide(
          SafetyCheckScreen(tripId: args[RouteArgs.tripId] as String? ?? ''),
          settings,
        );

      case AppRoutes.journey:
        return _slide(
          ActiveJourneyScreen(tripId: args[RouteArgs.tripId] as String? ?? ''),
          settings,
        );

      case AppRoutes.alert:
        return _slide(
          RiskAlertScreen(
            tripId: args[RouteArgs.tripId] as String? ?? '',
            alertId: args[RouteArgs.alertId] as String? ?? '',
          ),
          settings,
        );

      case AppRoutes.adapt:
        return _slide(
          AdaptTripScreen(
            tripId: args[RouteArgs.tripId] as String? ?? '',
            alertId: args[RouteArgs.alertId] as String? ?? '',
          ),
          settings,
        );

      case AppRoutes.alternatives:
        return _slide(
          AlternativeDestinationScreen(
            tripId: args[RouteArgs.tripId] as String? ?? '',
            alertId: args[RouteArgs.alertId] as String? ?? '',
          ),
          settings,
        );

      case AppRoutes.timeline:
        return _slide(
          TimelineScreen(tripId: args[RouteArgs.tripId] as String? ?? ''),
          settings,
        );

      case AppRoutes.expenses:
        return _slide(
          ExpensesScreen(tripId: args[RouteArgs.tripId] as String? ?? ''),
          settings,
        );

      case AppRoutes.settlement:
        return _slide(
          SettlementScreen(tripId: args[RouteArgs.tripId] as String? ?? ''),
          settings,
        );

      case AppRoutes.group:
        return _slide(
          GroupScreen(tripId: args[RouteArgs.tripId] as String? ?? ''),
          settings,
        );

      case AppRoutes.memories:
        return _slide(
          MemoriesScreen(tripId: args[RouteArgs.tripId] as String? ?? ''),
          settings,
        );

      case AppRoutes.summary:
        return _slide(
          TripSummaryScreen(tripId: args[RouteArgs.tripId] as String? ?? ''),
          settings,
        );

      case AppRoutes.authority:
        return _slide(const AuthorityDashboardScreen(), settings);

      case AppRoutes.privacy:
        return _slide(const PrivacySettingsScreen(), settings);

      default:
        return _slide(
          PlaceholderScreen(
            screenName: settings.name ?? 'Unknown',
            purpose: 'Route not yet implemented.',
          ),
          settings,
        );
    }
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return _slide(
      PlaceholderScreen(
        screenName: settings.name ?? 'Unknown',
        purpose: 'This route does not exist.',
      ),
      settings,
    );
  }

  static PageRouteBuilder<dynamic> _slide(Widget page, RouteSettings settings) {
    return PageRouteBuilder<dynamic>(
      settings: settings,
      pageBuilder: (_, _, _) => page,
      transitionsBuilder: (_, animation, _, child) {
        return SlideTransition(
          position:
              Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              ),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 280),
    );
  }
}
