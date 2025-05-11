# Dart Supabase ORM

## Resumo do Funcionamento

1. O usuário define entidades usando anotações como `@Entity`, `@Column`, etc.
2. O `build_runner` gera automaticamente:
   - Um `UserRepository` com métodos CRUD
   - Mapeamento entre objetos Dart e tabelas do Supabase
3. O usuário só precisa chamar os métodos gerados, sem escrever SQL manualmente

## Arquitetura

- **Annotations**: Define metadados (annotations)
- **Generator**: Cria o Builder para processar as annotations
- **dart_supabase_orm** e **orm.dart**: Classe principal do ORM

## Explicação das Partes Principais

### Annotations

Definimos `@Entity`, `@Column`, etc. para marcar as classes e propriedades.

### Code Generation

Usamos `source_gen` e `analyzer` para:

- Identificar classes marcadas com `@Entity`
- Extrair informações sobre propriedades e suas anotações
- Gerar código Dart que implementa o repositório com métodos CRUD

## Exemplo de Uso

1. Definição de entidades
   > test/example/user.dart

2. Operações
   > test/dart_supabase_orm_test.dart

## Comandos

**Instalação de dependências**  
```bash
dart pub get
```

**Geração de código**  
```bash
dart run build_runner build
```

**Reexecutar o build (quando houver conflitos)**  
```bash
dart run build_runner build --delete-conflicting-outputs
```

**Executar exemplos/testes**  
```bash
dart run test/dart_supabase_orm_test.dart
```

---

[Notion](https://www.notion.so/ORM-DART-1ee66b19d44e8020add5f90a4dae8703)
