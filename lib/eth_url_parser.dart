/// A Dart library for parsing and building Ethereum URIs according to
/// [EIP-681](https://eips.ethereum.org/EIPS/eip-681).
///
/// Parse a payment URI into a strongly-typed [TransactionRequest] with
/// [EthUrlParser.parse], or build one back into a URI with
/// [EthUrlParser.build]. All amounts are handled exactly via [BigInt] —
/// no wei is ever lost to floating-point precision.
library;

export 'src/models/models.dart';
export 'src/eth_url_parser_base.dart';
