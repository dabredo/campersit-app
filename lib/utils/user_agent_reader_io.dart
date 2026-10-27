import 'dart:io' show Platform;

String resolveUserAgent() {
  return 'Campersit App (${Platform.operatingSystem} ${Platform.operatingSystemVersion})';
}
