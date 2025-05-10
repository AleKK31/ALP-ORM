import 'package:dart_supabase_orm/dart_supabase_orm.dart';

import 'example/user.dart';
import 'example/user.orm_builder.g.part';

void main() async {
  // 1. Inicialize o BD do ORM
  final orm = DartSupabaseOrm(
    supabaseUrl: 'https://hrvsxgzdqtkbjcbgzkjz.supabase.co',
    supabaseKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhydnN4Z3pkcXRrYmpjYmd6a2p6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY4NDI4MTcsImV4cCI6MjA2MjQxODgxN30.x1luyo73b213LTGNsTU039IuE29PxJA91wJxpJwSOfc',
  );

  // 2. Crie uma instância do repositório
  final userRepo = AppUserRepository(orm.client);

  // 3. Teste as operações CRUD
  print('===== TESTE DO ORM =====');

  // CREATE
  final newUser = await userRepo.insert(
    AppUser(name: 'Test user', email: 'test@example.com'),
  );
  print('User criado: ${newUser.name} ${newUser.id}');

  // READ
  final fetchedUser = await userRepo.findById(newUser.id);
  print('User recuperado: ${fetchedUser?.email}');

  final allUsers = await userRepo.findAll();

  // UPDATE
  final updatedUserStream = userRepo.subscribeToChanges();
  updatedUserStream.listen((users) {
    if (users.isNotEmpty) {
      print('User atualizado: ${users.first.name}');
    } else {
      print('Nenhum usuário atualizado.');
    }
  });

  // DELETE
  await userRepo.delete(newUser.id);
  print('User deletado');

  print('=== TESTE FINALIZADO ===');

  return;
}
