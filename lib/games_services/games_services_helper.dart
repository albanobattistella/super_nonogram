import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:games_services/games_services.dart';

@pragma('vm:platform-const')
final bool isGamesServicesSupported =
    !kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS);

Future<T?> runAfterGamesSignIn<T>(FutureOr<T> Function() callback) async {
  if (!isGamesServicesSupported) return null;
  await GamesServices.signIn();
  if (!await GamesServices.isSignedIn) return null;
  return await callback();
}
