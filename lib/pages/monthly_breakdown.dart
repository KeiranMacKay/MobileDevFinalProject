import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../database/db_helper.dart';

class MonthlyBreakdown extends StatefulWidget {
  const MonthlyBreakdown({super.key});

  @override
  State<MonthlyBreakdown> createState() => _MonthlyBreakdownState();
}

class _MonthlyBreakdownState extends State<MonthlyBreakdown> {
  final PageController _controller = PageController(viewportFraction: 0.75);
  int _currentIndex = 0;

  /// Months that actually exist in the DB
  List<int> monthKeys = [];

  /// month -> { personName: totalSpent }
  Map<int, Map<String, double>> totalsByMonth = {};

  /// month -> List<Expense>
  Map<int, List<Expense>> billsByMonth = {};

  @override
  void initState() {
    super.initState();
    _loadFromDB();
    _controller.addListener(() {
      final page = _controller.page;
      if (page == null) return;
      final newIndex = page.round();
      if (newIndex != _currentIndex) {
        setState(() => _currentIndex = newIndex);
      }
    });
  }

  // Load + process DB data
  Future<void> _loadFromDB() async {
    final expenses = await WalletFlowDB.instance.getRecentExpenses(limit: 5000);

    Map<int, Map<String, double>> tempTotals = {};
    Map<int, List<Expense>> tempBills = {};

    for (final e in expenses) {
      final dateObj = DateTime.tryParse(e.date);
      if (dateObj == null) continue;

      final month = dateObj.month;

      tempTotals.putIfAbsent(month, () => {});
      tempBills.putIfAbsent(month, () => []);

      // Add bill
      tempBills[month]!.add(e);

      // Sum per person
      tempTotals[month]!.update(e.name, (old) => old + e.price,
          ifAbsent: () => e.price);
    }

    setState(() {
      totalsByMonth = tempTotals;

      // Sort months in natural order (Jan → Dec)
      monthKeys = totalsByMonth.keys.toList()..sort();

      billsByMonth = tempBills;
    });
  }

  // UI
  @override
  Widget build(BuildContext context) {
    if (monthKeys.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("No expenses yet.")),
      );
    }

    final int month = monthKeys[_currentIndex];
    final String monthName = _monthName(month);

    return Scaffold(
      appBar: AppBar(title: const Text("Monthly Breakdown")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // PIE CHART
            SizedBox(
              height: 250,
              child: PageView.builder(
                controller: _controller,
                itemCount: monthKeys.length,
                itemBuilder: (context, index) {
                  final m = monthKeys[index];
                  return MonthlyPieChart(
                    monthName: _monthName(m),
                    totals: totalsByMonth[m]!,
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            // PEOPLE TOTALS
            _buildPeopleTotals(month),

            const SizedBox(height: 5),

            // BILL HISTORY
            Expanded(
              child: _buildBillHistory(month, monthName),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGETS
  Widget _buildPeopleTotals(int month) {
    final totals = totalsByMonth[month]!;
    final entries = totals.entries.toList();
    double width = (MediaQuery.of(context).size.width - 32) / 2;

    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueAccent),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: entries.length,
        itemExtent: width,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, i) {
          final person = entries[i].key;
          final total = entries[i].value;

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(person, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("\$${total.toStringAsFixed(2)}"),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBillHistory(int month, String monthName) {
    final bills = billsByMonth[month]!;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueAccent),
      ),
      child: Column(
        children: [
          Text(
            "$monthName Transaction History",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),

          Expanded(
            child: ListView.builder(
              itemCount: bills.length,
              itemBuilder: (context, i) {
                final b = bills[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${b.name}: ${b.place}",
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            b.date,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      Text("\$${b.price.toStringAsFixed(2)}"),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helpers
  String _monthName(int m) {
    const names = [
      "", "January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December"
    ];
    return names[m];
  }
}

// PIE CHART
class MonthlyPieChart extends StatelessWidget {
  final String monthName;
  final Map<String, double> totals;

  const MonthlyPieChart({
    super.key,
    required this.monthName,
    required this.totals,
  });

  @override
  Widget build(BuildContext context) {
    final entries = totals.entries.toList();

    final List<PieChartSectionData> sections = List.generate(entries.length, (i) {
      final amount = entries[i].value;

      return PieChartSectionData(
        color: Colors.primaries[i % Colors.primaries.length],
        value: amount,
        title: "",
        radius: 50,
      );
    });

    return Column(
      children: [
        SizedBox(
          height: 180,
          width: 180,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 35,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          monthName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ],
    );
  }
}
