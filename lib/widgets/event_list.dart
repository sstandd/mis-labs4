import 'package:flutter/material.dart';
import '../models/event_model.dart';

class EventList extends StatelessWidget {
  final List<Event> events;
  final Function(Event) onEventTapped;

  const EventList({
    super.key,
    required this.events,
    required this.onEventTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: events.isEmpty
          ? const Center(
        child: Text(
          "No events for this day.",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text(
                event.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "${event.dateTime}",
                style: const TextStyle(color: Colors.grey),
              ),
              leading: const Icon(Icons.event, color: Colors.teal),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () => onEventTapped(event),
            ),
          );
        },
      ),
    );
  }
}
