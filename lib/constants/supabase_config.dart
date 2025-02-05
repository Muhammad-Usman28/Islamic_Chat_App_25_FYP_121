import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://ieafghhdubpnfdhbxomv.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImllYWZnaGhkdWJwbmZkaGJ4b212Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzg0MDU2OTcsImV4cCI6MjA1Mzk4MTY5N30.Y610LltjlcLlbeDK3cKhd_rZTYPVBmX9HcdYSgrH-z8';

  static Future<void> init() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
}
