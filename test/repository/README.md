# Flutter Unit Testing with Riverpod and Mockito

このプロジェクトは、FlutterアプリケーションでRiverpodとMockitoを使用したユニットテストの実装例を示しています。

## プロジェクト構造

```
lib/
├── domain/
│   ├── model/
│   │   └── user_state.dart     # ユーザーモデル
│   └── repository/
│       └── user_repository.dart # リポジトリインターフェース
├── infrastructure/
│   └── dio.dart                # Dioクライアントの設定
└── data/
    └── repository/
        └── user_repository_impl.dart # リポジトリの実装

test/
└── repository/
    └── user_repository_test.dart     # リポジトリのテスト
```

## 依存関係

```yaml
dependencies:
  flutter:
    sdk: flutter
  dio: ^5.0.0
  flutter_riverpod: ^2.0.0
  riverpod_annotation: ^2.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4
  build_runner: ^2.4.7
```

## テストの概要

このテストスイートでは、以下の主要なコンポーネントをテストしています：

1. **UserRepository**
   - ユーザー一覧の取得
   - エラーハンドリング

### テストのセットアップ

```dart
@GenerateMocks([Dio])
import 'user_repository_test.mocks.dart';

void main() {
  late MockDio mockDio;
  late ProviderContainer container;

  setUp(() {
    mockDio = MockDio();
    container = ProviderContainer(
      overrides: [
        dioProvider.overrideWithValue(mockDio),
      ],
    );
  });
}
```

### テストケース

1. **正常系テスト**
   - ユーザー一覧の取得が成功する場合
   - レスポンスの検証
   - API呼び出し回数の確認

2. **異常系テスト**
   - 404エラーの場合の例外処理
   - 不正なレスポンス形式の処理

## テストの実行方法

1. モッククラスの生成
```bash
flutter pub run build_runner build
```

2. テストの実行
```bash
flutter test test/repository/user_repository_test.dart
```

## 重要なポイント

### Mockitoの使用

- `@GenerateMocks([Dio])`アノテーションでモッククラスを生成
- `when`を使用して期待する動作を定義
- `verify`で呼び出しを検証

```dart
when(mockDio.get(
  any,
  options: anyNamed('options'),
)).thenAnswer((_) async => Response(...));

verify(mockDio.get(
  any,
  options: anyNamed('options'),
)).called(1);
```

### Riverpodとの統合

- `ProviderContainer`を使用してテスト環境を構築
- プロバイダーのオーバーライドでモックを注入

```dart
container = ProviderContainer(
  overrides: [
    dioProvider.overrideWithValue(mockDio),
  ],
);
```

### アサーション

- `expect`を使用して結果を検証
- 型チェック、データ内容、例外の確認

```dart
expect(result, isA<List<UserState>>());
expect(result.length, 2);
expect(result[0].name, 'Test User 1');
```

## ベストプラクティス

1. **テストの独立性**
   - 各テストは独立して実行可能
   - `setUp`と`tearDown`で適切な初期化と後処理

2. **モックの適切な使用**
   - 外部依存をモック化
   - 必要最小限のモック設定

3. **エラーケースのカバー**
   - 正常系と異常系の両方をテスト
   - 境界値のテスト

4. **可読性の確保**
   - 明確なテスト名
   - テストの構造化（given-when-then）

## 注意点

- モッククラスは自動生成されるため、変更後は`build_runner`の実行が必要
- `ProviderContainer`は必ず`dispose()`する
- 非同期処理のテストは`async/await`を適切に使用

-----

このケースでは、**スタブ**が正しい用語です。理由を説明しましょう：

1. 現在のコードの特徴：
- テストでは、Dioの`get`メソッドの振る舞いを定義し、特定のレスポンスを返すように設定しています
- メソッドの呼び出しを検証（verify）していますが、これは副次的な要素です
- 主な目的は、特定の入力に対して定義された出力を返すことです

```dart
// これはスタブの例です
when(mockDio.get(
  any,
  options: anyNamed('options'),
)).thenAnswer((_) async => Response(
  data: mockResponse,
  statusCode: 200,
  requestOptions: RequestOptions(path: '/'),
));
```

2. スタブとモックの違い：

スタブ：
- 決まった応答を返すように設定
- 状態検証（state verification）に使用
- テスト対象の間接的な入力を提供

モック：
- メソッドの呼び出しを検証
- 振る舞い検証（behavior verification）に使用
- インタラクションのテストが主目的

3. より適切な書き方：

```dart
test('getUsers returns list of users on successful response', () async {
  // スタブの設定
  when(mockDio.get(
    any,
    options: anyNamed('options'),
  )).thenAnswer((_) async => Response(
    data: mockResponse,
    statusCode: 200,
    requestOptions: RequestOptions(path: '/'),
  ));

  final repository = container.read(userRepositoryProvider);
  final result = await repository.getUsers();

  // 結果の検証（これが主目的）
  expect(result, isA<List<UserState>>());
  expect(result.length, 2);
  expect(result[0].name, 'Test User 1');
  
  // verify は省略可能（この場合は必須ではない）
});
```

このコードは主にスタブとして機能していますが、必要に応じてモックの機能も利用できる形になっています。しかし、主な目的から見るとスタブとして扱うのが適切です。