import 'package:equatable/equatable.dart';
import 'package:simple_build_number/src/enums.dart';

abstract class BuildNumberEvent extends Equatable {
  @override
  List<dynamic> get props => <Object>[];
}

class BuildNumberArgumentsLoadEvent extends BuildNumberEvent {
  @override
  String toString() => 'BuildNumberArgumentsLoadEvent';
}

class BuildNumberFileLoadEvent extends BuildNumberEvent {
  final String filePath;

  BuildNumberFileLoadEvent(this.filePath);

  @override
  String toString() => 'BuildNumberFileLoadEvent {filePath: $filePath}';

  @override
  List<Object> get props => <Object>[filePath];
}

class BuildNumberSetStateEvent extends BuildNumberEvent {
  final String? version;
  final BuildState? state;

  BuildNumberSetStateEvent({this.version, this.state});

  @override
  String toString() =>
      'BuildNumberSetStateEvent {version: $version, state: $state}';

  @override
  List<Object?> get props => <Object?>[version, state];
}
