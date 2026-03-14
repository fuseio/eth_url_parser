## 0.1.0

- **Breaking**: Removed `freezed` and `json_serializable` code generation dependencies
- Migrated `TransactionRequest` to a hand-written `final class` with Dart 3.4+ features
- Updated SDK constraint to `>=3.4.0 <4.0.0`
- Typed `QueryString.parse` return to `Map<String, String>`
- Removed all `dynamic` types from public and internal APIs
- Expanded test suite from 2 to 34 tests covering error cases, model tests, and round-trips
- Updated `analysis_options.yaml` to remove code-gen excludes
- Updated `lints` to ^5.1.1 and `test` to latest

## 0.0.7

- Upgrade dependencies

## 0.0.6

- Update all outdated dependencies
- Add DartDoc comments to model `TransactionRequest`

## 0.0.5

- dartdoc

## 0.0.4

- Upgrade dependencies

## 0.0.3

- Scientific notation conversion

## 0.0.2

- Added `TransactionRequest` model

## 0.0.1

- Initial version.
