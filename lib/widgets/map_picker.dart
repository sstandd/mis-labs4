import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPicker extends StatelessWidget {
  final bool isMapInitialized;
  final CameraPosition? initialCameraPosition;
  final Function(LatLng) onMapTapped;
  final double latitude;
  final double longitude;

  const MapPicker({
    super.key,
    required this.isMapInitialized,
    required this.initialCameraPosition,
    required this.onMapTapped,
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    if (!isMapInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return SizedBox(
      height: 200,
      child: GoogleMap(
        initialCameraPosition: initialCameraPosition!,
        onTap: onMapTapped,
        markers: {
          if (latitude != 0.0 && longitude != 0.0)
            Marker(
              markerId: const MarkerId('event_location'),
              position: LatLng(latitude, longitude),
            ),
        },
      ),
    );
  }
}
