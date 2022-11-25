# eth_url_parser

eth_url_parser is translated from https://www.npmjs.com/package/eth-url-parser

Module that supports parsing / parsing of all the different ethereum standard urls: [ERC-681](https://eips.ethereum.org/EIPS/eip-681) and [ERC-831](https://eips.ethereum.org/EIPS/eip-831)

This module contains two functions:

## `EthUrlParser.parse(string)`

Takes in a string of an Ethereum URL and returns an object matching that URL according to the previously mentioned standards
The returned object looks like this:

```dart
{
    'scheme': 'ethereum',
    'targetAddress': '0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD', // ENS names are also supported!
    'chain_id': '1',
    'parameters': {
        'value': '2014000000000000000', // (in WEI)
        'gas': '45000', // can be also gasLimit
        'gasPrice': '50',
    }
}
```

## `EthUrlParser.build(object)`

Takes in an object representing the different parts of the ethereum url and returns a string representing a valid ethereum url

## Getting started

# Flutter

`$ flutter pub add eth_url_parser`

# Dart

`$ dart pub add eth_url_parser`

## Usage

```dart
import 'package:eth_url_parser/eth_url_parser.dart';

final Map<String, dynamic> parameters = EthUrlParser.parse(
  'ethereum:0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD',
);
print('${parameters['targetAddress']}');
// '0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD'

final String uri = EthUrlParser.build(
  targetAddress: '0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD',
  functionName: 'transfer',
  parameters: {
    'address': '0x12345',
    'uint256': '1',
  },
);
print('uri $uri');
// 'ethereum:0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD/transfer?address=0x12345&uint256=1'

```
