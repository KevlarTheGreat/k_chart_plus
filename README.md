# K Chart Plus Package

## Summary

This is the best k chart (candlestick chart) package for flutter.  It's powerful and and easy to use.  This fork started from TrangLeQuynh/k_chart_plus and added user-defined custom secondary indicator capability among several other features!

### Primary Features:  
**Primary Chart** with time and candlestick (K Line) modes.  Optional trendlines (Drawn, Moving Average, Bollinger, etc).  Optional Volume indicator.    
**Technical Indicators (built-in)** MACD, KDJ, RSI, WR, and CCI in separate chart panes.  
**NEW - Secondary Technial Indicators (Custom Defined)** Provide a callback function with your custom data analysis and it will show up in the secondary chart-type that you selected. So far, supports line chart and a two-value bar chart.  I will be adding more types and will take requests.  Every data point in each indicator has a custom color field so you can change the line or bar color dynamically.  
**UI Supports** Drag, scale, long press, and fling. Lanugauge customizations.   
**Other Enhancements** Indicators are automatically recalculated every time the widget is rebuit.  Added functions to simulate live data.

### Project Components:

KChartWidget: The main widget that provides charting functionality, including financial technical indicators.  
DepthChart:  A separate widget supplied from the same k chart package.  
Example Application: A sample app demonstrating how to use the KChartWidget and test its features.

### Implementation Steps:

Extend KChartWidget: Add parameters for custom indicator calculation and painting functions.  
Update DataUtil: Allow custom indicator calculation functions.  
Modify ChartPainter: Call custom painting functions.  
Implement in main.dart: Provide custom indicator calculation and painting functions when initializing KChartWidget.

### Examples With Two Custom Indicators (Line and Bar):

|Example1|Example2|
|:-------------------------:|:-------------------------:|
|![](assets/example_1.png)  |  ![](assets/example_2.png)|

## Installation

First, add `k_chart_plus` as a [dependency in your pubspec.yaml file](https://flutter.dev/using-packages/).

```yaml
k_chart_plus: ^1.0.2
```

## Usage

**Main Data and Chart Updates**
```dart
// Initialize your data
List<KLineEntity> data = .....
// Create a ValueNotifier to store the financial data
ValueNotifier<List<KLineEntity>> datasNotifier = ValueNotifier<List<KLineEntity>>([]);
// Set the "value" to a new list to trigger a rebuild and recalculation of indicators.
datasNotifier.value = data;
// WARNING:  Modifying individual elements of "value" will not trigger a rebuild, you can optionally modify "value" then call the following to trigger rebuild/calculation:
datasNotifier.value = List.from(datasNotifier.value);

// NOTE:  DataUtil.calculate() has been removed.  It is now called automatically upon rebuild of the widget.  The built-in secondary charts currently use the same settings as the widget / main indicators. 
```

### Use K line chart

```dart
KChartWidget(
    chartStyle, // Required for styling purposes
    chartColors,// Required for styling purposes
    datas,// Required，Data must be an ordered list，(history=>now)
    mBaseHeight: 360, //height of chart (not contain Vol and Secondary) 
    isLine: isLine,// Decide whether it is k-line or time-sharing
    mainState: _mainState,// Decide what the main view shows
    secondaryStateLi: _secondaryStateLi,// Decide what the sub view shows
    fixedLength: 2,// Displayed decimal precision
    timeFormat: TimeFormat.YEAR_MONTH_DAY,
    onLoadMore: (bool a) {},// Called when the data scrolls to the end. When a is true, it means the user is pulled to the end of the right side of the data. When a
    // is false, it means the user is pulled to the end of the left side of the data.
    maDayList: [5,10,20],// Display of MA,This parameter must be equal to DataUtil.calculate‘s maDayList
    volHidden: false,// hide volume
    showNowPrice: true,// show now price
    isOnDrag: (isDrag){},// true is on Drag.Don't load data while Draging.
    isTrendLine: false, // You can use Trendline by long-pressing and moving your finger after setting true to isTrendLine property. 
    xFrontPadding: 100 // padding in front
),
```
### Use Depth chart

```dart
DepthChart(_bids, _asks, chartColors) //Note: Datas must be an ordered list，
```

### Dark | Light Theme

`ChartColor` helped to set the color for the chart. You need to flexibly change according to your theme configuration to ensure UI.

>
> If you need to apply multi theme, you need to change at least the colors related to the text, border, grid and background color
>

```dart
late ThemeData themeData = Theme.of(context);
late ChartColors chartColors = ChartColors(
  bgColor: themeData.colorScheme.background,
  defaultTextColor: themeData.textTheme.labelMedium?.color ?? Colors.grey,
  gridColor: themeData.dividerColor,
  hCrossColor: themeData.textTheme.bodyMedium?.color ?? Colors.white,
  vCrossColor: themeData.disabledColor.withOpacity(.1),
  crossTextColor: themeData.textTheme.bodyMedium?.color ?? Colors.white,
  selectBorderColor: themeData.textTheme.bodyMedium?.color ?? Colors.black54,
  selectFillColor: themeData.colorScheme.background,
  infoWindowTitleColor: themeData.textTheme.labelMedium?.color ?? Colors.grey,
  infoWindowNormalColor: themeData.textTheme.bodyMedium?.color ?? Colors.white,
);
```


Apply in k line chart:

```dart

KChartWidget(
    data,
    ChartStyle(),
    ChartColors().init(), ///custom chart color
    chartTranslations: ChartTranslations(
        date: 'Date'
        open: 'Open',
        high: 'High',
        low: 'Low',
        close: 'Close'
        changeAmount: 'Change',
        change: 'Change%',
        amount: 'Amount',
        vol: 'Volume',
    ),
    mBaseHeight: 360,
    isTrendLine: false,
    mainState: mainState,
    secondaryStateLi: secondaryStates,
    fixedLength: 2,
    timeFormat: TimeFormat.YEAR_MONTH_DAY,
);
```

### Thanks

[gwhcn/flutter_k_chart](https://github.com/gwhcn/flutter_k_chart)

[OpenFlutter/k_chart](https://github.com/OpenFlutter/k_chart)
