## Simple build number

Basic BLoC way to handle build number version with ability to handle different cases inside of your UI.

## Supported build load types

- ARGS - uses `--dart-define` args to specify build version. Can be used like
  so `flutter run --dart-define=APP_BUILD_NUMBER=1.0.0`

- FILE - uses `.txt` files from which we read version number. This file can be either static or populated during CI/CD

## Possible build states

Since apart from setting and keeping build number version somewhere the main point of this utility si to propagate
information whether application version has changed or not.

For that after every successful version number load there is `state` information inside of `BuildNumberLoadedState`
state. This attribute contains information where our application is.

1. **PRISTINE** - clean installation
2. **STALE** - user has already used application with specified version
3. **FRESH** - application has been updated, and it's users first time with new version

## Example

For example checkout example application

**NOTE:** If you are loading builder number using file make sure to include lib path inside your __pubspec.yaml__

**NOTE:** Make sure that you initialize lognito using `Lognito.init()` before using this utility.
