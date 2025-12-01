import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

// account class pulled from home page
class Account extends StatelessWidget {
  final String accountName;
  final List<String>? userNames;
  final List<List<double>>? userSpending;

  const Account({
    super.key,
    required this.accountName,
    this.userNames,
    this.userSpending,
  });

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

// bill class
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

// class for montly entry
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

  //DATABASE CONNECTION POINT, if you can write into this class intance itll work perfectly
  // account information, totals are for each month
  final Account testAccount = const Account(
    accountName: "The cheapies",
    userNames: ["Cheapy", "Spendy", "Wastey", "Hoardy", "Greedy", "John"],
    userSpending: [
      [
        1021.56, 1542.45, 648.10, 5460.90, 2121.22, 240.21, 500.00, 430.20, 315.90, 800.75, 920.10, 1100.00,
      ],
      [
        721.56, 542.45, 462.10, 3541.90, 1548.22, 320.01, 900.00, 650.50, 710.25, 1230.40, 1345.80, 1500.00,
      ],
      [
        1212.44, 1212.11, 564.33, 752.44, 2143.55, 234.66, 430.00, 510.10, 600.00, 720.30, 845.60, 900.00,
      ],
      [
        23.23, 54.45, 76.23, 11.11, 45.43, 44.33, 60.00, 55.55, 70.70, 80.80, 95.95, 100.00,
      ],
      [
        1.1, 2.2, 3.3, 4.4, 5.5, 6.6, 7.7, 8.8, 9.9, 10.1, 11.2, 12.3,
      ],
      [
        1000.1, 1000.1, 1000.1, 1000.1, 1000.1, 1000.1, 1000.1, 1000.1, 1000.1, 1000.1, 1000.1, 1000.1,
      ],
    ],
  );

  @override
  void initState() {
    super.initState();

    // DATABAsE CONNECTION POINT, sam idea write into this list from DB and we are cooking=
    // bill data for each month
    spendingData = [
      Entry('January', 0, 0, const [
        Bill(name: 'Cheapy', place: 'Oh Yeah Yeah Outfitters', date: 'Jan 5', price: 43.32),
        Bill(name: 'Spendy', place: 'Oh No No Hitman', date: 'Jan 12', price: 8008.30),
      ]),
      Entry('February', 0, 0, const [
        Bill(name: 'Cheapy', place: 'Place.exe', date: 'Feb 2', price: 200.10),
      ]),
      Entry('March', 0, 0, const [
        Bill(name: 'Spendy', place: 'ScamsRus', date: 'Mar 3', price: 6000.00),
      ]),
      Entry('April', 0, 0, const [
        Bill(name: 'Spendy', place: 'TotallyLegitCarpetCleaners', date: 'Apr 1', price: 224.11,),
      ]),
      Entry('May', 0, 0, const [
        Bill(name: 'Cheapy', place: 'McDaniels', date: 'May 9', price: 420.69),
      ]),
      Entry('June', 0, 0, const [
        Bill(name: 'Cheapy', place: 'OnlyFans', date: 'Jun 20', price: 3452.22),
      ]),
      Entry('July', 0, 0, const [
        Bill(name: 'Cheapy', place: 'Costcon', date: 'Jul 4', price: 210.50),
      ]),
      Entry('August', 0, 0, const [
        Bill(name: 'Spendy', place: 'Basozon', date: 'Aug 15', price: 350.00),
      ]),
      Entry('September', 0, 0, const [
        Bill(name: 'Cheapy', place: 'Some Frills', date: 'Sep 9', price: 75.25),
      ]),
      Entry('October', 0, 0, const [
        Bill(name: 'Spendy', place: 'Bestest Buy', date: 'Oct 20', price: 899.99),
      ]),
      Entry('November', 0, 0, const [
        Bill(name: 'Cheapy', place: 'Floormart', date: 'Nov 11', price: 120.45),
      ]),
      Entry('December', 0, 0, const [
        Bill(name: 'Spendy', place: 'John and Bashers', date: 'Dec 24', price: 650.75),
      ]),
    ];

    _controller.addListener(() {
      final page = _controller.page;
      if (page == null) return;
      final newIndex = page.round();
      if (newIndex != _currentIndex) {
        setState(() => _currentIndex = newIndex);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentEntry = spendingData[_currentIndex];

    final userNames = testAccount.userNames!;
    final userSpending = testAccount.userSpending!;
    final peopleCount = userNames.length;

    final double availableWidth = MediaQuery.of(context).size.width - 32;
    final double tileWidth = availableWidth / 2;

    Widget buildPersonTile(int index, int month) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              userNames[index],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '\$${userSpending[index][month].toStringAsFixed(2)}',
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Monthly Breakdown')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [

            // creating pie charts
            SizedBox(
              height: 250,
              child: PageView.builder(
                controller: _controller,
                itemCount: spendingData.length,
                itemBuilder: (context, index) {
                  return MonthlyPieChart(
                    monthName: spendingData[index].name,
                    account: testAccount,
                    monthIndex: index,
                  );
                },
              ),
            ),
            const SizedBox(height: 10),

            // scroll box, basically whats on the home page but for eaach month
            Container(
              height: 55,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blueAccent),
              ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: peopleCount,
                itemExtent: tileWidth,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) =>
                    buildPersonTile(index, _currentIndex),
              ),
            ),
            const SizedBox(height: 1),

            // bill history per month
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blueAccent),
                ),
                child: Column(
                  children: [
                    Text(
                      '${currentEntry.name} Transaction History',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),

                    Expanded(
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${bill.name}: ${bill.place}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text(bill.date,
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.grey)),
                                  ],
                                ),
                                Text('\$${bill.price.toStringAsFixed(2)}'),
                              ],
                            ),
                          );
                        },
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




// use for makingn pie charts
class MonthlyPieChart extends StatelessWidget {
  final String monthName;
  final Account account;
  final int monthIndex;

  const MonthlyPieChart({
    super.key,
    required this.monthName,
    required this.account,
    required this.monthIndex,
  });

  @override
  Widget build(BuildContext context) {
    final userSpending = account.userSpending!;
    final peopleCount = userSpending.length;

    final List<PieChartSectionData> sections = List.generate(peopleCount, (i) {
      return PieChartSectionData(
        color: Colors.primaries[i % Colors.primaries.length],
        value: userSpending[i][monthIndex],
        title: '',
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
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        )
      ],
    );
  }
}
