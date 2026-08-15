import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../widgets/buttons.dart';
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const IconChip(
                icon: Icons.construction_rounded,
                color: AppTheme.secondary,
                size: 64,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                screenName.toUpperCase(),
                style: AppTypography.displayMedium.copyWith(fontSize: 26),
              ),
              const SizedBox(height: 10),
              Text(
                purpose,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppTheme.muted(context),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              if (canPop)
                SecondaryButton(
                  label: 'Go back',
                  icon: Icons.arrow_back,
                  onPressed: () => Navigator.of(context).pop(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
