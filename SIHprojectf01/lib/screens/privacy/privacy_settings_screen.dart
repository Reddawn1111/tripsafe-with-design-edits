import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../widgets/common_widgets.dart';

/// PrivacySettingsScreen — User-facing consent controls, anonymization settings & privacy architecture (Step 13)
class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool _shareAnonymousDwells = true;
  bool _shareAggregateCrowdSignals = true;
  bool _enableDeviceContext = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy & Consent Controls'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // Privacy Guarantee Card
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppTheme.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppTheme.success.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_user_outlined, color: AppTheme.success, size: 28),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Zero-Surveillance Architecture', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        'TRIPSAFE strictly uses anonymized, aggregated signals. Your personal identity is never attached to movement records.',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          Text('Consented Data Sharing', style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Share Anonymized Dwell Events', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Helps calculate "Best time to visit" and typical stay duration for fellow travellers.', style: TextStyle(fontSize: 12)),
                  value: _shareAnonymousDwells,
                  activeThumbColor: AppTheme.primary,
                  onChanged: (val) => setState(() => _shareAnonymousDwells = val),
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Contribute to Crowd Pressure Heatmaps', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Aggregated across 50+ travellers to help municipal authorities manage bottlenecks.', style: TextStyle(fontSize: 12)),
                  value: _shareAggregateCrowdSignals,
                  activeThumbColor: AppTheme.primary,
                  onChanged: (val) => setState(() => _shareAggregateCrowdSignals = val),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          Text('Optional Device Activity (Step 13)', style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          AppCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Coarse Device Context', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Optional coarse usage duration to estimate tourist dwell comfort. Disabled by default.', style: TextStyle(fontSize: 12)),
                  value: _enableDeviceContext,
                  activeThumbColor: AppTheme.secondary,
                  onChanged: (val) => setState(() => _enableDeviceContext = val),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('🚫 Strict Non-Collection Guarantees:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('• No messages, chats, or keystrokes', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      Text('• No browser history or private searches', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      Text('• No photos, camera frames, or personal files', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      Text('• No passwords or clipboard data', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          Center(
            child: Text(
              'TripSafe v1.0.0+1 · SIH Mobility Intelligence System',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}
