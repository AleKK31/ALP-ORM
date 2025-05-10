import 'package:dart_supabase_orm/dart_supabase_orm.dart';

@Entity(tableName: 'users')
class AppUser {
  @PrimaryKey()
  final int? id;

  @Column(name: 'user_name')
  final String name;

  @Column()
  final String email;

  AppUser({this.id, required this.name, required this.email});

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as int,
      name: json['user_name'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'user_name': name, 'email': email};
  }
}
