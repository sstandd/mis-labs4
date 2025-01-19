import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../models/event_model.dart';
import 'notification_service.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();

  factory LocationService() {
    return _instance;
  }

  LocationService._internal();

  final List<Event> events = [];
  late final NotificationService notificationService;

  void initialize(List<Event> events, NotificationService notificationService) {
    this.events.addAll(events);
    this.notificationService = notificationService;
  }

  StreamSubscription<Position>? _positionStream;

  void startLocationMonitoring() {
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      for (var event in events) {
        if (_isWithinRange(position, event.latitude, event.longitude)) {
          notificationService.sendEventNotification(event.title);
        }
      }
    });
  }

  void stopLocationMonitoring() {
    _positionStream?.cancel();
  }

  bool _isWithinRange(Position position, double latitude, double longitude) {
    const double rangeInMeters = 100;
    double distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      latitude,
      longitude,
    );
    return distance <= rangeInMeters;
  }

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        throw Exception('Location permissions are denied');
      }
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }
}
