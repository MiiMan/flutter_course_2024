import 'package:flutter/material.dart';
import 'package:practice_4/presentation/counter_flow/counter_page/counter_page.dart';
import 'package:practice_4/presentation/counter_flow/counter_model.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    CounterModel model = Provider.of(context, listen: true);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Значение: ${model.counterValue}'),

            SizedBox(height: 15,),

            TextButton(
                onPressed: model.counterIncrement,
                child: Text('+1')
            ),

            TextButton(
                onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => CounterPage(model: model)
                    )
                ),
                child: Text('больше')
            )
          ],
        ),
      )
    );
  }
}
