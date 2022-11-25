import "package:test/test.dart";

import 'package:eth_url_parser/eth_url_parser.dart';

void main() {
  test('EthUrlParser.parse', () {
    expect(
      EthUrlParser.parse(
        'ethereum:0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD',
      ),
      {
        'scheme': 'ethereum',
        'targetAddress': '0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD'
      },
      reason: 'Can parse URI with payload starting with `0x`',
    );

    expect(
      EthUrlParser.parse(
        'ethereum:pay-0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD',
      ),
      {
        'scheme': 'ethereum',
        'prefix': 'pay',
        'targetAddress': '0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD',
      },
      reason: 'Can parse URI with payload starting with `0x` and `pay` prefix',
    );

    expect(
      EthUrlParser.parse(
        'ethereum:foo-0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD',
      ),
      {
        'scheme': 'ethereum',
        'prefix': 'foo',
        'targetAddress': '0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD',
      },
      reason: 'Can parse URI with payload starting with `0x` and `foo` prefix',
    );

    expect(
      EthUrlParser.parse(
        'ethereum:foo-doge-to-the-moon.eth',
      ),
      {
        'scheme': 'ethereum',
        'prefix': 'foo',
        'targetAddress': 'doge-to-the-moon.eth',
      },
      reason: 'Can parse URI with an ENS name',
    );

    expect(
      EthUrlParser.parse(
        'ethereum:0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD@42',
      ),
      {
        'scheme': 'ethereum',
        'targetAddress': '0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD',
        'chain_id': '42',
      },
      reason: 'Can parse URI with an ENS name',
    );

    expect(
      EthUrlParser.parse(
        'ethereum:0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD/transfer?address=0x12345&uint256=1',
      ),
      {
        'scheme': 'ethereum',
        'targetAddress': '0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD',
        'functionName': 'transfer',
        'parameters': {
          'address': '0x12345',
          'uint256': '1',
        }
      },
      reason: 'Can parse an ERC20 token transfer',
    );

    expect(
      EthUrlParser.parse(
          'ethereum:0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD?value=2.014e18&gas=10&gasLimit=21000&gasPrice=50'),
      {
        'scheme': 'ethereum',
        'targetAddress': '0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD',
        'parameters': {
          'value': '2014000000000000000',
          'gas': '10',
          'gasLimit': '21000',
          'gasPrice': '50',
        }
      },
      reason: 'Can parse a url with value and gas parameters',
    );
  });

  test(
    'EthUrlParser.build',
    () {
      expect(
        EthUrlParser.build(
          scheme: 'ethereum',
          targetAddress: '0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD',
        ),
        'ethereum:0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD',
        reason: 'Can build a URL with payload starting with `0x`',
      );

      expect(
        EthUrlParser.build(
          scheme: 'ethereum',
          prefix: 'pay',
          targetAddress: '0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD',
        ),
        'ethereum:pay-0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD',
        reason:
            'Can build a URL with payload starting with `0x` and `pay` prefix',
      );

      expect(
        EthUrlParser.build(
          scheme: 'ethereum',
          prefix: 'foo',
          targetAddress: '0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD',
        ),
        'ethereum:foo-0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD',
        reason:
            'Can build a URL with payload starting with `0x` and `foo` prefix',
      );

      expect(
        EthUrlParser.build(
          scheme: 'ethereum',
          prefix: 'foo',
          targetAddress: 'doge-to-the-moon.eth',
        ),
        'ethereum:foo-doge-to-the-moon.eth',
        reason: 'Can build a URL with an ENS name',
      );

      expect(
          EthUrlParser.build(
            scheme: 'ethereum',
            targetAddress: '0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD',
            chainId: '42',
          ),
          'ethereum:0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD@42',
          reason: 'Can build a URL with chain id');

      expect(
        EthUrlParser.build(
          scheme: 'ethereum',
          targetAddress: '0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD',
          functionName: 'transfer',
          parameters: {
            'address': '0x12345',
            'uint256': '1',
          },
        ),
        'ethereum:0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD/transfer?address=0x12345&uint256=1',
        reason: 'Can build a URL for an ERC20 token transfer',
      );

      expect(
        EthUrlParser.build(
          scheme: 'ethereum',
          targetAddress: '0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD',
          parameters: {
            'value': '2014000000000000000',
            'gas': '10',
            'gasLimit': '21000',
            'gasPrice': '50',
          },
        ),
        'ethereum:0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD?value=2.014e18&gas=10&gasLimit=21000&gasPrice=50',
        reason: 'Can build a url with value and gas parameters',
      );
    },
  );
}
