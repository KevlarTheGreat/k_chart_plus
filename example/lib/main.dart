import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:k_chart_plus/k_chart_plus.dart';

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
  const MyHomePage({super.key, this.title});

  final String? title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // List of KLineEntity objects to store the financial data
  ValueNotifier<List<KLineEntity>> datasNotifier =
      ValueNotifier<List<KLineEntity>>([]);
  bool showLoading = true;
  bool _volHidden = false;
  MainState _mainState = MainState.MA;
  final List<SecondaryState> _secondaryStateList = [];
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

  // Boolean to control data source.
  // Set to true to use local data.
  // Set to false to use internet data.
  bool useLocalData = false;

  @override
  void initState() {
    super.initState();

    // Initialize custom indicators with an empty list
    myCustomIndicators = [];

    // Fetch initial data and initialize custom indicators
    getData('1day').then((data) {
      datasNotifier.value = data;

      // Initialize custom indicators
      //_initCustomIndicators();

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

  Future<List<KLineEntity>> getData(String period) async {
    if (useLocalData) {
      return _getDataFromFile();
    } else {
      return _getDataFromInternet(period);
    }
  }

  Future<List<KLineEntity>> _getDataFromFile() async {
    final response = await rootBundle.loadString('assets/chartData.json');
    final Map<String, dynamic> jsonData = json.decode(response);
    final List<dynamic> dataList = jsonData['data']; // Extract the 'data' array
    return dataList.reversed.map((item) => KLineEntity.fromJson(item)).toList();
  }

  Future<List<KLineEntity>> _getDataFromInternet(String period) async {
    var url =
        'https://api.huobi.br.com/market/history/kline?period=$period&size=300&symbol=btcusdt';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      if (jsonData['status'] == 'error') {
        throw Exception('Error from API: ${jsonData['err-msg']}');
      }
      final List<dynamic> dataList =
          jsonData['data']; // Extract the 'data' array
      return dataList.reversed
          .map((item) => KLineEntity.fromJson(item))
          .toList();
    } else {
      throw Exception('Failed to load data from the internet');
    }
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
          entity.open = entity.low;
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

  // Initialize the depth chart
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
                  secondaryStateLi: _secondaryStateList.toSet(),
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
              _buildTitle(context, 'Custom Indicators'),
              _buildCustomButtons(datas),
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
        child: Wrap(
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
            const SizedBox(width: 10),
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
            const SizedBox(width: 10),
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

  // Build main indicator buttons
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

  // Build secondary indicator buttons
  Widget _buildSecondButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        alignment: WrapAlignment.start,
        spacing: 10,
        runSpacing: 5,
        children: SecondaryState.values.map((e) {
          bool isActive = _secondaryStateList.contains(e);
          return _buildButton(
            context: context,
            title: e.name,
            isActive: _secondaryStateList.contains(e),
            onPress: () {
              if (isActive) {
                _secondaryStateList.remove(e);
              } else {
                _secondaryStateList.add(e);
              }
            },
          );
        }).toList(),
      ),
    );
  }

  // Build custom indicator buttons
  Widget _buildCustomButtons(List<KLineEntity> datas) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        alignment: WrapAlignment.start,
        spacing: 10,
        runSpacing: 5,
        children: [
          _buildCustomIndicatorButton(
              datas, 'Half Close Price 1', ChartType.line, _calcHalfClosePrice),
          _buildCustomIndicatorButton(datas, 'Close Price Noisy 2',
              ChartType.bar, _calcClosePriceNoisy),
          _buildCustomIndicatorButton(
              datas, 'Cust MACD 3', ChartType.macd, _calcCustMACD),
        ],
      ),
    );
  }

  // Custom indicator that calculates half the close price
  _calcHalfClosePrice(dataList, name) {
    for (var data in dataList) {
      // Calculate the custom indicator data
      final customValue = data.close * 0.5;
      // Modify the existing zero-initialized data
      (data.indicatorDataMap[name] as LineIndicatorData).value = customValue;
    }
  }

  // Custom indicator that adds noise to the close price
  _calcClosePriceNoisy(dataList, name) {
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
      final barData = data.indicatorDataMap[name] as BarIndicatorData;
      barData.primary = customValue;
      barData.secondary =
          customValue + customValue * (Random().nextDouble() - 0.5) * 0.6;
    }
  }

  // Custom MACD Indicator Demonstrating use of the built-in MACD calculation
  _calcCustMACD(dataList, name) {
    DataUtil.calcMACD(dataList, name: name);
  }

  Widget _buildCustomIndicatorButton(List<KLineEntity> datas, String name,
      ChartType chartType, Function(List<KLineEntity>, String) calculate) {
    bool isActive =
        myCustomIndicators.any((indicator) => indicator.name == name);
    //return ElevatedButton(
    return _buildButton(
      context: context,
      title: name,
      isActive: isActive,
      onPress: () {
        setState(() {
          if (isActive) {
            CustomIndicator indicator = myCustomIndicators
                .firstWhere((indicator) => indicator.name == name);
            indicator.removeIndicatorData(datas);
            myCustomIndicators.remove(indicator);
          } else {
            CustomIndicator indicator = CustomIndicator(
              name: name,
              chartType: chartType,
              calculate: calculate,
              data: datas,
            );
            myCustomIndicators.add(indicator);
          }
        });
      },
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
}
