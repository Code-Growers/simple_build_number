import 'package:localstorage/localstorage.dart';

class BuildNumberRepository {
  static String buildNumberVersionKey = 'build_number_version';

  LocalStorage? storage;

  BuildNumberRepository({String? storageKey})
      : storage = new LocalStorage(storageKey ?? 'build_number_storage');

  Future<void> get ready => storage!.ready;

  void setVersion(String? version) =>
      storage!.setItem(BuildNumberRepository.buildNumberVersionKey, version);

  String? getVersion() =>
      storage!.getItem(BuildNumberRepository.buildNumberVersionKey);
}
