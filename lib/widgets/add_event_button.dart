import 'package:flutter/material.dart';

class AddEventButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AddEventButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: Colors.teal,
      child: const Icon(Icons.add),
    );
  }
}
