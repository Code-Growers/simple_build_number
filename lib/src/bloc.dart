import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_build_number/src/enums.dart';
import 'package:simple_build_number/src/event.dart';
import 'package:simple_build_number/src/state.dart';
import 'package:simple_build_number/src/logger.dart';
import 'package:simple_build_number/src/constants.dart';
import 'package:simple_build_number/src/repository.dart';

const String argsAppVersion = String.fromEnvironment(kAppVersionArgsKey,
    defaultValue: kAppVersionDefaultValue);

class BuildNumberBloc extends Bloc<BuildNumberEvent, BuildNumberState> {
  final BuildNumberRepository buildNumberRepository;
  final String? defaultVersion;

  BuildNumberBloc(this.buildNumberRepository,
      [this.defaultVersion = kAppVersionDefaultValue])
      : super(BuildNumberEmptyState());

  @override
  Stream<BuildNumberState> mapEventToState(BuildNumberEvent event) async* {
    if (event is BuildNumberArgumentsLoadEvent) {
      if (argsAppVersion.isEmpty) {
        yield* _yieldDefaultPristineState(BuildLoadType.args);
      } else {
        yield* _yieldLoadedStateForType(BuildLoadType.args, argsAppVersion);
      }
    }
    if (event is BuildNumberFileLoadEvent) {
      final String? fileVersionNumber =
          await _loadFilerVersionNumber(event.filePath);
      if (fileVersionNumber == null || fileVersionNumber.isEmpty) {
        yield* _yieldDefaultPristineState(BuildLoadType.file);
      } else {
        yield* _yieldLoadedStateForType(BuildLoadType.file, fileVersionNumber);
      }
    }
    if (event is BuildNumberSetStateEvent && state is BuildNumberLoadedState) {
      final BuildNumberLoadedState currentState =
          state as BuildNumberLoadedState;
      yield currentState.copyWith(state: event.state, version: event.version);
    }
  }

  Stream<BuildNumberState> _yieldLoadedStateForType(
      BuildLoadType loadType, String? resolvedVersion) async* {
    final BuildState buildState = await _getBuildState(resolvedVersion);
    _logLoadedBuildNumber(loadType, buildState);
    yield BuildNumberLoadedState(state: buildState, version: resolvedVersion);
    buildNumberRepository.setVersion(resolvedVersion);
  }

  Stream<BuildNumberState> _yieldDefaultPristineState(
      BuildLoadType loadType) async* {
    logger.i('${describeEnum(loadType)} build number value is nil or empty.');
    logger.i('Setting default version pristine state.');
    yield BuildNumberLoadedState(
        state: BuildState.pristine, version: defaultVersion);
  }

  Future<BuildState> _getBuildState(String? externalVersionNumber) async {
    await buildNumberRepository.ready;
    final String? storageVersionNumber = buildNumberRepository.getVersion();
    logger.i('Local storage build version loaded with: $storageVersionNumber');
    final BuildState buildState = storageVersionNumber == externalVersionNumber
        ? BuildState.stale
        : BuildState.fresh;
    return buildState;
  }

  Future<String?> _loadFilerVersionNumber(String filePath) async {
    try {
      return await rootBundle.loadString(filePath);
    } catch (e) {
      logger.e(
          'Getting build number from ${describeEnum(BuildLoadType.file)} has FAILED with: ${e.toString()}');
      return null;
    }
  }

  void _logLoadedBuildNumber(BuildLoadType loadType, BuildState buildState) {
    logger.i(
        'Loaded build ${describeEnum(loadType)} with ${describeEnum(buildState)} state');
  }
}
