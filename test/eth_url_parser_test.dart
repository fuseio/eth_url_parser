import 'dart:convert';

import 'package:test/test.dart';
import 'package:eth_url_parser/eth_url_parser.dart';
import 'package:eth_url_parser/src/query_string.dart';

void main() {
  group('EthUrlParser.parse', () {
    test('parses URI with payload starting with 0x', () {
      expect(
        EthUrlParser.parse(
          'ethereum:0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD',
        ),
        TransactionRequest(
          scheme: 'ethereum',
          targetAddress: '0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD',
        ),
      );
    });

    test('parses URI with pay prefix', () {
      expect(
        EthUrlParser.parse(
          'ethereum:pay-0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD',
        ),
        TransactionRequest(
          scheme: 'ethereum',
          prefix: 'pay',
          targetAddress: '0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD',
        ),
      );
    });

    test('rejects non-pay prefix (only pay- is defined by EIP-681)', () {
      expect(
        () => EthUrlParser.parse(
          'ethereum:foo-0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD',
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('parses URI with a bare ENS name', () {
      expect(
        EthUrlParser.parse('ethereum:vitalik.eth'),
        TransactionRequest(
          scheme: 'ethereum',
          targetAddress: 'vitalik.eth',
        ),
      );
    });

    test('parses a dashed ENS name as the target, not a prefix', () {
      expect(
        EthUrlParser.parse(
          'ethereum:foo-doge-to-the-moon.eth',
        ),
        TransactionRequest(
          scheme: 'ethereum',
          targetAddress: 'foo-doge-to-the-moon.eth',
        ),
      );
    });

    test('parses pay-prefixed ENS name with chain id', () {
      expect(
        EthUrlParser.parse('ethereum:pay-vitalik.eth@1'),
        TransactionRequest(
          scheme: 'ethereum',
          prefix: 'pay',
          targetAddress: 'vitalik.eth',
          chainId: 1,
        ),
      );
    });

    test('parses URI with chain id', () {
      expect(
        EthUrlParser.parse(
          'ethereum:0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD@1',
        ),
        TransactionRequest(
          scheme: 'ethereum',
          targetAddress: '0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD',
          chainId: 1,
        ),
      );
    });

    test('parses the EIP-681 ERC20 token transfer example', () {
      expect(
        EthUrlParser.parse(
          'ethereum:0x89205A3A3b2A69De6Dbf7f01ED13B2108B2c43e7/transfer?address=0x8e23ee67d1332ad560396262c48ffbb01f93d052&uint256=1',
        ),
        TransactionRequest(
          scheme: 'ethereum',
          targetAddress: '0x89205A3A3b2A69De6Dbf7f01ED13B2108B2c43e7',
          functionName: 'transfer',
          parameters: {
            'address': '0x8e23ee67d1332ad560396262c48ffbb01f93d052',
            'uint256': '1',
          },
        ),
      );
    });

    test('parses the EIP-681 native payment example', () {
      expect(
        EthUrlParser.parse(
          'ethereum:0xfb6916095ca1df60bB79Ce92cE3Ea74c37c5d359?value=2.014e18',
        ),
        TransactionRequest(
          scheme: 'ethereum',
          targetAddress: '0xfb6916095ca1df60bB79Ce92cE3Ea74c37c5d359',
          parameters: {'value': '2014000000000000000'},
        ),
      );
    });

    test('parses URI with value and gas parameters', () {
      expect(
        EthUrlParser.parse(
          'ethereum:0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD?value=2.014e18&gas=10&gasLimit=21000&gasPrice=50',
        ),
        TransactionRequest(
          scheme: 'ethereum',
          targetAddress: '0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD',
          parameters: {
            'value': '2014000000000000000',
            'gas': '10',
            'gasLimit': '21000',
            'gasPrice': '50',
          },
        ),
      );
    });

    test('throws on non-ethereum scheme', () {
      expect(
        () => EthUrlParser.parse(
            'bitcoin:0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD'),
        throwsException,
      );
    });

    test('throws FormatException on short URI (less than 9 chars)', () {
      expect(
        () => EthUrlParser.parse('eth:0x1'),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException on invalid amount (NaN)', () {
      expect(
        () => EthUrlParser.parse(
          'ethereum:0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD?value=notanumber',
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('preserves wei above int64 exactly (10 ETH + 1 wei)', () {
      final result = EthUrlParser.parse(
        'ethereum:0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD?value=10000000000000000001',
      );
      expect(result.parameters['value'], '10000000000000000001');
    });

    test('preserves 1 ETH + 1 wei exactly', () {
      final result = EthUrlParser.parse(
        'ethereum:0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD?value=1000000000000000001',
      );
      expect(result.parameters['value'], '1000000000000000001');
    });

    test('accepts a leading + sign on value per the number grammar', () {
      final result = EthUrlParser.parse(
        'ethereum:0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD?value=+1e18',
      );
      expect(result.parameters['value'], '1000000000000000000');
    });

    test('rejects negative value', () {
      expect(
        () => EthUrlParser.parse(
          'ethereum:0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD?value=-1e18',
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects non-integer number (exponent smaller than decimals)', () {
      expect(
        () => EthUrlParser.parse(
          'ethereum:0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD?value=1.5e0',
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects 40-char non-hex address (no ENS fallback for 0x)', () {
      expect(
        () => EthUrlParser.parse(
          'ethereum:0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCZ',
        ),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => EthUrlParser.parse(
          'ethereum:0x1234_EADBEEF5678ABCD1234DEADBEEF5678ABCD',
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects hex address of the wrong length', () {
      expect(
        () => EthUrlParser.parse('ethereum:0x1234DEADBEEF'),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects non-numeric chain id', () {
      expect(
        () => EthUrlParser.parse(
          'ethereum:0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD@abc',
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects empty target', () {
      expect(
        () => EthUrlParser.parse('ethereum:'),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => EthUrlParser.parse('ethereum:pay-'),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects a target that is neither an address nor an ENS name', () {
      expect(
        () => EthUrlParser.parse('ethereum:notanaddress'),
        throwsA(isA<FormatException>()),
      );
    });

    test('validates the address parameter of a transfer', () {
      expect(
        () => EthUrlParser.parse(
          'ethereum:0x89205A3A3b2A69De6Dbf7f01ED13B2108B2c43e7/transfer?address=0x12345&uint256=1',
        ),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('EthUrlParser.build', () {
    test('builds URL with payload starting with 0x', () {
      expect(
        EthUrlParser.build(
          TransactionRequest(
            scheme: 'ethereum',
            targetAddress: '0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD',
          ),
        ),
        'ethereum:0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD',
      );
    });

    test('builds URL with pay prefix', () {
      expect(
        EthUrlParser.build(
          TransactionRequest(
            scheme: 'ethereum',
            prefix: 'pay',
            targetAddress: '0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD',
          ),
        ),
        'ethereum:pay-0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD',
      );
    });

    test('rejects non-pay prefix (only pay- is defined by EIP-681)', () {
      expect(
        () => EthUrlParser.build(
          TransactionRequest(
            scheme: 'ethereum',
            prefix: 'foo',
            targetAddress: '0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD',
          ),
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('builds URL with an ENS name', () {
      expect(
        EthUrlParser.build(
          TransactionRequest(
            scheme: 'ethereum',
            targetAddress: 'doge-to-the-moon.eth',
          ),
        ),
        'ethereum:doge-to-the-moon.eth',
      );
    });

    test('builds URL with chain id', () {
      expect(
        EthUrlParser.build(
          TransactionRequest(
            scheme: 'ethereum',
            targetAddress: '0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD',
            chainId: 1,
          ),
        ),
        'ethereum:0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD@1',
      );
    });

    test('builds URL for an ERC20 token transfer', () {
      expect(
        EthUrlParser.build(
          TransactionRequest(
            scheme: 'ethereum',
            targetAddress: '0x89205A3A3b2A69De6Dbf7f01ED13B2108B2c43e7',
            functionName: 'transfer',
            parameters: {
              'address': '0x8e23ee67d1332ad560396262c48ffbb01f93d052',
              'uint256': '1',
            },
          ),
        ),
        'ethereum:0x89205A3A3b2A69De6Dbf7f01ED13B2108B2c43e7/transfer?address=0x8e23ee67d1332ad560396262c48ffbb01f93d052&uint256=1',
      );
    });

    test('builds URL with value and gas parameters', () {
      expect(
        EthUrlParser.build(
          TransactionRequest(
            scheme: 'ethereum',
            targetAddress: '0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD',
            parameters: {
              'value': '2014000000000000000',
              'gas': '10',
              'gasLimit': '21000',
              'gasPrice': '50',
            },
          ),
        ),
        'ethereum:0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD?value=2.014e18&gas=10&gasLimit=21000&gasPrice=50',
      );
    });

    test('emits plain decimal when compression would lose wei (1 ETH + 1 wei)',
        () {
      expect(
        EthUrlParser.build(
          TransactionRequest(
            scheme: 'ethereum',
            targetAddress: '0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD',
            parameters: {'value': '1000000000000000001'},
          ),
        ),
        'ethereum:0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD?value=1000000000000000001',
      );
    });

    test('preserves wei above int64 exactly (10 ETH + 1 wei)', () {
      expect(
        EthUrlParser.build(
          TransactionRequest(
            scheme: 'ethereum',
            targetAddress: '0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD',
            parameters: {'value': '10000000000000000001'},
          ),
        ),
        'ethereum:0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD?value=10000000000000000001',
      );
    });

    test('rejects negative value', () {
      expect(
        () => EthUrlParser.build(
          TransactionRequest(
            scheme: 'ethereum',
            targetAddress: '0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD',
            parameters: {'value': '-1'},
          ),
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects an invalid target address', () {
      expect(
        () => EthUrlParser.build(
          TransactionRequest(
            scheme: 'ethereum',
            targetAddress: '0x12345',
          ),
        ),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('TransactionRequest', () {
    test('default constructor has correct defaults', () {
      final tx = TransactionRequest(targetAddress: '0xABC');
      expect(tx.scheme, 'ethereum');
      expect(tx.parameters, isEmpty);
      expect(tx.functionName, isNull);
      expect(tx.prefix, isNull);
      expect(tx.chainId, isNull);
    });

    test('fromJson with minimal fields', () {
      final tx = TransactionRequest.fromJson({
        'targetAddress': '0xABC',
      });
      expect(tx.scheme, 'ethereum');
      expect(tx.targetAddress, '0xABC');
      expect(tx.parameters, isEmpty);
    });

    test('fromJson with all fields', () {
      final tx = TransactionRequest.fromJson({
        'scheme': 'ethereum',
        'targetAddress': '0xABC',
        'functionName': 'transfer',
        'prefix': 'pay',
        'chainId': 1,
        'parameters': {'value': '100'},
      });
      expect(tx.scheme, 'ethereum');
      expect(tx.targetAddress, '0xABC');
      expect(tx.functionName, 'transfer');
      expect(tx.prefix, 'pay');
      expect(tx.chainId, 1);
      expect(tx.parameters, {'value': '100'});
    });

    test('toJson round-trip', () {
      final tx = TransactionRequest(
        targetAddress: '0xABC',
        functionName: 'transfer',
        prefix: 'pay',
        chainId: 42,
        parameters: {'value': '100'},
      );
      final json = tx.toJson();
      final restored = TransactionRequest.fromJson(json);
      expect(restored, tx);
    });

    test('copyWith changes one field', () {
      final tx = TransactionRequest(
        targetAddress: '0xABC',
        chainId: 1,
      );
      final modified = tx.copyWith(chainId: 42);
      expect(modified.chainId, 42);
      expect(modified.targetAddress, '0xABC');
    });

    test('copyWith preserves other fields', () {
      final tx = TransactionRequest(
        targetAddress: '0xABC',
        functionName: 'transfer',
        prefix: 'pay',
        chainId: 1,
        parameters: {'value': '100'},
      );
      final modified = tx.copyWith(chainId: 99);
      expect(modified.scheme, tx.scheme);
      expect(modified.targetAddress, tx.targetAddress);
      expect(modified.functionName, tx.functionName);
      expect(modified.prefix, tx.prefix);
      expect(modified.parameters, tx.parameters);
    });

    test('equality with same values', () {
      final a = TransactionRequest(
        targetAddress: '0xABC',
        chainId: 1,
        parameters: {'value': '100'},
      );
      final b = TransactionRequest(
        targetAddress: '0xABC',
        chainId: 1,
        parameters: {'value': '100'},
      );
      expect(a, b);
    });

    test('inequality with different values', () {
      final a = TransactionRequest(targetAddress: '0xABC', chainId: 1);
      final b = TransactionRequest(targetAddress: '0xABC', chainId: 2);
      expect(a, isNot(b));
    });

    test('hashCode consistency for equal objects', () {
      final a = TransactionRequest(
        targetAddress: '0xABC',
        chainId: 1,
        parameters: {'value': '100'},
      );
      final b = TransactionRequest(
        targetAddress: '0xABC',
        chainId: 1,
        parameters: {'value': '100'},
      );
      expect(a.hashCode, b.hashCode);
    });

    test('toString produces valid JSON', () {
      final tx = TransactionRequest(
        targetAddress: '0xABC',
        chainId: 1,
      );
      final str = tx.toString();
      final decoded = jsonDecode(str) as Map<String, dynamic>;
      expect(decoded['targetAddress'], '0xABC');
      expect(decoded['chainId'], 1);
    });
  });

  group('QueryString', () {
    test('parse empty string returns empty map', () {
      expect(QueryString.parse(''), isEmpty);
    });

    test('parse single param', () {
      expect(QueryString.parse('key=value'), {'key': 'value'});
    });

    test('parse multiple params', () {
      expect(
        QueryString.parse('a=1&b=2&c=3'),
        {'a': '1', 'b': '2', 'c': '3'},
      );
    });

    test('parse URL-encoded values', () {
      expect(
        QueryString.parse('name=hello%20world&path=%2Ffoo%2Fbar'),
        {'name': 'hello world', 'path': '/foo/bar'},
      );
    });

    test('parse keeps a literal plus sign (RFC 3986, not form encoding)', () {
      expect(
        QueryString.parse('value=+1e18'),
        {'value': '+1e18'},
      );
    });
  });

  group('Round-trip', () {
    test('parse(build(tx)) preserves simple address', () {
      final tx = TransactionRequest(
        targetAddress: '0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD',
      );
      final result = EthUrlParser.parse(EthUrlParser.build(tx));
      expect(result.targetAddress, tx.targetAddress);
      expect(result.scheme, tx.scheme);
    });

    test('parse(build(tx)) preserves chainId', () {
      final tx = TransactionRequest(
        targetAddress: '0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD',
        chainId: 42,
      );
      final result = EthUrlParser.parse(EthUrlParser.build(tx));
      expect(result.chainId, tx.chainId);
      expect(result.targetAddress, tx.targetAddress);
    });

    test('parse(build(tx)) preserves functionName and parameters', () {
      final tx = TransactionRequest(
        targetAddress: '0x89205A3A3b2A69De6Dbf7f01ED13B2108B2c43e7',
        functionName: 'transfer',
        parameters: {
          'address': '0x8e23ee67d1332ad560396262c48ffbb01f93d052',
          'uint256': '1',
        },
      );
      final result = EthUrlParser.parse(EthUrlParser.build(tx));
      expect(result.functionName, tx.functionName);
      expect(result.parameters['address'], tx.parameters['address']);
      expect(result.parameters['uint256'], tx.parameters['uint256']);
    });

    test('parse(build(tx)) preserves every wei on adversarial amounts', () {
      for (final wei in [
        '1000000000000000001',
        '10000000000000000001',
        '2014000000000000000',
      ]) {
        final tx = TransactionRequest(
          targetAddress: '0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD',
          parameters: {'value': wei},
        );
        final result = EthUrlParser.parse(EthUrlParser.build(tx));
        expect(result.parameters['value'], wei);
      }
    });

    test('build(parse(uri)) preserves the spec example URI', () {
      const uri =
          'ethereum:0xfb6916095ca1df60bB79Ce92cE3Ea74c37c5d359?value=2.014e18';
      expect(EthUrlParser.build(EthUrlParser.parse(uri)), uri);
    });
  });
}
