import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:k_chart_plus/k_chart_plus.dart';

///
/// High-level overview:
///
/// 1. **UI Structure**:
///    - Constructs a column of widgets that make up part of the app's UI.
///    - Includes a chart widget, titles, buttons, and a conditional container for displaying a depth chart.
///
/// 2. **KChartWidget**:
///    - The `KChartWidget` is a primary part of the UI, displaying a financial chart.
///    - Initialized with several parameters:
///      - `datas`: The data to be displayed on the chart.
///      - `chartStyle` and `chartColors`: Styling and color information for the chart.
///      - `mBaseHeight`: The base height of the chart.
///      - `isTrendLine`: A boolean indicating whether to show trend lines.
///      - `mainState`: The state of the main chart.
///      - `volHidden`: A boolean indicating whether the volume is hidden.
///      - `secondaryStateLi`: A set of secondary states for the chart.
///      - `fixedLength`: The number of decimal places to display.
///      - `timeFormat`: The format for displaying time on the chart.
///
/// 3. **Titles and Buttons**:
///    - `_buildTitle(context, 'VOL')`: Builds a title widget with the text 'VOL'.
///    - `buildVolButton()`: Presumably builds a button related to volume.
///    - `_buildTitle(context, 'Main State')`: Builds a title widget with the text 'Main State'.
///    - `buildMainButtons()`: Presumably builds buttons related to the main state.
///    - `_buildTitle(context, 'Secondary State')`: Builds a title widget with the text 'Secondary State'.
///    - `buildSecondButtons()`: Presumably builds buttons related to the secondary state.
///
/// 4. **Depth Chart**:
///    - A `Container` widget is conditionally displayed if `_bids` and `_asks` are not null.
///    - The container has a white background, a fixed height of 320, and takes the full width of its parent.
///    - Contains a `DepthChart` widget, initialized with `_bids`, `_asks`, and `chartColors`.
///
/// 5. **Loading Indicator**:
///    - If `showLoading` is true, a `Container` is displayed over the chart with a loading indicator.
///
/// 6. **Helper Method**:
///    - `_buildTitle(BuildContext context, String title)`: A helper method that creates a `Padding` widget
///       containing a `Text` widget styled with the app's theme.
///
/// 7. **Data Management**:
///    - The data for the `KChartWidget` (`datas`) and other widgets is managed within the state of the widget.
///    - The `_bids` and `_asks` lists are updated with new data, and `setState` is called to refresh the UI.
///
/// 8. **Loading Data**:
///    - `getChartDataFromJson()`: Asynchronously loads JSON data from the `assets/chartData.json` file.
///    - `solveChartData(String result)`: Parses the JSON data, converts it into a list of `KLineEntity` objects, and
///       calculates technical indicators using `DataUtil.calculate(datas!)`.
///    - The `datas` list is then updated with the calculated indicators, and `setState` is called to refresh the UI.
///
/// 9. **Calculating Indicators**:
///    - `DataUtil.calculate(datas!)`: This method calculates various technical indicators (e.g., Moving Average,
///       Bollinger Bands, MACD) for the `datas` list.
///    - The calculated indicators are stored in the properties of each `KLineEntity` object within the `datas` list.
///
/// 10. **Using Data in KChartWidget**:
///     - The `KChartWidget` uses the `datas` list, which now contains the calculated technical indicators, to render the financial chart.
///     - The widget displays the chart based on the provided data, styles, and states.
///
/// Overall, this file is responsible for constructing a section of the app's UI, including a financial chart, titles,
/// buttons, and a depth chart, based on the provided data and state. The `KChartWidget` is a central component,
/// displaying the financial data managed by the state of the widget. The data is loaded from a JSON file, parsed,
/// and processed to calculate technical indicators using the `DataUtil.calculate` method, and then used by the
///  `KChartWidget` to render the chart.

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //List<KLineEntity>? datas;
  ValueNotifier<List<KLineEntity>> datasNotifier =
      ValueNotifier<List<KLineEntity>>([]);
  bool showLoading = true;
  bool _volHidden = false;
  MainState _mainState = MainState.MA;
  // final Set<SecondaryState> _secondaryStateLi = <SecondaryState>{};
  final List<SecondaryState> _secondaryStateLi = [];
  List<DepthEntity>? _bids, _asks;

  ChartStyle chartStyle = ChartStyle();
  ChartColors chartColors = ChartColors();

  // Custom indicators
  late List<CustomIndicator> myCustomIndicators;

  // Debug timer
  double debugValue = 0.0;
  double debugPhase = 0.0;
  Timer? _debugTimer;

  // Periodic update timer for fake data
  bool _updatesEnabled = false;
  bool _sineEnabled = false;
  bool _pulseEnabled = false;
  Timer? _dataGenTimer;

  @override
  void initState() {
    super.initState();

    // Initialize custom indicators with an empty list
    myCustomIndicators = [];

    // Fetch initial data and initialize custom indicators
    _getData('1day').then((data) {
      datasNotifier.value = data;

      // Initialize custom indicators
      _initCustomIndicator();

      rootBundle.loadString('assets/depth.json').then((result) {
        final parseJson = json.decode(result);
        final tick = parseJson['tick'] as Map<String, dynamic>;
        final List<DepthEntity> bids = (tick['bids'] as List<dynamic>)
            .map<DepthEntity>(
                (item) => DepthEntity(item[0] as double, item[1] as double))
            .toList();
        final List<DepthEntity> asks = (tick['asks'] as List<dynamic>)
            .map<DepthEntity>(
                (item) => DepthEntity(item[0] as double, item[1] as double))
            .toList();
        initDepth(bids, asks);

        // Start the debug timer
        _debugTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
          if (_sineEnabled) {
            _sineWaveCandles();
          } else if (_pulseEnabled) {
            _pulseCandles();
          }
        });

        // Start simulating periodic random updates
        _dataGen();
        // Set showLoading to false after data is loaded
        setState(() {
          showLoading = false;
        });
      });
    });
  }

  _initCustomIndicator() {
    myCustomIndicators = [
      CustomIndicator(
        name: 'Half Close Price',
        chartType: ChartType.line,
        data: datasNotifier.value, // datas must be initialized before this
        calculate: (dataList) {
          for (var data in dataList) {
            // Calculate the custom indicator data
            final customValue = data.close * 0.5;
            // Modify the existing zero-initialized data
            (data.indicatorDataMap['Half Close Price'] as LineIndicatorData)
                .value = customValue;
          }
          /*
          for (var entity in data) {
            // Calculate the difference between the high and low prices
            final diff = (entity.high - entity.low) / 2;
            // Add 20% of the diff to the high price.
            entity.high = entity.high + diff * 2;
            // Subtract 20% of the diff from the low price.
            entity.low = entity.low - diff * 2;
          }
          */
        },
      ),
      CustomIndicator(
        name: 'Close Price',
        chartType: ChartType.bar,
        data: datasNotifier.value, // datas must be initialized before this
        calculate: (dataList) {
          double minValue = double.infinity;
          // Find the minimum close price
          for (var data in dataList) {
            if (data.close < minValue) {
              minValue = data.close;
            }
          }

          for (var data in dataList) {
            // Calculate the custom indicator data
            // Set the minimum close price as the base value
            final customValue = data.close - minValue;
            // Modify the existing initialized data
            final barData =
                data.indicatorDataMap['Close Price'] as BarIndicatorData;
            barData.primary = customValue;
            barData.secondary =
                customValue + customValue * (Random().nextDouble() - 0.5) * 0.6;
          }
        },
      ),
      // Add more custom indicators here
    ];
  }

  // So far, only needed to stop the debug timers
  @override
  void dispose() {
    _debugTimer?.cancel();
    _dataGenTimer?.cancel();
    super.dispose();
  }

  // Test function to create a sine wave pattern on the candles
  void _sineWaveCandles() {
    setState(() {
      debugValue += 0.04;
      if (debugValue > 1.0) {
        debugValue = -1.0;
      }

      debugPhase += 0.07;
      if (debugPhase > 2 * pi) {
        debugPhase = 0;
      }

      if (datasNotifier.value.isNotEmpty) {
        const amplitude = 60000.0; // Adjust the amplitude as needed
        const mid = amplitude / 2;
        const frequency = 0.1; // Adjust the frequency as needed
        for (int i = 0; i < datasNotifier.value.length; i++) {
          final entity = datasNotifier.value[i];
          entity.low = amplitude * sin(frequency * i - debugPhase) + mid;
          //entity.low = amplitude * sin(frequency * i) + mid;
          entity.open = entity.low;

          // In phase, positive / negative
          //entity.high = (entity.low + amplitude * 0.9 * debugValue) + mid;

          // Slightly out of phase
          //entity.high = amplitude * sin(frequency * i - debugPhase + 0.2 * pi) + mid;

          // Slightly different frequency
          entity.high =
              amplitude * sin((frequency + 0.05) * i - debugPhase) + mid;

          entity.close = entity.high;
        }
        // Update the list to trigger a rebuild
        datasNotifier.value = List.from(datasNotifier.value);
      }
    });
  }

  // Test function to pulse the candles
  void _pulseCandles() {
    setState(() {
      debugValue += 0.04;
      if (debugValue > 1.0) {
        debugValue = -1.0;
      }
      int scale = 1;
      debugValue = debugValue * scale;

      if (datasNotifier.value.isNotEmpty) {
        for (var entity in datasNotifier.value) {
          // Calculate the midpoint between the high and low prices
          final diff = (entity.high - entity.low) / 2;
          // Calculate the midpoint between the high and low prices
          final mid = entity.low + diff;
          // Set the close price to the midpoint plus the debug value
          entity.open = mid - diff * debugValue;
          // Subtract 20% of the diff from the low price.
          entity.close = mid + diff * debugValue;
        }
        // Update the list to trigger a rebuild
        datasNotifier.value = List.from(datasNotifier.value);
      }
    });
  }

  void initDepth(List<DepthEntity>? bids, List<DepthEntity>? asks) {
    if (bids == null || asks == null || bids.isEmpty || asks.isEmpty) return;
    _bids = [];
    _asks = [];
    double amount = 0.0;
    bids.sort((left, right) => left.price.compareTo(right.price));
    for (var item in bids.reversed) {
      amount += item.vol;
      item.vol = amount;
      _bids!.insert(0, item);
    }

    amount = 0.0;
    asks.sort((left, right) => left.price.compareTo(right.price));
    for (var item in asks) {
      amount += item.vol;
      item.vol = amount;
      _asks!.add(item);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder<List<KLineEntity>>(
        valueListenable: datasNotifier,
        builder: (context, datas, child) {
          return ListView(
            shrinkWrap: true,
            children: <Widget>[
              const SafeArea(bottom: false, child: SizedBox(height: 10)),
              Stack(children: <Widget>[
                KChartWidget(
                  datas: datas,
                  chartStyle: ChartStyle(),
                  chartColors: ChartColors(),
                  mBaseHeight: 360,
                  isTrendLine: false,
                  mainState: _mainState,
                  volHidden: _volHidden,
                  secondaryStateLi: _secondaryStateLi.toSet(),
                  fixedLength: 2,
                  timeFormat: TimeFormat.YEAR_MONTH_DAY,
                  customIndicators: myCustomIndicators,
                  maDayList: const [5, 10, 20],
                  n: 20,
                  k: 2,
                ),
                if (showLoading)
                  Container(
                    width: double.infinity,
                    height: 450,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(),
                  ),
              ]),
              _buildTitle(context, 'Settings'),
              _buildSettingsButtons(),
              _buildTitle(context, 'Main State'),
              _buildMainButtons(),
              _buildTitle(context, 'Secondary State'),
              _buildSecondButtons(),
              const SizedBox(height: 30),
              if (_bids != null && _asks != null)
                Container(
                  color: Colors.white,
                  height: 320,
                  width: double.infinity,
                  child: DepthChart(
                    _bids!,
                    _asks!,
                    ChartColors(),
                  ),
                ) // Other UI elements...
            ],
          );
        },
      ),
    );
  }

  Widget _buildTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 12, 15),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              // color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildSettingsButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            _buildButton(
              context: context,
              title: 'VOL',
              isActive: !_volHidden,
              onPress: () {
                setState(() {
                  _volHidden = !_volHidden;
                });
              },
            ),
            const SizedBox(width: 10),
            // Add a vertical divider between the buttons
            Container(
              width: 2,
              height: 25,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
            const SizedBox(width: 10),
            _buildButton(
              context: context,
              title: _updatesEnabled ? 'Stop DataGen' : 'Start DataGen',
              isActive: _updatesEnabled,
              onPress: () {
                setState(() {
                  _updatesEnabled = !_updatesEnabled;
                  if (_updatesEnabled) {
                    _sineEnabled = false;
                    _pulseEnabled = false;
                  }
                });
              },
            ),
            const SizedBox(width: 10), // Add some spacing between the buttons
            _buildButton(
              context: context,
              title: _sineEnabled ? 'Stop Sines' : 'Start Sines',
              isActive: _sineEnabled,
              onPress: () {
                setState(() {
                  _sineEnabled = !_sineEnabled;
                  if (_sineEnabled) {
                    _updatesEnabled = false;
                    _pulseEnabled = false;
                  }
                });
              },
            ),
            const SizedBox(width: 10), // Add some spacing between the buttons
            _buildButton(
              context: context,
              title: _pulseEnabled ? 'Stop Pulses' : 'Start Pulses',
              isActive: _pulseEnabled,
              onPress: () {
                setState(() {
                  _pulseEnabled = !_pulseEnabled;
                  if (_pulseEnabled) {
                    _updatesEnabled = false;
                    _sineEnabled = false;
                  }
                });
              },
            ),
            const SizedBox(width: 10),
            // Add a vertical divider between the buttons
            Container(
              width: 2,
              height: 25,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        alignment: WrapAlignment.start,
        spacing: 10,
        runSpacing: 10,
        children: MainState.values.map((e) {
          return _buildButton(
            context: context,
            title: e.name,
            isActive: _mainState == e,
            onPress: () => _mainState = e,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSecondButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        alignment: WrapAlignment.start,
        spacing: 10,
        runSpacing: 5,
        children: SecondaryState.values.map((e) {
          bool isActive = _secondaryStateLi.contains(e);
          return _buildButton(
            context: context,
            title: e.name,
            isActive: _secondaryStateLi.contains(e),
            onPress: () {
              if (isActive) {
                _secondaryStateLi.remove(e);
              } else {
                _secondaryStateLi.add(e);
              }
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required String title,
    required isActive,
    required Function onPress,
  }) {
    late Color? bgColor, txtColor;
    if (isActive) {
      bgColor = Theme.of(context).primaryColor.withValues(alpha: 0.15);
      txtColor = Theme.of(context).primaryColor;
    } else {
      bgColor = Colors.transparent;
      txtColor = Theme.of(context)
          .textTheme
          .bodyMedium
          ?.color
          ?.withValues(alpha: 0.75);
    }
    return InkWell(
      onTap: () {
        onPress();
        setState(() {});
      },
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
        ),
        constraints: const BoxConstraints(minWidth: 60),
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: txtColor,
              ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// Simulate periodic updates to the data
  void _dataGen() {
    _dataGenTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_updatesEnabled) {
        if (datasNotifier.value.isNotEmpty) {
          final lastEntity = datasNotifier.value.last;
          final newOpen = lastEntity.open +
              (Random().nextDouble() - 0.5) * lastEntity.close * 0.1;
          final newClose =
              newOpen + (Random().nextDouble() - 0.5) * newOpen * 0.2;
          final newEntity = KLineEntity.fromCustom(
            open: max(0, newOpen),
            close: max(0, newClose),
            // Set high to which ever is higher, the open or close price
            high: max(newOpen, newClose) + Random().nextDouble() * 1000,
            low: min(newOpen, newClose) - Random().nextDouble() * 1000,
            vol: (newOpen - newClose).abs() * 100000,
            time: lastEntity.time! + const Duration(days: 1).inMilliseconds,
            // Copy the custom indicator types from the last entity
            customIndicatorTypes: lastEntity.indicatorDataMap.map(
              (key, value) => MapEntry(key, value.chartType),
            ),
          );
          datasNotifier.value = List.from(datasNotifier.value)..add(newEntity);
        }
      }
    });
  }

  Future<List<KLineEntity>> _getData(String period) async {
    // Fetch data and populate the datas list
    final response = await rootBundle.loadString('assets/chartData.json');
    final Map<String, dynamic> jsonData = json.decode(response);
    final List<dynamic> dataList = jsonData['data']; // Extract the 'data' array
    return dataList.reversed.map((item) => KLineEntity.fromJson(item)).toList();
  }

  /* // Old code for fetching data from the internet
  void getData(String period) {
    final Future<String> future = getChartDataFromInternet(period);
    //final Future<String> future = getChatDataFromJson();
    future.then((String result) {
      solveChartData(result);
    }).catchError((_) {
      showLoading = false;
      setState(() {});
      debugPrint('### datas error $_');
    });
  }

  Future<String> getChartDataFromInternet(String? period) async {
    var url =
        'https://api.huobi.br.com/market/history/kline?period=${period ?? '1day'}&size=300&symbol=btcusdt';
    late String result;
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      result = response.body;
    } else {
      debugPrint('Failed getting IP address');
    }
    return result;
  }

  Future<String> getChartDataFromJson() async {
    return rootBundle.loadString('assets/chartData.json');
  }
  */

  void _solveChartData(String result) {
    final Map parseJson = json.decode(result) as Map<dynamic, dynamic>;
    final list = parseJson['data'] as List<dynamic>;
    datasNotifier.value = list
        .map((item) => KLineEntity.fromJson(item as Map<String, dynamic>))
        .toList()
        .reversed
        .toList()
        .cast<KLineEntity>();

    //DataUtil.calculate(datas!);
    showLoading = false;
    setState(() {});
  }
}
