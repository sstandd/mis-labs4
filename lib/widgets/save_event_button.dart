import 'package:flutter/material.dart';

class SaveEventButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SaveEventButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.save, size: 20),
        label: const Text(
          "Save Event",
          style: TextStyle(fontSize: 18),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }
}
