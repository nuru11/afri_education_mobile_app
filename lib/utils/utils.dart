export 'constants/constants.dart';
export 'access_override.dart';
export 'offline_content_access.dart';
export 'init.dart';
export 'snackbar_utils.dart';
export 'share_utils.dart';
export 'navigation_utils.dart';
export 'image_picker_permissions.dart';
import 'package:logger/logger.dart';
// export 'files.dart';
// export 'notifications.dart';
// export 'network.dart';
// export 'config.dart';
// export 'extensions.dart';
// export 'package:image_picker/image_picker.dart';

final logger = Logger(
  printer: PrettyPrinter(
    // methodCount: 5, // Number of method calls to be displayed
    // errorMethodCount: 8, // Number of method calls if stacktrace is provided
    // lineLength: 120, // Width of the output
    colors: true, // Colorful log messages
    printEmojis: true, // Print an emoji for each log message
    dateTimeFormat:
        DateTimeFormat.dateAndTime, // Should each log print contain a timestamp
  ),
);

String toAgoDate(DateTime date) {
  final now = DateTime.now();
  final diff = now.difference(date);
  if (diff.inMinutes < 1) {
    return 'just now';
  } else if (diff.inHours < 1) {
    return '${diff.inMinutes}m';
  } else if (diff.inDays < 1) {
    return '${diff.inHours}h';
  } else {
    return '${diff.inDays}d';
  }
}
