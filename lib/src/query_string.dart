class QueryString {
  ///
  /// * Parses the given query string into a Map.
  ///
  static Map<String, String> parse(String query) {
    final search = RegExp('([^&=]+)=?([^&]*)');
    final result = <String, String>{};

    // Get rid off the beginning ? in query strings.
    if (query.startsWith('?')) query = query.substring(1);

    // Strict RFC 3986 percent-decoding: '+' is a literal plus, not a space —
    // the EIP-681 number grammar allows a leading '+' sign.
    String decode(String s) => Uri.decodeComponent(s);

    // Go through all the matches and build the result map.
    for (final match in search.allMatches(query)) {
      result[decode(match.group(1)!)] = decode(match.group(2)!);
    }

    return result;
  }
}
