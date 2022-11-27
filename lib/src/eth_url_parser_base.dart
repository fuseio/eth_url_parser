library eth_url_parser;

import 'package:decimal/decimal.dart';

import 'package:eth_url_parser/src/models/transaction_request.dart';
import 'package:eth_url_parser/src/query_string.dart';

class EthUrlParser {
  ///
  /// Parse an Ethereum URI according to ERC-831 and ERC-681
  ///
  /// @param  {string} uri string.
  ///
  /// @return [TransactionRequest]
  ///
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
        final Decimal amount = Decimal.parse(obj['parameters'][amountKey]);
        obj['parameters'][amountKey] = amount.toString();
        if (!amount.toDouble().isFinite) {
          throw Exception('Invalid amount');
        }
        if (amount < Decimal.zero) {
          throw Exception('Invalid amount');
        }
      }
    }

    return TransactionRequest.fromJson(obj);
  }

  ///
  /// Builds a valid Ethereum URI based on the initial parameters
  /// @param  [TransactionRequest]
  ///
  /// @return {string}
  ///
  static String build(TransactionRequest transactionRequest) {
    dynamic query;
    if (transactionRequest.parameters.isNotEmpty) {
      final amountKey =
          transactionRequest.functionName == 'transfer' ? 'uint256' : 'value';
      if (transactionRequest.parameters[amountKey] != null) {
        // This is weird. Scientific notation in JS is usually 2.014e+18
        // but the EIP 681 shows no "+" sign ¯\_(ツ)_/¯
        // source: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-681.md#semantics
        final int amount =
            int.parse(transactionRequest.parameters[amountKey], radix: 10);
        final String parsed = amount
            .toStringAsExponential()
            .replaceAll('+', '')
            .replaceAll('e0', '');
        transactionRequest = transactionRequest.copyWith(
            parameters: Map.from({
          ...transactionRequest.parameters,
          amountKey: parsed,
        }));
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
