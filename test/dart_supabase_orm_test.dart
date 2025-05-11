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
    AppUser(name: 'USER NAME', email: 'email@example.com'),
  );
  print('User criado: ${newUser.name} ${newUser.id}\n');

  // READ
  final fetchedUser = await userRepo.findById(newUser.id);
  print('User recuperado: ${fetchedUser?.email}\n');

  final allUsers = await userRepo.findAll();

  // UPDATE - Monitoramento de mudanças
  final updatedUserStream = userRepo.subscribeToChanges();
  updatedUserStream.listen((users) {
    if (users.isNotEmpty) {
      print('User atualizado (Uso de Stream): ${users.first.name}\n');
    } else {
      print('Nenhum usuário atualizado.');
    }
  });

  // UPDATE
  final userUpdate = await userRepo.findById(newUser.id);
  if (userUpdate != null) {
    final updatedUser = await userRepo.update(
      userUpdate.copyWith(name: 'Novo Nome'),
    );
    print('Usuário atualizado: id ${userUpdate.id}\n');
  }

  // DELETE
  //await userRepo.delete(newUser.id);
  //print('User deletado\n');

  // Com Stream
  final subscription = userRepo.subscribeToChanges().listen((usuarios) {
    print('Atualização recebida (STREAM): ${usuarios.length} usuários');
    usuarios.forEach((user) {
      print('${user.name} - ${user.email}');
    });
  });

  // Consulta com filtro LIKE
  final usersWithExampleEmail = await userRepo.query(
    where: {
      'email': {'like': '%@gmail.com%'},
    },
  );
  print('Usuários com email @example.com: ${usersWithExampleEmail.length}\n');
  print(
    'Usuários com email @example.com: ${usersWithExampleEmail.map((e) => e.email).toList()}\n',
  );

  // Ordenar por nome
  final usuariosOrdenadosNome = await userRepo.query(
    orderBy: 'name',
    ascending: true,
  );
  print(
    '\nUsuários ordenados por nome: ${usuariosOrdenadosNome.map((e) => e.name).toList()}\n',
  );

  final usuarios = await userRepo.query(
    where: {
      'name': {'ilike': '%test%'},
      'email': {'like': '%.com%'},
    },
    orderBy: 'name',
    ascending: true,
    limit: 5,
  );
  print('Usuários encontrados:');
  usuarios.forEach((user) {
    print('${user.id} - ${user.name} (${user.email})');
  });

  print('=== TESTE FINALIZADO ===');

  return;
}
