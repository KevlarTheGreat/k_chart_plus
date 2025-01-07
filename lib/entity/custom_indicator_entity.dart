import 'dart:ui';

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
        case ChartType.macd:
          indicatorDataMap[name] = MACDIndicatorData();
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
  Color color;

  LineIndicatorData(
      {this.value = 0.0, this.color = const Color.fromARGB(255, 155, 5, 117)})
      : super(ChartType.line);
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
  double primary;
  double secondary;
  Color primaryColor;
  Color secondaryColor;

  BarIndicatorData({
    this.primary = -1.0, // Negative value to indicate no data
    this.secondary = -1.0, // Negative value to indicate no data
    this.primaryColor = const Color(0xff4c5c74),
    this.secondaryColor = const Color.fromARGB(255, 93, 16, 129),
  }) : super(ChartType.bar);
}

class MACDIndicatorData extends CustomIndicatorData {
  double dif;
  double dea;
  double macd;

  Color primaryColor;
  Color secondaryColor;

  MACDIndicatorData({
    this.dif = 0.0,
    this.dea = 0.0,
    this.macd = 0.0,
    this.primaryColor = const Color(0xff4c5c74),
    this.secondaryColor = const Color.fromARGB(255, 93, 16, 129),
  }) : super(ChartType.macd);
}
