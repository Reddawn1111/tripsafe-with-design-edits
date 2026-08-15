import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

/// Reusable card wrapper with TRIPSAFE styling.
///
/// Flat charcoal surface, one hairline border, no elevation. The card no
/// longer relies on `Card` so the border radius and ink splash stay in sync.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.accentBorder,
    this.background,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  /// Tints the hairline border — use for advisory/alert cards.
  final Color? accentBorder;

  /// Overrides the card fill (rarely needed).
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = BorderRadius.circular(AppSpacing.radiusLg);

    return Container(
      decoration: BoxDecoration(
        color: background ?? (isDark ? AppTheme.cardDark : AppTheme.cardLight),
        borderRadius: radius,
        border: Border.all(
          color: accentBorder != null
              ? accentBorder!.withValues(alpha: 0.30)
              : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppSpacing.md),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// The saturated full-width panel that carries each screen's hierarchy.
///
/// One per screen. `color` is the accent; `foreground` is the ink placed on
/// it (defaults to the matching dark ink from the palette).
class AccentPanel extends StatelessWidget {
  const AccentPanel({
    super.key,
    required this.child,
    this.color = AppTheme.primary,
    this.foreground,
    this.padding,
    this.onTap,
  });

  final Widget child;
  final Color color;
  final Color? foreground;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  static Color inkFor(Color accent) {
    if (accent == AppTheme.secondary || accent == AppTheme.warning) {
      return AppTheme.onSecondary;
    }
    if (accent == AppTheme.success) return AppTheme.onSuccess;
    if (accent == AppTheme.info) return AppTheme.onInfo;
    return AppTheme.onPrimary;
  }

  @override
  Widget build(BuildContext context) {
    final ink = foreground ?? inkFor(color);
    final radius = BorderRadius.circular(AppSpacing.radiusXl);

    return Container(
      decoration: BoxDecoration(color: color, borderRadius: radius),
      clipBehavior: Clip.antiAlias,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(18),
            child: IconTheme(
              data: IconThemeData(color: ink, size: 20),
              child: DefaultTextStyle.merge(
                style: TextStyle(color: ink),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Small all-caps section heading: "WHAT'S THE PLAN TODAY".
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final label = Text(
      text.toUpperCase(),
      style: AppTypography.sectionLabel.copyWith(color: AppTheme.muted(context)),
    );
    if (trailing == null) return label;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [label, trailing!],
    );
  }
}

/// Pill badge — invite codes, severity tags, "LIVE" markers.
class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    this.color = AppTheme.success,
    this.dot = false,
    this.solid = false,
  });

  final String label;
  final Color color;

  /// Leading dot, for live/tracking states.
  final bool dot;

  /// Solid accent fill instead of a soft tint.
  final bool solid;

  @override
  Widget build(BuildContext context) {
    final fg = solid ? AccentPanel.inkFor(color) : color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: solid ? color : AppTheme.tint(color, 0.13),
        borderRadius: AppSpacing.pill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label.toUpperCase(),
            style: AppTypography.chipLabel.copyWith(
              color: fg,
              fontSize: 10,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

/// Rounded-square tinted icon chip used at the head of list rows.
class IconChip extends StatelessWidget {
  const IconChip({
    super.key,
    required this.icon,
    this.color = AppTheme.primary,
    this.size = 42,
  });

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppTheme.tint(color),
        borderRadius: BorderRadius.circular(size * 0.31),
      ),
      child: Icon(icon, color: color, size: size * 0.45),
    );
  }
}

/// A labelled figure — budget totals, stop counts, safety scores.
class StatBlock extends StatelessWidget {
  const StatBlock({
    super.key,
    required this.label,
    required this.value,
    this.color,
    this.filled = true,
  });

  final String label;
  final String value;
  final Color? color;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: filled
            ? (isDark ? const Color(0x0DFFFFFF) : const Color(0x08000000))
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.titleMedium.copyWith(color: color),
          ),
          const SizedBox(height: 3),
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.chipLabel.copyWith(
              fontSize: 9,
              letterSpacing: 1,
              color: AppTheme.muted(context),
            ),
          ),
        ],
      ),
    );
  }
}

/// Flat progress bar — budget health, journey completion.
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    super.key,
    required this.value,
    this.color = AppTheme.secondary,
    this.height = 7,
  });

  final double value;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: AppSpacing.pill,
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: height,
        color: color,
        backgroundColor: isDark ? const Color(0x14FFFFFF) : const Color(0x14000000),
      ),
    );
  }
}

/// Common app bar with TRIPSAFE styling — uppercase tight title.
class TripSafeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TripSafeAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = false,
    this.subtitle,
  });

  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: subtitle == null
          ? Text(title.toUpperCase())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title.toUpperCase()),
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: AppTypography.caption.copyWith(
                    color: AppTheme.muted(context),
                  ),
                ),
              ],
            ),
      actions: actions,
      leading: leading,
      centerTitle: centerTitle,
      toolbarHeight: subtitle == null ? kToolbarHeight : 72,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(subtitle == null ? kToolbarHeight : 72);
}

/// Empty state placeholder widget.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.action,
    this.actionLabel,
  });

  final String message;
  final IconData icon;
  final VoidCallback? action;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconChip(icon: icon, color: AppTheme.primary, size: 64),
            const SizedBox(height: AppSpacing.lg),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyLarge.copyWith(
                color: AppTheme.muted(context),
              ),
            ),
            if (action != null && actionLabel != null) ...[
              const SizedBox(height: AppSpacing.lg),
              OutlinedButton(onPressed: action, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Full-screen loading indicator.
class LoadingState extends StatelessWidget {
  const LoadingState({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: AppTheme.primary,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: AppTheme.muted(context),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Error state widget.
class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const IconChip(
              icon: Icons.error_outline,
              color: AppTheme.danger,
              size: 56,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyLarge,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
