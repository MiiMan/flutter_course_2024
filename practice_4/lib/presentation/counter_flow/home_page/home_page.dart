import 'package:flutter/material.dart';
import 'package:practice_4/presentation/counter_flow/counter_model.dart';
import 'package:practice_4/presentation/counter_flow/home_page/home_screen.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  final CounterModel model;

  const HomePage({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: model,
      child: HomeScreen(),
    );
  }
}
