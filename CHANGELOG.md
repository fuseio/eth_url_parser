## 0.2.0

Strict [EIP-681](https://eips.ethereum.org/EIPS/eip-681) compliance. Fixes
silent precision loss on the money path.

- **Fixed**: amounts are now parsed and formatted with `BigInt` — values above
  int64 (~9.22 ETH in wei) no longer lose wei silently through `num.parse`
- **Fixed**: `build` no longer corrupts amounts via lossy
  `toStringAsExponential` — trailing zeros compress into an exact exponent
  (`2014000000000000000` → `2.014e18`), anything else stays plain decimal
- **Fixed**: addresses are validated as exactly 40 hex digits; non-hex
  40-character strings are rejected, and a `0x` payload never falls back to
  ENS (hex takes precedence per the spec)
- **Added**: bare ENS targets (`ethereum:vitalik.eth`,
  `ethereum:doge-to-the-moon.eth`) parse per the spec grammar
- **Added**: the scientific-notation number grammar is enforced exactly —
  the exponent must be ≥ the number of decimals (`1.5e0` is rejected)
- **Breaking**: only the spec-defined `pay-` prefix is accepted; arbitrary
  ERC-831 prefixes (`foo-`) now throw
- **Breaking**: all malformed input throws `FormatException` with a
  descriptive message (previously a mix of bare `Exception` and raw
  `RangeError` on short input)
- **Breaking**: `QueryString.parse` uses strict RFC 3986 percent-decoding;
  `+` is a literal plus (the number grammar's sign), not a space
- Validated `chainId` as decimal digits and the `transfer` `address`
  parameter as a valid address or ENS name

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
