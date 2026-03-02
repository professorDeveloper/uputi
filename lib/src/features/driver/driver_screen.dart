import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DriverScreen extends StatefulWidget {
  const DriverScreen({super.key});

  @override
  State<DriverScreen> createState() => _DriverScreenState();
}

class _DriverScreenState extends State<DriverScreen> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: const Center(
        child: Text('Driver Screen'),
      ),
    );
  }
}
