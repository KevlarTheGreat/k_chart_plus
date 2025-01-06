// ignore_for_file: unreachable_switch_default

import 'package:flutter/material.dart';
import 'package:k_chart_plus/entity/index.dart';
import '../k_chart_widget.dart' show SecondaryState;
import 'base_chart_renderer.dart';

class SecondaryRenderer extends BaseChartRenderer<KLineEntity> {
  late double mMACDWidth;
  SecondaryState state;
  //TODO: Remove chartType from SecondaryRenderer
  ChartType? chartType; // ChartType if custom indicator, otherwise null
  String? indicatorName; // Custom indicator name, otherwise null
  final ChartStyle chartStyle;
  final ChartColors chartColors;

  SecondaryRenderer(
      Rect mainRect,
      double maxValue,
      double minValue,
      double topPadding,
      this.state,

      //TODO: Remove chartType from SecondaryRenderer
      /// ChartType if custom indicator, otherwise null
      this.chartType,

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
  }

  @override
  void drawChart(KLineEntity lastPoint, KLineEntity curPoint, double lastX,
      double curX, Size size, Canvas canvas) {
    if (chartType == null) {
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
      switch (chartType) {
        case ChartType.line:
          final lastIndicatorData =
              lastPoint.indicatorDataMap[indicatorName] as LineIndicatorData?;
          final curIndicatorData =
              curPoint.indicatorDataMap[indicatorName] as LineIndicatorData?;
          if (lastIndicatorData != null && curIndicatorData != null) {
            drawLine(
              lastIndicatorData.value,
              curIndicatorData.value,
              canvas,
              lastX,
              curX,
              this.chartColors.rsiColor,
            );
          }
          break;
        case ChartType.candlestick:
          break;
        case ChartType.bar:
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
  /// DEA: The signal line for the MACD.
  /// DIF: The the MACD line.
  void drawMACD(MACDEntity curPoint, Canvas canvas, double curX,
      MACDEntity lastPoint, double lastX) {
    final macd = curPoint.macd ?? 0;
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
    if (lastPoint.dif != 0) {
      drawLine(lastPoint.dif, curPoint.dif, canvas, lastX, curX,
          this.chartColors.difColor);
    }
    if (lastPoint.dea != 0) {
      drawLine(lastPoint.dea, curPoint.dea, canvas, lastX, curX,
          this.chartColors.deaColor);
    }
  }

  @override
  void drawText(Canvas canvas, KLineEntity data, double x) {
    List<TextSpan>? children;
    if (chartType == null) {
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
      switch (chartType) {
        case ChartType.line:
          final indicatorData =
              data.indicatorDataMap[indicatorName] as LineIndicatorData?;
          if (indicatorData != null) {
            children = [
              TextSpan(
                  text: "$indicatorName: ${format(indicatorData.value)}    ",
                  style: getTextStyle(this.chartColors.rsiColor)),
            ];
          }
          break;
        case ChartType.candlestick:
          break;
        case ChartType.bar:
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
