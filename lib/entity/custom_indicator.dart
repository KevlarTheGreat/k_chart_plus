import 'k_line_entity.dart';

/// This class is used to define custom indicators
/// Custom indicators can be calculated based on the data of the KLineEntity
/// The custom indicator data is stored in the KLineEntity, using the name of
/// the custom indicator as the key, thus the name of the custom indicator must
/// be unique.  The initializer of this class will initialize the custom indicator
/// data with the right type of CustomIndicatorData based on the ChartType.
class CustomIndicator {
  final String name;
  final ChartType chartType;
  final Function(List<KLineEntity>) calculate;

  CustomIndicator({
    required this.name,
    required this.chartType,
    required this.calculate,
    required List<KLineEntity> data,
  }) {
    // Initialize custom indicator data
    for (var entity in data) {
      if (!entity.indicatorDataMap.containsKey(name)) {
        // If data doesn't already include this indicator name, add the
        // indicator name to the map
        entity.addCustomIndicators(customIndicatorTypes: {name: chartType});
      } else {
        throw ArgumentError(
            'CustomIndicator Constructor: Custom indicator data with name $name already exists.');
      }
    }
  }
}

enum ChartType {
  line,
  candlestick,
  bar,
  macd,
  // other chart types
}
