// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'transaction_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

TransactionRequest _$TransactionRequestFromJson(Map<String, dynamic> json) {
  return _TransactionRequest.fromJson(json);
}

/// @nodoc
mixin _$TransactionRequest {
  String get scheme => throw _privateConstructorUsedError;
  String get targetAddress => throw _privateConstructorUsedError;
  String? get functionName => throw _privateConstructorUsedError;
  String? get prefix => throw _privateConstructorUsedError;
  int? get chainId => throw _privateConstructorUsedError;
  Map<String, dynamic> get parameters => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TransactionRequestCopyWith<TransactionRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TransactionRequestCopyWith<$Res> {
  factory $TransactionRequestCopyWith(
          TransactionRequest value, $Res Function(TransactionRequest) then) =
      _$TransactionRequestCopyWithImpl<$Res, TransactionRequest>;
  @useResult
  $Res call(
      {String scheme,
      String targetAddress,
      String? functionName,
      String? prefix,
      int? chainId,
      Map<String, dynamic> parameters});
}

/// @nodoc
class _$TransactionRequestCopyWithImpl<$Res, $Val extends TransactionRequest>
    implements $TransactionRequestCopyWith<$Res> {
  _$TransactionRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? scheme = null,
    Object? targetAddress = null,
    Object? functionName = freezed,
    Object? prefix = freezed,
    Object? chainId = freezed,
    Object? parameters = null,
  }) {
    return _then(_value.copyWith(
      scheme: null == scheme
          ? _value.scheme
          : scheme // ignore: cast_nullable_to_non_nullable
              as String,
      targetAddress: null == targetAddress
          ? _value.targetAddress
          : targetAddress // ignore: cast_nullable_to_non_nullable
              as String,
      functionName: freezed == functionName
          ? _value.functionName
          : functionName // ignore: cast_nullable_to_non_nullable
              as String?,
      prefix: freezed == prefix
          ? _value.prefix
          : prefix // ignore: cast_nullable_to_non_nullable
              as String?,
      chainId: freezed == chainId
          ? _value.chainId
          : chainId // ignore: cast_nullable_to_non_nullable
              as int?,
      parameters: null == parameters
          ? _value.parameters
          : parameters // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_TransactionRequestCopyWith<$Res>
    implements $TransactionRequestCopyWith<$Res> {
  factory _$$_TransactionRequestCopyWith(_$_TransactionRequest value,
          $Res Function(_$_TransactionRequest) then) =
      __$$_TransactionRequestCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String scheme,
      String targetAddress,
      String? functionName,
      String? prefix,
      int? chainId,
      Map<String, dynamic> parameters});
}

/// @nodoc
class __$$_TransactionRequestCopyWithImpl<$Res>
    extends _$TransactionRequestCopyWithImpl<$Res, _$_TransactionRequest>
    implements _$$_TransactionRequestCopyWith<$Res> {
  __$$_TransactionRequestCopyWithImpl(
      _$_TransactionRequest _value, $Res Function(_$_TransactionRequest) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? scheme = null,
    Object? targetAddress = null,
    Object? functionName = freezed,
    Object? prefix = freezed,
    Object? chainId = freezed,
    Object? parameters = null,
  }) {
    return _then(_$_TransactionRequest(
      scheme: null == scheme
          ? _value.scheme
          : scheme // ignore: cast_nullable_to_non_nullable
              as String,
      targetAddress: null == targetAddress
          ? _value.targetAddress
          : targetAddress // ignore: cast_nullable_to_non_nullable
              as String,
      functionName: freezed == functionName
          ? _value.functionName
          : functionName // ignore: cast_nullable_to_non_nullable
              as String?,
      prefix: freezed == prefix
          ? _value.prefix
          : prefix // ignore: cast_nullable_to_non_nullable
              as String?,
      chainId: freezed == chainId
          ? _value.chainId
          : chainId // ignore: cast_nullable_to_non_nullable
              as int?,
      parameters: null == parameters
          ? _value._parameters
          : parameters // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_TransactionRequest implements _TransactionRequest {
  _$_TransactionRequest(
      {this.scheme = 'ethereum',
      required this.targetAddress,
      this.functionName,
      this.prefix,
      this.chainId,
      final Map<String, dynamic> parameters = const {}})
      : _parameters = parameters;

  factory _$_TransactionRequest.fromJson(Map<String, dynamic> json) =>
      _$$_TransactionRequestFromJson(json);

  @override
  @JsonKey()
  final String scheme;
  @override
  final String targetAddress;
  @override
  final String? functionName;
  @override
  final String? prefix;
  @override
  final int? chainId;
  final Map<String, dynamic> _parameters;
  @override
  @JsonKey()
  Map<String, dynamic> get parameters {
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_parameters);
  }

  @override
  String toString() {
    return 'TransactionRequest(scheme: $scheme, targetAddress: $targetAddress, functionName: $functionName, prefix: $prefix, chainId: $chainId, parameters: $parameters)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_TransactionRequest &&
            (identical(other.scheme, scheme) || other.scheme == scheme) &&
            (identical(other.targetAddress, targetAddress) ||
                other.targetAddress == targetAddress) &&
            (identical(other.functionName, functionName) ||
                other.functionName == functionName) &&
            (identical(other.prefix, prefix) || other.prefix == prefix) &&
            (identical(other.chainId, chainId) || other.chainId == chainId) &&
            const DeepCollectionEquality()
                .equals(other._parameters, _parameters));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      scheme,
      targetAddress,
      functionName,
      prefix,
      chainId,
      const DeepCollectionEquality().hash(_parameters));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_TransactionRequestCopyWith<_$_TransactionRequest> get copyWith =>
      __$$_TransactionRequestCopyWithImpl<_$_TransactionRequest>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_TransactionRequestToJson(
      this,
    );
  }
}

abstract class _TransactionRequest implements TransactionRequest {
  factory _TransactionRequest(
      {final String scheme,
      required final String targetAddress,
      final String? functionName,
      final String? prefix,
      final int? chainId,
      final Map<String, dynamic> parameters}) = _$_TransactionRequest;

  factory _TransactionRequest.fromJson(Map<String, dynamic> json) =
      _$_TransactionRequest.fromJson;

  @override
  String get scheme;
  @override
  String get targetAddress;
  @override
  String? get functionName;
  @override
  String? get prefix;
  @override
  int? get chainId;
  @override
  Map<String, dynamic> get parameters;
  @override
  @JsonKey(ignore: true)
  _$$_TransactionRequestCopyWith<_$_TransactionRequest> get copyWith =>
      throw _privateConstructorUsedError;
}
