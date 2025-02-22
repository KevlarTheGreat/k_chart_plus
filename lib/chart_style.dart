import 'package:flutter/material.dart' show Color;

/// ChartColors
///
/// Note:
/// If you need to apply multi theme, you need to change at least the colors related to the text, border and background color
/// Ex:
/// Background: bgColor, selectFillColor
/// Border
/// Text
///
class ChartColors {
  /// the background color of base chart
  Color bgColor;

  Color kLineColor;

  ///
  Color lineFillColor;

  ///
  Color lineFillInsideColor;

  /// color: ma5, ma10, ma30, up, down, vol, macd, diff, dea, k, d, j, rsi
  Color ma5Color;
  Color ma10Color;
  Color ma30Color;
  Color upColor;
  Color dnColor;
  Color volColor;

  Color macdColor;
  Color difColor;
  Color deaColor;

  Color kColor;
  Color dColor;
  Color jColor;
  Color rsiColor;

  /// default text color: apply for text at grid
  Color defaultTextColor;

  /// color of the current price
  Color nowPriceUpColor;
  Color nowPriceDnColor;
  Color nowPriceTextColor;

  /// trend color
  Color trendLineColor;

  /// depth color
  Color depthBuyColor; //upColor
  Color depthBuyPathColor;
  Color depthSellColor; //dnColor
  Color depthSellPathColor;

  ///value border color after selection
  Color selectBorderColor;

  ///background color when value selected
  Color selectFillColor;

  ///color of grid
  Color gridColor;

  ///color of annotation content
  Color infoWindowNormalColor;
  Color infoWindowTitleColor;
  Color infoWindowUpColor;
  Color infoWindowDnColor;

  /// color of the horizontal cross line
  Color hCrossColor;

  /// color of the vertical cross line
  Color vCrossColor;

  /// text color
  Color crossTextColor;

  ///The color of the maximum and minimum values in the current display
  Color maxColor;
  Color minColor;

  /// get MA color via index
  Color getMAColor(int index) {
    switch (index % 3) {
      case 1:
        return ma10Color;
      case 2:
        return ma30Color;
      default:
        return ma5Color;
    }
  }

  /// constructor chart color
  ChartColors({
    this.bgColor = const Color(0xffffffff),
    this.kLineColor = const Color(0xff4C86CD),

    ///
    this.lineFillColor = const Color(0x554C86CD),

    ///
    this.lineFillInsideColor = const Color(0x00000000),

    ///
    this.ma5Color = const Color(0xffE5B767),
    this.ma10Color = const Color(0xff1FD1AC),
    this.ma30Color = const Color(0xffB48CE3),
    this.upColor = const Color(0xFF14AD8F),
    this.dnColor = const Color(0xFFD5405D),
    this.volColor = const Color(0xff2f8fd5),
    this.macdColor = const Color(0xff2f8fd5),
    this.difColor = const Color(0xffE5B767),
    this.deaColor = const Color(0xff1FD1AC),
    this.kColor = const Color(0xffE5B767),
    this.dColor = const Color(0xff1FD1AC),
    this.jColor = const Color(0xffB48CE3),
    this.rsiColor = const Color(0xffE5B767),
    this.defaultTextColor = const Color(0xFF909196),
    this.nowPriceUpColor = const Color(0xFF14AD8F),
    this.nowPriceDnColor = const Color(0xFFD5405D),
    this.nowPriceTextColor = const Color(0xffffffff),

    /// trend color
    this.trendLineColor = const Color(0xFFF89215),

    ///depth color
    this.depthBuyColor = const Color(0xFF14AD8F),
    this.depthBuyPathColor = const Color(0x3314AD8F),
    this.depthSellColor = const Color(0xFFD5405D),
    this.depthSellPathColor = const Color(0x33D5405D),

    ///value border color after selection
    this.selectBorderColor = const Color(0xFF222223),

    ///background color when value selected
    this.selectFillColor = const Color(0xffffffff),

    ///color of grid
    this.gridColor = const Color(0xFFD1D3DB),

    ///color of annotation content
    this.infoWindowNormalColor = const Color(0xFF222223),
    this.infoWindowTitleColor = const Color(0xFF4D4D4E), //0xFF707070
    this.infoWindowUpColor = const Color(0xFF14AD8F),
    this.infoWindowDnColor = const Color(0xFFD5405D),
    this.hCrossColor = const Color(0xFF222223),
    this.vCrossColor = const Color(0x28424652),
    this.crossTextColor = const Color(0xFF222223),

    ///The color of the maximum and minimum values in the current display
    this.maxColor = const Color(0xFF222223),
    this.minColor = const Color(0xFF222223),
  });
}

class ChartStyle {
  final double topPadding;

  final double bottomPadding;

  final double childPadding;

  ///point-to-point distance
  final double pointWidth;

  ///candle width
  final double candleWidth;
  final double candleLineWidth;

  ///vol column width
  final double volWidth;

  ///macd column width
  final double macdWidth;

  ///Bar column width
  final double barWidth;

  ///vertical-horizontal cross line width
  final double vCrossWidth;
  final double hCrossWidth;

  ///(line length - space line - thickness) of the current price
  final double nowPriceLineLength;
  final double nowPriceLineSpan;
  final double nowPriceLineWidth;

  final int gridRows;
  final int gridColumns;

  ///customize the time below
  final List<String>? dateTimeFormat;

  /// Override the background color
  final Color? backgroundColor;

  const ChartStyle({
    this.topPadding = 30.0,
    this.bottomPadding = 20.0,
    this.childPadding = 12.0,
    this.pointWidth = 11.0,
    this.candleWidth = 8.5,
    this.candleLineWidth = 1.0,
    this.volWidth = 8.5,
    this.macdWidth = 1.2,
    this.barWidth = 4,
    this.vCrossWidth = 8.5,
    this.hCrossWidth = 0.5,
    this.nowPriceLineLength = 4.5,
    this.nowPriceLineSpan = 3.5,
    this.nowPriceLineWidth = 1,
    this.gridRows = 4,
    this.gridColumns = 4,
    this.dateTimeFormat,
    this.backgroundColor,
  });
}
