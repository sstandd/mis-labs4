import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/event_model.dart';
import '../services/google_maps_service.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';

class MapScreen extends StatefulWidget {
  final List<Event> events;
  final LocationService locationService;
  final NotificationService notificationService;

  const MapScreen({
    super.key,
    required this.events,
    required this.locationService,
    required this.notificationService,
  });

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  late Position _currentPosition;
  bool _isLoading = true;
  Set<Polyline> _polylines = {};
  Marker? _selectedMarker;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    widget.locationService.startLocationMonitoring();
  }

  @override
  void dispose() {
    widget.locationService.stopLocationMonitoring();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await widget.locationService.getCurrentLocation();

      setState(() {
        _currentPosition = position;
        _isLoading = false;
      });

      _mapController.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(position.latitude, position.longitude),
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (kDebugMode) {
        print('Error fetching location: $e');
      }
    }
  }

  Future<void> _getDirections(double destLat, double destLng) async {
    try {
      final userLat = _currentPosition.latitude;
      final userLng = _currentPosition.longitude;

      final polylinePoints = await GoogleMapsService.getPolyline(
        userLat,
        userLng,
        destLat,
        destLng,
      );

      final polyline = Polyline(
        polylineId: const PolylineId('directions'),
        color: Colors.teal,
        width: 5,
        points: polylinePoints,
      );

      setState(() {
        _polylines = {polyline};
        _mapController.animateCamera(
          CameraUpdate.newLatLngBounds(
            _getLatLngBounds(polylinePoints),
            50, // Padding
          ),
        );
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching directions: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to fetch directions')),
      );
    }
  }

  LatLngBounds _getLatLngBounds(List<LatLng> points) {
    final latitudes = points.map((p) => p.latitude).toList();
    final longitudes = points.map((p) => p.longitude).toList();

    return LatLngBounds(
      southwest: LatLng(
        latitudes.reduce((a, b) => a < b ? a : b),
        longitudes.reduce((a, b) => a < b ? a : b),
      ),
      northeast: LatLng(
        latitudes.reduce((a, b) => a > b ? a : b),
        longitudes.reduce((a, b) => a > b ? a : b),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map View'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            GoogleMap(
              onMapCreated: (controller) {
                _mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  _currentPosition.latitude,
                  _currentPosition.longitude,
                ),
                zoom: 12.0,
              ),
              markers: widget.events.map((event) {
                return Marker(
                  markerId: MarkerId(event.title),
                  position: LatLng(event.latitude, event.longitude),
                  onTap: () {
                    setState(() {
                      _selectedMarker = Marker(
                        markerId: MarkerId(event.title),
                        position: LatLng(event.latitude, event.longitude),
                      );
                    });
                  },
                );
              }).toSet(),
              polylines: _polylines,
            ),
          if (_selectedMarker != null)
            Positioned(
              bottom: 50,
              left: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: () {
                  if (_selectedMarker != null) {
                    _getDirections(
                      _selectedMarker!.position.latitude,
                      _selectedMarker!.position.longitude,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.teal,
                ),
                child: const Text(
                  'Get Directions',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
