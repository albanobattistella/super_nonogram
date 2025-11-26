import 'package:stow_plain/stow_plain.dart';

final stows = Stows();

class Stows {
  static bool isVolatile = true;

  final currentLevel = PlainStow('currentLevel', 1, volatile: isVolatile);

  final hyperlegibleFont = PlainStow(
    'hyperlegibleFont',
    false,
    volatile: isVolatile,
  );

  final useHapticFeedback = PlainStow(
    'useHapticFeedback',
    true,
    volatile: isVolatile,
  );
}
