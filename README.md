## Features

This package is extension of InheritedModel and InheritedNotifier.

## Getting started

You execute this command in project.

'''
flutter pub add aspect_notifier
'''

and better to register the useful snippet.

```dart
class $NAME$ extends InheritedAspectNotifier<$ASPECT$> {
  const $NAME$({
    Key? key,
    required $NOTIFIER$ notifier,
    required Widget child,
  }) : super(key: key, notifier: notifier, child: child);

  static $NOTIFIER$ of(BuildContext context, {
    Set<$ASPECT$>? dependencies,
  }) {
    return InheritedAspectNotifier.inheritFrom<$NAME$>(
      context,
      dependencies: dependencies,
    ).notifier as $NOTIFIER$;
  }
}
```


## Usage

This is example for simple counter App.

```dart
import 'package:aspect_notifier/aspect_notifier.dart';
import 'package:flutter/material.dart';

enum ModelAspect {
  counter,
}

class Model extends AspectNotifier<ModelAspect> {
  int count = 0;

  void increment() {
    count++;
    notifyAspectListeners({ModelAspect.counter});
  }
}

class ModelScope extends InheritedAspectNotifier<ModelAspect> {
  const ModelScope({
    Key? key,
    required Model notifier,
    required Widget child,
  }) : super(key: key, notifier: notifier, child: child);

  static Model of(
      BuildContext context, {
        Set<ModelAspect>? dependencies,
      }) {
    return InheritedAspectNotifier.inheritFrom<ModelScope>(
      context,
      dependencies: dependencies,
    )!
        .notifier as Model;
  }
}

class CounterText extends StatefulWidget {
  const CounterText({Key? key}) : super(key: key);

  @override
  _CounterTextState createState() => _CounterTextState();
}

class _CounterTextState extends State<CounterText> {
  late Model _model;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _model = ModelScope.of(
      context,
      dependencies: {ModelAspect.counter},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Text('${_model.count}');
  }
}

class CounterView extends StatefulWidget {
  const CounterView({Key? key}) : super(key: key);

  @override
  _CounterViewState createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView> {
  late final Model _model;

  @override
  void initState() {
    super.initState();
    _model = Model();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ModelScope(
        notifier: _model,
        child: Scaffold(
          body: const Center(child: CounterText()),
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () {
              _model.increment();
            },
          ),
        ),
      ),
    );
  }
}

```
