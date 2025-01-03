import 'k_line_entity.dart';

class CustomIndicator {
  final String name;
  final ChartType chartType;
  final void Function(List<KLineEntity>) calculate;

  CustomIndicator({
    required this.name,
    required this.chartType,
    required this.calculate,
  });
}

enum ChartType {
  line,
  candlestick,
  bar,
  // other chart types
}
