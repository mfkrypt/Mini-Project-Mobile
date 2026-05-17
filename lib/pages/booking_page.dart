import 'package:flutter/material.dart';

class BookingPage extends StatelessWidget {
  const BookingPage({super.key, required this.boothName});

  final String boothName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book $boothName'),
      ),
      body: Center(
        child: Text(
          'Booking page for $boothName',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}