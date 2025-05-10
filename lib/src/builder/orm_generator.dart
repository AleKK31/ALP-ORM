import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:source_gen/source_gen.dart';
import 'package:dart_style/dart_style.dart';
import '../annotations.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

class OrmGenerator extends GeneratorForAnnotation<Entity> {
  @override
  Future<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        '@Entity só pode ser usado em classes.',
      );
    }

    final className = element.name;
    final tableName =
        annotation.peek('tableName')?.stringValue ?? _toSnakeCase(className);

    final library = await buildStep.resolver.libraryFor(
      AssetId.resolve(element.source!.uri, from: buildStep.inputId),
    );

    final fields =
        element.fields
            .where((f) => !f.isStatic)
            .map((field) {
              final columnAnn = TypeChecker.fromRuntime(
                Column,
              ).firstAnnotationOf(field);
              final ignoreAnn = TypeChecker.fromRuntime(
                Ignore,
              ).firstAnnotationOf(field);
              final isPrimaryKey =
                  TypeChecker.fromRuntime(
                    PrimaryKey,
                  ).firstAnnotationOf(field) !=
                  null;

              if (ignoreAnn != null) return null;

              final columnName =
                  columnAnn != null
                      ? ConstantReader(columnAnn).peek('name')?.stringValue ??
                          _toSnakeCase(field.name)
                      : _toSnakeCase(field.name);

              return _FieldInfo(
                name: field.name,
                columnName: columnName,
                type: field.type.getDisplayString(withNullability: false),
                isPrimaryKey: isPrimaryKey,
              );
            })
            .where((f) => f != null)
            .toList();

    final repositoryCode = '''
      // @dart=3.0
      import 'package:supabase/supabase.dart';
      import '${element.source!.uri.toFilePath()}'; // Corrigido para usar file path
      
      class ${className}Repository {
        final SupabaseClient _client;
        ${className}Repository(this._client);
        
        ${_generateCrudMethods(className, tableName, fields)}
        ${_generateRealtimeMethods(className, tableName, fields)}
      }
    ''';

    return repositoryCode; // Sem formatação, mas funcional
  }

  String _toSnakeCase(String input) =>
      input
          .replaceAllMapped(
            RegExp(r'(?<=[a-z])[A-Z]'),
            (m) => '_${m.group(0)!.toLowerCase()}',
          )
          .toLowerCase();

  String _generateCrudMethods(
    String className,
    String tableName,
    List<_FieldInfo?> fields,
  ) {
    final primaryKey = fields.firstWhere((f) => f?.isPrimaryKey ?? false);
    return '''
      Future<${className}?> findById(dynamic id) async {
        final data = await _client.from('$tableName').select().eq('${primaryKey?.columnName}', id).single();
        return data != null ? ${className}.fromJson(data as Map<String, dynamic>) : null;
      }
      
      Future<List<${className}>> findAll() async {
        final data = await _client.from('$tableName').select();
        return (data as List).map<${className}>((e) => ${className}.fromJson(e as Map<String, dynamic>)).toList();
      }
      
      Future<${className}> insert(${className} entity) async {
        final data = await _client.from('$tableName').insert(entity.toJson()).select().single();
        return ${className}.fromJson(data as Map<String, dynamic>);
      }
      
      Future<void> delete(dynamic id) async {
        await _client.from('$tableName').delete().eq('${primaryKey?.columnName}', id);
      }
    ''';
  }

  String _generateRealtimeMethods(
    String className,
    String tableName,
    List<_FieldInfo?> fields,
  ) {
    return '''
      Stream<List<${className}>> subscribeToChanges() {
        return _client
            .from('$tableName')
            .stream(primaryKey: ['${fields.firstWhere((f) => f?.isPrimaryKey ?? false)?.columnName}'])
            .map((data) => (data as List).map<${className}>((e) => ${className}.fromJson(e as Map<String, dynamic>)).toList());
      }
    ''';
  }

  Builder ormBuilder(BuilderOptions options) {
    return SharedPartBuilder([OrmGenerator()], 'orm_builder');
  }
}

class _FieldInfo {
  final String name;
  final String columnName;
  final String type;
  final bool isPrimaryKey;
  _FieldInfo({
    required this.name,
    required this.columnName,
    required this.type,
    required this.isPrimaryKey,
  });
}

Generator ormGenerator() => OrmGenerator();

Builder ormBuilder(BuilderOptions options) =>
    SharedPartBuilder([ormGenerator()], 'orm_builder');
