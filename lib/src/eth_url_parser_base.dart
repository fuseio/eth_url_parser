import 'package:eth_url_parser/src/models/transaction_request.dart';
import 'package:eth_url_parser/src/query_string.dart';

/// A Dart library for parsing and building Ethereum URIs as described in [EIP-681](https://eips.ethereum.org/EIPS/eip-681).
class EthUrlParser {
  // Static-only utility class; not meant to be instantiated.
  EthUrlParser._();

  /// Parses an Ethereum URI according to EIP-681.
  ///
  /// Amounts (`value`, or `uint256` for `transfer` calls, plus `gas`,
  /// `gasLimit` and `gasPrice`) are normalized to plain decimal wei strings
  /// using exact [BigInt] math, so scientific notation like `2.014e18` never
  /// loses precision.
  ///
  /// Throws a [FormatException] if the given [uri] is not a valid EIP-681
  /// Ethereum URI.
  ///
  /// ```dart
  /// final TransactionRequest transactionRequest = EthUrlParser.parse(
  ///   'ethereum:0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD?value=2.014e18&gas=10&gasLimit=21000&gasPrice=50',
  /// );
  /// print(transactionRequest.targetAddress); // "0x1234DEADBEEF5678ABCD1234DEADBEEF5678ABCD"
  /// ```
  static TransactionRequest parse(String uri) {
    if (!uri.startsWith('ethereum:')) {
      throw const FormatException('Not an Ethereum URI');
    }
    var rest = uri.substring('ethereum:'.length);

    // EIP-681: schema_prefix = "ethereum" ":" [ "pay-" ] — "pay" is the only
    // prefix the spec defines. Anything else is part of the target (ENS).
    String? prefix;
    if (rest.startsWith('pay-')) {
      prefix = 'pay';
      rest = rest.substring('pay-'.length);
    }

    String paramString = '';
    final queryIndex = rest.indexOf('?');
    if (queryIndex != -1) {
      paramString = rest.substring(queryIndex + 1);
      rest = rest.substring(0, queryIndex);
    }

    String? functionName;
    final slashIndex = rest.indexOf('/');
    if (slashIndex != -1) {
      functionName = Uri.decodeComponent(rest.substring(slashIndex + 1));
      rest = rest.substring(0, slashIndex);
      if (functionName.isEmpty) {
        throw const FormatException('Empty function name');
      }
    }

    int? chainId;
    final atIndex = rest.indexOf('@');
    if (atIndex != -1) {
      final chainIdString = rest.substring(atIndex + 1);
      rest = rest.substring(0, atIndex);
      // chain_id = 1*DIGIT
      if (!RegExp(r'^\d+$').hasMatch(chainIdString)) {
        throw FormatException('Invalid chain id: $chainIdString');
      }
      chainId = int.parse(chainIdString);
    }

    final targetAddress = _validateTargetAddress(rest);

    final Map<String, String> params = QueryString.parse(paramString);
    final Map<String, dynamic> parameters = Map<String, dynamic>.from(params);

    final amountKey = functionName == 'transfer' ? 'uint256' : 'value';
    for (final key in [amountKey, 'gas', 'gasLimit', 'gasPrice']) {
      final raw = parameters[key];
      if (raw != null) {
        final BigInt amount = _parseNumber(raw as String);
        if (amount < BigInt.zero) {
          throw FormatException('Invalid amount: $raw must not be negative');
        }
        parameters[key] = amount.toString();
      }
    }
    if (parameters['address'] != null) {
      _validateTargetAddress(parameters['address'] as String);
    }

    return TransactionRequest(
      scheme: 'ethereum',
      targetAddress: targetAddress,
      prefix: prefix,
      chainId: chainId,
      functionName: functionName,
      parameters: parameters,
    );
  }

  /// EIP-681: ethereum_address = ( "0x" 40*HEXDIG ) / ENS_NAME.
  ///
  /// Hexadecimal addresses take precedence over ENS names, so a target
  /// starting with 0x that is not a valid address is an error — never an ENS
  /// fallback. Addresses are 20 bytes, i.e. exactly 40 hex digits.
  static String _validateTargetAddress(String target) {
    if (target.startsWith('0x') || target.startsWith('0X')) {
      if (!RegExp(r'^0[xX][0-9a-fA-F]{40}$').hasMatch(target)) {
        throw FormatException('Invalid Ethereum address: $target');
      }
      return target;
    }
    // The spec leaves ENS_NAME open; require dot-separated non-empty labels
    // of [a-zA-Z0-9-] that don't start or end with a dash.
    final label = '[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?';
    if (!RegExp('^$label(\\.$label)+\$').hasMatch(target)) {
      throw FormatException(
          'Invalid target: $target is neither an Ethereum address nor an ENS name');
    }
    return target;
  }

  /// Parses the EIP-681 number grammar exactly, with no precision loss:
  ///
  ///     number = [ "-" / "+" ] *DIGIT [ "." 1*DIGIT ] [ ( "e" / "E" ) [ 1*DIGIT ] ]
  ///
  /// Only integer numbers are allowed, so the exponent must be greater than
  /// or equal to the number of decimals after the point.
  static BigInt _parseNumber(String input) {
    final match =
        RegExp(r'^([+-]?)(\d*)(?:\.(\d+))?(?:[eE](\d*))?$').firstMatch(input);
    if (match == null) {
      throw FormatException('Invalid number: $input');
    }
    final integerDigits = match.group(2)!;
    final decimalDigits = match.group(3) ?? '';
    if (integerDigits.isEmpty && decimalDigits.isEmpty) {
      throw FormatException('Invalid number: $input');
    }
    final exponent = int.parse('0${match.group(4) ?? ''}');
    if (exponent < decimalDigits.length) {
      throw FormatException(
          'Invalid number: $input — the exponent must be greater or equal to '
          'the number of decimals after the point');
    }
    final digits = BigInt.parse('0$integerDigits$decimalDigits');
    final magnitude =
        digits * BigInt.from(10).pow(exponent - decimalDigits.length);
    return match.group(1) == '-' ? -magnitude : magnitude;
  }

  /// Builds an Ethereum URI from a [TransactionRequest] object.
  ///
  /// The [TransactionRequest] object contains all the necessary information to build the URI,
  /// such as the scheme, target address, function name, and parameters.
  ///
  /// If the [TransactionRequest] object contains any parameters, they will be
  /// added to the URI as a query string. Amounts with at least three trailing
  /// zeros are emitted in the exponent notation EIP-681 suggests (`2.014e18`);
  /// all others stay plain decimal, so round-trips never lose a wei.
  ///
  /// Throws a [FormatException] if the prefix, target address, or amount is
  /// invalid.
  ///
  /// ```dart
  /// final transactionRequest = TransactionRequest(
  ///   scheme: 'ethereum',
  ///   targetAddress: '0x1234567890123456789012345678901234567890',
  ///   functionName: 'transfer',
  ///   parameters: {
  ///     'address': '0x0987654321098765432109876543210987654321',
  ///     'uint256': '1000000000000000000',
  ///   },
  /// );
  /// final uri = EthUrlParser.build(transactionRequest);
  /// ```
  static String build(TransactionRequest transactionRequest) {
    if (transactionRequest.prefix != null &&
        transactionRequest.prefix != 'pay') {
      throw FormatException(
          'Invalid prefix: ${transactionRequest.prefix} — EIP-681 only defines "pay-"');
    }
    _validateTargetAddress(transactionRequest.targetAddress);

    String? query;
    if (transactionRequest.parameters.isNotEmpty) {
      final amountKey =
          transactionRequest.functionName == 'transfer' ? 'uint256' : 'value';
      if (transactionRequest.parameters[amountKey] != null) {
        final BigInt amount =
            _parseNumber(transactionRequest.parameters[amountKey] as String);
        if (amount < BigInt.zero) {
          throw FormatException('Invalid amount: $amount must not be negative');
        }
        transactionRequest = transactionRequest.copyWith(
          parameters: Map.from({
            ...transactionRequest.parameters,
            amountKey: _formatNumber(amount),
          }),
        );
      }
      query = Uri(
        queryParameters: transactionRequest.parameters,
      ).toString();
    }
    final uri =
        '${transactionRequest.scheme}:${transactionRequest.prefix != null ? '${transactionRequest.prefix}-' : ''}${transactionRequest.targetAddress}${transactionRequest.chainId != null ? '@${transactionRequest.chainId}' : ''}${transactionRequest.functionName != null ? '/${transactionRequest.functionName}' : ''}${query ?? ''}';

    return uri;
  }

  /// Formats an amount losslessly, preferring the exponent notation EIP-681
  /// suggests: trailing zeros compress into an exponent (2014000000000000000
  /// becomes 2.014e18); a number they can't compress stays plain decimal, so
  /// no wei is ever dropped. The EIP shows exponents without a '+' sign.
  static String _formatNumber(BigInt amount) {
    final digits = amount.toString();
    var zeros = 0;
    while (
        zeros < digits.length - 1 && digits[digits.length - 1 - zeros] == '0') {
      zeros++;
    }
    if (zeros < 3) {
      return digits;
    }
    final mantissa = digits.substring(0, digits.length - zeros);
    final exponent = digits.length - 1;
    if (mantissa.length == 1) {
      return '${mantissa}e$exponent';
    }
    return '${mantissa[0]}.${mantissa.substring(1)}e$exponent';
  }
}
