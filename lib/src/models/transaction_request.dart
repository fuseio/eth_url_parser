import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_request.freezed.dart';
part 'transaction_request.g.dart';

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
@freezed
class TransactionRequest with _$TransactionRequest {
  /// Creates a new transaction request.
  ///
  /// [scheme] represents the blockchain scheme, default is 'ethereum'.
  /// [targetAddress] is the blockchain address the transaction is directed to.
  /// [functionName] is the name of the function to be called in the smart contract (optional).
  /// [prefix] can be used to add any prefix data needed for the transaction (optional).
  /// [chainId] is the ID of the blockchain network (optional).
  /// [parameters] is a map of parameters to be sent in the transaction (optional).
  factory TransactionRequest({
    @Default('ethereum') String scheme,
    required String targetAddress,
    String? functionName,
    String? prefix,
    int? chainId,
    @Default({}) Map<String, dynamic> parameters,
  }) = _TransactionRequest;

  /// Creates a new transaction request from a JSON object.
  ///
  /// [json] is a map containing the JSON data.
  factory TransactionRequest.fromJson(Map<String, dynamic> json) =>
      _$TransactionRequestFromJson(json);
}
