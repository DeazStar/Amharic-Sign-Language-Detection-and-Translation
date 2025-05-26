import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Home Page', style: Theme.of(context).textTheme.bodyMedium,),
    );
  }
}
