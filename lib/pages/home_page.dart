import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../database/db_helper.dart';
import 'bill_info.dart';

/// Simple widget used to render a bill row (visual only).
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

/// Dummy account class used only for graph + header.
/// In a real version this would also come from DB.
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

  // initial mock data for chart / names
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

  final List<String> currentViewableMonths =
  const ['Jan', 'Feb', 'Mar', 'Apr', 'May'];
  final double graphMax = 10000.0;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    try {
      final expenses = await WalletFlowDB.instance.getRecentExpenses(limit: 50);
      setState(() {
        _recentExpenses = expenses;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('HomePage: error loading expenses: $e');
      setState(() {
        _recentExpenses = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final account = widget.testAccount;
    final peopleCount = account.userNames?.length ?? 0;
    final monthsCount = currentViewableMonths.length;

    // spacing calc
    final availableWidth = MediaQuery.of(context).size.width - 32;
    final tileWidth = availableWidth / 2;

    Widget buildPersonTile(int index) {
      final name = account.userNames?[index] ?? 'User';
      final lastMonthSpending =
          account.userSpending?[index][monthsCount - 1] ?? 0.0;

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

            // bar chart (still mock data, but dynamic)
            SizedBox(
              height: MediaQuery.of(context).size.height / 3,
              child: BarChart(
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
                            child: Text(
                              currentViewableMonths[value.toInt()],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: List.generate(monthsCount, (monthIndex) {
                    return BarChartGroupData(
                      x: monthIndex,
                      barRods: List.generate(peopleCount, (personIndex) {
                        final personSpending =
                            account.userSpending?[personIndex][monthIndex] ??
                                0;
                        final color = Colors
                            .primaries[personIndex % Colors.primaries.length];
                        return BarChartRodData(
                          toY: personSpending,
                          color: color,
                        );
                      }),
                      barsSpace: 2,
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 1),

            // values for current month
            if (peopleCount > 0)
              Column(
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
              ),
            const SizedBox(height: 1),

            // transaction history (from DB if available)
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
                          itemBuilder: (context, i) {
                            final expense = _recentExpenses[i];
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        BillInfoPage(
                                          expense: expense,
                                        ),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: BillRow(
                                  expense: expense,
                                ),
                              ),
                            );
                          },
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
}
