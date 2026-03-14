import 'package:eth_url_parser/eth_url_parser.dart';

void main() {
  // Parse a simple Ethereum URL
  final request = EthUrlParser.parse(
    'ethereum:0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD',
  );
  print('Target address: ${request.targetAddress}');
  // Target address: 0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD

  // Parse a URL with parameters
  final transferRequest = EthUrlParser.parse(
    'ethereum:0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD/transfer?address=0xABCD&uint256=1',
  );
  print('Function: ${transferRequest.functionName}');
  // Function: transfer
  print('Parameters: ${transferRequest.parameters}');
  // Parameters: {address: 0xABCD, uint256: 1}

  // Build an Ethereum URL from a TransactionRequest
  final uri = EthUrlParser.build(
    TransactionRequest(
      targetAddress: '0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD',
      functionName: 'transfer',
      chainId: 1,
      parameters: {
        'address': '0xABCD',
        'uint256': '1',
      },
    ),
  );
  print('Built URI: $uri');
  // Built URI: ethereum:0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD@1/transfer?address=0xABCD&uint256=1
}
