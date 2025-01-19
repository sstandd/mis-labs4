import 'package:calendar_app/services/notification_service.dart';
import 'package:calendar_app/widgets/add_event_button.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../widgets/calendar_view.dart';
import '../widgets/event_list.dart';
import 'add_event_screen.dart';
import '../models/event_model.dart';
import 'event_details_screen.dart';

class CalendarScreen extends StatefulWidget {
  final List<Event> events;
  final Function(Event) onEventAdded;

  const CalendarScreen({
    super.key,
    required this.events,
    required this.onEventAdded,
  });

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  List<Event> _getEventsForDay(DateTime day) {
    return widget.events.where((event) {
      return event.dateTime.year == day.year &&
          event.dateTime.month == day.month &&
          event.dateTime.day == day.day;
    }).toList();
  }

  void _navigateToAddEventScreen(BuildContext context, DateTime selectedDay) async {
    final event = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEventScreen(
          onEventAdded: widget.onEventAdded,
          selectedDate: selectedDay,
        ),
      ),
    );

    if (event != null) {
      widget.onEventAdded(event);
    }
  }
  void _navigateToExamDetailsScreen(BuildContext context, Event event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExamDetailsScreen(event: event),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final selectedEvents = _getEventsForDay(_selectedDay);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Calendar"),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          CalendarView(
            focusedDay: _focusedDay,
            selectedDay: _selectedDay,
            calendarFormat: _calendarFormat,
            events: widget.events,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
          ),
          const SizedBox(height: 8),
          EventList(events: selectedEvents, onEventTapped: (Event event) {  _navigateToExamDetailsScreen(context, event); },),
        ],
      ),
      floatingActionButton: AddEventButton(
        onPressed: () => _navigateToAddEventScreen(context, _selectedDay),
      ),
    );
  }
}
