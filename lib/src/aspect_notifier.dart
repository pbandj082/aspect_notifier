import 'package:flutter/material.dart';

abstract class AspectNotifier<T> extends ChangeNotifier {
  final _aspectListeners = <ValueSetter<Set<T>>>[];

  void addAspectListener(ValueSetter<Set<T>> listener) {
    _aspectListeners.add(listener);
  }

  void removeAspectListener(ValueSetter<Set<T>> listener) {
    _aspectListeners.removeWhere((e) => e == listener);
  }

  void notifyAspectListeners(Set<T> dependencies) {
    for (final listener in _aspectListeners) {
      listener(dependencies);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _aspectListeners.clear();
    super.dispose();
  }
}
