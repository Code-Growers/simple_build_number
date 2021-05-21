import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:simple_build_number/src/enums.dart';

abstract class BuildNumberState extends Equatable {
  @override
  List<dynamic> get props => <dynamic>[];
}

class BuildNumberEmptyState extends BuildNumberState {
  @override
  String toString() => 'BuildNumberEmptyState';
}

class BuildNumberLoadedState extends BuildNumberState {
  final String? version;
  final BuildState state;

  BuildNumberLoadedState({required this.state, this.version});

  BuildNumberLoadedState copyWith({BuildState? state, String? version}) =>
      BuildNumberLoadedState(
          state: state ?? this.state, version: version ?? this.version);

  @override
  String toString() =>
      'BuildNumberLoadedState {state: ${describeEnum(state)}, version: $version}';

  @override
  List<dynamic> get props => <dynamic>[state, version];
}
