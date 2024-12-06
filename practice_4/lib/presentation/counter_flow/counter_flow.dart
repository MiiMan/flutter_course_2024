import 'package:flutter/material.dart';
import 'package:practice_4/presentation/counter_flow/counter_model.dart';
import 'package:practice_4/presentation/counter_flow/home_page/home_page.dart';

class CounterFlow extends StatelessWidget {
  final CounterModel model = CounterModel(10);

  CounterFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return HomePage(model: model);
  }
}
