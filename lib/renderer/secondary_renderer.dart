// ignore_for_file: unreachable_switch_default

import 'package:flutter/material.dart';
import 'package:k_chart_plus/entity/index.dart';
import '../k_chart_widget.dart' show SecondaryState;
import 'base_chart_renderer.dart';

class SecondaryRenderer extends BaseChartRenderer<KLineEntity> {
  late double mMACDWidth;
  late double barWidth;
  SecondaryState state;
  String? indicatorName; // Custom indicator name, otherwise null
  final ChartStyle chartStyle;
  final ChartColors chartColors;

  SecondaryRenderer(
      Rect mainRect,
      double maxValue,
      double minValue,
      double topPadding,
      this.state,

      /// The name of the custom indicator, otherwise null
      this.indicatorName,
      int fixedLength,
      this.chartStyle,
      this.chartColors)
      : super(
          chartRect: mainRect,
          maxValue: maxValue,
          minValue: minValue,
          topPadding: topPadding,
          fixedLength: fixedLength,
          gridColor: chartColors.gridColor,
        ) {
    mMACDWidth = this.chartStyle.macdWidth;
    barWidth = this.chartStyle.barWidth;
  }

  @override
  void drawChart(KLineEntity lastPoint, KLineEntity curPoint, double lastX,
      double curX, Size size, Canvas canvas) {
    if (indicatorName == null) {
      // Draw built-in indicator
      switch (state) {
        case SecondaryState.MACD:
          drawMACD(curPoint, canvas, curX, lastPoint, lastX);
          break;
        case SecondaryState.KDJ:
          drawLine(lastPoint.k, curPoint.k, canvas, lastX, curX,
              this.chartColors.kColor);
          drawLine(lastPoint.d, curPoint.d, canvas, lastX, curX,
              this.chartColors.dColor);
          drawLine(lastPoint.j, curPoint.j, canvas, lastX, curX,
              this.chartColors.jColor);
          break;
        case SecondaryState.RSI:
          drawLine(lastPoint.rsi, curPoint.rsi, canvas, lastX, curX,
              this.chartColors.rsiColor);
          break;
        case SecondaryState.WR:
          drawLine(lastPoint.r, curPoint.r, canvas, lastX, curX,
              this.chartColors.rsiColor);
          break;
        case SecondaryState.CCI:
          drawLine(lastPoint.cci, curPoint.cci, canvas, lastX, curX,
              this.chartColors.rsiColor);
          break;
        default:
          break;
      }
    } else {
      // Draw custom indicator
      CustomIndicatorData curIndicator =
          curPoint.indicatorDataMap[indicatorName]!;
      CustomIndicatorData lastIndicator =
          lastPoint.indicatorDataMap[indicatorName]!;
      switch (curIndicator.chartType) {
        case ChartType.line:
          final lastLineData = lastIndicator as LineIndicatorData?;
          final curLineData = curIndicator as LineIndicatorData?;
          if (lastLineData != null && curLineData != null) {
            drawLine(
              lastLineData.value,
              curLineData.value,
              canvas,
              lastX,
              curX,
              curLineData.color,
            );
          }
          break;
        case ChartType.candlestick:
          print('Candlestick chart type not yet supported');
          break;
        case ChartType.bar:
          drawBarChart(
              curPoint.indicatorDataMap[indicatorName] as BarIndicatorData,
              canvas,
              curX);
          break;
        case ChartType.macd:
          drawMACD(curPoint, canvas, curX, lastPoint, lastX,
              indicatorName: indicatorName);
          break;
        default:
          break;
      }
    }
  }

  /// Draw MACD line.
  /// The drawMACD function is responsible for drawing the MACD (Moving Average Convergence Divergence) line on a canvas. Here's a step-by-step explanation of how it works:
  /// Parameters:
  /// [curPoint]: The current MACD data point.
  /// [canvas]: The canvas on which to draw.
  /// [curX]: The x-coordinate for the current point.
  /// [lastPoint]: The previous MACD data point.
  /// [lastX]: The x-coordinate for the previous point.
  /// [indicatorName]: The name of the custom indicator, otherwise null.
  /// DEA: The signal line for the MACD.
  /// DIF: The the MACD line.
  void drawMACD(KLineEntity curPoint, Canvas canvas, double curX,
      KLineEntity lastPoint, double lastX,
      {String? indicatorName = null}) {
    double macd = curPoint.macd ?? 0;
    double curDif = curPoint.dif ?? 0;
    double curDea = curPoint.dea ?? 0;
    double lastDif = lastPoint.dif ?? 0;
    double lastDea = lastPoint.dea ?? 0;
    if (indicatorName != null) {
      // if indicatorName is not null, then use the custom MACD data
      final curCustData =
          curPoint.indicatorDataMap[indicatorName]! as MACDIndicatorData;
      final lastCustData =
          lastPoint.indicatorDataMap[indicatorName]! as MACDIndicatorData;
      macd = curCustData.macd;
      curDif = curCustData.dif;
      curDea = curCustData.dea;
      lastDif = lastCustData.dif;
      lastDea = lastCustData.dea;
    }
    //TODO: Setup custom colors for MACD
    double macdY = getY(macd);
    double r = mMACDWidth / 2;
    double zeroy = getY(0);
    if (macd > 0) {
      canvas.drawRect(Rect.fromLTRB(curX - r, macdY, curX + r, zeroy),
          chartPaint..color = this.chartColors.upColor);
    } else {
      canvas.drawRect(Rect.fromLTRB(curX - r, zeroy, curX + r, macdY),
          chartPaint..color = this.chartColors.dnColor);
    }
    if (lastDif != 0) {
      drawLine(lastDif, curDif, canvas, lastX, curX, this.chartColors.difColor);
    }
    if (lastDea != 0) {
      drawLine(lastDea, curDea, canvas, lastX, curX, this.chartColors.deaColor);
    }
  }

  /// Draw Bar Chart
  /// The drawBarChart function is responsible for drawing the
  /// bar chart on a canvas. Only positive values are drawn.  The larger of the
  /// two values is drawn first and the smaller values is drawn over the
  /// top of the larger value.
  void drawBarChart(BarIndicatorData curPoint, Canvas canvas, double curX) {
    final dataPrimary = curPoint.primary;
    final dataSecondary = curPoint.secondary;
    final primaryColor = curPoint.primaryColor;
    final secondaryColor = curPoint.secondaryColor;
    double primaryY = getY(dataPrimary);
    double secondaryY = getY(dataSecondary);
    double zeroY = getY(0);
    double spacing = 0.3;

    // Draw the primary and secondary bars side by side with the primary on the left
    if (dataPrimary > 0) {
      canvas.drawRect(
          Rect.fromLTRB(
              curX - barWidth - spacing, primaryY, curX - spacing, zeroY),
          chartPaint..color = primaryColor);
    }
    if (dataSecondary > 0) {
      canvas.drawRect(
          Rect.fromLTRB(
              curX + spacing, secondaryY, curX + barWidth + spacing, zeroY),
          chartPaint..color = secondaryColor);
    }
  }

  @override
  void drawText(Canvas canvas, KLineEntity data, double x) {
    List<TextSpan>? children;
    if (indicatorName == null) {
      switch (state) {
        case SecondaryState.MACD:
          children = [
            TextSpan(
                text: "MACD(12,26,9)    ",
                style: getTextStyle(this.chartColors.defaultTextColor)),
            if (data.macd != 0)
              TextSpan(
                  text: "MACD:${format(data.macd)}    ",
                  style: getTextStyle(this.chartColors.macdColor)),
            if (data.dif != 0)
              TextSpan(
                  text: "DIF:${format(data.dif)}    ",
                  style: getTextStyle(this.chartColors.difColor)),
            if (data.dea != 0)
              TextSpan(
                  text: "DEA:${format(data.dea)}    ",
                  style: getTextStyle(this.chartColors.deaColor)),
          ];
          break;
        case SecondaryState.KDJ:
          children = [
            TextSpan(
                text: "KDJ(9,1,3)    ",
                style: getTextStyle(this.chartColors.defaultTextColor)),
            if (data.macd != 0)
              TextSpan(
                  text: "K:${format(data.k)}    ",
                  style: getTextStyle(this.chartColors.kColor)),
            if (data.dif != 0)
              TextSpan(
                  text: "D:${format(data.d)}    ",
                  style: getTextStyle(this.chartColors.dColor)),
            if (data.dea != 0)
              TextSpan(
                  text: "J:${format(data.j)}    ",
                  style: getTextStyle(this.chartColors.jColor)),
          ];
          break;
        case SecondaryState.RSI:
          children = [
            TextSpan(
                text: "RSI(14):${format(data.rsi)}    ",
                style: getTextStyle(this.chartColors.rsiColor)),
          ];
          break;
        case SecondaryState.WR:
          children = [
            TextSpan(
                text: "WR(14):${format(data.r)}    ",
                style: getTextStyle(this.chartColors.rsiColor)),
          ];
          break;
        case SecondaryState.CCI:
          children = [
            TextSpan(
                text: "CCI(14):${format(data.cci)}    ",
                style: getTextStyle(this.chartColors.rsiColor)),
          ];
          break;
        default:
          break;
      }
    } else {
      CustomIndicatorData curIndicator = data.indicatorDataMap[indicatorName]!;
      switch (curIndicator.chartType) {
        case ChartType.line:
          final indicatorData = curIndicator as LineIndicatorData?;
          if (indicatorData != null) {
            children = [
              TextSpan(
                  text: "$indicatorName: ${format(indicatorData.value)}    ",
                  style: getTextStyle(indicatorData.color)),
            ];
          }
          break;
        case ChartType.candlestick:
          break;
        case ChartType.bar:
          final indicatorData = curIndicator as BarIndicatorData?;
          if (indicatorData != null) {
            children = [
              TextSpan(
                  text: "$indicatorName: ",
                  style: getTextStyle(this.chartColors.rsiColor)),
              TextSpan(
                  text: indicatorData.primary < 0
                      ? ""
                      : "P:${format(indicatorData.primary)}    ",
                  style: getTextStyle(indicatorData.primaryColor)),
              TextSpan(
                  text: indicatorData.secondary < 0
                      ? ""
                      : "S:${format(indicatorData.secondary)}",
                  style: getTextStyle(indicatorData.secondaryColor)),
            ];
          }
          break;
        case ChartType.macd:
          //TODO: Setup custom colors for MACD
          final indicatorData = curIndicator as MACDIndicatorData?;
          if (indicatorData != null) {
            children = [
              TextSpan(
                  text: "$indicatorName    ",
                  style: getTextStyle(this.chartColors.defaultTextColor)),
              if (indicatorData.macd != 0)
                TextSpan(
                    text: "MACD:${format(indicatorData.macd)}    ",
                    style: getTextStyle(this.chartColors.macdColor)),
              if (indicatorData.dif != 0)
                TextSpan(
                    text: "DIF:${format(indicatorData.dif)}    ",
                    style: getTextStyle(this.chartColors.difColor)),
              if (indicatorData.dea != 0)
                TextSpan(
                    text: "DEA:${format(indicatorData.dea)}    ",
                    style: getTextStyle(this.chartColors.deaColor)),
            ];
          }
          break;
        default:
          break;
      }
    }
    TextPainter tp = TextPainter(
        text: TextSpan(children: children ?? []),
        textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, Offset(x, chartRect.top - topPadding));
  }

  @override
  void drawVerticalText(canvas, textStyle, int gridRows) {
    TextPainter maxTp = TextPainter(
        text: TextSpan(text: "${format(maxValue)}", style: textStyle),
        textDirection: TextDirection.ltr);
    maxTp.layout();
    TextPainter minTp = TextPainter(
        text: TextSpan(text: "${format(minValue)}", style: textStyle),
        textDirection: TextDirection.ltr);
    minTp.layout();

    maxTp.paint(canvas,
        Offset(chartRect.width - maxTp.width, chartRect.top - topPadding));
    minTp.paint(canvas,
        Offset(chartRect.width - minTp.width, chartRect.bottom - minTp.height));
  }

  @override
  void drawGrid(Canvas canvas, int gridRows, int gridColumns) {
    // canvas.drawLine(Offset(0, chartRect.top), Offset(chartRect.width, chartRect.top), gridPaint); //hidden line
    canvas.drawLine(Offset(0, chartRect.bottom),
        Offset(chartRect.width, chartRect.bottom), gridPaint);
    double columnSpace = chartRect.width / gridColumns;
    for (int i = 0; i <= columnSpace; i++) {
      // Draw vertical lines in the secondary rect
      canvas.drawLine(Offset(columnSpace * i, chartRect.top - topPadding),
          Offset(columnSpace * i, chartRect.bottom), gridPaint);
    }
  }
}
