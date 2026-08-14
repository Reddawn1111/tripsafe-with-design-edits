import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../widgets/common_widgets.dart';

/// Temporary placeholder screen for screens not yet implemented.
/// Shows screen name and purpose; allows navigating back.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.screenName,
    required this.purpose,
  });

  final String screenName;
  final String purpose;

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    return Scaffold(
      appBar: TripSafeAppBar(
        title: screenName,
        leading: canPop
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.construction_rounded,
                size: 72,
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.4),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                screenName,
                style: AppTypography.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                purpose,
                style: AppTypography.bodyMedium.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              if (canPop)
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Go Back'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
