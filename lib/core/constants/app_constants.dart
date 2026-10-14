import 'package:flutter/foundation.dart';

class AppConstants {
  AppConstants._();

  static const String appName = 'Christmas Planner';
  static const String appVersion = '1.0.0';

  /// Compile-time Supabase settings. The debug defaults are the standard
  /// local stack from `make db` (ports in supabase/config.toml).
  static const String supabaseUrl = kDebugMode
      ? String.fromEnvironment(
          'SUPABASE_URL',
          defaultValue: 'http://localhost:56321',
        )
      : String.fromEnvironment('SUPABASE_URL');

  static const String supabaseAnonKey = kDebugMode
      ? String.fromEnvironment(
          'SUPABASE_ANON_KEY',
          defaultValue:
              'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0',
        )
      : String.fromEnvironment('SUPABASE_ANON_KEY');

  static const int minPasswordLength = 8;
  static const int maxNameLength = 100;
}
