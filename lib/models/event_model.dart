class Event {
  final String title;
  final DateTime dateTime;
  final double latitude;
  final double longitude;

  Event({
    required this.title,
    required this.dateTime,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'dateTime': dateTime.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  static Event fromMap(Map<String, dynamic> map) {
    return Event(
      title: map['title'],
      dateTime: DateTime.parse(map['dateTime']),
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }
}
