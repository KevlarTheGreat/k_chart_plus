// ignore_for_file: non_constant_identifier_names,library_prefixes,unused_import,camel_case_types
mixin CandleEntity {
  late double open;
  late double high;
  late double low;
  late double close;

  List<double>? maValueList;

// Upper track line
  double? up;

// Middle track line
  double? mb;

// Lower track line
  double? dn;

  double? BOLLMA;

  // TBO Trend overlay values (precomputed by the host app).
  double? tboFast;
  double? tboSlow;
  double? tboUpper;
  double? tboLower;

  /// TBO regime code: 1 = bullish, 0 = neutral, -1 = bearish.
  int? tboRegime;
}
