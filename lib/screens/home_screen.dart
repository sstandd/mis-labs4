import 'package:flutter/material.dart';
import 'calendar_screen.dart';
import 'map_screen.dart';
import '../models/event_model.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Event> _events = [];

  @override
  void initState() {
    super.initState();
    requestNotificationPermission(context);
    LocationService().startLocationMonitoring();
  }

  @override
  void dispose() {
    LocationService().stopLocationMonitoring();
    super.dispose();
  }

  void _onEventAdded(Event event) {
    setState(() {
      _events.add(event);
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      CalendarScreen(events: _events, onEventAdded: _onEventAdded),
      MapScreen(
        events: _events,
        locationService: LocationService(),
        notificationService: NotificationService(),
      ),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
        ],
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  // Request notification permission
  Future<void> requestNotificationPermission(BuildContext context) async {
    final status = await Permission.notification.request();

    if (status.isGranted) {
      // Permission granted, proceed with sending notifications
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Notification permission granted!")),
      );
    } else if (status.isDenied) {
      // Permission denied, show an explanation or redirect the user to settings
      _showPermissionDeniedDialog(context);
    } else if (status.isPermanentlyDenied) {
      // If the permission is permanently denied, open app settings to enable it manually
      _openAppSettings(context);
    }
  }

  // Show dialog if permission is denied
  void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Notification Permission Denied"),
          content: const Text(
              "This app requires notification permissions to send you event updates. Would you like to enable notifications in settings?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _openAppSettings(context); // Open settings to manually grant permission
              },
              child: const Text("Go to Settings"),
            ),
          ],
        );
      },
    );
  }

  // Open app settings if permission is permanently denied
  void _openAppSettings(BuildContext context) async {
    await openAppSettings();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Opening app settings...")),
    );
  }
}
