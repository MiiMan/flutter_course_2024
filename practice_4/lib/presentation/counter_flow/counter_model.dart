import 'package:flutter/cupertino.dart';

class CounterModel extends ChangeNotifier {

  CounterModel(int counterValue) : _counterValue = counterValue;

  int _counterValue = 0;

  int get counterValue => _counterValue;

  void counterIncrement() {
    _counterValue += 1;
    notifyListeners();
  }

  void counterSuperIncrement() {
    _counterValue += 5;
    notifyListeners();
  }

  void counterSuperDecrement() {
    _counterValue -= 5;
    notifyListeners();
  }
}