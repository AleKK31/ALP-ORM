library dart_supabase_orm.annotations;

class Entity {
  final String? tableName;

  const Entity({this.tableName});
}

class PrimaryKey {
  const PrimaryKey();
}

class Column {
  final String? name;

  const Column({this.name});
}

class Ignore {
  const Ignore();
}
