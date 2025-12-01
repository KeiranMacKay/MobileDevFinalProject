import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// Simple Bill model only for MonthlyBreakdown.
/// This is separate from the DB model used on Home.
class Bill {
  final String name;
  final String place;
  final String date;
  final double price;

  const Bill({
    required this.name,
    required this.place,
    required this.date,
    required this.price,
  });
}

// class for monthly data entry
class Entry {
  final String name;
  final double person1value;
  final double person2value;
  final List<Bill> bills;

  Entry(this.name, this.person1value, this.person2value, this.bills);
}

class MonthlyBreakdown extends StatefulWidget {
  const MonthlyBreakdown({super.key});

  @override
  State<MonthlyBreakdown> createState() => _MonthlyBreakdownState();
}

class _MonthlyBreakdownState extends State<MonthlyBreakdown> {
  final PageController _controller = PageController(viewportFraction: 0.75);
  int _currentIndex = 0;

  late final List<Entry> spendingData;

  @override
  void initState() {
    super.initState();

    // bills for display on each month (static / mock data)
    spendingData = [
      Entry('January', 1001.22, 999.99, const [
        Bill(name: 'Cheapy', place: 'Metro', date: 'Jan 5', price: 43.32),
        Bill(name: 'Spendy', place: 'Shell', date: 'Jan 12', price: 80.30),
      ]),
      Entry('February', 2002.11, 1001.22, const [
        Bill(name: 'Cheapy', place: 'Place.exe', date: 'Feb 2', price: 200.10),
      ]),
      Entry('March', 320.11, 1001.11, const [
        Bill(name: 'Spendy', place: 'ScamsRus', date: 'Mar 3', price: 6000.00),
      ]),
      Entry('April', 1001.22, 2222.22, const [
        Bill(
          name: 'Spendy',
          place: 'TotallyLegitCarpetCleaners',
          date: 'Apr 1',
          price: 224.11,
        ),
      ]),
      Entry('May', 747.33, 898.99, const [
        Bill(name: 'Cheapy', place: 'McDaniels', date: 'May 9', price: 420.69),
      ]),
      Entry('June', 3873.22, 232.99, const [
        Bill(
          name: 'Spendy',
          place: 'OTU Tuition',
          date: 'Jun 3',
          price: 101101.10,
        ),
        Bill(
          name: 'Cheapy',
          place: 'Bestest Buyers',
          date: 'Jun 12',
          price: 27.33,
        ),
        Bill(
          name: 'Cheapy',
          place: 'OnlyFans',
          date: 'Jun 20',
          price: 3452.22,
        ),
      ]),
    ];

    _controller.addListener(() {
      final newIndex = _controller.page!.round();
      if (newIndex != _currentIndex) {
        setState(() {
          _currentIndex = newIndex;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentEntry = spendingData[_currentIndex];

    return Scaffold(
      appBar: AppBar(title: const Text('Monthly Breakdown')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // pie chart
            SizedBox(
              height: 250,
              child: PageView.builder(
                controller: _controller,
                itemCount: spendingData.length,
                itemBuilder: (context, index) {
                  final entry = spendingData[index];
                  return Center(
                    child: MonthlyPieChart(entry: entry),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // info box for displaying value spending
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: Column(
                children: [
                  Text(
                    currentEntry.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          const Text(
                            'Person 1',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '\$${currentEntry.person1value.toStringAsFixed(2)}',
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text(
                            'Person 2',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '\$${currentEntry.person2value.toStringAsFixed(2)}',
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // scrolling transaction history
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
                    Center(
                      child: Text(
                        '${currentEntry.name} Transaction History',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Scrollbar(
                        child: ListView.builder(
                          itemCount: currentEntry.bills.length,
                          itemBuilder: (context, i) {
                            final bill = currentEntry.bills[i];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${bill.name}: ${bill.place}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        bill.date,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text('\$${bill.price.toStringAsFixed(2)}'),
                                ],
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

// reusable pie chart widget
class MonthlyPieChart extends StatelessWidget {
  final Entry entry;

  const MonthlyPieChart({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 180,
          width: 180,
          child: PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  color: Colors.blue,
                  value: entry.person1value,
                  title: '',
                  radius: 50,
                ),
                PieChartSectionData(
                  color: Colors.green,
                  value: entry.person2value,
                  title: '',
                  radius: 50,
                ),
              ],
              centerSpaceRadius: 35,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          entry.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
