import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://rupsgajtvzyxqjvlawnk.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ1cHNnYWp0dnp5eHFqdmxhd25rIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzkxMjY5NTksImV4cCI6MjA1NDcwMjk1OX0.TSahxE1zvtQFARoumAW6ZXGO8-ETXSRx88uKPeQ7IsQ';

  static Future<void> init() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
}
