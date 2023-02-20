library eth_url_parser;

import 'package:eth_url_parser/src/models/transaction_request.dart';
import 'package:eth_url_parser/src/query_string.dart';

/// A Dart library for parsing and building Ethereum URIs as described in [EIP-681](https://eips.ethereum.org/EIPS/eip-681).
class EthUrlParser {
  /// Parse an Ethereum URI according to ERC-831 and ERC-681
  ///
  /// Throws an [Exception] if the given [uri] is not a valid Ethereum URI or if
  /// it cannot be parsed.
  ///
  /// ```dart
  /// final TransactionRequest transactionRequest = EthUrlParser.parse(
  ///   'ethereum:0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD?value=2.014e18&gas=10&gasLimit=21000&gasPrice=50',
  /// );
  /// print(transactionRequest.targetAddress); // "0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD"
  /// ```
  static TransactionRequest parse(String uri) {
    if (uri.substring(0, 9) != 'ethereum:') {
      throw Exception('Not an Ethereum URI');
    }

    String? prefix;
    String addressRegex = '(0x[\\w]{40})';

    if (uri.substring(9, 11).toLowerCase() == '0x') {
      prefix = null;
    } else {
      final cutOff = uri.indexOf('-', 9);
      if (cutOff == -1) {
        throw Exception('Missing prefix');
      }
      prefix = uri.substring(9, cutOff);
      final rest = uri.substring(cutOff + 1);
      if (rest.substring(0, 2).toLowerCase() != '0x') {
        addressRegex =
            '([a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9].[a-zA-Z]{2,})';
      }
    }

    final fullRegex =
        '^ethereum:($prefix-)?$addressRegex\\@?([\\w]*)*\\/?([\\w]*)*';
    final exp = RegExp(fullRegex);
    final List<RegExpMatch> data = exp.allMatches(uri).toList();
    if (data.isEmpty) {
      throw Exception("Couldn't not parse the url");
    }

    dynamic parameters = uri.split('?');
    parameters = parameters.length > 1 ? parameters[1] : '';
    Map<dynamic, dynamic> params = QueryString.parse(parameters);

    final Map<String, dynamic> obj = {
      'scheme': 'ethereum',
      'targetAddress': data[0].group(2),
    };

    if (prefix != null) {
      obj.putIfAbsent('prefix', () => prefix);
    }

    if (data[0].group(3) != null) {
      obj.putIfAbsent('chainId', () => int.parse(data[0].group(3)!));
    }

    if (data[0].group(4) != null) {
      obj.putIfAbsent('functionName', () => data[0].group(4));
    }

    if (params.isNotEmpty) {
      obj.putIfAbsent('parameters', () => Map<String, dynamic>.from(params));
      final amountKey = obj['functionName'] == 'transfer' ? 'uint256' : 'value';

      if (obj['parameters'][amountKey] != null) {
        final num amount = num.parse(obj['parameters'][amountKey]);
        String value;
        if (amount.toString().endsWith('.0')) {
          value = amount.toString().split('.').first;
        } else {
          value = amount.toString();
        }
        obj['parameters'][amountKey] = value;
        if (!amount.toDouble().isFinite) {
          throw Exception('Invalid amount');
        }
        if (amount < 0) {
          throw Exception('Invalid amount');
        }
      }
    }

    return TransactionRequest.fromJson(obj);
  }

  /// Builds an Ethereum URI from a [TransactionRequest] object.
  ///
  /// The [TransactionRequest] object contains all the necessary information to build the URI,
  /// such as the scheme, target address, function name, and parameters.
  ///
  /// If the [TransactionRequest] object contains any parameters, they will be added to the URI
  /// as a query string. The amount parameter will be converted to atomic units if necessary.
  ///
  /// Throws an [Exception] if the amount parameter is invalid.
  ///
  /// ```dart
  /// final transactionRequest = TransactionRequest(
  ///   scheme: 'ethereum',
  ///   targetAddress: '0x1234567890123456789012345678901234567890',
  ///   functionName: 'transfer',
  ///   parameters: {
  ///     'value': '1.23',
  ///     'address': '0x0987654321098765432109876543210987654321',
  ///   },
  /// );
  /// final uri = EthUrlParser.build(transactionRequest);
  /// ```
  static String build(TransactionRequest transactionRequest) {
    dynamic query;
    if (transactionRequest.parameters.isNotEmpty) {
      final amountKey =
          transactionRequest.functionName == 'transfer' ? 'uint256' : 'value';
      if (transactionRequest.parameters[amountKey] != null) {
        // This is weird. Scientific notation in JS is usually 2.014e+18
        // but the EIP 681 shows no "+" sign ¯\_(ツ)_/¯
        // source: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-681.md#semantics
        final num amount = num.parse(transactionRequest.parameters[amountKey]);
        final String atomicUnits = amount
            .toStringAsExponential()
            .replaceAll('+', '')
            .replaceAll('e0', '');
        transactionRequest = transactionRequest.copyWith(
          parameters: Map.from({
            ...transactionRequest.parameters,
            amountKey: atomicUnits,
          }),
        );
        if (!amount.toDouble().isFinite) {
          throw Exception('Invalid amount');
        }
        if (amount < 0) {
          throw Exception('Invalid amount');
        }
      }
      query = Uri(
        queryParameters: transactionRequest.parameters,
      ).toString();
    }
    final uri =
        '${transactionRequest.scheme}:${transactionRequest.prefix != null ? '${transactionRequest.prefix}-' : ''}${transactionRequest.targetAddress}${transactionRequest.chainId != null ? '@${transactionRequest.chainId}' : ''}${transactionRequest.functionName != null ? '/${transactionRequest.functionName}' : ''}${query ?? ''}';

    return uri;
  }
}
