import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/event_model.dart';

class ExamDetailsScreen extends StatelessWidget {
  final Event event;

  const ExamDetailsScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    CameraPosition initialPosition = CameraPosition(
      target: LatLng(event.latitude, event.longitude),
      zoom: 12.0,
    );

    Marker eventMarker = Marker(
      markerId: MarkerId(event.title),
      position: LatLng(event.latitude, event.longitude),
      infoWindow: InfoWindow(title: event.title),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Exam Details"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Date: ${event.dateTime.toLocal().toString()}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: GoogleMap(
                initialCameraPosition: initialPosition,
                markers: {eventMarker},
                onMapCreated: (GoogleMapController controller) {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
