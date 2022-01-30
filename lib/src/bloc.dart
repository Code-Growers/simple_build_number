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
      : super(BuildNumberEmptyState()) {
    on<BuildNumberArgumentsLoadEvent>(_handleArgumentsLoadEvent);
    on<BuildNumberFileLoadEvent>(_handleFileLoadEvent);
    on<BuildNumberSetStateEvent>(_handleBuildNumberSetStateEvent);
  }

  void _handleArgumentsLoadEvent(BuildNumberArgumentsLoadEvent event,
      Emitter<BuildNumberState> emit) async {
    if (argsAppVersion.isEmpty) {
      emit(await _yieldDefaultPristineState(BuildLoadType.args));
    } else {
      if (argsAppVersion == kAppVersionDefaultValue &&
          kAppVersionDefaultValue != defaultVersion) {
        emit(
            await _yieldLoadedStateForType(BuildLoadType.args, defaultVersion));
      } else {
        emit(
            await _yieldLoadedStateForType(BuildLoadType.args, argsAppVersion));
      }
    }
  }

  void _handleFileLoadEvent(
      BuildNumberFileLoadEvent event, Emitter<BuildNumberState> emit) async {
    final String? fileVersionNumber =
        await _loadFilerVersionNumber(event.filePath);
    if (fileVersionNumber == null || fileVersionNumber.isEmpty) {
      emit(await _yieldDefaultPristineState(BuildLoadType.file));
    } else {
      emit(await _yieldLoadedStateForType(
          BuildLoadType.file, fileVersionNumber));
    }
  }

  void _handleBuildNumberSetStateEvent(
      BuildNumberSetStateEvent event, Emitter<BuildNumberState> emit) async {
    if (state is BuildNumberLoadedState) {
      final BuildNumberLoadedState currentState =
          state as BuildNumberLoadedState;
      emit(currentState.copyWith(state: event.state, version: event.version));
    }
  }

  Future<BuildNumberState> _yieldLoadedStateForType(
      BuildLoadType loadType, String? resolvedVersion) async {
    final BuildState buildState = await _getBuildState(resolvedVersion);
    _logLoadedBuildNumber(loadType, buildState);
    buildNumberRepository.setVersion(resolvedVersion);
    return BuildNumberLoadedState(state: buildState, version: resolvedVersion);
  }

  Future<BuildNumberState> _yieldDefaultPristineState(
      BuildLoadType loadType) async {
    logger.i('${describeEnum(loadType)} build number value is nil or empty.');
    logger.i('Setting default version pristine state.');
    return BuildNumberLoadedState(
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
