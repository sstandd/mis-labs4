import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/event_model.dart';

class CalendarView extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime selectedDay;
  final CalendarFormat calendarFormat;
  final List<Event> events;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(CalendarFormat) onFormatChanged;

  const CalendarView({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.calendarFormat,
    required this.events,
    required this.onDaySelected,
    required this.onFormatChanged,
  });

  List<Event> _getEventsForDay(DateTime day) {
    return events.where((event) {
      return event.dateTime.year == day.year &&
          event.dateTime.month == day.month &&
          event.dateTime.day == day.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2025, 12, 31),
        focusedDay: focusedDay,
        selectedDayPredicate: (day) => isSameDay(day, selectedDay),
        onDaySelected: onDaySelected,
        calendarFormat: calendarFormat,
        onFormatChanged: onFormatChanged,
        eventLoader: _getEventsForDay,
        calendarStyle: CalendarStyle(
          selectedDecoration: BoxDecoration(
            color: Colors.teal,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: Colors.teal.shade300,
            shape: BoxShape.circle,
          ),
          markerDecoration: const BoxDecoration(
            color: Colors.teal,
            shape: BoxShape.circle,
          ),
          markersMaxCount: 3,
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: true,
          titleCentered: true,
          titleTextStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          formatButtonTextStyle: const TextStyle(color: Colors.white),
          formatButtonDecoration: BoxDecoration(
            color: Colors.teal,
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
    );
  }
}
