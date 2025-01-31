import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../models/event_model.dart';
import '../widgets/event_title_input.dart';
import '../widgets/map_picker.dart';
import '../widgets/save_event_button.dart';
import '../widgets/selected_date_display.dart';

class AddEventScreen extends StatefulWidget {
  final Function(Event) onEventAdded;
  final DateTime selectedDate;

  const AddEventScreen({super.key, required this.onEventAdded, required this.selectedDate});

  @override
  _AddEventScreenState createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _titleController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  double _latitude = 0.0;
  double _longitude = 0.0;
  late CameraPosition _initialCameraPosition;
  bool isMapInitialized = false;
  late DateTime _eventDateTime;

  @override
  void initState() {
    super.initState();
    _eventDateTime = widget.selectedDate;
    _getCurrentLocation();
    _timeController.text = _formatTime(_eventDateTime);
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location permission is required to access your location.")),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
      _initialCameraPosition = CameraPosition(
        target: LatLng(_latitude, _longitude),
        zoom: 12.0,
      );
      isMapInitialized = true;
    });
  }

  void _onMapTapped(LatLng position) {
    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
    });
  }

  Future<void> _selectTime() async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_eventDateTime),
    );

    if (selectedTime != null) {
      setState(() {
        _eventDateTime = DateTime(
          _eventDateTime.year,
          _eventDateTime.month,
          _eventDateTime.day,
          selectedTime.hour,
          selectedTime.minute,
        );
        _timeController.text = _formatTime(_eventDateTime);
      });
    }
  }

  String _formatTime(DateTime dateTime) {
    final String hours = dateTime.hour.toString().padLeft(2, '0');
    final String minutes = dateTime.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  void _saveEvent() {
    if (_titleController.text.isEmpty || _latitude == 0.0 || _longitude == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields.")),
      );
      return;
    }

    final event = Event(
      title: _titleController.text,
      dateTime: _eventDateTime,
      latitude: _latitude,
      longitude: _longitude,
    );
    widget.onEventAdded(event);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Event"),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EventTitleInput(controller: _titleController),
            const SizedBox(height: 20),
            SelectedDateDisplay(selectedDate: _eventDateTime),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: Colors.grey.shade400,
                  width: 1.0,
                ),
              ),
              child: TextFormField(
                controller: _timeController,
                readOnly: true,
                onTap: _selectTime,
                decoration: InputDecoration(
                  labelText: 'Event Time',
                  prefixIcon: const Icon(Icons.access_time),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                  border: InputBorder.none,
                  fillColor: Colors.grey[200],
                )
              ),
            ),
            const SizedBox(height: 20),
            MapPicker(
              isMapInitialized: isMapInitialized,
              initialCameraPosition: isMapInitialized ? _initialCameraPosition : null,
              onMapTapped: _onMapTapped,
              latitude: _latitude,
              longitude: _longitude,
            ),
            const SizedBox(height: 20),
            SaveEventButton(onPressed: _saveEvent),
          ],
        ),
      ),
    );
  }
}
