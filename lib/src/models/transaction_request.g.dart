// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_TransactionRequest _$$_TransactionRequestFromJson(
        Map<String, dynamic> json) =>
    _$_TransactionRequest(
      scheme: json['scheme'] as String? ?? 'ethereum',
      targetAddress: json['targetAddress'] as String,
      functionName: json['functionName'] as String?,
      prefix: json['prefix'] as String?,
      chainId: json['chainId'] as int?,
      parameters: json['parameters'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$$_TransactionRequestToJson(
        _$_TransactionRequest instance) =>
    <String, dynamic>{
      'scheme': instance.scheme,
      'targetAddress': instance.targetAddress,
      'functionName': instance.functionName,
      'prefix': instance.prefix,
      'chainId': instance.chainId,
      'parameters': instance.parameters,
    };
