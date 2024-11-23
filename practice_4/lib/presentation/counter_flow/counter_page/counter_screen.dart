import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../counter_model.dart';

class CounterScreen extends StatelessWidget {
  const CounterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    CounterModel model = Provider.of(context, listen: true);

    return Scaffold(
      body: Column(
        children: [
          TextButton(
              onPressed: model.counterSuperIncrement,
              child: Text('+5')
          ),
          TextButton(
              onPressed: model.counterSuperDecrement,
              child: Text('-5')
          )
        ],
      ),
    );
  }
}
