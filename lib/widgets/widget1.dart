import 'package:flutter/material.dart';

class MyCustomWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          'Hello, World!',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}