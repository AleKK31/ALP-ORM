import 'package:dart_supabase_orm/dart_supabase_orm.dart';

@Entity(tableName: 'users')
class AppUser {
  @PrimaryKey()
  final int? id;

  @Column(name: 'name')
  final String name;

  @Column()
  final String email;

  AppUser({this.id, required this.name, required this.email});

  AppUser copyWith({int? id, String? name, String? email}) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
    );
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'email': email};
  }
}
