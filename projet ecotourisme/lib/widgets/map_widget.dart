import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:ecoguide/models/site_model.dart';
import 'package:ecoguide/utils/app_theme.dart';
import 'package:ecoguide/utils/constants.dart';
import 'package:ecoguide/services/location_service.dart';
import 'package:location/location.dart';

class MapWidget extends StatefulWidget {
  final List<Site> sites;
  final Function(Site)? onSiteTap;
  final LatLng? initialCenter;
  final double? initialZoom;
  final bool showUserLocation;
  final List<LatLng>? routePoints;

  const MapWidget({
    super.key,
    this.sites = const [],
    this.onSiteTap,
    this.initialCenter,
    this.initialZoom,
    this.showUserLocation = true,
    this.routePoints,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  final MapController _mapController = MapController();
  final LocationService _locationService = LocationService();
  LocationData? _currentPosition;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    if (widget.showUserLocation) {
      _loadCurrentLocation();
    }
  }

  Future<void> _loadCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      final position = await _locationService.getCurrentLocation();
      if (mounted && position != null) {
        setState(() {
          _currentPosition = position;
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  void _centerOnUser() {
    if (_currentPosition != null && 
        _currentPosition!.latitude != null && 
        _currentPosition!.longitude != null) {
      _mapController.move(
        LatLng(_currentPosition!.latitude!, _currentPosition!.longitude!),
        AppConstants.siteDetailZoom,
      );
    }
  }

  IconData _getSiteIcon(String type) {
    switch (type) {
      case 'reserve':
        return Icons.nature;
      case 'park':
        return Icons.park;
      case 'forest':
        return Icons.forest;
      case 'beach':
        return Icons.beach_access;
      case 'mountain':
        return Icons.terrain;
      case 'wetland':
        return Icons.water;
      default:
        return Icons.place;
    }
  }

  @override
  Widget build(BuildContext context) {
    final center = widget.initialCenter ??
        (_currentPosition != null &&
         _currentPosition!.latitude != null &&
         _currentPosition!.longitude != null
            ? LatLng(_currentPosition!.latitude!, _currentPosition!.longitude!)
            : const LatLng(
                AppConstants.defaultLatitude, AppConstants.defaultLongitude));

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: center,
            initialZoom: widget.initialZoom ?? AppConstants.defaultZoom,
            minZoom: AppConstants.minZoom,
            maxZoom: AppConstants.maxZoom,
          ),
          children: [
            // OpenStreetMap tiles
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.ecoguide.app',
            ),
            // Route polyline
            if (widget.routePoints != null && widget.routePoints!.isNotEmpty)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: widget.routePoints!,
                    color: AppTheme.primaryGreen,
                    strokeWidth: 4,
                  ),
                ],
              ),
            // Site markers
            MarkerLayer(
              markers: [
                // User location marker
                if (_currentPosition != null &&
                    _currentPosition!.latitude != null &&
                    _currentPosition!.longitude != null)
                  Marker(
                    point: LatLng(
                        _currentPosition!.latitude!, _currentPosition!.longitude!),
                    width: 30,
                    height: 30,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.accentBlue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ),
                // Site markers
                ...widget.sites.map((site) => Marker(
                      point: LatLng(site.latitude, site.longitude),
                      width: 40,
                      height: 40,
                      child: GestureDetector(
                        onTap: () => widget.onSiteTap?.call(site),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Icon(
                            _getSiteIcon(site.type),
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    )),
              ],
            ),
          ],
        ),
        // Location button
        if (widget.showUserLocation)
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton.small(
              heroTag: 'locationBtn_${widget.hashCode}',
              onPressed: _isLoadingLocation ? null : _centerOnUser,
              backgroundColor: Colors.white,
              child: _isLoadingLocation
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      Icons.my_location,
                      color: _currentPosition != null
                          ? AppTheme.accentBlue
                          : Colors.grey,
                    ),
            ),
          ),
      ],
    );
  }
}
