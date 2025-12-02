import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../database/db_helper.dart';

class BillRow extends StatelessWidget {
  final Expense expense;

  const BillRow({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${expense.name}: ${expense.place}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              expense.date,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        Text('\$${expense.price.toStringAsFixed(2)}'),
      ],
    );
  }
}

class Account {
  final String accountName;
  final List<String>? userNames;
  final List<List<double>>? userSpending;

  const Account({
    required this.accountName,
    this.userNames,
    this.userSpending,
  });
}

class HomePage extends StatefulWidget {
  HomePage({super.key});

  final Account testAccount = const Account(
    accountName: "The cheapies",
    userNames: ["Cheapy", "Spendy", "Wastey", "Hoardy", "Greedy", "John"],
    userSpending: [
      [1021.56, 1542.45, 648.10, 5460.90, 2121.22],
      [721.56, 542.45, 462.10, 3541.90, 1548.22],
      [1212.44, 1212.11, 564.33, 752.44, 2143.55],
      [23.23, 54.45, 76.23, 11.11, 45.43],
      [1.1, 2.2, 3.3, 4.4, 5.5, 6.6],
      [1000.1, 1000.1, 1000.1, 1000.1, 1000.1],
    ],
  );

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Expense> _recentExpenses = [];
  bool _isLoading = true;

  // month -> { personName : total }
  Map<int, Map<String, double>> _totalsByMonth = {};
  List<int> _monthKeys = [];
  Set<String> _allPeople = {};

  final double graphMax = 10000.0;

  bool get _hasDbData => _totalsByMonth.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    try {
      final expenses = await WalletFlowDB.instance.getRecentExpenses(limit: 5000);

      Map<int, Map<String, double>> tempTotals = {};
      Set<String> tempPeople = {};

      for (final e in expenses) {
        final dt = DateTime.tryParse(e.date);
        if (dt == null) continue;

        final month = dt.month;
        tempTotals.putIfAbsent(month, () => {});
        tempTotals[month]!.update(
          e.name,
          (old) => old + e.price,
          ifAbsent: () => e.price,
        );
        tempPeople.add(e.name);
      }

      setState(() {
        _recentExpenses = expenses;
        _totalsByMonth = tempTotals;
        _monthKeys = _totalsByMonth.keys.toList()..sort();
        _allPeople = tempPeople;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('HomePage: error loading expenses: $e');
      setState(() {
        _recentExpenses = [];
        _totalsByMonth = {};
        _monthKeys = [];
        _allPeople = {};
        _isLoading = false;
      });
    }
  }

  String _monthAbbrev(int m) {
    const names = [
      "",
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    if (m < 1 || m > 12) return "";
    return names[m];
  }

  @override
  Widget build(BuildContext context) {
    final account = widget.testAccount;
    final availableWidth = MediaQuery.of(context).size.width - 32;
    final tileWidth = availableWidth / 2;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue,
              child: Text(
                account.accountName[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Welcome ${account.accountName}',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Center(
              child: Text(
                'Monthly Spending',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 0),

            SizedBox(
              height: MediaQuery.of(context).size.height / 3,
              child: _hasDbData
                  ? _buildDbChart()
                  : _buildStaticChart(account),
            ),
            const SizedBox(height: 1),

            _hasDbData
                ? _buildDbCurrentMonth(tileWidth)
                : _buildStaticCurrentMonth(account, tileWidth),
            const SizedBox(height: 1),

            // Transaction history (DB)
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blueAccent),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        'Transaction History',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _recentExpenses.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No transactions yet.\nAdd a bill to see it here.',
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : Scrollbar(
                                  child: ListView.builder(
                                    itemCount: _recentExpenses.length,
                                    itemBuilder: (context, i) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      child: BillRow(
                                        expense: _recentExpenses[i],
                                      ),
                                    ),
                                  ),
                                ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───── DB-backed chart & current month ─────

  Widget _buildDbChart() {
    if (_monthKeys.isEmpty || _allPeople.isEmpty) {
      return const Center(child: Text('No data for chart yet.'));
    }

    List<int> viewMonths;
    if (_monthKeys.length <= 5) {
      viewMonths = List<int>.from(_monthKeys);
    } else {
      viewMonths = _monthKeys.sublist(_monthKeys.length - 5);
    }

    final people = _allPeople.toList()..sort();
    final monthsCount = viewMonths.length;
    final peopleCount = people.length;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: graphMax,
        gridData: FlGridData(show: false),
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < 0 || value.toInt() >= monthsCount) {
                  return const SizedBox.shrink();
                }
                final month = viewMonths[value.toInt()];
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(_monthAbbrev(month)),
                );
              },
            ),
          ),
        ),
        barGroups: List.generate(monthsCount, (monthIdx) {
          final month = viewMonths[monthIdx];
          final totalsForMonth = _totalsByMonth[month] ?? {};

          return BarChartGroupData(
            x: monthIdx,
            barsSpace: 2,
            barRods: List.generate(peopleCount, (personIdx) {
              final person = people[personIdx];
              final amount = totalsForMonth[person] ?? 0.0;
              final color =
                  Colors.primaries[personIdx % Colors.primaries.length];

              return BarChartRodData(
                toY: amount,
                color: color,
              );
            }),
          );
        }),
      ),
    );
  }

  Widget _buildDbCurrentMonth(double tileWidth) {
    final currentMonth = DateTime.now().month;
    final totals = _totalsByMonth[currentMonth] ?? {};

    if (totals.isEmpty) {
      return const SizedBox.shrink();
    }

    final entries = totals.entries.toList();

    return Column(
      children: [
        const Center(
          child: Text(
            'Your Spending This Month',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 1),
        Container(
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blueAccent),
          ),
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: entries.length,
            itemExtent: tileWidth,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final person = entries[index].key;
              final total = entries[index].value;
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      person,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 1),
                    Text('\$${total.toStringAsFixed(2)}'),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ───── static fallback chart & current month (no DB) ─────

  Widget _buildStaticChart(Account account) {
    final peopleCount = account.userNames?.length ?? 0;
    final monthsCount = account.userSpending?.first.length ?? 0;
    const labels = ['Jan', 'Feb', 'Mar', 'Apr', 'May'];

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: graphMax,
        gridData: FlGridData(show: false),
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= monthsCount) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(labels[value.toInt()]),
                );
              },
            ),
          ),
        ),
        barGroups: List.generate(monthsCount, (monthIndex) {
          return BarChartGroupData(
            x: monthIndex,
            barsSpace: 2,
            barRods: List.generate(peopleCount, (personIndex) {
              final personSpending =
                  account.userSpending?[personIndex][monthIndex] ?? 0;
              final color =
                  Colors.primaries[personIndex % Colors.primaries.length];
              return BarChartRodData(
                toY: personSpending,
                color: color,
              );
            }),
          );
        }),
      ),
    );
  }

  Widget _buildStaticCurrentMonth(Account account, double tileWidth) {
    final peopleCount = account.userNames?.length ?? 0;
    final monthsCount = account.userSpending?.first.length ?? 0;
    final currentMonthIndex = monthsCount - 1;

    if (peopleCount == 0) return const SizedBox.shrink();

    Widget buildPersonTile(int index) {
      final name = account.userNames?[index] ?? 'User';
      final lastMonthSpending =
          account.userSpending?[index][currentMonthIndex] ?? 0.0;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 1),
            Text('\$${lastMonthSpending.toStringAsFixed(2)}'),
          ],
        ),
      );
    }

    return Column(
      children: [
        const Center(
          child: Text(
            'Your Spending This Month',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 1),
        Container(
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blueAccent),
          ),
          height: 60,
          child: peopleCount == 1
              ? buildPersonTile(0)
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: peopleCount,
                  itemExtent: tileWidth,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return buildPersonTile(index);
                  },
                ),
        ),
      ],
    );
  }
}
