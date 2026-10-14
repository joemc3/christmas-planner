import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/logger.dart';
import 'exceptions.dart';

/// Runs a repository call, logs failures and maps them to the app's typed
/// exceptions. [what] names the action for the log and the message.
Future<T> guard<T>(String what, Future<T> Function() run) async {
  try {
    return await run();
  } on AuthenticationException {
    rethrow;
  } on PostgrestException catch (e) {
    AppLogger.error('Failed to $what', error: e);
    throw DatabaseException(message: e.message, error: e);
  } on AuthException catch (e) {
    AppLogger.error('Failed to $what', error: e);
    throw AuthenticationException(message: e.message, error: e);
  } catch (e, stackTrace) {
    AppLogger.error(
      'Unexpected error: $what',
      error: e,
      stackTrace: stackTrace,
    );
    throw DatabaseException(message: 'Failed to $what', error: e);
  }
}

/// The signed-in user's id, or an [AuthenticationException].
String requireUserId(SupabaseClient client) {
  final id = client.auth.currentUser?.id;
  if (id == null) {
    throw const AuthenticationException(message: 'User not authenticated');
  }
  return id;
}

/// Formats a DATE column value (no time, no zone).
String? dateColumn(DateTime? d) => d == null
    ? null
    : '${d.year.toString().padLeft(4, '0')}-'
          '${d.month.toString().padLeft(2, '0')}-'
          '${d.day.toString().padLeft(2, '0')}';

DateTime? parseDateColumn(Object? v) =>
    v == null ? null : DateTime.parse(v as String);
