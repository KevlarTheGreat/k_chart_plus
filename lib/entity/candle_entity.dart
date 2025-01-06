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
}
