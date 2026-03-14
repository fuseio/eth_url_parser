import 'dart:convert';

/// Represents a request to perform a transaction on a blockchain.
///
/// This class encapsulates the necessary information to perform a transaction
/// on a blockchain. It is designed to be flexible and can be used for different
/// blockchain schemes.
///
/// Example:
/// ```dart
/// var request = TransactionRequest(
///   targetAddress: '0x123...',
///   functionName: 'transfer',
///   parameters: {'value': '1.23'},
///   chainId: 122,
/// );
/// ```
final class TransactionRequest {
  /// The blockchain scheme, default is 'ethereum'.
  final String scheme;

  /// The blockchain address the transaction is directed to.
  final String targetAddress;

  /// The name of the function to be called in the smart contract (optional).
  final String? functionName;

  /// A prefix for the transaction (optional).
  final String? prefix;

  /// The ID of the blockchain network (optional).
  final int? chainId;

  /// A map of parameters to be sent in the transaction.
  final Map<String, dynamic> parameters;

  /// Creates a new transaction request.
  ///
  /// [scheme] represents the blockchain scheme, default is 'ethereum'.
  /// [targetAddress] is the blockchain address the transaction is directed to.
  /// [functionName] is the name of the function to be called in the smart contract (optional).
  /// [prefix] can be used to add any prefix data needed for the transaction (optional).
  /// [chainId] is the ID of the blockchain network (optional).
  /// [parameters] is a map of parameters to be sent in the transaction (optional).
  TransactionRequest({
    this.scheme = 'ethereum',
    required this.targetAddress,
    this.functionName,
    this.prefix,
    this.chainId,
    this.parameters = const {},
  });

  /// Creates a new transaction request from a JSON object.
  ///
  /// [json] is a map containing the JSON data.
  factory TransactionRequest.fromJson(Map<String, dynamic> json) {
    return TransactionRequest(
      scheme: json['scheme'] as String? ?? 'ethereum',
      targetAddress: json['targetAddress'] as String,
      functionName: json['functionName'] as String?,
      prefix: json['prefix'] as String?,
      chainId: json['chainId'] as int?,
      parameters: json['parameters'] != null
          ? Map<String, dynamic>.from(json['parameters'] as Map)
          : const {},
    );
  }

  /// Converts this transaction request to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'scheme': scheme,
      'targetAddress': targetAddress,
      if (functionName != null) 'functionName': functionName,
      if (prefix != null) 'prefix': prefix,
      if (chainId != null) 'chainId': chainId,
      if (parameters.isNotEmpty) 'parameters': parameters,
    };
  }

  /// Creates a copy of this transaction request with the given fields replaced.
  TransactionRequest copyWith({
    String? scheme,
    String? targetAddress,
    String? functionName,
    String? prefix,
    int? chainId,
    Map<String, dynamic>? parameters,
  }) {
    return TransactionRequest(
      scheme: scheme ?? this.scheme,
      targetAddress: targetAddress ?? this.targetAddress,
      functionName: functionName ?? this.functionName,
      prefix: prefix ?? this.prefix,
      chainId: chainId ?? this.chainId,
      parameters: parameters ?? this.parameters,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TransactionRequest) return false;
    return scheme == other.scheme &&
        targetAddress == other.targetAddress &&
        functionName == other.functionName &&
        prefix == other.prefix &&
        chainId == other.chainId &&
        _mapEquals(parameters, other.parameters);
  }

  @override
  int get hashCode => Object.hash(
        scheme,
        targetAddress,
        functionName,
        prefix,
        chainId,
        Object.hashAll(
            parameters.entries.map((e) => Object.hash(e.key, e.value))),
      );

  @override
  String toString() => jsonEncode(toJson());

  static bool _mapEquals(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
}
