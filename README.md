# K Chart Package

## Feature

Maybe this is the best k chart in Flutter.Support drag,scale,long press,fling.And easy to use.

|Example1|Example2|
|:-------------------------:|:-------------------------:|
|![](assets/example_1.png)  |  ![](assets/example_2.png)|

## Installation

First, add `k_chart` as a [dependency in your pubspec.yaml file](https://flutter.dev/using-packages/).

```yaml
k_chart:
    git:
      url: https://github.com/TrangLeQuynh/k_chart
      ref: dev #name branch
```

> If you don't want to support selecting multiple secondary states, you need to use: ```ref: single```



## Usage

**When you change the data, you must call this:**
```dart
DataUtil.calculate(datas); //This function has some optional parameters: n is BOLL N-day closing price. k is BOLL param.
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

`ChartColor` helped to set the color for the chart. Use `extension` to edit the colors that need to be changed

```dart
ChartColors init() {
    ThemeData themeData = Theme.of(navigationService.getContext());
    bgColor = themeData.colorScheme.background;
    defaultTextColor = themeData.textTheme.bodyMedium?.color ?? const Color(0xff60738E);

    selectBorderColor = themeData.textTheme.bodyMedium?.color ?? Colors.black54;
    selectFillColor =  themeData.colorScheme.background;

    gridColor = themeData.dividerColor ?? const Color(0xff4c5c74);

    infoWindowNormalColor = themeData.textTheme.bodyMedium?.color ?? const Color(0xffffffff);
    infoWindowTitleColor = themeData.textTheme.bodyMedium?.color ?? const Color(0xffffffff);

    hCrossColor = themeData.textTheme.bodyMedium?.color ?? const Color(0xffffffff);
    vCrossColor = themeData.disabledColor.withOpacity(.1);
    crossTextColor = themeData.textTheme.bodyMedium?.color ?? const Color(0xffffffff);

    maxColor = themeData.textTheme.bodyMedium?.color ?? const Color(0xffffffff);
    minColor = themeData.textTheme.bodyMedium?.color ?? const Color(0xffffffff);
    return this;
}
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
