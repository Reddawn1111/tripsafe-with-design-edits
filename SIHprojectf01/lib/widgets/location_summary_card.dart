import 'package:flutter/material.dart';

import '../services/location_service.dart';

/// Shows the user's current GPS location on the Home screen.
/// Fetches location on first build and displays a short summary,
/// a loading state, or an error state.
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _isLoading
            ? _buildLoading()
            : _errorMessage != null
                ? _buildError()
                : _buildSuccess(),
      ),
    );
  }

  Widget _buildLoading() {
    return const Row(
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
        SizedBox(width: 12),
        Text('Locating you...'),
      ],
    );
  }

  Widget _buildError() {
    return Row(
      children: [
        const Icon(Icons.location_off, color: Colors.redAccent),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            _errorMessage ?? 'Unable to fetch location.',
            style: const TextStyle(fontSize: 13),
          ),
        ),
        TextButton(
          onPressed: _fetchLocation,
          child: const Text('Retry'),
        ),
      ],
    );
  }

  Widget _buildSuccess() {
    final address = _address!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.my_location, color: Colors.blueAccent),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                address.areaLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                address.shortLine,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: _fetchLocation,
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh location',
        ),
      ],
    );
  }
}