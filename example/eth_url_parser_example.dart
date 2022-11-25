import 'package:eth_url_parser/eth_url_parser.dart';

void main() {
  final String uri = EthUrlParser.build(
    targetAddress: '0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD',
    functionName: 'transfer',
    parameters: {
      'address': '0x12345',
      'uint256': '1',
    },
  );
  print('uri $uri');
  final Map<String, dynamic> parameters = EthUrlParser.parse(
    'ethereum:0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD',
  );
  print('scheme ${parameters['scheme']}');
  print('targetAddress ${parameters['targetAddress']}');
}
