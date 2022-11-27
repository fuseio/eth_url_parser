import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_request.freezed.dart';
part 'transaction_request.g.dart';

@freezed
class TransactionRequest with _$TransactionRequest {
  factory TransactionRequest({
    @Default('ethereum') String scheme,
    required String targetAddress,
    String? functionName,
    String? prefix,
    int? chainId,
    @Default({}) Map<String, dynamic> parameters,
  }) = _TransactionRequest;

  factory TransactionRequest.fromJson(Map<String, dynamic> json) =>
      _$TransactionRequestFromJson(json);
}
