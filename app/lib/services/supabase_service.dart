import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    final url = dotenv.env['SUPABASE_URL'] ?? 'https://zxclczrpyrslkmoqmwhg.supabase.co';
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

    if (url.isEmpty || anonKey.isEmpty) {
      debugPrint('Warning: SUPABASE_URL or SUPABASE_ANON_KEY not set in .env');
    }

    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
    debugPrint('Supabase initialized successfully.');
  }
}