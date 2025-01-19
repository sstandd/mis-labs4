import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GoogleMapsService {
  static const String _googleMapsApiKey = 'AIzaSyDoOGE15xsd8k_stFEshzb68tn0wu3FCMQ';

  static Future<void> getDirections(
      double startLat,
      double startLng,
      double destinationLat,
      double destinationLng,
      ) async {
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=$startLat,$startLng&destination=$destinationLat,$destinationLng'
        '&key=$_googleMapsApiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['routes'].isNotEmpty) {
          final directionsUrl =
              'https://www.google.com/maps/dir/?api=$_googleMapsApiKey&origin=$startLat,$startLng&destination=$destinationLat,$destinationLng&travelmode=driving';
          await _launchURL(directionsUrl);
        } else {
          throw Exception('No routes found in the response.');
        }
      } else {
        throw Exception(
          'Failed to fetch directions. HTTP Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> openMap(double latitude, double longitude) async {
    final String url =
        'https://www.google.com/maps/search/?api=$_googleMapsApiKey&query=$latitude,$longitude';

    try {
      await _launchURL(url);
    } catch (e) {
      throw Exception('Failed to open map location: $e');
    }
  }

  static Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Could not launch URL: $url');
    }
  }

  static Future<List<LatLng>> getPolyline(
      double startLat,
      double startLng,
      double destinationLat,
      double destinationLng,
      ) async {
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=$startLat,$startLng&destination=$destinationLat,$destinationLng'
        '&key=$_googleMapsApiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['routes'].isNotEmpty) {
        final polyline = data['routes'][0]['overview_polyline']['points'];
        return _decodePolyline(polyline);
      } else {
        throw Exception('No routes found in the response.');
      }
    } else {
      throw Exception(
        'Failed to fetch directions. HTTP Status: ${response.statusCode}',
      );
    }
  }

  static List<LatLng> _decodePolyline(String polyline) {
    final List<LatLng> points = [];
    int index = 0;
    int len = polyline.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int shift = 0, result = 0;
      int b;

      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      final int dLat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dLat;

      shift = 0;
      result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      final int dLng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dLng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }
}
