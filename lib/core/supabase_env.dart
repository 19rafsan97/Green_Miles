import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseEnv {
  SupabaseEnv._();

  static String _url = '';
  static String _anonKey = '';
  static String _emailRedirectTo = '';

  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
    _url = dotenv.env['SUPABASE_URL']?.trim() ?? '';
    _anonKey = dotenv.env['SUPABASE_ANON_KEY']?.trim() ?? '';
    _emailRedirectTo = dotenv.env['SUPABASE_EMAIL_REDIRECT_TO']?.trim() ?? '';
  }

  static String get url => _url;
  static String get anonKey => _anonKey;
  static String? get emailRedirectTo =>
      _emailRedirectTo.isEmpty ? null : _emailRedirectTo;
  static String? get projectRef {
    if (_url.isEmpty) {
      return null;
    }
    final uri = Uri.tryParse(_url);
    final host = uri?.host ?? '';
    if (host.isEmpty) {
      return null;
    }
    final firstSegment = host.split('.').first;
    return firstSegment.isEmpty ? null : firstSegment;
  }

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
