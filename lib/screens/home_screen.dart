import 'package:flutter/material.dart';
import '../widgets/widget1.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: Center(
        child: MyCustomWidget(),
      ),
    );
  }
}