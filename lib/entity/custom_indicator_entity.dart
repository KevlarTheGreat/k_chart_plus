import 'custom_indicator.dart';

mixin CustomIndicatorEntity {
  // Map to store custom indicator data
  Map<String, CustomIndicatorData> indicatorDataMap = {};

  /// Method to initialize or add custom indicator data
  /// [customIndicatorTypes] is a map of custom indicator names and their types
  /// The method will initialize the custom indicator data with the right type of
  /// CustomIndicatorData based on the ChartType.  This will not override existing
  /// custom indicator data.
  void addCustomIndicators(
      {required Map<String, ChartType> customIndicatorTypes}) {
    customIndicatorTypes.forEach((name, chartType) {
      switch (chartType) {
        case ChartType.line:
          indicatorDataMap[name] = LineIndicatorData();
          break;
        case ChartType.candlestick:
          indicatorDataMap[name] = CandleIndicatorData();
          break;
        case ChartType.bar:
          indicatorDataMap[name] = BarIndicatorData();
          break;
      }
    });
  }
}

abstract class CustomIndicatorData {
  final ChartType chartType;

  CustomIndicatorData(this.chartType);
}

class LineIndicatorData extends CustomIndicatorData {
  double value;

  LineIndicatorData({this.value = 0.0}) : super(ChartType.line);
}

class CandleIndicatorData extends CustomIndicatorData {
  double open;
  double high;
  double low;
  double close;

  CandleIndicatorData({
    this.open = 0.0,
    this.high = 0.0,
    this.low = 0.0,
    this.close = 0.0,
  }) : super(ChartType.candlestick);
}

class BarIndicatorData extends CustomIndicatorData {
  double high;
  double low;

  BarIndicatorData({
    this.high = 0.0,
    this.low = 0.0,
  }) : super(ChartType.bar);
}
