import 'package:flutter/material.dart';
import 'package:practice_4/presentation/counter_flow/counter_model.dart';
import 'package:practice_4/presentation/counter_flow/counter_page/counter_screen.dart';
import 'package:provider/provider.dart';

class CounterPage extends StatelessWidget {
  final CounterModel model;
  const CounterPage({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: model,
      child: CounterScreen(),
    );
  }
}
