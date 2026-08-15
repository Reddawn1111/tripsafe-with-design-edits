import 'package:flutter/material.dart';

import '../services/location_service.dart';
import '../utils/app_theme.dart';
import 'buttons.dart';
import 'common_widgets.dart';

/// Shows the user's current GPS location. Fetches on first build and
/// displays a short summary, a loading state, or an error state.
class LocationSummaryCard extends StatefulWidget {
  const LocationSummaryCard({super.key});

  @override
  State<LocationSummaryCard> createState() => _LocationSummaryCardState();
}

class _LocationSummaryCardState extends State<LocationSummaryCard> {
  final _locationService = LocationService();

  bool _isLoading = true;
  LocationAddress? _address;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final address = await _locationService.getCurrentLocationAddress();
      setState(() {
        _address = address;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: _isLoading
          ? _buildLoading()
          : _errorMessage != null
              ? _buildError()
              : _buildSuccess(),
    );
  }

  Widget _buildLoading() {
    return Row(
      children: [
        const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2.2,
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Locating you…',
          style: AppTypography.bodyMedium.copyWith(
            color: AppTheme.muted(context),
          ),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Row(
      children: [
        const IconChip(
          icon: Icons.location_off,
          color: AppTheme.danger,
          size: 38,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            _errorMessage ?? 'Unable to fetch location.',
            style: AppTypography.bodySmall.copyWith(
              fontSize: 12.5,
              color: AppTheme.body(context),
            ),
          ),
        ),
        const SizedBox(width: 8),
        PillButton(
          label: 'Retry',
          dense: true,
          onPressed: _fetchLocation,
        ),
      ],
    );
  }

  Widget _buildSuccess() {
    final address = _address!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const IconChip(icon: Icons.my_location, size: 38),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                address.areaLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.titleMedium,
              ),
              const SizedBox(height: 3),
              Text(
                address.shortLine,
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
        const SizedBox(width: 8),
        CircleIconButton(
          icon: Icons.refresh,
          size: 32,
          tooltip: 'Refresh location',
          onPressed: _fetchLocation,
        ),
      ],
    );
  }
}
