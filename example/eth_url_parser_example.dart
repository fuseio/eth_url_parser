import 'package:eth_url_parser/eth_url_parser.dart';

void main() {
  final TransactionRequest transactionRequest = EthUrlParser.parse(
    'ethereum:0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD',
  );
  print(transactionRequest.targetAddress);
  final String uri = EthUrlParser.build(
    TransactionRequest(
      targetAddress: '0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD',
      functionName: 'transfer',
      parameters: {
        'address': '0x12345',
        'uint256': '1',
      },
    ),
  );
  print('URL Format for Transaction Requests $uri');
}
