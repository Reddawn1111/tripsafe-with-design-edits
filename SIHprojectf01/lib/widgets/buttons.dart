import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

/// Reusable primary action button — solid rust pill.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.color,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;

  /// Overrides the accent — e.g. `AppTheme.success` to start a journey.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final bg = color ?? AppTheme.primary;
    final fg = _inkFor(bg);

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        disabledBackgroundColor: bg.withValues(alpha: 0.35),
        disabledForegroundColor: fg.withValues(alpha: 0.5),
      ),
      child: isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2.2, color: fg),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Text(label),
              ],
            ),
    );
  }
}

/// Reusable secondary (outlined) button.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  /// Tints both the label and the hairline outline.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final style = color == null
        ? null
        : OutlinedButton.styleFrom(
            foregroundColor: color,
            side: BorderSide(color: color!.withValues(alpha: 0.4), width: 1.5),
            backgroundColor: color!.withValues(alpha: 0.08),
          );

    return OutlinedButton(
      onPressed: onPressed,
      style: style,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18),
            const SizedBox(width: AppSpacing.sm),
          ],
          Text(label),
        ],
      ),
    );
  }
}

/// Compact pill button for inline actions — "Add to Trip", "Start".
class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color,
    this.dense = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  /// Defaults to the on-surface ink (off-white pill on dark).
  final Color? color;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = color ?? (isDark ? AppTheme.onDark : AppTheme.onLight);
    final fg = color == null
        ? (isDark ? AppTheme.surfaceDark : AppTheme.cardLight)
        : _inkFor(bg);

    return Material(
      color: bg,
      shape: const StadiumBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: dense ? 12 : 16,
            vertical: dense ? 7 : 10,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: dense ? 13 : 15, color: fg),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: AppTypography.chipLabel.copyWith(
                  color: fg,
                  fontSize: dense ? 11 : 12.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Circular icon button used top-right on accent panels and cards.
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.background,
    this.foreground,
    this.size = 36,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final Color? background;
  final Color? foreground;
  final double size;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = background ?? (isDark ? AppTheme.cardDark : AppTheme.cardLight);
    final fg = foreground ?? (isDark ? AppTheme.onDark : AppTheme.onLight);

    final button = Material(
      color: bg,
      shape: CircleBorder(
        side: background == null
            ? BorderSide(
                color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
              )
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, size: size * 0.44, color: fg),
        ),
      ),
    );

    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}

/// Selectable vibe/filter chip.
class VibeChip extends StatelessWidget {
  const VibeChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final on = isDark ? AppTheme.onDark : AppTheme.onLight;
    final surface = isDark ? AppTheme.cardDark : AppTheme.cardLight;

    return Material(
      color: selected ? on : surface,
      shape: StadiumBorder(
        side: BorderSide(
          color: selected
              ? Colors.transparent
              : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: AppTypography.chipLabel.copyWith(
              color: selected ? surface : AppTheme.muted(context),
            ),
          ),
        ),
      ),
    );
  }
}

Color _inkFor(Color accent) {
  if (accent == AppTheme.secondary || accent == AppTheme.warning) {
    return AppTheme.onSecondary;
  }
  if (accent == AppTheme.success) return AppTheme.onSuccess;
  if (accent == AppTheme.info) return AppTheme.onInfo;
  if (accent == AppTheme.onDark) return AppTheme.surfaceDark;
  return AppTheme.onPrimary;
}
