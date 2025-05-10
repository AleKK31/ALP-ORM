import 'package:supabase/supabase.dart';

class DartSupabaseOrm {
  final SupabaseClient client;

  DartSupabaseOrm({required String supabaseUrl, required String supabaseKey})
    : client = SupabaseClient(supabaseUrl, supabaseKey);

  // Este método será preenchido pelo generator
  T repository<T>() {
    throw UnimplementedError('Repository should be generated');
  }
}
