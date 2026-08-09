# eth_url_parser

A Dart library for parsing and building Ethereum URLs according to [ERC-681](https://eips.ethereum.org/EIPS/eip-681).

Originally translated from the JavaScript [eth-url-parser](https://www.npmjs.com/package/eth-url-parser) package.

## Features

- Strict EIP-681 grammar: only the spec-defined `pay-` prefix, addresses of
  exactly 40 hex digits, bare ENS targets (`ethereum:vitalik.eth`)
- Exact amount handling via `BigInt` — no precision loss at any magnitude,
  in either direction (parse or build)
- Parse Ethereum URIs into strongly-typed `TransactionRequest` objects
- Build valid Ethereum URIs from `TransactionRequest` objects
- Supports ERC-681 parameters: `value`, `gas`, `gasLimit`, `gasPrice`
- Supports ERC-20 `transfer` function calls
- Chain ID support
- All malformed input throws `FormatException` with a descriptive message
- No code generation required -- pure Dart

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  eth_url_parser: ^0.2.0
```

## Usage

### Parsing an Ethereum URL

```dart
import 'package:eth_url_parser/eth_url_parser.dart';

final request = EthUrlParser.parse(
  'ethereum:0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD?value=2.014e18&gas=45000',
);
print(request.targetAddress); // 0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD
print(request.parameters['value']); // 2014000000000000000
print(request.parameters['gas']); // 45000
```

### Building an Ethereum URL

```dart
import 'package:eth_url_parser/eth_url_parser.dart';

final uri = EthUrlParser.build(
  TransactionRequest(
    targetAddress: '0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD',
    functionName: 'transfer',
    parameters: {
      'address': '0x8e23ee67d1332ad560396262c48ffbb01f93d052',
      'uint256': '1',
    },
  ),
);
print(uri);
// ethereum:0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD/transfer?address=0x8e23ee67d1332ad560396262c48ffbb01f93d052&uint256=1
```

### The `TransactionRequest` model

```dart
TransactionRequest(
  scheme: 'ethereum',       // default
  targetAddress: '0x...',   // required
  functionName: 'transfer', // optional
  prefix: 'pay',           // optional ('pay' is the only EIP-681 prefix)
  chainId: 1,              // optional
  parameters: {             // optional
    'value': '1000000000000000000',
    'gas': '21000',
  },
)
```

## API Reference

### `EthUrlParser.parse(String uri)`

Parses an Ethereum URI string and returns a `TransactionRequest`.
Throws a `FormatException` for invalid URIs.

### `EthUrlParser.build(TransactionRequest request)`

Builds an Ethereum URI string from a `TransactionRequest` object.
Amounts with at least three trailing zeros are emitted in the exponent
notation the EIP suggests (`2.014e18`); all others stay plain decimal, so
round-trips never lose a wei. Throws a `FormatException` for an invalid
prefix, target address, or amount.
