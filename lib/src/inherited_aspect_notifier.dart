import 'package:flutter/material.dart';

import 'aspect_notifier.dart';

abstract class InheritedAspectNotifier<T> extends InheritedWidget {
  const InheritedAspectNotifier({
    Key? key,
    required this.notifier,
    required Widget child,
  }) : super(key: key, child: child);

  final AspectNotifier<T> notifier;

  @override
  bool updateShouldNotify(covariant InheritedAspectNotifier oldWidget) {
    return oldWidget.notifier != notifier;
  }

  @override
  InheritedElement createElement() => _InheritedAspectNotifierElement<T>(this);

  static U? inheritFrom<U extends InheritedAspectNotifier>(
    BuildContext context, {
    Set<Object>? dependencies,
  }) {
    return context.dependOnInheritedWidgetOfExactType<U>(aspect: dependencies);
  }
}

class _InheritedAspectNotifierElement<T> extends InheritedElement {
  _InheritedAspectNotifierElement(InheritedAspectNotifier<T> widget)
      : super(widget) {
    widget.notifier.addAspectListener(_handleUpdate);
  }

  final _updatedDependencies = <T>{};
  bool _dirty = false;

  @override
  InheritedAspectNotifier<T> get widget =>
      super.widget as InheritedAspectNotifier<T>;

  @override
  void update(InheritedAspectNotifier<T> newWidget) {
    if (newWidget.notifier != widget.notifier) {
      widget.notifier.removeAspectListener(_handleUpdate);
      newWidget.notifier.addAspectListener(_handleUpdate);
    }
    super.update(newWidget);
  }

  @override
  Widget build() {
    if (_dirty) {
      notifyClients(widget);
    }
    return super.build();
  }

  @override
  void notifyClients(InheritedAspectNotifier oldWidget) {
    super.notifyClients(oldWidget);
    _dirty = false;
    _updatedDependencies.clear();
  }

  @override
  void updateDependencies(Element dependent, Object? aspect) {
    final dependencies = getDependencies(dependent) as Set<T>?;
    assert(aspect is Set?);
    final additionalDependencies = aspect as Set<T>?;
    if (dependencies != null && dependencies.isEmpty) {
      return;
    }

    if (additionalDependencies == null) {
      setDependencies(dependent, <T>{});
    } else {
      setDependencies(
        dependent,
        (dependencies ?? <T>{})..addAll(additionalDependencies),
      );
    }
  }

  @override
  void notifyDependent(InheritedAspectNotifier oldWidget, Element dependent) {
    final dependencies = getDependencies(dependent) as Set<Object>?;
    if (dependencies == null) {
      return;
    }
    final intersection = dependencies.intersection(_updatedDependencies);
    if (intersection.isNotEmpty) {
      dependent.didChangeDependencies();
    }
  }

  @override
  void unmount() {
    widget.notifier.removeAspectListener(_handleUpdate);
    super.unmount();
  }

  void _handleUpdate(Set<T> dependencies) {
    _dirty = true;
    _updatedDependencies.addAll(dependencies);
    markNeedsBuild();
  }
}
